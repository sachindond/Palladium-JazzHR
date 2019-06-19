/** Developer 	: Sachin/Vinit
 *  Date		: 11 March 2019
 *  Purpose		: Test class for JazzHR Applicant Journey Controller
 **/
@isTest
public class TestJazzHRApplicantJourneyController {
    static testMethod void testfetchApplicant(){
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c applicantObj = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert applicantObj;
        JazzHRApplicantJourneyController.fetchApplicant('test');
        
    }
    static testMethod void testgetApplicantsData(){
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
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
        JazzHRApplicantJourneyController.getApplicantsData(insertSecondApplicant.id);
    }
    
}