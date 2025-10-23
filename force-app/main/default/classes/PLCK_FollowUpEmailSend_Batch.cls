public without sharing class PLCK_FollowUpEmailSend_Batch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, PLCK_FollowUpDate__c, OwnerId, Owner.FirstName, Owner.LastName FROM Opportunity WHERE PLCK_FollowUpDate__c = TOMORROW');
    }

    public void execute(Database.BatchableContext bc, List<Object> scope) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp : (List<Opportunity>) scope) {

            String oppLink = URL.getOrgDomainUrl().toExternalForm()+'/'+opp.Id;
            String htmlEmailBody = 'Hello '+opp.Owner.FirstName + ' ' + opp.Owner.LastName+', <br/>' + 
                                   '<br/> This is a reminder that the opportunity <a href=' + oppLink + '>' + opp.Name + '</a> has a follow-up date at '+opp.PLCK_FollowUpDate__c.format();
            String oppOwnerFirstName = opp.Owner.FirstName;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(opp.OwnerId);
            email.setSaveAsActivity(false);
            email.setSubject('Follow up on '+opp.Name);
            email.setHtmlBody(htmlEmailBody);
            emails.add(email);
        }

        // Send emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    public void finish(Database.BatchableContext bc) {}
}