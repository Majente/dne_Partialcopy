trigger QuoteTrigger on SBQQ__Quote__c (before Update) {    
    for(SBQQ__Quote__c quote : trigger.new) {
         quote.SBQQ__EndDate__c = null;
        System.debug('Before update quote ::: ' + quote); 
    }
}