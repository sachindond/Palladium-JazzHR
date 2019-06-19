/**
 * Developer	: Vinit/Sachin
 * Date			: 29 Jan 2019
 * Purpose		: Test class to cover batch classes
**/
@isTest
public class TestBatchSyncUsersFromJazzHR {
    static testMethod void testUsersBatch(){
        JazzHR_Setting__c jazzHRSettingObj = new JazzHR_Setting__c();
       	jazzHRSettingObj.Base_Url__c='https://test.com';
        jazzHRSettingObj.Name='JazzHR';
        jazzHRSettingObj.Api_Key__c ='testkey';
        jazzHRSettingObj.Batch_Run_Date__c = '';
        insert jazzHRSettingObj;
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c applicantObj = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert applicantObj;
        Lead leadObj = handlerObj.createLead('test@test.com');
        insert leadObj;
       
        test.startTest();
        HttpMockGenerator jazzHRUserHttpMockResp = new HttpMockGenerator(200,'Complete','[{"id":"usr_20160603155236_XWXBGMNKTQ3YJF6","type":"Deleted","last_name":"Dawson","first_name":"Michelle","email":"deleted_user@jazz.co","date_created":"2016-06-03"},{"id":"usr_20160603155236_XWXBGMNKTQ3YJF6M","type":"Deleted","last_name":"Dawson","first_name":"Michelle","email":"deleted_user@jazz.co","date_created":"2016-06-03"}]');
        system.debug('---->'+jazzHRUserHttpMockResp);
         
        Test.setMock(HttpCalloutMock.class, jazzHRUserHttpMockResp);
        BatchSyncUsersFromJazzHR userBatchObj = new BatchSyncUsersFromJazzHR();
        database.executeBatch(userBatchObj);
     	//Test.stopTest();
       
        HttpMockGenerator jazzHRJobsHttpMockResp = new HttpMockGenerator(200,'Complete','[{"id":"job_20190117125841_TDOEVWMW9CUJVOL4","team_id":"","title":"Lounge Host"}]');
        system.debug('-->jazzHRJobsHttpMockResp--->'+jazzHRJobsHttpMockResp);
         //test.startTest();
        Test.setMock(HttpCalloutMock.class, jazzHRJobsHttpMockResp);
        BatchSyncJobsFromJazzHR jobBatchObj = new BatchSyncJobsFromJazzHR();
        //BatchSyncApplicantsFromJazzHR applicantBatchObj = new BatchSyncApplicantsFromJazzHR();
        database.executeBatch(jobBatchObj);
       // Test.stopTest();
       
       HttpMockGenerator jazzHRApplicantMockResp = new HttpMockGenerator(200,'Complete','[{"id":"prospect_20190125164225_AEOQV5MUGH5DTOJK","first_name":"Daniela","last_name":"Martiniuc","email":"danutsu1012@gmail.com","address":"07 Oakway  London","location":"07 Oakway  London London London SW20 9JE","phone":"7958294432","linkedin_url":"","eeo_gender":null,"eeo_race":null,"eeo_disability":null,"website":"","desired_salary":"","desired_start_date":"","referrer":"","languages":"","wmyu":"","has_driver_license":"No answer","willing_to_relocate":"No answer","citizenship_status":"No answer","education_level":"No answer","has_cdl":"No answer","over_18":"No answer","can_work_weekends":"No answer","can_work_evenings":"No answer","can_work_overtime":"No answer","has_felony":"No answer","felony_explanation":"","twitter_username":"","college_gpa":"","college":"","references":"","notes":"","apply_date":"2019-01-25","comments_count":"0","source":"Indeed","recruiter_id":"","eeoc_veteran":null,"eeoc_disability":null,"eeoc_disability_signature":null,"eeoc_disability_date":null,"jobs":[{"job_id":"job_20181002135332_FQ8JZGISBQ1RXGLK","hiring_lead_rating":"0","average_rating":"0.0","workflow_step_id":null,"job_title":"","applicant_progress":"New"}],"comments":false,"feedback":[],"rating":[],"resume_link":"","activities":{"id":"activity_20190125164225_MZUXUPGL9ITJ6XKG","activity":"","date":"2019-01-25","time":"16:42:25"},"messages":[{"comm_id":"comm_20190125164225_VWAT2ZKNWHILBQOV","comm_subject":"Cover Letter","comm_text":".","comm_author_email":"danutsu1012@gmail.com","comm_to":"","comm_cc":"","comm_bcc":"","comm_datetime_sent":"2019-01-25 16:42:25"},{"comm_id":"comm_20190125164225_EVYADPJWJEI3TTZJ","comm_subject":"Daniela, received your resume","comm_text":"]","comm_author_email":"naparcedo@bpsdc.co.uk","comm_to":"danutsu1012@gmail.com","comm_cc":"","comm_bcc":"","comm_datetime_sent":"2019-01-25 16:42:25"}],"questionnaire":[{"answer":"testanswer","question":"testquestion"}],"evaluation":[],"categories":[]}]');
        system.debug('-->jazzHRJobsHttpMockResp--->'+jazzHRApplicantMockResp);
        // test.startTest();
        test.setMock(HttpCalloutMock.class,jazzHRApplicantMockResp);
        BatchSyncApplicantsFromJazzHR applicantBatchObj = new BatchSyncApplicantsFromJazzHR();
        database.executeBatch(applicantBatchObj);
        Test.stopTest();
        
        
        

    }
    
