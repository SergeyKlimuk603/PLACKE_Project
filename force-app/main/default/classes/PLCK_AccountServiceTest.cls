@IsTest
public with sharing class PLCK_AccountServiceTest {

    @TestSetup
    static void setup() {
        PLCK_TestDataFactory.createPricebookForProspectAccounts();
        try {
            User u2 = PLCK_TestDataFactory.createStandardUser('PLCK Standard User');
            u2.PLCK_ERPUserNumber__c = '9999';
            insert u2;
        } catch (Exception e) {

        }
    }

    // @IsTest
    // static void shouldCreatePricebookForEachCustomer() {
    //     List<Account> accounts = PLCK_TestDataFactory.prepareAccounts(5, null);
    //     Id activeCustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PLCK_ActiveCustomer').getRecordTypeId();
    //     accounts[0].RecordTypeId = activeCustomerRecTypeId;
    //     accounts[1].RecordTypeId = activeCustomerRecTypeId;
    //     accounts[2].RecordTypeId = activeCustomerRecTypeId;
    //     accounts[3].RecordTypeId = activeCustomerRecTypeId;
    //     accounts[4].RecordTypeId = activeCustomerRecTypeId;

    //     Test.startTest();
    //     insert accounts;
    //     Test.stopTest();

    //     for (Account acc : [SELECT Id, PLCK_SalesOrganisation__c, PLCK_PriceBook__r.PLCK_SalesOrganisation__c, PLCK_PriceBook__c FROM Account]) {
    //         System.assertEquals(null, acc.PLCK_PriceBook__r.PLCK_SalesOrganisation__c);
    //         System.assertNotEquals(null, acc.PLCK_PriceBook__c);
    //     }
    // }

    @IsTest
    static void shouldSetAccountOwner() {
        User u = PLCK_TestDataFactory.createStandardUser('System Administrator');
        System.runAs(u) {
            List<Account> accounts = PLCK_TestDataFactory.prepareAccounts(1, null);
            Id activeCustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PLCK_ActiveCustomer').getRecordTypeId();
            accounts[0].RecordTypeId = activeCustomerRecTypeId;
            accounts[0].PLCK_ERPSalesrepNumber__c = '9999';

            Test.startTest();
            insert accounts;
            Test.stopTest();

            Account acc = [SELECT Id, OwnerId, CreatedById FROM Account];
            u = [SELECT Id FROM User WHERE Username = :u.Username];
            User u2 = [SELECT Id FROM User WHERE PLCK_ERPUserNumber__c = '9999'];
            System.assertEquals(u2.Id, acc.OwnerId);
            System.assertEquals(u.Id, acc.CreatedById);
        }
    }

    @IsTest
    static void shouldMapFieldValuesFromERPToPicklistFieldsForEachAccount() {
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, null)[0];
        acc.PLCK_SalesOrganisation_ERP__c = '1020';
        acc.PLCK_ABCClass_ERP__c = 'C';
        acc.PLCK_BusinessSegment_ERP__c = '350';

        Test.startTest();
        insert acc;
        Test.stopTest();

        Account insertedAccount = [SELECT Id, PLCK_ABCClass__c, PLCK_ABCClass_ERP__c, PLCK_BusinessSegment__c, PLCK_BusinessSegment_ERP__c, PLCK_SalesOrganisation__c, PLCK_SalesOrganisation_ERP__c FROM Account];

        System.assertEquals(PLCK_AccountService.BUSINESS_SEGMENT_GLASS, insertedAccount.PLCK_BusinessSegment__c);
        System.assertEquals(insertedAccount.PLCK_ABCClass_ERP__c, insertedAccount.PLCK_ABCClass__c);
        System.assertEquals(insertedAccount.PLCK_SalesOrganisation_ERP__c, insertedAccount.PLCK_SalesOrganisation__c);
    }

    @IsTest
    static void assignPricebookForVisionCustomer() {
        List<Account> accounts = PLCK_TestDataFactory.prepareAccounts(1, null);
        Id activeCustomerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PLCK_ActiveCustomer').getRecordTypeId();
        
        String visionSalesOrg = 'US';
        accounts[0].RecordTypeId = activeCustomerRecTypeId;
        accounts[0].PLCK_SalesOrganisation_ERP__c = visionSalesOrg;

        Test.startTest();
        insert accounts;
        Test.stopTest();

        Map<String,String> salesOrgERPmapping = PLCK_Utils.getSalesOrgERPMapping(new Set<String>{visionSalesOrg});

        for (Account acc : [SELECT Id, PLCK_SalesOrganisation__c, PLCK_PriceBook__r.PLCK_SalesOrganisation__c, PLCK_PriceBook__c FROM Account]) {
            System.assertEquals(salesOrgERPmapping.get(visionSalesOrg), acc.PLCK_PriceBook__r.PLCK_SalesOrganisation__c);
            System.assertNotEquals(null, acc.PLCK_PriceBook__c);
        }
    }

}