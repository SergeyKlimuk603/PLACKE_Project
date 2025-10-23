@isTest
public class PLCK_PricebookEntryServiceTest {
    @IsTest
    static void createPricebookEntry_success(){
        String currencyCode = 'EUR';
        Decimal price = 0;
        String type = PLCK_PricebookEntryService.PRICE_TYPE_NEW;

        Pricebook2 pricebook = new Pricebook2(Name = PLCK_Utils.generateRandomString(5), IsActive = true);
        insert pricebook;

        Product2 product = PLCK_TestDataFactory.prepareProduct(PLCK_AccountService.SALES_ORGANISATION_DE, '12345678');
        insert product;

        PricebookEntry pe;
        Test.startTest();
        pe = PLCK_PricebookEntryService.createPricebookEntry(product, pricebook.Id, currencyCode, price, type);
        Test.stopTest();

        System.assertNotEquals(null, pe, 'PricebookEntry is null');
        System.assertEquals(product.Id, pe.Product2Id, 'PricebookEntry Product is not assigned');
        System.assertEquals(pricebook.Id, pe.Pricebook2Id, 'PricebookEntry Pricebook doesnt match');
        System.assertEquals(currencyCode, pe.CurrencyIsoCode, 'PricebookEntry currency doesnt match');
        System.assertEquals(price, pe.UnitPrice, 'PricebookEntry price doesnt match');
        System.assertEquals(type, pe.PLCK_PriceType__c, 'PricebookEntry type doesnt match');
    }

    @IsTest
    static void createPricebookEntry_noPricebook(){
        String currencyCode = 'EUR';
        Decimal price = 0;
        String type = PLCK_PricebookEntryService.PRICE_TYPE_NEW;

        Product2 product = PLCK_TestDataFactory.prepareProduct(PLCK_AccountService.SALES_ORGANISATION_DE, '12345678');
        insert product;

        PricebookEntry pe;
        Test.startTest();
        pe = PLCK_PricebookEntryService.createPricebookEntry(product, null, currencyCode, price, type);
        Test.stopTest();

        System.assertEquals(null, pe, 'PricebookEntry is not null');
    }

    @IsTest
    static void createPricebookEntry_noProduct(){
        String currencyCode = 'EUR';
        Decimal price = 0;
        String type = PLCK_PricebookEntryService.PRICE_TYPE_NEW;

        Pricebook2 pricebook = new Pricebook2(Name = PLCK_Utils.generateRandomString(5), IsActive = true);
        insert pricebook;

        PricebookEntry pe;
        Test.startTest();
        pe = PLCK_PricebookEntryService.createPricebookEntry(null, pricebook.Id, currencyCode, price, type);
        Test.stopTest();

        System.assertEquals(null, pe, 'PricebookEntry is not null');
    }
}