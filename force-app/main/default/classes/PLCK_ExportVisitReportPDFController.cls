public with sharing class PLCK_ExportVisitReportPDFController {

    public static final String PLCK_PARTICIPANT_TYPE_CUSTOMER_CONTACT = 'Customer Contact';
    public static final String PLCK_PARTICIPANT_TYPE_PL = 'PL';
    public PLCK_VisitReport__c visitReport{get; set;}
    public List<PLCK_Participant__c> participantsCustomer{get; set;}
    public List<PLCK_Participant__c> participantsPL{get; set;}

    public PLCK_ExportVisitReportPDFController(ApexPages.StandardController stdController) {
        this.visitReport = (PLCK_VisitReport__c)stdController.getRecord();
        this.participantsCustomer = [SELECT Id, PLCK_Contact__r.Name FROM PLCK_Participant__c WHERE PLCK_Type__c = :PLCK_PARTICIPANT_TYPE_CUSTOMER_CONTACT AND PLCK_VisitReport__c = :visitReport.Id];
        this.participantsPL = [SELECT Id, PLCK_Contact__r.Name FROM PLCK_Participant__c WHERE PLCK_Type__c = :PLCK_PARTICIPANT_TYPE_PL AND PLCK_VisitReport__c = :visitReport.Id];
    }
}