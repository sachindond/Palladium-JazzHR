@isTest
public class TestJazzHRFetchDeletedApplicant {
    static testMethod void testfetchDeletedApplicant(){
        // create applicant records
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c insertFirstApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert insertFirstApplicant;
        JazzHRFetchDeletedApplicantController.fetchDeletedApplicant(insertFirstApplicant.Id);
    }
}