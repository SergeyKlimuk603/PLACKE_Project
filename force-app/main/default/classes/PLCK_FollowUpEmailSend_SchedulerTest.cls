@isTest
public class PLCK_FollowUpEmailSend_SchedulerTest {
    
    @isTest
    private static void executeTest(){

        Test.startTest();

        PLCK_FollowUpEmailSend_Scheduler scheduleFollowUp = new PLCK_FollowUpEmailSend_Scheduler(); 
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule follow up email', sch, scheduleFollowUp);

        Test.stopTest();
    }
}