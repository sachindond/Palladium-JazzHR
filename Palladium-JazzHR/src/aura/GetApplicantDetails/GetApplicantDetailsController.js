({
    doInit : function(component, event, helper) {
        var action = component.get("c.getSingleApplicantRecord");
        console.log("----->"+component.get("v.recordId"));
        action.setParams({"recordId" :component.get("v.recordId")});
        action.setCallback(this,function(res){
            if(res.getState() === "SUCCESS"){
                var syncedRecord = res.getReturnValue();
                console.log("------syncedRecord ",syncedRecord);
                //$A.get("e.force:closeQuickAction").fire();
                if(syncedRecord.isSyncCompleted == true){
                    var applicantRecord = syncedRecord.SyncedApplicant;
                    component.set("v.applicantRecord",applicantRecord);
                    if(applicantRecord.Type__c!=null && applicantRecord.Type__c!=''){
                        console.log("**** applicantRecord.Type__c *** ",applicantRecord.Type__c);
                        if(applicantRecord.Type__c == 'JazzHR'){
                            component.set("v.isSpinnerClosed",false);
                            component.set("v.showSendEmailDiv",true);
                        }else{
                           
                            $A.get("e.force:closeQuickAction").fire();
                            helper.showToast("Success!", "Record synced from JazzHR. Please refresh the page.", "success");
                        }
                    }
                }else{
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast("Error!", "Record sync from JazzHR failed. Please try again or contact administrator.", "error");
                }
            }else{
                 helper.showToast("Error!", "Record sync from JazzHR failed. Please try again or contact administrator.", "error");
            }
        });
		$A.enqueueAction(action);
    },
    sendEmailToApplicant : function(component, event, helper) {
        var appRecord = component.get("v.applicantRecord");
        //var applicantId = 'a1H0Q000000AvIBUA0';
        var applicantId = component.get("v.recordId");
        if(applicantId!=null && applicantId!=''){
            console.log("*** Send Email From Here applicant ID",applicantId);
            var action = component.get("c.sendEmail");
            action.setParams({"applicantId" :applicantId});
            action.setCallback(this,function(res){
                if(res.getState() === "SUCCESS"){
                    var returnValue = res.getReturnValue();
                    if(returnValue ==true){
                        helper.showToast("Success!", "Record synced from JazzHR and reminder email sent successfully. Please refresh the page.", "success");
                        component.set("v.showSendEmailDiv",false);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }else{
                    console.log("***Fail");
                }
            });
            $A.enqueueAction(action);
        }
    },
    onClickCancelButton: function(component, event, helper) {
        component.set("v.showSendEmailDiv",false);
        $A.get("e.force:closeQuickAction").fire();
        helper.showToast("Success!", "Record synced from JazzHR. Please refresh the page.", "success");
    }
})