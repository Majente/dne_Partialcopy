trigger LeadDataTrigger on Lead (before insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            system.debug('Entering in handler ###'+trigger.new);
            LeadDataTriggerHandler.leadDataSetMethod(trigger.new);
        }
    }
}