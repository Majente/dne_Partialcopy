/**************************************************
* Name : ContentDocumentLinkTriggerMaster
* Author: Soljit NA
* Date: 2019-05-16
* 
* Description: Trigger on the ContentDocumentLink object to do rollup on lead and account initially
*
****************************************************/
public Without Sharing class  ContentDocumentLinkTriggerMaster {
    
    public static void beforeInsert(List<ContentDocumentLink> newList){
        
    }
    
    public static void afterInsert(List<ContentDocumentLink> newList){
        collectLeadAndAccountIds(newList);
    }
    
    public static void beforeUpdate(Map<Id,ContentDocumentLink> newMap,Map<Id,ContentDocumentLink> oldMap){
        
    }
    
    public static void afterUpdate(Map<Id,ContentDocumentLink> newMap,Map<Id,ContentDocumentLink> oldMap){
        
    }
    
    public static void beforeDelete(List<ContentDocumentLink> oldList){
        
    }
    
    public static void afterDelete(List<ContentDocumentLink> oldList){
        collectLeadAndAccountIds(oldList);
    }
    
    public static void afterUndelete(List<ContentDocumentLink> newList){
        collectLeadAndAccountIds(newList);
    }
    
    // Collecting Id of Account and Lead
    public static void collectLeadAndAccountIds(List<ContentDocumentLink> cdlList){
        Set<Id> sObjectIdSet = new Set<Id>();
        for(ContentDocumentLink cdl : cdlList){
            // If LinkedEntityId is of Lead or Account
            if(cdl.LinkedEntityId.getSobjectType() == Account.SobjectType || 
               cdl.LinkedEntityId.getSobjectType() == Lead.SobjectType ){
                sObjectIdSet.add(cdl.LinkedEntityId);
            }
        }
        populateRollUpOnAccountAndLead(sObjectIdSet); // Calling method to populate rollup on the Lead and Account
    }
    
    
    // Method to populate file count on the SObject (Account , Lead)
    public static void populateRollUpOnAccountAndLead(Set<Id> sObjectIds){
        List<Sobject> objectToUpdate = new List<Sobject>();
        Set<Id> objectForZeroCount = new Set<Id>(sObjectIds);
        if(sObjectIds.isEmpty()){
            return;
        }
        for(AggregateResult ar : [SELECT count(Id) totalCount,LinkedEntityId 
                                  FROM ContentDocumentLink WHERE LinkedEntityId IN :sObjectIds GROUP BY LinkedEntityId]){
            System.debug(ar.get('totalCount'));
            System.debug(ar.get('LinkedEntityId'));    
                                      
            Id sObjectId = (Id)ar.get('LinkedEntityId');
            sObject sObj = sObjectId.getSObjectType().newSObject(sObjectId);
            sObj.put('Number_of_file__c',ar.get('totalCount'));
            objectToUpdate.add(sObj);
            objectForZeroCount.remove(sObjectId);
        }
        // Putting Count zero for objects where no Content Document Link remaining
        for(Id sObjectId : objectForZeroCount){
            sObject sObj = sObjectId.getSObjectType().newSObject(sObjectId);
            sObj.put('Number_of_file__c',0);
            objectToUpdate.add(sObj);
        }
        
        // Updating records
        if(objectToUpdate.size() > 0){
            UPDATE objectToUpdate;
        }
    }
}