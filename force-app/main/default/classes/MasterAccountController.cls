public class MasterAccountController {
@AuraEnabled
    public static List<Account> setMasterAccount(string accName){
        List<Account> supplierList = new List<Account>();
        system.debug('accName =>'+accName);
        accName = '%'+accName+'%';
        if(string.isNotBlank(accName)){
            For(Account acc: [select id,Name,Market__r.Name from Account where Name Like: accName AND ParentId = null AND Is_Master__c = false]){
                supplierList.add(acc);
            } 
        }
        return supplierList;
    }
    @AuraEnabled
    public static void attechedMaster(string masterAccName, List<string> SupplierAccount){
        system.debug('masterAccName::'+masterAccName);
        system.debug('SupplierAccount::'+SupplierAccount);
        system.debug('recordTypeName::'+Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId());
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        acc.Name = masterAccName;
        acc.Is_Master__c = true;
        try{
            insert acc;
        }catch(Exception ex){
            System.debug('Exception:: '+ex.getMessage());
        }
        List<Account> SupplierAccountList = new List<Account>();
        for(Account SupplierAccId:[select Id, Name, MasterAccount__c From Account WHERE Id =:SupplierAccount]){
            SupplierAccId.ParentId = acc.Id;
            SupplierAccountList.add(SupplierAccId);
        }
        try{
            update SupplierAccountList;
        }catch(Exception ex){
            System.debug('Exception:: '+ex.getMessage());
        }
    }
}