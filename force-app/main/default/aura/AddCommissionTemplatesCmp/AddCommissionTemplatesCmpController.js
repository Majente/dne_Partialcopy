({
	/*doInit : function(component, event, helper)
    {
    	var theCommTemplateList = [];

		theCommTemplateList.push({'sobjectType':'DNE_Commission_Hierarchy__c','Type__c':'New'});
		theCommTemplateList.push({'sobjectType':'DNE_Commission_Hierarchy__c','Type__c':'Renewal'});

		component.set('v.commissionHierarchyList',theCommTemplateList);
    },
    //---------------------------------
    
    addCommissionTemplate : function(component, event, helper)
    {
    	var commTemplateList = component.get("v.commissionHierarchyList");
		commTemplateList.push({'sobjectType':'DNE_Commission_Hierarchy__c','Type__c':'Retention'});

		component.set('v.commissionHierarchyList',commTemplateList);
    }*/

    doInit : function(component, event, helper)
    {
        var theCommHierList = [];

        theCommHierList.push({'sobjectType':'DNE_Commission_Hierarchy__c','Type__c':'New'});
        //theCommHierList.push({'sobjectType':'DNE_Commission_Hierarchy__c','Type__c':'Renewal'});

        component.set('v.commissionHierarchyList',theCommHierList);

        helper.loadTypeOptions(component);
    },
    //---------------------------------
    
    addRow : function(component, event, helper)
    {
        var commHierList = component.get("v.commissionHierarchyList");
        commHierList.push({'sobjectType':'DNE_Commission_Hierarchy__c','Type__c':'New'});

        component.set('v.commissionHierarchyList',commHierList);
        component.set("v.disableRemoveRowButton", false);
    },
    //---------------------------------
    
    removeRow : function(component, event, helper)
    {
        var commHierList = component.get("v.commissionHierarchyList");
        commHierList.pop();

        component.set('v.commissionHierarchyList',commHierList);
        component.set("v.disableRemoveRowButton", commHierList.length < 2);
    },
    //---------------------------------

    saveCommissionHierarchyListJSC : function(component, event, helper)
    {
        helper.saveCommissionHierarchyListJSH(component, event, helper);
    }/*,
    //---------------------------------

    saveAllJSC : function(component, event, helper)
    {
        var saveAllEvent = cmp.getEvent("saveAllEvent");
        saveAllEvent.fire();
    }*/
})