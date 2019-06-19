public class JazzHRApplicantJourneyController {
    @AuraEnabled
    public static List <sObject > fetchApplicant(String searchKeyWord) {
        system.debug('*********search Key'+searchKeyWord);
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject  > returnList = new List < sObject  > ();
        List < sObject  > lstOfApplicant = [select id,Name,First_Name__c,Last_Name__c,Address__c,Location__c,Postal_Code__c,Source__c,Phone__c,Email__c,Last_Sync_Date_Time__c,Is_Synced__c from Applicant__c 
                                                where First_Name__c LIKE: searchKey OR  Last_Name__c LIKE:searchKey OR Phone__c LIKE:searchKey OR Email__c LIKE:searchKey LIMIT 10];
        
        for (sObject  acc: lstOfApplicant) {
            returnList.add(acc);
        }
        return returnList;
    }
    
    public static List<Schema.FieldSetMember> getFields(string objectname) {
        if(objectname == 'Job_Applications__r')
            return SObjectType.Job_Application__c.FieldSets.Job_Applicant_Field_Set_For_Lex_Cmp.getFields();
        if(objectname == 'Questionnaire__r')
            return SObjectType.Questionnaire__c.FieldSets.Questionnaire_Field_Set_For_Lex_Cmp.getFields();
        if(objectname == 'Applicant__c')
             return SObjectType.Applicant__c.FieldSets.Applicant_Field_Set_For_Lex_Cmp.getFields();
            
        else
            return null;
    }
    
    @AuraEnabled
    public static Applicant__c getApplicantsData(string applicantId){
        Applicant__c ApplicantDetails = new Applicant__c();
        try{
            string query = 'SELECT Id, (' + getQueryString('Job_Applications__r') + 
                '), (' + getQueryString('Questionnaire__r') + '), '+ getFieldList('Applicant__c') + ' FROM Applicant__c where Id =:applicantId';
            system.debug('query: ' + query);
            ApplicantDetails =  Database.query(query);
            system.debug('****ApplicantDetails: '+ApplicantDetails); 
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRApplicantJourneyController.getApplicantsData', '');   
            system.debug('Error Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage());
            ApplicantDetails = null;
        }
        return ApplicantDetails;
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
    
     public static String getFieldList(string objectname) {
        String query = '';
        for(Schema.FieldSetMember f : getFields(objectname)) {
            query += f.getFieldPath() + ',';
        }
        query = query.substring(0, query.length() - 1);
        return query;
    }
}