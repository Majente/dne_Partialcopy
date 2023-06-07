trigger QuoteLineTrigger2 on SBQQ__QuoteLine__c (after insert, after update) {
    List<string> qliSet = new List<string>();
    for(SBQQ__QuoteLine__c qli: trigger.new){
        qliSet.add(qli.id);
    }
QuoteLineTriggerHandler.updateOli(qliSet);
}