({
    doInit:function(component, event, helper){
        component.set("v.spinner",true);
        var action = component.get("c.getData");
        action.setParams({
            "objName" : component.get("v.ObjectName") 
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                  component.set("v.spinner",false);
                /* var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "message": result.message
                    });
                    toastEvent.fire();*/
                //$A.get('e.force:refreshView').fire();
                var pageSize = component.get("v.pageSize");
                component.set("v.InvoiceData",result);
                component.set("v.totalRecords", component.get("v.InvoiceData").length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                var PagList = [];
                for ( var i=0; i< pageSize; i++ ) {
                    if ( component.get("v.InvoiceData").length> i )
                        PagList.push(response.getReturnValue()[i]);    
                }
                component.set('v.PaginationList', PagList);
                
            }else if(state == 'ERROR'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "message": response.getError()[0].message
                });
                toastEvent.fire();
                component.set("v.spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    next: function (component, event, helper) {
        var sObjectList = component.get("v.InvoiceData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i = end + 1; i < end + pageSize + 1; i++ ) {
            if ( sObjectList.length > i ) {
                PagList.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.InvoiceData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i= start-pageSize; i < start ; i++ ) {
            if ( i > -1 ) {
                PagList.push(sObjectList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    //Select all 
    handleSelectAll: function(component, event, helper) {
        var selectedCheckbox = [];
        var checkvalue = component.find("SelectAllEntry").get("v.value");        
        var checkJob = component.find("SelectEntry");
        if(checkvalue == true){
            for(var i=0; i<checkJob.length; i++){
                checkJob[i].set("v.value",true);
            }
        }
        else{
            for(var i=0; i<checkJob.length; i++){
                checkJob[i].set("v.value",false);
            }
        }
         var checkvalue1 = component.find("SelectEntry");
        if(!Array.isArray(checkvalue1)){
            if (checkvalue1.get("v.value") == true) {
                selectedCheckbox.push(checkvalue1.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue1.length; i++) {
                if (checkvalue1[i].get("v.value") == true) {
                    selectedCheckbox.push(checkvalue1[i].get("v.text"));
                }
            }
        }
        component.set("v.selectedEntries",selectedCheckbox);
         console.log('selectedCheckbox-' + selectedCheckbox);
    },
       
     
        //Process the select single
    handleSelect: function(component, event, helper) {
        var selectedCheckbox = [];
        var checkvalue = component.find("SelectEntry");
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedCheckbox.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedCheckbox.push(checkvalue[i].get("v.text"));
                }
            }
        }
        component.set("v.selectedEntries",selectedCheckbox);
         console.log('selectedCheckbox-' + selectedCheckbox);
    },
    handleProceed: function(component, event, helper) {
        component.set("v.spinner",true);
        var selectRecords = component.get("v.selectedEntries");
        var action = component.get("c.ProcessEntry");
        action.setParams({
            "SelectedRec" : selectRecords
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                  component.set("v.spinner",false);
                 var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "message": result
                    });
                    toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }else if(state == 'ERROR'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "message": response.getError()[0].message
                });
                toastEvent.fire();
                component.set("v.spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
})