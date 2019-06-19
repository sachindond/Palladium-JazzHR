/**
* Developer	: Vinit/Sachin
* Date			: 20 Feb 2019
* Purpose		: Controller to handle merging of lightning component.
**/

public class JazzHRMergeApplicantRecordsController {
    
    public class ApplicantWrapper{
        @AuraEnabled
        public boolean isSelected{get;set;}
        @AuraEnabled
        public string recordId{get;set;}
        @AuraEnabled
        public string firstName{get;set;}
        @AuraEnabled
        public string lastName{get;set;}
        @AuraEnabled
        public string email{get;set;}
        @AuraEnabled
        public string jazzHRId{get;set;}
        @AuraEnabled
        public date applyDate{get;set;}
        @AuraEnabled
        public integer totalJobApplications{get;set;}
        @AuraEnabled
        public integer totalQuestionnaire{get;set;}
        
        
        ApplicantWrapper(){
            isSelected = false;
        }
    }
    
    @AuraEnabled
    public static list<Applicant__c> findDuplicateApplicants(string applicantId){
        system.debug('applicantId'+applicantId);
        Applicant__c applicantRecord = [select id,Email__c,JazzHR_Applicant_ID__c from Applicant__c where id=:applicantId limit 1];
        system.debug('** Applicant Records ***'+applicantRecord);
        list<Applicant__c> lstOfDuplicateApplicants = null;
        if(applicantRecord.Email__c != null)
        {
            lstOfDuplicateApplicants = [select id,email__c,first_Name__c,Last_Name__c,JazzHR_Applicant_ID__c from Applicant__c where email__c=:applicantRecord.Email__c and Id !=:applicantRecord.id];
            if(lstOfDuplicateApplicants.size() == 0)
                lstOfDuplicateApplicants = null;
        }
        system.debug('lstOfDuplicateApplicants: ' + lstOfDuplicateApplicants);
        
        return lstOfDuplicateApplicants;
    }
    
