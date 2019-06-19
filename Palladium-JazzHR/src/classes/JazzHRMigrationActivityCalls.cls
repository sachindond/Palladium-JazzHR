/* 
* Developer 	: Sachin/Vinit
* Date			: 28 Jan 2019
* Purpose		: This class will be utilised just once for the one time data migration activity. 
* It fetches all data and not filtered so use this class only when ONE time migration activity is needed 
*/
public class JazzHRMigrationActivityCalls {
    
	// This is for one time migration of users from Jazz HR to Salesforce.
    public static boolean MigrateAllUsers()
    {        
       // try
       // {
            //Get complete list of users from JazzHR using paginated callouts.
            List<List<JazzHRWrapper.UserWrapper>> returnedDataList = JazzHRCallouts.GetAllUsers();  
            system.debug('---MigrateAllUsers------'+returnedDataList);
            boolean status = JazzHRSFDCUtils.SyncUsers(returnedDataList);
            return status;
       // }
        //catch(Exception oEx)
      //  {
           // Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRMigrationActivityCalls.MigrateAllUsers', '');    
          //  system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
           // return false;
       // }
    }
    
    //Migrates all Jobs to Salesforce.
    //IMPORTANT: Make sure to migrate users first. Jobs needs to be associated to correct hiring lead.
    //User Logic yet to be added.
    
    public static boolean MigrateAllJobs()
    {        
        try
        {
            //Get complete list of jobs from JazzHR using paginated callouts.
            List<List<JazzHRWrapper.JobListingWrapper>> returnedDataList = JazzHRCallouts.GetAllJobs();
            boolean status = JazzHRSFDCUtils.SyncJobs(returnedDataList);
			return status;
        }
        catch(Exception oEx)
        {
          //  Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRMigrationActivityCalls.MigrateAllJobs', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return false;
        }
    }
    
    //Migrate All Applicants    
    public static boolean MigrateAllApplicants()
    {        
        try
        {
            //Get complete list of applicant from JazzHR using paginated callouts.
            List<List<JazzHRWrapper.ApplicantWrapper>> returnedDataList = JazzHRCallouts.GetAllApplicants();  
			boolean status = JazzHRSFDCUtils.SyncApplicants(returnedDataList);
            return status;
        }
        catch(Exception oEx)
        {
           // Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRMigrationActivityCalls.MigrateAllApplicants', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return false;
        }
    }

	//Migrate All Job Applications. Make sure to get all jobs and applicant before using this call.
    public static boolean MigrateAllJobApplications()
    {
        try
        {
            //Get complete list of job applications from JazzHR using paginated callouts.
            List<List<JazzHRWrapper.JobApplicatonWrapper>> returnedDataList = JazzHRCallouts.GetAllJobApplications();  
			boolean status = JazzHRSFDCUtils.SyncJobApplications(returnedDataList);
            return status;
        }
        catch(Exception oEx)
        {
           // Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRMigrationActivityCalls.MigrateAllJobApplications', '');    
            system.debug('Error: ' + 'Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            return false;
        }        
    }
}