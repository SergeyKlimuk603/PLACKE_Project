public with sharing class PLCK_Product2TriggerHandler extends PLCK_TriggerHandler {

    public override void afterInsert() {
        createPricebookEntry((List<Product2>) Trigger.new);
    }

    private static void createPricebookEntry(List<Product2> newProducts) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        PricebookEntry pe;
        Id stdPricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : PLCK_Utils.getStandardPricebookId();
        Map<String, Pricebook2> pricebookMap = new Map<String, Pricebook2>();
        for(Pricebook2 prc : [SELECT Id, PLCK_SalesOrganisation__c FROM Pricebook2 WHERE PLCK_SalesOrganisation__c != NULL]) {
            pricebookMap.put(prc.PLCK_SalesOrganisation__c, prc);
        }
        for(Product2 p : newProducts) {
            for (CurrencyType ct : PLCK_Utils.retrieveActiveCurrencyISOCodes()) {
                pe = new PricebookEntry();
                pe.Product2Id = p.Id;
                pe.Pricebook2Id = stdPricebookId;
                pe.CurrencyIsoCode = ct.IsoCode;
                pe.UnitPrice = 0;
                pe.IsActive = p.IsActive;
                pe.PLCK_PricebookEntry_ExternalID__c = (String) p.Id + (String) stdPricebookId + ct.IsoCode;
                pricebookEntries.add(pe);
                if(p.PLCK_SalesOrganisation_ERP__c != null && pricebookMap.containsKey(p.PLCK_SalesOrganisation_ERP__c)) {
                    PricebookEntry prcEntry = pe.clone(false);
                    prcEntry.Pricebook2Id = pricebookMap.get(p.PLCK_SalesOrganisation_ERP__c).Id;
                    prcEntry.PLCK_PriceType__c = 'New';
                    prcEntry.PLCK_PricebookEntry_ExternalID__c = (String) p.Id + (String) pricebookMap.get(p.PLCK_SalesOrganisation_ERP__c).Id + ct.IsoCode;
                    pricebookEntries.add(prcEntry);
                }
            }
        }
        if(!pricebookEntries.isEmpty()) {
            insert pricebookEntries;
        }
    }
}