@IsTest
public class DuplicateAccountTableControllerTest {
 @testSetup 
    static void Createrecords(){
        
        List<Account_Dups__c> dupList = new List<Account_Dups__c>();
         Account_Dups__c dupRec = new Account_Dups__c(); 
        dupRec.Master_Account__c = null;
        dupRec.Duplicate_Account__c = null;
        dupRec.Last_Activity_Date__c = System.now();
        //dupRec.Fuzzy_Match__c = true;
        dupRec.Number_of_Opportunity__c = 5;  
        dupList.add(dupRec);
        
        insert dupList;
    }
    @isTest 
    static void DuplicateAccountTableMethod(){
        List<Account_Dups__c> dupsList = [SELECT Id, Name,Master_Account__c,Master_Account__r.id, Duplicate_Account__r.Name, Duplicate_Account__c, Number_of_Opportunity__c FROM Account_Dups__c Limit 1]; 
        Map<String, List<Account_Dups__c>> RecdataMap = new Map<String, List<Account_Dups__c>>();
        for(Account_Dups__c dups : dupsList){
           RecdataMap.put(dups.Master_Account__c, dupsList);
        }
        Test.startTest();
       DuplicateAccountTableController extension = new DuplicateAccountTableController();
       extension.dataMap = RecdataMap;
        Test.stopTest();
        
        System.assertEquals(1, [select count(id) from Account_Dups__c].size());
    }
}