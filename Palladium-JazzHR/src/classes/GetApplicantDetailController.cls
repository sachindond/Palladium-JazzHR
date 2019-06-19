/** Developer		: Vinit/Sachin
* Date				: 31 Jan 2019
* Purpose			: Class used to sync individual applicant
**/
public class GetApplicantDetailController {
    /*    
@AuraEnabled
public static string recordId{set;get;}
*/  
    @AuraEnabled
    public static JazzHRSFDCUtils.SyncApplicantResponse getSingleApplicantRecord(string recordId){        
        boolean bRet = false;
        JazzHRSFDCUtils.SyncApplicantResponse singleApplicantResponseObj= new JazzHRSFDCUtils.SyncApplicantResponse();
        system.debug('---recordId'+recordId);
        
        Applicant__c appObj = [select id,JazzHR_Applicant_ID__c from Applicant__c where id=:recordId];
        //JazzHRWrapper.ApplicantWrapper applicantRecord = new JazzHRWrapper.ApplicantWrapper();
        System.debug('----appObj'+appObj);
        if(appObj !=null){            
            JazzHRWrapper.ApplicantWithSingleApplicationWrapper applicantWithSingleApp;
            JazzHRWrapper.ApplicantWrapper applicantRecord = JazzHRCallouts.GetSingleApplicant(appObj.JazzHR_Applicant_ID__c);
            if(applicantRecord == null)
                applicantWithSingleApp = JazzHRCallouts.ApplicantWithSingleApplicationWrapper(appObj.JazzHR_Applicant_ID__c);
            singleApplicantResponseObj = JazzHRSFDCUtils.SyncSingleApplicant(applicantRecord, applicantWithSingleApp);
            If(Test.isRunningTest())
                Logger.Log('Information','','GetApplicantDetailController.getSingleApplicantRecord', null);    
            
            return singleApplicantResponseObj;
        }
        return singleApplicantResponseObj;
    }
    @AuraEnabled
    public static boolean sendEmail(string applicantId){
        try{
            
            JazzHR_Setting__c jazzHRSettingObj = JazzHR_Setting__c.getInstance('JazzHR');
            boolean IsSendEmailEnabled = false;
            If(jazzHRSettingObj !=null)
            {
                IsSendEmailEnabled = jazzHRSettingObj.Enable_Send_Email__c;
                system.debug('Send Email?: ' + IsSendEmailEnabled);
                if(IsSendEmailEnabled)
                {
                    Applicant__c applicantRecord = [select First_Name__c,Last_Name__c,Email__c from  Applicant__c where Id =:applicantId limit 1];
                    //Job_Listing__c listing = [Select Description__c From Job_Listing__c WHERE Id = 'a3z0Q0000008jgm'];
                    date d = date.today();
                    Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
                    String dateString = dt.format('d MMMM yyyy');
                    system.debug('dateString'+dateString);
                    string emailbody = '<p class="ql-indent-8" style="text-align: right;"><img height="119" width="250" style="margin-right:70px; margin-top:50px;" src="https://bpsdc--c.eu8.content.force.com/servlet/servlet.ImageServer?id=0150N00000782ML&oid=00Db0000000dbrK&lastMod=1557772523000" alt=""></img></p>'
                        +'<p style="text-align: right;  margin-right:84px;"><span style="color: gray; line-height: 0px;">Battersea Academy for Skills &amp; Employment CIC</span></p>'
                        +'<p style="text-align: right; margin-right:84px;"><span style="color: gray; line-height: 0px;">30 Arches Lane</span></p>'
                        +'<p style="text-align: right;  margin-right:84px;"><span style="color: gray; line-height: 0px;">Battersea Power Station</span></p>'
                        +'<p style="text-align: right;  margin-right:84px;"><span style="color: gray; line-height: 0px;">London SW11 8AB </span></p>'
                        +'<p style="text-align: right;  margin-right:84px;"><br></p>'
                        +'<p style="margin-left:30px;color: gray;">'+ dateString+'</p>'
                        +'<p style="margin-left:30px;">Dear Applicant,</p>'
                        +'<p> </p>'
                        +'<p style="margin-left:30px;">Thank you for your recent application.</p>'
                        +'<p> </p>'
                        +'<p  style="margin:0; margin-left:30px;">To keep informed of new roles and to get regular updates from us please add your details to</p>'
                        +'<p  style=" margin-left:30px;">our talent pool, the online link for this is <a href="https://baseskillsacademy.co.uk/talent-pool/" target="_blank">https://baseskillsacademy.co.uk/talent-pool/</a></p>'
                        +'<p> </p>'
                        +'<p  style="margin-left:30px;">If you would like us to erase your data from our systems please contact us directly and we</p>'
                        +'<p  style=" margin:0; margin-left:30px;">shall email confirmation that this has been actioned. </p>'
                        +'<p> </p>'
                        +'<p  style="margin-left:30px;">To find out more about our privacy policy please refer to our website <a href="https://baseskillsacademy.co.uk/" target="_blank">https://baseskillsacademy.co.uk/</a></p>'
                        +'<p> </p>'
                        +'<p  style="margin-left:30px;">Thank you for your interest in Battersea Power Station</p>'
                        +'<p><br></p>'
                       
                    	+'<table style="margin-left:30px;" class="ql-table-blob" border="0" style="width: 552.85pt; margin-left: -56.95pt;" width="737">'
                   		+'<tbody>'
                      	+'<tr>'
                        +'<td colspan="1" rowspan="1" valign="bottom" width="284" style="width: 212.65pt;">'
                        +'<p class="MsoFooter"><span style="font-size: 8.0pt;"> </span></p>'
                        +'<p class="MsoFooter"><b><span style="font-size: 8.0pt;">Battersea Academy for Skills &amp; Employment CIC</span></b></p>'
                        +'<p class="MsoFooter"><span style="font-size: 8.0pt;">  30</span> &nbsp;<span style="font-size: 8.0pt;">Arches Lane <b></b></span></p>'
                        +'<p class="MsoFooter"><span style="font-size: 8.0pt;">Battersea Power Station</span></p>'
                        +'<p class="MsoFooter"><span style="font-size: 8.0pt;">London SW11 8AB</span></p>'
                        +'</td>'
                        +'<td colspan="1" rowspan="1" valign="bottom" width="246" style="width: 184.25pt;">'
                        +'<p class="MsoFooter"><b><span style="font-size: 8.0pt;">Incorporated Community Interest Company</span></b></p>'
                        +'<p class="MsoFooter"><span style="font-size: 8.0pt;">Registered in England and Wales</span></p>'
                        +'<p class="MsoFooter"><span style="font-size: 8.0pt;">Company No. 10506927</span></p>'
                        +'<p class="MsoFooter"><span style="font-size: 8.0pt;">Vat no: 267 009 991</span></p>'
                        +'</td>'
                        +'<td colspan="1" rowspan="1" valign="bottom" width="208" style="width: 155.95pt;">'
                        +'<p class="MsoFooter" style="text-align: justify;"><span style="font-size: 8.0pt;">T: (+44) 20 7062 1804</span></p>'
                        +'<p class="MsoFooter" style="text-align: justify;"><span style="font-size: 8.0pt;">F: (+44)20 7 501 0699</span></p>'
                        +'<p class="MsoFooter" style="text-align: justify;"><span style="font-size: 8.0pt;">E: <span class="MsoHyperlink"><a href="mailto:hello@baseskillsacademy.co.u" target="_blank">hello@baseskillsacademy.co.u</a></span><u><span style="color: #0070C0;">k</span></u></span></p>'
                        +'<p class="MsoFooter" style="text-align: justify;"><span style="font-size: 8.0pt;">W: www.baseskillsacademy.co.uk</span></p>'
                        +'</td>'
                      	+'</tr>'
                       	+'</tbody>'
                       	+'</table>';
                     	
/* Commented these two lines after request from Herman.
 *                         +'<p> </p>'
                        +'<p style="margin-left:30px;">We have had a high number of responses for this vacancy and unfortunately you have not</p>'
                        +'<p style="margin:0; margin-left:30px;">met the full criteria to be successful on this occasion.</p>'
 **/
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    system.debug('***applicantRecord'+applicantRecord);
                    //mail.setTargetObjectId(applicantId); 
                    mail.setSenderDisplayName('BASE Notification'); 
                    mail.setSubject('BASE Notification');
                    mail.setUseSignature(false); 
                    mail.setBccSender(false); 
                    mail.setSaveAsActivity(false);
                    // TO ADDRESS SHOUL 
                   //mail.toaddresses =new String[] {'er.sachindond@gmail.com'};
                   mail.toaddresses = new String[] {applicantRecord.Email__c};
                   // EmailTemplate et=[Select id,Body from EmailTemplate where Name=:'Notify Applicant To Register Via Talent Pool V2']; 
                   // system.debug('********EMail template'+et.Id);
                   // mail.setTemplateId(et.id); 
                    //mail.setHtmlBody(et.Body);
                        // mail.setHtmlBody('Hello ' + applicantRecord.First_Name__c +'<br/><br/> It appears you have not yet register via talent pool. <br/> Benefits-Test <br/> Registration Link- Test Link </br> </br> Thanks </br> </br> Regards <br/> BASE Team');
                    mail.setHtmlBody(emailbody);
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }     
            
            return true;
        }
        catch(Exception oEx)
        {
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'JazzHRMergeApplicantRecordsController.sendEmail', '');    
            return false;
        }
    }
}