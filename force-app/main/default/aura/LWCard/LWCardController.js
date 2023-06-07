({
    doInit : function(component,event,helper) {
    var action=component.get('c.fetchAccount');
         action.setParams({
            "recordId": 'a3T030000004irFEAQ'
        });
    action.setCallback(this,function(response){
    var state=response.getState();
        
    
    var response1=response.getReturnValue();
    if(state =="SUCCESS")
    {
       //alert(response1);
       component.set("v.accountList",response1);
    }
 
});
$A.enqueueAction(action);
        }
})