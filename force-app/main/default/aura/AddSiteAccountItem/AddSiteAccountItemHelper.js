({
	helperMethod : function() {
		
	},
  /*  getTypePicklist : function(component, event, helper){
        var action = component.get("c.getTypeValue");
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state=='SUCCESS'){
                var type = response.getReturnValue() ;
                component.set("v.types",type);
                
                console.log("here......1111");
            }
            
            
        });
        
        $A.enqueueAction(action) ;
    },*/
  /*  getUOMPicklist : function(component, event, helper){
        var action = component.get("c.getUOMValue");
        action.setCallback(this,function(response){
            var state = response.getState();            
            if(state=='SUCCESS'){
                var units = response.getReturnValue() ;
                component.set("v.units",units);
            }
        });
        
        $A.enqueueAction(action) ;
    },*/
    
    //for Dependent PickList
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField, event, helper) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            setTimeout(function(){
            console.log('Calling fetchPicklistValues');
            if (response.getState() == "SUCCESS") {
            	console.log('Calling Inside If fetchPicklistValues');
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                //alert('Test :: ' + StoreResponse);
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                
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
            }else{
            }
				var pLflag = false;
                helper.onControllerFieldChange(component, event, helper, pLflag);
            }, 500);
            
        });
        $A.enqueueAction(action);
       
    },
    
    fetchDepValues: function(component, ListOfDependentFields, depPickListFlag) {
        // create a empty array var for store dependent picklist values for controller field  
        console.log('Calling fetchDepValues');
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        console.log('depPickListFlag ::: ' + depPickListFlag);
		if (depPickListFlag) {
            console.log('In depPickListFlag If');            
			component.set("v.siteInstance.Unit_of_Measure__c", ['--- None ---']);		
		}		
        console.log(component.get("v.siteInstance.Unit_of_Measure__c"));
        console.log('dependentFields' + dependentFields);        
     },
     //Dependent picklist 
    onControllerFieldChange: function(component, event, helper, depPickLstFlag) {    
        console.log('Calling onControllerFieldChange');
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        console.log("controllerValueKey " + controllerValueKey);
        console.log("depnedentFieldMap " + depnedentFieldMap);
        if(component.get('v.siteInstance.Type__c') != null)
        {
            controllerValueKey = component.get('v.siteInstance.Type__c');
        }
        if (controllerValueKey != '' && controllerValueKey != '--- None ---' ) {
           // alert('controller value::'+controllerValueKey);
           // alert('dependent map:::'+depnedentFieldMap);
           var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
           
            if( ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields, depPickLstFlag);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
})