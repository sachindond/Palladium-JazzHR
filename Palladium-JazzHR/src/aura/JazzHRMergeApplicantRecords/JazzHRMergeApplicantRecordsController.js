({
    doInit : function(component, event, helper) {
       helper.findOtherDuplicateApplicant(component, event, helper);
       
    },
    openMergeCmp : function(component, event, helper) {
       component.set("v.isOpen",true);
        helper.allDuplicateApplicants(component, event, helper);
    },
    closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   },
    
    onSelection: function(component, event, helper) {
		 var selected = event.getSource().get("v.value");
		 selected = true;
   },
 
    moveNext : function(component,event,helper){
     // control the next button based on 'currentStep' attribute value    
     var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "1"){
            
            component.set("v.currentStep", "2");
        }
        else if(getCurrentStep == 2){
            component.set("v.currentStep", "3");
            helper.mergeApplicants(component,event,helper);
        }
    },
    
    moveBack : function(component,event,helper){
      // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
         if(getCurrentStep == "2"){
            component.set("v.currentStep", "1");
         }
         else if(getCurrentStep == 3){
            component.set("v.currentStep", "2");
         }
    },
    
    finish : function(component,event,helper){
      // on last step show the alert msg, hide popup modal box and reset the currentStep attribute  
        alert('Thank You !');
        component.set("v.isOpen", false); 
        component.set("v.currentStep", "1");
    },
   
   // when user click direactly on step 1,step 2 or step 3 indicator then showing appropriate step using set 'currentStep'   
    selectFromHeaderStep1 : function(component,event,helper){
        component.set("v.currentStep", "1");
    },
    selectFromHeaderStep2 : function(component,event,helper){
        component.set("v.currentStep", "2");
    },
    selectFromHeaderStep3 : function(component,event,helper){
        component.set("v.currentStep", "3");
    },
    previewRecords : function(component,event,helper){
        console.log("********** preview Records ******* ");
        
    },
    onRadioButtonChange:function(component,event,helper){
       
        var selected = event.getSource().get("v.text");
        console.log("***qq**selected"+selected);
        var applicationListMasterRecordSelected = component.get("v.lstApplicantMatchingApplicant");
        if(applicationListMasterRecordSelected.length>0){
            for(var i = 0 ;i<applicationListMasterRecordSelected.length;i++){
                if(selected ==applicationListMasterRecordSelected[i].recordId){
                    applicationListMasterRecordSelected[i].isSelected = true; 
                    component.set("v.isRecordSelected",true);
                }else{
                    applicationListMasterRecordSelected[i].isSelected = false; 
                    
                }
            }
            component.set("v.lstApplicantMatchingApplicant",applicationListMasterRecordSelected);
        }
        console.log("***********selected value of radio button",applicationListMasterRecordSelected);
        
        //
    }

 
})