/** Date : 08/06/2019
*   Purpose : This batch updates all applicants complete details...
**/
global class BatchSyncApplicantCompleteDetails implements Database.Batchable<sObject>, Database.stateful,Database.AllowsCallouts{
    List<List<JazzHRWrapper.JobApplicatonWrapper>> returnedDataList = new List<List<JazzHRWrapper.JobApplicatonWrapper>>();
    global Database.QueryLocator start (Database.BatchableContext bContext){
        string queryString = 'Select Id From Applicant__c'; 
        return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext bContext,List<Applicant__c> scope){
        try{
            system.debug('*** List Of Job Listing ***'+scope.size());
         
            for(Applicant__c currentApplicant : scope){
                GetApplicantDetailController.getSingleApplicantRecord(currentApplicant.Id);
            }
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'BatchSyncApplicantCompleteDetails.Execute', null);    
        }
    }
    global void finish(Database.BatchableContext bContext){
        system.debug('Inside BatchSyncApplicantCompleteDetails Finish..'); 
    }
}