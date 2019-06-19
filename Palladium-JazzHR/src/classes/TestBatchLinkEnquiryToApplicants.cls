/** Developer		: Sachin/Vinit
 *  Date			: 17 March 2019
 *  Purpose			: Test Class For BatchLinkEnquiryToApplicants
 **/
@isTest
public class TestBatchLinkEnquiryToApplicants {
    static testMethod void testBatchLinkEnquiryToApplicants(){
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Lead leadObj = handlerObj.createLead('test@test.com');
        insert leadObj;
        Applicant__c applicantObj = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert applicantObj;
        Test.startTest();
        BatchLinkEnquiryToApplicants batchLinkeEnquiryBatchObj = new BatchLinkEnquiryToApplicants();
        database.executeBatch(batchLinkeEnquiryBatchObj);
        Test.stopTest();
    }
   
}