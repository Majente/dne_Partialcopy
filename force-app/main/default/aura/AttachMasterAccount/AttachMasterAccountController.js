({
    handleSearch : function(component, event, helper) {
        var recName = component.get("v.accountName");
        var action = component.get("c.setMasterAccount");
        if(recName!=null){
            var selectAcc = '';
            component.set("v.SelectedAccount",selectAcc);
            action.setParams({
            accName:recName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue() ;
                //alert(JSON.stringify(result));
                component.set("v.supplierData",result);
            }else{
                //alert(JSON.stringify(response.getError()));
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please enter Account Name',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
       
    },
    handleCheckbox : function(component, event, helper) {
        var selectedId='';
        selectedId = event.target.getAttribute('id');
        //alert('selectedId:'+selectedId);
        if(document.getElementById(selectedId).checked && component.get("v.SelectedAccount").indexOf(selectedId) < 0){
            component.get('v.SelectedAccount').push(selectedId);
        }else{
            var index = component.get("v.SelectedAccount").indexOf(selectedId);
            if (index > -1) {
                component.get("v.SelectedAccount").splice(index, 1); 
            }
        }
         console.log('SelectedAccount:'+component.get("v.SelectedAccount"));
    },
    handleCreate : function(component, event, helper) {
        var SelectedAccount = component.get("v.SelectedAccount");
        //alert(SelectedAccount.length);
        if(SelectedAccount.length>1){
        component.set("v.openPopup",true);
        }else{
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please Select Account',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    closeModel : function(component, event, helper) {
        component.set("v.openPopup", false);
    },
    likenClose : function(component, event, helper) {
        var SelectedAccount = component.get("v.SelectedAccount");
        var masterAccountName = component.get("v.masterAccountName");
        if(masterAccountName != null){
            var action = component.get("c.attechedMaster");
            action.setParams({
                "masterAccName":masterAccountName,
                "SupplierAccount" : SelectedAccount
            });
            action.setCallback(this, function(response) {            
                if(response.getState()=="SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Master Account Inserted',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });                
                    toastEvent.fire();                
                    component.set("v.openPopup", false);            }
                else{
                    console.log(response.getError());
                }
            })
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please Enter Master Account Name',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
})