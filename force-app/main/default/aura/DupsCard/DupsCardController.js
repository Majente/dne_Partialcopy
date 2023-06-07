({
    doInit : function(component, event, helper) {
        var action = component.get('c.getaccountsDups');
        var recId = component.get('v.recordId');
        action.setParams({
            accId :  recId
        });
        action.setCallback(this, function(response){
            var responseValue = response.getReturnValue();
            component.set('v.DupsList', responseValue);
        });
        $A.enqueueAction(action); 
    },
    
    navigate: function(component, event, helper) {
        var idx = event.currentTarget.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx
        });
        navEvt.fire();   
    }
})