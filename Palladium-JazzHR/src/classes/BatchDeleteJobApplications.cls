/** Date : 18/06/2019
 *  Purpose : This batch class is to delete job applications which is in inconsistent state 
 *  i.e JazzHR Application Id is missing on job applications.
 *  BASE Phase - 4
**/

global class BatchDeleteJobApplications implements Database.Batchable<sObject> {
    global database.QueryLocator start(database.BatchableContext bContext){
        // get the list of job applications where jazzhr_job_application_id = null
        string queryString = 'select id from Job_Application__c where JazzHR_Job_Application_ID__c=null';
        return database.getQueryLocator(queryString);
    }
    global void execute(database.BatchableContext bContext,List<Job_Application__c> lstJobApplication){
        system.debug('***** List to Delete the Job Application Size ***'+lstJobApplication.size());
        try{
            if(lstJobApplication.size()>0)
                delete lstJobApplication;
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'BatchDeleteJobApplications.Execute', null);    
        }
    }
    global void finish(database.BatchableContext bContext){
        system.debug('** Inside BatchDeleteJobApplications Finish Method **');
    }
}