({
    doInit : function(component, event, helper) {
        component.set("v.LoadSpinner",true);
        var action = component.get('c.OldOpportunities');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert(result.length);
                component.set("v.PercList",result);
                component.set("v.OldOppList",result.OldOpp);
                //alert(JSON.stringify(component.get("v.OldOppList")));
               	component.set("v.RenewOppList",result.RenewalOpp); 
                //alert(JSON.stringify(component.get("v.RenewOppList")));
                component.set("v.LoadSpinner",false);
            }
        });
        
        $A.enqueueAction(action);
    }
})