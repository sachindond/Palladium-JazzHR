// Date : 6/6/2019
// Test Class for Scheduler 
@isTest
public class TestScheduleBatchUpdateJobApplication {
    public static testMethod void TestScheduleJazzHRBatches() {
        Test.StartTest();
        ScheduleBatchUpdateJazzHRJobApplication testsche = new ScheduleBatchUpdateJazzHRJobApplication();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}