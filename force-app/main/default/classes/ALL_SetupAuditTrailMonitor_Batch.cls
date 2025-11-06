public class ALL_SetupAuditTrailMonitor_Batch implements Database.Batchable<SObject>, Database.Stateful {

    private String query;
    private List<String> emailMessages = new List<String>();
    private List<String> keywords;
    private List<String> recipients;
    private Set<String> excludedUsers;
    private Date startDate;

    public ALL_SetupAuditTrailMonitor_Batch() {
        loadMetadataConfig();
        buildQuery();
    }

    private void loadMetadataConfig() {
        keywords       = new List<String>();
        recipients     = new List<String>();
        excludedUsers  = new Set<String>();
        Boolean hasStartDate = false;

        for (ALL_AuditTrailConfig__mdt cfg : [
            SELECT Keyword__c, Recipients__c, Start_Date__c, Exclude_Users__c
            FROM   ALL_AuditTrailConfig__mdt
            WHERE Active__c = true
        ]) {
            if (String.isNotBlank(cfg.Keyword__c)) {
                for (String kw : cfg.Keyword__c.split(';')) {
                    if (String.isNotBlank(kw)) {
                        keywords.add(kw.trim().toLowerCase());
                    }
                }
            }

            if (String.isNotBlank(cfg.Recipients__c)) {
                for (String mail : cfg.Recipients__c.split(';')) {
                    if (String.isNotBlank(mail)) {
                        recipients.add(mail.trim());
                    }
                }
            }

            if (String.isNotBlank(cfg.Exclude_Users__c)) {
                for (String usr : cfg.Exclude_Users__c.split(';')) {
                    if (String.isNotBlank(usr)) {
                        excludedUsers.add(usr.trim().toLowerCase());
                    }
                }
            }

            if (cfg.Start_Date__c != null && !hasStartDate) {
                startDate   = cfg.Start_Date__c;
                hasStartDate = true;
            }
        }

        if (!hasStartDate) {
            startDate = Date.today().addDays(-7);
        }
    }

    private void buildQuery() {
        query = 'SELECT Id, Action, CreatedById, CreatedDate, Display FROM SetupAuditTrail';
        if (startDate != null) {
            query += ' WHERE CreatedDate >= :startDate';
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SetupAuditTrail> scope) {
        if (scope.isEmpty()) return;

        Set<Id> uIds = new Set<Id>();
        for (SetupAuditTrail row : scope) {
            uIds.add(row.CreatedById);
        }

        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Name, Username FROM User WHERE Id IN :uIds
        ]);

        System.debug('-----userMap.size(): ' + userMap.size());
        for (String key: userMap.keySet()) {
            System.debug('-----userMap key: ' + key);
            System.debug('-----userMap values(1): ' + userMap.get(key));
        }

        process(scope, userMap);
    }

    private void process(List<SetupAuditTrail> rows, Map<Id, User> users) {
        for (SetupAuditTrail row : rows) {
            if (String.isBlank(row.Display)) continue;

            User rowUser = users.get(row.CreatedById);
            String usernameLower = rowUser != null ? rowUser.Username.toLowerCase() : '';
            if (excludedUsers.contains(usernameLower)) continue;

            String d = row.Display.toLowerCase();
            for (String kw : keywords) {
                if (d.contains(kw)) {
                    String uName = rowUser != null ? rowUser.Name : 'Unknown';
                    emailMessages.add(buildRow(row, uName));
                    break;
                }
            }
        }
    }

    private String buildRow(SetupAuditTrail row, String uName) {
        return '<tr>' +
               '<td>' + row.Action + '</td>' +
               '<td>' + uName + '</td>' +
               '<td>' + row.CreatedDate.format() + '</td>' +
               '<td>' + row.Display + '</td>' +
               '</tr>';
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('[FINISH] Email recipients: ' + recipients);
        System.debug('[FINISH] Messages to send: ' + emailMessages.size());
        System.debug('[FINISH] Audit records filtered from date: ' + startDate);
        System.debug('[FINISH] Excluded usernames: ' + excludedUsers);

        if (recipients.isEmpty() || emailMessages.isEmpty()) {
            System.debug('[FINISH] No email sent – recipients or messages empty.');
            System.debug('[FINISH] Batch job complete.');
            return;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(recipients);
        mail.setSubject('Setup Audit Trail Report – ' + DateTime.now().format('yyyy-MM-dd HH:mm'));

        String instanceName = System.URL.getOrgDomainUrl().getHost();
        String orgId        = UserInfo.getOrganizationId();

        // OrgWideEmailAddress owea = [
        //     SELECT Id FROM OrgWideEmailAddress
        //     WHERE Address = 'no-reply.salesforce@cloud.kiongroup.com'
        //     LIMIT 1];
        // mail.setOrgWideEmailAddressId(owea.Id);

        List<User> exUsrList = [SELECT Name, Username FROM User WHERE Username IN :excludedUsers];
        List<String> excludedNames = new List<String>();
        for (User u : exUsrList) {
            excludedNames.add(u.Name);
        }

        for (String u : excludedUsers) {
            Boolean found = false;
            for (User ux : exUsrList) {
                if (ux.Username.equalsIgnoreCase(u)) { found = true; break; }
            }
            if (!found) excludedNames.add(u);
        }

        String htmlBody = '<html><body>' +
                          '<h2>Setup Audit Trail Monitor Report</h2>' +
                          '<p><strong>Instance:</strong> ' + instanceName + '</p>' +
                          '<p><strong>Org Id:</strong> ' + orgId + '</p>' +
                          '<p><strong>Keywords:</strong> ' + String.join(new List<String>(keywords), ', ') + '</p>' +
                          '<p><strong>Excluded Users:</strong> ' + String.join(excludedNames, ', ') + '</p>' +
                          '<br/>' +
                          '<table border="1" cellpadding="5" cellspacing="0">' +
                          '<tr><th>Action</th><th>User</th><th>Date</th><th>Display</th></tr>' +
                          String.join(emailMessages, '') +
                          '</table>' +
                          '</body></html>';

        System.debug('-----htmlBody: ' + htmlBody);

        mail.setHtmlBody(htmlBody);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        System.debug('[FINISH] Email sent to: ' + recipients);
        System.debug('[FINISH] Batch job complete.');
    }
    /*
    Database.executeBatch(new ALL_SetupAuditTrailMonitor_Batch(), 200);
    */
}