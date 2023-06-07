({
    getData : function(component, event, helper) {
        component.set("v.spinner",true);
        var recordId =  component.get("v.recordId");
        var action = component.get("c.syncOpportunity");
        action.setParams({
            "contractId": recordId
        });
        action.setCallback(this, function(response) {
            //alert ('SetCallback::::'); 
            var state = response.getState();
            // alert ('Getstate::::'+state); 
            var result = response.getReturnValue();
            //alert ('Result::::'+result);
            if (state == "SUCCESS") {
               $A.get('e.force:refreshView').fire();
                if(result.status == 'Success')  {       
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": result.msg
                    });
                    toastEvent.fire();
                }
                else if(result.status == 'Error'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "Error",
                        "message": result.msg
                    });
                    toastEvent.fire();
                }
            }
            else if(state == "Error"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": JSON.stringify(response.getError())
                });
                toastEvent.fire();
            }
               component.set("v.spinner",false);
        }); 
        
        $A.enqueueAction(action);
    },
    
  
})