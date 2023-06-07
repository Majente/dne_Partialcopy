trigger TaskTrigger on Task (after insert, after update, after delete) 
{
    if (Trigger.isBefore) 
    {} 
    
    else if (Trigger.isAfter) {
        if(Trigger.isDelete){
            TaskTriggerHelper.lastActivityDate(Trigger.old);                    
        }
        else{
            TaskTriggerHelper.lastActivityDate(Trigger.new);                                
        }        
        TaskTriggerHelper.populateDNELastActivityDate();	    	
    }
}