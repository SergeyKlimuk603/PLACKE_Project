@IsTest
public with sharing class PLCK_FetchNewPricebookEntriesTest {
    @TestSetup
    static void setup(){
        PLCK_TestDataFactory.createPricebookForProspectAccounts();
        try {
            User u2 = PLCK_TestDataFactory.createStandardUser('PLCK Standard User');
            u2.PLCK_ERPUserNumber__c = '9999';
            insert u2;
        } catch (Exception e) {

        }
    }

    @IsTest
    static void fetchNewestPricebookTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, null)[0];

        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        String visionSalesOrg = '1350';
        acc.RecordTypeId = customerRecTypeId;
        acc.Status__c = PLCK_FetchNewPricebookEntries.CUSTOMER_STATUS_ACTIVE;
        acc.PLCK_SalesOrganisation_ERP__c = '1350';
        acc.PLCK_ABCClass__c = 'A1';
        acc.PLCK_FetchPricebookCheck__c = true;

        insert acc;

        Test.startTest();
            PLCK_FetchNewPricebookEntries.fetchNewestPricebook(new List<Id>{acc.Id});
        Test.stopTest();

        List<Account> updatedAccounts = [SELECT Id, PLCK_SalesOrganisation__c, PLCK_PriceBook__r.PLCK_SalesOrganisation__c, PLCK_PriceBook__c FROM Account];
        System.assertNotEquals(null, updatedAccounts[0].PLCK_PriceBook__c);
    }

    @IsTest
    static void fetchNewestPricebookExecuteTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, null)[0];

        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        String visionSalesOrg = '1350';
        acc.RecordTypeId = customerRecTypeId;
        acc.Status__c = PLCK_FetchNewPricebookEntries.CUSTOMER_STATUS_ACTIVE;
        acc.PLCK_SalesOrganisation_ERP__c = '1350';
        acc.PLCK_ABCClass__c = 'A1';
        acc.PLCK_FetchPricebookCheck__c = true;

        insert acc;

        Map<Id,Account> accountMap = new Map<Id,Account>();
        accountMap.put(acc.Id,acc);

        Test.startTest();
            PLCK_FetchNewPricebookEntries.fetchNewestPricebookExecute(accountMap,true,true);
        Test.stopTest();

        List<Account> updatedAccounts = [SELECT Id, PLCK_SalesOrganisation__c, PLCK_PriceBook__r.PLCK_SalesOrganisation__c, PLCK_PriceBook__c FROM Account];
        System.assertNotEquals(null, updatedAccounts[0].PLCK_PriceBook__c);
    }
}