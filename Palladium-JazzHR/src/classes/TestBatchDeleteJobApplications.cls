/** Date : 19/06/2019
 *  Purpose : Test class for BatchDeleteJobApplications
**/
@isTest
public class TestBatchDeleteJobApplications {
    public static testMethod void testBatchDeleteJobApplication(){
        
        // create test records applicant, job listing, and job application
        
        Applicant__c appObj = new Applicant__c();
        appObj.Email__c= 'test@test.com';
        appObj.First_Name__c = 'testFirstName';
        appObj.Last_Name__c = 'testLastName';
        appObj.JazzHR_Applicant_ID__c = 'prospect_20190125164225_AEOQV5MUGH5DTOJK';
        insert appObj;
        // create job listing
        Job_Listing__c jobListingObj = new Job_Listing__c();
        jobListingObj.JazzHR_Job_ID__c = 'job_20181126172240_AX3UHKDC1UNW1LSJ';
        insert jobListingObj;
        
        // create job application
        Job_Application__c jobApplicatonObj = new Job_Application__c();
        jobApplicatonObj.Applicant__c = appObj.id;
        jobApplicatonObj.Job_Listing__c = jobListingObj.id;
        insert jobApplicatonObj;
        
        BatchDeleteJobApplications batchObj = new BatchDeleteJobApplications();
        database.executeBatch(batchObj);
    }
}