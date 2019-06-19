/**
 * Developer		: Sachin/Vinit
 * Date				: 29 Jan 2019
 * Purpose			: Class for Test Class Data Handler
**/
public class JazzHRTestDataHandler {
  public Applicant__c createApplicant(string jazzHRApplicantId, string applicantType){
        Applicant__c appObj = new Applicant__c();
        appObj.JazzHR_Applicant_ID__c = jazzHRApplicantId;
      appObj.Email__c= 'test@test.com';
      appObj.First_Name__c = 'testFirstName';
      appObj.Last_Name__c = 'testLastName';
      
      appObj.Address__c='testaddress';
      appObj.Apply_Date__c = date.today();
      appObj.Can_Work_Evenings__c ='yes';
      appObj.Can_Work_Overtime__c = 'no';
      appObj.Can_Work_Weekends__c = 'yes';
      appObj.Citizenship_Status__c = 'test';
      appObj.College__c = 'test';
      appObj.Type__c = applicantType;
        return appObj;
    }
    public Lead createLead(string email){
        Lead l = new Lead();
        l.Email = email;
        l.LastName = 'test';
        return l;
    }
   
    
}