public class UpdateMasterAccountController {
    @AuraEnabled
    public static List<AccountWrapper> getDuplicateData(String recordId){
        System.debug('recordId^^' + recordId);
        List<AccountWrapper> accWrapperList = new List<AccountWrapper>();
        for(Account_Dups__c aDuplicate : [SELECT Id,Name,Duplicate_Account__c,Duplicate_Account__r.Name,Last_Activity_Date__c,
                                          Master_Account__c,Master_Account__r.Name,Number_of_Opportunity__c FROM 
                                          Account_Dups__c WHERE Master_Account__c =: recordId]){
                                              accWrapperList.add(new AccountWrapper(aDuplicate));   
                                          }
        System.debug('accWrapperList^^' + accWrapperList.size());
        return accWrapperList;
    }
    @AuraEnabled
    public static Result updateMasterRecord(String recordId,String masterId,String dataList){
        System.debug('dataList^^' + dataList);
        System.debug('recordId^^' + recordId);
        System.debug('masterId^^' + masterId);
        List<Account_Dups__c> listTobeDelete = new List<Account_Dups__c>();
        List<Account_Dups__c> listTobeInsert = new List<Account_Dups__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Result res = new Result();
        
        List<AccountWrapper> accWrapperList = (List<AccountWrapper>)JSON.deserialize(dataList, List<AccountWrapper>.class);
        System.debug('accWrapperList^^' + accWrapperList.size());
        for(Opportunity opp : [SELECT Id FROM Opportunity WHERE AccountId =: recordId]){
            oppList.add(opp);
        }
        System.debug('oppList^^' + oppList.size());
        for(AccountWrapper accWrapper : accWrapperList){
            listTobeDelete.add(accWrapper.dupRecord);
            if(accWrapper.dupRecord.Duplicate_Account__c != masterId){
                Account_Dups__c dupRec = new Account_Dups__c();
                dupRec.Master_Account__c = masterId;
                dupRec.Duplicate_Account__c = accWrapper.dupRecord.Duplicate_Account__c;
                dupRec.Number_of_Opportunity__c = accWrapper.dupRecord.Number_of_Opportunity__c;
                listTobeInsert.add(dupRec);
            }
        }
        Account_Dups__c dupRec = new Account_Dups__c();
        dupRec.Master_Account__c = masterId;
        dupRec.Duplicate_Account__c = recordId;
        dupRec.Number_of_Opportunity__c = oppList.size();
        listTobeInsert.add(dupRec);
        
        System.debug('listTobeInsert^^' + listTobeInsert.size());
        System.debug('listTobeDelete^^' + listTobeDelete.size());
        
        try{
            if(listTobeDelete.size() > 0){
                DELETE listTobeDelete;
            }
            if(listTobeInsert.size() > 0){
                INSERT listTobeInsert;
            }
            res.status = 'Success';
            res.message = 'Duplicate records updated successfully.';
            res.masterRecId = masterId;
        }catch(Exception ex){
            System.debug('exception occured^^' + ex.getMessage());
            res.status = 'Error';
            res.message = String.valueOf(ex);
        }
        return res;
    }
    public class Result{
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String masterRecId {get;set;}
    }
    public class AccountWrapper{
        @AuraEnabled
        public boolean isSelected {get;set;}
        @AuraEnabled
        public Account_Dups__c dupRecord {get;set;}
        public AccountWrapper(Account_Dups__c dupRecord){
            this.dupRecord = dupRecord;
            this.isSelected = false;
            
        }
    }
}