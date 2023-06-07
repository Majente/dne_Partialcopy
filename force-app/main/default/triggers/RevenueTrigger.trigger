trigger RevenueTrigger on Invoice__c (before Update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        List<Invoice__c> invList = new List<Invoice__c>();
        List<Invoice__c> canInvList = new List<Invoice__c>();
        for(Invoice__c inv : Trigger.New){
            if((inv.Received_Amount__c != Trigger.oldMap.get(inv.Id).Received_Amount__c) || ((inv.Amount__c != Trigger.oldMap.get(inv.Id).Amount__c) && inv.Processed__c)){
                invList.add(inv);
            }
        }
        for(Invoice__c inv : Trigger.New){
            if(((inv.Amount__c != Trigger.oldMap.get(inv.Id).Amount__c) && inv.Processed__c == false) && inv.Amount__c != 0){
                canInvList.add(inv);
            } 
        }
        System.debug('invList.size() ::: ' + invList.size());
        System.debug('invList ::: ' + invList);
        if(invList.size() > 0){
            RevenueTriggerHandler.updateRevenuePaymentStatus(invList);            
        }
        if(canInvList.size() > 0){
            RevenueTriggerHandler.updateCancelledRevenue(canInvList);            
        }
    }
    
}