({
    
    createObjectData: function(component, event,helper,obj) {
        var RowItemList = component.get("v.cardList"); 
        
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
                Market__c: obj[0].serviceAddressAccount.Market__c,
                //Name: obj[0].serviceAddressAccount.Name,
                //Parent: {Name: obj.serviceAddressAccount.Parent.Name, Id: obj.serviceAddressAccount.Parent.Name},
                ParentId: obj[0].serviceAddressAccount.ParentId,
                RecordTypeId: obj[0].serviceAddressAccount.RecordTypeId,
                Service_address_same_as_parent__c: obj[0].serviceAddressAccount.Service_address_same_as_parent__c,
                //ShippingStreet:obj[0].serviceAddressAccount.ShippingStreet,
                //ShippingCity:obj[0].serviceAddressAccount.ShippingCity,
                ShippingState:obj[0].serviceAddressAccount.ShippingState,
                //ShippingPostalCode:obj[0].serviceAddressAccount.ShippingPostalCode,
                ShippingCountry:obj[0].serviceAddressAccount.ShippingCountry,
            };
        }
        
        var siteList = obj[0].siteList ;
        var parentAccountDetail = obj[0].parentAccountDetail ;
        var allSitesList =[] ;
        if(obj[0].hasOwnProperty("siteList")){
            if(siteList.length){
                //siteList.forEach(function(value,key){
                
                allSitesList.push({ 
                    Account__c: siteList.Account__c,
                    Id: siteList.Id,
                    ParentId: parentAccountId,
                    Name: siteList.Name,
                    Type__c: siteList.Type__c,
                    Volume__c: siteList.Volume__c,
                    Unit_of_Measure__c: siteList.Unit_of_Measure__c,
                    Error : siteList.Error,
                    errorMessage:siteList.errorMessage
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
        
        var newRecord = {
            parentAccountId:parentAccountId,
            serviceAddressAccount:serviceAddressAccount,
            siteList:allSitesList,
            parentAccountDetail:accountDetails
        }
        
        RowItemList.push(newRecord);
        component.set("v.cardList", RowItemList);  
        console.log('RowItemList = '+JSON.stringify(RowItemList));
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
    getAccountDetails:function(component, event, helper){
        
        var action = component.get("c.getAccountDetail");
        var accountid = component.get("v.recordId");
        action.setParams({
            parentAccId:accountid
        });        
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state=='SUCCESS'){
                var RowItemList = component.get("v.cardList");
                var result = response.getReturnValue() ;
                console.log("Result ::"+JSON.stringify(result));
                
                component.set("v.ResultData",result);
                //component.set("v.ColumnData",result.DataColumn);
                if(result.length){                    
                    result.forEach(function(value,key){
                        //For each account
                        var parentAccountId = component.get("v.recordId");
                        var parentAccountDetail = value.parentAccountDetail ;
                        component.set("v.ColumnData",value.DataColumn);
                        if(value.hasOwnProperty("parentAccountId")){
                            parentAccountId = value.parentAccountId;;            
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
                        
                        if(accountDetails==null){            
                            component.set("v.accountDetails",parentAccountDetail);
                            accountDetails = parentAccountDetail;
                        }
                        
                        var newRecord = {
                            parentAccountId:parentAccountId,
                            serviceAddressAccount:serviceAddressAccount,
                            siteList: allSitesList,
                            parentAccountDetail:accountDetails
                        }
                        RowItemList.push(newRecord); 
                        
                    }) // End of account loop
                    
                    component.set("v.cardList", RowItemList);  
                    console.log('RowItemList = '+RowItemList);
                    
                }
                /*
                jQuery(document).ready(function(){
                    setTimeout(function(){
                        var asasas = $(".slds-text-heading--medium") ; 
                        //console.log(asasas);
                        $(".modal-header").find("h2").html('gbd sansi'); 
                        //console.log('changetitle');
                    }, 8000);
        	
        		}); */
            }
            
            
            
        });
        $A.enqueueAction(action);
        //document.getElementById("acc_site_spinner").style.display = "none";  
    },
    getAccountDetails2:function(component, event, helper,obj){
        
        var action = component.get("c.getAccountDetail");
        var accountid = component.get("v.recordId");
        action.setParams({
            parentAccId:accountid
        });        
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state=='SUCCESS'){
                var RowItemList = component.get("v.cardList");
                var result = response.getReturnValue() ;
                console.log("Result ::"+JSON.stringify(result));
                //alert("Result ::"+JSON.stringify(result));
                //alert(JSON.stringify(result.length));
                
                if(result.length){   
                    
                    result.forEach(function(value,key){
                        //For each account
                        var parentAccountId = component.get("v.recordId");
                        var parentAccountDetail = value.parentAccountDetail ;
                        if(value.hasOwnProperty("parentAccountId")){
                            parentAccountId = value.parentAccountId;;            
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
                                //Name: value.serviceAddressAccount.Name,
                                //Parent: {Name: obj.serviceAddressAccount.Parent.Name, Id: obj.serviceAddressAccount.Parent.Name},
                                ParentId: value.serviceAddressAccount.ParentId,
                                RecordTypeId: value.serviceAddressAccount.RecordTypeId,
                                Service_address_same_as_parent__c: value.serviceAddressAccount.Service_address_same_as_parent__c,
                                //ShippingStreet:value.serviceAddressAccount.ShippingStreet,
                                //ShippingCity:value.serviceAddressAccount.ShippingCity,
                                ShippingState:value.serviceAddressAccount.ShippingState,
                                //ShippingPostalCode:value.serviceAddressAccount.ShippingPostalCode,
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
                                //siteList.forEach(function(siteValue,siteKey){
                                
                                allSitesList.push({ 
                                    Account__c: siteList.Account__c,
                                    Id: siteList.Id,
                                    ParentId: parentAccountId,
                                    Name: siteList.Name,
                                    Type__c: siteList.Type__c,
                                    Volume__c: siteList.Volume__c,
                                    Unit_of_Measure__c: siteList.Unit_of_Measure__c,
                                    Error : siteList.Error,
                                    errorMessage:siteList.errorMessage
                                });
                                //siteList[siteKey].Error = 'Success';
                                //siteList[siteKey].errorMessage = '';
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
                        
                        var newRecord = {
                            parentAccountId:parentAccountId,
                            serviceAddressAccount:serviceAddressAccount,
                            siteList: allSitesList,
                            parentAccountDetail:accountDetails
                        }
                        RowItemList.push(newRecord); 
                        
                    }) // End of account loop
                    
                    
                    component.set("v.cardList", RowItemList);  
                    console.log(JSON.stringify('RowItemList2 = '+RowItemList));
                    
                }
                /*
                jQuery(document).ready(function(){
                    setTimeout(function(){
                        var asasas = $(".slds-text-heading--medium") ; 
                        //console.log(asasas);
                        $(".modal-header").find("h2").html('gbd sansi'); 
                        //console.log('changetitle');
                    }, 8000);
        	
        		}); */
            }
            
            
            
        });
        $A.enqueueAction(action);
        //document.getElementById("acc_site_spinner").style.display = "none";  
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
        var RowItemList = component.get("v.cardList");
        var accountDetails = component.get("v.accountDetails");
        console.log('rwData ::'+rwData);
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
                parentAccountDetail:accountDetails
            }
            RowItemList.push(newRecord); 
        }
        component.set("v.cardList", RowItemList);  
        console.log('RowItemList = '+JSON.stringify(RowItemList));
        component.set("v.loaded",false); 
    }, 
    
})