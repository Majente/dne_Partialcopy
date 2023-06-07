({
    // function call on component Load
    doInit: function(component, event, helper) {   
        component.set("v.loaded",true);
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        const sURLVariables = sPageURL.split("=")[1];
        if(sURLVariables!=null){
            component.set("v.recordId",sURLVariables);
        }
        var UnitTypeList = [];
        var recordId = component.get("v.recordId")
        var action = component.get("c.getAccountSites");
        action.setParams({  
            recordId: recordId
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state == 'SUCCESS') {    
                var result = res.getReturnValue();
                console.log('result ::'+JSON.stringify(result));
                component.set("v.accountDetails",result[0].serviceAddressAccount);
                component.set("v.siteListLength",result[0].siteList.length-1);
                component.set("v.depnedentFieldMap",result[0].dependentMap);
                component.set("v.cardList",result[0]);
                var StoreResponse = component.get('v.depnedentFieldMap');
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = [];
                // for store controller picklist value to set on lightning:select. 
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
                console.log("listControllingValues :: "+ControllerField);
                 var depnedentFieldMap = component.get("v.depnedentFieldMap");
                var allSitesList = []; 
                console.log("allSitesList%%"+JSON.stringify(allSitesList));
                    var siteList = result[0].siteList ;    
                    console.log("siteList =>"+JSON.stringify(siteList));
                    if(siteList.length){
                        siteList.forEach(function(value,key){
                            if (value.Type__c != '' && value.Type__c != '--- None ---' ) {
                                
                                var ListOfDependentFields = depnedentFieldMap[value.Type__c];
                                console.log("ListOfDependentFields =>"+ListOfDependentFields);
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
                console.log('allSitesList ####>>>>> '+JSON.stringify(allSitesList));
                component.set("v.siteList",allSitesList);
            } 
            console.log('siteList ####>>>>> '+JSON.stringify(component.get("v.siteList")));
        });     
        
        $A.enqueueAction(action);
    },
    
    AddNewRow : function(component, event, helper){
        var icon = component.get("v.siteListLength");
        icon++
        component.set("v.siteListLength",icon);
        var cList = component.get("v.cardList");
        var Acc = cList.serviceAddressAccount.Id;
        //alert(Acc);
        var site = {'Account__c':Acc,'Name':'','Type__c':'','Unit_of_Measure__c':'','Volume__c':'','UnitTypeMeasureList':['--- None ---']};
        var rowSiteAdd = component.get("v.siteList");
        rowSiteAdd.push(site);
        // component.set("v.siteListLength",rowSiteAdd.length-1);
        component.set("v.siteList",rowSiteAdd); 
    },
    
    removeRow : function(component, event, helper){
        var icon = component.get("v.siteListLength");
        icon--
        component.set("v.siteListLength",icon);
        var rowSiteDelete = component.get("v.siteList");
        var curRec = event.target.name;
        rowSiteDelete.splice(curRec,1);
        
        if(rowSiteDelete.length == 0){
            var site = {'Name':'','Type__c':'','Unit_of_Measure__c':'','Volume__c':0,'UnitTypeMeasureList':['--- None ---']};
            rowSiteDelete.push(site);
        }
        component.set("v.siteList",rowSiteDelete);
        component.set("v.siteListLength",rowSiteDelete.length-1);
        
    },
    
    // function for save the Records 
    Save: function(component, event, helper) {
        var SaveSiteList = [];
        var allSitesList = [];
        var accId = component.get("v.recordId");
        var siteListSave = component.get("v.siteList");
        var cList = component.get("v.cardList");
        var accountDetails = component.get("v.accountDetails");
        console.log('accountDetails'+JSON.stringify(accountDetails));
            if(accountDetails.Name == '' || accountDetails.Name == null){
                //component.set("v.loaded",false);
                return helper.showMsg("Name of Service Address is missing.", "error");
            }
             if(accountDetails.Market__c[0] == '' || accountDetails.Market__c[0] == null){
                //component.set("v.loaded",false);
                return helper.showMsg("Market is missing.", "error");
            }
        if(siteListSave.length){
            siteListSave.forEach(function(value,key){
                allSitesList.push({ 
                    Account__c: value.Account__c,
                    Id: value.Id,
                    Name: value.Name,  
                    Type__c: value.Type__c,
                    Volume__c: value.Volume__c,
                    Unit_of_Measure__c: value.Unit_of_Measure__c,
                });
            });
        }
        for(var i=0; i < allSitesList.length; i++){
                console.log('Site type :: ' + allSitesList[i].Unit_of_Measure__c);
                if(allSitesList[i].Name != '' && (allSitesList[i].Type__c == '' || allSitesList[i].Type__c == null || allSitesList[i].Type__c == '--- None ---')){
                    //component.set("v.loaded",false);
                    return helper.showMsg("Type of Site is missing.", "error");
                }  
                if(allSitesList[i].Name != '' && (allSitesList[i].Volume__c == '' || allSitesList[i].Volume__c == null)){
                   //component.set("v.loaded",false);
                    return helper.showMsg("Volume is missing.", "error");
                     
                } 
                if(allSitesList[i].Name != '' && (allSitesList[i].Unit_of_Measure__c == '' || allSitesList[i].Unit_of_Measure__c == null || allSitesList[i].Unit_of_Measure__c == '--- None ---')){
                   //component.set("v.loaded",false);
                    return helper.showMsg("Unit of Measure is missing.", "error");
                }
            }
        /*console.log('cardList'+JSON.stringify(cardList));
        console.log('siteSave'+JSON.stringify(siteListSave));
        console.log('accountDetails'+JSON.stringify(accountDetails));*/
        var newRecord = {
            parentAccountId:cList.parentAccountId,
            serviceAddressAccount:cList.serviceAddressAccount,
            siteList:allSitesList,
            parentAccountDetail:accountDetails,
            dependentMap:cList.dependentMap
        }
        var accId = cList.parentAccountId;
        SaveSiteList.push(newRecord);
        console.log('SaveSiteList =>>'+JSON.stringify(SaveSiteList));
        //console.log('allSitesList&&&&& '+allSitesList);
        var action = component.get("c.saveAccountSites");
        action.setParams({
            ListAccounts: JSON.stringify(SaveSiteList),
            accId:accId
        });       
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dupSiteErrorMsg;
                var dupSite = true;
                console.log("SUCCESS");
                var result = response.getReturnValue();
                console.log('result = '+JSON.stringify(result));
                if(result.length>0){
                    for(var i = 0; i < result.length; i++){
                        if(result[i].flag){
                            return helper.showMsg(result[i].message, "error"); 
                        }
                    }
                console.log('result ::'+JSON.stringify(result));                     
            } 
           // console.log('siteList ####>>>>> '+JSON.stringify(component.get("v.siteList")));
                
                $A.get('e.force:refreshView').fire();
            }else{
                //alert(JSON.stringify(response.getError()));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"Error",
                    "message": response.getError()[0].message
                });
                toastEvent.fire();
                component.set("v.loaded",false);
            }
        });
        
        $A.enqueueAction(action);
    },
    sameddress: function(component, event, helper) {
        var sameAddress = component.get("v.ParentAccountInstance.serviceAddressAccount.Service_address_same_as_parent__c");
        component.set("v.sameAddress.ShippingStreet",'');
        component.set("v.sameAddress.ShippingCity",'');
        component.set("v.sameAddress.ShippingState",'');
        component.set("v.sameAddress.ShippingPostalCode",'');
        component.set("v.sameAddress.ShippingCountry",'');
        
    },
     onControllerFieldChangeforValue:function(component, event, helper)
    { 
		var flag = true;
        helper.onControllerFieldChange(component, event, helper, flag,'');
    },
})