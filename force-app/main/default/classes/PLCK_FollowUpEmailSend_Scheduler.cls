global class PLCK_FollowUpEmailSend_Scheduler implements Schedulable{
    
    global void execute(SchedulableContext sc) {

        PLCK_FollowUpEmailSend_Batch b = new PLCK_FollowUpEmailSend_Batch();
        database.executeBatch(b);
    }
}