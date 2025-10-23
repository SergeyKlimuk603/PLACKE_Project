@isTest
public class PLCK_CreatePricebookEntriesBatchTest {

    @isTest
    private static void createPricebookEntriesBatch_test(){
        // List<Pricebook2> pricebooks = new List<Pricebook2>{
        //     new Pricebook2(Name = PLCK_Utils.generateRandomString(5), IsActive = true),
        //     new Pricebook2(Name = PLCK_Utils.generateRandomString(5), IsActive = true)
        // };
        // insert pricebooks;
        PLCK_TestDataFactory.createPricebookForProspectAccounts();

        List<Account> accounts = PLCK_TestDataFactory.prepareAccounts(2, null);
        Id activeCustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PLCK_ActiveCustomer').getRecordTypeId();
        accounts[0].RecordTypeId = activeCustomerRecTypeId;
        //accounts[0].PLCK_Pricebook__c = pricebooks[0].Id;
        accounts[1].RecordTypeId = activeCustomerRecTypeId;
        //accounts[1].PLCK_Pricebook__c = pricebooks[1].Id;
        insert accounts;

        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accounts[0].Id);
        accountIds.add(accounts[1].Id);

        Product2 product = PLCK_TestDataFactory.prepareProduct(PLCK_AccountService.SALES_ORGANISATION_DE, '12345678');
        insert product;

        Test.startTest();
        Database.executeBatch(new PLCK_CreatePricebookEntriesBatch(accountIds,new Set<String>{PLCK_AccountService.SALES_ORGANISATION_DE}));
        Test.stopTest();

        List<Account> existingAccounts = [SELECT Id, PLCK_PriceAutomationStatus__c, PLCK_LastPriceAutomationUpdate__c, PLCK_Pricebook__c
                                                FROM Account
                                                WHERE Id =: accountIds];
        List<Id> pricebookIds = new List<Id>();
        for(Account acc: existingAccounts){
            System.assertEquals('completed',acc.PLCK_PriceAutomationStatus__c, 'Price automation is not complete');
            System.assertNotEquals(null,acc.PLCK_LastPriceAutomationUpdate__c, 'Price automation date is not complete');
            pricebookIds.add(acc.PLCK_Pricebook__c);
        }

        List<PricebookEntry> createdPricebookEntries = [SELECT Id, Product2Id, Pricebook2Id 
                                                        FROM PricebookEntry
                                                        WHERE Pricebook2Id =: pricebookIds
                                                        AND Product2Id =: product.Id];
        List<CurrencyType> activeCurrencies = PLCK_Utils.retrieveActiveCurrencyISOCodes();
        System.assertEquals(activeCurrencies.size(), createdPricebookEntries.size(), 'Pricebook entries not created');

    }
}