@IsTest
public class InvoiceEntryControllerTest {
@IsTest
    static void TestMethod1(){
        Test.startTest();
        InvoiceEntryController.getData('CSV_INVOICE_DATA_TEMP__c');
        Test.stopTest();
    }
    @IsTest
    static void TestMethod2(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
       
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
        acc.Name = 'Vegreville Lanes';
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
        opp.Flow_Date__c = system.today();
        opp.Subscription_Term__c = 60;
        opp.Monthly_Site_Admin_Fee__c = 0;
		opp.Daily_Site_Admin_Fee__c = 0;
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
        opp.Flow_Date__c = system.today();
        opp.Subscription_Term__c = 60;
        opp.Monthly_Site_Admin_Fee__c = 0;
		opp.Daily_Site_Admin_Fee__c = 0;
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
        accSite.Name = '0010210837514';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        siteList = new String[]{accSite.id};
        
        Site__c accSite1 = new Site__c();
        accSite1.Name = '0010210837515';
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
        
        Contract theContract = new Contract();
        theContract.SBQQ__Opportunity__c = opp.Id;
        theContract.StartDate = system.today();
        theContract.ContractTerm = 60;
        theContract.AccountId = acc.Id;
        INSERT theContract;
        
        SBQQ__Subscription__c theSubscription = new SBQQ__Subscription__c();
        theSubscription.SBQQ__SubscriptionStartDate__c = Date.today();
        theSubscription.SBQQ__SubscriptionEndDate__c = Date.today().addYears(4);
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
        
        PriceListValidateDate__c pricelist = New PriceListValidateDate__c();
        pricelist.Name = 'test';
        pricelist.Validate_Date__c = 165;
        insert pricelist;
        
        CSV_INVOICE_DATA_TEMP__c invoice = new CSV_INVOICE_DATA_TEMP__c();
        invoice.LDC_Account_Number__c = '0010210837514';
        invoice.Customer_Name__c = 'Vegreville Lanes';
        invoice.Commodity__c = 'Gas';
        invoice.Contract_End_Date__c = date.valueOf('2027-10-03'); 
        invoice.Contract_Start_Date__c = system.today();
        invoice.Contract_Term_Months__c = 60;
        invoice.MatchedContract__c = theContract.id;
        invoice.Contract_ID__c = 'C00054851';
         invoice.Calculation_Type__c = '50/50 On Flow';
        Insert invoice;
        
        List<string> IdList = new List<string>();
        IdList.add(invoice.id);
        Test.startTest();
        InvoiceEntryController.ProcessEntry(IdList);
        Test.stopTest();
    }
}