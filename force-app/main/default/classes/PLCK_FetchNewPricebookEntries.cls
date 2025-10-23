public with sharing class PLCK_FetchNewPricebookEntries {
    
    @InvocableMethod(label='Fetch Newest Pricebook for Active Customer' description='Fetch Newest Pricebook for Active Customers from SAP with a specific sales org')
    public static List<String> fetchNewestPricebook(List<Id> idsList){
        List<String> result = new List<String>();
        try{
            if(idsList.isEmpty()){
                result.add('You need to provide one Id');
            }

            Set<Id> accountIds = new Set<Id>();
            //either called from Account or Opportunity context, so only check 1st id
            if(Schema.Account.SObjectType == idsList[0].getSobjectType()){
                accountIds.addAll(idsList);
            }else if(Schema.Opportunity.SObjectType == idsList[0].getSobjectType()){
                for(Opportunity opp : [SELECT Id, AccountId
                                                    FROM Opportunity
                                                    WHERE Id =: idsList]){
                    
                    accountIds.add(opp.AccountId);                              
                }
            }else{
                throw new PLCK_FetchNewPricebookEntriesException('Object not supported!');
            }

            Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id, Name, PLCK_SalesOrganisation_ERP__c, RecordTypeId, PLCK_Pricebook__c,
                                                            PLCK_LastPriceAutomationUpdate__c, PLCK_PriceAutomationStatus__c
                                                            FROM Account
                                                            WHERE Id IN :accountIds
            ]);

            fetchNewestPricebookExecute(accounts,false,false,result);
            /*Id activeCustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PLCK_ActiveCustomer').getRecordTypeId();
            
            Set<Id> accountIdsToProcess = new Set<Id>();
            Set<String> salesOrgs = new Set<String>();
            Map<Id,Pricebook2> pricebooksForAccount = new Map<Id,Pricebook2>();
            Date lastPriceAutomationDate;
            List<Account> accountsToUpdate = new List<Account>();
            for (Account acc : accounts.values()) {
                if(acc.RecordTypeId == activeCustomerRecTypeId){
                    if (!acc.PLCK_SalesOrganisation_ERP__c.isNumeric()) {
                        result.add('It is not necessary to fetch newest pricebook for Vision Accounts');
                        break;
                    }else{
                        salesOrgs.add(acc.PLCK_SalesOrganisation_ERP__c);
                        accountIdsToProcess.add(acc.Id);
                        accountsToUpdate.add(acc);
                        lastPriceAutomationDate = acc.PLCK_LastPriceAutomationUpdate__c;
                        result.add('Pricebook is being fetched!');
                        if(acc.PLCK_Pricebook__c == null){
                            pricebooksForAccount.put(acc.Id,new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true));
                        }
                    }
                }else{
                    result.add(acc.Name + ' is not available for Pricebook fetch!');
                }
            }

            if(!pricebooksForAccount.isEmpty()){
                insert pricebooksForAccount.values();
            }

            if(!accountsToUpdate.isEmpty()){
                for(Account acc: accountsToUpdate){
                    acc.PLCK_LastPriceAutomationUpdate__c = null;
                    acc.PLCK_PriceAutomationStatus__c = 'in progress';
                    if(pricebooksForAccount.containsKey(acc.Id)){
                        acc.PLCK_Pricebook__c = pricebooksForAccount.get(acc.Id).Id;
                    }
                }
                update accountsToUpdate;
            }

            if(!accountIdsToProcess.isEmpty() && !salesOrgs.isEmpty()){
                PLCK_CreatePricebookEntriesBatch batchInstance;
                if(lastPriceAutomationDate != null){
                    batchInstance = new PLCK_CreatePricebookEntriesBatch(accountIdsToProcess,salesOrgs,lastPriceAutomationDate);
                }else{
                    batchInstance = new PLCK_CreatePricebookEntriesBatch(accountIdsToProcess,salesOrgs);
                }
                Database.executeBatch(batchInstance);
            }*/
        }catch(Exception e){
            result.clear();
            result.add(e.getMessage());
        }
        System.debug('##results -->  '+result);
        return result;
    }

    public static void fetchNewestPricebookExecute(Map<Id,Account> accounts, Boolean isCalledByTrigger, Boolean isBeforeTrigger){
        fetchNewestPricebookExecute(accounts, isCalledByTrigger, isBeforeTrigger, new List<String>{});
    }

    public static void fetchNewestPricebookExecute(Map<Id,Account> accounts, Boolean isCalledByTrigger, Boolean isBeforeTrigger, List<String> result){
        Id activeCustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PLCK_ActiveCustomer').getRecordTypeId();
            
        Set<Id> accountIdsToProcess = new Set<Id>();
        Set<String> salesOrgs = new Set<String>();
        Map<Id,Pricebook2> pricebooksForAccount = new Map<Id,Pricebook2>();
        Date lastPriceAutomationDate;
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> accountsToUpdateList = new List<Account>();

        for (Account acc : accounts.values()) {
            if(acc.RecordTypeId == activeCustomerRecTypeId){
                if (!acc.PLCK_SalesOrganisation_ERP__c.isNumeric()) {
                    result.add('It is not necessary to fetch newest pricebook for Vision Accounts');
                    break;
                }else{
                    salesOrgs.add(acc.PLCK_SalesOrganisation_ERP__c);
                    accountIdsToProcess.add(acc.Id);
                    accountsToUpdate.add(acc);
                    lastPriceAutomationDate = acc.PLCK_LastPriceAutomationUpdate__c;
                    result.add('Pricebook is being fetched!');
                    if(acc.PLCK_Pricebook__c == null){
                        pricebooksForAccount.put(acc.Id,new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true));
                    }
                }
            }else{
                result.add(acc.Name + ' is not available for Pricebook fetch!');
            }
        }

        if(!pricebooksForAccount.isEmpty()){
            insert pricebooksForAccount.values();
        }

        /*if(!accountsToUpdate.isEmpty() ){
            for(Account acc: accountsToUpdate){
                acc.PLCK_LastPriceAutomationUpdate__c = null;
                acc.PLCK_PriceAutomationStatus__c = 'in progress';
                if(pricebooksForAccount.containsKey(acc.Id)){
                    acc.PLCK_Pricebook__c = pricebooksForAccount.get(acc.Id).Id;
                }
            }
            update accountsToUpdate;
        }*/

        if(!accountsToUpdate.isEmpty()){
            if(isBeforeTrigger){
                for(Account acc: accountsToUpdate){
                    acc.PLCK_LastPriceAutomationUpdate__c = null;
                    acc.PLCK_PriceAutomationStatus__c = 'in progress';
                    if(pricebooksForAccount.containsKey(acc.Id)){
                        acc.PLCK_Pricebook__c = pricebooksForAccount.get(acc.Id).Id;
                    }
                }
            } else {
                for(Account acc : accountsToUpdate){
                    Account accToUpdate = new Account(
                        Id = acc.Id,
                        PLCK_LastPriceAutomationUpdate__c = null,
                        PLCK_PriceAutomationStatus__c = 'in progress'
                    );
                    if(pricebooksForAccount.containsKey(acc.Id)){
                        accToUpdate.PLCK_Pricebook__c = pricebooksForAccount.get(acc.Id).Id;
                    }
    
                    accountsToUpdateList.add(accToUpdate);
                }
                update accountsToUpdateList;
            }
        }

        if(!accountIdsToProcess.isEmpty() && !salesOrgs.isEmpty()){
            PLCK_CreatePricebookEntriesBatch batchInstance;
            if(lastPriceAutomationDate != null){
                batchInstance = new PLCK_CreatePricebookEntriesBatch(accountIdsToProcess,salesOrgs,lastPriceAutomationDate);
            }else{
                batchInstance = new PLCK_CreatePricebookEntriesBatch(accountIdsToProcess,salesOrgs);
            }
            if(isCalledByTrigger){
                Database.executeBatch(batchInstance,10);
            } else {
                Database.executeBatch(batchInstance);
            }
        }
    }
   
    private class PLCK_FetchNewPricebookEntriesException extends Exception{}
}