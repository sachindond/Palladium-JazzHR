({
	findOtherDuplicateApplicant : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.findDuplicateApplicants");
        action.setParams({"applicantId":recordId});
        action.setCallback(this,function(respo){
            if(respo.getState() === 'SUCCESS'){
                var applicantRecords = respo.getReturnValue();
                console.log("*@@**Single **** applicantRecords****",applicantRecords);
                component.set("v.lstApplicant",applicantRecords);
            }
        });
        $A.enqueueAction(action);
	},
    // get all duplicate applicants
    allDuplicateApplicants: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getAllDuplicateApplicants");
        action.setParams({"applicantId":recordId});
        action.setCallback(this,function(respo){
            if(respo.getState() === 'SUCCESS'){
                var applicantRecords = respo.getReturnValue();
                console.log("*** All applicantRecords****",applicantRecords);
                component.set("v.lstApplicantMatchingApplicant",applicantRecords);
            }
        });
        $A.enqueueAction(action);
    },
    // Merge applicant with master record
    mergeApplicants:function(component,event,helper){
        // get master recocrd id and email 
        var selectedMasterApplicant =  component.get("v.lstApplicantMatchingApplicant");
        var email;
        var masterApplicantRecordId;
        if(selectedMasterApplicant.length>0){
            for(var i=0;i<selectedMasterApplicant.length;i++){
                if(selectedMasterApplicant[i].isSelected == true){
                    email = selectedMasterApplicant[i].email;
                    masterApplicantRecordId = selectedMasterApplicant[i].recordId;
                } 
            }
            var action = component.get("c.MergeDuplicateApplicants");
            action.setParams({"masterApplicantId":masterApplicantRecordId,"email":email});
            action.setCallback(this,function(respo){
                console.log("****** state",respo.getState());
                console.log("****respo"+respo.getReturnValue());
                var istrue = true;
                if(respo.getReturnValue() == true){
                    var interval = setInterval($A.getCallback(function () {
                        
                        console.log("**********interval",component.get('v.progress'));
                        var progress = component.get('v.progress');
                        if(progress !=100){
                        component.set('v.progress', progress === 100 ? clearInterval(interval) : progress + 10);
                            
                        }else{
                            component.set('v.progress',100);
                            clearInterval(interval);
                            console.log("**$$*100%Completed");
							window.location ='/'+ masterApplicantRecordId;
                            
                            component.set("v.isOpen",false);
                            
                        }
                    }), 1000);
                    
                }
            });
            $A.enqueueAction(action);
        }
        
    }
})