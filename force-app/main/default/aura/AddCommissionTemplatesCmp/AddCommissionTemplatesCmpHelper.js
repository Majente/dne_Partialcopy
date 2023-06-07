({
	loadTypeOptions : function(component)
    {
        var loadPicklistAction = component.get('c.getPicklistsOptions');

        loadPicklistAction.setCallback(this, function(response)
        {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {
                component.set("v.pageMessage", '');
                $A.util.removeClass( component.find("pageMessageDiv"), "slds-box");

                var serverResponse = response.getReturnValue();

                var responseJSON = JSON.parse(serverResponse);
                component.set('v.picklistsOptionsMap',responseJSON);

                var picklistsOptionsMapVar = component.get("v.picklistsOptionsMap");
                component.set("v.typeOptions", picklistsOptionsMapVar['typeOptions']);

            }
            else
            {
                return this.manageUnsuccessfulCallouts(response, state);
            }

        });
        $A.enqueueAction(loadPicklistAction);
    },
    //====================================================
	
	saveCommissionHierarchyListJSH : function(component)
    {
        //saveCommissionHierarchyList(List<DNE_Commission_Hierarchy__c> chList)
        var saveAction = component.get('c.saveCommissionHierarchyList');

        var commHierList = component.get('v.commissionHierarchyList');

        saveAction.setParams({
                chList : commHierList
            });

        saveAction.setCallback(this, function(response)
        {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {
                var responseString = response.getReturnValue();
                console.log('JTM - responseString = ' + responseString);
                component.set("v.pageMessage", responseString);

                if(responseString.includes('SUCCESS'))
                {
                    console.log('JTM - SUCCESS');
                    $A.util.removeClass( component.find("pageMessageDiv"), "slds-text-color_error");;
                    $A.util.addClass( component.find("pageMessageDiv"), "slds-text-color_success slds-box");
                }
                else
                {
                    console.log('JTM - ERROR');
                    $A.util.removeClass( component.find("pageMessageDiv"), "slds-text-color_success");
                    $A.util.addClass( component.find("pageMessageDiv"), "slds-text-color_error slds-box");
                }

            }
            else
            {
                return this.manageUnsuccessfulCallouts(response, state);
            }

        });
        $A.enqueueAction(saveAction);
    },
    //====================================================

    manageUnsuccessfulCallouts: function(response, state)
    {
        if (state === "ERROR") {
            var errors = response.getError();
            if(!errors || !errors[0] || !errors[0].message)
                throw new Error("Callout Failed -- Missing Error Details. If the problem persist, please contact your administrator");

            throw new Error("Error message: "+errors[0].message);
        }
        else
            throw new Error("Action State returned was: " + state);
    }
})