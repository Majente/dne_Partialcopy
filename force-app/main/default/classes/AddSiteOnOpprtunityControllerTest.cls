/**************************************************

* Class: AddSiteOnOpprtunityControllerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test class for AddSiteOnOpprtunityController

****************************************************/
@isTest
public class AddSiteOnOpprtunityControllerTest {
    
    /*********************************************************
    @Name 			: testSite
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for AddSiteOnOpprtunityController
	********************************************************/
    @isTest
    public static void testSite(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        /*Pricebook2 standardPricebook = new Pricebook2(
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
        
        Market__c marketTest1 = new Market__c();
        marketTest1.Name = 'Quebec';
        marketTest1.Gas_Threshold__c = 2000;
        marketTest1.Electricity_Threshold__c = 290000;
        marketTest1.Country__c = 'Canada';
        INSERT marketTest1;
        
        Account acc =new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Market__c = marketTest.id;
        INSERT acc; 
        
        Opportunity opp = new Opportunity();
        opp.name ='Test opp';
        opp.AccountId = acc.id;
        opp.CloseDate = Date.newInstance(2019, 06, 20);
        opp.Market__c = marketTest.id;
        opp.Month_Year__c = monYea.id;
        opp.StageName = 'Qualification';
        opp.Commodity_Type__c = 'Gas';
        opp.Supplier_Price__c =100;
        
        INSERT opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.name ='Test opp';
        opp1.AccountId = acc.id;
        opp1.CloseDate = Date.newInstance(2019, 06, 20);
        opp1.Market__c = marketTest.id;
        opp1.Month_Year__c = monYea.id;
        opp1.StageName = 'Qualification';
        opp1.Commodity_Type__c = 'Gas';
        opp1.Supplier_Price__c =60;
        INSERT opp1;
        
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
        
        String[] siteList;
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        siteList = new String[]{accSite.id};
        
        Site__c accSite1 = new Site__c();
        accSite1.Name = 'AccountSite13';
        accSite1.Type__c = 'Gas';
        accSite1.Account__c = accServ1.id;
        accSite1.Market__c = marketTest.id;
        accSite1.Unit_of_Measure__c = 'GJ';
        accSite1.Volume__c = 1000;
        INSERT accSite1;
        
        siteList = new String[]{accSite1.id};  
        
        Product2 prod = new Product2();
        prod.Name = 'Gas - Small fixed';
        prod.Family = 'Gas';
        prod.ProductCode = 'Gas-Small Fixed';
        prod.Is_Fixed__c = true;
        prod.Size__c = 'Small';
        prod.Price_Type__c = 'Fixed';
        prod.IsActive = true;
        INSERT prod;
        
        
        
       
        
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
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.UnitPrice = 50;
        oli.Product2Id = Pro.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Site__c = accSite.id;
        oli.Quantity = 1;
        oli.OpportunityId = opp.id;
        INSERT oli;
        
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
        priceLi.Effective_From__c = datetime.newInstance(2019, 5, 12, 12, 30, 0);
        priceLi.Effective_To__c = datetime.newInstance(2019, 5, 30, 12, 30, 0);
        priceLi.Month_Year__c = monYea.id;
        Insert priceLi;
        
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
        
        PriceListValidateDate__c pricelist = New PriceListValidateDate__c();
        pricelist.Name = 'test';
        pricelist.Validate_Date__c = 165;
        insert pricelist;
      
        Test.startTest();
        Apexpages.currentPage().getParameters().put('Id',opp.id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(opp);
        AddSiteOnOpprtunityController addSiteOpp = New AddSiteOnOpprtunityController(stdCon);
        addSiteOpp.siteIds = accSite.Id + ',' + accSite1.Id;
        AddSiteOnOpprtunityController.getServiceAccountByOpportunity(opp.id);
        AddSiteOnOpprtunityController.getSiteList(acc.id, opp.Id);
        addSiteOpp.saveOpportunitySite();
        //AddSiteOnOpprtunityController.saveSitesdata(siteList,opp.id);
        AddSiteOnOpprtunityController.getServiceAccountByOpportunity(opp1.id);
        AddSiteOnOpprtunityController.getSiteList(acc.id, opp1.Id);
        //AddSiteOnOpprtunityController.saveSitesdata(siteList,opp1.id);
        addSiteOpp.saveOpportunitySite();
        Test.stopTest();
    }// End of test method
} // End of Test class