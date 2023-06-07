({
    getSiteDetailsByPage : function(component, event, helper, sites, start, end) {    
        //alert('start'+start+'end'+end);
        component.set("v.loaded",false);
         var UnitTypeList = [];
                var StoreResponse = component.get('v.depnedentFieldMap');
                var listOfkeys = [];
                var ControllerField = [];
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                component.set("v.listControllingValues", ControllerField);
                //console.log("listControllingValues :: "+ControllerField);
                 var depnedentFieldMap = component.get("v.depnedentFieldMap");
                var allSitesList = []; 
                //console.log("allSitesList%%"+JSON.stringify(allSitesList));
                    var siteList = sites ;    
                    //console.log("siteList =>"+JSON.stringify(siteList));
                    if(siteList.length){
                        siteList.forEach(function(value,key){
                            if (value.Type__c != '' && value.Type__c != '--- None ---' ) {
                                
                                var ListOfDependentFields = depnedentFieldMap[value.Type__c];
                                //console.log("ListOfDependentFields =>"+ListOfDependentFields);
                                if(ListOfDependentFields.length > 0){
                                    component.set("v.bDisabledDependentFld" , false);
                                    UnitTypeList = ListOfDependentFields;
                                }else{
                                    component.set("v.bDisabledDependentFld" , true); 
                                    component.set("v.listDependingValues", ['--- None ---']);
                                }  
                                
                            } else {
                                component.set("v.listDependingValues", ['--- None ---']);
                                component.set("v.bDisabledDependentFld" , true);
                            }
                            allSitesList.push({ 
                                Account__c: value.Account__c,
                                Id: value.Id,
                                Name: value.Name,  
                                Type__c: value.Type__c,
                                Volume__c: value.Volume__c,
                                Unit_of_Measure__c: value.Unit_of_Measure__c,
                                Error : value.Error,
                                errorMessage:value.errorMessage,
                                UnitTypeMeasureList: UnitTypeList
                            });                    
                        })
                    }else{
                        allSitesList.push({
                            Account__c: '',                        
                            Name: '',  
                            Type__c: '',
                            Volume__c: '',
                            Unit_of_Measure__c: '',
                            Error : 'Success',
                            errorMessage:''
                        });
                    }
                //console.log('allSitesList ####>>>>> '+JSON.stringify(allSitesList));
                component.set("v.siteList",allSitesList);
         console.log('siteList ####>>>>> '+JSON.stringify(component.get("v.siteList")));
        component.set("v.loaded",false);

    },
     generatePageList : function(component){
        var pageNumber = component.get("v.currentPageNumber");
        var pageList = [];
        var totalRecords = component.get("v.totalPages");
         //alert('pageNumber'+pageNumber+'totalRecords'+totalRecords);
        if(totalRecords > 1){ 
            if(totalRecords <= 5){
                var counter = 2;
                for(; counter < (totalRecords); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalRecords-5)){
                        pageList.push(totalRecords-5, totalRecords-4, totalRecords-3, totalRecords-2, totalRecords-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
         component.set("v.loaded",false);
    },
     onControllerFieldChange: function(component, event, helper, depPickLstFlag, ControllingVal) {    
       //console.log('Calling onControllerFieldChange');
       var index = event.getSource().get("v.name");
       var controllerValueKey = event.getSource().get("v.value");
       var depnedentFieldMap = component.get("v.depnedentFieldMap");
       //console.log("controllerValueKey " + controllerValueKey);
       // console.log("depnedentFieldMap " + depnedentFieldMap);
        if(controllerValueKey == null || controllerValueKey == undefined){
           controllerValueKey = ControllingVal;
       }  
       //console.log("controllerValueKey-1 " + controllerValueKey);
        
        if (controllerValueKey != '' && controllerValueKey != '--- None ---' ) {
           var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
           // console.log('ListOfDependentFields-11 :'+ListOfDependentFields);
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
           //console.log('SiteList for index::'+JSON.stringify(SiteList));
           //console.log('Calling fetchDepValues');
           //console.log('ListOfDependentFields :'+ListOfDependentFields);
           var dependentFields = [];
           dependentFields.push('--- None ---');
           for (var i = 0; i < ListOfDependentFields.length; i++) {
               dependentFields.push(ListOfDependentFields[i]);
           }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
       // console.log('ListOfDependentFields2 :'+component.get("v.listDependingValues"));
       // console.log('depPickListFlag ::: ' + depPickListFlag);
           if (depPickListFlag) {
               //console.log('In depPickListFlag If'); 
               var  allSitesList={Name: SiteList[index].Name,  
                                  Type__c: SiteList[index].Type__c,
                                  Volume__c: SiteList[index].Volume__c,
                                  UnitTypeMeasureList: dependentFields
                                 }
               //console.log('allSitesList'+JSON.stringify(allSitesList));
            SiteList[index]=allSitesList;
            //console.log('SiteList######:::'+JSON.stringify(SiteList));
            component.set("v.siteList", SiteList);
            //alert(JSON.stringify(component.get("v.siteList")));
		}		
        //console.log(component.get("v.siteList.Unit_of_Measure__c"));
        //console.log('dependentFields' + dependentFields);        
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