@isTest
public class SelectedDuplicateControllerTest {

    @testSetup
    static void CreateAccountMethod()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Is_Processed__c = false;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        insert acc;
    }
    
    @isTest
    static void testMethod1()
    {
        
        List<Account> acList = [select Id, Name from Account where Name = 'Test' limit 1];     
        List<Account_Dups__c> dupList = new List<Account_Dups__c>();
        
        Account_Dups__c dup = new Account_Dups__c();
        dup.Master_Account__c = acList[0].id;
        dup.Duplicate_Account__c = acList[0].id;
        
        dup.Last_Activity_Date__c = system.now();
        dup.Number_of_Opportunity__c = 5;
        dupList.add(dup);
        insert dupList;
            
        Test.startTest();
        SelectedDuplicateController sdc = new SelectedDuplicateController();
        Test.stopTest();
        
        System.assertEquals(1, [select count(id) from Account_Dups__c].size());
    }
}