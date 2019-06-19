/**
* Developer 	: Sachin/Vinit
* Date			: 27 Jan 2019
* Purpose		: Methods to fetch all required data from JazzHR using REST HTTP Callouts
**/
public class JazzHRCallouts {
    
    private static string strApiKey;
    private static string strBaseUrl;
    
    // method to check access token is present in custom setting
    public static boolean Initialize(){
        
        try{
            JazzHR_Setting__c jazzHRSettingObj = JazzHR_Setting__c.getInstance('JazzHR');
            if(jazzHRSettingObj !=null){
                strApiKey =  jazzHRSettingObj.Api_Key__c;
                strBaseUrl = jazzHRSettingObj.Base_Url__c;
                system.debug('strApiKey: ' + strApiKey);
                system.debug('strBaseUrl: ' + strBaseUrl);
                if(strApiKey != null && strBaseUrl != null){
                    return true;
                }else{
                    //Logger.Log('Error','Api Key or Base Url is missing in Custom Setting','JazzHRCallouts.Initialize', 'Blank');
                    return false;
                }
            }else{
                //Logger.Log('Error','Api Key or Base Url is missing in Custom Setting','JazzHRCallouts.Initialize', 'Blank');
                return false;
            }
            
        }catch(Exception oEx){
            //Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.Initilize', 'request body if any');    
            return false;
        }
    }
    
    
    // Method to get all Jazz HR Users
    public static List<List<JazzHRWrapper.UserWrapper>> GetAllUsers(){
        try{
            //JazzHR API returns data in chunk of 100 and can be access via page number until results scanned.
            //We will iterate via these pages and store the results in list of UserWrapper
            
            Integer pagenumber = 1;
            
            List<List<JazzHRWrapper.UserWrapper>> ReturnedDataList = new List<List<JazzHRWrapper.UserWrapper>>();
            List<JazzHRWrapper.UserWrapper> ReturnedData = null;
            do
            {
                transient String strResponse;
                string strEndPoint = 'users/page/' + pagenumber;
                strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
                system.debug('-----------str response of users'+strResponse);
                ReturnedData = (List<JazzHRWrapper.UserWrapper>)System.JSON.deserialize(strResponse, List<JazzHRWrapper.UserWrapper>.class);
                If(ReturnedData != null && ReturnedData.size() > 0)
                    ReturnedDataList.add(ReturnedData);
                pagenumber+=1;
                if(Test.isRunningTest())
                    break;
            }
            while(ReturnedData != null && ReturnedData.size() > 0);
            
            system.debug('----user list'+ReturnedDataList);
            return ReturnedDataList;
        }catch(Exception oEx){
            system.debug( 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.GetAllUsers', 'request body if any');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return null;
        }
    }
    
    // Method to get all JOb list
    // Given method is to be used only one time for data migration. When all jobs are in Salesforce, we will only fetch daily jobs from batch
    // from a seperate method.
    public static List<List<JazzHRWrapper.JobListingWrapper>> GetAllJobs(){
        try{
            //JazzHR API returns data in chunk of 100 and can be access via page number until results scanned.
            //We will iterate via these pages and store the results in list of JobListingWrapper
            
            Integer pagenumber = 1;
            
            List<List<JazzHRWrapper.JobListingWrapper>> ReturnedDataList = new List<List<JazzHRWrapper.JobListingWrapper>>();
            List<JazzHRWrapper.JobListingWrapper> ReturnedData = null;
            do
            {
                transient String strResponse;
                string strEndPoint = 'jobs/page/' + pagenumber;
                strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
                system.debug('----job listing response---->'+strResponse);
                ReturnedData = (List<JazzHRWrapper.JobListingWrapper>)System.JSON.deserialize(strResponse, List<JazzHRWrapper.JobListingWrapper>.class);
                If(ReturnedData != null && ReturnedData.size() > 0)
                    ReturnedDataList.add(ReturnedData);
                pagenumber+=1;
                if(Test.isRunningTest())
                    break;
            }
            while(ReturnedData != null && ReturnedData.size() > 0 );
            
            return ReturnedDataList;
            
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.GetAllJobs', 'request body if any');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
        }
        return null;        
    }
    
    //Get Jobs by date
    public static List<List<JazzHRWrapper.JobListingWrapper>> GetJobsByDate(string fromopendate){
        try{
            //JazzHR API returns data in chunk of 100 and can be access via page number until results scanned.
            //We will iterate via these pages and store the results in list of JobListingWrapper
            
            Integer pagenumber = 1;
            
            List<List<JazzHRWrapper.JobListingWrapper>> ReturnedDataList = new List<List<JazzHRWrapper.JobListingWrapper>>();
            List<JazzHRWrapper.JobListingWrapper> ReturnedData = new List<JazzHRWrapper.JobListingWrapper>();
            do
            {
                transient String strResponse;
                string strEndPoint = 'jobs/from_open_date/' + fromopendate + '/page/' + pagenumber;
                strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
                system.debug('----jobs by date response---->'+strResponse);
                try
                {
                    //JOSN response might content single record and multiple records. we need to support the response fetching accordingly.
                    ReturnedData = (List<JazzHRWrapper.JobListingWrapper>)System.JSON.deserialize(strResponse, List<JazzHRWrapper.JobListingWrapper>.class);                    
                }
                catch(Exception ex)
                {
                    //possiblity that single record recieved
                    system.debug('possibly single Job record received and exception thrown. Try single parser now');
                    JazzHRWrapper.JobListingWrapper currentJob = (JazzHRWrapper.JobListingWrapper)System.JSON.deserialize(strResponse, 
                                                                                                                          JazzHRWrapper.JobListingWrapper.class);  
                    
                    ReturnedData.add(currentJob);
                }
                
                If(ReturnedData != null && ReturnedData.size() > 0)
                    ReturnedDataList.add(ReturnedData);
                pagenumber+=1;
                if(Test.isRunningTest())
                    break;
            }
            while(ReturnedData != null && ReturnedData.size() > 0);
            
            return ReturnedDataList;
            
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.GetJobsByDate', 'request body if any');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
        }
        return null;        
    }
    
    // Method to get AllApplicant from jazzhr. Should be called only one time.
    public static List<List<JazzHRWrapper.ApplicantWrapper>> GetAllApplicants(){
        
        try
        {
            //JazzHR API returns data in chunk of 100 and can be access via page number until results scanned.
            //We will iterate via these pages and store the results in list of ApplicantWrapper
            
            Integer pagenumber = 1;
            
            List<List<JazzHRWrapper.ApplicantWrapper>> ReturnedDataList = new List<List<JazzHRWrapper.ApplicantWrapper>>();
            List<JazzHRWrapper.ApplicantWrapper> ReturnedData = null;
            do
            {
                transient String strResponse;
                string strEndPoint = 'applicants/page/' + pagenumber;
                strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
                system.debug('----applicant response---->'+strResponse);
                ReturnedData = (List<JazzHRWrapper.ApplicantWrapper>)System.JSON.deserialize(strResponse, List<JazzHRWrapper.ApplicantWrapper>.class);
                If(ReturnedData != null && ReturnedData.size() > 0)
                    ReturnedDataList.add(ReturnedData);
                pagenumber+=1;
                if(Test.isRunningTest())
                    break;
            }
            while(ReturnedData != null && ReturnedData.size() > 0 );
            
            return ReturnedDataList;    
        }
        catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.GetAllApplicants', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return null;
        }
    }
    
