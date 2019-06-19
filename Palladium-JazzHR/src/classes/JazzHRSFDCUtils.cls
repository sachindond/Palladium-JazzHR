/* 
* Developer 	: Sachin/Vinit
* Date			: 29 Jan 2019
* Purpose		: This class will be utilised to add generic utility methods that can be used from 
batch as well as one time activities like data migration and real time sync. 
*/
public class JazzHRSFDCUtils {
    //sync list of users with SFDC from JazzHr. Fetching all users because filter on date is not possible and data is low.
    public static boolean SyncUsers(List<List<JazzHRWrapper.UserWrapper>> returnedDataList)
    {
        try
        {
            List<JazzHR_User__c> UsersToUpsertList = new List<JazzHR_User__c>();
            
            system.debug('returnedDataList size: ' + returnedDataList.size());
            
            For(List<JazzHRWrapper.UserWrapper> currentListofUsers: returnedDataList)
            {
                system.debug('currentList.size: ' + currentListofUsers.size());
                
                For(JazzHRWrapper.UserWrapper currentUser: currentListofUsers)
                {
                    JazzHR_User__c newUser = new JazzHR_User__c();
                    newUser.Date_Created__c = currentUser.date_created;
                    newUser.Email__c = currentUser.email;
                    newUser.First_Name__c = currentUser.first_name;
                    newUser.JazzHr_User_ID__c = currentUser.id;
                    newUser.Last_Name__c = currentUser.last_name;
                    newUser.Type__c = currentUser.type;
                    
                    UsersToUpsertList.add(newUser);
                }
            }
            
            If(UsersToUpsertList != null && UsersToUpsertList.size()>0)
            {
                system.debug('UsersToUpsertList size: ' + UsersToUpsertList.size());
                upsert UsersToUpsertList JazzHr_User_ID__c;
            }
            return true;
        }
        catch(Exception oEx)
        {
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRSFDCUtils.SyncUsers', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return false;
        }
    }
    
    //sync list of Jobs with SFDC from JazzHr
    public static boolean SyncJobs(List<List<JazzHRWrapper.JobListingWrapper>> returnedDataList)
    {
        try
        {
            List<Job_Listing__c> JobsToUpsertList = new List<Job_Listing__c>();
            Set<String> HiringLeadJazzIDSet = new Set<String>();
            
            system.debug('returnedDataList size: ' + returnedDataList.size());
            List<Account> defaultEmployerAccount = [SELECT Id, Employer_Code__c FROM Account WHERE Employer_Code__c = 'DEFAULT' LIMIT 1];  
            string defaultAccountId = '';
            If( defaultEmployerAccount == null || defaultEmployerAccount.size() ==0 )
            {
                Account newAccount = new Account();
                newAccount.Name = 'Default Employer Account';
                newAccount.Employer_Code__c = 'DEFAULT';
                insert newAccount;
                defaultAccountId = newAccount.Id;
            }
            else
                defaultAccountId = defaultEmployerAccount[0].Id;
            
            For(List<JazzHRWrapper.JobListingWrapper> currentListofJobs: returnedDataList)
            {
                system.debug('currentList.size: ' + currentListofJobs.size());

                For(JazzHRWrapper.JobListingWrapper currentJob: currentListofJobs)
                {
                    Job_Listing__c newJob = new Job_Listing__c();

                    //[Vinit] To respect Master Details Relationship of Account and Job Listing, setting default account at the time of job creation.
                    //Same will be updated through Trigger when Employer Code is entered by User.
                    /*
                    If( defaultEmployerAccount == null || defaultEmployerAccount.size() ==0 )
                    {
                        Account newAccount = new Account();
                        newAccount.Name = 'Default Employer Account';
                        newAccount.Employer_Code__c = 'DEFAULT';
                        insert newAccount;
                        newJob.Account__c = newAccount.Id;
                    }
                    else
                      */
                    newJob.Account__c = defaultAccountId;
                    
                    newJob.Employer_Code__c = 'DEFAULT';
                    
                    newJob.Board_Code__c = currentJob.board_code;
                    newJob.City__c = currentJob.city;
                    newJob.Country_ID__c = currentJob.country_id;
                    newJob.Department__c = currentJob.department;
                    newJob.Description__c = currentJob.description;
                    newJob.Internal_Code__c = currentJob.internal_code;
                    newJob.JazzHR_Job_ID__c = currentJob.id;
                    //Valueof method throws exception for invalid values. Added localised exception to handle it.
                    try{
                        newJob.Maximum_Salary__c = Decimal.valueOf(currentJob.maximum_salary);                       
                    }
                    catch(Exception ex){
                        system.debug('valid Maximum_Salary__c not recieived.. Skipped..');
                    }
                    
                    //Valueof method throws exception for invalid values. Added localised exception to handle it.
                    try{
                        newJob.Minimum_Salary__c = Decimal.valueOf(currentJob.minimum_salary);                        
                    }
                    catch(Exception ex){
                        system.debug('valid Minimum_Salary__c not recieived.. Skipped..');
                    }
                    
                    
                    newJob.Notes__c = currentJob.notes;
                    try{
                    newJob.Original_Open_Date__c = date.valueOf(currentJob.original_open_date);
                    }Catch(Exception ex){
                        
                    }
                    newJob.Send_To_Job_Boards__c = currentJob.send_to_job_boards;
                    newJob.State__c = currentJob.state;
                    newJob.Status__c = currentJob.status;
                    newJob.Team_ID__c = currentJob.team_id;
                    
                    newJob.Title__c = currentJob.title;
                    newJob.Type__c = currentJob.type;
                    newJob.Zip__c = currentJob.zip;
                     //questionnaire object is not yet in scope. Sp below mapping is not yet needed.
                    //newJob.Questionnaire__c = currentJob.questionnaire;                    
                    //We will fetch the hiring leads (jazzHR Users) later and associate them to Job Listing. Make sure to migrate users first.                    
                    newJob.Hiring_Lead_Jazz_Id__c = currentJob.hiring_lead;
                    HiringLeadJazzIDSet.add(currentJob.hiring_lead);
                    
                    JobsToUpsertList.add(newJob);
                }
            }
            
            //Associate Hiring Lead
            List<JazzHR_User__c> HiringLeadsList = [SELECT ID, JazzHr_User_ID__c FROM JazzHR_User__c WHERE JazzHr_User_ID__c =: HiringLeadJazzIDSet];
            //Create Map<Jazz Id, User Id in Salesforce>
            Map<String, Id> UserJazzIdSFDCIdMap = new Map<String, Id>();
            For(JazzHR_User__c currentuser: HiringLeadsList)
            {
                UserJazzIdSFDCIdMap.put(currentuser.JazzHr_User_ID__c, currentuser.Id);
            }
            //Associate correct Hiring Lead in the generated list of jobs now.
            For(Job_Listing__c currentjob: JobsToUpsertList)
            {
                currentjob.Hiring_Lead__c = UserJazzIdSFDCIdMap.get(currentjob.Hiring_Lead_Jazz_Id__c);
            }
            
            If(JobsToUpsertList != null && JobsToUpsertList.size()>0)
            {
                system.debug('JobsToUpsertList size: ' + JobsToUpsertList.size());
                upsert JobsToUpsertList JazzHR_Job_ID__c;
            }
            return true;
        }
        catch(Exception oEx)
        {
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRSFDCUtils.SyncJobs', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return false;
        }        
    }
    
