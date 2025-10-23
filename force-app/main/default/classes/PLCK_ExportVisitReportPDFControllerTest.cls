@IsTest
public with sharing class PLCK_ExportVisitReportPDFControllerTest {

    @IsTest
    static void shouldReturnDataForPDFExport() {
        PLCK_TestDataFactory.createPricebookForProspectAccounts();
        Account acc = PLCK_TestDataFactory.createAccount();
        PLCK_VisitReport__c vr = PLCK_TestDataFactory.createVisitReport(acc.Id);
        PLCK_Participant__c participant = new PLCK_Participant__c(PLCK_Contact__c = PLCK_TestDataFactory.createContact('1').Id, PLCK_VisitReport__c = vr.Id, PLCK_Type__c = PLCK_ExportVisitReportPDFController.PLCK_PARTICIPANT_TYPE_CUSTOMER_CONTACT);
        PLCK_Participant__c participant2 = new PLCK_Participant__c(PLCK_Contact__c = PLCK_TestDataFactory.createContact('2').Id, PLCK_VisitReport__c = vr.Id, PLCK_Type__c = PLCK_ExportVisitReportPDFController.PLCK_PARTICIPANT_TYPE_PL);
        insert new List<PLCK_Participant__c>{participant, participant2};

        Test.startTest();
        PageReference pageRef = Page.PLCK_ExportVisitReportPDF;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(vr.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(vr);
        PLCK_ExportVisitReportPDFController testAccPlan = new PLCK_ExportVisitReportPDFController(sc);
        Test.stopTest();

        System.assertEquals(1, testAccPlan.participantsCustomer.size());
        System.assertEquals(1, testAccPlan.participantsPL.size());
    }
}