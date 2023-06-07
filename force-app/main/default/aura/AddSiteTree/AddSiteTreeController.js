({ // eslint-disable-line
    
    
    
    init: function (cmp, event, helper) {
        
        var recordId = cmp.get("v.applicantId");
        
        console.log("recordId"+recordId);
       var columns = [
            {
                type: 'url',
                fieldName: 'accountOwnerName',
                label: 'Account',
                typeAttributes: {
                    label: { fieldName: 'accountOwnerName' }
                }
            },
            {
                type: 'String',
                fieldName: 'Market__c',
                label: 'Market'
            },
            {
                type: 'number',
                fieldName: 'Volume__c',
                label: 'Volume'
            },
            {
                type: 'Picklist',
                fieldName: 'Type__c',
                label: 'Type'                
            }
            ,
            {
                type: 'Picklist',
                fieldName: 'Unit_of_Measure__c',
                label: 'Unit Of Measure'                
            }
             
        ];

        cmp.set('v.gridColumns', columns);
        helper.getSiteList(cmp, event, helper,recordId);
    },

    saveSites:function(cmp, event, helper) {
        helper.saveSelectedSIteData(cmp, event, helper);
        
    },
    
    handleRowToggle: function(cmp, event, helper) {
               
        // retrieve the unique identifier of the row being expanded
        var rowName = event.getParam('name');
        
         
		var selectedRows = cmp.find('treegrid_async').getSelectedRows();
        
        //console.log(selectedRows);
        
        // the new expanded state for this row
        var isExpanded = event.getParam('isExpanded');

        // does the component have children content for this row already?
        var hasChildrenContent = event.getParam('hasChildrenContent');
       
        // the complete row data
        var row = event.getParam('row');

        // the row names that are currently expanded
        var expandedRows = cmp.find('treegrid_async').getCurrentExpandedRows();

        // if hasChildrenContent is false then we need to react and add children
        if (hasChildrenContent === false) {
            cmp.set('v.isLoading', true);

            // call a method to retrieve the updated data tree that includes the missing children
            helper.retrieveUpdatedData(cmp, event, helper,rowName,false) ;
            
        }
        
        
    },
    
    handleRowSelectionNew: function(cmp, event, helper) {
           
        var selectededRowsOld = cmp.get('v.selectededRows') ;
        var selectedRowsNewData = cmp.find('treegrid_async').getSelectedRows();
        
        var selectedRowsNew = [] ; 
        if(selectedRowsNewData.length>0){
            selectedRowsNewData.forEach(function(val,key){
                selectedRowsNew.push(val.Id);
            });
        }
        
        console.log('selectededRowsOld'+selectededRowsOld);
        console.log('selectedRowsNew'+selectedRowsNew);
        
        var currentRow = '' ;
        var currentRowStatus = '' ;
        var hasChild = false ;
      
        
        
        if(selectededRowsOld.length<selectedRowsNew.length){
            currentRowStatus = 'checked' ;
            currentRow = helper.findUnique(cmp, event, helper,selectedRowsNew,selectededRowsOld);
            //console.log('currentRow checked : '+currentRow[0]);
            selectededRowsOld.push(currentRow[0]);
            cmp.set('v.selectededRows',selectededRowsOld) ;
            
            hasChild = helper.hasChildren(cmp, event, helper,currentRow[0]) ;
            
            if(!hasChild){
                helper.retrieveUpdatedData(cmp, event, helper,currentRow[0],true) ;
            }         
            
        }else{
            currentRowStatus = 'unchecked' ;
            currentRow = helper.findUnique(cmp, event, helper,selectededRowsOld,selectedRowsNew);
            //console.log('currentRow unchecked :'+currentRow);             
            
            var gridDatas = cmp.get('v.gridData');
            for(var i = 0; i<gridDatas.length; i++){
                if(gridDatas[i].Id==currentRow[0]){
                    var children = gridDatas[i]._children ; 
                    if(children.length){
                        children.forEach(function(cVal,cKey){
                            var indx = selectededRowsOld.indexOf(cVal.Id) ;                
							selectededRowsOld.splice(indx,1);
                        });
                    }                    
                }
            }
            
            var indx = selectededRowsOld.indexOf(currentRow[0]) ;                
			selectededRowsOld.splice(indx,1);             
            cmp.set('v.selectededRows',selectededRowsOld) ; 
            
            
            
        }
                        
    },
    
    handleRowSelection: function(cmp, event, helper) {
        
        var selectedRows = cmp.find('treegrid_async').getSelectedRows();
        var accountIds = [] ;
        var temp ;
        console.log('grid datas = '+JSON.stringify(cmp.get('v.gridData')));
        console.log('selectedRows = '+JSON.stringify(selectedRows));        
        console.log('grid datas _children = '+JSON.stringify(cmp.get('v.gridData')[0]._children));
       
        var gridDatas = cmp.get('v.gridData');
        var selectedData = [];
        /*for(var i = 0; i<gridDatas.length; i++){
            for(var j = 0; j<selectedRows.length; j++){
                if(gridDatas[i].name == selectedRows[j].name){
                    //gridDatas[i]._children.Selected = true;
                        var childrenData = gridDatas[i]._children;
                        selectedData.push(gridDatas[i].Id);
                        for(var k=0; k<childrenData.length; k++){
                            selectedData.push(childrenData[k].Id);
                        }
                    //selectedData.push(gridDatas[i]._children.Id);
                }
            } 
        }
        cmp.set("v.gridExpandedRows",selectedData);
        */
        var selectedMarket = cmp.get("v.selectedMarket");
        cmp.set("v.selectedMarket",selectedMarket.trim());
        selectedRows.forEach(function(value,key){
            selectedMarket = (value.Market__c).trim() ;
            //cmp.set("v.selectedMarket",selectedMarket.trim());
            accountIds.push(value.Id);
            temp = value.Id;
            
            
        });
        var lightningAppExternalEvent = $A.get("e.c:lightningAppExternalEvent");
	    	lightningAppExternalEvent.setParams({'data':accountIds});
	    	lightningAppExternalEvent.fire();
     
    },
    callExternalFunction : function(component, event, helper){
			console.log('Inside lightning controller function-->callExternalFunction');
			var lightningAppExternalEvent = $A.get("e.c:lightningAppExternalEvent");
	    	lightningAppExternalEvent.setParams({'data':component.get('Test')});
	    	lightningAppExternalEvent.fire();
	},
    
}) // eslint-disable-line