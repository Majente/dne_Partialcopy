({
    
    // function call on component Load
    doInit: function(component, event, helper) {
        // create a Default RowItem [Contact Instance] on first time Component Load
        // by call this helper function 
        component.set("v.loaded",true);
        var action = component.get("c.getAccountDetail");
        var accountid = component.get("v.recordId");
        action.setParams({
            parentAccId:accountid
        });        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue() ;
                console.log("Result ::"+JSON.stringify(result));
                var pageSize = component.get("v.pageSize");
                var noOfPages = Math.ceil(result.length/pageSize);
                component.set("v.totalPages", noOfPages);
                component.set("v.ResultData",result);
                var locList = [];
                var MarkList = [];
                var CityList = [];
                for(var i=0;i<result.length;i++){
                    console.log('serviceAddressAccount ::'+JSON.stringify(result[i]));
                    if(result[i] && result[i].serviceAddressAccount && JSON.stringify(result[i].serviceAddressAccount) != '{}'){
                        if(result[i] && result[i].serviceAddressAccount && result[i].serviceAddressAccount.Name != null){
                            locList.push(result[i].serviceAddressAccount.Name); 
                            console.log('locList :'+locList)
                        }
                        if(result[i] && result[i].serviceAddressAccount && result[i].serviceAddressAccount.Market__r && result[i].serviceAddressAccount.Market__r.Name != null){
                            MarkList.push(result[i].serviceAddressAccount.Market__r.Name);
                            console.log('MarkList :'+MarkList)
                            
                        }
                        if(result[i] && result[i].serviceAddressAccount && result[i].serviceAddressAccount.ShippingCity != null){
                            CityList.push(result[i].serviceAddressAccount.ShippingCity);
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
                
                console.log('LocationPicklist ::'+component.get("v.LocationPicklist"));
                console.log('CityPicklist ::'+component.get("v.CityPicklist"));
                console.log('MarketPicklist ::'+component.get("v.MarketPicklist"));
                
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    PaginationList.push(result[i]);    
                }
                helper.generatePageList(component);
                component.set('v.ResultDataPagination', PaginationList);
                console.log("PaginationList ::"+JSON.stringify(PaginationList));
                component.set("v.ExistingDataList",result);
                helper.getAccountDetailsByPage(component, event, helper);
            } 
        });
        $A.enqueueAction(action);
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
        var cardList = component.get("v.cardListFinal");
        console.log('#######CardList-Save = '+JSON.stringify(cardList));
        var cList = component.get("v.FinalcardList");
        console.log('#######cList = '+JSON.stringify(cList));
        // alert('#######cList = '+JSON.stringify(cList));
        
        for(var i=0; i < cList.length; i++){
            for(var j=0; j < cardList.length; j++){
                if(cardList[j].serviceAddressAccount.Name == cList[i].serviceAddressAccount.Name){
                    //cList[i].serviceAddressAccount = cardList[j].serviceAddressAccount;
                    cList[i].serviceAddressAccount.Name = cardList[j].serviceAddressAccount.Name;
                    cList[i].serviceAddressAccount.Service_address_same_as_parent__c = cardList[j].serviceAddressAccount.Service_address_same_as_parent__c;
                    cList[i].serviceAddressAccount.Billing_address_same_as_parent__c = cardList[j].serviceAddressAccount.Billing_address_same_as_parent__c;
                    cList[i].serviceAddressAccount.ShippingCity = cardList[j].serviceAddressAccount.ShippingCity;
                    cList[i].serviceAddressAccount.ShippingState = cardList[j].serviceAddressAccount.ShippingState;
                    cList[i].serviceAddressAccount.ShippingStreet = cardList[j].serviceAddressAccount.ShippingStreet;
                    cList[i].serviceAddressAccount.ShippingPostalCode = cardList[j].serviceAddressAccount.ShippingPostalCode;
                    cList[i].serviceAddressAccount.ShippingCountry = cardList[j].serviceAddressAccount.ShippingCountry;
                    cList[i].serviceAddressAccount.Market__c = cardList[j].serviceAddressAccount.Market__c;
                    //console.log('address ::'+(JSON.stringify(cList[i].serviceAddressAccount)));
                    cList[i].siteList = cardList[j].siteList;
                    console.log('site ::'+(JSON.stringify(cList[i].siteList)));
                }
            }
        }
        console.log('NewFinal =>>'+JSON.stringify(cList));
        for( var i=0; i < cList.length; i++){
            console.log('In-FIrst Loop Condition Check');
            
            if(cList[i].serviceAddressAccount && (cList[i].serviceAddressAccount.Name == '' || cList[i].serviceAddressAccount.Name == null)){
                component.set("v.loaded",false);
                return helper.showMsg("Name of Service Address is missing.", "error");
            }            
            
            if(Array.isArray(cList[i].serviceAddressAccount.Market__c) == true){
                component.set("v.loaded",false);
                return helper.showMsg("Market is missing!", "error");
            }
            if(cList[i].serviceAddressAccount && (cList[i].serviceAddressAccount.Market__c == '' || cList[i].serviceAddressAccount.Market__c == null)){
                console.log('serviceAddressAccount58:: '+JSON.stringify(cList[i].serviceAddressAccount));
                console.log('cardList-serviceAddressAccount58:: '+JSON.stringify(cardList[i].serviceAddressAccount));
                component.set("v.loaded",false);
                return helper.showMsg("Market is missing!", "error");
            }
            
            // alert(cList[i].siteList[i].Type__c);
            
        }
        console.log('OutOfLoop');
        
        for(var i=0; i < cList.length; i++){
            var valueArr = cList.map(function(item){ return item.serviceAddressAccount.Name });
            var UnmatchedRecord = '';
            var isDuplicate = valueArr.some(function(item, idx){ 
                if(valueArr.indexOf(item) != idx){
                    UnmatchedRecord = item;
                    return valueArr.indexOf(item) != idx 
                }
            });
            if(isDuplicate){
                component.set("v.loaded",false);
                return helper.showMsg("Duplicate Service Address is not allowed. "+UnmatchedRecord, "error");
            }
        }
        for(var i=0; i < cList.length; i++){
            for(var j=0; j < cList[i].siteList.length; j++)
            {
                console.log('In-Third Loop Condition Check');
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
            
        }
        
        component.set("v.FinalcardList",cList);
        
        console.log('############## '+JSON.stringify(component.get("v.FinalcardList")));
        action.setParams({
            ListAccounts: JSON.stringify(component.get("v.FinalcardList")),
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
                
                var cardListDatas = component.get("v.FinalcardList");
                console.log('cardListDatas = '+JSON.stringify(cardListDatas));
                var cardDataList = component.get("v.cardList")
                if(result.length>0){
                    for(var i = 0; i < result.length; i++){
                        if(result[i].flag){
                            var message = result[i].message +' '+'On location: '+result[i].serviceAddress;
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": message,
                                "type": 'error'
                            });
                            toastEvent.fire();
                            component.set("v.loaded",false);
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
                                component.set("v.FinalcardList",cardListDatas);
                                //component.set("v.cardList",cardListDatas);
                                component.set("v.loaded",false);
                            }
                            for(var j = 0; j < cardDataList.length; j++){
                                var SiteListDatas = cardDataList[j].siteList;
                                var marketVal = cardDataList[j].serviceAddressAccount.Market__c == '' || cardDataList[j].serviceAddressAccount.Market__c == undefined ? null : cardDataList[j].serviceAddressAccount.Market__c;
                                var sKey = cardDataList[j].serviceAddressAccount.Name+marketVal;
                                
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
                                cardDataList[j].siteList = SiteListDatas;
                                component.set("v.cardList",cardDataList);
                                //component.set("v.cardList",cardListDatas);
                                component.set("v.loaded",false);
                            }	
                        }
                    }
                }else{
                    $A.get("e.force:closeQuickAction").fire();                
                    $A.get('e.force:refreshView').fire(); 
                }
                
            }else{
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
        var resultD = component.get("v.cardList");
        helper.createObjectData(component, event, helper,resultD);
        //helper.getAccountDetails2(component, event, helper,index); 
    },
    
    // function for delete the row 
    removeDeletedRowParent: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVarParent");
        //component.set("v.loaded",true);
        console.log("index:::"+index);
        
        // get the all List (accountList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.cardList");
        var AllFinalcardList = component.get("v.FinalcardList");
        console.log('Before-AllFinalcardList => '+JSON.stringify(AllFinalcardList));
        for (var i = 0; i < AllFinalcardList.length; i++) {
            if(AllFinalcardList[i].serviceAddressAccount.Name == AllRowsList[index].serviceAddressAccount.Name){
                console.log('AllFinalcardList[i].serviceAddressAccount ##'+AllFinalcardList[i].serviceAddressAccount.Name+' => '+ 'AllRowsList[index].serviceAddressAccount ##'+AllRowsList[index].serviceAddressAccount.Name);
                AllFinalcardList.splice(i, 1);
                console.log('AfterSplice => '+JSON.stringify(AllFinalcardList));
            }
        }
        
        AllRowsList.splice(index, 1);
        console.log('AllFinalcardList => '+JSON.stringify(AllFinalcardList));
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
        component.set("v.FinalcardList", null); 
        component.set("v.ExistingDataList",null);
        component.set("v.FinalcardList", AllFinalcardList); 
        component.set("v.ExistingDataList",AllFinalcardList);
        console.log('##################Remove-FinalcardList '+JSON.stringify(component.get("v.FinalcardList")));
        //helper.removeDeletedRowFromFinalList(component, event, helper,index);
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
    
    next : function(component, event, helper){
        /*
        var cardList = component.get("v.cardList");
        var FinalcardList = component.get("v.FinalcardList");
        for(var i=0;i<cardList.length;i++){
            FinalcardList.push(cardList[i]);
        }
        component.set("v.FinalcardList",FinalcardList);
        console.log('FinalcardList::'+JSON.stringify(component.get("v.FinalcardList")));
        var sObjectList = component.get("v.ResultData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.ResultDataPagination', Paginationlist);
        helper.getAccountDetailsByPage(component, event, helper);
        */
    },
    processMe : function(component, event, helper) {
        var name = '';
        if(event.target.name){
            name = event.target.name;
        }else{
            name = event.getSource().get("v.name");
        }
        //name = name -1;
        //alert('name ::'+name);
        component.set("v.currentPage",name);
        window.setTimeout(function(){
            helper.handleValueOnNumberChange(component, event, helper,name);
        }, 1000
                         );
    },
    handleValueOnChange: function(component, event, helper) {
        //alert('selectedLocation =>'+component.get("v.selectedLocation"));
        //alert('selectedMarket =>'+component.get("v.selectedMarket"));
        //alert('selectedCity =>'+component.get("v.selectedCity"));
        component.set("v.loaded",true);
        var filteredList = [];
        
        var existingList = component.get("v.ExistingDataList");
        console.log('existingList-valueChnage :'+JSON.stringify(existingList));
        var cardList = component.get("v.cardListFinal");
        
        if(component.get("v.selectedLocation") == '' && component.get("v.selectedMarket") == '' && component.get("v.selectedCity") == ''){
            
            var result = component.get('v.ExistingDataList');
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
            var pageSize = component.get("v.pageSize");
            //alert('lenght::'+result.length); 
            var currentNumberPage = component.get("v.currentPage");
            if(currentNumberPage == null){
                currentNumberPage = '1';
            }
            var noOfPages = Math.ceil(result.length/pageSize);
            component.set("v.totalPages", noOfPages);
            var start = ((currentNumberPage*pageSize)-pageSize); 
            var end = start + pageSize;
            var PaginationList = [];
            for(var i=start; i<end; i++){
                if(result.length > i){
                    PaginationList.push(result[i]);    
                }
            }
            component.set('v.ResultDataPagination', PaginationList);
            console.log('ResultDataPagination ::'+JSON.stringify(component.get("v.ResultDataPagination")));
            helper.generatePageList(component); 
            window.setTimeout(function(){
                helper.getAccountDetailsByPage2(component, event, helper);
            }, 1000
                             );
        }
        else if(component.get("v.selectedLocation") != '' && component.get("v.selectedMarket") == '' && component.get("v.selectedCity") == ''){
            //alert('condition-1');
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
                component.set("v.loaded",false);
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
                helper.processMeDoInIt(component, event, helper,filteredList,'1');
            }
            
        }
            else if(component.get("v.selectedLocation") == '' && component.get("v.selectedMarket") != '' && component.get("v.selectedCity") == ''){
                //alert('condition-2');
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
                    component.set("v.loaded",false);
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
                    helper.processMeDoInIt(component, event, helper,filteredList,'1');
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
                        component.set("v.loaded",false);
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
                        helper.processMeDoInIt(component, event, helper,filteredList,'1');
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
                            component.set("v.loaded",false);
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
                            helper.processMeDoInIt(component, event, helper,filteredList,'1');
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
                                component.set("v.loaded",false);
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
                                helper.processMeDoInIt(component, event, helper,filteredList,'1');
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
                                    component.set("v.loaded",false);
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
                                    helper.processMeDoInIt(component, event, helper,filteredList,'1');
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
                                        component.set("v.loaded",false);
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
                                        helper.processMeDoInIt(component, event, helper,filteredList,'1');
                                    }
                                }
        
        //helper.getAccountDetailsByPage(component, event, helper);
    },
    setPageSize: function(component, event, helper) {  
        component.set("v.loaded",true);
        var pageSizeVal = parseInt(component.get("v.pageSize"));
        component.set("v.pageSize",pageSizeVal);
        helper.handleValueOnNumberChange(component, event, helper,1);   
        
    },
    
    
})