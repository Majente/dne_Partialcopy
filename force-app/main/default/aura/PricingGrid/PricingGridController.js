({
    
    init : function(component, event, helper) {
       
        /*==========================*/
        component.set('v.spinner',true);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD hh:mm:ss");
        component.set('v.today', today);
        var marketOpt = component.get("c.getAllOptions");
        marketOpt.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.spinner',false);
                var storeResponse = response.getReturnValue();
                
                var marketList=storeResponse['marketList'];
                var commodityList=storeResponse['commodityList'];
                var sizeList=storeResponse['sizeList'];
                
                if(marketList.dataType=='sObject'){
                    var marketOptions=marketList.sObjectData;                    
                    component.set("v.marketOptions", marketOptions);
                	component.set("v.selectedMarket", marketOptions[0].Id);
                }
                if(commodityList.dataType=='string'){
                    var commodityOptions=commodityList.stringData;                    
                    component.set("v.commodityOptions", commodityOptions);
                	component.set("v.selectedCommodity", commodityOptions[0]);
                }
                if(sizeList.dataType=='string'){
                    var sizeOptions=sizeList.stringData;
                    component.set("v.sizeOptions", sizeOptions);
                	component.set("v.selectedSize", sizeOptions[0]);
                    
                }
                component.find("supplier_opt1").set("v.value",'Fixed');
                console.log('here.......');
                helper.onGetSupplierResult(component,event, helper);
            }
        });
        $A.enqueueAction(marketOpt);        
		
    },
    
    onGetSupplier : function(component,event, helper ){
      helper.onGetSupplierResult(component,event, helper);
    },
    handleSelect: function (component, event, helper) {
        console.log()
        var getSupplierData = component.get("c.getTodayPbmMap");
        var supplier = component.find("supplier_opt").get("v.selectedTabId");
        var pricetype = component.find("supplier_opt1").get("v.value");
        
        console.log('tab supplier', supplier);
        getSupplierData.setParams({
            tabId: component.get("v.tabId"),
            commodity: component.get("v.selectedCommodity"), 
            market: component.get("v.selectedMarket"), 
            size: component.get("v.selectedSize"),
            pricetype:pricetype
        });
        getSupplierData.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var storeResponse = response.getReturnValue();
                console.log(storeResponse.length);
                var supplierPricebyMonthObject=[];
                for(var ind in storeResponse){
                    console.log('ind--'+ind);
                    console.log('ind--'+JSON.stringify(storeResponse[ind]));
                   
                    supplierPricebyMonthObject.push({'key':ind,'value':storeResponse[ind]});
                }
                component.set("v.supplierPricebyMonthObject", supplierPricebyMonthObject);
                component.set("v.supplierPricebyMonth", storeResponse);
                var getstoreResponse = component.get("v.supplierPricebyMonth");
                //component.set("v.selectedSize", storeResponse[0]);
                console.log('**** getSupplierData');
                
                console.log(storeResponse);
                 console.log('**** supplierPricebyMonthObject');
                 console.log(supplierPricebyMonthObject);
                console.log('**** getstoreResponse');
                console.log(getstoreResponse);
            }
        });
        $A.enqueueAction(getSupplierData);
        console.log(component.get("v.tabId"));
    },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
    
    
})