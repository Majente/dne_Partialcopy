({
    init: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'RecordName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Master Accounts', fieldName: 'Matser_Account', type: 'url', typeAttributes: {label: { fieldName: 'MatserAccount' }, target: '_blank'}},
            {label: 'Duplicate Accounts', fieldName: 'Duplicate_Account', type: 'url',typeAttributes: {label: { fieldName: 'DuplicateAccount' }, target: '_blank'}},
            {label: 'Number of Opportunity', fieldName: 'NumberOfOpportunity', type: 'Number'},
            {label: 'Last Activity Date', fieldName: 'LastActivityDate', type: 'Date/Time'}
        ]);
        
        var action=component.get('c.getaccountsDups');
        var recId = component.get('v.recordId');
        action.setParams({ 
            accId :  recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                var rows = response.getReturnValue();
                //alert(JSON.stringify(rows));
                for(var i=0; i<rows.length; i++)
                {
                    component.set("v.TempId",rows[i].accID);
                    var acId = component.get('v.TempId');
                    var recid = component.get("v.recordId");
                    //alert(recid);
                    //alert(JSON.stringify(acId));
                    rows.forEach(function(record){
                        
                        if(rows[i].MatserAccount === "")
                        {
                            record.Matser_Account = null;
                        }
                        else
                        {
                            record.Matser_Account = '/'+recid;
                        }
                        
                        if(rows[i].DuplicateAccount === "")
                        {
                            record.Duplicate_Account = null;
                        }
                        else
                        {
                            record.Duplicate_Account = '/'+acId;
                        }
                          if(rows[i].Name === "")
                        {
                            record.RecordName = null;
                        }
                        else
                        {
                            record.RecordName = '/'+acId;
                        }
                        
                    });
                    component.set("v.data", rows);   
                }
                }catch(e){
                    console.log(e.message);
                    }
            }
            
            else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
                // Show offline error
            }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
        });
        $A.enqueueAction(action);    
        
        component.set('v.maxRowSelection', 1);
        component.set('v.isButtonDisabled', true);
    },
    
    /*updateSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.selectedRowsCount', selectedRows.length);
    },*/
     handleSelect : function(component, event, helper) {
        
        var selectedRows = event.getParam('selectedRows'); 
         component.set("v.selectedRows", selectedRows);
        alert(JSON.stringify(selectedRows));       
        
    },
    
    processSelect : function(component, event, helper) {
       
        var action = component.get('c.selectedRow');
        action.setParams({ 
            selectList :   component.get("v.selectedRows")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('hi')
            }
            else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
                // Show offline error
            }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
        });
        $A.enqueueAction(action);    
        
    }
    
})