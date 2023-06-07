({
	doInit : function(component, event, helper) {
		//component.set("v.sObjectType",User);
	},
    updateOwner : function(component, event, helper) {
        helper.updateOwnerHelper(component,event,helper);
    },
    updateOwnerAsQueue : function(component, event, helper) {
        helper.updateOwnerAsQueueHelper(component,event,helper);
    }
    
})