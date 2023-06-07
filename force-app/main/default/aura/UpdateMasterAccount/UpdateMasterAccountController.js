({
    doInit : function(component, event, helper) {
        helper.getData(component,event,helper);
    },
    onGroup : function(component,event,helper){
        var selected = event.getSource().get("v.text");
        component.set("v.selectedDupId",selected);
    },
    processSelect : function(component,event,helper){
        var selectedVal = component.get("v.selectedDupId");
        var data = component.get("v.duplicateList");
        if(selectedVal == null || selectedVal == undefined || selectedVal == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "message": 'Please select record.'
            });
            toastEvent.fire();
            return false;
        }
        component.set("v.spinner",true);
        var action = component.get("c.updateMasterRecord");
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "masterId" : selectedVal,
            "dataList" : JSON.stringify(data)
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state == 'SUCCESS'){
                var result = res.getReturnValue();
                if(result != null && result != undefined){
                    if(result.status == 'Success'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Success",
                            "message": result.message
                        });
                        toastEvent.fire();
                        component.set("v.spinner",false);
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result.masterRecId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }else if(result.status == 'Error'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Error",
                            "message": result.message
                        });
                        toastEvent.fire();
                        component.set("v.spinner",false);
                    }
                }
            }
            else if(state == 'ERROR'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
                component.set("v.spinner",false);
            }
        });
        $A.enqueueAction(action);
    },
})