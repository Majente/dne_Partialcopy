trigger AssumptionTrigger on Assumption__c (before insert, before update) {
    //To check identical records
    if(Trigger.IsInsert || Trigger.IsUpdate){
        AssumptionTriggerHandler.checkStatusLead(Trigger.new);
    }
 }