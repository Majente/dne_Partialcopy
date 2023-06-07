({
    
    // function call on component Load
    doInit: function(component, event, helper) {
        //alert(component.get('v.typeslist'));
        // create a Default RowItem [Contact Instance] on first time Component Load
        // by call this helper function 
        //helper.getAccountDetails(component, event, helper);     
        var ParentAccountInstance = component.get("v.ParentAccountInstance");
        //console.log("ParentAccountInstance");
        //console.log(JSON.stringify(ParentAccountInstance));
        
        var rowIndexParent = component.get("v.rowIndexParent");
        
        helper.createObjectData(component, event, helper,ParentAccountInstance,rowIndexParent); 
        console.log('siteList = '+JSON.stringify(component.get("v.siteList")));
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
         
      	component.getEvent("DeleteAccountSiteEvtParent").setParams({"indexVarParent" : component.get("v.rowIndexParent") }).fire();
    },
    
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
		
        // get the all List (accountList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.siteList");
        AllRowsList.splice(index, 1);
        
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
        
        var cardList =component.get('v.cardList');
        var rowIndex = component.get("v.rowIndexParent");
        cardList[rowIndex].siteList=AllRowsList;
        //component.set('v.cardList',cardList);
        component.set('v.siteList',AllRowsList);
        var siteList = component.get('v.siteList');
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
        alert(event.getParam('cardList'));
    },
    onCardListChange:function(component, event, helper) {
    	var ParentAccountInstance = component.get("v.ParentAccountInstance");
        //console.log("ParentAccountInstance");
        //console.log(JSON.stringify(ParentAccountInstance));
    }
    
})