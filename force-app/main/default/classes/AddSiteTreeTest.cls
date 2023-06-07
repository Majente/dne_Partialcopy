/**************************************************

* Class: AddSiteTreeTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test class for AddSiteTree

****************************************************/

@isTest
public class AddSiteTreeTest {
    Static Pricebook2 standardPricebook;    
    @testSetup
    public static void createpricebook(){
           standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),         //get standard pricebookId
            IsActive = true
        );
        UPDATE standardPricebook;
    }
    
    @isTest
    public static void testAddSiteTree(){
        //-----recordtypeId for Service Address type Account-----
        Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId(); 
        //-----recordtypeId for Supplier type Account-----
        Id supplierId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        //-----recordtypeId for Fixed type Opportunity-----
        Id oppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Fixed').getRecordTypeId();
          
        PriceListValidateDate__c priceListCusSetting = new PriceListValidateDate__c();
        priceListCusSetting.Validate_Date__c = 30;
        priceListCusSetting.SetupOwnerId = UserInfo.getOrganizationId();
        insert priceListCusSetting;
        
        Account supplierAccount = new Account();
        supplierAccount.Name = 'supplierAccount account';
        supplierAccount.RecordTypeId = supplierId;
        supplierAccount.Business_Size__c = 'Small';
        INSERT supplierAccount;
        
        Market__c testMarket = new Market__c();
        testMarket.Name = 'test market 1';
        testMarket.Gas_Threshold__c = 5.0;
        testMarket.Electricity_Threshold__c = 5.0;
        testMarket.Country__c = 'USA';
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
        theOpportunity.Subscription_Term__c = 12.00;
        theOpportunity.Supplier_Price__c = 20;
        theOpportunity.Admin_Fee__c = 20;
        theOpportunity.pricebook2id = Test.getStandardPricebookId();
        INSERT theOpportunity;
        
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
        testSite2.Opportunity__c = theOpportunity.Id;
        testSite2.Market__c = testMarket.Id;
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
        prod.ProductCode = 'Gas';
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
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = theOpportunity.Id;
        oli.Site__c = testSite.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 10.0;
        oli.TotalPrice = 50.0;
        INSERT oli;
        
        SBQQ__Quote__c quot = new SBQQ__Quote__c();
        quot.SBQQ__Opportunity2__c = theOpportunity.Id;
        quot.SBQQ__Primary__c = true;
        INSERT quot;
        
        Price_list__c plist = new Price_list__c();
        plist.Month_Year__c = monthYear.Id;
        plist.Term__c = '12';
        plist.Size__c = 'Large';
        plist.Market__c = testMarket.Id;
        plist.Name = 'Gas';
        plist.Latest__c = true;
        plist.Effective_From__c = Datetime.now();
        plist.Effective_To__c = Date.today().addDays(5);
        plist.Type__c = 'Fixed';
        plist.List_Price__c = 100.00;
        plist.Supplier__c = supplierAccount.Id;
        INSERT plist;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(theOpportunity);
        AddSiteTree siteTree = new AddSiteTree(sc);
        AddSiteTree.market = testMarket.Id;
        AddSiteTree.getServiceAccountByOpportunity(theOpportunity.Id); 
        List<Site__c> sites = AddSiteTree.getSiteList(parentAccount.Id,theOpportunity.Id);
        system.assertEquals(Test.getStandardPricebookId(),AddSiteTree.getStandardPB(),'error');
        system.assertEquals(null,AddSiteTree.saveSitesdata(siteList,theOpportunity.Id),'error');
        Apexpages.currentPage().getParameters().put('Id',theOpportunity.Id);
        siteTree.siteIds = testSite.Id;
        siteTree.saveOpportunitySite();
        String parentId = parentAccount.Id;
        AddSiteTree.TreeWrapper trWrapper = new AddSiteTree.TreeWrapper(parentId);
        trWrapper.addSite(testSite);
        system.assertEquals(quot.Id, AddSiteTree.fetchQuoteId(theOpportunity), 'error');
        Test.stopTest();
        system.assertEquals(1, sites.size(), 'error');
        
    }
}