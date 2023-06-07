global class FindDuplicateAccountFuzzyMatchBatchTemp implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global String accRecordType;
    global Set<String> allProcessedAccounts;
    global FindDuplicateAccountFuzzyMatchBatchTemp(){
        allProcessedAccounts = new Set<String>();
        accRecordType = 'Account';
        query = 'SELECT Id, Name,RecordType.Name FROM Account WHERE RecordType.Name =: accRecordType';
    }
    global FindDuplicateAccountFuzzyMatchBatchTemp(String accId){
        allProcessedAccounts = new Set<String>();
        accRecordType = 'Account';
        query = 'SELECT Id, Name,RecordType.Name FROM Account WHERE RecordType.Name =: accRecordType ANd id = '+ accId;
    }
    global FindDuplicateAccountFuzzyMatchBatchTemp(Integer noOfRecords){
        allProcessedAccounts = new Set<String>();
        accRecordType = 'Account';
        query = 'SELECT Id, Name,RecordType.Name FROM Account WHERE RecordType.Name =: accRecordType Limit '+ noOfRecords;
    }
    // Batch Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    
    //Batch Execute Method
    global void execute(Database.BatchableContext BC, List<Account> acctList)
    {
        
        Datacloud.FindDuplicatesResult[] duplicateAccountRes;
        String acctName;
        String Key;
        List<String> dupeAccounts = new List<String>();
        Set<String> unqueKey = new Set<String>();
        Map<String,Integer> accIdWithOppCount = new Map<String,Integer>();
        List<Account_Dups__c> dupplicateRecords = new List<Account_Dups__c>();
        Map<String,Account_Dups__c> exitingRecords = new Map<String,Account_Dups__c>();
        if(acctList.size() > 0  && !allProcessedAccounts.contains(acctList[0].Id))
        {
            dupeAccounts.add(acctList[0].ID);
            duplicateAccountRes = Datacloud.FindDuplicates.findDuplicates(acctList);
            
            for (Datacloud.FindDuplicatesResult findDupeResult : duplicateAccountRes) {
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            acctName = String.ValueOf(matchRecord.getRecord().get('Id'));
                            System.debug('Duplicate Record: ' + matchRecord.getRecord() + '===' + matchRecord.getMatchConfidence());
                            
                            if(matchRecord.getMatchConfidence() >= 70 && !dupeAccounts.contains(acctName))
                            {
                                dupeAccounts.add(acctName);
                                allProcessedAccounts.add(acctName);
                            }
                        }
                    }
                }
            }
            allProcessedAccounts.add(acctList[0].Id);
            
            System.debug('=duplicateAccountIds=' + dupeAccounts);
            Map<String,Id> accountWithMasterRecord = new Map<String,Id>();
            String masterRecId = '';
            if(!dupeAccounts.isEmpty()){
                List<AggregateResult> aggList = [Select count(id) cnt, AccountId, Account.LastActivityDate lad from Opportunity group by AccountId, Account.LastActivityDate having AccountId in :dupeAccounts order by count(id) desc];
                system.debug('=aggList=' + aggList);
                Set<String> accIds = new Set<String>();
                Map<Id, Date> accountToDateMap = new Map<Id, Date>();
                if(!aggList.isEmpty())
                {
                    accIds.add(String.valueOf(aggList[0].get('AccountId')));
                    accIdWithOppCount.put(String.valueOf(aggList[0].get('AccountId')), Integer.valueOf(aggList[0].get('cnt')));
                    accountToDateMap.put(String.valueOf(aggList[0].get('AccountId')), Date.valueOf(aggList[0].get('lad')));
                    for(Integer i = 1; i < aggList.size(); i++)
                    {
                        accountToDateMap.put(String.valueOf(aggList[i].get('AccountId')), Date.valueOf(aggList[i].get('lad')));
                        accIdWithOppCount.put(String.valueOf(aggList[i].get('AccountId')), Integer.valueOf(aggList[i].get('cnt')));
                        if(aggList[0] == aggList[i])
                        {
                            accIds.add(String.valueOf(aggList[i].get('AccountId')));
                        }                         
                    }
                }
                
                if(!accIds.isEmpty())
                {
                    for(Account acc : [Select id, LastActivityDate from Account where id in :accIds order by LastActivityDate desc limit 1])
                    {
                        masterRecId = acc.Id;
                    }
                }
                else if(!dupeAccounts.isEmpty())
                {
                    Integer count = 0;
                    for(Account acc : [Select id, LastActivityDate from Account where id in :dupeAccounts order by LastActivityDate desc])
                    {
                        if(count == 0){
                            masterRecId = acc.Id;
                        }
                        count++;
                        accountToDateMap.put(acc.Id , acc.LastActivityDate);
                    }
                }
                
                for(Id acctId : dupeAccounts){
                    if(acctId != masterRecId){ 
                       unqueKey.add(String.valueOf(masterRecId) + String.valueOf(acctId));
                    }
                }
                // Find existing records
                for(Account_Dups__c ad:  [SELECT Id, Unique_Account_Id__c FROM Account_Dups__c Where Unique_Account_Id__c IN: unqueKey]){
                    exitingRecords.put(ad.Unique_Account_Id__c,ad);
                }
                for(Id acctId : dupeAccounts){
                    if(acctId != masterRecId){
                        Key = String.valueOf(masterRecId) + String.valueOf(acctId);
                        if(!exitingRecords.containsKey(key))
                        {
                            Account_Dups__c dupRec = new Account_Dups__c(); 
                            dupRec.Master_Account__c = masterRecId;
                            dupRec.Duplicate_Account__c = acctId;
                            dupRec.Last_Activity_Date__c = accountToDateMap.containsKey(acctId) ? accountToDateMap.get(acctId):System.now();
                            dupRec.Unique_Account_Id__c = Key;
                            dupRec.Number_of_Opportunity__c = accIdWithOppCount.get(acctId);   
                            dupplicateRecords.add(dupRec);
                        }
                    }
                }
            }
        }
        try{
            if(dupplicateRecords.size() > 0){
                
                Database.SaveResult[] srList = Database.insert(dupplicateRecords, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted record. Record ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }catch(Exception ex){
            System.debug('exception occured on creation^^' + ex.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('#### job^^' + job);
        System.debug('#### FindDuplicateAccountBatch Finished.');
    }
}