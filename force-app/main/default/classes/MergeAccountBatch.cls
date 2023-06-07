global class MergeAccountBatch implements Database.Batchable<sObject> {
    global String query;
    global String RecordId;
    
    global MergeAccountBatch(){
        // collect the batches of records or objects to be passed to execute
        query = 'SELECT Id, Master_Account__c,Master_Account__r.Name,Duplicate_Account__c,Duplicate_Account__r.Name FROM Account_Dups__c';
    }
    global MergeAccountBatch(string RecID){
        RecordId = RecID;
        // collect the batches of records or objects to be passed to execute
        query = 'SELECT Id, Master_Account__c,Master_Account__r.Name,Duplicate_Account__c,Duplicate_Account__r.Name FROM Account_Dups__c';
        query += ' WHERE id =: RecordId';
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Pass query data's to the execution
        system.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account_Dups__c> accDupsList) {
        set<string> MasterId = new set<string>();
        set<string> DuplicateId = new set<string>();
        // process each batch of records default size is 200
        List<Account_Dups__c> dupList = new List<Account_Dups__c>();
        for(Account_Dups__c dups: accDupsList) { 
            if(dups.Master_Account__c != null && dups.Master_Account__c != dups.Duplicate_Account__c){
                MasterId.add(dups.Master_Account__c); //Store masterrecord id
            }
            if(dups.Duplicate_Account__c != null && dups.Duplicate_Account__c != dups.Master_Account__c){
                DuplicateId.add(dups.Duplicate_Account__c); //Store duplicate record id
            }
            dups.Is_Processed__c = true;
            dups.Merge_Duplicate_Record_Id__c = dups.Duplicate_Account__c;
            dupList.add(dups);
        }
        system.debug('dupList ::'+dupList);
        // Get all Account fields formatted for use in a SOQL query
        Map<String, Schema.SObjectField> AllLeadFields = Schema.getGlobalDescribe().get('Account').getDescribe().SObjectType.getDescribe().fields.getMap();
        
        List<String> accessiblefields = new List<String>();
        Map<string,string> FieldMap = new Map<string,string>();
        for(Schema.SObjectField field : AllLeadFields.values()){
            if(field.getDescribe().isAccessible() && field.getDescribe().isUpdateable()){
                if(field.getDescribe().getName() != 'IsPartner'){
                    accessiblefields.add(field.getDescribe().getName());
                    FieldMap.put(field.getDescribe().getName(), field.getDescribe().getLabel());
                }
            }
        }
        
        String allfields='';
        
        for(String fieldname : accessiblefields){
            allfields += fieldname+',';
        }
        
        allfields = allfields.subString(0,allfields.length()-1);
        
        
        //Query string to get all Master Account
        
        String masterAccountRecord = 'SELECT ' + allfields + ' FROM Account WHERE id IN: MasterId';
        
        
        // Query string to get all Duplicate Accounts
        String duplicatesAccRecords = 'SELECT ' + allfields + ' FROM Account WHERE id IN: DuplicateId';
        
        List<Account> masterAccounts = database.query(masterAccountRecord);
        
        Account masterAccount = masterAccounts[0];
        Id masterAccountID = masterAccount.Id;
        system.debug('masterAccount ::'+masterAccount);
        
        List<Account> duplicateAccounts = database.query(duplicatesAccRecords);
        system.debug('duplicateAccounts ::'+duplicateAccounts);
        // Go through the master and duplicate record fields, and update the master record where its fields are blank, 
        //but the duplicate's is populated
        
        //SObjectType AccountType = Schema.getGlobalDescribe().get('Account');
        // Map<String, Schema.sObjectField> mapFields = AccountType.getDescribe().fields.getMap();
        
        for(String fieldName : FieldMap.keySet())
        {
            if(masterAccount != null && duplicateAccounts != null){
                
                if(masterAccount.get(fieldName) == null && duplicateAccounts[0].get(fieldName) != null)
                {
                    system.debug('masterAccount.get(fieldName) :'+masterAccount.get(fieldName));
                    system.debug('duplicateAccounts[0].get(fieldName) :'+duplicateAccounts[0].get(fieldName));
                    masterAccount.put(fieldName, duplicateAccounts[0].get(fieldName));
                    system.debug('masterAccount :::'+masterAccount);
                }
            }
        }
        //Update Master Account and Duplicate account for reset dependancy
        List<Account> UpdateMasterAcc = new List<Account>();
        for(Account MasterAcc: masterAccounts){
            MasterAcc.ParentId = null;
            MasterAcc.Account_site__c = null;
            UpdateMasterAcc.add(MasterAcc);
        }
        List<Account> UpdateDuplicateAcc = new List<Account>();
        for(Account DuplicateAcc: duplicateAccounts){
            DuplicateAcc.ParentId = null;
            DuplicateAcc.Account_site__c = null;
            UpdateDuplicateAcc.add(DuplicateAcc);
        }
        //Remove Deactivated account-contact relationship from assigned contacts of master account
        Set<id> contactIdSet = new Set<id>();
        for(Contact con: [SELECT Id, AccountId FROM Contact WHERE AccountId IN: MasterId]){
            contactIdSet.add(con.id);
        }
        List<AccountContactRelation> DeleteMasterConRelations = new List<AccountContactRelation>();
        for(AccountContactRelation rel: [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE ContactId IN: contactIdSet]){
            if(DuplicateId.contains(rel.AccountId)){
                DeleteMasterConRelations.add(rel);
            }
        }
        //Remove Deactivated account-contact relationship from assigned contacts of duplicate account
        Set<id> dupscontactIdSet = new Set<id>();
        for(Contact con: [SELECT Id, AccountId FROM Contact WHERE AccountId IN: DuplicateId]){
            dupscontactIdSet.add(con.id);
        }
        List<AccountContactRelation> DeleteDupsConRelations = new List<AccountContactRelation>();
        for(AccountContactRelation rel: [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE ContactId IN: dupscontactIdSet]){
            if(MasterId.contains(rel.AccountId)){
                DeleteDupsConRelations.add(rel);
            }
        }
        //DML's for delete relations
        if(DeleteMasterConRelations.size()>0 || DeleteDupsConRelations.size()>0){
            Delete DeleteMasterConRelations;
            system.debug('AfterDelete-MasterConRelations ::'+DeleteMasterConRelations);
            Delete DeleteDupsConRelations;
            system.debug('AfterDelete-DupsConRelations ::'+DeleteDupsConRelations);
        }
        //DML's for update master and duplicate accounts
        if(UpdateMasterAcc.size()>0 || UpdateDuplicateAcc.size()>0){
            update UpdateMasterAcc;
            system.debug('AfterUpdate-MasterAcc ::'+UpdateMasterAcc);
            update UpdateDuplicateAcc;
            system.debug('AfterUpdate-DuplicateAcc ::'+UpdateDuplicateAcc);
        }
        //Update account dups record
        if(dupList.size()>0){
            update dupList;
            system.debug('AfterUpdate-dupList ::'+dupList);
        }
        //Transfer sites from duplicate to master account
        if(masterAccount != null && duplicateAccounts != null){
            List<Account> UpdateSiteAccountList = new List<Account>();
            for(Account SiteAccount : [Select id,RecordType.Name,ParentId from Account where RecordType.Name = 'Service Address' And ParentId  IN: duplicateAccounts]){
                SiteAccount.ParentId = masterAccount.Id;
                UpdateSiteAccountList.add(SiteAccount);
            }
            if(UpdateSiteAccountList.size()>0){
                update UpdateSiteAccountList;
                System.debug('UpdateSiteAccountList ::'+UpdateSiteAccountList);
            }
            
        }
        
        Database.MergeResult[] results;
        if(masterAccount != null) {
            //merge masterAccount duplicateAccounts;  
            results = Database.merge(masterAccount, duplicateAccounts, false);
        }
        
        for(Database.MergeResult res : results) {
            if (res.isSuccess()) {
                // Get the master ID from the result and validate it
                System.debug('Master record ID: ' + res.getId());
                // Get the IDs of the merged records and display them
                List<Id> mergedIds = res.getMergedRecordIds();
                System.debug('IDs of merged records: ' + mergedIds);
                
                // Get the ID of the reparented record and 
                // validate that this the contact ID.
                System.debug('Reparented record ID: ' + res.getUpdatedRelatedIds());
                
                
            }
            else {
                for(Database.Error err : res.getErrors()) {
                    // Write each error to the debug output
                    System.debug(err.getMessage());
                }
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}