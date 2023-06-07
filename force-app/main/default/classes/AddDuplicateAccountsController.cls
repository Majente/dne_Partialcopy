public class AddDuplicateAccountsController {
    @AuraEnabled
    public static Result createDuplicateAccounts(String winningAccount, String duplicateAccountData){
        Account_Dups__c winningAccountRecord = (Account_Dups__c)JSON.deserialize(winningAccount, Account_Dups__c.class);
        List<Account_Dups__c> duplicateDataList = (List<Account_Dups__c>)JSON.deserialize(duplicateAccountData, List<Account_Dups__c>.class);
        Result res = new Result();
        
        System.debug('winningAccountRecord^^' + winningAccountRecord);
        System.debug('duplicateDataList^^' + duplicateDataList.size());
        
        for(Account_Dups__c dupAccounts : duplicateDataList){
            dupAccounts.Master_Account__c = winningAccountRecord.Master_Account__c;
        }
        
        try{
            if(duplicateDataList.size() > 0){
                INSERT duplicateDataList;
                res.status = 'Success';
                res.message = 'Duplicate accounts inserted successfully.';
            }
        }catch(Exception ex){
            System.debug('exception occured on insertion^^' + ex.getMessage());
            res.status = 'Error';
            res.message = String.valueOf(ex);
        }
        return res;
    }
    public class Result{
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String message {get;set;}
    }   
}