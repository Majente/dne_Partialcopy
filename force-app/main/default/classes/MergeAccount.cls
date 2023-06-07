public class MergeAccount{
    @AuraEnabled
    public static void MergeAccountS(string DRecId){
        
        set<string> MasterId = new set<string>();
        set<string> DuplicateId = new set<string>();
        // Queries to get the inserted accounts 
        for(Account_Dups__c dups: [SELECT Id, Master_Account__c,Master_Account__r.Name, Duplicate_Account__c,
                                   Duplicate_Account__r.Name FROM Account_Dups__c where id =: DRecId]){
                                       MasterId.add(dups.Master_Account__c);
                                       DuplicateId.add(dups.Duplicate_Account__c);
                                   }
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
                system.debug('fieldName :::'+fieldName);
                system.debug('masterAccount.get(fieldName) :'+masterAccount.get(fieldName));
                system.debug('duplicateAccounts[0].get(fieldName) :'+duplicateAccounts[0].get(fieldName));
                if(masterAccount.get(fieldName) == null && duplicateAccounts[0].get(fieldName) != null)
                {
                    system.debug('masterAccount.get(fieldName) :'+masterAccount.get(fieldName));
                    system.debug('duplicateAccounts[0].get(fieldName) :'+duplicateAccounts[0].get(fieldName));
                    masterAccount.put(fieldName, duplicateAccounts[0].get(fieldName));
                    system.debug('masterAccount :::'+masterAccount);
                }
        }
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
}