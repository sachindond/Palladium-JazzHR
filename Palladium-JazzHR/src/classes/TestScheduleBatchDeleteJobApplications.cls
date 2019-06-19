/** Date : 18/06/2019 
 *  Test Class for ScheduleBatchDeleteJobApplications
**/
@isTest
public class TestScheduleBatchDeleteJobApplications {
    public static testMethod void TestScheduleDeleteJobApplicationBatch() {
        Test.StartTest();
        ScheduleBatchDeleteJobApplications testsche = new ScheduleBatchDeleteJobApplications();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche);
        Test.stopTest();
    }
}