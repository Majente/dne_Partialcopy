/**************************************************
* Class: HScQuoteBillingAccountSetupTest
* Author: VP
* Date: 2019-11-17
* Description: Test class for HScQuoteBillingAccountSetup
****************************************************/
@istest
public  class HScQuoteBillingAccountSetupTest {
    
    @isTest
    public static void  testLeSite(){
      /*  pricebook2 prb = new pricebook2( 
        id =test.getStandardPricebookId(),
        IsActive = true);
        update prb;*/
  
  Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
  
        Account ac = new Account();
        ac.name = 'test account';
        ac.RecordTypeId =RecordTypeIdAccount;
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
        
        Site__c site = new Site__c();
        site.Name= 'Test Site01';
        site.Account__c=ac.id;
        site.Opportunity__c=oppObj.id;
        site.Type__c = 'Electricity';
        site.Unit_of_Measure__c = 'KWH';
        site.Volume__c= 10000;
        insert site;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = qut.Id;
        ql.SBQQ__PricebookEntryId__c = pbe.Id;
        ql.SBQQ__Product__c = pd.Id;
        ql.Site__c=site.id;
        insert ql;
           
        quoteLineList.add(ql);
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('qid', qut.id);
        HScQuoteBillingAccountSetup billingDisplay = new HScQuoteBillingAccountSetup();
        billingDisplay.loadQuoteDetails();
        test.stopTest();
        }
    }