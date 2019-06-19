/** Date 17/6/2019
 * purpose : Test class for  ScheduleBatchApplicantCompleteDetails
 **/
@isTest
public class TestScheduleBatchApplicantDetails {
    public static testMethod void testApplicantDetails() {
        Test.startTest();
        ScheduleBatchApplicantCompleteDetails testsche = new ScheduleBatchApplicantCompleteDetails();
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c insertFirstApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert insertFirstApplicant;
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        
        Test.stopTest();
    }
}