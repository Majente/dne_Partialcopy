({
    
    doInit:function(component, event, helper){
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.siteInstance");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI, event, helper);
         
       // helper.getTypePicklist(component, event, helper);
       // helper.getUOMPicklist(component, event, helper);
        var action = component.get("c.initSite");
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state=='SUCCESS'){
                var site = response.getReturnValue() ;
                component.set("v.site",site);
                console.log("here......1111");
            }
            
            
        });
        
        $A.enqueueAction(action) ;
        var siteInstance=component.get("v.siteInstance");
        siteInstance.sobjectType='Site__c';
        component.set("v.siteInstance",siteInstance);
        
    },
    AddNewRow : function(component, event, helper){
        // fire the AddNewRowEvt Lightning Event 
        var rowParentIndex = component.get("v.rowIndexParent");
        console.log("rowParentIndex-------"+rowParentIndex);
        component.getEvent("AddNewAccountSiteEvt").setParams({rowParentIndex:rowParentIndex}).fire();     
    },
    
    removeRow : function(component, event, helper){
        // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
        component.getEvent("DeleteAccountSiteEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
    checkBillingAddress: function(component, event, helper){
        
        var accounBillingDetails = component.get('v.accounDetails');
        var accountInstance=component.get('v.AccountInstance');
        console.log(accounBillingDetails);
        if(accountInstance.Billing_address_same_as_parent__c && accounBillingDetails.BillingAddress!=undefined){ 
            accountInstance.BillingStreet = accounBillingDetails.BillingAddress.street?accounBillingDetails.BillingAddress.street:'';
            accountInstance.BillingCity = accounBillingDetails.BillingAddress.city?accounBillingDetails.BillingAddress.city:'';
            accountInstance.BillingState = accounBillingDetails.BillingAddress.state?accounBillingDetails.BillingAddress.state:'';
            accountInstance.BillingPostalCode = accounBillingDetails.BillingAddress.postalCode?accounBillingDetails.BillingAddress.postalCode:'';
            accountInstance.BillingCountry = accounBillingDetails.BillingAddress.country?accounBillingDetails.BillingAddress.country:'';
        }else{
            accountInstance.BillingStreet='';
            accountInstance.BillingCity='';
            accountInstance.BillingState='';
            accountInstance.BillingPostalCode='';
            accountInstance.BillingCountry='';
        }
        component.set('v.AccountInstance',accountInstance);
        
    },
    onControllerFieldChangeforValue:function(component, event, helper)
    { 
		var flag = true;
        helper.onControllerFieldChange(component, event, helper, flag);
    },
    onCardListChange:function(component, event, helper){                
        component.set("v.siteInstance",component.get("v.siteInstance")) ;
    }
   
})