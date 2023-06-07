global class DuplicateAccountDataBatc implements Database.Batchable<sObject> {
    global string query;
    global DuplicateAccountDataBatc(){
        query = 'SELECT Id, Name, Is_Processed__c FROM Account where Is_Processed__c = false';
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        system.debug('accListData'+accList.size());
        Map<string,Account> accoutMap = new Map<string,Account>();
        Set<String> accNames = new Set<String>();
        for(Account acc : accList) {        
            accoutMap.put(acc.Name, acc);
        }
        try {
            system.debug('accoutMap'+accoutMap);
            AggregateResult[] duplicatedAcc = [SELECT Name, COUNT(Id) FROM Account WHERE Id IN :accoutMap.values() GROUP BY Name HAVING COUNT(Name) > 1];
            system.debug('duplicatedAcc'+duplicatedAcc);
            system.debug('duplicatedAcc'+duplicatedAcc.size());
            for (AggregateResult duplicateaAct : duplicatedAcc)
            {    
                accNames.add(duplicateaAct.get('Name').toString());
            }
           
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}