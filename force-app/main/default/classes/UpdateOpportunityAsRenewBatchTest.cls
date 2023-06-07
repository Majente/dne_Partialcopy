@isTest
public class UpdateOpportunityAsRenewBatchTest {
    @testSetup
    public static void createTestData(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'CANADA';                
        INSERT marketTest;
        
        Account acc =new Account();
        acc.Name = 'Test Account' + Integer.valueOf(Math.random() * 100);
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Market__c = marketTest.id;
        INSERT acc; 
        
        Account accServ =new Account();
        accServ.Name = 'Service Account' + Integer.valueOf(Math.random() * 100);
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = acc.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = 'May 2019';
        monYea.Month__c = 5;
        monYea.Year__c = 2019;
        INSERT monYea;

        Opportunity opp = new Opportunity();
        opp.name ='Test opp' + Integer.valueOf(Math.random() * 100);
        opp.AccountId = acc.id;
        opp.CloseDate = System.today().addDays(5);
        opp.Market__c = marketTest.id;
        opp.Month_Year__c = monYea.id;
        opp.Flow_Date__c = System.today().addDays(2);
        opp.StageName = 'Qualification';
        opp.Commodity_Type__c = 'Gas';
        INSERT opp;
        
        Opportunity opp2 = new Opportunity();
        opp2.name ='Test opp' + Integer.valueOf(Math.random() * 100);
        opp2.AccountId = acc.id;
        opp2.CloseDate = System.today().addDays(3);
        opp2.Market__c = marketTest.id;
        opp2.Month_Year__c = monYea.id;
        opp2.StageName = 'Qualification';
        opp2.Commodity_Type__c = 'Gas';
        opp2.Flow_Date__c = System.today().addDays(4);
        INSERT opp2;
        
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite' + Integer.valueOf(Math.random() * 100);
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        
        Site__c accSite2 = new Site__c();
        accSite2.Name = 'AccountSite' + Integer.valueOf(Math.random() * 100);
        accSite2.Type__c = 'Gas';
        accSite2.Account__c = accServ.id;
        accSite2.Market__c = marketTest.id;
        accSite2.Unit_of_Measure__c = 'GJ';
        accSite2.Volume__c = 1200;
        INSERT accSite2;
        
        Product2 pro = new Product2();
        pro.Name = 'Gas - Small fixed';
        pro.Family = 'Gas';
        pro.ProductCode = 'Gas-Small Fixed';
        pro.Is_Fixed__c = true;
        pro.Size__c = 'Small';
        pro.Price_Type__c = 'Fixed';
        pro.IsActive = true;
        INSERT pro;
        
        PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id,
        UnitPrice = 1, IsActive = true);
        insert pbe; 
        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c = opp.id;
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__StartDate__c = System.today();
        Insert newQuote;
        
        SBQQ__QuoteLine__c  quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = newQuote.id;
        quoteLine.SBQQ__Product__c = Pro.Id;
        quoteLine.SBQQ__PricebookEntryId__c = pbe.Id;
        quoteLine.SBQQ__ListPrice__c = 12;
        quoteLine.Supplier_Price__c = 40;
        quoteLine.SBQQ__Quantity__c = 1;
        quoteLine.Site__c = accSite.id;
        Insert quoteLine;
        
        Opportunity_Site__c oppSite = new Opportunity_Site__c();
        oppSite.Opportunity__c =opp.id;
        oppSite.Site__c = accSite.id;
        Insert oppSite;

        Opportunity_Site__c oppSite2 = new Opportunity_Site__c();
        oppSite2.Opportunity__c =opp.id;
        oppSite2.Site__c = accSite.id;
        Insert oppSite2;
        
        Opportunity_Site__c oppSite3 = new Opportunity_Site__c();
        oppSite3.Opportunity__c =opp2.id;
        oppSite3.Site__c = accSite.id;
        Insert oppSite3;

        Opportunity_Site__c oppSite4 = new Opportunity_Site__c();
        oppSite4.Opportunity__c =opp2.id;
        oppSite4.Site__c = accSite.id;
        Insert oppSite4;

}
    @isTest
    public static void testRenewBatch(){
        
        Test.startTest();
        UpdateOpportunityAsRenewBatch renewBatch = new UpdateOpportunityAsRenewBatch();
        Database.executeBatch(renewBatch,1);
        Test.stopTest();
        List<Opportunity> oppList = [SELECT Id,Flow_Date__c,SBQQ__Renewal__c FROM Opportunity ORDER BY Flow_Date__c ASC];
        System.assert(oppList[0].SBQQ__Renewal__c);
    }

}