    //sync list of applicants with SFDC from JazzHr
    public static boolean SyncApplicants(List<List<JazzHRWrapper.ApplicantWrapper>> returnedDataList)
    {
        try
        {
            List<Applicant__c> ApplicantToUpsertList = new List<Applicant__c>();
            system.debug('returnedDataList size: ' + returnedDataList.size());
            For(List<JazzHRWrapper.ApplicantWrapper> currentListofApplicants: returnedDataList)
            {
                For(JazzHRWrapper.ApplicantWrapper currentApplicant: currentListofApplicants)
                {
                    Applicant__c newApplicant = new Applicant__c();
                    newApplicant.JazzHR_Applicant_ID__c = currentApplicant.id;
                    newApplicant.First_Name__c = currentApplicant.first_name;
                    newApplicant.Last_Name__c = currentApplicant.last_name;
                    
                    try{
                        newApplicant.Apply_Date__c = date.valueOf(currentApplicant.apply_date);                        
                    }
                    catch(Exception oEx)
                    {
                        system.debug('invalid Apply_Date__c recived.. skipped..');
                    }
                    
                    newApplicant.Phone__c = currentApplicant.prospect_phone;
                    newApplicant.Job_Title__c = currentApplicant.job_title;
                    ApplicantToUpsertList.add(newApplicant);
                }
            }
            
            //Duplicat applicants are recived in bulk call for multiple application
            //Approach: Upsert any one of the Applicant only, and manage multiple Jobs through junction object Job Application later.
            Map<String, Applicant__c> ApplicantJazzIDRecordMap = new Map<String, Applicant__c>();
            
            For(Applicant__c currentApplicant: ApplicantToUpsertList)
            {
                ApplicantJazzIDRecordMap.put(currentApplicant.JazzHR_Applicant_ID__c, currentApplicant);
            }
            
            If(ApplicantToUpsertList != null && ApplicantToUpsertList.size()>0)
            {
                system.debug('ApplicantToUpsertList size: ' + ApplicantToUpsertList.size());
                Database.UpsertResult[] results = Database.upsert(ApplicantJazzIDRecordMap.values(), Applicant__c.Fields.JazzHR_Applicant_ID__c, false); 
                
                List<Log_Entry__c> entries = new List<Log_Entry__c>();
                
                for(Database.UpsertResult theResult : results) {
                    if(theResult.isSuccess())
                        continue; // next item
                    List<Database.Error> errors = theResult.getErrors();
                    for(Database.Error theError : Errors) {
                        Log_Entry__c newentry = new Log_Entry__c();
                        newEntry.Function__c = 'JazzHRSFDCUtils.SyncApplicants';
                        newEntry.Message__c = 'Status Code: ' + theError.getStatusCode() + ': Error: ' + theError.getMessage();
                        newentry.Type__c = 'Error';
                        entries.add(newentry);
                    }
                }
                
                insert entries;                
            }
            return true;
        }
        catch(Exception oEx)
        {
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRSFDCUtils.SyncApplicants', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return false;
        }        
    }
    
    
    public static boolean SyncJobApplications(List<List<JazzHRWrapper.JobApplicatonWrapper>> returnedDataList)
    {
        try
        {
            List<Job_Application__c> JobsApplicationsToUpsertList = new List<Job_Application__c>();
            Set<String> JobsJazzIDSet = new Set<String>();
            Set<String> ApplicantsJazzIDSet = new Set<String>();
            
            system.debug('returnedDataList size: ' + returnedDataList.size());
            
            For(List<JazzHRWrapper.JobApplicatonWrapper> currentListofJobAplicationss: returnedDataList)
            {
                system.debug('currentListofJobAplicationss.size: ' + currentListofJobAplicationss.size());
                
                For(JazzHRWrapper.JobApplicatonWrapper currentJobApplication: currentListofJobAplicationss)
                {
                   
                    Job_Application__c newJobApplication = new Job_Application__c();
                    newJobApplication.JazzHR_Job_Application_ID__c = currentJobApplication.id;
                    newJobApplication.Rating__c = currentJobApplication.rating;
                    newJobApplication.Workflow_Step_Id__c = currentJobApplication.workflow_step_id;
                    newJobapplication.Job_Jazz_ID__c = currentJobApplication.job_id;
                    newJobApplication.Applicant_Jazz_Id__c = currentJobApplication.applicant_id;
                    newJobApplication.Last_Synced_At__c = DateTime.now();
                    //Fetch Applicant and jobs seperately and associate later
                    JobsJazzIDSet.add(currentJobApplication.job_id);
                    ApplicantsJazzIDSet.add(currentJobApplication.applicant_id);
                    
                    JobsApplicationsToUpsertList.add(newJobApplication);
                }
            }
            
            //Fetch Related Jobs
            List<Job_Listing__c> JobsList = [SELECT ID, JazzHR_Job_ID__c FROM Job_Listing__c WHERE JazzHR_Job_ID__c =: JobsJazzIDSet];
            //Create Map<Jazz Id, User Id in Salesforce>
            Map<String, Id> JobJazzIdSFDCIdMap = new Map<String, Id>();
            For(Job_Listing__c currentjob: JobsList)
            {
                JobJazzIdSFDCIdMap.put(currentjob.JazzHR_Job_ID__c, currentjob.Id);
            }
            
            //Fetch Related Applicants
            List<Applicant__c> ApplicantsList = [SELECT ID, JazzHR_Applicant_ID__c FROM Applicant__c WHERE JazzHR_Applicant_ID__c =: ApplicantsJazzIDSet];
            
            //Create Map<Jazz Id, User Id in Salesforce>
            Map<String, Id> ApplicantJazzIdSFDCIdMap = new Map<String, Id>();
            For(Applicant__c currentapplicant: ApplicantsList)
            {
                ApplicantJazzIdSFDCIdMap.put(currentapplicant.JazzHR_Applicant_ID__c, currentapplicant.Id);
            }            
            
            //Associate correct Job and Applicant in the generated list of jobs now.
            For(Job_Application__c currentjobapplication: JobsApplicationsToUpsertList)
            {
                currentjobapplication.Job_Listing__c = JobJazzIdSFDCIdMap.get(currentjobapplication.Job_Jazz_ID__c);
                currentjobapplication.Applicant__c = ApplicantJazzIdSFDCIdMap.get(currentjobapplication.Applicant_Jazz_Id__c);
            }
            
            If(JobsApplicationsToUpsertList != null && JobsApplicationsToUpsertList.size()>0)
            {
                system.debug('JobsApplicationsToUpsertList size: ' + JobsApplicationsToUpsertList.size());
                
                //Database.UpsertResult[] results = Database.upsert(ApplicantToUpsertList, Applicant__c.Fields.JazzHR_Applicant_ID__c, false); 
                Database.UpsertResult[] results = Database.upsert(JobsApplicationsToUpsertList, false); 
                
                //upsert ApplicantToUpsertList JazzHR_Applicant_ID__c;
                List<Log_Entry__c> entries = new List<Log_Entry__c>();
                
                for(Database.UpsertResult theResult : results) {
                   
                    if(theResult.isSuccess())
                        continue; // next item
                    List<Database.Error> errors = theResult.getErrors();
                    for(Database.Error theError : Errors) {
                        Log_Entry__c newentry = new Log_Entry__c();
                        newEntry.Function__c = 'JazzHRSFDCUtils.SyncJobApplications';
                        newEntry.Message__c = 'Status Code: ' + theError.getStatusCode() + ': Error: ' + theError.getMessage();
                        newentry.Type__c = 'Error';
                        entries.add(newentry);
                    }
                }
                
                insert entries;
            }
            return true;
        }
        catch(Exception oEx)
        {
             Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRSFDCUtils.SyncJobApplications', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return false;           
        }
    }
    // method to sync job application basesd on job id for update workflow step id 
    // Date : 04/06/2019
        
