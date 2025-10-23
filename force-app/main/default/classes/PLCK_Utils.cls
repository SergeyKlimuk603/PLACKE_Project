public with sharing class PLCK_Utils {

    public static List<CurrencyType> retrieveActiveCurrencyISOCodes() {
        return [SELECT IsoCode, ConversionRate FROM CurrencyType WHERE IsActive = TRUE];
    }

    public static Id getStandardPricebookId() {
        return [SELECT Id, Name FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
    }

    public static String generateRandomString(Integer lengthOfString) {
        final String possibleChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while (randomString.length() < lengthOfString) {
            Integer indexOfRandomChar = Math.mod(Math.abs(Crypto.getRandomInteger()), possibleChars.length());
            randomString += possibleChars.substring(indexOfRandomChar, indexOfRandomChar + 1);
        }
        return randomString;
    }

    public static Map<String,String> getSalesOrgERPMapping(Set<String> salesOrgs){
        Map<String,String> salesOrgMapping = new Map<String,String>();

        if(salesOrgs.isEmpty()){
            return salesOrgMapping;
        }

        Map<String,PLCK_MapSalesOrganistation__mdt> mapSalesOrgsMap = PLCK_MapSalesOrganistation__mdt.getAll();

        if(!mapSalesOrgsMap.isEmpty()){
            
            for(String org: salesOrgs){
                System.debug('##contains org -> '+mapSalesOrgsMap.containsKey(org));
                if(mapSalesOrgsMap.containsKey(org)){
                    salesOrgMapping.put(org, mapSalesOrgsMap.get(org).PLCK_SalesOrgNumber__c);
                }
            }
        }

        return salesOrgMapping;
    }
}