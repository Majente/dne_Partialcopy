({
	saveCommissionHierarchyJSH : function(component)
    {
        //saveCommissionHierarchyList(List<DNE_Commission_Hierarchy__c> chList)
        var saveAction = component.get('c.saveCommissionHierarchy');

        var commHier = component.get('v.commissionHierarchy');

        var openerLkp = component.get("v.openerLkp");
        var openerId = $A.util.isEmpty(openerLkp) ? null : openerLkp.val;

        var level1Lkp = component.get("v.level1Lkp");
        var level1Id = $A.util.isEmpty(level1Lkp) ? null : level1Lkp.val;

        console.log('JTM - level1Lkp = ' + level1Lkp);
        console.log('JTM - level1Id = ' + level1Id);

        var level2Lkp = component.get("v.level2Lkp");
        var level2Id = $A.util.isEmpty(level2Lkp) ? null : level2Lkp.val;


        var level3Lkp = component.get("v.level3Lkp");
        var level3Id = $A.util.isEmpty(level3Lkp) ? null : level3Lkp.val;


        var level4Lkp = component.get("v.level4Lkp");
        var level4Id = $A.util.isEmpty(level4Lkp) ? null : level4Lkp.val;


        var level5Lkp = component.get("v.level5Lkp");
        var level5Id = $A.util.isEmpty(level5Lkp) ? null : level5Lkp.val;


        var level6Lkp = component.get("v.level6Lkp");
        var level6Id = $A.util.isEmpty(level6Lkp) ? null : level6Lkp.val;


        var level7Lkp = component.get("v.level7Lkp");
        var level7Id = $A.util.isEmpty(level7Lkp) ? null : level7Lkp.val;


        var level8Lkp = component.get("v.level8Lkp");
        var level8Id = $A.util.isEmpty(level8Lkp) ? null : level8Lkp.val;


        var level9Lkp = component.get("v.level9Lkp");
        var level9Id = $A.util.isEmpty(level9Lkp) ? null : level9Lkp.val;


        var level10Lkp = component.get("v.level10Lkp");
        var level10Id = $A.util.isEmpty(level10Lkp) ? null : level10Lkp.val;


        var level11Lkp = component.get("v.level11Lkp");
        var level11Id = $A.util.isEmpty(level11Lkp) ? null : level11Lkp.val;


        var level12Lkp = component.get("v.level12Lkp");
        var level12Id = $A.util.isEmpty(level12Lkp) ? null : level12Lkp.val;


        var level13Lkp = component.get("v.level13Lkp");
        var level13Id = $A.util.isEmpty(level13Lkp) ? null : level13Lkp.val;


        var level14Lkp = component.get("v.level14Lkp");
        var level14Id = $A.util.isEmpty(level14Lkp) ? null : level14Lkp.val;


        var level15Lkp = component.get("v.level15Lkp");
        var level15Id = $A.util.isEmpty(level15Lkp) ? null : level15Lkp.val;


        var level16Lkp = component.get("v.level16Lkp");
        var level16Id = $A.util.isEmpty(level16Lkp) ? null : level16Lkp.val;


        saveAction.setParams({
                ch : commHier,
                openerId: openerId,
                level1Id: level1Id,
                level2Id: level2Id,
                level3Id: level3Id,
                level4Id: level4Id,
                level5Id: level5Id,
                level6Id: level6Id,
                level7Id: level7Id,
                level8Id: level8Id,
                level9Id: level9Id,
                level10Id: level10Id,
                level11Id: level11Id,
                level12Id: level12Id,
                level13Id: level13Id,
                level14Id: level14Id,
                level15Id: level15Id,
                level16Id: level16Id
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

        			component.set("v.disableSaveButton", true);
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