    public static boolean SyncJobApplicationsByJobId(List<List<JazzHRWrapper.JobApplicatonWrapper>> returnedDataList)
    {
        try
        {
            List<Job_Application__c> JobsApplicationsToUpsertList = new List<Job_Application__c>();
            Set<String> JobsJazzIDSet = new Set<String>();
            Set<String> ApplicantsJazzIDSet = new Set<String>();
            system.debug('returnedDataList size: ' + returnedDataList.size());
            For(List<JazzHRWrapper.JobApplicatonWrapper> currentListofJobAplicationss: returnedDataList)
            {
                system.debug('currentListofJobAplicationss.size: ' + currentListofJobAplicationss.size());
                
                For(JazzHRWrapper.JobApplicatonWrapper currentJobApplication: currentListofJobAplicationss)
                {
                   
                    Job_Application__c newJobApplication = new Job_Application__c();
                    newJobApplication.JazzHR_Job_Application_ID__c = currentJobApplication.id;
                    newJobApplication.Rating__c = currentJobApplication.rating;
                    newJobApplication.Workflow_Step_Id__c = currentJobApplication.workflow_step_id;
                    newJobapplication.Job_Jazz_ID__c = currentJobApplication.job_id;
                    newJobApplication.Applicant_Jazz_Id__c = currentJobApplication.applicant_id;
                    newJobApplication.Last_Synced_At__c = DateTime.now();
                    //Fetch Applicant and jobs seperately and associate later
                    JobsJazzIDSet.add(currentJobApplication.job_id);
                    ApplicantsJazzIDSet.add(currentJobApplication.applicant_id);
                    JobsApplicationsToUpsertList.add(newJobApplication);
                }
            }
            
            //Fetch Related Jobs
            List<Job_Listing__c> JobsList = [SELECT ID, JazzHR_Job_ID__c FROM Job_Listing__c WHERE JazzHR_Job_ID__c =: JobsJazzIDSet];
            //Create Map<Jazz Id, User Id in Salesforce>
            Map<String, Id> JobJazzIdSFDCIdMap = new Map<String, Id>();
            For(Job_Listing__c currentjob: JobsList)
            {
                JobJazzIdSFDCIdMap.put(currentjob.JazzHR_Job_ID__c, currentjob.Id);
            }
            
            //Fetch Related Applicants
            List<Applicant__c> ApplicantsList = [SELECT ID, JazzHR_Applicant_ID__c FROM Applicant__c WHERE JazzHR_Applicant_ID__c =: ApplicantsJazzIDSet];
           
            //Create Map<Jazz Id, User Id in Salesforce>
            Map<String, Id> ApplicantJazzIdSFDCIdMap = new Map<String, Id>();
            For(Applicant__c currentapplicant: ApplicantsList)
            {
                ApplicantJazzIdSFDCIdMap.put(currentapplicant.JazzHR_Applicant_ID__c, currentapplicant.Id);
            }            
            
            //Associate correct Job and Applicant in the generated list of jobs now.
            For(Job_Application__c currentjobapplication: JobsApplicationsToUpsertList)
            {
                currentjobapplication.Job_Listing__c = JobJazzIdSFDCIdMap.get(currentjobapplication.Job_Jazz_ID__c);
                currentjobapplication.Applicant__c = ApplicantJazzIdSFDCIdMap.get(currentjobapplication.Applicant_Jazz_Id__c);
            }
            
            If(JobsApplicationsToUpsertList != null && JobsApplicationsToUpsertList.size()>0)
            {
                Database.UpsertResult[] results = Database.upsert(JobsApplicationsToUpsertList, Job_Application__c.Fields.JazzHR_Job_Application_ID__c, false); 
               // Database.UpsertResult[] results = Database.upsert(JobsApplicationsToUpsertList, false); 
                
                //upsert ApplicantToUpsertList JazzHR_Applicant_ID__c;
                List<Log_Entry__c> entries = new List<Log_Entry__c>();
                // Updated Code Snipet due to : We need Applicant, Job Application and Job Listing Id for reference in Log Entries
                for(Integer index = 0; index < results.size(); index++) {
                    if(results[index].isSuccess()) {
                        continue;
                    } 
                    else if(!results[index].isSuccess()) {
                        Database.Error errors =  results[index].getErrors().get(0);
                        Log_Entry__c newentry = new Log_Entry__c();
                        newEntry.Function__c = 'JazzHRSFDCUtils.SyncJobApplicationsByJobId';
                        string errorMessage = 'Status Code: ' + errors.getStatusCode() + '	\r\n' 
                            + ' Error: ' + errors.getMessage() + '\r\n' +'JazzHR Job Application ID:'+ JobsApplicationsToUpsertList[index].JazzHR_Job_Application_ID__c + '\r\n'
                            + ' JazzHR Applicant ID:'+JobsApplicationsToUpsertList[index].Applicant_Jazz_Id__c+'\r\n'
                            +'  JazzHR JobListing ID:'+JobsApplicationsToUpsertList[index].Job_Jazz_ID__c;
                        newEntry.Message__c = errorMessage;
                        newentry.Type__c = 'Error';
                        entries.add(newentry);
                    }
                }
                
                
                /* Orignal Code Snipet
                for(Database.UpsertResult theResult : results) {
                    system.debug('****Result id'+theResult.getId());
                    if(theResult.isSuccess()){
                        continue; // next item
                    }else{
                        List<Database.Error> errors = theResult.getErrors();
                        for(Database.Error theError : Errors) {
                            Log_Entry__c newentry = new Log_Entry__c();
                            newEntry.Function__c = 'JazzHRSFDCUtils.SyncJobApplications';
                            newEntry.Message__c = 'Status Code: ' + theError.getStatusCode() + ': Error: ' + theError.getMessage() + 'Applicant ID' +
                                theResult.getId();
                            newentry.Type__c = 'Error';
                            entries.add(newentry);
                        }
                    }

                } 
               */
                insert entries;
            }
            return true;
        }
        catch(Exception oEx)
        {
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRSFDCUtils.SyncJobApplications', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return false;           
        }
    }
    //sync a single applicant with SFDC from JazzHr
    public static SyncApplicantResponse SyncSingleApplicant(JazzHRWrapper.ApplicantWrapper currentApplicant, 
                                              JazzHRWrapper.ApplicantWithSingleApplicationWrapper currentApplicantWithSingleJob)
    {
        SyncApplicantResponse response = new SyncApplicantResponse();
        try
        {
            If(currentApplicant != null)
            {
                system.debug('---applicant record currentApplicant!=null----->'+currentApplicant);
                //Step 1: Update Applicant Details
                Applicant__c newApplicant = new Applicant__c();
                newApplicant.JazzHR_Applicant_ID__c = currentApplicant.id;
                newApplicant.First_Name__c = currentApplicant.first_name;
                newApplicant.Last_Name__c = currentApplicant.last_name;
                newApplicant.Email__c = currentApplicant.email;
                
                List<Lead> exisitngLead = [select email, Id From Lead where email =: currentApplicant.email Order By CreatedDate DESC];
                If(exisitngLead != null && exisitngLead.size()>0)
                {
                    newApplicant.Enquiry__c = exisitngLead[0].Id;
                    newApplicant.Type__c = 'TalentPool';
                }
                else
                    newApplicant.Type__c = 'JazzHR';
                
                newApplicant.Address__c = currentApplicant.address;
                newApplicant.Location__c = currentApplicant.location;
                
                newApplicant.Applicant_Locality__c = GetLocality(currentApplicant.location);
                
                newApplicant.Phone__c = currentApplicant.phone;
                newApplicant.Linkedin_Url__c = currentApplicant.linkedin_url;
                newApplicant.Eeo_Gender__c = currentApplicant.eeo_gender;
                newApplicant.Eeo_Race__c = currentApplicant.eeo_race;
                newApplicant.Eeo_Disability__c = currentApplicant.eeo_disability;
                newApplicant.Website__c = currentApplicant.website;
                newApplicant.desired_salary__c = currentApplicant.desired_salary;
                newApplicant.Desired_Start_Date__c = currentApplicant.desired_start_date;
                
                //[Vinit] Desired Salary and Start Date data type coonverted to string
                /*
                //Valueof method throws exception for invalid values. Added localised exception to handle it.
                try
                {
                    //newApplicant.desired_salary__c = decimal.valueOf(currentApplicant.desired_salary);
                }
                catch(Exception ex)
                {
                    system.debug('Valid Desired Salary not recived. Skipped..');
                }
                
                //Valueof method throws exception for invalid values. Added localised exception to handle it.
                try
                {
                    //newApplicant.Desired_Start_Date__c = date.valueOf(currentApplicant.desired_start_date);
                }
                catch(Exception ex)
                {
                    system.debug('Valid Desired_Start_Date__c Desired Date not recived.. Skipped');
                }
                */
                
                newApplicant.Referrer__c = currentApplicant.referrer;
                newApplicant.Languages__c = currentApplicant.languages;
                newApplicant.Wmyu__c = currentApplicant.wmyu;
                newApplicant.Has_Driver_License__c = currentApplicant.has_driver_license;
                newApplicant.Willing_To_Relocate__c = currentApplicant.willing_to_relocate;
                newApplicant.Citizenship_Status__c = currentApplicant.citizenship_status;
                newApplicant.Education_Level__c = currentApplicant.education_level;
                newApplicant.Has_Cdl__c = currentApplicant.has_cdl;
                newApplicant.Over_18__c = currentApplicant.over_18;
                newApplicant.Can_Work_Weekends__c = currentApplicant.can_work_weekends;
                newApplicant.Can_Work_Evenings__c = currentApplicant.can_work_evenings;
                newApplicant.Can_Work_Overtime__c = currentApplicant.can_work_overtime;
                newApplicant.Has_Felony__c = currentApplicant.has_felony;
                newApplicant.Felony_Explanation__c = currentApplicant.felony_explanation;
                newApplicant.Twitter_Username__c = currentApplicant.twitter_username;
                newApplicant.College_Gpa__c = currentApplicant.college_gpa;
                newApplicant.College__c = currentApplicant.college;
                newApplicant.References__c = currentApplicant.references;
                newApplicant.Notes__c = currentApplicant.notes;          
                
                
                try{
                    newApplicant.Apply_Date__c = date.valueOf(currentApplicant.apply_date);               
                }
                catch(Exception ex){
                    system.debug('valid Apply_Date__c not recieived.. Skipped..');
                }
                
                newApplicant.Comments_Count__c = currentApplicant.comments_count;
                newApplicant.Source__c = currentApplicant.source;
                newApplicant.Recruiter_Id__c = currentApplicant.recruiter_id;
                newApplicant.Eeoc_Veteran__c = currentApplicant.eeoc_veteran;
                newApplicant.Eeoc_Disability__c = currentApplicant.eeoc_disability;
                newApplicant.Eeoc_Disability_Signature__c = currentApplicant.eeoc_disability_signature;
                
                try{
                    newApplicant.Eeoc_Disability_Date__c = date.valueOf(currentApplicant.eeoc_disability_date);            
                }
                catch(Exception ex){
                    system.debug('valid Eeoc_Disability_Date__c not recieived.. Skipped..');
                }
                
                newApplicant.Resume_Link__c = currentApplicant.resume_link;
                
                system.debug('Applicant ready to upsert: ' + newApplicant);
                
                //[Vinit] Add Sync Datetime stamp
                newApplicant.Is_Synced__c = true;
                newApplicant.Last_Sync_Date_Time__c = DateTime.now();
                
                upsert newApplicant JazzHR_Applicant_ID__c;
                
                //Step 2: Update Application Details
                List<Job_Application__c> JobApplicationsToUpdate = new List<Job_Application__c>();
                
                //Get List of Current Job Applications on Applicant     
                List<Job_Application__c> ExistingJobApplicationsList = [SELECT Id, Job_Jazz_ID__c,JazzHR_Job_Application_ID__c, Hiring_Lead_Rating__c, Average_Rating__c,
                                                                        Workflow_Step_ID__c, Applicant_Progress__c FROM Job_Application__c
                                                                        WHERE Applicant__r.JazzHR_Applicant_ID__c =: currentApplicant.id ];
                
                //Create a map with Jazz Job Id as Key and Application record as value
                Map<string, Job_application__c> JazzJobIdAndApplicationMap = new Map<string, Job_application__c>();
                
                For(Job_Application__c currentApp: ExistingJobApplicationsList)
                {
                    JazzJobIdAndApplicationMap.put(currentApp.Job_Jazz_ID__c, currentApp);
                }
                system.debug('ExistingJobApplicationsList Size: ' + ExistingJobApplicationsList.size());
                system.debug('JazzJobIdAndApplicationMap Size: ' + JazzJobIdAndApplicationMap.size());
                
                //TODO: Handle new job applications. If job application does not already, insert those and add to same map
                Set<string> JobIdsForNewJobApplicationsSet = new Set<string>();
                
                boolean isJobList = false;
                
                For(JazzHRWrapper.Job currentJobApplication: currentApplicant.jobs)
                {
                    Job_Application__c job = JazzJobIdAndApplicationMap.get(currentJobApplication.job_id);
                    if(job == null)
                    {
                        JobIdsForNewJobApplicationsSet.add(currentJobApplication.job_id);
                    }
                }
                
                List<Job_Listing__c> JobsList = [SELECT Id, JazzHR_Job_ID__c FROM Job_Listing__c WHERE JazzHR_Job_ID__c=:JobIdsForNewJobApplicationsSet];
                
                For(Job_Listing__c newJob : JobsList)
                {
                    Job_Application__c newApplication = new Job_Application__c();
                    newApplication.Applicant__c = newApplicant.id;
                    newApplication.Job_Listing__c = newJob.id;
                    newApplication.Job_Jazz_ID__c = newJob.JazzHR_Job_ID__c;
                    newApplication.Last_Synced_At__c = DateTime.now();
                    JazzJobIdAndApplicationMap.put(newJob.JazzHR_Job_ID__c, newApplication);
                }
                
                For(JazzHRWrapper.Job currentJobApplication: currentApplicant.jobs)
                {
                    Job_Application__c job = JazzJobIdAndApplicationMap.get(currentJobApplication.job_id);
                    if(job == null)
                    {
                        job = new Job_Application__c();
                    }
                    
                    job.Job_Jazz_ID__c = currentJobApplication.job_id;                
                    
                    //Valueof method throws exception for invalid values. Added localised exception to handle it.
                    try{
                        job.Hiring_Lead_Rating__c = Decimal.valueOf(currentJobApplication.hiring_lead_rating);
                    }
                    catch(Exception ex){
                        system.debug('valid Hiring_Lead_Rating__c not recieived.. Skipped..');
                    }                    
                    
                    //Valueof method throws exception for invalid values. Added localised exception to handle it.
                    try{
                        job.Average_Rating__c = Decimal.valueOf(currentJobApplication.average_rating);                    
                    }
                    catch(Exception ex){
                        system.debug('valid Average_Rating__c not recieived.. Skipped..');
                    }
                    
                    job.Workflow_Step_ID__c = currentJobApplication.workflow_step_id;
                    job.Applicant_Progress__c = currentJobApplication.applicant_progress;
                    // this line is not in code i have added it = sachin 13/6/
                    
                    JobApplicationsToUpdate.add(job);
                }
                
                
                If(JobApplicationsToUpdate != null && JobApplicationsToUpdate.size()>0)
                {
                    system.debug('JobApplicationsToUpdate size: ' + JobApplicationsToUpdate.size());
                    upsert JobApplicationsToUpdate;
                }
                
                //Step 3: Update Questionnarie Details.
                List<Questionnaire__c> QuestionnariesToUpdate = new List<Questionnaire__c>();
                
                //Get List of Current Job Applications on Applicant     
                List<Questionnaire__c> ExistingQuestionsList = [SELECT Id, Question__c, Answer__c FROM Questionnaire__c
                                                                WHERE Applicant__r.JazzHR_Applicant_ID__c =: currentApplicant.id ];
                
                /*
//Create a map with Jazz Job Id as Key and Application record as value
Map<string, Questionnaire__c> ExistingQuestionsMap = new Map<string, Questionnaire__c>();

For(Questionnaire__c currentquestion: ExistingQuestionsList)
{
ExistingQuestionsMap.put(currentquestion.Question__c, currentquestion);
}
system.debug('ExistingQuestionsList Size: ' + ExistingQuestionsList.size());
system.debug('ExistingQuestionsMap Size: ' + ExistingQuestionsMap.size());
*/
                //As key is not received, we needed to delete all and then reinsert all questiosn for given applicant.
                
                //Delete ExistingQuestionsList;
                
                For(JazzHRWrapper.QuestionnaireWrapper currentQues: currentApplicant.questionnaire)
                {
                    Questionnaire__c question = new Questionnaire__c();
                    
                    question.Question__c = currentQues.question;                
                    question.Answer__c = currentQues.answer;
                    question.Applicant__c = newApplicant.Id;
                    
                    QuestionnariesToUpdate.add(question);
                }
                
                
                If(QuestionnariesToUpdate != null && QuestionnariesToUpdate.size()>0)
                {
                    system.debug('QuestionnariesToUpdate size: ' + QuestionnariesToUpdate.size());
                    upsert QuestionnariesToUpdate;
                }     
                
                response.isSyncCompleted = true;
                response.SyncedApplicant = newApplicant;
                return response;
            }
            Else If(currentApplicantWithSingleJob != null)
            {
                system.debug('---applicant record----->'+currentApplicantWithSingleJob);
                //Step 1: Update Applicant Details
                Applicant__c newApplicant = new Applicant__c();
                newApplicant.JazzHR_Applicant_ID__c = currentApplicantWithSingleJob.id;
                newApplicant.First_Name__c = currentApplicantWithSingleJob.first_name;
                newApplicant.Last_Name__c = currentApplicantWithSingleJob.last_name;
                newApplicant.Email__c = currentApplicantWithSingleJob.email;
                
                List<Lead> exisitngLead = [select email, Id From Lead where email =: currentApplicantWithSingleJob.email Order By CreatedDate DESC];
                If(exisitngLead != null && exisitngLead.size()>0)
                {
                    newApplicant.Enquiry__c = exisitngLead[0].Id;
                    newApplicant.Type__c = 'TalentPool';
                }
                else
                    newApplicant.Type__c = 'JazzHR';
                
                newApplicant.Address__c = currentApplicantWithSingleJob.address;
                newApplicant.Location__c = currentApplicantWithSingleJob.location;
                
                newApplicant.Applicant_Locality__c = GetLocality(currentApplicantWithSingleJob.location);
                
                newApplicant.Phone__c = currentApplicantWithSingleJob.phone;
                newApplicant.Linkedin_Url__c = currentApplicantWithSingleJob.linkedin_url;
                newApplicant.Eeo_Gender__c = currentApplicantWithSingleJob.eeo_gender;
                newApplicant.Eeo_Race__c = currentApplicantWithSingleJob.eeo_race;
                newApplicant.Eeo_Disability__c = currentApplicantWithSingleJob.eeo_disability;
                newApplicant.Website__c = currentApplicantWithSingleJob.website;
                newApplicant.desired_salary__c = currentApplicantWithSingleJob.desired_salary;
                newApplicant.Desired_Start_Date__c = currentApplicantWithSingleJob.desired_start_date;
                
                //Desired Start date and Salary data type converted to string 
                /*
                //Valueof method throws exception for invalid values. Added localised exception to handle it.
                try
                {
                    //newApplicant.desired_salary__c = decimal.valueOf(currentApplicantWithSingleJob.desired_salary);
                }
                catch(Exception ex)
                {
                    system.debug('Valid Desired Salary not recived. Skipped..');
                }
                
                //Valueof method throws exception for invalid values. Added localised exception to handle it.
                try
                {
                    //newApplicant.Desired_Start_Date__c = date.valueOf(currentApplicantWithSingleJob.desired_start_date);
                }
                catch(Exception ex)
                {
                    system.debug('Valid Desired_Start_Date__c Desired Date not recived.. Skipped');
                }
                */
                
                newApplicant.Referrer__c = currentApplicantWithSingleJob.referrer;
                newApplicant.Languages__c = currentApplicantWithSingleJob.languages;
                newApplicant.Wmyu__c = currentApplicantWithSingleJob.wmyu;
                newApplicant.Has_Driver_License__c = currentApplicantWithSingleJob.has_driver_license;
                newApplicant.Willing_To_Relocate__c = currentApplicantWithSingleJob.willing_to_relocate;
                newApplicant.Citizenship_Status__c = currentApplicantWithSingleJob.citizenship_status;
                newApplicant.Education_Level__c = currentApplicantWithSingleJob.education_level;
                newApplicant.Has_Cdl__c = currentApplicantWithSingleJob.has_cdl;
                newApplicant.Over_18__c = currentApplicantWithSingleJob.over_18;
                newApplicant.Can_Work_Weekends__c = currentApplicantWithSingleJob.can_work_weekends;
                newApplicant.Can_Work_Evenings__c = currentApplicantWithSingleJob.can_work_evenings;
                newApplicant.Can_Work_Overtime__c = currentApplicantWithSingleJob.can_work_overtime;
                newApplicant.Has_Felony__c = currentApplicantWithSingleJob.has_felony;
                newApplicant.Felony_Explanation__c = currentApplicantWithSingleJob.felony_explanation;
                newApplicant.Twitter_Username__c = currentApplicantWithSingleJob.twitter_username;
                newApplicant.College_Gpa__c = currentApplicantWithSingleJob.college_gpa;
                newApplicant.College__c = currentApplicantWithSingleJob.college;
                newApplicant.References__c = currentApplicantWithSingleJob.references;
                newApplicant.Notes__c = currentApplicantWithSingleJob.notes;          
                
                
                try{
                    newApplicant.Apply_Date__c = date.valueOf(currentApplicantWithSingleJob.apply_date);               
                }
                catch(Exception ex){
                    system.debug('valid Apply_Date__c not recieived.. Skipped..');
                }
                
                newApplicant.Comments_Count__c = currentApplicantWithSingleJob.comments_count;
                newApplicant.Source__c = currentApplicantWithSingleJob.source;
                newApplicant.Recruiter_Id__c = currentApplicantWithSingleJob.recruiter_id;
                newApplicant.Eeoc_Veteran__c = currentApplicantWithSingleJob.eeoc_veteran;
                newApplicant.Eeoc_Disability__c = currentApplicantWithSingleJob.eeoc_disability;
                newApplicant.Eeoc_Disability_Signature__c = currentApplicantWithSingleJob.eeoc_disability_signature;
                
                try{
                    newApplicant.Eeoc_Disability_Date__c = date.valueOf(currentApplicantWithSingleJob.eeoc_disability_date);            
                }
                catch(Exception ex){
                    system.debug('valid Eeoc_Disability_Date__c not recieived.. Skipped..');
                }
                
                newApplicant.Resume_Link__c = currentApplicantWithSingleJob.resume_link;
                
                system.debug('Applicant ready to upsert: ' + newApplicant);
				//Update sync date time
                newApplicant.Is_Synced__c = true;
                newApplicant.Last_Sync_Date_Time__c = DateTime.now();
                
                upsert newApplicant JazzHR_Applicant_ID__c;
                
                //Step 2: Update Application Details
                List<Job_Application__c> JobApplicationsToUpdate = new List<Job_Application__c>();
                
                //Get List of Current Job Applications on Applicant     
                List<Job_Application__c> ExistingJobApplicationsList = [SELECT Id, Job_Jazz_ID__c, Hiring_Lead_Rating__c, Average_Rating__c,
                                                                        Workflow_Step_ID__c, Applicant_Progress__c FROM Job_Application__c
                                                                        WHERE Applicant__r.JazzHR_Applicant_ID__c =: currentApplicantWithSingleJob.id ];
                
                
                //Create a map with Jazz Job Id as Key and Application record as value
                Map<string, Job_application__c> JazzJobIdAndApplicationMap = new Map<string, Job_application__c>();
                
                For(Job_Application__c currentApp: ExistingJobApplicationsList)
                {
                    JazzJobIdAndApplicationMap.put(currentApp.Job_Jazz_ID__c, currentApp);
                }
                
                system.debug('ExistingJobApplicationsList Size: ' + ExistingJobApplicationsList.size());
                system.debug('JazzJobIdAndApplicationMap Size: ' + JazzJobIdAndApplicationMap.size());
                
                //TODO: Handle new job applications. If job application does not already, insert those and add to same map
                Set<string> JobIdsForNewJobApplicationsSet = new Set<string>();
                
                Job_Application__c job = JazzJobIdAndApplicationMap.get(currentApplicantWithSingleJob.jobs.job_id);
                if(job == null)
                {
                    JobIdsForNewJobApplicationsSet.add(currentApplicantWithSingleJob.jobs.job_id);
                }
                
                
                List<Job_Listing__c> JobsList = [SELECT Id, JazzHR_Job_ID__c FROM Job_Listing__c WHERE JazzHR_Job_ID__c=:JobIdsForNewJobApplicationsSet];
                
                For(Job_Listing__c newJob : JobsList)
                {
                    Job_Application__c newApplication = new Job_Application__c();
                    newApplication.Applicant__c = newApplicant.id;
                    newApplication.Job_Listing__c = newJob.id;
                    newApplication.Job_Jazz_ID__c = newJob.JazzHR_Job_ID__c;
                    newApplication.Last_Synced_At__c = DateTime.now();
                    JazzJobIdAndApplicationMap.put(newJob.JazzHR_Job_ID__c, newApplication);
                }
                
                Job_Application__c jobApp = JazzJobIdAndApplicationMap.get(currentApplicantWithSingleJob.jobs.job_id);
                if(jobApp == null)
                {
                    jobApp = new Job_Application__c();
                }
                
                jobApp.Job_Jazz_ID__c = currentApplicantWithSingleJob.jobs.job_id;                
                
                //Valueof method throws exception for invalid values. Added localised exception to handle it.
                try{
                    jobApp.Hiring_Lead_Rating__c = Decimal.valueOf(currentApplicantWithSingleJob.jobs.hiring_lead_rating);
                }
                catch(Exception ex){
                    system.debug('valid Hiring_Lead_Rating__c not recieived.. Skipped..');
                }                    
                
                //Valueof method throws exception for invalid values. Added localised exception to handle it.
                try{
                    jobApp.Average_Rating__c = Decimal.valueOf(currentApplicantWithSingleJob.jobs.average_rating);                    
                }
                catch(Exception ex){
                    system.debug('valid Average_Rating__c not recieived.. Skipped..');
                }
                
                jobApp.Workflow_Step_ID__c = currentApplicantWithSingleJob.jobs.workflow_step_id;
                jobApp.Applicant_Progress__c = currentApplicantWithSingleJob.jobs.applicant_progress;
                JobApplicationsToUpdate.add(jobApp);
                
                
                
                If(JobApplicationsToUpdate != null && JobApplicationsToUpdate.size()>0)
                {
                    system.debug('JobApplicationsToUpdate size: ' + JobApplicationsToUpdate.size());
                    upsert JobApplicationsToUpdate;
                }
                
                //Step 3: Update Questionnarie Details.
                List<Questionnaire__c> QuestionnariesToUpdate = new List<Questionnaire__c>();
                
                //Get List of Current Job Applications on Applicant     
                List<Questionnaire__c> ExistingQuestionsList = [SELECT Id, Question__c, Answer__c FROM Questionnaire__c
                                                                WHERE Applicant__r.JazzHR_Applicant_ID__c =: currentApplicantWithSingleJob.id ];
                
                
                //Create a map with Jazz Job Id as Key and Application record as value
                /*Map<string, Questionnaire__c> ExistingQuestionsMap = new Map<string, Questionnaire__c>();

                For(Questionnaire__c currentquestion: ExistingQuestionsList)
                {
                ExistingQuestionsMap.put(currentquestion.Question__c, currentquestion);
                }
                system.debug('ExistingQuestionsList Size: ' + ExistingQuestionsList.size());
                system.debug('ExistingQuestionsMap Size: ' + ExistingQuestionsMap.size());
                */
                //As key is not received, we needed to delete all and then reinsert all questiosn for given applicant.
                
                Delete ExistingQuestionsList;
                
                For(JazzHRWrapper.QuestionnaireWrapper currentQues: currentApplicantWithSingleJob.questionnaire)
                {
                    Questionnaire__c question = new Questionnaire__c();
                    
                    question.Question__c = currentQues.question;                
                    question.Answer__c = currentQues.answer;
                    question.Applicant__c = newApplicant.Id;
                    
                    QuestionnariesToUpdate.add(question);
                }
                
                
                If(QuestionnariesToUpdate != null && QuestionnariesToUpdate.size()>0)
                {
                    system.debug('QuestionnariesToUpdate size: ' + QuestionnariesToUpdate.size());
                    upsert QuestionnariesToUpdate;
                }            
                
                response.isSyncCompleted = true;
                response.SyncedApplicant = newApplicant;
                return response;
            }
            else
            {
                                
                response.isSyncCompleted = false;
                response.SyncedApplicant = null;
                return response;
            }
               // return false;
        }
        catch(Exception oEx)
        {
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRSFDCUtils.SyncSingleApplicant', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            
            response.isSyncCompleted = false;
            response.SyncedApplicant = null;
            return response;
        }        
    }    
    
