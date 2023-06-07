public class DupsListController {

    @AuraEnabled
    public static List<Account_Dups__c> getaccountsDups(String accId){
        List<Account_Dups__c> DupsList = [Select id, Name, Duplicate_Account__r.Name,Master_Account__r.Name, Number_of_Opportunity__c, Last_Activity_Date__c FROM Account_Dups__c where Master_Account__c =: accId];              
        return DupsList;
    }
}