({
    
	navigate : function(component,event) {
       /* var urlEvent = $A.get("e.force:navigateToURL");
       urlEvent.setParams({
           "url": '/lightning/n/Applications/?id='+component.get('v.recordId')
       });
       urlEvent.fire();
       */
       
       var evt = $A.get("e.force:navigateToComponent");
       console.log('evt'+evt);
       evt.setParams({
           componentDef: "c:AddSiteTree",
           componentAttributes :{
               applicantId:component.get('v.recordId')
           }
       });
       
       evt.fire();
		
	}
})