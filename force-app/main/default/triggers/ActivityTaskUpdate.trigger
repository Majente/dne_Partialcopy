trigger ActivityTaskUpdate on Task (After insert, After update) {
    List<Id> LeadIds = new List<Id>();
    List<Lead> LeadList = new List<Lead>();
    
    for(Task t :trigger.new)
    {
        if(t.whoId!=null)
        {
            Schema.SObjectType tType= t.whoId.getSObjectType();
            if(tType == Lead.Schema.SObjectType)
            {
                LeadIds.add(t.WhoId);
            }
        }
    }
    

        
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