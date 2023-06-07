({
    addDupRecord : function(component,event,helper) {
        var dupList = component.get("v.dupAccountRecList");
        dupList.push({
            "sobjectType" : "Account_Dups__c",
            "Duplicate_Account__c" : ""
        });
        component.set("v.dupAccountRecList",dupList);
        component.set("v.dataLength",dupList.length);
    },
})