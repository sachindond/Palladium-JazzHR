public class SyncApplicantFromJazzHRClassic {
    public static Id Id {get;set;}
    public static Applicant__c applicantRecord{get;set;}
    public static string JazzHRApplicantId{get;set;}
    public SyncApplicantFromJazzHRClassic(ApexPages.StandardController controller) {
        applicantRecord = (Applicant__c) controller.getRecord();
        system.debug('**** applicant record ****'+applicantRecord);
        Id = applicantRecord.id;
        JazzHRApplicantId = applicantRecord.JazzHR_Applicant_ID__c;
    }
    public static PageReference syncApplicantDetails() {
       
        boolean bRet;
        System.debug('Applicant Id: ' + Id);
        System.debug('***** JAzz ID'+JazzHRApplicantId);
        if(JazzHRApplicantId!=null){
            JazzHRWrapper.ApplicantWithSingleApplicationWrapper applicantWithSingleApp;
            JazzHRWrapper.ApplicantWrapper applicantRecord = JazzHRCallouts.GetSingleApplicant(JazzHRApplicantId);
            if(applicantRecord == null)
                applicantWithSingleApp = JazzHRCallouts.ApplicantWithSingleApplicationWrapper(JazzHRApplicantId);
           // bRet = JazzHRSFDCUtils.SyncSingleApplicant(applicantRecord, applicantWithSingleApp);
            JazzHRSFDCUtils.SyncApplicantResponse response = JazzHRSFDCUtils.SyncSingleApplicant(applicantRecord, applicantWithSingleApp);
            bret = response.isSyncCompleted;
        }
        if(bRet == true){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Applicant details synced successfully from JazzHR. Click back to go to record page.');
            ApexPages.addMessage(myMsg);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error in sync from JazzHR. Try again or contact administrator. Click back to go to record page.');
            ApexPages.addMessage(myMsg);
        }
        //build your code logic here
        /*
        PageReference pageRef = new PageReference('/'+Id);
        pageRef.setRedirect(false);
        
        return pageRef; //Returns to the Applicant  page
*/
        return null;
    }
}