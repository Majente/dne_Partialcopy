trigger ActivityEventUpdate on Event (After insert, After update) {
    List<Id> LeadIds = new List<Id>();
    List<Lead> LeadList = new List<Lead>();
    
    for(Event E :trigger.new)
    {
        if(E.whoId!=null)
        {
            Schema.SObjectType EType= E.whoId.getSObjectType();
            if(EType == Lead.Schema.SObjectType)
            {
                LeadIds.add(E.WhoId);
            }
        }
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