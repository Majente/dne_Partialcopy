trigger LeadTrigger on Lead (before insert, before update, after insert, after update)
{    
    Map<String,Id> queueMap = LeadTriggerHandler.queryLeadQueues(); 
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            //LeadTriggerHandler.onSubstatusUpdate(Trigger.new, queueMap);
            LeadTriggerHandler.onStatusUpdate(Trigger.new, queueMap);
            LeadTriggerHandler.onOwnerUpdate(Trigger.new, queueMap);
        }

        if(Trigger.isUpdate)
        {
            /*LeadTriggerHandler.onSubstatusUpdate(Trigger.new, queueMap);
            LeadTriggerHandler.validateOnUpdate(Trigger.new);*/
            LeadTriggerHandler.onStatusUpdate(Trigger.new, queueMap);
            LeadTriggerHandler.onOwnerUpdate(Trigger.new, queueMap);
        }
    }

    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            LeadTriggerHandler.createCallbackEvent(Trigger.new);
        }

        if(Trigger.isUpdate)
        {
            LeadTriggerHandler.createCallbackEvent(Trigger.new);
        }
    }
}