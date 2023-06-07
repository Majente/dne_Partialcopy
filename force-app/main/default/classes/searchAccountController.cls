public class searchAccountController {
@AuraEnabled
    public static List <Account_Dups__c> fetchAccount(String recordId) {
        return [SELECT Id,Name, Master_Account__r.Name, Duplicate_Account__r.Name, Last_Activity_Date__c, Number_of_Opportunity__c FROM Account_Dups__c Where id =:recordId]; 
    }
    
}