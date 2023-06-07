trigger DNE_SubscriptionTrigger on SBQQ__Subscription__c (before insert, after insert, after update,before Update) 
{
    if(Trigger.isBefore)
    {
        system.debug('is before:::');
        if(Trigger.isInsert)
        {
            system.debug('is before insert:::');
            //DNE_SubscriptionTriggerHelper.populateCommissionHierarchy();     Commented on Date 10/10/2019
            	DNE_SubscriptionTriggerHelper.populateListPriceInCustomMarjin();
            	DNE_SubscriptionTriggerHelper.populateDNEAdminFeeFromContract();
            	DNE_SubscriptionTriggerHelper.populateOriginalAmountQuantityvolume();
            //DNE_SubscriptionTriggerHelper.checkAmendmentBeforeInsert(Trigger.new);            
        }
        if(Trigger.isUpdate)
        {
            system.debug('is before update:::');
            DNE_SubscriptionTriggerHelper.populateCustomMarjinInListPrice();
            //DNE_SubscriptionTriggerHelper.updateAnnualQuantity(trigger.OldMap, trigger.NewMap);
        }
    }
    // -------------------
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
          //DNE_SubscriptionTriggerHelper.checkAmendment(Trigger.new);  
         DNE_SubscriptionTriggerHelper.createInvoiceAndCommissions(Trigger.new);   
        }
        if(Trigger.isUpdate)
        {
            //DNE_SubscriptionTriggerHelper.fixInvoicesOnResolution();
            DNE_SubscriptionTriggerHelper.updateRevenue(trigger.OldMap, trigger.NewMap);
           // DNE_SubscriptionTriggerHelper.recalculateCommissions();            
           // DNE_SubscriptionTriggerHelper.cancelCommissions();            
        }
    }
}