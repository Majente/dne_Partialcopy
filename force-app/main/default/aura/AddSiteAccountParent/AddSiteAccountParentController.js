({
    
    // function call on component Load
    doInit: function(component, event, helper) {
        // create a Default RowItem [Contact Instance] on first time Component Load
        // by call this helper function 
        
        helper.getAccountDetails(component, event, helper); 
        
        /*jQuery(document).ready(function(){
            setTimeout(function(){
                var asasas = $(".slds-text-heading--medium") ; 
                console.log(asasas);
                $(".modal-header").find("h2").html('gbd sansi'); 
                console.log('changetitle');
            }, 8000);
        	
        });*/
    },
    loadJquery: function(component, event, helper) {
        //alert('jquery loaded ');
        jQuery(document).load(function(){
            alert('here....');
            $(".slds-text-heading--medium").html('gbd sansi');
        });
    },
    // function for save the Records 
    Save: function(component, event, helper) {
        component.set("v.loaded",true);
        var action = component.get("c.saveAccounts");
        var accId = component.get("v.recordId");
        var cList = component.get("v.cardList");
        console.log('#######cList = '+JSON.stringify(cList));
        // alert('#######cList = '+JSON.stringify(cList));
        var uniqueArray = [];
        
        for(i=0; i < cList.length; i++){
            if(cList[i].serviceAddressAccount.Name == '' || cList[i].serviceAddressAccount.Name == null){
                component.set("v.loaded",false);
                return helper.showMsg("Name of Service Address is missing.", "error");
            }            
            for(var k=1;k<cList.length; k++){
                if(cList[k].serviceAddressAccount.Name != '' && cList[k].serviceAddressAccount.Name != null && i != k){
                    
                    if(cList[i].serviceAddressAccount.Name == cList[k].serviceAddressAccount.Name){                         
                        $("#"+i).addClass('Error');
                        $("#"+k).addClass('Error');
                         component.set("v.loaded",false);
                        return helper.showMsg("Duplicate Service Address is not allowed. "+cList[i].serviceAddressAccount.Name, "error");
                  
                    }else{
                        $("#"+i).removeClass('Error');
                        $("#"+k).removeClass('Error'); 
                    }
                }
            }
            
            if(cList[i].serviceAddressAccount.Market__c == '' || cList[i].serviceAddressAccount.Market__c == null){
                console.log('serviceAddressAccount58:: '+JSON.stringify(cList[i].serviceAddressAccount))
                component.set("v.loaded",false);
                return helper.showMsg("Market is missing .", "error");
                 
            }
            // alert(cList[i].siteList[i].Type__c);
            for(var j=0; j < cList[i].siteList.length; j++)
            {
                console.log('Site type :: ' + cList[i].siteList[j].Unit_of_Measure__c);
                //alert('Site UOM :: ' + cList[i].siteList[j].Unit_of_Measure__c);
                if(cList[i].siteList[j].Name != '' && (cList[i].siteList[j].Type__c == '' || cList[i].siteList[j].Type__c == null || cList[i].siteList[j].Type__c == '--- None ---')){
                    component.set("v.loaded",false);
                    return helper.showMsg("Type of Site is missing.", "error");
                     
                }  
                if(cList[i].siteList[j].Name != '' && (cList[i].siteList[j].Volume__c == '' || cList[i].siteList[j].Volume__c == null)){
                   component.set("v.loaded",false);
                    return helper.showMsg("Volume is missing.", "error");
                     
                } 
                if(cList[i].siteList[j].Name != '' && (cList[i].siteList[j].Unit_of_Measure__c == '' || cList[i].siteList[j].Unit_of_Measure__c == null || cList[i].siteList[j].Unit_of_Measure__c == '--- None ---')){
                   component.set("v.loaded",false);
                    return helper.showMsg("Unit of Measure is missing.", "error");
                     
                }
            }
            
            var marketVal = cList[i].serviceAddressAccount.Market__c;
            marketVal = (marketVal == null || marketVal == undefined) ? '' : marketVal ;
            var uniqueKey = cList[i].serviceAddressAccount.Name + '-' + marketVal;
            if(uniqueArray.indexOf(uniqueKey) === -1) {
                uniqueArray.push(uniqueKey);
            }
        }
        
        if(uniqueArray.length != cList.length){
            var uniqueServiceAddress =  uniqueArray[0];
            //uniqueServiceAddress = "'"+uniqueServiceAddress.substring(0, uniqueServiceAddress.indexOf('-'))+"'";
            //  return helper.showMsg("Duplicate service address is not allow. "+JSON.stringify(commonNameArray), "error");
            
        }
        var errorFlag = false;
        for(var i = 0; i < cList.length; i++){ 
            var mar =  cList[i].serviceAddressAccount.Market__c;
            if(Array.isArray(mar)){
                cList[i].serviceAddressAccount.Market__c = mar[0];               
            }
        }
        component.set("v.cardList",cList);
        if(errorFlag){
            return false;
        }
        
        console.log('############## '+JSON.stringify(component.get("v.cardList")));
        action.setParams({
            ListAccounts: JSON.stringify(component.get("v.cardList")),
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
                
                var cardListDatas = component.get("v.cardList");
                console.log('cardListDatas = '+JSON.stringify(cardListDatas));
                
                if(result.length>0){
                    for(var i = 0; i < result.length; i++){
                        if(result[i].flag){
                            //dupSite = true;
                            for(var j = 0; j < cardListDatas.length; j++){
                                var SiteListDatas = cardListDatas[j].siteList;
                                var marketVal = cardListDatas[j].serviceAddressAccount.Market__c == '' || cardListDatas[j].serviceAddressAccount.Market__c == undefined ? null : cardListDatas[j].serviceAddressAccount.Market__c;
                                var sKey = cardListDatas[j].serviceAddressAccount.Name+marketVal;
                                
                                for(var k = 0; k < SiteListDatas.length; k++){
                                    //alert('sKey = '+sKey);                                
                                    if(result[i].site.Name == SiteListDatas[k].Name
                                       && result[i].site.Account__c == SiteListDatas[k].Account__c && result[i].site.Market__c == SiteListDatas[k].Market__c
                                       && result[i].site.Type__c == SiteListDatas[k].Type__c && result[i].site.Unit_of_Measure__c == SiteListDatas[k].Unit_of_Measure__c
                                       && result[i].serviceAddress == sKey){
                                        // alert('in if');
                                        //dupSite = false;
                                        SiteListDatas[k].Error = 'Error' ;  
                                        SiteListDatas[k].errorMessage = result[i].message; 
                                    }else{
                                        SiteListDatas[k].Error = '' ;  
                                        SiteListDatas[k].errorMessage = '';
                                    }
                                }
                                cardListDatas[j].siteList = SiteListDatas;
                                component.set("v.cardList",cardListDatas);
                                component.set("v.loaded",false);
                            }
                            
                            //used to show the duplicate site error message if site's acc is Different
                            /* if(result[i].site.Name != null && dupSite){
                                if(dupSiteErrorMsg == null)
                                {
                                   dupSiteErrorMsg = result[i].message+': '+result[i].site.Name;
                                } 
                                else{
                                    dupSiteErrorMsg += ','+result[i].site.Name;
                                }
                            }*/
                        }
                    }
                }else{
                    $A.get("e.force:closeQuickAction").fire();                
                    $A.get('e.force:refreshView').fire(); 
                }
                /*   if(dupSiteErrorMsg != null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type":"Error",
                        "message": dupSiteErrorMsg
                    });
                    toastEvent.fire(); 
                }  */
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
    
    // function for create new object Row in Contact List 
    addNewRowParent: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List
        var index = event.getParam("indexVarParent");  
        
        console.log("here ....+ ="+index);
        var resultD = component.get("v.ResultData");
        helper.createObjectData(component, event, helper,resultD);
        //helper.getAccountDetails2(component, event, helper,index); 
    },
    
    // function for delete the row 
    removeDeletedRowParent: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVarParent");
        component.set("v.loaded",true);
        console.log("index:::"+index);
        
        // get the all List (accountList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.cardList");
        AllRowsList.splice(index, 1);
        // set the accountList after remove selected row element  
        console.log("AllRowsList:::"+AllRowsList.length);
        if(AllRowsList.length == 0){
            var parentAccountId =component.get("v.recordId");
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
            var allSitesList = {
                Account__c: '',                               
                Name: '',
                Service_Address_As_Parent__c: '',
                Unit_of_Measure__c: '',
                Type__c: '',
                Volume__c: ''
            };
            AllRowsList = {
                parentAccountId:parentAccountId,
                serviceAddressAccount:serviceAddressAccount,
                siteList:allSitesList
            }
            component.set("v.loaded",false);
        }
        component.set("v.loaded",false);
        component.set("v.cardList", null); 
        component.set("v.cardList", AllRowsList); 
        //alert(component.get("v.cardList"));
        //console.log('################## '+component.get("v.cardList"));
        
    }, 
    handleClose : function(component, event, helper) {
        //$A.get('e.force:refreshView').fire();
        /*var sobjectName = component.get('v.sObjectName');
    	var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "scope": sobjectName
        });
        navEvent.fire(); */
        $A.get('e.force:closeQuickAction').fire();
        //location.reload();
    },
    
    redirectToListView: function(component,event,helper){
        $A.get('e.force:refreshView').fire();
        $A.get('e.force:closeQuickAction').fire();
        /*var sobjectName = component.get('v.sObjectName');
    	var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "scope": sobjectName
        });
        navEvent.fire();*/
    },
    showFileData :  function (component, event, helper){ 
        component.set("v.loaded",true);
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        var parentAccountId = component.get("v.recordId");
        var RowItemList = component.get("v.cardList");
        var accountDetails = component.get("v.accountDetails");
        var batchSize = 0;
        if (file) {
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "base64");
            reader.onerror = function (evt) {
                   alert("Failed to read file!\n\n" + reader.error);
                }
            reader.onload = function (evt) {
                var csv = evt.target.result;
                console.log("csvData:::"+csv);
                //var rows = csv.split("\n");
                //rows.shift(); 
                var action  = component.get('c.refineCSV');
                action.setParams({ CsvData : JSON.stringify(csv) });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.ServerData",response.getReturnValue());
                        console.log("Server-Response:::"+JSON.stringify(response.getReturnValue()));
                        var RowsData = response.getReturnValue();
                         helper.ProcessFileData(component, event, helper,RowsData);
                    }
                }); 
                $A.enqueueAction(action);
            }
        }
    },
    
})