    @AuraEnabled
    public static list<ApplicantWrapper> getAllDuplicateApplicants(string applicantId){
        system.debug('*************applicantId'+applicantId);
        list<ApplicantWrapper> lstApplicantWrapper = new list<ApplicantWrapper>();
        Applicant__c applicantRecord = [select id,Email__c,JazzHR_Applicant_ID__c from Applicant__c where id=:applicantId limit 1];
        system.debug('** Applicant Records ***'+applicantRecord);
        list<Applicant__c> lstOfDuplicateApplicants;
        lstOfDuplicateApplicants = [select id,email__c,Apply_Date__c,first_Name__c,Last_Name__c,JazzHR_Applicant_ID__c,(select id from Job_Applications__r),(select id,Answer__c,Question__c from Questionnaire__r) from Applicant__c where email__c=:applicantRecord.Email__c];
        System.debug('*** lst of applicants'+lstOfDuplicateApplicants);
        if(lstOfDuplicateApplicants.size()>0){
            for(Applicant__c ap: lstOfDuplicateApplicants){
                ApplicantWrapper appObj = new ApplicantWrapper();
                appObj.recordId = ap.id;
                appObj.firstName = ap.First_Name__c;
                appObj.lastName = ap.Last_Name__c;
                appObj.jazzHRId = ap.JazzHR_Applicant_ID__c;
                appObj.email = ap.Email__c;
                appObj.applyDate = ap.Apply_Date__c;
                appObj.totalJobApplications = ap.Job_Applications__r.size();
                appObj.totalQuestionnaire = ap.Questionnaire__r.size();
                lstApplicantWrapper.add(appObj);
            }
        }
        return lstApplicantWrapper;
    }
    
    
    // Sachin : This method is newly created for upsert question and job applications orignal method is commented below
    // Date : 11/06/2019
    @AuraEnabled
    public static boolean MergeDuplicateApplicants(string masterApplicantId, string email){
       //get all duplicate applicants with applications and questionnaries
        boolean bret = false;
        
        try{
            string query = 'select id, JazzHR_Applicant_ID__c, (' + getQueryString('Job_Applications__r') + 
                '), (' + getQueryString('Questionnaire__r') + ') from Applicant__c where email__c=:email and Id !=:masterApplicantId';
            
            system.debug('query: ' + query);
            List<Applicant__c> lstOfDuplicateApplicants = Database.query(query);
             system.debug('***********lstOfDuplicateApplicants'+lstOfDuplicateApplicants);                           
            //iterate through each and prepare lists to update
            List<Job_Application__c> ApplicantionsToMerge = new List<Job_Application__c>();
            List<Questionnaire__c> QuestionsToMerge = new List<Questionnaire__c>();  
            List<Job_Application__c> ApplicantionsToDelete = new List<Job_Application__c>();
            List<Questionnaire__c> QuestionsToDelete = new List<Questionnaire__c>();  
            List<Log_Entry__c> lstLogEntries = new List<Log_Entry__c>();
                                                                                                           
            For(Applicant__c currentApplicant : lstOfDuplicateApplicants)
            {
                if(currentApplicant.Job_Applications__r !=null)
                {
                    For(Job_Application__c currentApplication: currentApplicant.Job_Applications__r)
                    {
                        Job_Application__c moveApplication = currentApplication.clone();
                        moveApplication.Applicant__c = masterApplicantId;
                        ApplicantionsToMerge.add(moveApplication);
                        ApplicantionsToDelete.add(currentApplication);
                        
                    }
                }
                
                if(currentApplicant.Questionnaire__r !=null)
                {
                    For(Questionnaire__c currentQuestion: currentApplicant.Questionnaire__r)
                    {
                        Questionnaire__c moveQuestion = currentQuestion.clone();
                        moveQuestion.Applicant__c = masterApplicantId;
                        QuestionsToMerge.add(moveQuestion);
                        QuestionsToDelete.add(currentQuestion);
                    }
                }
            }
            system.debug('***ApplicantionsToMerge'+ApplicantionsToMerge);
            system.debug('***QuestionsToMerge'+QuestionsToMerge);
            system.debug('***ApplicantionsToDelete'+ApplicantionsToDelete);
            system.debug('***QuestionsToDelete'+QuestionsToDelete);
            
            if(ApplicantionsToMerge.size() > 0)
                delete ApplicantionsToDelete;
            
            if(ApplicantionsToMerge.size() > 0){
              	Database.UpsertResult[] upsertResults = Database.upsert(ApplicantionsToMerge, Job_Application__c.Fields.JazzHR_Job_Application_ID__c, false); 
                for(Database.UpsertResult upsertResultsObj : upsertResults) {
                    if(upsertResultsObj.isSuccess()){
                        continue; // next item
                    }else{
                        List<Database.Error> errors = upsertResultsObj.getErrors();
                        for(Database.Error errorObj : Errors) {
                            Log_Entry__c newentry = new Log_Entry__c();
                            newEntry.Function__c = 'JazzHRMergeApplicantRecordsController.MergeDuplicateApplicants';
                            newEntry.Message__c = 'Status Code: ' + errorObj.getStatusCode() + ': Error: ' + errorObj.getMessage();
                            newentry.Type__c = 'Error';
                            lstLogEntries.add(newentry);
                        }
                    }
                } 
                insert lstLogEntries;
            }
            if(QuestionsToMerge.size() > 0)
                insert QuestionsToMerge;
            
            
            
            if(QuestionsToMerge.size() > 0)
               delete QuestionsToDelete;
            
            //Store the JazzHR Ids to master applicants before deleting duplicate applicants. These can be used later to refetch records.
            string deletedJazzHRIds = '';
            for(Applicant__c currentApplicant: lstOfDuplicateApplicants)
            {
                deletedJazzHRIds = deletedJazzHRIds + currentApplicant.JazzHR_Applicant_ID__c + ';';
            }
            
            if(deletedJazzHRIds != '')
            {
                
                Applicant__c masterApplicant = [select id,Deleted_Applicant_Ids__c from Applicant__c where id=:masterApplicantId];
                system.debug('*** Master Applicant ****'+masterApplicantId+'##'+masterApplicant.Deleted_Applicant_Ids__c);
                string [] deletedIds = deletedJazzHRIds.split(';');
                system.debug('deletedIds'+deletedIds);
                if(masterApplicant.Deleted_Applicant_Ids__c!=null){
                    for(integer i = 0; i<deletedIds.size(); i++)
                    {
                        system.debug('***Deleted ids stirng'+deletedIds[i]);
                        
                        if(!masterApplicant.Deleted_Applicant_Ids__c.contains(deletedIds[i])){
                            system.debug('**In if loop ');
                            masterApplicant.Deleted_Applicant_Ids__c = deletedJazzHRIds + deletedIds[i]+';';
                        }else{
                            system.debug('**In if loop  deletedIds[i]'+ deletedIds[i]);
						}
                        
                    }
                }else{
                    system.debug('**In else loop ');
                    masterApplicant.Deleted_Applicant_Ids__c = deletedJazzHRIds;
                }
                system.debug('**before delete'+masterApplicant.Deleted_Applicant_Ids__c);
                update masterApplicant;
                system.debug('***after update DELETED IDS'+deletedJazzHRIds);
               // Applicant__c masterApplicant = new Applicant__c(Id = masterApplicantId, Deleted_Applicant_Ids__c = deletedJazzHRIds);
               // update masterApplicant;
				
            }
            
            if(lstOfDuplicateApplicants != null && lstOfDuplicateApplicants.size() > 0)
              delete lstOfDuplicateApplicants;
            
            bret = true;
        }
        catch (Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRMergeApplicantRecordsController.MergeDuplicateApplicants', '');    
            bret = false;
        }
        return bret;
    }
    
