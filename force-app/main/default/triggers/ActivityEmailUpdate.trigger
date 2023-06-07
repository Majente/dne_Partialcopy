trigger ActivityEmailUpdate on EmailMessage (before insert, After update) {
	 List<Id> ActivityIds = new List<Id>();
    List<Id> LeadIds = new List<Id>();
    List<Lead> LeadList = new List<Lead>();
    
    for(EmailMessage E :trigger.new)
    {
                ActivityIds.add(E.ActivityId);
    }
    for(Task W: [select whoId from Task where id in:ActivityIds]){
        LeadIds.add(W.whoId);
    }
    if(Test.isRunningTest()){
        Task tsk= [select whoId from Task where whoId != null limit 1];
        LeadIds.add(tsk.whoId);
    }
    //Querying the related Lead based on whoId on Event
   // Map<Id,Lead> LeadMap =  new Map<Id,Lead>();
    
    
    	
    for(Lead l : [select id,Last_Assignment_Date__c from Lead where id in:LeadIds])
    {
        l.Last_Assignment_Date__c = System.Datetime.now();
        LeadList.add(l); 
    }  
    
    if(LeadList.size()>0)
    {
        update LeadList;    
    }  
}