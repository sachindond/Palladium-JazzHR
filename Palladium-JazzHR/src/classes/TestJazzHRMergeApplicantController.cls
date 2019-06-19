/** Developer 	: Sachin/Vinit
 *  Date 		: 11 March 2019
 *  Purpose		: Test class for JazzHR Merge Applicant Functionality
 **/
@isTest
public class TestJazzHRMergeApplicantController {
	
    static testMethod void testfindDuplicateApplicants(){
        // create applicant records
		JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c insertFirstApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert insertFirstApplicant;
        Applicant__c insertSecondApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJW','JazzHR');
        insert insertSecondApplicant;
        JazzHRMergeApplicantRecordsController.findDuplicateApplicants(insertFirstApplicant.Id);
   		JazzHRMergeApplicantRecordsController.getAllDuplicateApplicants(insertFirstApplicant.Id);
    }
    static testMethod void testgetAllDuplicateApplicants(){
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c insertFirstApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert insertFirstApplicant;
        Applicant__c insertSecondApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJW','JazzHR');
        insert insertSecondApplicant;
        JazzHRMergeApplicantRecordsController.getAllDuplicateApplicants(insertFirstApplicant.Id);
    }
    static testMethod void testMergeDuplicateApplicants(){
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c insertFirstApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert insertFirstApplicant;
        
        Applicant__c insertSecondApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJW','JazzHR');
        insert insertSecondApplicant;
        
        Job_Listing__c jobListingObj = new Job_Listing__c();
		jobListingObj.JazzHR_Job_ID__c = 'testId';
        insert jobListingObj;

        Job_Application__c jobApplication = new Job_Application__c();
        jobApplication.Applicant__c	= insertSecondApplicant.id;
        jobApplication.Job_Listing__c = jobListingObj.id;
        insert jobApplication;
        
        Questionnaire__c questionObject = new Questionnaire__c();
        questionObject.Applicant__c = insertSecondApplicant.Id;
        questionObject.Question__c ='Test Question';
        questionObject.Answer__c ='Test Answer';
        insert questionObject;
        JazzHRMergeApplicantRecordsController.MergeDuplicateApplicants(insertFirstApplicant.Id, 'test@test.com');
    }
        
    
}