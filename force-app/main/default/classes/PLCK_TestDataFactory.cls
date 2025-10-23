@IsTest
public with sharing class PLCK_TestDataFactory {

    public static Account createAccount() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PLCK_SalesOrganisation__c = PLCK_AccountService.SALES_ORGANISATION_DE;
        insert acc;
        return acc;
    }

    public static List<Account> prepareAccounts(Decimal numberOfAccounts, String priceGroup) {
        List<Account> accounts = new List<Account>();
        for (Decimal i = 0; i < numberOfAccounts; i++) {
            accounts.add(new Account(
                    Name = PLCK_Utils.generateRandomString(5),
                    PLCK_SalesOrganisation__c = PLCK_AccountService.SALES_ORGANISATION_DE,
                    PLCK_SalesOrganisation_ERP__c = PLCK_AccountService.SALES_ORGANISATION_DE,
                    PLCK_PriceGroup__c = priceGroup,
                    PLCK_SAP_BPNumber__c = String.valueOf(i)
            ));
        }
        return accounts;
    }

    public static PLCK_VisitReport__c createVisitReport(String accId) {
        PLCK_VisitReport__c vr = new PLCK_VisitReport__c();
        vr.PLCK_Account__c = accId;
        insert vr;
        return vr;
    }

    public static Contact createContact(String uniqueChar) {
        Contact con = new Contact();
        con.FirstName = 'John' + uniqueChar;
        con.LastName = 'Doe' + uniqueChar;
        con.Email = 'john@test.test' + uniqueChar;
        insert con;
        return con;
    }

    public static Product2 prepareProduct(String salesOrg, String productCode) {
        return new Product2(
                Name = PLCK_Utils.generateRandomString(5),
                PLCK_SalesOrganisation_ERP__c = salesOrg,
                ProductCode = productCode
        );
    }

    public static PLCK_PriceLine__c preparePriceLine(String salesOrg, String salesMaterialNumber, String priceGroup, Decimal price, String customerNumber) {
        return new PLCK_PriceLine__c(
                PLCK_SalesOrganisation_ERP__c = salesOrg,
                PLCK_SalesMaterialNumber__c = salesMaterialNumber,
                PLCK_PriceGroup__c = priceGroup,
                PLCK_SalesPrice__c = price,
                PLCK_CustomerNumber__c = customerNumber
        );
    }

    public static List<PLCK_PriceLine__c> prepareScalePriceLines(String salesOrg, String salesMaterialNumber, String priceGroup, Decimal price, String customerNumber, Decimal numberOfThresholds) {
        List<PLCK_PriceLine__c> pls = new List<PLCK_PriceLine__c>();
        for (Decimal i = 0; i < numberOfThresholds; i++) {
            pls.add(new PLCK_PriceLine__c(
                    PLCK_SalesOrganisation_ERP__c = salesOrg,
                    PLCK_SalesMaterialNumber__c = salesMaterialNumber,
                    PLCK_PriceGroup__c = priceGroup,
                    PLCK_CustomerNumber__c = customerNumber,
                    PLCK_SalesPrice__c = (i * 3) + 1,
                    PLCK_ScaleThreshold__c = (i * 3) + 1,
                    PLCK_SalesPriceIndicator__c = 'C'
            ));
        }
        return pls;
    }

    public static void createPricebookForProspectAccounts() {
        insert new List<Pricebook2>{
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '1350', IsActive = true),
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '1020', IsActive = true),
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '2120', IsActive = true),
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '1820', IsActive = true),
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '5520', IsActive = true),
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '2620', IsActive = true),
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '3620', IsActive = true),
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '1720', IsActive = true),
                new Pricebook2(Name = PLCK_Utils.generateRandomString(5), PLCK_SalesOrganisation__c = '1730', IsActive = true)
        };
    }

    public static User createStandardUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        return new User(
                Alias = 'standt',
                Email = 'standarduser@testorg.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                ManagerId = UserInfo.getUserId(),
                Username = PLCK_Utils.generateRandomString(10) + '@test.test');
    }
}