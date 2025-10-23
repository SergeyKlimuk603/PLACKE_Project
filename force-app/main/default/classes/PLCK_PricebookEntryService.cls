public with sharing class PLCK_PricebookEntryService {

    public static final String PRICE_TYPE_NEW = 'New';
    
    public static PricebookEntry createPricebookEntry(Product2 product, Id pricebookId, String currencyCode, Decimal price, String type){

        if(product == null || pricebookId == null){
            return null;
        }

        PricebookEntry pe = new PricebookEntry();
        pe.Product2Id = product.Id;
        pe.Pricebook2Id = pricebookId;
        pe.CurrencyIsoCode = currencyCode;
        pe.UnitPrice = price;
        pe.IsActive = product.IsActive;
        pe.PLCK_PricebookEntry_ExternalID__c = (String) product.Id + (String) pricebookId + currencyCode;
        pe.PLCK_PriceType__c = type;
        
        return pe;
    }
}