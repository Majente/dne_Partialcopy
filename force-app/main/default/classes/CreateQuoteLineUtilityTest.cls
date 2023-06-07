/**************************************************
* Class: CreateQuoteLineUtilityTest
* Author: Soljit <VW>
* Date: 2019-12-14
* Description: Test class for CreateQuoteLineUtility
****************************************************/

@isTest
public class CreateQuoteLineUtilityTest {
    
    /*********************************************************
    @Name 			: testCreateQuoteLineUtility
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for CreateQuoteLineUtility
	********************************************************/
    @isTest
    public static void testCreateQuoteLineUtility(){
        //-----recordtypeId for Service Address type Account-----
        Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId(); 
        //-----recordtypeId for Supplier type Account-----
        Id supplierId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        //-----recordtypeId for Fixed type Opportunity-----
        Id oppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Fixed').getRecordTypeId();
        
        Account supplierAccount = new Account();
        supplierAccount.Name = 'supplierAccount account';
        supplierAccount.RecordTypeId = supplierId;
        supplierAccount.Business_Size__c = 'Small';
        INSERT supplierAccount;
        
        Market__c testMarket = new Market__c();
        testMarket.Name = 'test market 1';
        testMarket.Gas_Threshold__c = 5.0;
        testMarket.Electricity_Threshold__c = 5.0;
        testMarket.Country__c = 'CANADA';        
        INSERT testMarket;
        
        Account parentAccount = new Account();
        parentAccount.Name = 'test parent account';
        parentAccount.RecordTypeId = recordId;
        parentAccount.Market__c = testMarket.Id;
        parentAccount.Business_Size__c = 'Small';
        INSERT parentAccount;
        
        Account theAccount = new Account();
        theAccount.Name = 'test account';
        theAccount.RecordTypeId = recordId;
        theAccount.ParentId = parentAccount.Id;
        theAccount.Market__c = testMarket.Id;
        theAccount.Business_Size__c = 'Small';
        INSERT theAccount;
        
        Month_Year__c monthYear = new Month_Year__c();
        monthYear.Name = DateTime.now().format('MMMM') + ' ' + DateTime.now().year();
        monthYear.Month__c = System.now().month();
        monthYear.Year__c = System.now().year();
        INSERT monthYear;
        
        /*Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),         //get standard pricebookId
            IsActive = true
        );
         Update standardPricebook;  */
        Opportunity theOpportunity = new Opportunity();
        theOpportunity.Name = 'test opp';
        theOpportunity.CloseDate = date.today().addDays(5);
        theOpportunity.StageName = 'Proposal';
        theOpportunity.Commodity_Type__c = 'Gas';
        theOpportunity.AccountId = parentAccount.Id;
        theOpportunity.Market__c = testMarket.Id;
        theOpportunity.Electricity_Product_of_Choice__c = 'test electricity choice';
        theOpportunity.Gas_Product_of_Choice__c = 'test Gas choice';
        theOpportunity.Supplier__c = supplierAccount.Id;
        theOpportunity.Margin__c = 10;
        theOpportunity.RecordTypeId = oppRecId;
        theOpportunity.Month_Year__c = monthYear.Id;
        theOpportunity.Subscription_Term__c = 12;
        theOpportunity.Supplier_Price__c = 20;
        theOpportunity.Admin_Fee__c = 20;
        theOpportunity.pricebook2id = Test.getStandardPricebookId();
        INSERT theOpportunity;
        
        Set<Id> oppIdList = new Set<Id>();
        oppIdList.add(theOpportunity.Id);
        
        Site__c testSite = new Site__c();
        testSite.Name = 'test site';
        testSite.Type__c = 'Gas';
        testSite.Opportunity__c = theOpportunity.Id;
        testSite.Market__c = testMarket.Id;
        testSite.Volume__c = 10.0;
        testSite.Unit_of_Measure__c = 'GJ';
        testSite.Account__c = parentAccount.Id;
        INSERT testSite;
        
        Site__c testSite2 = new Site__c();
        testSite2.Name = 'test site2';
        testSite2.Type__c = 'Gas';
        testSite2.Volume__c = 10.0;
        testSite2.Unit_of_Measure__c = 'GJ';
        testSite2.Account__c = parentAccount.Id;
        INSERT testSite2;
        List<String> siteList = new List<String>();
        siteList.add(testSite.ID);
        siteList.add(testSite2.Id);
        
        Product2 prod = new Product2();
        prod.Name = 'Gas';
        prod.Family = 'Gas';
        prod.ProductCode = 'Electricity';
        prod.Price_Type__c = 'Fixed';
        prod.Size__c = 'Large';
        prod.Is_Fixed__c = true;
        INSERT prod;
  
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
             
        pricebookentry pbe = new pricebookentry();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 50.0;
        pbe.IsActive = true;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        INSERT pbe;
                        
        Price_list__c plist = new Price_list__c();
        plist.Month_Year__c = monthYear.Id;
        plist.Term__c = '12';
        plist.Size__c = 'Large';
        plist.Market__c = testMarket.Id;
        plist.Name = 'Electricity';
        plist.Month_Year__c = monthYear.Id;
        plist.Latest__c = true;
        plist.Effective_From__c = Datetime.now();
        plist.Effective_To__c = Date.today().addDays(5);
        plist.Type__c = 'Fixed';
        plist.List_Price__c = 100.00;
        plist.Supplier__c = supplierAccount.Id;
        INSERT plist;
        
        PriceListValidateDate__c pricelist = New PriceListValidateDate__c();
        pricelist.Name = 'test';
        pricelist.Validate_Date__c = 165;
        insert pricelist;
        
        Test.startTest();

        CreateQuoteLineUtility.getAllProducts(new Set<String>{'Gas'},new Set<String>{'Fixed'},new Set<String>{'Large'});
        CreateQuoteLineUtility.fetchQuoteId(New Set<Id>{theOpportunity.Id});
        Id quoteId = [Select Id from SBQQ__Quote__c where SBQQ__Opportunity2__c =: theOpportunity.Id LIMIT 1].Id;
        CreateQuoteLineUtility.createQLI(prod.Id, quoteId, New List<Site__c>{testSite}, plist.List_Price__c + theOpportunity.Margin__c, theOpportunity.Subscription_Term__c, theOpportunity.Margin__c);        
        CreateQuoteLineUtility.createQLI(prod.Id, quoteId, New List<Site__c>{testSite2}, plist.List_Price__c + theOpportunity.Margin__c, theOpportunity.Subscription_Term__c, theOpportunity.Margin__c, theOpportunity.Supplier_Price__c);

        system.assertEquals(2, [select id from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId].size());

        CreateQuoteLineUtility.createQuote(theOpportunity.Id);

        system.assertEquals(2, [Select Id from SBQQ__Quote__c where SBQQ__Opportunity2__c =: theOpportunity.Id].size());

        Test.stopTest();
        
    }// End of test method
} // End of Test class