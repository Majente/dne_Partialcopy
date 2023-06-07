public class RadioController {
    
    public string selectedAccountId{get; set;}
    public List<Account_Dups__c> accounts{get; set;}
    
    public RadioController()
    {
        accounts = [Select Name, Duplicate_Account__c,Master_Account__c, Number_of_Opportunity__c, Last_Activity_Date__c FROM Account_Dups__c];
    }
}