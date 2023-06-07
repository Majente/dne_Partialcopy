({
    createObjectData: function(component, event,helper,ParentAccountInstance,rowIndexParent) {
        console.log("rowIndexParent"+rowIndexParent);
        var allSitesList = component.get("v.siteList") ; 
        console.log("allSitesList%%"+JSON.stringify(allSitesList));
        if(ParentAccountInstance != null && ParentAccountInstance.hasOwnProperty("siteList")){
            var siteList = ParentAccountInstance.siteList ;            
            if(siteList.length){
                siteList.forEach(function(value,key){
                    allSitesList.push({ 
                        Account__c: value.Account__c,
                        Id: value.Id,
                        Name: value.Name,  
                        Type__c: value.Type__c,
                        Volume__c: value.Volume__c,
                        Unit_of_Measure__c: value.Unit_of_Measure__c,
                        Error : value.Error,
                        errorMessage:value.errorMessage
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
        
        component.set("v.siteList",allSitesList) ;
        console.log('siteList ####>>>>> '+JSON.stringify(component.get("v.siteList")));
        var cardList =component.get('v.cardList');
        console.log('cardList ####>>>>> '+JSON.stringify(cardList));
        var siteLength = cardList[rowIndexParent].siteList.length;
        cardList[rowIndexParent].siteList=allSitesList;
        
        if(allSitesList.length!=siteLength){
            component.set('v.cardList',cardList);
        }
        console.log('cardList-afterSet ####>>>>> '+JSON.stringify(component.get('v.cardList')));
        //alert('card-List-lenght:'+component.get('v.cardList').length);
        var finalCardList =component.get('v.FinalcardList');
        console.log('finalCardList ####>>>>> '+JSON.stringify(finalCardList));
        
        var siteArray = [];
        var Length;
        for (var i = 0; i < finalCardList.length; i++) {
            if(finalCardList[i].serviceAddressAccount && finalCardList[i].serviceAddressAccount.Name && cardList[rowIndexParent].serviceAddressAccount && finalCardList[i].serviceAddressAccount.Name == cardList[rowIndexParent].serviceAddressAccount.Name){
                Length = finalCardList[i].siteList.length;
                console.log('Length ####>>>>> '+Length);
                finalCardList[i].siteList=allSitesList;
            }
        }
        
        console.log('allSitesList-Length ####>>>>> '+allSitesList.length);
        if(allSitesList.length != Length){
            component.set('v.FinalcardList',finalCardList);
            component.set("v.ExistingDataList",finalCardList);
        }
        console.log('FinalcardList ##Site =>'+JSON.stringify(component.get('v.FinalcardList')));
        /*var accounDetails = component.get("v.accounDetails") ;
        
		var parentId = component.get("v.accounDetails.Id") ;   
        var recordTypeId = component.get("v.accounDetails.recordTypeId") ; 
        // get the accountList from component and add(push) New Object to List  
        var RowItemList = component.get("v.accountList");        
        
        var parentAccountItemList = [] ;
        parentAccountItemList.push(accounDetails.Name);
        RowItemList.forEach(function(item,key){           
            parentAccountItemList.push(item.acc.Name); 
        });
        component.set("v.parentAccountList",parentAccountItemList);   
        
        var bilingAddress ='' ;
        if(component.get("v.accounDetails.Billing_address_same_as_parent__c")){
        	bilingAddress = component.get("v.accounDetails.BillingAddress.street") 
        					+", "+component.get("v.accounDetails.BillingAddress.city") 
        					+", "+component.get("v.accounDetails.BillingAddress.state") 
        					+", "+component.get("v.accounDetails.BillingAddress.country")
        					+", "+component.get("v.accounDetails.BillingAddress.postalCode");
        }	
        
        var shippingAddress = '' ;
        if(component.get("v.accounDetails.Service_address_same_as_parent__c")){
			shippingAddress = component.get("v.accounDetails.ShippingAddress.street") 
        					+", "+component.get("v.accounDetails.ShippingAddress.city") 
        					+", "+component.get("v.accounDetails.ShippingAddress.state") 
        					+", "+component.get("v.accounDetails.ShippingAddress.country")
        					+", "+component.get("v.accounDetails.ShippingAddress.postalCode");
        }
        
        var accObj = {
            'sobjectType': 'Account',
            'ParentId': '',            
            'Billing_address_same_as_parent__c':false,
            'Service_address_same_as_parent__c':false,
            'recordTypeId': recordTypeId,
            'Name': '',
            'Business_Size__c': '',
            'BillingAddress': bilingAddress,
            'ShippingAddress': shippingAddress,
            'Total_Annual_Volume_Gas__c': '',
            'Total_Annual_Volume_ElectrictIy__c': '',
            'BillingStreet': '',
            'BillingCity': '',
            'BillingState': '',
            'BillingPostalCode': '',
            'BillingCountry':''
        };
        
        RowItemList.push({acc:accObj,parentName:''});
        // set the updated list to attribute (accountList) again    
        component.set("v.accountList", RowItemList);
        */
        
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
            accId:accountid
        });        
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state=='SUCCESS'){
                var result = response.getReturnValue() ;
                //alert(JSON.stringify(result));
                //console.log(JSON.stringify(result));
                if(result.acc==null || result.acc.Market__c==undefined){
                    helper.showToastError(component, event, helper);
                    $A.get("e.force:closeQuickAction").fire();
                    return;
                }                
                component.set("v.accounDetails",result.acc);                
                helper.setParentAccountItemList(component, event,helper,result.acc.Name) ;                
                helper.createObjectData(component, event,helper);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    setParentAccountItemList:function(component, event,helper,parentName){
        var parentAccountItemList = component.get("v.parentAccountList");
        parentAccountItemList.push(parentName);                                
        component.set("v.parentAccountList",parentAccountItemList);
    }
})