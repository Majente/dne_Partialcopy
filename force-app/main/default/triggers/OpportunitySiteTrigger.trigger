/**************************************************

* Class: OpportunitySiteTrigger
* Author: Soljit <VW>
* Date: 2019-09-10
* Description: OpportunitySiteTrigger for OpportunitySite

****************************************************/
trigger OpportunitySiteTrigger on Opportunity_Site__c (before delete, After Insert) {
    if(Trigger.isBefore && Trigger.isDelete){
        OpportunitySiteTriggerHandler.deleteQuoteLines(Trigger.old);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        OpportunitySiteTriggerHandler.insertQLIForOpportunitySites(Trigger.New);
    }
}