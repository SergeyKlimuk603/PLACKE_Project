public with sharing class PLCK_AccountService {

    public static final String SALES_ORGANISATION_DE = '1020';
    public static final String SALES_ORGANISATION_PL = '2620';
    public static final String BUSINESS_SEGMENT_AUTOMOTIVE = 'Automotive';
    public static final String BUSINESS_SEGMENT_LIFESTYLE = 'Lifestyle';
    public static final String BUSINESS_SEGMENT_GLASS = 'Glass Cosmetics';
    public static final String BUSINESS_SEGMENT_AVIATION = 'Aviation';
    public static final String CUSTOMER_STATUS_ACTIVE = 'Active';

    /*public static final Map<String, String> SALES_ORGANISATION_MAPPING_FROM_ERP = new Map<String, String>{
            '100' => BUSINESS_SEGMENT_AUTOMOTIVE,
            '110' => BUSINESS_SEGMENT_AUTOMOTIVE,
            '120' => BUSINESS_SEGMENT_AUTOMOTIVE,
            '130' => BUSINESS_SEGMENT_AUTOMOTIVE,
            '210' => BUSINESS_SEGMENT_LIFESTYLE,
            '220' => BUSINESS_SEGMENT_LIFESTYLE,
            '240' => BUSINESS_SEGMENT_LIFESTYLE,
            '300' => BUSINESS_SEGMENT_GLASS,
            '310' => BUSINESS_SEGMENT_GLASS,
            '320' => BUSINESS_SEGMENT_GLASS,
            '330' => BUSINESS_SEGMENT_GLASS,
            '340' => BUSINESS_SEGMENT_GLASS,
            '350' => BUSINESS_SEGMENT_GLASS,
            '400' => BUSINESS_SEGMENT_AUTOMOTIVE,
            '500' => BUSINESS_SEGMENT_AVIATION,
            '510' => BUSINESS_SEGMENT_AVIATION,
            '520' => BUSINESS_SEGMENT_AVIATION,
            '530' => BUSINESS_SEGMENT_AVIATION
    };*/

    /*public static final Map<String, String> SALES_ORGANISATION_MAPPING_FROM_ERP = new Map<String, String>{
        '1' => BUSINESS_SEGMENT_AUTOMOTIVE,
        '2' => BUSINESS_SEGMENT_LIFESTYLE,
        '3' => BUSINESS_SEGMENT_GLASS,
        '4' => BUSINESS_SEGMENT_AUTOMOTIVE,
        '5' => BUSINESS_SEGMENT_AVIATION
    };*/

    public static final Set<String> ABCCLASS_TO_CONSIDER = new Set<String>{'A','B'};

    public static void setPicklistValues(List<Account> accounts) {
        Map<String,String> salesOrgMap = new Map<String,String>();
        Map<String, String> businessSegmentMap = new Map<String, String>();
        Map<String, String> segmentMap = new Map<String, String>();
        Set<String> setOfSalesOrgValues = getPicklistValues(Account.PLCK_SalesOrganisation__c);
        Set<String> setOfABCClass = getPicklistValues(Account.PLCK_ABCClass__c);
        Map<String, PLCK_MapSalesOrganistation__mdt> salesOrgMetadataMap = PLCK_MapSalesOrganistation__mdt.getAll();
        Map<String, PLCK_Map_Business_Segment__mdt> businessSegmentMetadataMap = PLCK_Map_Business_Segment__mdt.getAll();
        Map<String, PLCK_Map_Segment__mdt> segmentMetadataMap = PLCK_Map_Segment__mdt.getAll();
        Set<String> setOfSalesRegionValues = getPicklistValues(Account.PLCK_SalesRegion__c);
        Set<String> segmentValues = getPicklistValues(Account.PLCK_Segment__c);
        Set<String> subSegmentValues = getPicklistValues(Account.PLCK_SubSegment__c);
        	
        for(String salesOrg : salesOrgMetadataMap.keySet()){
            salesOrgMap.put(salesOrgMetadataMap.get(salesOrg).PLCK_SalesOrgLabel__c,salesOrgMetadataMap.get(salesOrg).PLCK_SalesOrgNumber__c);
        }

        for(PLCK_Map_Business_Segment__mdt businessSegment : businessSegmentMetadataMap.values()) {

            businessSegmentMap.put(businessSegment.PLCK_Business_Segment_Code__c, businessSegment.PLCK_Business_Segment_Name__c);
        }

        for(PLCK_Map_Segment__mdt segment : segmentMetadataMap.values()) {

            segmentMap.put(segment.PLCK_Segment_Code__c, segment.PLCK_Segment_Code__c  + '0');
        }

        for (Account acc : accounts) {
            if (setOfSalesOrgValues.contains(acc.PLCK_SalesOrganisation_ERP__c)) {
                acc.PLCK_SalesOrganisation__c = acc.PLCK_SalesOrganisation_ERP__c;
            } else if (salesOrgMap.containsKey(acc.PLCK_SalesOrganisation_ERP__c)) {
                acc.PLCK_SalesOrganisation__c = salesOrgMap.get(acc.PLCK_SalesOrganisation_ERP__c);
            }

            if(acc.PLCK_BusinessSegment_ERP__c != null){
                String businessSegmentERPStart = (acc.PLCK_BusinessSegment_ERP__c).substring(0,1);
                String businessSegmentERPStart2 = (acc.PLCK_BusinessSegment_ERP__c).substring(0,2); 
                
                acc.PLCK_BusinessSegment__c = (businessSegmentERPStart != null && businessSegmentMap.containsKey(businessSegmentERPStart)) ? businessSegmentMap.get(businessSegmentERPStart) : null;
                
                if(acc.PLCK_BusinessSegment__c != null && businessSegmentERPStart2 != null){
                    acc.PLCK_Segment__c = businessSegmentERPStart2 != null && acc.PLCK_BusinessSegment_ERP__c.length() == 3 && segmentValues.contains(acc.PLCK_BusinessSegment_ERP__c) ? acc.PLCK_BusinessSegment_ERP__c: segmentMap.get(businessSegmentERPStart2);
                    acc.PLCK_SubSegment__c = acc.PLCK_BusinessSegment_ERP__c.length() == 4 && subSegmentValues.contains(acc.PLCK_BusinessSegment_ERP__c)? acc.PLCK_BusinessSegment_ERP__c : null;
               }
            }

            if (setOfABCClass.contains(acc.PLCK_ABCClass_ERP__c)) {
                acc.PLCK_ABCClass__c = acc.PLCK_ABCClass_ERP__c;
            }

            if(setOfSalesRegionValues.contains(acc.PLCK_SalesRegionText__c)){
                acc.PLCK_SalesRegion__c = acc.PLCK_SalesRegionText__c;
            }
        }
    }

    public static void setAccountOwner(List<Account> accounts, Map<Id, Account> oldAccounts) {
        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Set<String> erpSalesRepNumbers = new Set<String>();
        for(Account acc : accounts) {
            if(acc.RecordTypeId == customerRecTypeId && acc.Status__c == CUSTOMER_STATUS_ACTIVE && acc.PLCK_ERPSalesrepNumber__c != null && (oldAccounts == null || acc.PLCK_ERPSalesrepNumber__c != oldAccounts.get(acc.Id).PLCK_ERPSalesrepNumber__c)) {
                erpSalesRepNumbers.add(acc.PLCK_ERPSalesrepNumber__c);
            }
        }
        if(!erpSalesRepNumbers.isEmpty()) {
            Map<String, User> erpNumberToUserMap = new Map<String, User>();
            for(User u : [SELECT Id, PLCK_ERPUserNumber__c FROM User WHERE IsActive = TRUE AND PLCK_ERPUserNumber__c IN :erpSalesRepNumbers]) {
                erpNumberToUserMap.put(u.PLCK_ERPUserNumber__c, u);
            }
            for(Account acc : accounts) {
                if(acc.RecordTypeId == customerRecTypeId && acc.Status__c == CUSTOMER_STATUS_ACTIVE && acc.PLCK_ERPSalesrepNumber__c != null && (oldAccounts == null || acc.PLCK_ERPSalesrepNumber__c != oldAccounts.get(acc.Id).PLCK_ERPSalesrepNumber__c)) {
                    if(erpNumberToUserMap.containsKey(acc.PLCK_ERPSalesrepNumber__c)) {
                        acc.OwnerId = erpNumberToUserMap.get(acc.PLCK_ERPSalesrepNumber__c).Id;
                    }
                }
            }
        }
    }

    public static Set<String> getPicklistValues(SObjectField fieldName) {
        Set<String> values = new Set<String>();
        for (PLCK_CustomSelectOption cso : PLCK_CustomSelectOption.getSelectOptionsForPicklistField(fieldName)) {
            values.add(cso.value);
        }
        return values;
    }

    private static Boolean isVisionAccount(Account acc){
        return null != acc.PLCK_SalesOrganisation_ERP__c ? !acc.PLCK_SalesOrganisation_ERP__c.isNumeric() : false;
    }

    public static void assignSalesOrgPricebookToCustomer(List<Account> accounts, Map<Id, Account> oldAccounts) {
        Id customerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        List<Account> accountsToAssignPricebook = new List<Account>();
        Set<String> salesOrgs = new Set<String>();
        Set<String> visionSalesOrgs = new Set<String>();
        for (Account acc : accounts) {
            if (((oldAccounts == null && acc.RecordTypeId == customerRecTypeId && acc.Status__c == CUSTOMER_STATUS_ACTIVE) 
                ||(oldAccounts != null && acc.RecordTypeId != oldAccounts.get(acc.Id).RecordTypeId))
                ) {
                    accountsToAssignPricebook.add(acc);
                    if(isVisionAccount(acc)){
                        visionSalesOrgs.add(acc.PLCK_SalesOrganisation_ERP__c);
                    }else{
                        salesOrgs.add(acc.PLCK_SalesOrganisation_ERP__c);
                    }
            }
        }
        
        if(!salesOrgs.isEmpty() || !visionSalesOrgs.isEmpty()){

            Map<String,String> salesOrgERPmapping = PLCK_Utils.getSalesOrgERPMapping(visionSalesOrgs);
            salesOrgs.addAll(salesOrgERPmapping.values());
        
            Map<String,Id> pricebookBySalesOrg = new Map<String,Id>();
            List<Pricebook2> pricebooks = [SELECT Id, PLCK_SalesOrganisation__c FROM Pricebook2 WHERE PLCK_SalesOrganisation__c IN :salesOrgs];
            
            for(Pricebook2 prc : pricebooks) {
                pricebookBySalesOrg.put(prc.PLCK_SalesOrganisation__c, prc.Id);
            }

            if(!accountsToAssignPricebook.isEmpty()){
                for(Account acc: accountsToAssignPricebook){
                    String salesOrgNumber = isVisionAccount(acc) ? salesOrgERPmapping.get(acc.PLCK_SalesOrganisation_ERP__c) : acc.PLCK_SalesOrganisation_ERP__c;
                    acc.PLCK_PriceBook__c = pricebookBySalesOrg.get(salesOrgNumber);
                    System.debug(acc);
                }
            }
        }
    }
}