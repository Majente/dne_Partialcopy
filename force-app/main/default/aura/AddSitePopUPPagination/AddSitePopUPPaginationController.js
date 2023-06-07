({
    // function call on component Load
    doInit: function(component, event, helper) {   
        component.set("v.loaded",true);
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        const sURLVariables = sPageURL.split("=")[1];
        if(sURLVariables!=null){
            component.set("v.recordId",sURLVariables);
        }
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
                component.set("v.depnedentFieldMap",result[0].dependentMap);
                component.set("v.cardList",result[0]);
                var pageSize = component.get("v.pageSize");
                component.set("v.siteListLength",pageSize-1);
                var noOfPages = Math.ceil(result[0].siteList.length/pageSize);
                //alert('noOfPages :: ' + noOfPages);
                component.set("v.totalPages", noOfPages);
                var sites = [];
                var card = component.get("v.cardList");
                for(var i=0;i<pageSize;i++){
                    if(card.siteList[i]!=null){
                        sites.push(card.siteList[i]);
                    }
                }
                console.log('sites&&& '+sites)
                component.set("v.siteListLength",sites.length-1);
                var start = 0;
                helper.getSiteDetailsByPage(component, event, helper, sites, start, pageSize-1);
                helper.generatePageList(component); 
            } 
        });     
        $A.enqueueAction(action);
    },
    AddNewRow : function(component, event, helper){
        component.set("v.loaded",true);
        var currentPageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var start = ((currentPageNumber*pageSize)-pageSize); 
        //alert('start: '+start+'end: '+end);
        var icon = component.get("v.siteListLength");
        icon++
        component.set("v.siteListLength",icon);
        var cList = component.get("v.cardList");
        var Acc = cList.serviceAddressAccount.Id;
        //alert(Acc);
        var site = {'Account__c':Acc,'Name':'','Type__c':'','Unit_of_Measure__c':'','Volume__c':'','UnitTypeMeasureList':['--- None ---']};
        var rowSiteAdd = component.get("v.siteList");
        var end = rowSiteAdd.length;
        var cardList = component.get("v.cardList");
        // index to add to
        var index = (start+end);
        cardList.siteList.splice(index, 0, site);
        component.set("v.cardList",cardList);
        console.log('cardList++++++'+JSON.stringify(component.get("v.cardList")));
        rowSiteAdd.push(site);
        component.set("v.siteList",rowSiteAdd); 
        component.set("v.loaded",false);
    },
    removeRow : function(component, event, helper){
        component.set("v.loaded",true);
        var currentPageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var icon = component.get("v.siteListLength");
        icon--
        component.set("v.siteListLength",icon);
        var rowSiteDelete = component.get("v.siteList");
        var cardList = component.get("v.cardList");
        var curRec = parseInt(event.target.name);
        rowSiteDelete.splice(curRec,1);
        if(rowSiteDelete.length == 0){
            var site = {'Name':'','Type__c':'','Unit_of_Measure__c':'','Volume__c':0,'UnitTypeMeasureList':['--- None ---']};
            rowSiteDelete.push(site);
        }
        component.set("v.siteList",rowSiteDelete);
        var cardCurRec = ((currentPageNumber*pageSize)-pageSize)+curRec;
        //alert(cardCurRec);
        cardList.siteList.splice(cardCurRec,1);
        component.set("v.cardList",cardList);
        component.set("v.loaded",false);
        //console.log('cardList------'+JSON.stringify(component.get("v.cardList")));
    },
    
    // function for save the Records 
    Save: function(component, event, helper) {
        component.set("v.loaded",true);
        var currentPageNumber = component.get("v.currentPageNumber");
        //alert('currentPageNumber: '+currentPageNumber)
        var cardList = component.get("v.cardList");
        var AddOnSiteList = component.get("v.siteList");
        var pageSize = component.get("v.pageSize");
        var start = ((currentPageNumber*pageSize)-pageSize); 
        var end = (start+AddOnSiteList.length);
        var temp = 0;
        for (var i = start; i<end; i++) {
            for(var j=temp;j<AddOnSiteList.length;j++){
                console.log('AddOnSiteList[j]:: '+JSON.stringify(AddOnSiteList[j]));
                console.log('cardList.siteList[i]:: '+JSON.stringify(cardList.siteList[i]));
                cardList.siteList[i]=AddOnSiteList[j];
                temp++;
                break;
            }
        }
        component.set("v.cardList",cardList);
        var accountDetails = component.get("v.accountDetails");      
         if(accountDetails.Name == '' || accountDetails.Name == null){
                component.set("v.loaded",false);
                return helper.showMsg("Name of Service Address is missing.", "error");
            }
             if(accountDetails.Market__c[0] == '' || accountDetails.Market__c[0] == null){
                component.set("v.loaded",false);
                return helper.showMsg("Market is missing.", "error");
            }
        var BeforeSave = component.get("v.cardList");
        var accId = BeforeSave.parentAccountId;
        console.log('BeforeSave:: '+JSON.stringify(BeforeSave));
        var saveSiteList = [];
        BeforeSave.siteList.forEach(function(value,key){
                saveSiteList.push({ 
                    Account__c: value.Account__c,
                    Id: value.Id,
                    Name: value.Name,  
                    Type__c: value.Type__c,
                    Volume__c: value.Volume__c,
                    Unit_of_Measure__c: value.Unit_of_Measure__c,
                });
            });
        for(var i=0; i < saveSiteList.length; i++){
                //console.log('Site type :: ' + saveSiteList[i].Unit_of_Measure__c);
                if(saveSiteList[i].Name != '' && (saveSiteList[i].Type__c == '' || saveSiteList[i].Type__c == null || saveSiteList[i].Type__c == '--- None ---')){
                    component.set("v.loaded",false);
                    return helper.showMsg("Type of Site is missing.", "error");
                }  
                if(saveSiteList[i].Name != '' && (saveSiteList[i].Volume__c == '' || saveSiteList[i].Volume__c == null)){
                   component.set("v.loaded",false);
                    return helper.showMsg("Volume is missing.", "error");
                     
                } 
                if(saveSiteList[i].Name != '' && (saveSiteList[i].Unit_of_Measure__c == '' || saveSiteList[i].Unit_of_Measure__c == null || saveSiteList[i].Unit_of_Measure__c == '--- None ---')){
                   component.set("v.loaded",false);
                    return helper.showMsg("Unit of Measure is missing.", "error");
                }
            }
        BeforeSave.siteList=saveSiteList;
        BeforeSave.serviceAddressAccount = accountDetails;
        var FinalListSave = [];
        FinalListSave.push({
            dependentMap:BeforeSave.dependentMap,
            parentAccountDetail:BeforeSave.parentAccountDetail,
            parentAccountId:BeforeSave.parentAccountId,
            serviceAddressAccount:BeforeSave.serviceAddressAccount,
            siteList:BeforeSave.siteList
        });
        //FinalListSave.push(FinalObj);
        component.set("v.cardList",FinalListSave);
        var action = component.get("c.saveAccountSites");
        var ReasultFinalList = component.get("v.cardList");
        console.log('FullDataList ::'+JSON.stringify(ReasultFinalList));
        action.setParams({
            ListAccounts: JSON.stringify(ReasultFinalList),
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
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": result[i].message,
                                "type": "error"
                            });
                            toastEvent.fire(); 
                        }
                    }
                    var ErrorList = component.get("v.cardList");
                    console.log('ErrorList:'+JSON.stringify(ErrorList));
                    component.set("v.accountDetails",ErrorList[0].serviceAddressAccount);
                    component.set("v.siteListLength",ErrorList[0].siteList.length-1);
                    component.set("v.depnedentFieldMap",ErrorList[0].dependentMap);
                    component.set("v.cardList",ErrorList[0]);
                    var currentPageNumber = component.get("v.currentPageNumber");
                    //alert('currentPageNumber: '+currentPageNumber);
                    var pageSize = component.get("v.pageSize");
                    var start = ((currentPageNumber*pageSize)-pageSize); 
                    //alert('start: '+start);
                    var end = start + pageSize;
                    //alert('noOfPages :: ' + noOfPages);
                    //component.set("v.totalPages", noOfPages);
                    var card = component.get("v.cardList");
                    var sites = [];
                    for(var i=start;i<start+pageSize;i++){
                        sites.push(card.siteList[i]);
                    }
                     console.log('sites&&& '+sites)
                    var start = 0;
                    helper.getSiteDetailsByPage(component, event, helper, sites, start, pageSize-1);
                    helper.generatePageList(component);
                    component.set("v.loaded",false);
                }else{
                    $A.get('e.force:refreshView').fire();
                }
            } else{
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
    
    processMe : function(component, event, helper) {
        component.set("v.loaded",true);
       // alert('oldPageNumber: '+component.get("v.oldPageNumber"));
        var oldPageNumber = component.get("v.oldPageNumber")
        var cardList = component.get("v.cardList");
        var AddOnSiteList = component.get("v.siteList");
       // console.log('AddOnSiteList:: '+JSON.stringify(AddOnSiteList))
        var pageSizeOld = parseInt(component.get("v.pageSize"));
        var startOld = ((oldPageNumber*pageSizeOld)-pageSizeOld); 
        var temp = 0;
        for(var i=startOld;i<(startOld+AddOnSiteList.length);i++){
            for(var j=temp;j<AddOnSiteList.length;j++){
                cardList.siteList[i]=AddOnSiteList[j];
                temp++;
                break;
            }
        }
        component.set("v.cardList",cardList);
        var name = '';
        if(event.target.name){
            name = event.target.name;
        }else{
            name = event.getSource().get("v.name");
        }
        name = name -1;
        var currentPageNumber = parseInt(name)+1;
        component.set("v.currentPageNumber", currentPageNumber);
        helper.generatePageList(component); 
        var sObjectList = component.get("v.cardList");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var start = ((currentPageNumber*pageSize)-pageSize); 
        var end = start + pageSize;
        for(var i=start; i<end; i++){
            if(sObjectList.siteList[i]!=null){
                Paginationlist.push(sObjectList.siteList[i]);
            }
        }
        //console.log('Paginationlist::'+Paginationlist);
        component.set("v.siteListLength",Paginationlist.length-1);
        var noOfPages = Math.ceil(sObjectList.siteList.length/pageSize);
        component.set("v.totalPages", noOfPages);
        component.set("v.oldPageNumber",currentPageNumber);
        helper.getSiteDetailsByPage(component, event, helper, Paginationlist, start, end);
    },
})