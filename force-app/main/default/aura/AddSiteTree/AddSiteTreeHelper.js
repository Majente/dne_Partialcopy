({ 
    originalData: [],
    
    addChildrenToRow: function(data, rowName, children) {
        var that = this;

        // step through the array using recursion until we find the correct row to update
        var newData = data.map(function(row) {
            // does this row have a properly formatted _children key with content?
            var hasChildrenContent = false;
            if (row.hasOwnProperty('_children') && Array.isArray(row._children) && row._children.length > 0) {
                hasChildrenContent = true;
            }

            if (row.name === rowName) {
                row._children = children;
            } else if (hasChildrenContent) {
                that.addChildrenToRow(row._children, rowName, children);
            }

            return row;
        });

        return newData;
    },

    retrieveUpdatedData: function(cmp, event, helper,rowName,status) {
        var that = this;
		      
        var originalData = this.originalData ;
        var action = cmp.get("c.getSiteList");
        var recordId = cmp.get("v.applicantId");
        console.log("recordId  == "+recordId);
        action.setParams({  parentID : rowName ,oppId: recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                
                var accLists = response.getReturnValue();				
				var childrenData = [] ;                
                accLists.forEach(function(value,key){
                    
                    value.name = value.Id ;
                    value.fieldName = value.Name ;
                    value.accountOwner = '/'+value.Id;
                    value.accountOwnerName = value.Name;
                    if ( value.hasOwnProperty('Market__r') ) {
                        value.Market__c = value.Market__r.Name ;
                    }else{
                        value.Market__c = '' ;
                    }
                    
                    value._children = [] ;                    
                    childrenData.push(value);                    
                });                
                     
                var updatedData = that.addChildrenToRow(originalData, rowName, childrenData);        
                //resolve(updatedData);
                cmp.set('v.gridData', updatedData);
                this.originalData = updatedData ;
                cmp.set('v.isLoading', false);
                
                if(status){
                    
                    if(childrenData.length){
                        var gridExpandedRows = cmp.get("v.gridExpandedRows");        
                        gridExpandedRows.push(rowName);
                        cmp.set("v.gridExpandedRows",gridExpandedRows);                   
                                            
                        childrenData.forEach(function(val,key){                            
                            var selectededRows = cmp.get("v.selectededRows");        
                            if(selectededRows.indexOf(val.Id)<0){
                                selectededRows.push(val.Id);
                            }                            
                            cmp.set("v.selectededRows",selectededRows); 
                        });
                    } 
                    
                }
            
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    getSiteList:function(cmp, event, helper,parentID){
        
        var action = cmp.get("c.getServiceAccountByOpportunity");
        
        action.setParams({  parentID : parentID });
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                
                var accLists = response.getReturnValue();
                 
				var accountData = [] ;
                
                accLists.forEach(function(value,key){
                    value.name = value.Id ;
                    value.fieldName = value.Name ;
                    value.accountOwner = '/'+value.Id;
                    value.accountOwnerName = value.Name;
                    if ( value.hasOwnProperty('Market__r') ) {
                        value.Market__c = value.Market__r.Name ;
                    }else{
                        value.Market__c = '' ;
                    }
                    
                    value._children = [] ;                    
                    accountData.push(value);                    
                });                
                cmp.set('v.gridData', accountData);             
                this.originalData = accountData ;
            }
        });
        
        $A.enqueueAction(action);  
        
    },
    
    saveSelectedSIteData:function(cmp, event, helper){
        var selectedRows = cmp.find('treegrid_async').getSelectedRows();
        
        var accountIds = [] ;
        selectedRows.forEach(function(value,key){
            accountIds.push(value.Id);
        });
        
        console.log(accountIds);
        var saveSites = cmp.get("c.saveSitesdata");  
        var recordId = cmp.get("v.applicantId");
        console.log("recordId  == "+recordId);
        saveSites.setParams({  siteIds : accountIds, oppId: recordId  });
                
        saveSites.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(response);
                var res = response.getReturnValue();
                console.log('*************');
                console.log(res);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": 'ALERT',
                    "message": res,
                });
                toastEvent.fire(); 
               var sObjectEvent = $A.get("e.force:navigateToSObject");
               sObjectEvent.setParams({
                   "recordId": recordId                   
               })
               sObjectEvent.fire();
            }          
        });
                
        $A.enqueueAction(saveSites);
        
    },
    
     findUnique:function(cmp, event, helper,array1,array2){
        var unique = [];
        for(var i = 0; i < array1.length; i++){
            var found = false;
            
            for(var j = 0; j < array2.length; j++){ // j < is missed;
                if(array1[i] == array2[j]){
                    found = true;
                    break; 
                }
            }
            if(found == false){
                unique.push(array1[i]);
            }
        }
        return unique ; 
    },
    
    hasChildren:function(cmp, event, helper,currentRow){
        var gridDatas = cmp.get('v.gridData');
        var child= false ;
        for(var i = 0; i<gridDatas.length; i++){
            if(gridDatas[i].Id==currentRow){
                var children = gridDatas[i]._children ; 
                if(children.length){
                    
                    child= true ;
                    var gridExpandedRows = cmp.get("v.gridExpandedRows");        
                    gridExpandedRows.push(currentRow);
                    cmp.set("v.gridExpandedRows",gridExpandedRows);
                    
                    children.forEach(function(val,key){
                        var selectededRows = cmp.get("v.selectededRows");        
                        if(selectededRows.indexOf(val.Id)<0){
                            selectededRows.push(val.Id);
                        }
                        cmp.set("v.selectededRows",selectededRows);
                    });
                    
                    //break;
                }                    
            }
        }
        return child ; 
        
    }
    
    
    
}) // eslint-disable-line