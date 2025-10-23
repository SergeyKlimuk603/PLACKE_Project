public with sharing class PLCK_CreatePricebookEntriesBatch implements Database.Batchable<sObject>{

    public final String query;
    public final Set<Id> accountIds;
    public final Set<String> salesOrgs;
    public final Date lastFetchDate;

    public PLCK_CreatePricebookEntriesBatch(Set<Id> accountIds, Set<String> salesOrgs) {
        this.accountIds = accountIds;
        this.salesOrgs = salesOrgs;
        this.query = 'SELECT Id, Name, IsActive, PLCK_SalesOrganisation_ERP__c FROM Product2 WHERE PLCK_SalesOrganisation_ERP__c IN :salesOrgs';
    }

    public PLCK_CreatePricebookEntriesBatch(Set<Id> accountIds, Set<String> salesOrgs, Date lastFetchDate) {
        this.accountIds = accountIds;
        this.salesOrgs = salesOrgs;
        this.lastFetchDate = lastFetchDate;
        this.query = 'SELECT Id, Name, IsActive, PLCK_SalesOrganisation_ERP__c FROM Product2 WHERE PLCK_SalesOrganisation_ERP__c IN :salesOrgs AND CreatedDate >= :lastFetchDate';
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }
  
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        
        List<Product2> products = (List<Product2>) scope;
       
        List<Account> accounts = [SELECT Id, PLCK_PriceBook__c, PLCK_PriceAutomationStatus__c, PLCK_SalesOrganisation_ERP__c 
                                    FROM Account
                                    WHERE Id =: accountIds];
        
        Map<String, List<Id>> pricebookIdBySalesOrg = new Map<String,List<Id>>();
        for(Account acc: accounts){
            List<Id> pricebookIds = pricebookIdBySalesOrg.get(acc.PLCK_SalesOrganisation_ERP__c);
            if(pricebookIds == null){
                pricebookIds = new List<Id>();
            }
            pricebookIds.add(acc.PLCK_PriceBook__c);
            pricebookIdBySalesOrg.put(acc.PLCK_SalesOrganisation_ERP__c, pricebookIds);
        }
        
        List<CurrencyType> currencies = PLCK_Utils.retrieveActiveCurrencyISOCodes();

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        for(Product2 prod : products){

            if(pricebookIdBySalesOrg.containsKey(prod.PLCK_SalesOrganisation_ERP__c)){

                List<Id> pricebookIds = pricebookIdBySalesOrg.get(prod.PLCK_SalesOrganisation_ERP__c);
                
                for(Id pricebook : pricebookIds){
                    
                    for (CurrencyType ct : currencies){
                        PricebookEntry pe = PLCK_PricebookEntryService.createPricebookEntry(prod, pricebook, ct.IsoCode, 0, PLCK_PricebookEntryService.PRICE_TYPE_NEW);
                        pricebookEntries.add(pe);
                        
                    }
                }
            }
        }

        if(!pricebookEntries.isEmpty()) {
            Database.insert(pricebookEntries,false);
        }
    }
  
    public void finish(Database.BatchableContext bc){
        List<Account> accounts = [SELECT Id, PLCK_PriceBook__c, PLCK_PriceAutomationStatus__c, PLCK_SalesOrganisation_ERP__c 
                                    FROM Account
                                    WHERE Id =: accountIds];
                                    
        for(Account acc: accounts){
            acc.PLCK_PriceAutomationStatus__c = 'completed';
            acc.PLCK_LastPriceAutomationUpdate__c = System.today();
        }

        update accounts;
    }
}