    static testMethod void testGetSingleApplicant(){
        JazzHR_Setting__c jazzHRSettingObj = new JazzHR_Setting__c();
        jazzHRSettingObj.Base_Url__c='https://test.com';
        jazzHRSettingObj.Name='JazzHR';
        jazzHRSettingObj.Api_Key__c ='testkey';
        jazzHRSettingObj.Batch_Run_Date__c = '';
        insert jazzHRSettingObj;
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c applicantObj = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert applicantObj;
        Lead l = handlerObj.createLead('test@test.com');
        insert l;
        HttpMockGenerator jazzHRApplicantMockResp = new HttpMockGenerator(200,'Complete','{"id":"prospect_20190125164225_AEOQV5MUGH5DTOJK","first_name":"Daniela","last_name":"Martiniuc","email":"test@test.com","address":"07 Oakway  London","location":"07 Oakway  London London London SW20 9JE","phone":"7958294432","linkedin_url":"","eeo_gender":null,"eeo_race":null,"eeo_disability":null,"website":"","desired_salary":"","desired_start_date":"","referrer":"","languages":"","wmyu":"","has_driver_license":"No answer","willing_to_relocate":"No answer","citizenship_status":"No answer","education_level":"No answer","has_cdl":"No answer","over_18":"No answer","can_work_weekends":"No answer","can_work_evenings":"No answer","can_work_overtime":"No answer","has_felony":"No answer","felony_explanation":"","twitter_username":"","college_gpa":"","college":"","references":"","notes":"","apply_date":"2019-01-25","comments_count":"0","source":"Indeed","recruiter_id":"","eeoc_veteran":null,"eeoc_disability":null,"eeoc_disability_signature":null,"eeoc_disability_date":null,"jobs":[{"job_id":"job_20181002135332_FQ8JZGISBQ1RXGLK","hiring_lead_rating":"0","average_rating":"0.0","workflow_step_id":null,"job_title":"","applicant_progress":"New"}],"comments":false,"feedback":[],"rating":[],"resume_link":"","activities":{"id":"activity_20190125164225_MZUXUPGL9ITJ6XKG","activity":"","date":"2019-01-25","time":"16:42:25"},"messages":[{"comm_id":"comm_20190125164225_VWAT2ZKNWHILBQOV","comm_subject":"Cover Letter","comm_text":".","comm_author_email":"danutsu1012@gmail.com","comm_to":"","comm_cc":"","comm_bcc":"","comm_datetime_sent":"2019-01-25 16:42:25"},{"comm_id":"comm_20190125164225_EVYADPJWJEI3TTZJ","comm_subject":"Daniela, received your resume","comm_text":"]","comm_author_email":"naparcedo@bpsdc.co.uk","comm_to":"danutsu1012@gmail.com","comm_cc":"","comm_bcc":"","comm_datetime_sent":"2019-01-25 16:42:25"}],"questionnaire":[{"answer":"testanswer","question":"testquestion"}],"evaluation":[],"categories":[]}');
        system.debug('-->jazzHRJobsHttpMockResp--->'+jazzHRApplicantMockResp);
        Test.startTest();
        test.setMock(HttpCalloutMock.class,jazzHRApplicantMockResp);
        JazzHRWrapper.ApplicantWrapper applicantRecord = JazzHRCallouts.GetSingleApplicant(applicantObj.JazzHR_Applicant_ID__c);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@applicantRecord'+applicantRecord);
        JazzHRSFDCUtils.SyncSingleApplicant(applicantRecord,null);
        
       Test.stopTest();
    }
    static testMethod void testApplicantWithSingleJob(){
         JazzHR_Setting__c jazzHRSettingObj = new JazzHR_Setting__c();
        jazzHRSettingObj.Base_Url__c='https://test.com';
        jazzHRSettingObj.Name='JazzHR';
        jazzHRSettingObj.Api_Key__c ='testkey';
        jazzHRSettingObj.Batch_Run_Date__c = '';
        insert jazzHRSettingObj;
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c applicantObj = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert applicantObj;
        Lead l = handlerObj.createLead('test@test.com');
        insert l;
        Test.startTest();
         HttpMockGenerator jazzHRApplicantMockResp1 = new HttpMockGenerator(200,'Complete','{"id":"prospect_20190125164225_AEOQV5MUGH5DTOJK","first_name":"Daniela","last_name":"Martiniuc","email":"test@test.com","address":"07 Oakway  London","location":"07 Oakway  London London London SW20 9JE","phone":"7958294432","linkedin_url":"","eeo_gender":null,"eeo_race":null,"eeo_disability":null,"website":"","desired_salary":"","desired_start_date":"","referrer":"","languages":"","wmyu":"","has_driver_license":"No answer","willing_to_relocate":"No answer","citizenship_status":"No answer","education_level":"No answer","has_cdl":"No answer","over_18":"No answer","can_work_weekends":"No answer","can_work_evenings":"No answer","can_work_overtime":"No answer","has_felony":"No answer","felony_explanation":"","twitter_username":"","college_gpa":"","college":"","references":"","notes":"","apply_date":"2019-01-25","comments_count":"0","source":"Indeed","recruiter_id":"","eeoc_veteran":null,"eeoc_disability":null,"eeoc_disability_signature":null,"eeoc_disability_date":null,"jobs":{"job_id":"job_20181002135332_FQ8JZGISBQ1RXGLK","hiring_lead_rating":"0","average_rating":"0.0","workflow_step_id":null,"job_title":"","applicant_progress":"New"},"comments":false,"feedback":[],"rating":[],"resume_link":"","activities":{"id":"activity_20190125164225_MZUXUPGL9ITJ6XKG","activity":"","date":"2019-01-25","time":"16:42:25"},"messages":[{"comm_id":"comm_20190125164225_VWAT2ZKNWHILBQOV","comm_subject":"Cover Letter","comm_text":".","comm_author_email":"danutsu1012@gmail.com","comm_to":"","comm_cc":"","comm_bcc":"","comm_datetime_sent":"2019-01-25 16:42:25"},{"comm_id":"comm_20190125164225_EVYADPJWJEI3TTZJ","comm_subject":"Daniela, received your resume","comm_text":"]","comm_author_email":"naparcedo@bpsdc.co.uk","comm_to":"danutsu1012@gmail.com","comm_cc":"","comm_bcc":"","comm_datetime_sent":"2019-01-25 16:42:25"}],"questionnaire":[{"answer":"testanswer","question":"testquestion"}],"evaluation":[],"categories":[]}');
        system.debug('-->jazzHRJobsHttpMockResp--->'+jazzHRApplicantMockResp1);
        
        test.setMock(HttpCalloutMock.class,jazzHRApplicantMockResp1);
        JazzHRWrapper.ApplicantWithSingleApplicationWrapper applicantRecord1 = JazzHRCallouts.ApplicantWithSingleApplicationWrapper(applicantObj.JazzHR_Applicant_ID__c);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@applicantRecord'+applicantRecord1);
        
        JazzHRSFDCUtils.SyncSingleApplicant(null,applicantRecord1);
        Test.stopTest();
    }
    static testMethod void testGetUsers(){
        JazzHR_Setting__c jazzHRSettingObj = new JazzHR_Setting__c();
        jazzHRSettingObj.Base_Url__c='https://test.com';
        jazzHRSettingObj.Name='JazzHR';
        jazzHRSettingObj.Api_Key__c ='testkey';
        jazzHRSettingObj.Batch_Run_Date__c = '';
        insert jazzHRSettingObj;
        HttpMockGenerator jazzHRUserHttpMockResp = new HttpMockGenerator(200,'Complete','[{"id":"usr_20160603155236_XWXBGMNKTQ3YJF6","type":"Deleted","last_name":"Dawson","first_name":"Michelle","email":"deleted_user@jazz.co","date_created":"2016-06-03"},{"id":"usr_20160603155236_XWXBGMNKTQ3YJF6M","type":"Deleted","last_name":"Dawson","first_name":"Michelle","email":"deleted_user@jazz.co","date_created":"2016-06-03"}]');
        system.debug('---->'+jazzHRUserHttpMockResp);
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, jazzHRUserHttpMockResp);
        JazzHRMigrationActivityCalls.MigrateAllUsers();
        Test.stopTest();
        
    }
    static testMethod void testGetAllJobs(){
        JazzHR_Setting__c jazzHRSettingObj = new JazzHR_Setting__c();
        jazzHRSettingObj.Base_Url__c='https://test.com';
        jazzHRSettingObj.Name='JazzHR';
        jazzHRSettingObj.Api_Key__c ='testkey';
        jazzHRSettingObj.Batch_Run_Date__c = '';
        insert jazzHRSettingObj;
        HttpMockGenerator jazzHRJobsHttpMockResp = new HttpMockGenerator(200,'Complete','[{"id":"job_20190117125841_TDOEVWMW9CUJVOL4","team_id":"","title":"Lounge Host"}]');
        system.debug('-->jazzHRJobsHttpMockResp--->'+jazzHRJobsHttpMockResp);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, jazzHRJobsHttpMockResp);
        JazzHRMigrationActivityCalls.MigrateAllJobs();
        Test.stopTest();
    }
    static testMethod void testGetAllApplicant(){
        JazzHR_Setting__c jazzHRSettingObj = new JazzHR_Setting__c();
        jazzHRSettingObj.Base_Url__c='https://test.com';
        jazzHRSettingObj.Name='JazzHR';
        jazzHRSettingObj.Api_Key__c ='testkey';
        jazzHRSettingObj.Batch_Run_Date__c = '';
        insert jazzHRSettingObj;
        HttpMockGenerator jazzHRApplicantMockResp = new HttpMockGenerator(200,'Complete','[{"id":"prospect_20190125164225_AEOQV5MUGH5DTOJK","first_name":"Daniela","last_name":"Martiniuc","email":"danutsu1012@gmail.com","address":"07 Oakway  London","location":"07 Oakway  London London London SW20 9JE","phone":"7958294432","linkedin_url":"","eeo_gender":null,"eeo_race":null,"eeo_disability":null,"website":"","desired_salary":"","desired_start_date":"","referrer":"","languages":"","wmyu":"","has_driver_license":"No answer","willing_to_relocate":"No answer","citizenship_status":"No answer","education_level":"No answer","has_cdl":"No answer","over_18":"No answer","can_work_weekends":"No answer","can_work_evenings":"No answer","can_work_overtime":"No answer","has_felony":"No answer","felony_explanation":"","twitter_username":"","college_gpa":"","college":"","references":"","notes":"","apply_date":"2019-01-25","comments_count":"0","source":"Indeed","recruiter_id":"","eeoc_veteran":null,"eeoc_disability":null,"eeoc_disability_signature":null,"eeoc_disability_date":null,"jobs":[{"job_id":"job_20181002135332_FQ8JZGISBQ1RXGLK","hiring_lead_rating":"0","average_rating":"0.0","workflow_step_id":null,"job_title":"","applicant_progress":"New"}],"comments":false,"feedback":[],"rating":[],"resume_link":"","activities":{"id":"activity_20190125164225_MZUXUPGL9ITJ6XKG","activity":"","date":"2019-01-25","time":"16:42:25"},"messages":[{"comm_id":"comm_20190125164225_VWAT2ZKNWHILBQOV","comm_subject":"Cover Letter","comm_text":".","comm_author_email":"danutsu1012@gmail.com","comm_to":"","comm_cc":"","comm_bcc":"","comm_datetime_sent":"2019-01-25 16:42:25"},{"comm_id":"comm_20190125164225_EVYADPJWJEI3TTZJ","comm_subject":"Daniela, received your resume","comm_text":"]","comm_author_email":"naparcedo@bpsdc.co.uk","comm_to":"danutsu1012@gmail.com","comm_cc":"","comm_bcc":"","comm_datetime_sent":"2019-01-25 16:42:25"}],"questionnaire":[{"answer":"testanswer","question":"testquestion"}],"evaluation":[],"categories":[]}]');
        system.debug('-->jazzHRJobsHttpMockResp--->'+jazzHRApplicantMockResp);
        Test.startTest();
        test.setMock(HttpCalloutMock.class,jazzHRApplicantMockResp);
        JazzHRMigrationActivityCalls.MigrateAllApplicants();
        Test.stopTest();
    }
    static testMethod void testGetAllJobApplication(){
        JazzHR_Setting__c jazzHRSettingObj = new JazzHR_Setting__c();
        jazzHRSettingObj.Base_Url__c='https://test.com';
        jazzHRSettingObj.Name='JazzHR';
        jazzHRSettingObj.Api_Key__c ='testkey';
        jazzHRSettingObj.Batch_Run_Date__c = '';
        insert jazzHRSettingObj;
        // ned to add 
        HttpMockGenerator jazzHRAJobApplicationMockResp = new HttpMockGenerator(200,'Complete','[{"id":"projob_20190202230943_5SSBQD4GAYBZLNUU","applicant_id":"prospect_20190202230943_VCFXWFFNJM2GP1H4","job_id":"job_20190116154112_3TPHTX3RTQG9SIDJ","rating":"0","workflow_step_id":"1","date":"0000-00-00"},{"id":"projob_20190202224801_2T1VYAIZF5RGPAHD","applicant_id":"prospect_20190202224801_NLNXVK6JAHC0OMAT","job_id":"job_20181002135332_FQ8JZGISBQ1RXGLK","rating":"0","workflow_step_id":"1","date":"0000-00-00"}]');
        system.debug('-->jazzHRJobsHttpMockResp--->'+jazzHRAJobApplicationMockResp);
         Test.startTest();
        test.setMock(HttpCalloutMock.class,jazzHRAJobApplicationMockResp);
        JazzHRMigrationActivityCalls.MigrateAllJobApplications();
        Test.stopTest();
    }
    
}