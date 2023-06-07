({
    
    createObjectData: function(component, event,helper,obj) {
        console.log('obj:::'+JSON.stringify(obj));
        var RowItemList = component.get("v.cardList"); 
        var RowItemFinalList = component.get("v.FinalcardList"); 
        var ExistingData = component.get("v.ExistingDataList"); 
        var parentAccountId =component.get("v.recordId");
        if(obj[0].hasOwnProperty("parentAccountId")){
            parentAccountId = obj[0].parentAccountId;           
        }
        var serviceAddressAccount = {
            Billing_address_same_as_parent__c: false,                
            Market__c: '',
            Name: '',
            //Parent: {Name: '', Id: ''},
            ParentId: parentAccountId,
            RecordTypeId: '',
            Service_address_same_as_parent__c: false,
            ShippingStreet:'',
            BillingCity:'',
            BillingState:'',
            BillingPostalCode:'',
            BillingCountry:''
        };
        if(obj[0].hasOwnProperty("parentAccountId")){
            
            component.set('v.ServiceAddressSame',"true");
            
            serviceAddressAccount = {
                Billing_address_same_as_parent__c: obj[0].serviceAddressAccount.Billing_address_same_as_parent__c,
                //Id: obj[0].serviceAddressAccount.Id,
                Market__c: [],
                //Name: obj[0].serviceAddressAccount.Name,
                //Parent: {Name: obj.serviceAddressAccount.Parent.Name, Id: obj.serviceAddressAccount.Parent.Name},
                ParentId: obj[0].serviceAddressAccount.ParentId,
                RecordTypeId: obj[0].serviceAddressAccount.RecordTypeId,
                Service_address_same_as_parent__c: obj[0].serviceAddressAccount.Service_address_same_as_parent__c,
                //ShippingStreet:obj[0].serviceAddressAccount.ShippingStreet,
                //ShippingCity:obj[0].serviceAddressAccount.ShippingCity,
                // ShippingState:obj[0].serviceAddressAccount.ShippingState,
                //ShippingPostalCode:obj[0].serviceAddressAccount.ShippingPostalCode,
                // ShippingCountry:obj[0].serviceAddressAccount.ShippingCountry,
            };
        }
        
        var siteList = obj[0].siteList ;
        var dependentMap = obj[0].dependentMap;
        var parentAccountDetail = obj[0].parentAccountDetail ;
        console.log('siteList = '+JSON.stringify(siteList));
        console.log('hasOwnProperty = '+obj[0].hasOwnProperty("siteList"));
        var allSitesList =[] ;
        if(obj[0].hasOwnProperty("siteList")){
            if(siteList.length){
                //siteList.forEach(function(value,key){
                
                allSitesList.push({ 
                    
                    Account__c: '',                        
                    Name: '',
                    Service_Address_As_Parent__c: '',
                    ParentId: parentAccountId,
                    Type__c: '',
                    Volume__c: '',
                    Unit_of_Measure__c: '',
                    Error : 'Success',
                    errorMessage:''
                });
                
                // })
            }else{
                allSitesList.push({ 
                    Account__c: '',                        
                    Name: '',
                    ParentId: parentAccountId,
                    Type__c: '',
                    Volume__c: '',
                    Unit_of_Measure__c: '',
                    Error : 'Success',
                    errorMessage:''
                });
            }
        }else{
            allSitesList.push({ Account__c: '',                               
                               Name: '',
                               Service_Address_As_Parent__c: '',
                               Unit_of_Measure__c: '',
                               Type__c: '',
                               Volume__c: '',
                               Error : 'Success',
                               errorMessage:''
                              });
        }
        var accountDetails = component.get("v.accountDetails");
        if(accountDetails==null){            
            component.set("v.accountDetails",parentAccountDetail);
            accountDetails = parentAccountDetail;
        }
        console.log('allSitesList = '+JSON.stringify(allSitesList));
        var newRecord = {
            parentAccountId:parentAccountId,
            serviceAddressAccount:serviceAddressAccount,
            siteList:allSitesList,
            parentAccountDetail:accountDetails,
            dependentMap:dependentMap
        }
        console.log('newRecord = '+JSON.stringify(newRecord));
        
        RowItemList.splice(1, 0,newRecord);
        RowItemFinalList.push(newRecord);
        ExistingData.splice(1, 0, newRecord);
        component.set("v.cardList", RowItemList);
        console.log('cardList-createObj = '+JSON.stringify(component.get("v.cardList")));
        component.set("v.FinalcardList", RowItemFinalList);
        console.log('ExistingDataList-createObj = '+JSON.stringify(component.get("v.ExistingDataList")));
        component.set("v.ExistingDataList",ExistingData);
        console.log('FinalcardList-createObj = '+JSON.stringify(component.get("v.FinalcardList")));
        
        
    },
    
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"Success",
            "title": "Success!",
            "message": "The record has been Saved successfully."
        });
        toastEvent.fire();
    },
    showToastError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"Error",
            "title": "Error!",
            "message": "Please Select Market."
        });
        toastEvent.fire();
    },
    
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
        
        var isValid = true;
        var allContactRows = component.get("v.accountList");
        for (var indexVar = 0; indexVar < allContactRows.length; indexVar++) {
            if (allContactRows[indexVar].Name == '') {
                isValid = false;
                alert('Enter Site Name ');
            }
            if (allContactRows[indexVar].Business_Size__c == '') {
                isValid = false;
                alert('Select Business Size ' );
            }
        }
        return isValid;
    },
    
    getAccountDetailsByPage:function(component, event, helper){
        component.set("v.loaded",true);
        var result = component.get("v.ResultData");
        console.log("Resultpage ::"+JSON.stringify(result));
        var RowItemList =[] ;//= component.get("v.cardList");
        if(result.length){      
            result.forEach(function(value,key){
                //For each account
                var parentAccountId = component.get("v.recordId");
                var parentAccountDetail = value.parentAccountDetail;
                var dependentMap = value.dependentMap;
                console.log('dependentMap:: '+JSON.stringify(dependentMap))
                component.set("v.ColumnData",value.DataColumn);
                if(value.hasOwnProperty("parentAccountId")){
                    parentAccountId = value.parentAccountId;           
                }
                var serviceAddressAccount = {
                    Billing_address_same_as_parent__c: false,                
                    Market__c: '',
                    Name: '',
                    //Parent: {Name: '', Id: ''},
                    ParentId: parentAccountId,
                    RecordTypeId: '',
                    Service_address_same_as_parent__c: false,
                    ShippingStreet:'',
                    BillingCity:'',
                    BillingState:'',
                    BillingPostalCode:'',
                    BillingCountry:''
                };
                
                if(value.hasOwnProperty("parentAccountId")){
                    component.set('v.ServiceAddressSame',"true");
                    serviceAddressAccount = {
                        Billing_address_same_as_parent__c: value.serviceAddressAccount.Billing_address_same_as_parent__c,
                        Id: value.serviceAddressAccount.Id,
                        Market__c: value.serviceAddressAccount.Market__c,
                        Market__r: value.serviceAddressAccount.Market__r,
                        Name: value.serviceAddressAccount.Name,
                        //Parent: {Name: obj.serviceAddressAccount.Parent.Name, Id: obj.serviceAddressAccount.Parent.Name},
                        ParentId: value.serviceAddressAccount.ParentId,
                        RecordTypeId: value.serviceAddressAccount.RecordTypeId,
                        Service_address_same_as_parent__c: value.serviceAddressAccount.Service_address_same_as_parent__c,
                        ShippingStreet:value.serviceAddressAccount.ShippingStreet,
                        ShippingCity:value.serviceAddressAccount.ShippingCity,
                        ShippingState:value.serviceAddressAccount.ShippingState,
                        ShippingPostalCode:value.serviceAddressAccount.ShippingPostalCode,
                        ShippingCountry:value.serviceAddressAccount.ShippingCountry,
                    };
                }
                // Account Completed
                // Site start
                //console.log("===Site start====");
                console.log('Value ::'+JSON.stringify(value));
                var allSitesList =[] ;
                if(value.hasOwnProperty("siteList")){
                    var siteList = value.siteList;
                    if(siteList.length > 0){
                        siteList.forEach(function(siteValue,siteKey){
                            
                            allSitesList.push({ 
                                Account__c: siteValue.Account__c,
                                Id: siteValue.Id,
                                ParentId: parentAccountId,
                                Name: siteValue.Name,
                                Type__c: siteValue.Type__c,
                                Volume__c: siteValue.Volume__c,
                                Unit_of_Measure__c: siteValue.Unit_of_Measure__c,
                                Error : siteValue.Error,
                                errorMessage:siteValue.errorMessage
                            });
                            //siteList[siteKey].Error = 'Success';
                            //siteList[siteKey].errorMessage = '';
                        })
                    }else{
                        allSitesList.push({ 
                            Account__c: '',                        
                            Name: '',
                            ParentId: parentAccountId,
                            Type__c: '',
                            Volume__c: '',
                            Unit_of_Measure__c: '',
                            Error : 'Success',
                            errorMessage:''
                        });
                    }
                }else{
                    allSitesList.push({ Account__c: '',                               
                                       Name: '',
                                       Service_Address_As_Parent__c: '',
                                       Unit_of_Measure__c: '',
                                       Type__c: '',
                                       Volume__c: '',
                                       Error : 'Success',
                                       errorMessage:''
                                      });
                } 
                
                var accountDetails = component.get("v.accountDetails");
                console.log('accountDetails ::'+accountDetails);
                if(accountDetails==null){            
                    component.set("v.accountDetails",parentAccountDetail);
                    accountDetails = parentAccountDetail;
                }
                console.log('accountDetails-2 ::'+JSON.stringify(component.get("v.accountDetails")));
                var newRecord = {
                    parentAccountId:parentAccountId,
                    serviceAddressAccount:serviceAddressAccount,
                    siteList: allSitesList,
                    parentAccountDetail:accountDetails,
                    dependentMap:dependentMap
                }
                
                RowItemList.push(newRecord); 
                
            }) // End of account loop
            console.log('RowItemList = '+ JSON.stringify(RowItemList));
            var DisplayList = [];
            var pageSize = component.get("v.pageSize");
            //alert(RowItemList.length);
            if(RowItemList.length < pageSize){
                pageSize = RowItemList.length;
            }
            for(var i=0; i< pageSize; i++){
                DisplayList.push(RowItemList[i]);    
            }
            console.log('DisplayList = '+ JSON.stringify(DisplayList));
            component.set("v.cardList", DisplayList); 
            component.set("v.cardListFinal",DisplayList);
            component.set("v.FinalcardList",RowItemList);
            component.set("v.loaded",false);
            
        } 
        console.log('FinalcardList=>> '+ JSON.stringify(component.get("v.FinalcardList")));
    },
    /*getAccountDetailsByPage2:function(component, event, helper){
        component.set("v.loaded",true);
        var result = component.get("v.ResultDataPagination");
        console.log("Resultpage ::"+JSON.stringify(result));
        var cardListF = [];
        var RowItemList =[] ;//= component.get("v.cardList");
        var fileData; 
        if(result[0].UploadedFileData){
            fileData = result[0].UploadedFileData;
        }
        if(result[0] && result[0].UploadedFileData && result[0].UploadedFileData != true){
            cardListF = component.get("v.cardListFinal");
        }
        if(result.length){      
            
            result.forEach(function(value,key){
                //For each account
                var parentAccountId = component.get("v.recordId");
                var parentAccountDetail = value.parentAccountDetail;
                var dependentMap = value.dependentMap;
                console.log('dependentMap:: '+JSON.stringify(dependentMap))
                component.set("v.ColumnData",value.DataColumn);
                if(value.hasOwnProperty("parentAccountId")){
                    parentAccountId = value.parentAccountId;           
                }
                var serviceAddressAccount = {
                    Billing_address_same_as_parent__c: false,                
                    Market__c: '',
                    Name: '',
                    //Parent: {Name: '', Id: ''},
                    ParentId: parentAccountId,
                    RecordTypeId: '',
                    Service_address_same_as_parent__c: false,
                    ShippingStreet:'',
                    BillingCity:'',
                    BillingState:'',
                    BillingPostalCode:'',
                    BillingCountry:''
                };
                
                if(value.hasOwnProperty("parentAccountId")){
                    component.set('v.ServiceAddressSame',"true");
                    serviceAddressAccount = {
                        Billing_address_same_as_parent__c: value.serviceAddressAccount.Billing_address_same_as_parent__c,
                        Id: value.serviceAddressAccount.Id,
                        Market__c: value.serviceAddressAccount.Market__c,
                        Name: value.serviceAddressAccount.Name,
                        //Parent: {Name: obj.serviceAddressAccount.Parent.Name, Id: obj.serviceAddressAccount.Parent.Name},
                        ParentId: value.serviceAddressAccount.ParentId,
                        RecordTypeId: value.serviceAddressAccount.RecordTypeId,
                        Service_address_same_as_parent__c: value.serviceAddressAccount.Service_address_same_as_parent__c,
                        ShippingStreet:value.serviceAddressAccount.ShippingStreet,
                        ShippingCity:value.serviceAddressAccount.ShippingCity,
                        ShippingState:value.serviceAddressAccount.ShippingState,
                        ShippingPostalCode:value.serviceAddressAccount.ShippingPostalCode,
                        ShippingCountry:value.serviceAddressAccount.ShippingCountry,
                    };
                }
                // Account Completed
                // Site start
                //console.log("===Site start====");
                console.log('Value ::'+JSON.stringify(value));
                var allSitesList =[] ;
                if(value.hasOwnProperty("siteList")){
                    var siteList = value.siteList;
                    if(siteList.length > 0){
                        siteList.forEach(function(siteValue,siteKey){
                            
                            allSitesList.push({ 
                                Account__c: siteValue.Account__c,
                                Id: siteValue.Id,
                                ParentId: parentAccountId,
                                Name: siteValue.Name,
                                Type__c: siteValue.Type__c,
                                Volume__c: siteValue.Volume__c,
                                Unit_of_Measure__c: siteValue.Unit_of_Measure__c,
                                Error : siteValue.Error,
                                errorMessage:siteValue.errorMessage
                            });
                            //siteList[siteKey].Error = 'Success';
                            //siteList[siteKey].errorMessage = '';
                        })
                    }else{
                        allSitesList.push({ 
                            Account__c: '',                        
                            Name: '',
                            ParentId: parentAccountId,
                            Type__c: '',
                            Volume__c: '',
                            Unit_of_Measure__c: '',
                            Error : 'Success',
                            errorMessage:''
                        });
                    }
                }else{
                    allSitesList.push({ Account__c: '',                               
                                       Name: '',
                                       Service_Address_As_Parent__c: '',
                                       Unit_of_Measure__c: '',
                                       Type__c: '',
                                       Volume__c: '',
                                       Error : 'Success',
                                       errorMessage:''
                                      });
                } 
                
                var accountDetails = component.get("v.accountDetails");
                console.log('accountDetails ::'+accountDetails);
                if(accountDetails==null){            
                    component.set("v.accountDetails",parentAccountDetail);
                    accountDetails = parentAccountDetail;
                }
                console.log('accountDetails-2 ::'+JSON.stringify(component.get("v.accountDetails")));
                var newRecord = {
                    parentAccountId:parentAccountId,
                    serviceAddressAccount:serviceAddressAccount,
                    siteList: allSitesList,
                    parentAccountDetail:accountDetails,
                    dependentMap:dependentMap,
                    UploadedFileData:fileData
                }
                
                RowItemList.push(newRecord); 
                cardListF.push(newRecord);
                
            }) // End of account loop
            component.set("v.cardList", RowItemList); 
                component.set("v.cardListFinal",cardListF);
                component.set("v.loaded",false);
            console.log('RowItemList = '+ JSON.stringify(RowItemList));
            console.log('cardListFinal = '+ JSON.stringify(component.get("v.cardListFinal")));
        }
    },*/
    getAccountDetailsByPage2:function(component, event, helper){
        component.set("v.loaded",true);
        var result = component.get("v.ResultDataPagination");
        console.log("Resultpage ::"+JSON.stringify(result));
        var cardListF = [];
        var RowItemList =[] ;//= component.get("v.cardList");
        var fileData; 
        if(result[0].UploadedFileData){
            fileData = result[0].UploadedFileData;
        }
        if(result[0] && result[0].UploadedFileData && result[0].UploadedFileData != true){
            cardListF = component.get("v.cardListFinal");
        }
        var parentAccountId = component.get("v.recordId");
        var accountDetails = component.get("v.accountDetails");
        
        if(result){   
            for(var i=0; i < result.length; i++){
                var parentAccountDetail = result[i].parentAccountDetail;
                var dependentMap = result[i].dependentMap;
                component.set("v.ColumnData",result[i].DataColumn);
                if(result[i].parentAccountId){
                    parentAccountId = result[i].parentAccountId;
                }
                var serviceAddressAccount = {
                    Billing_address_same_as_parent__c: false,                
                    Market__c: '',
                    Name: '',
                    ParentId: parentAccountId,
                    RecordTypeId: '',
                    Service_address_same_as_parent__c: false,
                    ShippingStreet:'',
                    BillingCity:'',
                    BillingState:'',
                    BillingPostalCode:'',
                    BillingCountry:''
                };
                if(result[i].parentAccountId){
                    component.set('v.ServiceAddressSame',"true");
                    serviceAddressAccount = {
                        Billing_address_same_as_parent__c: result[i].serviceAddressAccount.Billing_address_same_as_parent__c,
                        Id: result[i].serviceAddressAccount.Id,
                        Market__c: result[i].serviceAddressAccount.Market__c,
                        Name: result[i].serviceAddressAccount.Name,
                        ParentId: result[i].serviceAddressAccount.ParentId,
                        RecordTypeId: result[i].serviceAddressAccount.RecordTypeId,
                        Service_address_same_as_parent__c: result[i].serviceAddressAccount.Service_address_same_as_parent__c,
                        ShippingStreet:result[i].serviceAddressAccount.ShippingStreet,
                        ShippingCity:result[i].serviceAddressAccount.ShippingCity,
                        ShippingState:result[i].serviceAddressAccount.ShippingState,
                        ShippingPostalCode:result[i].serviceAddressAccount.ShippingPostalCode,
                        ShippingCountry:result[i].serviceAddressAccount.ShippingCountry,
                    };
                }
                var allSitesList =[] ;
                if(result[i].siteList){
                    var siteList = result[i].siteList;
                    if(siteList.length > 0){
                        for(var j=0; j < siteList.length; j++){
                            allSitesList.push({ 
                                Account__c: siteList[j].Account__c,
                                Id: siteList[j].Id,
                                ParentId: parentAccountId,
                                Name: siteList[j].Name,
                                Type__c: siteList[j].Type__c,
                                Volume__c: siteList[j].Volume__c,
                                Unit_of_Measure__c: siteList[j].Unit_of_Measure__c,
                                Error : siteList[j].Error,
                                errorMessage:siteList[j].errorMessage
                            });
                        }
                    }else{
                        allSitesList.push({ 
                            Account__c: '',                        
                            Name: '',
                            ParentId: parentAccountId,
                            Type__c: '',
                            Volume__c: '',
                            Unit_of_Measure__c: '',
                            Error : 'Success',
                            errorMessage:''
                        });
                    }
                }
                else{
                    allSitesList.push({ Account__c: '',                               
                                       Name: '',
                                       Service_Address_As_Parent__c: '',
                                       Unit_of_Measure__c: '',
                                       Type__c: '',
                                       Volume__c: '',
                                       Error : 'Success',
                                       errorMessage:''
                                      });
                } 
                if(accountDetails == null){            
                    component.set("v.accountDetails",parentAccountDetail);
                    accountDetails = parentAccountDetail;
                }
                
                var newRecord = {
                    parentAccountId:parentAccountId,
                    serviceAddressAccount:serviceAddressAccount,
                    siteList: allSitesList,
                    parentAccountDetail:accountDetails,
                    dependentMap:dependentMap,
                    UploadedFileData:fileData
                }
                
                RowItemList.push(newRecord); 
                cardListF.push(newRecord);
            }
            component.set("v.cardList", RowItemList); 
            component.set("v.cardListFinal",cardListF);
            
            component.set("v.loaded",false);
        }
        /* if(result.length){      
            
            result.forEach(function(value,key){
                //For each account
                var parentAccountId = component.get("v.recordId");
                var parentAccountDetail = value.parentAccountDetail;
                var dependentMap = value.dependentMap;
                console.log('dependentMap:: '+JSON.stringify(dependentMap))
                component.set("v.ColumnData",value.DataColumn);
                if(value.hasOwnProperty("parentAccountId")){
                    parentAccountId = value.parentAccountId;           
                }
                var serviceAddressAccount = {
                    Billing_address_same_as_parent__c: false,                
                    Market__c: '',
                    Name: '',
                    //Parent: {Name: '', Id: ''},
                    ParentId: parentAccountId,
                    RecordTypeId: '',
                    Service_address_same_as_parent__c: false,
                    ShippingStreet:'',
                    BillingCity:'',
                    BillingState:'',
                    BillingPostalCode:'',
                    BillingCountry:''
                };
                
                if(value.hasOwnProperty("parentAccountId")){
                    component.set('v.ServiceAddressSame',"true");
                    serviceAddressAccount = {
                        Billing_address_same_as_parent__c: value.serviceAddressAccount.Billing_address_same_as_parent__c,
                        Id: value.serviceAddressAccount.Id,
                        Market__c: value.serviceAddressAccount.Market__c,
                        Name: value.serviceAddressAccount.Name,
                        //Parent: {Name: obj.serviceAddressAccount.Parent.Name, Id: obj.serviceAddressAccount.Parent.Name},
                        ParentId: value.serviceAddressAccount.ParentId,
                        RecordTypeId: value.serviceAddressAccount.RecordTypeId,
                        Service_address_same_as_parent__c: value.serviceAddressAccount.Service_address_same_as_parent__c,
                        ShippingStreet:value.serviceAddressAccount.ShippingStreet,
                        ShippingCity:value.serviceAddressAccount.ShippingCity,
                        ShippingState:value.serviceAddressAccount.ShippingState,
                        ShippingPostalCode:value.serviceAddressAccount.ShippingPostalCode,
                        ShippingCountry:value.serviceAddressAccount.ShippingCountry,
                    };
                }
                // Account Completed
                // Site start
                //console.log("===Site start====");
                console.log('Value ::'+JSON.stringify(value));
                var allSitesList =[] ;
                if(value.hasOwnProperty("siteList")){
                    var siteList = value.siteList;
                    if(siteList.length > 0){
                        siteList.forEach(function(siteValue,siteKey){
                            
                            allSitesList.push({ 
                                Account__c: siteValue.Account__c,
                                Id: siteValue.Id,
                                ParentId: parentAccountId,
                                Name: siteValue.Name,
                                Type__c: siteValue.Type__c,
                                Volume__c: siteValue.Volume__c,
                                Unit_of_Measure__c: siteValue.Unit_of_Measure__c,
                                Error : siteValue.Error,
                                errorMessage:siteValue.errorMessage
                            });
                            //siteList[siteKey].Error = 'Success';
                            //siteList[siteKey].errorMessage = '';
                        })
                    }else{
                        allSitesList.push({ 
                            Account__c: '',                        
                            Name: '',
                            ParentId: parentAccountId,
                            Type__c: '',
                            Volume__c: '',
                            Unit_of_Measure__c: '',
                            Error : 'Success',
                            errorMessage:''
                        });
                    }
                }
                else{
                    allSitesList.push({ Account__c: '',                               
                                       Name: '',
                                       Service_Address_As_Parent__c: '',
                                       Unit_of_Measure__c: '',
                                       Type__c: '',
                                       Volume__c: '',
                                       Error : 'Success',
                                       errorMessage:''
                                      });
                } 
                
                var accountDetails = component.get("v.accountDetails");
                console.log('accountDetails ::'+accountDetails);
                if(accountDetails==null){            
                    component.set("v.accountDetails",parentAccountDetail);
                    accountDetails = parentAccountDetail;
                }
                console.log('accountDetails-2 ::'+JSON.stringify(component.get("v.accountDetails")));
                var newRecord = {
                    parentAccountId:parentAccountId,
                    serviceAddressAccount:serviceAddressAccount,
                    siteList: allSitesList,
                    parentAccountDetail:accountDetails,
                    dependentMap:dependentMap,
                    UploadedFileData:fileData
                }
                
                RowItemList.push(newRecord); 
                cardListF.push(newRecord);
                
            }) // End of account loop
            component.set("v.cardList", RowItemList); 
            component.set("v.cardListFinal",cardListF);
            component.set("v.loaded",false);
            console.log('RowItemList = '+ JSON.stringify(RowItemList));
            console.log('cardListFinal = '+ JSON.stringify(component.get("v.cardListFinal")));
        }*/
    },
    setParentAccountItemList:function(component, event,helper,parentName){
        var parentAccountItemList = component.get("v.parentAccountList");
        parentAccountItemList.push(parentName);                                
        component.set("v.parentAccountList",parentAccountItemList);
    },
    checkError:function(value1,value2){
        var error = false ;
        var message = '' ; 
        value2.forEach(function(value,key){
            
            console.log("value");
            console.log(JSON.stringify(value.message));
            console.log(JSON.stringify(value.site));
            console.log(JSON.stringify(value1));
            if(
                value.site.Account__c==value1.Account__c &&  
                value.site.Market__c==value1.Market__c &&  
                value.site.Name==value1.Name && 
                value.site.Type__c==value1.Type__c && 
                value.site.Unit_of_Measure__c==value1.Unit_of_Measure__c 
            ){
                message = value.message ;
                console.log("I am here...");
                error = true ;
            }
            
        });
        //alert(JSON.stringify({message:message,error:error}));
        return {message:message,error:error} ;
        
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
    ProcessFileData :  function (component, event, helper,rwData){ 
        component.set("v.loaded",true);
        var parentAccountId = component.get("v.recordId");
        var chunkSize = 10;
        var RowItemList = [];
        var FinalItemList = [];
        var accountDetails = component.get("v.accountDetails");
        console.log('rwData ::'+JSON.stringify(rwData));
        var dependentMap = rwData[0].dependentMap;
        console.log('dependentMap >>'+dependentMap);
        var fileData = rwData[0].UploadedFileData;
        for (var i = 0; i < rwData.length; i++) {
            var allSitesList =[] ;
            var serviceAddressAccount;
            for (var j = 0; j < rwData[i].SiteList.length; j ++) {
                var a = rwData[i].SiteList[j];
                for (var k = 0; k < a.length; k += 10) {
                    console.log(a[k]); 
                    var typeVal = a[7].toLowerCase();
                    typeVal = typeVal[0].toUpperCase() + typeVal.slice(1);
                    serviceAddressAccount = {
                        Name: rwData[i].LocationId,
                        RecordTypeId:  rwData[i].recordTypeId,
                        Billing_address_same_as_parent__c: false,                
                        Market__c: a[0],
                        Service_address_same_as_parent__c: false,
                        ShippingStreet:a[1],
                        ShippingCity:a[2],
                        ShippingState:a[3],
                        ShippingPostalCode:a[4],
                        ShippingCountry:a[5]
                    };
                    
                    allSitesList.push({ 
                        Name: a[6],
                        Type__c: typeVal,
                        Volume__c: a[9],
                        Unit_of_Measure__c: a[8]
                    });
                }
            }
            var newRecord = {
                parentAccountId:parentAccountId,
                serviceAddressAccount:serviceAddressAccount,
                siteList: allSitesList,
                parentAccountDetail:accountDetails,
                dependentMap:dependentMap,
                UploadedFileData:fileData
            }
            RowItemList.push(newRecord); 
            FinalItemList.push(newRecord);
            
        }
        component.set("v.FinalcardList", null);
        component.set("v.ExistingDataList",null);
        component.set("v.FinalcardList", FinalItemList);
        component.set("v.ExistingDataList",FinalItemList);
        console.log('FinalcardList-FileData = '+JSON.stringify(component.get("v.FinalcardList")));
        
        console.log('RowItemList = '+JSON.stringify(RowItemList));
        console.log('FinalItemList = '+JSON.stringify(FinalItemList));
        var pageSize = component.get("v.pageSize");
        var noOfPages = Math.ceil(RowItemList.length/pageSize);
        component.set("v.totalPages", noOfPages);
        var PaginationList = [];
        for(var i=0; i< pageSize; i++){
            PaginationList.push(RowItemList[i]);    
        }
        console.log("PaginationList ::"+JSON.stringify(PaginationList));
        var locList = [];
        var MarkList = [];
        var CityList = [];
        for(var i=0;i<RowItemList.length;i++){
            console.log('serviceAddressAccount ::'+JSON.stringify(RowItemList[i]));
            if(RowItemList[i] && RowItemList[i].serviceAddressAccount && JSON.stringify(RowItemList[i].serviceAddressAccount) != '{}'){
                if(RowItemList[i] && RowItemList[i].serviceAddressAccount && RowItemList[i].serviceAddressAccount.Name != null){
                    locList.push(RowItemList[i].serviceAddressAccount.Name); 
                    console.log('locList :'+locList)
                }
                if(RowItemList[i] && RowItemList[i].serviceAddressAccount && RowItemList[i].serviceAddressAccount.Market__r && RowItemList[i].serviceAddressAccount.Market__r.Name != null){
                    MarkList.push(RowItemList[i].serviceAddressAccount.Market__r.Name);
                    console.log('MarkList :'+MarkList)
                    
                }
                if(RowItemList[i] && RowItemList[i].serviceAddressAccount && RowItemList[i].serviceAddressAccount.ShippingCity != null){
                    CityList.push(RowItemList[i].serviceAddressAccount.ShippingCity);
                    console.log('CityList :'+CityList)
                } 
            }
        }
        
        if(MarkList.length){
            var newMarkList = [...new Set(MarkList)];
            component.set("v.MarketPicklist",newMarkList);
        }
        if(locList.length){
            var newLocationList = [...new Set(locList)];
            component.set("v.LocationPicklist",newLocationList);
        }
        if(CityList.length){
            var newCityList = [...new Set(CityList)];
            component.set("v.CityPicklist",newCityList);
        }
        
        component.set('v.ResultDataPagination', PaginationList);
        helper.generatePageList(component);
        helper.getAccountDetailsByPage2(component, event, helper);
        
        console.log('cardList-FileData = '+JSON.stringify(component.get("v.cardList")));
        
        component.set("v.loaded",false); 
    }, 
    generatePageList : function(component){
        component.set("v.loaded",true);
        var pageNumber = component.get("v.currentPageNumber");
        var pageList = [];
        var totalRecords = component.get("v.totalPages");
        if(totalRecords > 1){ 
            if(totalRecords <= 10){
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
    },
    processMeDoInIt : function(component, event, helper,dataList,pageNumber) {
        component.set("v.loaded",true);
        var name;
        if(pageNumber != ''){
            name = pageNumber;
        }
        var currentPageNumber = parseInt(name);
        component.set("v.currentPageNumber", currentPageNumber);
        //alert('pageNumberCurrent ::'+currentPageNumber);
        helper.generatePageList(component); 
        var cardListVar = dataList;
        console.log('cardListVar::'+JSON.stringify(cardListVar));
        
        console.log('FinalcardList-1::'+JSON.stringify(component.get("v.FinalcardList")));
        
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        
        var start = ((currentPageNumber*pageSize)-pageSize); 
        var end = start + pageSize;
        //alert('start :: ' + start + ' end:: '+ end);
        for(var i=start; i<end; i++){
            if(cardListVar.length > i){
                Paginationlist.push(cardListVar[i]);
                //FinalcardList.push(cardListVar[i]);
            }
        }
        var cardList = component.get("v.cardListFinal");
        console.log('CardListOnChange-1::'+JSON.stringify(cardList));
        var result =  component.get("v.ExistingDataList");  
        console.log('FinalCardListOnChange-1::'+JSON.stringify(result));
        for(var i=0; i < result.length; i++){
            for(var j=0; j < cardList.length; j++){
                if(result[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                    result[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                    result[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                    result[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                    result[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                    result[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                    result[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                    result[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                    result[i].siteList =cardList[j].siteList;
                    // console.log('site ::'+(JSON.stringify(result[i].siteList)));
                }
            } 
        }
        component.set("v.ExistingDataList",result);
        component.set('v.ResultDataPagination', Paginationlist);
        //console.log('FinalcardList-2::'+JSON.stringify(component.get("v.FinalcardList")));
        window.setTimeout(function(){
            helper.getAccountDetailsByPage2(component, event, helper);
        }, 1000
                         );
    },
    handleValueOnNumberChange: function(component, event, helper,currentPage) {
        component.set("v.loaded",true);
        var currentPageNumber = parseInt(currentPage);
        component.set("v.currentPageNumber", currentPageNumber);
        //alert('currentPageNumber :'+currentPageNumber);
        var filteredList = [];
        var existingList = component.get("v.ExistingDataList");
        console.log('existingList-NumberChnge :'+JSON.stringify(existingList));
        var cardList = component.get("v.cardListFinal");
        if(component.get("v.selectedLocation") == '' && component.get("v.selectedMarket") == '' && component.get("v.selectedCity") == ''){
            var result = component.get('v.ExistingDataList');
            console.log('result::'+JSON.stringify(result));
            var cardList = component.get("v.cardListFinal");
            console.log('#######CardList-Save = '+JSON.stringify(cardList));
            for(var i=0; i < result.length; i++){
                for(var j=0; j < cardList.length; j++){
                    if(result[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                        result[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                        result[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                        result[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                        result[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                        result[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                        result[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                        result[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                        result[i].siteList =cardList[j].siteList;
                        // console.log('site ::'+(JSON.stringify(result[i].siteList)));
                    }
                } 
            }
            console.log('resultAfter::'+JSON.stringify(result));
            
            var pageSize = component.get("v.pageSize");
            var noOfPages = Math.ceil(result.length/pageSize);
            component.set("v.totalPages", noOfPages);
            //alert('totalPages :'+noOfPages);
            var start = ((currentPageNumber*pageSize)-pageSize); 
            var end = start + pageSize; 
            //alert('start :'+start);
            //alert('end :'+end);
            var PaginationList = [];
            for(var i=start; i<end; i++){
                if(result.length > i){
                    PaginationList.push(result[i]);   
                }
            }
            component.set('v.ResultDataPagination', PaginationList);
            //alert('PaginationList :'+PaginationList.length);
            helper.generatePageList(component); 
            window.setTimeout(function(){
                helper.getAccountDetailsByPage2(component, event, helper);
            }, 1000
                             );
            
        }
        else if(component.get("v.selectedLocation") != '' && component.get("v.selectedMarket") == '' && component.get("v.selectedCity") == ''){
            
            for(var i=0; i< existingList.length; i++){
                if(existingList[i].serviceAddressAccount && (existingList[i].serviceAddressAccount.Name && existingList[i].serviceAddressAccount.Name == component.get("v.selectedLocation"))){
                    filteredList.push(existingList[i]); 
                }
            }
            
            for(var i=0; i < filteredList.length; i++){
                for(var j=0; j < cardList.length; j++){
                    if(filteredList[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                        filteredList[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                        filteredList[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                        filteredList[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                        filteredList[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                        filteredList[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                        filteredList[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                        filteredList[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                        filteredList[i].siteList =cardList[j].siteList;
                    }
                } 
            }
            console.log('filteredList ::'+JSON.stringify(filteredList));
            console.log('arrayIsEmpty ::'+filteredList.length);
            if(Array.isArray(filteredList) && filteredList.length == 0){
                //component.set("v.loaded",false);
                helper.showInfo(component, event, helper);
                return;
            }else{
                //component.set('v.ResultDataPagination', filteredList);
                var result = filteredList;
                //alert('lenght::'+result.length);
                var pageSize = component.get("v.pageSize");
                //alert('pageSize::'+pageSize);
                var noOfPages = Math.ceil(result.length/pageSize);
                component.set("v.totalPages", noOfPages);
                helper.processMeDoInIt(component, event, helper,filteredList,currentPage);
            }
            
        }
            else if(component.get("v.selectedLocation") == '' && component.get("v.selectedMarket") != '' && component.get("v.selectedCity") == ''){
               
                for(var i=0; i< existingList.length; i++){
                    if(existingList[i].serviceAddressAccount && (existingList[i].serviceAddressAccount.Market__r && existingList[i].serviceAddressAccount.Market__r.Name == component.get("v.selectedMarket"))){
                        filteredList.push(existingList[i]); 
                    }
                }
                for(var i=0; i < filteredList.length; i++){
                    for(var j=0; j < cardList.length; j++){
                        if(filteredList[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                            filteredList[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                            filteredList[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                            filteredList[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                            filteredList[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                            filteredList[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                            filteredList[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                            filteredList[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                            filteredList[i].siteList =cardList[j].siteList;
                        }
                    } 
                }
                console.log('filteredList ::'+JSON.stringify(filteredList));
                console.log('arrayIsEmpty ::'+filteredList.length);
                if(Array.isArray(filteredList) && filteredList.length == 0){
                    //component.set("v.loaded",false);
                    helper.showInfo(component, event, helper);
                    return;
                }
                else{
                    //component.set('v.ResultDataPagination', filteredList);
                    var result = filteredList;
                    //alert('lenght::'+result.length);
                    var pageSize = component.get("v.pageSize");
                    //alert('pageSize::'+pageSize);
                    var noOfPages = Math.ceil(result.length/pageSize);
                    component.set("v.totalPages", noOfPages);
                    helper.processMeDoInIt(component, event, helper,filteredList,currentPage);
                }
            }
                else if(component.get("v.selectedLocation") == '' && component.get("v.selectedMarket") == '' && component.get("v.selectedCity") != ''){
                    // alert('condition-3');
                    for(var i=0; i< existingList.length; i++){
                        if(existingList[i].serviceAddressAccount && (existingList[i].serviceAddressAccount.ShippingCity && existingList[i].serviceAddressAccount.ShippingCity == component.get("v.selectedCity"))){
                            filteredList.push(existingList[i]); 
                        }
                    }
                    for(var i=0; i < filteredList.length; i++){
                        for(var j=0; j < cardList.length; j++){
                            if(filteredList[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                                filteredList[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                                filteredList[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                                filteredList[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                                filteredList[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                                filteredList[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                                filteredList[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                                filteredList[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                                filteredList[i].siteList =cardList[j].siteList;
                            }
                        } 
                    }
                    console.log('filteredList ::'+JSON.stringify(filteredList));
                    console.log('arrayIsEmpty ::'+filteredList.length);
                    if(Array.isArray(filteredList) && filteredList.length == 0){
                        //component.set("v.loaded",false);
                        helper.showInfo(component, event, helper);
                        return;
                    }
                    else{
                        //component.set('v.ResultDataPagination', filteredList);
                        var result = filteredList;
                        //alert('lenght::'+result.length);
                        var pageSize = component.get("v.pageSize");
                        //alert('pageSize::'+pageSize);
                        var noOfPages = Math.ceil(result.length/pageSize);
                        component.set("v.totalPages", noOfPages);
                        helper.processMeDoInIt(component, event, helper,filteredList,currentPage);
                    }
                }
                    else if(component.get("v.selectedLocation") != '' && component.get("v.selectedMarket") != '' && component.get("v.selectedCity") == ''){
                        // alert('condition-4');
                        for(var i=0; i< existingList.length; i++){
                            if(existingList[i].serviceAddressAccount && (existingList[i].serviceAddressAccount.Name && existingList[i].serviceAddressAccount.Name == component.get("v.selectedLocation")) && (existingList[i].serviceAddressAccount.Market__r && existingList[i].serviceAddressAccount.Market__r.Name == component.get("v.selectedMarket"))){
                                filteredList.push(existingList[i]); 
                            }
                        }
                        for(var i=0; i < filteredList.length; i++){
                            for(var j=0; j < cardList.length; j++){
                                if(filteredList[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                                    filteredList[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                                    filteredList[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                                    filteredList[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                                    filteredList[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                                    filteredList[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                                    filteredList[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                                    filteredList[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                                    filteredList[i].siteList =cardList[j].siteList;
                                }
                            } 
                        }
                        console.log('filteredList ::'+JSON.stringify(filteredList));
                        console.log('arrayIsEmpty ::'+filteredList.length);
                        if(Array.isArray(filteredList) && filteredList.length == 0){
                            // component.set("v.loaded",false);
                            helper.showInfo(component, event, helper);
                            return;
                        }
                        else{
                            //component.set('v.ResultDataPagination', filteredList);
                            var result = filteredList;
                            //alert('lenght::'+result.length);
                            var pageSize = component.get("v.pageSize");
                            //alert('pageSize::'+pageSize);
                            var noOfPages = Math.ceil(result.length/pageSize);
                            component.set("v.totalPages", noOfPages);
                            helper.processMeDoInIt(component, event, helper,filteredList,currentPage);
                        }
                    }
                        else if(component.get("v.selectedLocation") == '' && component.get("v.selectedMarket") != '' && component.get("v.selectedCity") != ''){
                            //alert('condition-5');
                            for(var i=0; i< existingList.length; i++){
                                if(existingList[i].serviceAddressAccount && (existingList[i].serviceAddressAccount.Market__r && existingList[i].serviceAddressAccount.Market__r.Name == component.get("v.selectedMarket")) && (existingList[i].serviceAddressAccount.ShippingCity && existingList[i].serviceAddressAccount.ShippingCity == component.get("v.selectedCity"))){
                                    filteredList.push(existingList[i]); 
                                }
                            }
                            for(var i=0; i < filteredList.length; i++){
                                for(var j=0; j < cardList.length; j++){
                                    if(filteredList[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                                        filteredList[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                                        filteredList[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                                        filteredList[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                                        filteredList[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                                        filteredList[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                                        filteredList[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                                        filteredList[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                                        filteredList[i].siteList =cardList[j].siteList;
                                    }
                                } 
                            }
                            console.log('filteredList ::'+JSON.stringify(filteredList));
                            console.log('arrayIsEmpty ::'+filteredList.length);
                            if(Array.isArray(filteredList) && filteredList.length == 0){
                                // component.set("v.loaded",false);
                                helper.showInfo(component, event, helper);
                                return;
                            }
                            else{
                                //component.set('v.ResultDataPagination', filteredList);
                                var result = filteredList;
                                //alert('lenght::'+result.length);
                                var pageSize = component.get("v.pageSize");
                                //alert('pageSize::'+pageSize);
                                var noOfPages = Math.ceil(result.length/pageSize);
                                component.set("v.totalPages", noOfPages);
                                helper.processMeDoInIt(component, event, helper,filteredList,currentPage);
                            }
                        }
                            else if(component.get("v.selectedLocation") != '' && component.get("v.selectedMarket") == '' && component.get("v.selectedCity") != ''){
                                //alert('condition-6');
                                for(var i=0; i< existingList.length; i++){
                                    if(existingList[i].serviceAddressAccount && (existingList[i].serviceAddressAccount.Name && existingList[i].serviceAddressAccount.Name == component.get("v.selectedLocation")) && (existingList[i].serviceAddressAccount.ShippingCity && existingList[i].serviceAddressAccount.ShippingCity == component.get("v.selectedCity"))){
                                        filteredList.push(existingList[i]); 
                                    }
                                }
                                for(var i=0; i < filteredList.length; i++){
                                    for(var j=0; j < cardList.length; j++){
                                        if(filteredList[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                                            filteredList[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                                            filteredList[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                                            filteredList[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                                            filteredList[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                                            filteredList[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                                            filteredList[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                                            filteredList[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                                            filteredList[i].siteList =cardList[j].siteList;
                                        }
                                    } 
                                }
                                console.log('filteredList ::'+JSON.stringify(filteredList));
                                console.log('arrayIsEmpty ::'+filteredList.length);
                                if(Array.isArray(filteredList) && filteredList.length == 0){
                                    //component.set("v.loaded",false);
                                    helper.showInfo(component, event, helper);
                                    return;
                                }
                                else{
                                    //component.set('v.ResultDataPagination', filteredList);
                                    var result = filteredList;
                                    //alert('lenght::'+result.length);
                                    var pageSize = component.get("v.pageSize");
                                    //alert('pageSize::'+pageSize);
                                    var noOfPages = Math.ceil(result.length/pageSize);
                                    component.set("v.totalPages", noOfPages);
                                    helper.processMeDoInIt(component, event, helper,filteredList,currentPage);
                                }
                            }
                                else{
                                    // alert('condition-7');
                                    for(var i=0; i< existingList.length; i++){
                                        if(existingList[i].serviceAddressAccount && (existingList[i].serviceAddressAccount.Name && existingList[i].serviceAddressAccount.Name == component.get("v.selectedLocation")) && (existingList[i].serviceAddressAccount.Market__r && existingList[i].serviceAddressAccount.Market__r.Name == component.get("v.selectedMarket")) && (existingList[i].serviceAddressAccount.ShippingCity && existingList[i].serviceAddressAccount.ShippingCity == component.get("v.selectedCity"))){
                                            filteredList.push(existingList[i]); 
                                        }
                                    }
                                    for(var i=0; i < filteredList.length; i++){
                                        for(var j=0; j < cardList.length; j++){
                                            if(filteredList[i].serviceAddressAccount.Name == cardList[j].serviceAddressAccount.Name){
                                                filteredList[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                                                filteredList[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                                                filteredList[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                                                filteredList[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                                                filteredList[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                                                filteredList[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                                                filteredList[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                                                filteredList[i].siteList =cardList[j].siteList;
                                            }
                                        } 
                                    }
                                    console.log('filteredList ::'+JSON.stringify(filteredList));
                                    console.log('arrayIsEmpty ::'+filteredList.length);
                                    if(Array.isArray(filteredList) && filteredList.length == 0){
                                        //    component.set("v.loaded",false);
                                        helper.showInfo(component, event, helper);
                                        return;
                                    }
                                    else{
                                        //component.set('v.ResultDataPagination', filteredList);
                                        var result = filteredList;
                                        //alert('lenght::'+result.length);
                                        var pageSize = component.get("v.pageSize");
                                        //alert('pageSize::'+pageSize);
                                        var noOfPages = Math.ceil(result.length/pageSize);
                                        component.set("v.totalPages", noOfPages);
                                        helper.processMeDoInIt(component, event, helper,filteredList,currentPage);
                                    }
                                }
        
    },
    checkExisting: function(arr, name) {
        const { length } = arr;
        const found = arr.find(el => el.name === name.name);
        if (!found) arr.push(name);
        return arr;
    },
    showInfo : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info',
            message: 'No data found!',
            duration:' 5000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    
})