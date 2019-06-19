/** Developer 	: Sachin/Vinit
 *  Date		: 17 March 2019
 *  Purpose		:Test Class For SyncApplicantFromJazzHRClassic
**/ 
@isTest
public class TestSyncApplicantFromJazzHRClassic {
    static testMethod void testSyncApplicantFromJazzHRClassic(){
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c applicantObj = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert applicantObj;
        PageReference pageRef = Page.GetApplicantDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(applicantObj);
        SyncApplicantFromJazzHRClassic testSyncApplicant = new SyncApplicantFromJazzHRClassic(sc);
        SyncApplicantFromJazzHRClassic.syncApplicantDetails();
    }
}