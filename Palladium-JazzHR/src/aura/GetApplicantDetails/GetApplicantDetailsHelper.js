({
        
        showToast : function(title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type
            });
            toastEvent.fire();
        },
    sendEmailToApplicant : function(component, event, helper,applicantId) {
        if(applicantId!=null && applicantId!=''){
            console.log("*** Send Email From Here applicant ID",applicantId);
            var action = component.get("c.sendEmail");
            action.setParams({"applicantId" :applicantId});
            action.setCallback(this,function(res){
                if(res.getState() === "SUCCESS"){
                    var returnValue = res.getReturnValue();
                    if(returnValue ==true){
                        helper.showToast("Success!", "Email Sent Successfully", "success");
                        component.set("v.showSendEmailDiv",false);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})