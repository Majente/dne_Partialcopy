({
	getData : function(component, event, helper) {
		var action = component.get("c.getDuplicateData");
        action.setParams({
            "recordId" : component.get("v.recordId") 
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            if(state == 'SUCCESS'){
                var result = res.getReturnValue();
                if(result != null && result != undefined){
                    component.set("v.duplicateList",result);
                }
            }
            else if(state == 'ERROR'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "message": res.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})