    // Merge Applicant Old Method commented on - 11/06/2019 
    // Reason : we need to update this to handle all upsert of Questionnaire__c and Job_Applications__c
    /*  
    @AuraEnabled
    public static boolean MergeDuplicateApplicants(string masterApplicantId, string email){
        //get all duplicate applicants with applications and questionnaries
        boolean bret = false;
        
        try{
            string query = 'select id, JazzHR_Applicant_ID__c, (' + getQueryString('Job_Applications__r') + 
                '), (' + getQueryString('Questionnaire__r') + ') from Applicant__c where email__c=:email and Id !=:masterApplicantId';
            
            system.debug('query: ' + query);
            List<Applicant__c> lstOfDuplicateApplicants = Database.query(query);
             system.debug('***********lstOfDuplicateApplicants'+lstOfDuplicateApplicants);                           
            //iterate through each and prepare lists to update
            List<Job_Application__c> ApplicantionsToMerge = new List<Job_Application__c>();
            List<Questionnaire__c> QuestionsToMerge = new List<Questionnaire__c>();  
            List<Job_Application__c> ApplicantionsToDelete = new List<Job_Application__c>();
            List<Questionnaire__c> QuestionsToDelete = new List<Questionnaire__c>();  
                                                                                                           
            For(Applicant__c currentApplicant : lstOfDuplicateApplicants)
            {
                if(currentApplicant.Job_Applications__r !=null)
                {
                    For(Job_Application__c currentApplication: currentApplicant.Job_Applications__r)
                    {
                        Job_Application__c moveApplication = currentApplication.clone();
                        moveApplication.Applicant__c = masterApplicantId;
                        ApplicantionsToMerge.add(moveApplication);
                        ApplicantionsToDelete.add(currentApplication);
                        
                    }
                }
                
                if(currentApplicant.Questionnaire__r !=null)
                {
                    For(Questionnaire__c currentQuestion: currentApplicant.Questionnaire__r)
                    {
                        Questionnaire__c moveQuestion = currentQuestion.clone();
                        moveQuestion.Applicant__c = masterApplicantId;
                        QuestionsToMerge.add(moveQuestion);
                        QuestionsToDelete.add(currentQuestion);
                    }
                }
            }
            system.debug('***ApplicantionsToMerge'+ApplicantionsToMerge);
            system.debug('***QuestionsToMerge'+QuestionsToMerge);
            system.debug('***ApplicantionsToDelete'+ApplicantionsToDelete);
            system.debug('***QuestionsToDelete'+QuestionsToDelete);
            if(ApplicantionsToMerge.size() > 0)
                insert ApplicantionsToMerge;
            
            if(QuestionsToMerge.size() > 0)
                insert QuestionsToMerge;
            
            if(ApplicantionsToMerge.size() > 0)
                delete ApplicantionsToDelete;
            
            if(QuestionsToMerge.size() > 0)
               delete QuestionsToDelete;
            
            //Store the JazzHR Ids to master applicants before deleting duplicate applicants. These can be used later to refetch records.
            
            string deletedJazzHRIds = '';
            for(Applicant__c currentApplicant: lstOfDuplicateApplicants)
            {
                deletedJazzHRIds = deletedJazzHRIds + currentApplicant.JazzHR_Applicant_ID__c + ';';
            }
            
            if(deletedJazzHRIds != '')
            {
                Applicant__c masterApplicant = new Applicant__c(Id = masterApplicantId, Deleted_Applicant_Ids__c = deletedJazzHRIds);
                update masterApplicant;
            }
            
            if(lstOfDuplicateApplicants != null && lstOfDuplicateApplicants.size() > 0)
              delete lstOfDuplicateApplicants;
            
            bret = true;
        }
        catch (Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRMergeApplicantRecordsController.MergeDuplicateApplicants', '');    
            bret = false;
        }
        return bret;
    }  
   */        
   public static List<Schema.FieldSetMember> getFields(string objectname) {
        if(objectname == 'Job_Applications__r')
            return SObjectType.Job_Application__c.FieldSets.Job_Application_Field_Set.getFields();
        if(objectname == 'Questionnaire__r')
        	return SObjectType.Questionnaire__c.FieldSets.Questionnaire_Field_Set.getFields();
        else
            return null;
   }
   
   public static String getQueryString(string objectname) {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : getFields(objectname)) {
            query += f.getFieldPath() + ',';
        }
        query = query.substring(0, query.length() - 1);
        query += ' FROM ' + objectname;
        return query;
   }
   
    
    
    /*
    public static boolean sendEmail(string applicantId){
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setTargetObjectId(applicantId); 
            mail.setSenderDisplayName('BASE Notification'); 
            mail.setUseSignature(false); 
            mail.setBccSender(false); 
            mail.setSaveAsActivity(false);
          // TO ADDRESS SHOUL 
			mail.toaddresses =new String[] { 'er.sachindond@gmail.com','vinitjknasik@gmail.com'};
            EmailTemplate et=[Select id from EmailTemplate where Name=:'Notify Applicant To Register Via Talent Pool']; 
            mail.setTemplateId(et.id); 
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            return true;
        }
        catch(Exception oEx)
        {
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRMergeApplicantRecordsController.sendEmail', '');    
            return false;
        }
    }
*/
}