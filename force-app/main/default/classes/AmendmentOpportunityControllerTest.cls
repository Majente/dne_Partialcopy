/**************************************************

* Class: AmendmentOpportunityControllerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test class for AmendmentOpportunityController

****************************************************/
@isTest
public class AmendmentOpportunityControllerTest {
    
      /*********************************************************
    @Name 			: testSample
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for AmendmentOpportunityController
	********************************************************/
    @isTest
    public static void testSample(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();
        
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
            Pricebook2Id = pricebookId, Product2Id = pro.Id,
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
        marketTest.Country__c = 'CANADA';
        INSERT marketTest;
        
        Market__c marketTest1 = new Market__c();
        marketTest1.Name = 'Quebec';
        marketTest1.Gas_Threshold__c = 2000;
        marketTest1.Electricity_Threshold__c = 290000;
        marketTest1.Country__c = 'CANADA';
        INSERT marketTest1;
        
        
        Account acc =new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Market__c = marketTest.id;
        INSERT acc; 
        
        Opportunity opp1 = new Opportunity();
        opp1.name ='Test opp';
        opp1.AccountId = acc.id;
        opp1.CloseDate = Date.newInstance(2019, 06, 20);
        opp1.Market__c = marketTest.id;
        opp1.Month_Year__c = monYea.id;
        opp1.StageName = 'Qualification';
        opp1.Commodity_Type__c = 'Gas';
        INSERT opp1;
        
        /*opp1.Subscription_Term__c = 24;
        opp1.Admin_Fee__c =1;
        opp1.Margin__c = 3;
        opp1.Supplier_Price__c = 22.50;
        Update opp1;*/
        
        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = acc.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 
        
        Account accServ1 =new Account();
        accServ1.Name = 'Service Account 2';
        accServ1.RecordTypeId = RecordTypeIdServiceAddre;
        accServ1.Market__c = marketTest.id;
        accServ1.ParentId = acc.id;
        accServ1.Business_Size__c = 'Small';
        INSERT accServ1; 
        
        Account supp = new Account();
        supp.Name = 'Direct Energy - Alberta';
        supp.Market__c = marketTest.id;
        supp.Business_Size__c = 'Small';
        supp.RecordTypeId = RecordTypeIdSupplier;
        INSERT supp;
        
        Account supp1 = new Account();
        supp1.Name = 'Gas Champ';
        supp1.Market__c = marketTest.id;
        supp1.Business_Size__c = 'Small';
        supp1.RecordTypeId = RecordTypeIdSupplier;
        INSERT supp1;
        
        Assumption__c maxMargin = new Assumption__c();
        maxMargin.Supplier__c = supp.Id;
        maxMargin.Market__c = marketTest.Id;
        maxMargin.Commodity__c = 'Gas';
        maxMargin.Business_Size__c = 'Small';
        maxMargin.Active__c = true;
        maxMargin.Type__c = 'Margin Max';
        maxMargin.Amount__c = 4;
        maxMargin.Pricing_Type__c = 'Fixed';
        INSERT maxMargin;
        
        Assumption__c minMargin = new Assumption__c();
        minMargin.Supplier__c = supp.Id;
        minMargin.Market__c = marketTest.Id;
        minMargin.Commodity__c = 'Gas';
        minMargin.Business_Size__c = 'Small';
        minMargin.Active__c = true;
        minMargin.Type__c = 'Margin Min';
        minMargin.Amount__c = 2;
        minMargin.Pricing_Type__c = 'Fixed';
        INSERT minMargin;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.name ='Test opp';
        opp.AccountId = acc.id;
        opp.CloseDate = Date.newInstance(2019, 06, 20);
        opp.Market__c = marketTest.id;
        opp.Month_Year__c = monYea.id;
        opp.StageName = 'Qualification';
        opp.Commodity_Type__c = 'Gas';
        opp.Supplier__c = supp.id;
        opp.Flow_Date__c = System.today();
        opp.Subscription_Term__c = 24;
        INSERT opp;
        
        Contract theContract = new Contract();
        theContract.SBQQ__Opportunity__c = opp.Id;
        theContract.StartDate = Date.today();
        theContract.Payment_Terms__c = '100% Residual - Monthly';
        theContract.ContractTerm = 36;
        theContract.AccountId = acc.Id;
        theContract.Supplier_s_contract_ID__c = 'sup - ' + Integer.valueOf(Math.random() * 100);
        INSERT theContract;
        
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        accSite.Type__c = opp.Commodity_Type__c;
        accSite.Unit_of_Measure__c ='GJ';
        accSite.Market__c = opp.Market__c;
        INSERT accSite;
        
        Site__c accSite1 = new Site__c();
        accSite1.Name = 'AccountSite13';
        accSite1.Type__c = 'Gas';
        accSite1.Account__c = accServ1.id;
        accSite1.Market__c = marketTest.id;
        accSite1.Unit_of_Measure__c = 'GJ';
        accSite1.Volume__c = 1000;
        accSite1.Type__c = opp.Commodity_Type__c;
        accSite1.Unit_of_Measure__c ='GJ';
        accSite1.Market__c = opp.Market__c;
        INSERT accSite1;
      
        Price_List__c priceLi = new Price_List__c();
        priceLi.Name = 'Gas';
        priceLi.Product_Code__c = 'Gas-Small Fixed';
        priceLi.Type__c = 'Fixed';
        priceLi.Size__c = 'Small';
        priceLi.Term__c = '12';
        priceLi.List_Price__c = 2.11;
        priceLi.Market__c = marketTest.id;
        priceLi.Supplier__c = supp.id;
        priceLi.Latest__c = true;
        priceLi.Effective_From__c = datetime.now().addDays(-5);
        priceLi.Effective_To__c = datetime.now().addDays(5);
        priceLi.Month_Year__c = monYea.id;
        Insert priceLi;
        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c = opp.id;
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__StartDate__c = System.today();
        newQuote.SBQQ__PricebookId__c = pricebookId;
        Insert newQuote;
        
	    SBQQ__QuoteLine__c  quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = newQuote.id;
        quoteLine.Site__c = accSite.id;
        quoteLine.SBQQ__Product__c = Pro.Id;
        quoteLine.SBQQ__PricebookEntryId__c = pbe.Id;
        quoteLine.SBQQ__ListPrice__c = 3;
        quoteLine.Supplier_Price__c = 40;
        quoteLine.SBQQ__Quantity__c = 1;
        quoteLine.SBQQ__DefaultSubscriptionTerm__c = 12;
        Insert quoteLine;
        
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
        
        opp.Subscription_Term__c = 12;
        opp.Admin_Fee__c =2;
        opp.Margin__c = 2;
        opp.Supplier_Price__c = 22.50;
        UPDATE OPP;
        oppList.add(opp);
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.UnitPrice = quoteLine.SBQQ__ListPrice__c;
        oli.Product2Id = Pro.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Site__c = accSite.id;
        oli.Quantity = 1;
        oli.OpportunityId = opp.id;
        INSERT oli;
        
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.UnitPrice = quoteLine.SBQQ__ListPrice__c;
        oli1.Product2Id = Pro.Id;
        oli1.PricebookEntryId = pbe.Id;
        oli1.Site__c = accSite.id;
        oli1.Quantity = -oli.Quantity;
        oli1.OpportunityId = opp.id;
        INSERT oli1;
        
        Opportunity_Site__c oppSite = new Opportunity_Site__c();
        oppSite.Opportunity__c =opp.id;
        oppSite.Site__c = accSite.id;
        oppSite.Market__c = marketTest.id;
        Insert oppSite;

        
        PriceListValidateDate__c pricelist = New PriceListValidateDate__c();
        pricelist.Name = 'test';
        pricelist.Validate_Date__c = 165;
        insert pricelist;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        AmendmentOpportunityController amendOpp = new AmendmentOpportunityController(stdController);
        System.assert(amendOpp.subWrapper.size() > 0);
        System.assert(amendOpp.wrrapperList.size() > 0);
        System.assertEquals(null,amendOpp.saveOLI());
        
        amendOpp.wrrapperList[0].isSelected = true;
        amendOpp.subWrapper[0].isSelected = true;
        amendOpp.subWrapper[0].sub.Annual_Volume__c = 150;
        System.assertNotEquals(null,amendOpp.saveOLI());
        // flow date less than today
        amendOpp.calculateRemainingTerm(System.today().addDays(-1),24);
        // flow date greater than today
        System.assertEquals(24.0,amendOpp.calculateRemainingTerm(System.today().addDays(1),24));
        System.assertNotEquals(null,amendOpp.Cancel());
        
        Test.stopTest();
  
    }// End of test method
}// End of Test class