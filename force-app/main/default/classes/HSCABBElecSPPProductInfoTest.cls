/**************************************************
* Class: HSCABBElecSPPProductInfo
* Author: VP
* Date: 2019-11-17
* Description: Test class for HSCABBElecSPPProductInfo
****************************************************/
@istest
public  class HSCABBElecSPPProductInfoTest {
    
    @isTest
    public static void  testLeSite2(){
      /*  pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
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
        insert ql;
           
        quoteLineList.add(ql);
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        HSCABBElecSPPProductInfo producInfo = new HSCABBElecSPPProductInfo();
        producInfo.init();
        producInfo.chooseplan();
        test.stopTest();
        }
        
    
    @istest
        public static void  testLeSite3(){
      /*  pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
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
        insert ql;
           
        quoteLineList.add(ql);
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        HSCABBElecSPPProductInfo producInfo = new HSCABBElecSPPProductInfo();
        producInfo.init();
        producInfo.chooseplan();
        test.stopTest();
        }
       
    @istest
        public static void  testLeSite4(){
       /* pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
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
        insert ql;
           
        quoteLineList.add(ql);
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        HSCABBElecSPPProductInfo producInfo = new HSCABBElecSPPProductInfo();
        producInfo.init();
        producInfo.chooseplan();
        test.stopTest();
        }
        @isTest
        public static void  testLeSite5(){
       /* pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
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
        insert ql;
           
        quoteLineList.add(ql);
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        HSCABBElecSPPProductInfo producInfo = new HSCABBElecSPPProductInfo();
        producInfo.init();
        producInfo.chooseplan();
        test.stopTest();
        }
        @istest
        public static void  testLeSite6(){
       /* pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
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
        insert ql;
           
        quoteLineList.add(ql);
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        HSCABBElecSPPProductInfo producInfo = new HSCABBElecSPPProductInfo();
        producInfo.init();
        producInfo.chooseplan();
        test.stopTest();
        }
         @isTest
        public static void  testLeSite7(){
       /* pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
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
        insert ql;
           
        quoteLineList.add(ql);
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        HSCABBElecSPPProductInfo producInfo = new HSCABBElecSPPProductInfo();
        producInfo.init();
        producInfo.chooseplan();
        test.stopTest();
        }
        @istest
        public static void  testLeSite8(){
       /* pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
  
        Account ac = new Account();
        ac.name = 'test account';
        insert ac;
        
        Opportunity oppObj = new Opportunity();
        oppObj.stageName = 'Qualification';
        oppObj.Name = 'test opp';
        oppObj.AccountId = ac.id;
        oppObj.CloseDate = date.today().addDays(5);
        insert oppObj;
        
        SBQQ__Quote__c qut = new SBQQ__Quote__c();
        qut.SBQQ__Opportunity2__c = oppObj.Id;
        qut.SBQQ__Primary__c = True;
        qut.SBQQ__SubscriptionTerm__c = 72;
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
        insert ql;
           
        quoteLineList.add(ql);
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        HSCABBElecSPPProductInfo producInfo = new HSCABBElecSPPProductInfo();
        producInfo.init();
        producInfo.chooseplan();
        test.stopTest();
        }
    }