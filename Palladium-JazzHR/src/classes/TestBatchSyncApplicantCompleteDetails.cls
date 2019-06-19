/** Date : 17/6/2019
* Purpose : Test class to cover BatchSyncApplicantCompleteDetails
**/
@isTest
public class TestBatchSyncApplicantCompleteDetails {
    static testMethod void testgetSingleApplicantRecord(){
        // create applicant records
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c insertFirstApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert insertFirstApplicant;
        BatchSyncApplicantCompleteDetails batchObj = new BatchSyncApplicantCompleteDetails();
        database.executeBatch(batchObj);
    }
}