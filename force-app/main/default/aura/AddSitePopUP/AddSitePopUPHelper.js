({
   onControllerFieldChange: function(component, event, helper, depPickLstFlag, ControllingVal) {    
       console.log('Calling onControllerFieldChange');
       var index = event.getSource().get("v.name");
       var controllerValueKey = event.getSource().get("v.value");
       var depnedentFieldMap = component.get("v.depnedentFieldMap");
       console.log("controllerValueKey " + controllerValueKey);
        console.log("depnedentFieldMap " + depnedentFieldMap);
        if(controllerValueKey == null || controllerValueKey == undefined){
           controllerValueKey = ControllingVal;
       }  
       console.log("controllerValueKey-1 " + controllerValueKey);
        
        if (controllerValueKey != '' && controllerValueKey != '--- None ---' ) {
           var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            console.log('ListOfDependentFields-11 :'+ListOfDependentFields);
            if( ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields, depPickLstFlag, index);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
       fetchDepValues: function(component, ListOfDependentFields, depPickListFlag, index) {
        // create a empty array var for store dependent picklist values for controller field 
           var SiteList = component.get("v.siteList"); 
           console.log('SiteList for index::'+JSON.stringify(SiteList));
           console.log('Calling fetchDepValues');
           console.log('ListOfDependentFields :'+ListOfDependentFields);
           var dependentFields = [];
           dependentFields.push('--- None ---');
           for (var i = 0; i < ListOfDependentFields.length; i++) {
               dependentFields.push(ListOfDependentFields[i]);
           }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        console.log('ListOfDependentFields2 :'+component.get("v.listDependingValues"));
        console.log('depPickListFlag ::: ' + depPickListFlag);
           if (depPickListFlag) {
               console.log('In depPickListFlag If'); 
               var  allSitesList={Name: SiteList[index].Name,  
                                  Type__c: SiteList[index].Type__c,
                                  Volume__c: SiteList[index].Volume__c,
                                  UnitTypeMeasureList: dependentFields
                                 }
               console.log('allSitesList'+JSON.stringify(allSitesList));
            SiteList[index]=allSitesList;
            console.log('SiteList######:::'+JSON.stringify(SiteList));
            component.set("v.siteList", SiteList);
            //alert(JSON.stringify(component.get("v.siteList")));
		}		
        //console.log(component.get("v.siteList.Unit_of_Measure__c"));
        console.log('dependentFields' + dependentFields);        
     },
       showMsg: function(msg,err){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": msg,
            "type": err
        });
        toastEvent.fire();
        component.set("v.loaded",false);
        return false;
    },
})