    //method to get applicants applied on given date
    public static List<List<JazzHRWrapper.ApplicantWrapper>> GetApplicantsByDate(string applydate){
        
        try
        {
            //JazzHR API returns data in chunk of 100 and can be access via page number until results scanned.
            //We will iterate via these pages and store the results in list of ApplicantWrapper
            
            Integer pagenumber = 1;
            
            List<List<JazzHRWrapper.ApplicantWrapper>> ReturnedDataList = new List<List<JazzHRWrapper.ApplicantWrapper>>();
            List<JazzHRWrapper.ApplicantWrapper> ReturnedData = new List<JazzHRWrapper.ApplicantWrapper>();
            do
            {
                transient String strResponse;
                string strEndPoint = 'applicants/apply_date/'+ applydate + '/page/' + pagenumber;
                strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
                system.debug('----applicant by date response---->'+strResponse);
                //ReturnedData = (List<JazzHRWrapper.ApplicantWrapper>)System.JSON.deserialize(strResponse, List<JazzHRWrapper.ApplicantWrapper>.class);
                
                try
                {
                    //JOSN response might content single record and multiple records. we need to support the response fetching accordingly.
                    ReturnedData = (List<JazzHRWrapper.ApplicantWrapper>)System.JSON.deserialize(strResponse, List<JazzHRWrapper.ApplicantWrapper>.class);                    
                }
                catch(Exception ex)
                {
                    //possiblity that single record recieved
                    system.debug('possibly single Job record received and exception thrown. Try single parser now');
                    JazzHRWrapper.ApplicantWrapper currentApplicant = (JazzHRWrapper.ApplicantWrapper)System.JSON.deserialize(strResponse, 
                                                                                                                              JazzHRWrapper.ApplicantWrapper.class);  
                    ReturnedData.add(currentApplicant);
                }
                
                
                If(ReturnedData != null && ReturnedData.size() > 0)
                    ReturnedDataList.add(ReturnedData);
                pagenumber+=1;
                if(Test.isRunningTest())
                    break;
            }
            while(ReturnedData != null && ReturnedData.size() > 0);
            
            return ReturnedDataList;    
        }
        catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.GetApplicantsByDate', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return null;
        }
    }    
    
    // Method to get single applicant details
    public static JazzHRWrapper.ApplicantWrapper GetSingleApplicant(string applicantId){
        try{
            //JazzHR API returns data for single Applicant based on Prospect Id.
            //We will iterate via these pages and store the results in list of ApplicantWrapper
            System.debug('----applicantId--->'+applicantId);
            JazzHRWrapper.ApplicantWrapper ReturnedData = new JazzHRWrapper.ApplicantWrapper();
            
            String strResponse;
            string strEndPoint = 'applicants/' + applicantId;
            strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
            system.debug('-----GetSingleApplicant responses'+(strResponse));
            ReturnedData = (JazzHRWrapper.ApplicantWrapper)System.JSON.deserialize(strResponse, JazzHRWrapper.ApplicantWrapper.class);
            system.debug('----------GetSingleApplicant ReturnedData->'+ReturnedData);
            return ReturnedData;             
        }catch(Exception oEx){
            //Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.GetSingleApplicant', 'request body if any'); 
            system.debug('JazzHRCallouts.GetSingleApplicant' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            
            return null;
        }
    }    
    
    // Method to get single applicant details
    public static JazzHRWrapper.ApplicantWithSingleApplicationWrapper ApplicantWithSingleApplicationWrapper(string applicantId){
        try{
            //JazzHR API returns data for single Applicant based on Prospect Id.
            //We will iterate via these pages and store the results in list of ApplicantWithSingleApplicationWrapper
            System.debug('----applicantId--->'+applicantId);
            JazzHRWrapper.ApplicantWithSingleApplicationWrapper ReturnedData = new JazzHRWrapper.ApplicantWithSingleApplicationWrapper();
            
            String strResponse;
            string strEndPoint = 'applicants/' + applicantId;
            strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
            system.debug('-----ApplicantWithSingleApplicationWrapper responses'+(strResponse));
            ReturnedData = (JazzHRWrapper.ApplicantWithSingleApplicationWrapper)System.JSON.deserialize(strResponse, JazzHRWrapper.ApplicantWithSingleApplicationWrapper.class);
            system.debug('----------GetSingleApplicant ReturnedData->'+ReturnedData);
            return ReturnedData;             
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.ApplicantWithSingleApplicationWrapper', '');    
            return null;
        }
    }        
    // Method to get all jobApplicants
    public static List<List<JazzHRWrapper.JobApplicatonWrapper>> GetAllJobApplications(){
        try{
            
            //JazzHR API returns data in chunk of 100 and can be access via page number until results scanned.
            //We will iterate via these pages and store the results in list of JobApplicatonWrapper
            
            Integer pagenumber = 1;
            
            List<List<JazzHRWrapper.JobApplicatonWrapper>> ReturnedDataList = new List<List<JazzHRWrapper.JobApplicatonWrapper>>();
            List<JazzHRWrapper.JobApplicatonWrapper> ReturnedData = null;
            do
            {
                transient String strResponse;
                string strEndPoint = 'applicants2jobs/page/' + pagenumber;
                strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
                system.debug('-----GetAllJobApplications responses'+(strResponse));
                ReturnedData = (List<JazzHRWrapper.JobApplicatonWrapper>)System.JSON.deserialize(strResponse, List<JazzHRWrapper.JobApplicatonWrapper>.class);
                If(ReturnedData != null && ReturnedData.size() > 0)
                    ReturnedDataList.add(ReturnedData);
                pagenumber+=1;
                if(Test.isRunningTest())
                    break;
            }
            while(ReturnedData != null && ReturnedData.size() > 0 );
            
            return ReturnedDataList;
            
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.GetAllJobApplications', 'request body if any');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return null;
        }
    }
    
    
    // Date : 06/03/2019
    // Method to get Job Application based on Job Listing Id
    public static List<List<JazzHRWrapper.JobApplicatonWrapper>> getJobApplicationByJobId(string jobId){
       
        try{
            
            Integer pagenumber = 1;
            List<List<JazzHRWrapper.JobApplicatonWrapper>> ReturnedDataList = new List<List<JazzHRWrapper.JobApplicatonWrapper>>();
            List<JazzHRWrapper.JobApplicatonWrapper> ReturnedData = new   List<JazzHRWrapper.JobApplicatonWrapper> ();
            do
            {
                transient String strResponse;
                string strEndPoint = 'applicants2jobs/job_id/'+jobId+'/page/'+pagenumber;
                strResponse = JazzHRCallouts.ExecuteJazzHRHTTPCallout(strEndPoint, 'GET', null);
                system.debug('-----GetAllJobApplications responses'+(strResponse));
                try{
                    ReturnedData = (List<JazzHRWrapper.JobApplicatonWrapper>)System.JSON.deserialize(strResponse, List<JazzHRWrapper.JobApplicatonWrapper>.class);
                    system.debug('****RETURN DATA IN TRY***'+ReturnedData.size());
                }catch(Exception Ex){
                    // this logic to handle single job application record
                    JazzHRWrapper.JobApplicatonWrapper singleJobApplication = (JazzHRWrapper.JobApplicatonWrapper)System.JSON.deserialize(strResponse, 
                                                                                                                                          JazzHRWrapper.JobApplicatonWrapper.class);  
                    system.debug('***single job applicaton '+singleJobApplication);
                    if(singleJobApplication!=null)
                        ReturnedData.add(singleJobApplication);
                }
                If(ReturnedData != null && ReturnedData.size() > 0)
                    ReturnedDataList.add(ReturnedData);
                pagenumber+=1;
                if(Test.isRunningTest())
                    break;
            }
            while(ReturnedData != null && ReturnedData.size() > 0);
            system.debug('*****Return Data List Size****'+ReturnedDataList.size());
            system.debug('*****Return Data List****'+ReturnedDataList);
            return ReturnedDataList;
            
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.getJobApplicationByJobId', 'request body if any');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return null;
        }
        
    }    
    
    //generic method to use for HTTP Callouts. Just create correct endpoint append string that will be added to Base URL
    // And Request Body.
    private static String ExecuteJazzHRHTTPCallout(string strEndpoint, string httpmethod, string requestBody)
    {
        try
        {
            If(Initialize())
            {
                Http http = new Http();
                HTTPRequest request = new HTTPRequest();
                string finalEndPoint = strBaseURL + '/' + strEndpoint + '?apikey=' + strApiKey;
                system.debug('finalEndPoint Created: ' + finalEndPoint);
                request.setEndpoint(finalEndPoint);
                request.setMethod(httpmethod);
                
                //request.setHeader('Accept', 'application/json');
                if(requestBody != null)
                    request.setBody(requestBody);
                transient HTTPResponse response = http.send(request);
                String strResponse = String.valueOf(response.getBodyAsBlob().toString());
                
                system.debug('----callout response --->'+strResponse);
                return strResponse;
            }
            else
                Logger.Log('Error','Initialization From custom Settings Failed..', 'JazzHRCallouts.ExecuteGCLHTTPCalloutInit', 'request body if any');    
            
        }
        catch(Exception oEx)
        {
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRCallouts.ExecuteGCLHTTPCalloutInit', 'request body if any');    
        }
        return null;   
    }    
}