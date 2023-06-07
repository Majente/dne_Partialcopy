@isTest
public class OpportunityDataBatchTest {
     
@isTest
    static void TestBatch(){
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'DNE';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.id;
        con.Email = 'Test@gmail.com';
        con.Phone = '1234556';
        insert con;
        
        Contact con2 = new Contact();
        con2.LastName = 'Test2';
        con2.AccountId = acc.id;
        con2.Email = 'Test23@gmail.com';
        con2.Phone = '123455236';
        insert con2;
        
        Market__c mrk = new Market__c();
        mrk.Name = 'TestMarket';
        mrk.Country__c = 'USA';
        insert mrk;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.Market__c = mrk.Id;
        opp.CloseDate = system.today().addDays(20);
        opp.Commodity_Type__c = 'Electricity';
        opp.Name = 'Test-Opp';
        opp.StageName = 'Closed Won';
        opp.Flow_Date__c = system.today();
        opp.Opener__c = con.Id;
        opp.Closer__c = con2.Id;
        opp.Selling_Price__c = 20;
        insert opp;
        
        Contract contr = new Contract();
        contr.AccountId = acc.id;
        contr.StartDate = opp.Flow_Date__c;
        contr.Status = 'Draft';
        contr.ContractTerm = 12;
        contr.Adder_Margin__c = 10;
        
        contr.SBQQ__Opportunity__c = opp.Id;
        insert contr;
        
        Opportunity_Data_Temp__c oppTemp = new Opportunity_Data_Temp__c();
        oppTemp.Type__c = 'Elec';
        oppTemp.Start_Date__c = system.today();
        oppTemp.End_Date__c = oppTemp.Start_Date__c.addYears(1).addDays(-1);
        oppTemp.Opportunity_Name__c = 'Test-Opp';
        oppTemp.Term__c = 12;
        oppTemp.Adder__c = 10;
        oppTemp.Opener__c = con.Id;
        oppTemp.Closer__c = con.Id;
        oppTemp.Contract_Price__c = opp.Selling_Price__c;
        oppTemp.Opportunity__c = contr.SBQQ__Opportunity__c;
        oppTemp.Is_Opener_Closer_MisMatch__c = false;
        insert oppTemp;
        
        Opportunity_Data_Temp__c oppTewmp = [select id from Opportunity_Data_Temp__c where id =: oppTemp.id];
        Opportunity_Data_Temp__c oppTemp2 = new Opportunity_Data_Temp__c();
        oppTemp2.Id = oppTewmp.id;
        oppTemp2.Is_Opener_Closer_MisMatch__c = true;
        update oppTemp2;
        
        OpportunityDataBatchClass OppBatch= new OpportunityDataBatchClass();
        Id jobid= Database.executeBatch(OppBatch,1);
        Test.stopTest();
    }
}