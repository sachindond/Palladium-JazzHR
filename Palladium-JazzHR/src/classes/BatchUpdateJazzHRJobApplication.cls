/** Date : 03/06/2019
*   Purpose : This batch update workflow id on Job Application Record...
**/
global class BatchUpdateJazzHRJobApplication implements Database.Batchable<sObject>, Database.stateful,Database.AllowsCallouts{
    List<List<JazzHRWrapper.JobApplicatonWrapper>> returnedDataList = new List<List<JazzHRWrapper.JobApplicatonWrapper>>();
    global Database.QueryLocator start (Database.BatchableContext bContext){
        string queryString = 'select id,JazzHR_Job_ID__c,Status__c from Job_Listing__c'; // where Status__c !=\'Closed\''; Need to take all job listings.
        return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext bContext,List<Job_Listing__c> scope){
       try{
            system.debug('*** List Of Job Listing ***'+scope.size());
            //step 1. Get Job Applications for each job
            for(Job_Listing__c jobListingObj : scope){
              
                List<List<JazzHRWrapper.JobApplicatonWrapper>> currentJobApplicationList = 
                    	JazzHRCallouts.getJobApplicationByJobId(jobListingObj.JazzHR_Job_ID__c);
                if(currentJobApplicationList != null)
                {
                    system.debug('Current Job Listing Applications: ' + currentJobApplicationList.size());
                    returnedDataList.addAll(currentJobApplicationList); 
                }
            }
            system.debug('returnedDataList size: ' + returnedDataList.size());
            if(returnedDataList != null && returnedDataList.size() > 0)
                JazzHRSFDCUtils.SyncJobApplicationsByJobId(returnedDataList);
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'BatchUpdateJazzHRJobApplication.Execute', null);    
        }
    }
    global void finish(Database.BatchableContext bContext){
        system.debug('Inside BatchUpdateJazzHRJobApplication Finish..'); 
    }
}