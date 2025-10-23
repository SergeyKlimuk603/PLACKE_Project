public without sharing class PLCK_TriggerFactory {

    private static Set<Type> bypassSet;

    private PLCK_TriggerFactory() {}

    private static PLCK_TriggerHandler createHandler(Type t) {
        Object handler = t.newInstance();
        if (!(handler instanceof PLCK_TriggerHandler)) {
            throw new PLCK_TriggerFactory.TriggerFactoryException('No PLCK_TriggerHandler named \'' + t.getName() + '\' found.');
        }
        return (PLCK_TriggerHandler)handler;
    }

    public static void createAndExecuteHandler(Type t) {
        if (!PLCK_TriggerFactory.isBypassOnHandler(t)) {
            PLCK_TriggerFactory.createHandler(t).execute();
        }
    }

    public static Boolean setBypassOnHandler(Type handler, Boolean bypassOn) {
        Boolean prevBypassValue = isBypassOnHandler(handler);

        if(PLCK_TriggerFactory.bypassSet == null) {
            PLCK_TriggerFactory.bypassSet = new Set<Type>();
        }

        if(bypassOn) {
            PLCK_TriggerFactory.bypassSet.add(handler);
        } else {
            PLCK_TriggerFactory.bypassSet.remove(handler);
        }

        return prevBypassValue;
    }

    public static Boolean isBypassOnHandler(System.Type handler) {
        return (PLCK_TriggerFactory.bypassSet != null && PLCK_TriggerFactory.bypassSet.contains(handler)) || isBypassSetOnHandler(handler);
    }

    public static Boolean isBypassSetOnHandler(Type t) {
        Trigger_Bypass_Config__c bypassSettings = Trigger_Bypass_Config__c.getInstance();
        Boolean result = bypassSettings.AllTriggerHandler__c;

        if (!result) {
            try {
                result = (Boolean) bypassSettings.get(t.getName() + '__c');
                result = result == null ? false : result;
            } catch (System.SObjectException x) {
                result = false;
            }
        }

        return result;
    }

    private class TriggerFactoryException extends Exception {}
}