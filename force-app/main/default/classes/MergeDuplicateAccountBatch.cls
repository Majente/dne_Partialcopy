global class MergeDuplicateAccountBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global MergeDuplicateAccountBatch(){
        query = 'SELECT Id,Name,Duplicate_Account__c,Master_Account__c FROM Account_Dups__c';
    }
    // Batch Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    
    //Batch Execute Method
    global void execute(Database.BatchableContext BC, List<Account_Dups__c> duplicateData){
        System.debug('duplicateData^^' + duplicateData.size());
        if(duplicateData.size() > 0){
            Map<String,List<Id>> parentWithDuplicateMap = new Map<String,List<Id>>();
            for(Account_Dups__c accDup : duplicateData){
                if(!parentWithDuplicateMap.containsKey(accDup.Master_Account__c)){
                    parentWithDuplicateMap.put(accDup.Master_Account__c,new List<Id>());
                }
                parentWithDuplicateMap.get(accDup.Master_Account__c).add(accDup.Duplicate_Account__c);
            }
            System.debug('parentWithDuplicateMap^^' + parentWithDuplicateMap.size());
            if(parentWithDuplicateMap.size() > 0){
                for(String masterId : parentWithDuplicateMap.keySet()){
                    MergeUtility.mergeData(masterId,parentWithDuplicateMap.get(masterId));
                }
            }
        }
    }
    
    // Finish Method
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('#### job^^' + job);
        System.debug('#### MergeDuplicateAccountBatch Finished.');
    }
}