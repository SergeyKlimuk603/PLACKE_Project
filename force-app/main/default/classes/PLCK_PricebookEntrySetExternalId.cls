global class PLCK_PricebookEntrySetExternalId implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Product2Id, Pricebook2Id, CurrencyIsoCode, PLCK_PricebookEntry_ExternalID__c FROM PricebookEntry WHERE PLCK_PricebookEntry_ExternalID__c = NULL';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        List<PricebookEntry> pricebookEntries = (List<PricebookEntry>) scope;
        
        for(PricebookEntry pe: pricebookEntries){
            pe.PLCK_PricebookEntry_ExternalID__c = (String) pe.Product2Id + (String) pe.Pricebook2Id + pe.CurrencyIsoCode;
        }

        try {
            update pricebookEntries;
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        
    }
}