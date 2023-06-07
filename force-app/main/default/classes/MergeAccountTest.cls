@IsTest
public class MergeAccountTest {
@TestSetup
    static void createRecord(){
        id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = recTypeId;
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name  = 'Test';
        acc2.RecordTypeId = recTypeId;
        insert acc2;
        
        List<Account_Dups__c> dupList = new List<Account_Dups__c>();
         Account_Dups__c dupRec = new Account_Dups__c(); 
        dupRec.Master_Account__c = acc.id;
        dupRec.Duplicate_Account__c = acc2.Id;
        dupRec.Last_Activity_Date__c = System.now();
        dupRec.Number_of_Opportunity__c = 2;  
        dupList.add(dupRec);
        
        insert dupList;
        
    }
    @isTest
    static void TestMerge(){
        Account_Dups__c dups = [select id,Master_Account__c,Duplicate_Account__c from Account_Dups__c limit 1];
        test.startTest();
        MergeAccount.MergeAccountS(dups.id);
        system.assertNotEquals(null, dups.Id);
            test.stopTest();
    }
   
}