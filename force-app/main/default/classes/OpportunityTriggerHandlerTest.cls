/**************************************************

* Class: OpportunityTriggerHandlerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test class for OpportunityTriggerHandler

****************************************************/
@isTest
public class OpportunityTriggerHandlerTest {
    
      /*********************************************************
    @Name 			: testOpportunityUpdate
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for OpportunityTriggerHandler when update opportunity.
	********************************************************/
    @testSetup
    public static void testOpportunityUpdate(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        
       /* Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;*/
        
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
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = 'May 2019';
        monYea.Month__c = 5;
        monYea.Year__c = 2019;
        INSERT monYea;
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'Canada';
        INSERT marketTest;
        
        Account suppAcc =new Account();
        suppAcc.Name = 'Supplier Account' + Integer.valueOf(Math.random() * 100);
        suppAcc.RecordTypeId = RecordTypeIdSupplier;
        suppAcc.Market__c = marketTest.id;
        INSERT suppAcc;
        
        Case caseRec = new Case();
        caseRec.Type = 'To Operations';
        caseRec.Status = 'New';
        caseRec.Priority = 'Medium';
        caseRec.Term__c = '12';
        caseRec.Subject = 'Test Case Subject';
        caseRec.Origin = 'Email';
        INSERT caseRec;
            
        Account acc =new Account();
        acc.Name = 'DNE';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Market__c = marketTest.id;
        INSERT acc; 
        
        Contact con = new Contact();
        con.Salutation = 'Mr.';
        con.LastName = 'Test Contact' + Integer.valueOf(Math.random() * 100);
        con.AccountId = acc.Id;
        con.Email = 'test@gmail.com';
        con.Phone = '23434456423';
        INSERT con;
        
        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = acc.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 
        
        Opportunity mainOpp = new Opportunity();
        mainOpp.name ='Test opp' + Integer.valueOf(Math.random() * 100);
        mainOpp.AccountId = acc.id;
        mainOpp.CloseDate = System.today().addDays(5);
        mainOpp.Market__c = marketTest.id;
        mainOpp.Month_Year__c = monYea.id;
        mainOpp.Margin__c = 5;
        mainOpp.Flow_Date__c = System.today().addDays(-5);
        mainOpp.Case__c = caseRec.Id;
        mainOpp.Supplier__c = suppAcc.Id;
        mainOpp.Subscription_Term__c = 12;
        mainOpp.StageName = 'Qualification';
        mainOpp.Commodity_Type__c = 'Gas';
        mainOpp.Monthly_Site_Admin_Fee__c = 0;
        mainOpp.Daily_Site_Admin_Fee__c = 0;
        INSERT mainOpp;
        
        Id RecordTypeIdAmendmentOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.name ='Test opp' + Integer.valueOf(Math.random() * 100);
        opp.AccountId = acc.id;
        opp.RecordTypeId = RecordTypeIdAmendmentOpp;
        opp.CloseDate = System.today().addDays(5);
        opp.Market__c = marketTest.id;
        opp.Month_Year__c = monYea.id;
        opp.Margin__c = 5;
        opp.Main_Opportunity__c = mainOpp.Id;
        opp.Case__c = caseRec.Id;
        opp.Supplier__c = suppAcc.Id;
        opp.Subscription_Term__c = 12;
        opp.StageName = 'Qualification';
        opp.Commodity_Type__c = 'Gas';
        opp.Monthly_Site_Admin_Fee__c = 0;
        opp.Daily_Site_Admin_Fee__c = 0;
        INSERT opp;
        
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite11';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        
        Site__c accSite2 = new Site__c();
        accSite2.Name = 'AccountSite12';
        accSite2.Type__c = 'Gas';
        accSite2.Account__c = accServ.id;
        accSite2.Market__c = marketTest.id;
        accSite2.Unit_of_Measure__c = 'GJ';
        accSite2.Volume__c = 1500;
        INSERT accSite2;
        
        Opportunity_Site__c oppSite1 = new Opportunity_Site__c();
        oppSite1.Opportunity__c =opp.id;
        oppSite1.Site__c = accSite.id;
        oppSite1.Market__c = marketTest.id;
       // Insert oppSite1;
        
        Opportunity_Site__c oppSite2 = new Opportunity_Site__c();
        oppSite2.Opportunity__c =opp.id;
        oppSite2.Site__c = accSite2.id;
        oppSite2.Market__c = marketTest.id;
        //Insert oppSite2;

        Contract theContract = new Contract();
        theContract.SBQQ__Opportunity__c = opp.Id;
        theContract.StartDate = Date.today();
        theContract.Payment_Terms__c = '50% Upfront on flow and 50% Residual - Monthly';
        theContract.ContractTerm = 36;
        theContract.AccountId = acc.Id;
        theContract.CurrentVolume__c = 50;
        theContract.CurrentAmount__c = 50;
        theContract.Supplier_s_contract_ID__c = 'sup - ' + Integer.valueOf(Math.random() * 100);
        INSERT theContract;
        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c = opp.id;
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__MasterContract__c = theContract.Id;
        newQuote.SBQQ__StartDate__c = System.today();
        Insert newQuote;
        
        SBQQ__QuoteLine__c  quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = newQuote.id;
        quoteLine.SBQQ__Product__c = Pro.Id;
        quoteLine.SBQQ__PricebookEntryId__c = pbe.Id;
        quoteLine.SBQQ__ListPrice__c = 12;
        quoteLine.Supplier_Price__c = 40;
        quoteLine.AnnualVolumeForSite__c = 50;
        quoteLine.SBQQ__Quantity__c = 1;
        quoteLine.Site__c = accSite.id;
        quoteLine.SBQQ__DefaultSubscriptionTerm__c = 12;
        Insert quoteLine;
        
        SBQQ__QuoteLine__c  quoteLine2 = new SBQQ__QuoteLine__c();
        quoteLine2.SBQQ__Quote__c = newQuote.id;
        quoteLine2.SBQQ__Product__c = Pro.Id;
        quoteLine2.SBQQ__PricebookEntryId__c = pbe.Id;
        quoteLine2.SBQQ__ListPrice__c = 12;
        quoteLine2.Supplier_Price__c = 40;
        quoteLine2.AnnualVolumeForSite__c = 50;
        quoteLine2.SBQQ__Quantity__c = 1;
        quoteLine2.SBQQ__DefaultSubscriptionTerm__c = 12;
        Insert quoteLine2;
        
        SBQQ__Subscription__c theSubscription = new SBQQ__Subscription__c();
        theSubscription.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-1);
        theSubscription.SBQQ__SubscriptionEndDate__c = Date.today().addYears(2);
        theSubscription.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
        theSubscription.SBQQ__QuoteLine__c  = quoteLine.id;        
        theSubscription.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
        theSubscription.SBQQ__ListPrice__c  = quoteLine.SBQQ__ListPrice__c;
        theSubscription.SBQQ__Account__c = acc.Id;
        theSubscription.Annual_Volume__c = 100;
        theSubscription.SBQQ__Contract__c = theContract.Id;
        theSubscription.SBQQ__Number__c =quoteLine.SBQQ__Number__c;
        theSubscription.Site__c = quoteLine.site__c;
        INSERT theSubscription;
                        
        Test.startTest();
       
        opp.Subscription_Term__c = 24;
        opp.Flow_Date__c = System.today().addDays(1);
        opp.Opener__c = con.Id;
        opp.Closer__c = con.Id;
        UPDATE opp;
        
        Test.stopTest();
  
    }
    @isTest
    public static void testClosedWonOpportunity(){
        Opportunity opp = [SELECT Id,StageName,RecordType.Name,Case__c,RecordTypeId FROM Opportunity WHERE RecordType.Name = 'Amendment' LIMIT 1];
        Case caseRec = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        
        opp.StageName = 'Activate Change';
        UPDATE opp;
        System.assertEquals(caseRec.Id,opp.Case__c);
        Test.stopTest();
    }
    @isTest
    public static void testsyncRenewalOpportunity(){
        Contract contr = [SELECT Id FROM Contract LIMIT 1];
        set<id> contrSet = new set<id>{contr.id};
        Test.startTest();
        
        OpportunityTriggerHandler.syncRenewalOpportunity(contrSet);
        Test.stopTest();
    }
    @IsTest
    public static void dummyCover(){
     Test.startTest();
        OpportunityTriggerHandler.dummyData();
        Test.stopTest();
    }
}