    public static string GetLocality(string location)
    {
        string locality = 'Other';
        
        try{
            if(location.contains('SE11 4') || location.contains('SE11 5') || location.contains('SE11 6'))
            {
                locality = 'Local – Lambeth';
            }
            else if(location.contains('SW11') ||   location.contains('SW4 9')||   location.contains('SW8 3')||   
                    location.contains('SW8 4')||   location.contains('SW8 5')||   location.contains('SW12 2')||  
                    location.contains('SW12 8')||   location.contains('SW12 9')||   location.contains('SW15 1')|| 
                    location.contains('SW15 2')||   location.contains('SW15 3')||   location.contains('SW15 4')|| 
                    location.contains('SW15 5')||   location.contains('SW15 6')||   location.contains('SW15 9')|| 
                    location.contains('SW16 1')||   location.contains('SW16 4')||   location.contains('SW16 6')|| 
                    location.contains('SW17 1')||   location.contains('SW17 7')||   location.contains('SW17 8')||  
                    location.contains('SW17 9')||   location.contains('SW18 1')||   location.contains('SW18 2')|| 
                    location.contains('SW18 3')||   location.contains('SW18 4')||   location.contains('SW18 5')|| 
                    location.contains('SW19 5')||   location.contains('SW19 6')||     location.contains('SW1P 1')|| 
                    location.contains('SW1P 2')||     location.contains('SW1P 3')||     location.contains('SW1P 4')|| 
                    location.contains('SW1P 9')||   location.contains('SW1V 1')||   location.contains('SW1V 2')||  
                    location.contains('SW1V 3')||   location.contains('SW1V 4'))
            {
                locality = 'Local - Wandsworth';
            }
        }
        catch(Exception oEx)
        {
            system.debug('Error in getting Locality from Location: ' + Location);
        }
        return locality;
    }
    
    public class SyncApplicantResponse{
        @AuraEnabled
        public boolean isSyncCompleted {get;set;}
        @AuraEnabled
        public Applicant__c SyncedApplicant{get;set;}       
    }
}