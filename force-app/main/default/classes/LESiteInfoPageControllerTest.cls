/**************************************************
* Class: LESiteInfoPageControllerTest
* Author: Soljit <VW>
* Date: 2019-06-26
* Description: Test class for LESiteInfoPageController
****************************************************/
@istest
public  class LESiteInfoPageControllerTest {
    
    /*********************************************************
    @Name           : testLeSite
    @Parameters     : 
    @Reutrn type    : void
    @Description    : test method for LESiteInfoPageController
    ********************************************************/
    @isTest
    public static void  testLeSite(){
       /* pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Country__c = 'USA';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        INSERT marketTest;
        
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();

        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = ac.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 

        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;

        Opportunity oppObj = new Opportunity();
        oppObj.stageName = 'Qualification';
        oppObj.Name = 'test opp';
        oppObj.AccountId = ac.id;
        oppObj.CloseDate = date.today().addDays(5);
        insert oppObj;
        
        SBQQ__Quote__c qut = new SBQQ__Quote__c();
        qut.SBQQ__Opportunity2__c = oppObj.Id;
        qut.SBQQ__Primary__c = True;
        qut.SBQQ__SubscriptionTerm__c = 12;
        qut.SBQQ__Account__c = ac.Id;
        insert qut;
        
        
        Product2 pd = new Product2();
        pd.Name = 'test pro';
        pd.ProductCode = 'Electricity-Custom';
        pd.Family = 'Electricity';
        pd.Is_Fixed__c = true;
        pd.IsActive = true;
        insert pd;
       
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = test.getStandardPricebookId();
        pbe.IsActive = true;
        pbe.Product2Id = pd.Id;
        pbe.UnitPrice = 50;
        insert pbe;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = qut.Id;
        ql.SBQQ__PricebookEntryId__c = pbe.Id;
        ql.SBQQ__Product__c = pd.Id;
        ql.Site__c = accSite.Id;
        insert ql;
           
        quoteLineList.add(ql);
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        LESiteInfoPageController leSitePage = new LESiteInfoPageController();
        leSitePage.init();
        leSitePage.siteCountVolume();
        leSitePage.chooseplan();
        leSitePage.chooseplan2();
        test.stopTest();
     
    }
    
    /*********************************************************
    @Name           : testLeSite2
    @Parameters     : 
    @Reutrn type    : void
    @Description    : test method for LESiteInfoPageController
    ********************************************************/
     @isTest
    public static void  testLeSite2(){
      /*  pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Country__c = 'USA';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        INSERT marketTest;
        
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();

        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = ac.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 

        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;

        Opportunity oppObj = new Opportunity();
        oppObj.stageName = 'Qualification';
        oppObj.Name = 'test opp';
        oppObj.AccountId = ac.id;
        oppObj.CloseDate = date.today().addDays(5);
        insert oppObj;
        
        SBQQ__Quote__c qut = new SBQQ__Quote__c();
        qut.SBQQ__Opportunity2__c = oppObj.Id;
        qut.SBQQ__Primary__c = True;
        qut.SBQQ__SubscriptionTerm__c = 24;
        qut.SBQQ__Account__c = ac.Id;
        insert qut;
        
        Product2 pd = new Product2();
        pd.Name = 'test pro';
        pd.ProductCode = 'Electricity-Custom';
        pd.Family = 'Gas';
        pd.IsActive = true;
        pd.Is_Fixed__c = true;
        insert pd;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = test.getStandardPricebookId();
        pbe.IsActive = true;
        pbe.Product2Id = pd.Id;
        pbe.UnitPrice = 50;
        insert pbe;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = qut.Id;
        ql.SBQQ__PricebookEntryId__c = pbe.Id;
        ql.SBQQ__Product__c = pd.Id;
        ql.Site__c = accSite.Id;
        insert ql;
        quoteLineList.add(ql);
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        LESiteInfoPageController leSitePage = new LESiteInfoPageController();
        leSitePage.init();
        leSitePage.siteCountVolume();
        leSitePage.chooseplan();
        leSitePage.chooseplan2();
        test.stopTest();
    }
    
    /*********************************************************
    @Name           : testLeSite3
    @Parameters     : 
    @Reutrn type    : void
    @Description    : test method for LESiteInfoPageController
    ********************************************************/
       @isTest
    public static void  testLeSite3(){
      /*  pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;

        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Country__c = 'USA';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        INSERT marketTest;
        
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();

        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = ac.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 

        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        
        Opportunity oppObj = new Opportunity();
        oppObj.stageName = 'Qualification';
        oppObj.Name = 'test opp';
        oppObj.AccountId = ac.id;
        oppObj.CloseDate = date.today().addDays(5);
        insert oppObj;
        
        SBQQ__Quote__c qut = new SBQQ__Quote__c();
        qut.SBQQ__Opportunity2__c = oppObj.Id;
        qut.SBQQ__Primary__c = True;
        qut.SBQQ__SubscriptionTerm__c = 36;
        qut.SBQQ__Account__c = ac.Id;
        insert qut;
        
        Product2 pd = new Product2();
        pd.Name = 'test pro';
        pd.ProductCode = 'Electricity-Custom';
        pd.Family = 'Gas';
        pd.IsActive = true;
        pd.Is_Fixed__c = false;
        insert pd;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = test.getStandardPricebookId();
        pbe.IsActive = true;
        pbe.Product2Id = pd.Id;
        pbe.UnitPrice = 50;
        insert pbe;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = qut.Id;
        ql.SBQQ__PricebookEntryId__c = pbe.Id;
        ql.SBQQ__Product__c = pd.Id; 
        ql.Site__c = accSite.Id;
        insert ql;
        quoteLineList.add(ql);
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        LESiteInfoPageController leSitePage = new LESiteInfoPageController();
        leSitePage.init();
        leSitePage.siteCountVolume();
        leSitePage.chooseplan();
        leSitePage.chooseplan2();
        test.stopTest();
    }
    
    /*********************************************************
    @Name           : testLeSite4
    @Parameters     : 
    @Reutrn type    : void
    @Description    : test method for LESiteInfoPageController
    ********************************************************/
         @isTest
    public static void  testLeSite4(){
        /*pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;

        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Country__c = 'USA';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        INSERT marketTest;
        
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();

        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = ac.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 

        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        
        Opportunity oppObj = new Opportunity();
        oppObj.stageName = 'Qualification';
        oppObj.Name = 'test opp';
        oppObj.AccountId = ac.id;
        oppObj.CloseDate = date.today().addDays(5);
        insert oppObj;
        
        SBQQ__Quote__c qut = new SBQQ__Quote__c();
        qut.SBQQ__Opportunity2__c = oppObj.Id;
        qut.SBQQ__Primary__c = True;
        qut.SBQQ__SubscriptionTerm__c = 48;
        qut.SBQQ__Account__c = ac.Id;
        insert qut;
        
        Product2 pd = new Product2();
        pd.Name = 'test pro';
        pd.ProductCode = 'Electricity-Custom';
        pd.Family = 'Electricity';
        pd.IsActive = true;
        pd.Is_Fixed__c = false;
        insert pd;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = test.getStandardPricebookId();
        pbe.IsActive = true;
        pbe.Product2Id = pd.Id;
        pbe.UnitPrice = 50;
        insert pbe;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = qut.Id;
        ql.SBQQ__PricebookEntryId__c = pbe.Id;
        ql.SBQQ__Product__c = pd.Id; 
        ql.Site__c = accSite.Id;
        insert ql;
        quoteLineList.add(ql);
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        LESiteInfoPageController leSitePage = new LESiteInfoPageController();
        leSitePage.init();
        leSitePage.siteCountVolume();
        leSitePage.chooseplan();
        leSitePage.chooseplan2();
        test.stopTest();
    }
    
    /*********************************************************
    @Name           : testLeSite5
    @Parameters     : 
    @Reutrn type    : void
    @Description    : test method for LESiteInfoPageController
    ********************************************************/
         @isTest
    public static void  testLeSite5(){
       /* pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;

        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Country__c = 'USA';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        INSERT marketTest;
        
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();

        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = ac.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 

        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        
        Opportunity oppObj = new Opportunity();
        oppObj.stageName = 'Qualification';
        oppObj.Name = 'test opp';
        oppObj.AccountId = ac.id;
        oppObj.CloseDate = date.today().addDays(5);
        insert oppObj;
        
        SBQQ__Quote__c qut = new SBQQ__Quote__c();
        qut.SBQQ__Opportunity2__c = oppObj.Id;
        qut.SBQQ__Primary__c = True;
        qut.SBQQ__SubscriptionTerm__c = 60;
        qut.SBQQ__Account__c = ac.Id;
        insert qut;
        
        Product2 pd = new Product2();
        pd.Name = 'test pro';
        pd.ProductCode = 'Electricity-Custom';
        pd.Family = 'Electricity';
        pd.IsActive = true;
        pd.Is_Fixed__c = false;
        insert pd;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = test.getStandardPricebookId();
        pbe.IsActive = true;
        pbe.Product2Id = pd.Id;
        pbe.UnitPrice = 50;
        insert pbe;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = qut.Id;
        ql.SBQQ__PricebookEntryId__c = pbe.Id;
        ql.SBQQ__Product__c = pd.Id; 
        ql.Site__c = accSite.Id;
        insert ql;
        quoteLineList.add(ql);
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        LESiteInfoPageController leSitePage = new LESiteInfoPageController();
        leSitePage.init();
        leSitePage.siteCountVolume();
        leSitePage.chooseplan();
        leSitePage.chooseplan2();
        test.stopTest();
    }
}