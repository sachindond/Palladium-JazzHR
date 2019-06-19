/**	Developer 	: Sachin/Vinit
 * 	Date 		: 17 March 2019
 *  Purpose     : test class for getapplicantDetails Controller
 **/
@isTest
public class TestGetApplicationDetailController {
    static testMethod void testgetSingleApplicantRecord(){
        // create applicant records
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c insertFirstApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert insertFirstApplicant;
        GetApplicantDetailController.getSingleApplicantRecord(insertFirstApplicant.Id);
    }
    static testMethod void testSendMail(){
        JazzHRTestDataHandler handlerObj = new JazzHRTestDataHandler();
        Applicant__c insertFirstApplicant = handlerObj.createApplicant('prospect_20190125164225_AEOQV5MUGH5DTOJK','JazzHR');
        insert insertFirstApplicant;
        JazzHR_Setting__c jazzHRSettingObj = new JazzHR_Setting__c();
        jazzHRSettingObj.Name = 'JazzHR';
        jazzHRSettingObj.Enable_Send_Email__c = true;
        insert jazzHRSettingObj;
        GetApplicantDetailController.sendEmail(insertFirstApplicant.Id);
    }
    
}