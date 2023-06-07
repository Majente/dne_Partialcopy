@isTest
public class ShowDuplicateAccountsTest {
    
    @testSetup
    static void CreateAccountMethod()
    {
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
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = system.today();
        opp.StageName = 'Procesting';
        opp.AccountId = acc.Id;
        system.debug('opp.AccountId '+opp.AccountId );
        insert opp;
    }
        
    @isTest
    static void testMethod2()
    {
        Account accList = [select Id, Name,LastActivityDate from Account limit 1];
        Account_Dups__c dups = [select Id, Master_Account__c,Duplicate_Account__c,Last_Activity_Date__c,Number_of_Opportunity__c from Account_Dups__c limit 1];
        List<ShowDuplicateAccounts.DataWrapper> DList = new List<ShowDuplicateAccounts.DataWrapper>();
        ShowDuplicateAccounts.DataWrapper dw =  new ShowDuplicateAccounts.DataWrapper(dups);
        dw.isMaster = true;
        dw.RecId = accList.Id;
        DList.add(dw);
        
        List<ShowDuplicateAccounts.DataWrapper> DList2 = new List<ShowDuplicateAccounts.DataWrapper>();
        Test.setCurrentPageReference(new PageReference('Page.myPage')); 
        System.currentPageReference().getParameters().put('id', dw.RecId);
        
        Test.startTest(); 
        ShowDuplicateAccounts sdc = new ShowDuplicateAccounts();
        sdc.WrapperList = new List<ShowDuplicateAccounts.DataWrapper>(DList);
        sdc.changeMasterAccount();
        sdc.WrapperList = new List<ShowDuplicateAccounts.DataWrapper>(DList2);
        Test.stopTest();        
    }
    
    @isTest
    static void testMethod3()
    {
        Account accList = [select Id, Name,LastActivityDate from Account limit 1];
        Account_Dups__c dups = [select Id, Master_Account__c,Duplicate_Account__c,Last_Activity_Date__c,Number_of_Opportunity__c from Account_Dups__c limit 1];
        List<ShowDuplicateAccounts.DataWrapper> DList = new List<ShowDuplicateAccounts.DataWrapper>();
        ShowDuplicateAccounts.DataWrapper dw =  new ShowDuplicateAccounts.DataWrapper(dups);
        dw.isMaster = false;
        dw.RecId = accList.Id;
        DList.add(dw);
        
        Test.startTest(); 
        ShowDuplicateAccounts sdc = new ShowDuplicateAccounts();
        sdc.WrapperList = new List<ShowDuplicateAccounts.DataWrapper>(DList);
        sdc.changeMasterAccount();
        Test.stopTest();
    }   
}