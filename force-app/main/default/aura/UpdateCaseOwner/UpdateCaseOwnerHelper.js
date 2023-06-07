({
    updateOwnerHelper : function(component, event, helper) {
        var action = component.get("c.UpdateCase");
        var currentCaseId = component.get("v.recordId");
        action.setParams({ 
            ownerId : component.get("v.sObjectType.OwnerId"),
            caseId : currentCaseId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams({
        		"type": "Success",
                "title": "Success", 
                "message": "Case Owner Updated Sucessfully" 
    			});
    			toastEvent.fire();
                var redirectToObject = $A.get("e.force:navigateToSObject");
                redirectToObject.setParams({
                    "recordId" : currentCaseId
                })
                redirectToObject.fire();
            }
        });
        $A.enqueueAction(action);
	},
    updateOwnerAsQueueHelper : function(component, event, helper) {
        var action = component.get("c.UpdateCaseOwnerAsQueue");
        var currentCaseId = component.get("v.recordId");
        action.setParams({ 
            caseId : currentCaseId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams({
        		"type": "Success",
                "title": "Success", 
                "message": "Case Owner Updated Sucessfully" 
    			});
    			toastEvent.fire();
                var redirectToObject = $A.get("e.force:navigateToSObject");
                redirectToObject.setParams({
                    "recordId" : currentCaseId
                })
                redirectToObject.fire();
            }
        });
        $A.enqueueAction(action);
	},
    
    
    validateContactForm: function(component) {
        var validContact = true;

         // Show error messages if required fields are blank
        var allValid = component.find('contactField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
            // Verify we have an account to attach it to
            var account = component.get("v.account");
            if($A.util.isEmpty(account)) {
                validContact = false;
                console.log("Quick action context doesn't have a valid account.");
            }
        	return(validContact);
            
        }  
	}
       
})