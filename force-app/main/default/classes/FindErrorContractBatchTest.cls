@IsTest
public class FindErrorContractBatchTest {

    @IsTest static void TestBatch(){
        Test.startTest();
        Account accp = new Account();
        accp.Name = 'DNE';
        accp.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        insert accp;
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'CANADA';
        INSERT marketTest;
        
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Account acc =new Account();
        acc.Name = 'Service Account 2';
        acc.RecordTypeId = RecordTypeIdServiceAddre;
        acc.Market__c = marketTest.id;
        acc.ParentId = accp.id;
        acc.Business_Size__c = 'Small';
        INSERT acc;
        
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
        
        Product2 pro = new Product2();
        pro.Name = 'Gas - Small fixed';
        pro.Family = 'Gas';
        pro.ProductCode = 'Gas-Small Fixed';
        pro.Is_Fixed__c = true;
        pro.Size__c = 'Small';
        pro.Price_Type__c = 'Fixed';
        pro.IsActive = true;
        INSERT pro;
        
        Product2 pro2 = new Product2();
        pro2.Name = 'Gas - Medium fixed';
        pro2.Family = 'Gas';
        pro2.ProductCode = 'Gas-Medium Fixed';
        pro2.Is_Fixed__c = true;
        pro2.Size__c = 'Small';
        pro2.Price_Type__c = 'Fixed';
        pro2.IsActive = true;
        INSERT pro2;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id,
            UnitPrice = 1, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro2.Id,
            UnitPrice = 5, IsActive = true);
        insert standardPrice2;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.Market__c = mrk.Id;
        opp.CloseDate = system.today().addDays(20);
        opp.Commodity_Type__c = 'Electricity';
        opp.Name = 'Test-Opp';
        opp.StageName = 'Closed Won';
        opp.Flow_Date__c = system.today();
        opp.Subscription_Term__c = 12;
        opp.Margin__c = 10;
        insert opp;
        
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = acc.id;
        accSite.Market__c = mrk.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        accSite.Type__c = opp.Commodity_Type__c;
        accSite.Unit_of_Measure__c ='GJ';
        accSite.Market__c = opp.Market__c;
        INSERT accSite;
        
        Site__c accSite2 = new Site__c();
        accSite2.Name = 'AccountSite01';
        accSite2.Type__c = 'Gas';
        accSite2.Account__c = acc.id;
        accSite2.Market__c = marketTest.id;
        accSite2.Unit_of_Measure__c = 'GJ';
        accSite2.Volume__c = 1200;
        accSite2.Type__c = opp.Commodity_Type__c;
        accSite2.Unit_of_Measure__c ='GJ';
        INSERT accSite2;
        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c = opp.id;
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__StartDate__c = System.today();
        newQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        Insert newQuote;
        
	    SBQQ__QuoteLine__c  quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = newQuote.id;
        quoteLine.Site__c = accSite.id;
        quoteLine.SBQQ__Product__c = Pro.Id;
        quoteLine.SBQQ__PricebookEntryId__c = standardPrice.Id;
        quoteLine.SBQQ__ListPrice__c = 3;
        quoteLine.Supplier_Price__c = 40;
        quoteLine.SBQQ__Quantity__c = 1;
        quoteLine.SBQQ__DefaultSubscriptionTerm__c = 12;
        Insert quoteLine;
        
        SBQQ__QuoteLine__c  quoteLine2 = new SBQQ__QuoteLine__c();
        quoteLine2.SBQQ__Quote__c = newQuote.id;
        quoteLine2.Site__c = accSite2.id;
        quoteLine2.SBQQ__Product__c = Pro2.Id;
        quoteLine2.SBQQ__PricebookEntryId__c = standardPrice2.Id;
        quoteLine2.SBQQ__ListPrice__c = 5;
        quoteLine2.Supplier_Price__c = 40;
        quoteLine2.SBQQ__Quantity__c = 1;
        quoteLine2.SBQQ__DefaultSubscriptionTerm__c = 12;
        Insert quoteLine2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.UnitPrice = quoteLine.SBQQ__ListPrice__c;
        oli.Product2Id = Pro.Id;
        oli.PricebookEntryId = standardPrice.Id;
        oli.Site__c = accSite.id;
        oli.Quantity = 1;
        oli.OpportunityId = opp.id;
        INSERT oli;
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.UnitPrice = quoteLine.SBQQ__ListPrice__c;
        oli2.Product2Id = Pro2.Id;
        oli2.PricebookEntryId = standardPrice2.Id;
        oli2.Site__c = accSite2.id;
        oli2.Quantity = 1;
        oli2.OpportunityId = opp.id;
        INSERT oli2;
        
        Contract contr = new Contract();
        contr.AccountId = acc.id;
        contr.StartDate = opp.Flow_Date__c;
        contr.Status = 'Draft';
        contr.ContractTerm = integer.valueOf(opp.Subscription_Term__c);
        contr.Adder_Margin__c = 12;
        contr.SBQQ__Opportunity__c = opp.Id;
        insert contr;
        
        SBQQ__Subscription__c theSubscription = new SBQQ__Subscription__c();
        theSubscription.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-1);
        theSubscription.SBQQ__SubscriptionEndDate__c = Date.today().addYears(2);
        theSubscription.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
        theSubscription.SBQQ__QuoteLine__c  = quoteLine.id;        
        theSubscription.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
        theSubscription.SBQQ__ListPrice__c  = quoteLine.SBQQ__ListPrice__c;
        theSubscription.SBQQ__Account__c = acc.Id;
        theSubscription.Annual_Volume__c = 100;
        theSubscription.SBQQ__Contract__c = contr.Id;
        theSubscription.SBQQ__Number__c =quoteLine.SBQQ__Number__c;
        theSubscription.Site__c = quoteLine.site__c;
        INSERT theSubscription;
        
        Opportunity_Temp__c oppTemp = new Opportunity_Temp__c();
        oppTemp.Opportunity__c = opp.id;
        oppTemp.contract__c = contr.id;
        oppTemp.Stage__c = opp.stageName;
        oppTemp.Flow_Date__c = opp.Flow_Date__c;
        oppTemp.Amount__c = opp.Amount;
        oppTemp.Volume__c = opp.Total_Volume__c;
        oppTemp.Term__c = opp.Subscription_Term__c;
        oppTemp.Margin__c = opp.Margin__c;
        oppTemp.End_Date__c = opp.End_date__c;
        insert oppTemp;
        
        
        FindErrorContractBatch OppBatch= new FindErrorContractBatch();
        Id jobid= Database.executeBatch(OppBatch,1);
        Test.stopTest();
    }
}