({
    
    // function call on component Load
    doInit: function(component, event, helper) {
        //alert("v.SpinnerLoad :"+component.get("v.SpinnerLoad"));
        
        console.log('cardList >>>> '+JSON.stringify(component.get("v.cardList")));
        console.log('depnedentFieldMap:: '+JSON.stringify(component.get('v.depnedentFieldMap')));
        var result = component.get("v.ExistingDataList");
        
        //console.log("result ::"+JSON.stringify(result));
        var RowItemList =[] ;
        var fileData; 
        if(result[0].UploadedFileData){
            fileData = result[0].UploadedFileData;
        }
        var parentAccountId = component.get("v.recordId");
        var accountDetails = component.get("v.accountDetails");
        if(result){   
            for(var i=0; i < result.length; i++){
                //For each account
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
                        Market__r: result[i].serviceAddressAccount.Market__r,
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
                
            } // End of account loop
            console.log('RowItemList = '+ JSON.stringify(RowItemList));
            component.set("v.FinalcardList",RowItemList);
        }
        
        console.log('FinalcardList-Site=>> '+ JSON.stringify(component.get("v.FinalcardList")));     
        var ParentAccountInstance = component.get("v.ParentAccountInstance");
        //console.log("ParentAccountInstance");
        //console.log(JSON.stringify(ParentAccountInstance));
        var rowIndexParent = component.get("v.rowIndexParent");
        //alert('rowIndexParent:'+rowIndexParent);
        
        //window.setTimeout(function(){
        helper.createObjectData(component, event, helper,ParentAccountInstance,rowIndexParent); 
        console.log('siteList = '+JSON.stringify(component.get("v.siteList")));
        //    }, 100
        //);
        
    },
    
    // function for save the Records 
    Save: function(component, event, helper) {
        // first call the helper function in if block which will return true or false.
        // this helper function check the "first Name" will not be blank on each row.
        if (helper.validateRequired(component, event)) {
            // call the apex class method for save the Contact List
            // with pass the contact List attribute to method param.  
            var action = component.get("c.saveAccounts");
            var accId = component.get("v.recordId");
            //console.log(component.get("v.accountList"));
            action.setParams({
                ListAccounts: component.get("v.accountList"),
                accId:accId
            });
            
            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // if response if success then reset/blank the 'accountList' Attribute 
                    component.set("v.accountList", []);
                    helper.createObjectData(component, event);
                    $A.get("e.force:closeQuickAction").fire();
                    //helper.showToast(component, event, helper);
                    $A.get('e.force:refreshView').fire();
                    
                }else{
                    //alert(JSON.stringify(response.getError()));
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
        }
    },
    
    // function for create new object Row in Contact List 
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        var rowIndexParent = event.getParam("rowParentIndex");
        
        console.log("rowIndexParent======"+rowIndexParent);        
        helper.createObjectData(component, event, helper,'',rowIndexParent); 
        console.log('###### $$$$$$$$$$$$$$ '+component.get("v.typeslist")[0].value);
        
        var cardlst = component.get("v.cardList");
        console.log('###### cardlst '+JSON.stringify(cardlst));
        
        cardlst.forEach(function(value,key){
            var allSitesList = cardlst[key].siteList;
            allSitesList.forEach(function(value1,key1){
                if(allSitesList[key1].Type__c == '' || allSitesList[key1].Type__c == null){
                    allSitesList[key1].Type__c = component.get("v.typeslist")[0].value;
                }
                if(allSitesList[key1].Unit_of_Measure__c == '' || allSitesList[key1].Unit_of_Measure__c == null){
                    allSitesList[key1].Unit_of_Measure__c = component.get("v.units")[0].value;
                }
            });
            cardlst[key].siteList = allSitesList;
        });
        component.set('v.cardList',cardlst);
        console.log('###### cardlst-after  '+JSON.stringify(cardlst));
        
        var finalcardlst = component.get("v.FinalcardList");
        console.log('###### finalcardlst-beforeAddSite '+JSON.stringify(component.get("v.FinalcardList")));
        finalcardlst.forEach(function(value,key){
            var allSitesfinalList = finalcardlst[key].siteList;
            allSitesfinalList.forEach(function(value1,key1){
                if(allSitesfinalList[key1].Type__c == '' || allSitesfinalList[key1].Type__c == null){
                    allSitesfinalList[key1].Type__c = component.get("v.typeslist")[0].value;
                }
                if(allSitesfinalList[key1].Unit_of_Measure__c == '' || allSitesfinalList[key1].Unit_of_Measure__c == null){
                    allSitesfinalList[key1].Unit_of_Measure__c = component.get("v.units")[0].value;
                }
            });
            finalcardlst[key].siteList = allSitesfinalList;
            console.log('###### allSitesfinalList '+JSON.stringify(component.get('v.allSitesfinalList')));
        });
        component.set('v.FinalcardList',finalcardlst);
        console.log('###### finalcardlst-afterAddSite '+JSON.stringify(component.get('v.FinalcardList')));
    },
    // function for create new object Row in Contact List 
    AddNewRowParent: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List 
        
        var cardIndex = component.get("v.cardIndex");
        
        cardIndex = cardIndex +1 ;
        
        component.set("v.cardIndex",cardIndex);
        component.getEvent("AddNewAccountSiteEvtParent").setParams({indexVarParent:cardIndex}).fire();
    },
    removeRowParent: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List 
        console.log(component.get("v.rowIndexParent"));
        component.getEvent("DeleteAccountSiteEvtParent").setParams({"indexVarParent" : component.get("v.rowIndexParent") }).fire();
    },
    
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        
        // get the all List (accountList attribute) and remove the Object Element Using splice method    
        var cardvarList =component.get("v.cardList");
        console.log('BeforeDelete-CardList ##'+JSON.stringify(cardvarList));
        var rowIndex = component.get("v.rowIndexParent");
        console.log('BeforeDelete-rowIndexParent ##'+JSON.stringify(rowIndex));
        var AllRowsList = cardvarList[rowIndex].siteList;
        console.log('SiteList ##'+JSON.stringify(AllRowsList));
        var AllFinalcardList = component.get("v.FinalcardList");
        console.log('BeforeSIte-AllFinalcardList => '+JSON.stringify(AllFinalcardList));
        for (var i = 0; i < AllFinalcardList.length; i++) {
            for(var j= 0; j < AllFinalcardList[i].siteList.length; j++){
                if(AllFinalcardList[i].siteList[j].Id == AllRowsList[index].Id){
                    console.log('siteList[j].Account :: '+AllFinalcardList[i].siteList[j].Id+' => '+ 'AllRowsList[index].Account :: '+AllRowsList[index].Id);
                    console.log('siteList[j].SiteList :: '+JSON.stringify(AllFinalcardList[i].siteList[j]));
                    AllFinalcardList[i].siteList;
                    console.log('AfterSplice => '+JSON.stringify(AllFinalcardList));
                    break;
                }
            }
        }	
        console.log('AllRowsList ##'+JSON.stringify(AllRowsList));
        AllRowsList.splice(index, 1);
        console.log('AllFinalcardList => '+JSON.stringify(AllFinalcardList));
        // set the accountList after remove selected row element 
        component.set("v.siteList", AllRowsList);
        
        if(component.get("v.siteList").length == 0){
            //var rowIndexParent = event.getParam("rowParentIndex");
            //helper.createObjectData(component, event, helper,'',rowIndexParent); 
            AllRowsList.push({ 
                Account__c: '',                        
                Name: '',  
                Type__c: '',
                Volume__c: '',
                Unit_of_Measure__c: '',
                sobjectType:'Site__c',
                Error:'Success',
                errorMessage:''
            });
        }
        
        /*var accounDetails = component.get("v.accounDetails") ;
        var parentAccountItemList = [] ;
        parentAccountItemList.push(accounDetails.Name);
        AllRowsList.forEach(function(item,key){           
            parentAccountItemList.push(item.Name); 
        });
        component.set("v.parentAccountList",parentAccountItemList);
        */
        
        
        cardvarList[rowIndex].siteList= AllRowsList;
        component.set('v.cardList',cardvarList);
        console.log('AfterSetCardList => '+JSON.stringify(component.get("v.cardList")));
        component.set('v.siteList',AllRowsList);
        component.set('v.FinalcardList',AllFinalcardList);
        component.set("v.ExistingDataList",AllFinalcardList);
    }, 
    sameddress: function(component, event, helper) {
        var sameAddress = component.get("v.ParentAccountInstance.serviceAddressAccount.Service_address_same_as_parent__c");
        component.set("v.sameAddress.ShippingStreet",'');
        component.set("v.sameAddress.ShippingCity",'');
        component.set("v.sameAddress.ShippingState",'');
        component.set("v.sameAddress.ShippingPostalCode",'');
        component.set("v.sameAddress.ShippingCountry",'');
        /*var sameAddrs = component.get("v.ServiceAddressSame");
        var accountDetails1 = component.get("v.accountDetails");
        console.log('accountDetails = '+JSON.stringify(accountDetails1));
        if(sameAddrs){
            //component.set("v.sameAddress",null) ;
            component.set("v.sameAddress",accountDetails1) ;
            console.log('######## '+JSON.stringify(component.get("v.sameAddress")));
        }*/
    },
    updaeSiteList: function(component, event, helper) {
        console.log("application event called");
        //alert(event.getParam('cardList'));
    },
    onCardListChange:function(component, event, helper) {
        var ParentAccountInstance = component.get("v.ParentAccountInstance");
        //console.log("ParentAccountInstance");
        //console.log(JSON.stringify(ParentAccountInstance));
    },
    openSiteCMP: function(component, event, helper) {
        console.log(component.get("v.rowIndexParent"));
        var index = component.get("v.rowIndexParent");
        var cardList = component.get("v.cardList");
        console.log('cardList-SA :'+cardList[index].serviceAddressAccount.Id);
        var recordId = cardList[index].serviceAddressAccount.Id;
        window.open('/lightning/cmp/c__AddSitePopUPPagination?c__recordId='+recordId);
    },
    
})