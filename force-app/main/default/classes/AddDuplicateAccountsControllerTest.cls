@isTest
private class AddDuplicateAccountsControllerTest {
	@testSetup
    static void createData(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Is_Processed__c = false;
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Test2';
        acc2.Is_Processed__c = false;
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        insert acc2;
        
        
        Account_Dups__c acDup = new Account_Dups__c();
        acDup.Master_Account__c = acc.id;
        acDup.Duplicate_Account__c = acc2.id;
        acDup.Number_of_Opportunity__c = 5;
        acDup.Last_Activity_Date__c = system.now();
        insert acDup;
       
    }
    
    @isTest
    static void testcreateDuplicateAccounts(){
    	Account_Dups__c  dupAcc1 = [SELECT Id,Name FROM Account_Dups__c  LIMIT 1];
        String strJSON = JSON.serialize(dupAcc1);
        Account_Dups__c  dupAcc2 = [SELECT Id,Name FROM Account_Dups__c LIMIT 1];
        String strJSON2 = JSON.serialize(new List<Account_Dups__c>{dupAcc1, dupAcc2});
        system.assertNotEquals(null, strJSON2);
        system.assertNotEquals(null, strJSON);
        Test.startTest();
        AddDuplicateAccountsController.createDuplicateAccounts(strJSON,strJSON2);
        Test.stopTest();
    }
}