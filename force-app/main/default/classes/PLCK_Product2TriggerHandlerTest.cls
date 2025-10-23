@IsTest
public with sharing class PLCK_Product2TriggerHandlerTest {

    @IsTest
    static void shouldInsertPricebookEntryInEachCurrencyInStandardPricebook() {
        PLCK_TestDataFactory.createPricebookForProspectAccounts();

        Test.startTest();
        insert PLCK_TestDataFactory.prepareProduct(PLCK_AccountService.SALES_ORGANISATION_DE, '1111');
        Test.stopTest();

        System.assertEquals(PLCK_Utils.retrieveActiveCurrencyISOCodes().size()*2, [SELECT Id FROM PricebookEntry].size());
    }
}