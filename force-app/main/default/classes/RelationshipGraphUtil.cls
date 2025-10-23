public with sharing class RelationshipGraphUtil {
    public class ArgumentException extends Exception {}

    public class Options {
        public Integer maxDepth = 5;
        public Boolean includePolymorphic = false;
        public Set<String> excludeExact = new Set<String>{
            'Task','Event','Activity','ContentDocument','ContentVersion','ContentNote',
            'ContentDocumentLink','FeedItem','FeedComment','FeedTrackedChange','EmailMessage',
            'EmailMessageRelation','EmailMessageAttachment'
        };
        public Set<String> excludeSuffix = new Set<String>{ 'History','Share','ChangeEvent','Tag','Feed' };
        public Set<String> excludeObjects = new Set<String>();
    }

    public class Node {
        public String objectApiName;
        public List<Map<String, Object>> children = new List<Map<String, Object>>();
    }

    private static Map<String, Schema.SObjectType> GD;
    private static Map<String, List<Map<String, Object>>> EDGES_CACHE;
    private static Map<String, Node> NODE_CACHE;
    private static Options OPT;

    public static String buildChildGraphJson(String rootObjectApiName) {
        return buildChildGraphJson(rootObjectApiName, new Options());
    }
    public static String buildChildGraphJson(String rootObjectApiName, Integer maxDepth) {
        Options o = new Options();
        if (maxDepth != null && maxDepth > 0) o.maxDepth = maxDepth;
        return buildChildGraphJson(rootObjectApiName, o);
    }
    public static String buildChildGraphJson(String rootObjectApiName, Options options) {
        if (String.isBlank(rootObjectApiName)) throw new ArgumentException('rootObjectApiName is required');
        if (options == null) options = new Options();

        GD = Schema.getGlobalDescribe();
        Schema.SObjectType sType = getTypeStrict(GD, rootObjectApiName);
        if (sType == null) throw new ArgumentException('Unknown sObject: ' + rootObjectApiName);

        OPT = options;
        EDGES_CACHE = new Map<String, List<Map<String, Object>>>();
        NODE_CACHE  = new Map<String, Node>();

        Set<String> path = new Set<String>();
        Node root = buildNode(sType, 0, path);
        return JSON.serializePretty(root);
    }

    private static Node buildNode(Schema.SObjectType sType, Integer depth, Set<String> path) {
        String apiName = String.valueOf(sType);
        String memoKey = apiName + '|' + String.valueOf(OPT.maxDepth - depth);
        Node cached = NODE_CACHE.get(memoKey);
        if (cached != null) return cached;

        Node node = new Node();
        node.objectApiName = apiName;

        Schema.DescribeSObjectResult d = tryDescribe(sType);
        if (d == null || !d.isAccessible() || isExcluded(apiName) || depth >= OPT.maxDepth) {
            NODE_CACHE.put(memoKey, node);
            return node;
        }

        if (path.contains(apiName)) {
            NODE_CACHE.put(memoKey, node);
            return node;
        }
        path.add(apiName);

        List<Map<String, Object>> edges = getEdgesForParent(apiName, sType, depth); // depth passed in
        if (edges != null && !edges.isEmpty()) {
            for (Map<String, Object> edge : edges) {
                String childApi = (String) edge.get('object');
                if (isExcluded(childApi)) continue;

                Schema.SObjectType childType = getTypeStrict(GD, childApi);
                if (childType == null) continue;

                Node childNode = buildNode(childType, depth + 1, path);

                Map<String, Object> edgeOut = new Map<String, Object>();
                edgeOut.putAll(edge);
                edgeOut.put('node', childNode);

                node.children.add(edgeOut);
            }
        }

        path.remove(apiName);
        NODE_CACHE.put(memoKey, node);
        return node;
    }

    private static List<Map<String, Object>> getEdgesForParent(String parentApi, Schema.SObjectType parentType, Integer depth) {
        // Cache by parent only; depth-based filtering is applied inline below.
        List<Map<String, Object>> cached = EDGES_CACHE.get(parentApi);
        List<Map<String, Object>> edges;
        if (cached != null) {
            edges = new List<Map<String, Object>>();
            edges.addAll(cached);
        } else {
            edges = new List<Map<String, Object>>();
            Schema.DescribeSObjectResult pd = tryDescribe(parentType);
            if (pd != null && pd.isAccessible()) {
                for (Schema.ChildRelationship cr : pd.getChildRelationships()) {
                    Schema.SObjectType childType = cr.getChildSObject();
                    if (childType == null) continue;

                    Schema.DescribeSObjectResult cd = tryDescribe(childType);
                    if (cd == null || !cd.isAccessible()) continue;

                    Schema.SObjectField f = cr.getField();
                    if (f == null) continue;

                    String childApi = String.valueOf(childType);
                    if (isExcluded(childApi)) continue;

                    Map<String, Object> edge = new Map<String, Object>();
                    edge.put('object', childApi);
                    edge.put('viaField', String.valueOf(f)); // e.g. Contact.AccountId
                    edge.put('relationshipName', cr.getRelationshipName());
                    edge.put('cascadeDelete', cr.isCascadeDelete());
                    Boolean isJunction = (cr.getJunctionIdListNames() != null && !cr.getJunctionIdListNames().isEmpty());
                    edge.put('isJunction', isJunction);
                    if (isJunction) edge.put('junctionIdListNames', cr.getJunctionIdListNames());
                    edge.put('polymorphic', false);
                    edges.add(edge);
                }
            }
            EDGES_CACHE.put(parentApi, edges);
        }

        // FIRST-LEVEL FILTER: keep only edges where field is custom (__c) OR child object is custom (__c)
        if (depth == 0) {
            List<Map<String, Object>> filtered = new List<Map<String, Object>>();
            for (Map<String, Object> e : edges) {
                String childApi = (String)e.get('object');
                String viaFieldFull = (String)e.get('viaField');      // "Child.Field"
                String fieldName = viaFieldFull != null
                    ? viaFieldFull.substring(viaFieldFull.lastIndexOf('.') + 1)
                    : null;

                Boolean childIsCustom = isCustomApi(childApi);
                Boolean fieldIsCustom = (fieldName != null && fieldName.endsWith('__c'));

                if (childIsCustom || fieldIsCustom) {
                    filtered.add(e);
                }
            }
            edges = filtered;
        }

        return edges;
    }

    private static Boolean isExcluded(String api) {
        if (OPT.excludeExact.contains(api)) return true;
        if (OPT.excludeObjects.contains(api)) return true;
        for (String suf : OPT.excludeSuffix) if (api.endsWith(suf)) return true;
        return false;
    }
    private static Boolean isCustomApi(String api) {
        return api != null && api.endsWith('__c');
    }

    private static Schema.DescribeSObjectResult tryDescribe(Schema.SObjectType t) {
        try { return t.getDescribe(); } catch (Exception e) { return null; }
    }
    private static Schema.DescribeFieldResult tryDescribe(Schema.SObjectField f) {
        try { return f.getDescribe(); } catch (Exception e) { return null; }
    }
    private static Schema.SObjectType getTypeStrict(Map<String, Schema.SObjectType> all, String apiName) {
        if (String.isBlank(apiName)) return null;
        Schema.SObjectType t = all.get(apiName);
        if (t != null) return t;
        for (String key : all.keySet()) if (key != null && key.equalsIgnoreCase(apiName)) return all.get(key);
        return null;
    }
    private static List<Map<String, Object>> ensureList(
        Map<String, List<Map<String, Object>>> registry, String key
    ) {
        List<Map<String, Object>> lst = registry.get(key);
        if (lst == null) {
            lst = new List<Map<String, Object>>();
            registry.put(key, lst);
        }
        return lst;
    }
}