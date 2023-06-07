public class DupsAccountController {
    
    public List<Account_Dups__c> dupsaccountList {get;set;}
    
    public DupsAccountController()
    { 
        dupsaccountList = [Select Name, Duplicate_Account__c,Master_Account__r.Name, Number_of_Opportunity__c, Last_Activity_Date__c FROM Account_Dups__c];
    }
}