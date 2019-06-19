({
    doInit:function(component, event, helper) {
        var obj = component.get("v.selectedLookUpRecord");
        console.log("***doInit",obj.Id);
        
        
    },
    handleComponentEvent:function(component, event, helper) {
		helper.getSelectedApplicant(component, event, helper);
        
    },
    expandJobApplicantionSection : function(component, event, helper) {
        helper.expandSection(component,event,'expanJobApplicationId');
    },
    expandQuestionSection: function(component, event, helper) {
        helper.expandSection(component,event,'expandQuestionSectionId');
    },
    expandEnquirySection: function(component, event, helper) {
        helper.expandSection(component,event,'expandEnquirySectionId');
    },
    onApplicantOptionChange : function(component, event, helper) {
    }
})