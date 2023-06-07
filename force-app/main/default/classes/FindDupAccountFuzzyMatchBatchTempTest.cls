@isTest
public class FindDupAccountFuzzyMatchBatchTempTest {
    @isTest
    static void testMethod1() 
    {
        List<Account> accList =new List<Account>();
        List<Account_Dups__c> dupList = new List<Account_Dups__c>();
        List<Opportunity> opList = new List<Opportunity>();
        
        
        for(integer i=0; i<2; i++)
        {
            Account acc = new Account();
            acc.Name = 'Test'+i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
            acc.Phone = '(780) 732-72775';
            accList.add(acc);
            
        }
        insert accList;
        
        
        Account_Dups__c dupRec = new Account_Dups__c(); 
        dupRec.Master_Account__c = null;
        dupRec.Duplicate_Account__c = null;
        dupRec.Last_Activity_Date__c = System.now();
        //dupRec.Fuzzy_Match__c = true;
        dupRec.Number_of_Opportunity__c = 5;  
        dupList.add(dupRec);
        
        insert dupList;
        
        for(integer i=0; i<2; i++)
        {
            Opportunity opp = new Opportunity();
            Opp.Name = 'Test Opp'+i;
            Opp.StageName='Legal';
            Opp.Accountid = null;
            Opp.Closedate= System.today().addDays(100);
            opList.add(opp);  
        }    
        insert opList;
        
        
        Test.startTest();        
        FindDuplicateAccountFuzzyMatchBatchTemp obj = new FindDuplicateAccountFuzzyMatchBatchTemp();
        DataBase.executeBatch(obj); 
        Test.stopTest();
        
        System.assertEquals(1, [select count(id) from Account_Dups__c].size());
    }
    @isTest
    static void testMethod2() 
    {
        List<Account> accList =new List<Account>();
        List<Account_Dups__c> dupList = new List<Account_Dups__c>();
        List<Opportunity> opList = new List<Opportunity>();
        
        
        for(integer i=0; i<2; i++)
        {
            Account acc = new Account();
            acc.Name = 'Test'+i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
            acc.Phone = '(780) 732-72775';
            accList.add(acc);
            
        }
        insert accList;
        
        
        Account_Dups__c dupRec = new Account_Dups__c(); 
        dupRec.Master_Account__c = accList[0].id;
        dupRec.Duplicate_Account__c = accList[0].id;
        dupRec.Last_Activity_Date__c = System.now();
        //dupRec.Fuzzy_Match__c = true;
        dupRec.Number_of_Opportunity__c = 5;  
        dupList.add(dupRec);
        
        insert dupList;
        
        for(integer i=0; i<2; i++)
        {
            Opportunity opp = new Opportunity();
            Opp.Name = 'Test Opp'+i;
            Opp.StageName='Legal';
            Opp.Accountid = accList[0].id;
            Opp.Closedate= System.today().addDays(100);
            opList.add(opp);  
        }    
        insert opList;
        
        
        Test.startTest();  
        Integer noOfRecords = 2;
        FindDuplicateAccountFuzzyMatchBatchTemp obj = new FindDuplicateAccountFuzzyMatchBatchTemp(noOfRecords);
        obj.accRecordType = 'Account';
        DataBase.executeBatch(obj); 
        Test.stopTest();
        
        System.assertEquals(1, [select count(id) from Account_Dups__c].size());
    }
    
    @isTest 
	static void testMethod4()
	{
        Test.StartTest();
		FindDuplicateAccountSchedular testsche = new FindDuplicateAccountSchedular();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
    } 
}