@isTest
public without sharing class PLCK_FollowUpEmailSend_BatchTest {

    private static final String CUSTOMER_STATUS_ACTIVE = 'Active';
    
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

    @isTest
    private static void executeTest() {

        User u = PLCK_TestDataFactory.createStandardUser('System Administrator');
        System.runAs(u) {
            List<Account> accounts = PLCK_TestDataFactory.prepareAccounts(1, null);
            PLCK_TestDataFactory.createPricebookForProspectAccounts();
            Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
            accounts[0].RecordTypeId = customerRecTypeId;
            accounts[0].Status__c = CUSTOMER_STATUS_ACTIVE;
            accounts[0].PLCK_ERPSalesrepNumber__c = '9999';
            accounts.get(0).PLCK_PriceBook__c = [SELECT Id FROM Pricebook2 LIMIT 1].Id;
            insert accounts;

            insert new Opportunity(
                Name = 'Opp Test',
                PLCK_FollowUpDate__c = Date.today().addDays(1),
                AccountId = accounts.get(0).Id,
                StageName = 'New',
                CloseDate = Date.today().addDays(100)
            );

            Test.startTest();

            Database.executeBatch(new PLCK_FollowUpEmailSend_Batch());

            Test.stopTest();
        }
    }
}