({
    doInit : function(component, event, helper) {
        helper.addDupRecord(component, event, helper);
    },
    addNewRow : function(component, event, helper){
        helper.addDupRecord(component, event, helper);
    },
    removeRow : function(component, event, helper){
        var index = event.target.id;
        var allRowsList = component.get("v.dupAccountRecList");
        allRowsList.splice(index, 1);
        component.set("v.dupAccountRecList", allRowsList);
        component.set("v.dataLength",allRowsList.length);
    },
    saveData : function(component,event,helper){
        var winAccount = component.get("v.dupAccountRec");
        var dupList = component.get("v.dupAccountRecList");
        if(winAccount.Master_Account__c == null || winAccount.Master_Account__c == '' 
           || winAccount.Master_Account__c == undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "message": "Please select winning account."
            });
            toastEvent.fire();
            return false;
        }
        for(var i=0;i<dupList.length;i++){
            if(dupList[i].Duplicate_Account__c == null || dupList[i].Duplicate_Account__c == '' 
               || dupList[i].Duplicate_Account__c == undefined){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "message": "Please select duplicate account."
                });
                toastEvent.fire();
                return false;
            }
        }
        component.set("v.spinner",true);
        var action = component.get("c.createDuplicateAccounts");
        action.setParams({
            "winningAccount" : JSON.stringify(winAccount),
            "duplicateAccountData" : JSON.stringify(dupList)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.spinner",false);
                if(result.status == 'Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "message": result.message
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }else if(result.status == 'Error'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Error",
                        "message": result.message
                    });
                    toastEvent.fire();
                }
            }
            else if(state == 'ERROR'){
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
    cancelAction : function(component,event,helper){
        $A.get('e.force:refreshView').fire();
    },
})