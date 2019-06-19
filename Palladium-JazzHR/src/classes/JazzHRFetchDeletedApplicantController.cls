/** Date : 11/06/2019
 *  Purpose : This class fetch applicant and its corresponding job listing and job application from jazzHR
 *  We pass JazzHR Applicant ID - Which is to be deleted in Merge Process and if users want to fetch it again from JazzHR
**/
public class JazzHRFetchDeletedApplicantController
{
    @AuraEnabled
    public static JazzHRSFDCUtils.SyncApplicantResponse fetchDeletedApplicant(string jazzHRApplicantId){
        system.debug('*** jazzHRApplicantId ***'+jazzHRApplicantId);
        JazzHRSFDCUtils.SyncApplicantResponse singleApplicantResponseObj= new JazzHRSFDCUtils.SyncApplicantResponse();
        // blank check
        if(string.isNotBlank(jazzHRApplicantId) && string.isNotEmpty(jazzHRApplicantId)){
            JazzHRWrapper.ApplicantWithSingleApplicationWrapper applicantWithSingleApp;
            JazzHRWrapper.ApplicantWrapper applicantRecord = JazzHRCallouts.GetSingleApplicant(jazzHRApplicantId);
            if(applicantRecord == null)
                applicantWithSingleApp = JazzHRCallouts.ApplicantWithSingleApplicationWrapper(jazzHRApplicantId);
            singleApplicantResponseObj = JazzHRSFDCUtils.SyncSingleApplicant(applicantRecord, applicantWithSingleApp);
            If(Test.isRunningTest())
                Logger.Log('Information','','JazzHRFetchDeletedApplicantController.fetchDeletedApplicant', null);    
            
            return singleApplicantResponseObj;          
        }
        return singleApplicantResponseObj;
    }       
}