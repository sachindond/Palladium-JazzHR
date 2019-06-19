/** Developer 	: Sachin/Vinit
 *  Date		: 17 March 2019
 *  Purpose		: Test Class For ScheduleJazzHRBatches
**/
@isTest
public class TestScheduleJazzHRBatches {
	public static testMethod void TestScheduleJazzHRBatches() {
		Test.StartTest();
            ScheduleJazzHRBatches testsche = new ScheduleJazzHRBatches();
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
}