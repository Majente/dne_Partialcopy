({
	handleSelectTab: function (component) {
        
       
        var getSupplierData = component.get("c.getTodayPbmMap");
        var pricetype = component.find("supplier_opt1").get("v.value");
        
        console.log("helper supplier"+JSON.stringify(getSupplierData)) ;
        
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
                component.set('v.spinner',false);
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
    
    onGetSupplierResult:function(component,event, helper ){
        component.set('v.spinner',true); 
        var getSupplierCmp = component.get("c.getSupplierList");
        console.log('@@@@@'+getSupplierCmp);
        var commodity = component.find("commodity_opt").get("v.value");
        console.log('commodity ',commodity);
        var market = component.find("market_opt").get("v.value");
        console.log('market ',market); 
        var size = component.find("size_opt").get("v.value");
        console.log('size ',size);
        var type = component.find("supplier_opt1").get("v.value"); 
        console.log("supplier ", component.get("v.AccountsList"));           
        //console.log("supplier ", component.find("supplier_opt").get('v.label'));        
        
        
        var params = {
            commodity: commodity, 
            market: market, 
            size: size,
            type:type,
        };
        getSupplierCmp.setParams(params);
        console.log(params);
        
        var opts = [];
        getSupplierCmp.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                
                var storeResponse = [];
                storeResponse = response.getReturnValue();
                console.log('Supplier List'+JSON.stringify(storeResponse));
                //alert(JSON.stringify(storeResponse));
                
                for (let [key, value] of Object.entries(storeResponse)) {  
                    console.log(key + ':' + value);
                    opts.push({'label': value, 'value': key});
                }
                for(var i = 0; i<storeResponse.length; i++){
					opts.push({'label': storeResponse[i].key, 'value': storeResponse[i].value});
				}
               //alert(opts.length);
                if(opts.length > 0){
                    component.set("v.supplierOpts", opts);
                    component.set("v.tabId",opts[0].value );
                    helper.handleSelectTab(component);
                    component.set('v.norecord',true);
                }else{
                    var opt = [];
                    component.set("v.supplierOpts", opt);
                    component.set('v.spinner',false);
                    component.set('v.norecord',false);
                }
                                
                
            }
        });
        $A.enqueueAction(getSupplierCmp);
    }
    
})