@IsTest
public class MergeAccountBatchTest {
    @TestSetup
    static void CreateTestRecords(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = devRecordTypeId;
        acc.Name = 'Test - Account';
        acc.Phone = '12436554';
        acc.NumberOfEmployees = 12;
        insert acc;
        
        Account acc2 = new Account();
        acc2.RecordTypeId = devRecordTypeId;
        acc2.Name = 'Test - Account 2';
        acc2.Phone = '124365542';
        acc2.NumberOfEmployees = 12;
        acc2.Email__c = 'Test@gmail.com';
        acc2.Type = '6-11';
        acc2.Industry = 'Agriculture';
        insert acc2;
        
        Contact con = new Contact();
        con.LastName = 'Test-Con';
        con.Email = 'Test@gmail.com';
        con.Phone = '2215422121';
        con.AccountId = acc2.Id;
        insert con;
        
        Market__c marketTest1 = new Market__c();
        marketTest1.Name = 'Quebec';
        marketTest1.Gas_Threshold__c = 2000;
        marketTest1.Electricity_Threshold__c = 290000;
        marketTest1.Country__c = 'CANADA';
        INSERT marketTest1;
        
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest1.id;
        accServ.ParentId = acc2.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test-Opportunity';
        opp.AccountId = acc2.Id;
        opp.CloseDate = system.today().addDays(15);
        opp.Market__c = marketTest1.id;
        opp.StageName = 'Qualification';
        opp.Commodity_Type__c = 'Gas';
        insert opp;
        
        Contract theContract = new Contract();
        theContract.SBQQ__Opportunity__c = opp.Id;
        theContract.StartDate = Date.today();
        theContract.Payment_Terms__c = '100% Residual - Monthly';
        theContract.ContractTerm = 36;
        theContract.AccountId = acc2.Id;
        theContract.Supplier_s_contract_ID__c = 'sup - ' + Integer.valueOf(Math.random() * 100);
        INSERT theContract;
        
        Account_Dups__c dups = new Account_Dups__c();
        dups.Master_Account__c = acc.id;
        dups.Duplicate_Account__c = acc2.Id;
        dups.Unique_Account_Id__c = '0010300000QoFjhAAF0010300000QoIYnAAN';
        insert dups;
    }
    
    @IsTest
    static void testBatchMethod(){
        Account_Dups__c dupsRecord = [SELECT Id, Master_Account__c, Duplicate_Account__c, Unique_Account_Id__c FROM Account_Dups__c limit 1];
        Test.startTest();
        MergeAccountBatch batchable = new MergeAccountBatch(dupsRecord.id);
        database.executeBatch(batchable);
        system.assertNotEquals(null, dupsRecord.id);
        Test.stopTest();
    }
}