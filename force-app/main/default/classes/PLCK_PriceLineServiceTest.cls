@IsTest
public with sharing class PLCK_PriceLineServiceTest {

    private static final String CUSTOMER_STATUS_ACTIVE = 'Active';

    @isTest
    private static void linkPriceLineToAccountTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, '000')[0];
        acc.PLCK_ExternalID__c = '00000000_1020';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        acc.Status__c = CUSTOMER_STATUS_ACTIVE;
        
        Pricebook2 pricebook = new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true);
        insert pricebook;

        acc.PLCK_Pricebook__c = pricebook.Id;
        insert acc;
        
        PLCK_PriceLine__c priceLine = PLCK_TestDataFactory.preparePriceLine(PLCK_AccountService.SALES_ORGANISATION_DE, '1111', null, 100, '00000000');

        Test.startTest();
        insert priceLine;
        Test.stopTest();

        priceLine = [SELECT Id, PLCK_Customer__c FROM PLCK_PriceLine__c LIMIT 1];
        System.assertNotEquals(null, priceLine.PLCK_Customer__c);
    }

    @isTest
    private static void fetchStandardPriceLinesTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, '000')[0];
        acc.PLCK_ExternalID__c = '00000000_1020';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        acc.Status__c = CUSTOMER_STATUS_ACTIVE;

        Pricebook2 pricebook = new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true);
        insert pricebook;

        acc.PLCK_Pricebook__c = pricebook.Id;
        insert acc;
        
        PLCK_PriceLine__c priceLine = PLCK_TestDataFactory.preparePriceLine(PLCK_AccountService.SALES_ORGANISATION_DE, '1111', null, 100, null);
        insert priceLine;

        Test.startTest();
        
        List<PLCK_PriceLine__c> priceLines = PLCK_PriceLineService.fetchStandardPriceLines(acc.Id,null,null);

        Test.stopTest();

        System.assertEquals(1, priceLines.size());
    }

    @isTest
    private static void fetchStandardPriceLinesWithSearchTextTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, '000')[0];
        acc.PLCK_ExternalID__c = '00000000_1020';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        acc.Status__c = CUSTOMER_STATUS_ACTIVE;

        Pricebook2 pricebook = new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true);
        insert pricebook;

        acc.PLCK_Pricebook__c = pricebook.Id;
        insert acc;
        
        PLCK_PriceLine__c priceLine = PLCK_TestDataFactory.preparePriceLine(PLCK_AccountService.SALES_ORGANISATION_DE, '1111', null, 100, null);
        insert priceLine;

        Test.startTest();
        
        List<PLCK_PriceLine__c> priceLines = PLCK_PriceLineService.fetchStandardPriceLines(acc.Id,'11',null);

        Test.stopTest();

        System.assertEquals(1, priceLines.size());
    }

    @isTest
    private static void fetchStandardPriceLinesWithListOfMaterialNumbersTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, '000')[0];
        acc.PLCK_ExternalID__c = '00000000_1020';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        acc.Status__c = CUSTOMER_STATUS_ACTIVE;
        
        Pricebook2 pricebook = new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true);
        insert pricebook;

        acc.PLCK_Pricebook__c = pricebook.Id;
        insert acc;
        
        PLCK_PriceLine__c priceLine = PLCK_TestDataFactory.preparePriceLine(PLCK_AccountService.SALES_ORGANISATION_DE, '1111', null, 100, null);
        insert priceLine;

        Test.startTest();
        
        List<PLCK_PriceLine__c> priceLines = PLCK_PriceLineService.fetchStandardPriceLines(acc.Id,null,new List<String>{'1111'});

        Test.stopTest();

        System.assertEquals(1, priceLines.size());
    }

    @isTest
    private static void fetchGroupPriceLinesTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, 'PG1')[0];
        acc.PLCK_ExternalID__c = '00000000_1020';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        acc.Status__c = CUSTOMER_STATUS_ACTIVE;
        
        Pricebook2 pricebook = new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true);
        insert pricebook;

        acc.PLCK_Pricebook__c = pricebook.Id;
        insert acc;
        
        PLCK_PriceLine__c priceLine = PLCK_TestDataFactory.preparePriceLine(PLCK_AccountService.SALES_ORGANISATION_DE, '1111', 'PG1', 100, null);
        insert priceLine;

        Test.startTest();
        
        List<PLCK_PriceLine__c> priceLines = PLCK_PriceLineService.fetchGroupPriceLines(acc.Id,null,null);

        Test.stopTest();

        System.assertEquals(1, priceLines.size());
    }

    @isTest
    private static void fetchGroupPriceLinesWithSearchTextTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, 'PG1')[0];
        acc.PLCK_ExternalID__c = '00000000_1020';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        acc.Status__c = CUSTOMER_STATUS_ACTIVE;
        
        Pricebook2 pricebook = new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true);
        insert pricebook;

        acc.PLCK_Pricebook__c = pricebook.Id;
        insert acc;
        
        PLCK_PriceLine__c priceLine = PLCK_TestDataFactory.preparePriceLine(PLCK_AccountService.SALES_ORGANISATION_DE, '1111', 'PG1', 100, null);
        insert priceLine;

        Test.startTest();
        
        List<PLCK_PriceLine__c> priceLines = PLCK_PriceLineService.fetchGroupPriceLines(acc.Id,'11',null);

        Test.stopTest();

        System.assertEquals(1, priceLines.size());
    }

    @isTest
    private static void fetchGroupPriceLinesWithListOfMaterialNumbersTest(){
        Account acc = PLCK_TestDataFactory.prepareAccounts(1, 'PG1')[0];
        acc.PLCK_ExternalID__c = '00000000_1020';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        acc.Status__c = CUSTOMER_STATUS_ACTIVE;
        
        Pricebook2 pricebook = new Pricebook2(Name = acc.Name + '_' + acc.PLCK_SalesOrganisation_ERP__c, IsActive = true);
        insert pricebook;

        acc.PLCK_Pricebook__c = pricebook.Id;
        insert acc;
        
        PLCK_PriceLine__c priceLine = PLCK_TestDataFactory.preparePriceLine(PLCK_AccountService.SALES_ORGANISATION_DE, '1111', 'PG1', 100, null);
        insert priceLine;

        Test.startTest();
        
        List<PLCK_PriceLine__c> priceLines = PLCK_PriceLineService.fetchGroupPriceLines(acc.Id,null,new List<String>{'1111'});

        Test.stopTest();

        System.assertEquals(1, priceLines.size());
    }
}