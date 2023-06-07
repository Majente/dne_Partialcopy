({
    
    doInit:function(component, event, helper){
        var rowIndex = component.get('v.rowIndex');
        var lengthOfList = component.get('v.lengthOfList');         
        var controllerValueKey = component.find("cntrlFld").get("v.value") 
        var StoreResponse = component.get('v.depnedentFieldMap');
        // create a empty array for store map keys(@@--->which is controller picklist values) 
        var listOfkeys = []; // for store all map keys (controller picklist values)
        var ControllerField = []; // for store controller picklist value to set on lightning:select. 
        
        // play a for loop on Return map 
        // and fill the all map key on listOfkeys variable.
        for (var singlekey in StoreResponse) {
            listOfkeys.push(singlekey);
        }
        //set the controller field value for lightning:select
        if (listOfkeys != undefined && listOfkeys.length > 0) {
            ControllerField.push('--- None ---');
        }
        
        for (var i = 0; i < listOfkeys.length; i++) {
            ControllerField.push(listOfkeys[i]);
        }  
        // set the ControllerField variable values to country(controller picklist field)
        component.set("v.listControllingValues", ControllerField);
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        if (controllerValueKey != '' && controllerValueKey != '--- None ---' ) {
           // alert('controller value::'+controllerValueKey);
           // alert('dependent map:::'+depnedentFieldMap);
           var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields,false);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
        
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