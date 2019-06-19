({
    // on click of fetch applicant button call apex method to get deleted applicant jazzhr into system.
    onClickFetchApplicantButton : function(component, event, helper) {
        var jazzHRApplicantID = component.find("inputTextBoxID").get("v.value");
        console.log("** JazzHR applicant ID **",jazzHRApplicantID);
        if(jazzHRApplicantID ==''){
            component.find("inputTextBoxID").set("v.errors", [{message:"This Field is Rquired"}]);
       		return false;
        }
        
        component.find("inputTextBoxID").set("v.errors",null);
        var action = component.get("c.fetchDeletedApplicant");
        action.setParams({"jazzHRApplicantId":jazzHRApplicantID});
        action.setCallback(this,function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var syncRecord = response.getReturnValue();
                console.log("***syncRecord",syncRecord);
                if(syncRecord.isSyncCompleted == true){
                    console.log("**syncRecord.JazzHR_Applicant_ID__c*",syncRecord.Id);
                    console.log("**syncRecord.SyncedApplicant",syncRecord.SyncedApplicant);
                    helper.showToast("Success!", "Record synced from JazzHR. Please refresh the page.", "success");
                    window.location = '/'+ syncRecord.SyncedApplicant.Id;
                }else if(syncRecord.isSyncCompleted == false){
                    helper.showToast("error!", "Fetching deleted Applicant failed. Please check JazzHR Applicant ID again or Contact Administrator", "error");
                }
                
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})