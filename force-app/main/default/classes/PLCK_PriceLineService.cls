public without sharing class PLCK_PriceLineService {

    public static final String PRICEBOOK_ENTRY_PRICE_TYPE_CUSTOMER_NEGOTIATED = 'Customer Negotiated Price';
    public static final String PRICEBOOK_ENTRY_PRICE_TYPE_GROUP_PRICE = 'Customer Group Price';

    public static void linkPriceLineToAccount(List<PLCK_PriceLine__c> priceLines) {

        Set<String> accountExternalIds = new Set<String>();

        for(PLCK_PriceLine__c pl : priceLines) {

            // if one of these fields are null then we can't match the price line with the account so we can skip it
            if(pl.PLCK_CustomerNumber__c == null || pl.PLCK_SalesOrganisation_ERP__c == null) {
                continue;
            }

            accountExternalIds.add(pl.PLCK_CustomerNumber__c+'_'+pl.PLCK_SalesOrganisation_ERP__c);

        }

        Map<String, Account> accountsByExtId = new Map<String, Account>();
        for(Account acc : [SELECT Id, PLCK_ExternalID__c FROM Account WHERE PLCK_ExternalID__c IN :accountExternalIds]) {

            accountsByExtId.put(acc.PLCK_ExternalID__c, acc);
        }

        for(PLCK_PriceLine__c pl : priceLines) {

            if(accountsByExtId.get(pl.PLCK_CustomerNumber__c+'_'+pl.PLCK_SalesOrganisation_ERP__c) != null) {
                pl.PLCK_Customer__c = accountsByExtId.get(pl.PLCK_CustomerNumber__c+'_'+pl.PLCK_SalesOrganisation_ERP__c).Id;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<PLCK_PriceLine__c> fetchStandardPriceLines(String accountId, String searchTerm, List<String> materials){
        
        //String accountId = '0019Z00000DJPzIQAX';
        System.debug('##### accountId: '+accountId);
        Account acc = [SELECT Id, PLCK_SalesOrganisation__c FROM Account WHERE Id = :accountId LIMIT 1];
        System.debug('##### acc: '+acc);
        System.debug('##### searchTerm: '+searchTerm);
        System.debug('##### materials: '+materials);
        String salesorg = acc.PLCK_SalesOrganisation__c;
        String searchText = '%'+searchTerm+'%';
        String query = 'SELECT Id, PLCK_SalesMaterialNumber__c, Name, PLCK_ConditionType__c, PLCK_DistributionChannel__c, '
                            +' PLCK_Multiplicator__c, PLCK_PriceGroup__c, PLCK_SalesPriceIndicator__c, PLCK_SalesPrice__c, PLCK_Price__c, '
                            +' PLCK_ScaleThreshold__c, PLCK_UnitOfMeasure__c, CurrencyIsoCode ' 
                    + ' FROM PLCK_PriceLine__c '
                    + ' WHERE (PLCK_SalesOrganisation__c = :salesorg OR PLCK_SalesOrganisation_ERP__c = :salesorg) AND '
                    + ' PLCK_Type_of_Price__c = \'Standard Price\' ';
        if(String.isNotBlank(searchTerm) && (materials == null || materials.isEmpty())){
            query += ' AND PLCK_SalesMaterialNumber__c LIKE :searchText ';
        }
        if(materials != null && !materials.isEmpty()){
            query += ' AND PLCK_SalesMaterialNumber__c IN :materials ';
        }

        System.debug('##### query: '+query);

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<PLCK_PriceLine__c> fetchGroupPriceLines(String accountId, String searchTerm, List<String> materials){
        
        //String accountId = '0019Z00000DJPzIQAX';
        System.debug('##### accountId: '+accountId);
        Account acc = [SELECT Id, PLCK_SalesOrganisation__c, PLCK_PriceGroup__c FROM Account WHERE Id = :accountId LIMIT 1];
        System.debug('##### acc: '+acc);
        System.debug('##### searchTerm: '+searchTerm);
        System.debug('##### materials: '+materials);
        String salesorg = acc.PLCK_SalesOrganisation__c;
        String pricegroup = acc.PLCK_PriceGroup__c;
        String searchText = '%'+searchTerm+'%';
        String query = 'SELECT Id, PLCK_SalesMaterialNumber__c, Name, PLCK_ConditionType__c, PLCK_DistributionChannel__c, '
                            +' PLCK_Multiplicator__c, PLCK_PriceGroup__c, PLCK_SalesPriceIndicator__c, PLCK_SalesPrice__c, PLCK_Price__c, '
                            +' PLCK_ScaleThreshold__c, PLCK_UnitOfMeasure__c, CurrencyIsoCode ' 
                    + ' FROM PLCK_PriceLine__c '
                    + ' WHERE (PLCK_SalesOrganisation__c = :salesorg OR PLCK_SalesOrganisation_ERP__c = :salesorg) AND '
                    + ' PLCK_PriceGroup__c = :pricegroup AND '
                    + ' PLCK_Type_of_Price__c = \'Group Price\' ';
        if(String.isNotBlank(searchTerm) && (materials == null || materials.isEmpty())){
            query += ' AND PLCK_SalesMaterialNumber__c LIKE :searchText ';
        }
        if(materials != null && !materials.isEmpty()){
            query += ' AND PLCK_SalesMaterialNumber__c IN :materials ';
        }

        System.debug('##### query: '+query);

        return Database.query(query);
    }
}