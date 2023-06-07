global class MergeDuplicateAccounts implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query;
    global String accId;
    global MergeDuplicateAccounts(){
        //accId = 'a3T030000004jJPEAY';
        query = 'SELECT Id, Master_Account__c, Duplicate_Account__c FROM Account_Dups__c';
    }    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account_Dups__c> scope) {
        system.debug('scope'+scope);
        Map<Id,List<Account_Dups__c>> accATLMap = new Map<Id,List<Account_Dups__c>>();
        for(Account_Dups__c adc: scope){
            if (accATLMap.get(adc.Master_Account__c) == null)
            {
                // instantiate a new list
                accATLMap.put(adc.Master_Account__c, new List <Account_Dups__c> ());
            }
            // add the element to the list
            accATLMap.get(adc.Master_Account__c).add(adc);
        }        
        System.debug('accATLMap'+accATLMap);
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}