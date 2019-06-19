global class BatchSyncApplicantsFromJazzHR implements 
Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    global string batchRunDate = null; 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        try
        {   
            // get date from custom setting to decide whether to run batch for yesterday or given date.
            JazzHR_Setting__c jazzHRSettingObj = JazzHR_Setting__c.getInstance('JazzHR');
            
            If(jazzHRSettingObj !=null)
            {
                batchRunDate = jazzHRSettingObj.Batch_Run_Date__c;
                system.debug('Batch Run Date From custom Setting: ' + batchRunDate);
            }            
        }
        catch(Exception oEx)
        {
            //Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'BatchSyncApplicantsFromJazzHR.Start', null);    
        }     
        
        //dummy query call for getting valid QueryLocator.
        string query = 'SELECT ID From Applicant__c Limit 1';
        return Database.getQueryLocator(query);
    }
    
    //Batch executes the Get Daily JazzHR Applicant Callouts and then upserts the details received into Applicant object.
    global void execute(Database.BatchableContext bc, List<Applicant__c> scope){
        try
        {
            system.debug('Inside BatchSyncApplicantsFromJazzHR execute batchRunDate: ' + batchRunDate);
            Date previoudDay = Date.today() - 1;
            if(String.isEmpty(batchRunDate) || batchRunDate == null)
                batchRunDate = string.valueOf(previoudDay.year()) + '-' + string.valueOf(previoudDay.month()) + '-' + string.valueOf(previoudDay.day());
            
            system.debug('Final batchRunDate: ' + batchRunDate);
            List<List<JazzHRWrapper.ApplicantWrapper>> returnedDataList = JazzHRCallouts.GetApplicantsByDate(batchRunDate);  
            boolean status = JazzHRSFDCUtils.SyncApplicants(returnedDataList);
            system.debug('JazzHRSFDCUtils.SyncApplicants(returnedDataList) Status: ' + status);
        }
        catch(Exception oEx)
        {
            //Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'BatchSyncApplicantsFromJazzHR.Execute', null);    
        }
    } 
    
    global void finish(Database.BatchableContext bc){
        try
        {
            system.debug('Inside BatchSyncApplicantsFromJazzHR Finish');   

        }
        catch(Exception oEx)
        {
            //Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'BatchSyncApplicantsFromJazzHR.Finish', null);    
        }
    }    
}