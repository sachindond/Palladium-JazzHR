({
	expandSection:function(component,event,secId){
	  var allsection = component.find(secId);
        	for(var selectedSection in allsection) {
        	$A.util.toggleClass(allsection[selectedSection], 'slds-show');  
        	$A.util.toggleClass(allsection[selectedSection], 'slds-hide');  
       }
	},
    getSelectedApplicant:function(component,event,helper){
        var obj = component.get("v.selectedLookUpRecord");
        console.log("***doInit",obj.Id);
        var action = component.get("c.getApplicantsData");
        action.setParams({"applicantId":obj.Id});
        action.setCallback(this,function(respo){
            console.log("*******Applicant Details: ",respo.getReturnValue());
            component.set('v.ApplicantDetails', respo.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})