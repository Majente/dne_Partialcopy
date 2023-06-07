/**************************************************
* Class: FindContractForActivationBatchTest
* Description: Test class for FindContractForActivationBatch and FindContractForActivationBatchSchedule class
****************************************************/
@isTest
public class FindContractForActivationBatchTest {
 @testSetup
    public static void createTestData(){
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Country__c = 'Canada';
        marketTest.Electricity_Threshold__c = 250000;
        INSERT marketTest;
        
        List<Account> accToInsertList = new List<Account>();
        Id account_RTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Account acc =new Account();
        acc.Name = 'Test Account' + Integer.valueOf(Math.random() * 100);
        acc.RecordTypeId = account_RTId;
        acc.Market__c = marketTest.Id;
        accToInsertList.add(acc);
        
        Id supplier_RTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Account supplier =new Account();
        supplier.Name = 'Test Supplier';
        supplier.RecordTypeId = supplier_RTId;
        supplier.Market__c = marketTest.Id;
        accToInsertList.add(supplier); 

        Id serviceAddress_RTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = serviceAddress_RTId;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = acc.id;
        accServ.Business_Size__c = 'Small';
        accToInsertList.add(accServ); 

        INSERT accToInsertList;
        
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = DateTime.now().format('MMMM') + ' ' + DateTime.now().year();
        monYea.Month__c = System.now().month();
        monYea.Year__c = System.now().Year();
        insert monYea;
        
        Account dneAccount = new Account();
		dneAccount.Name = 'DNE';
		INSERT dneAccount;
        
        List<Contact> commissionReceiverList = new List<Contact>();
        Contact opener1 = new Contact();
		opener1.AccountId = dneAccount.Id;
		opener1.FirstName = 'Commission_';
		opener1.LastName = 'Opener_1';
		commissionReceiverList.add(opener1);

		Contact closer1 = new Contact();
		closer1.AccountId = dneAccount.Id;
		closer1.FirstName = 'Commission_';
		closer1.LastName = 'Closer_1';
		commissionReceiverList.add(closer1);

		Contact opener2 = new Contact();
		opener2.AccountId = dneAccount.Id;
		opener2.FirstName = 'Commission_';
		opener2.LastName = 'Opener_2';
		commissionReceiverList.add(opener2);

		Contact closer2 = new Contact();
		closer2.AccountId = dneAccount.Id;
		closer2.FirstName = 'Commission_';
		closer2.LastName = 'Closer_2';
		commissionReceiverList.add(closer2);

		INSERT commissionReceiverList;

        Id fixedOppty_RTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Fixed').getRecordTypeId();
		Opportunity theOppty = new Opportunity();
        theOppty.RecordTypeId = fixedOppty_RTId;
		theOppty.Type = 'New Business';
        theOppty.Name ='Test opp' + Integer.valueOf(Math.random() * 100);
        theOppty.AccountId = acc.Id;
        theOppty.CloseDate = Date.today().addDays(5);
        theOppty.Market__c = marketTest.Id;
        theOppty.Month_Year__c = monYea.Id;
        theOppty.StageName = 'Closed Won';
        theOppty.Commodity_Type__c = 'Gas';
        theOppty.Pricebook2Id = Test.getStandardPricebookId();
        theOppty.Subscription_Term__c = 36;
        theOppty.Margin__c = 4;
        theOppty.Selling_Price__c = 50;
        theOppty.Supplier_Price__c = 50;
        theOppty.Gas_Product_of_Choice__c = 'Fixed';
        theOppty.Supplier__c = supplier.Id;
        theOppty.Opener__c = opener1.Id;
        theOppty.Opener_2__c = opener2.Id;
        theOppty.Closer__c = closer1.Id;
        theOppty.Closer_2__c = closer2.Id;

        Date aMonthFromNow = Date.today().addMonths(1);
		Date theFlowDate = Date.newInstance(aMonthFromNow.year(), aMonthFromNow.month(), 1);
        theOppty.Flow_Date__c = theFlowDate;
        INSERT theOppty;
        
        List<Opportunity> oppList = new List<Opportunity>();
        theOppty.StageName = 'Closed Won';
        oppList.add(theOppty);
        
        Opportunity theOppty2 = new Opportunity();
        theOppty2.RecordTypeId = fixedOppty_RTId;
		theOppty2.Type = 'New Business';
        theOppty2.Name ='Test opp' + Integer.valueOf(Math.random() * 100);
        theOppty2.AccountId = acc.Id;
        theOppty2.CloseDate = Date.today().addDays(5);
        theOppty2.Market__c = marketTest.Id;
        theOppty2.Month_Year__c = monYea.Id;
        theOppty2.StageName = 'Closed Won';
        theOppty2.Commodity_Type__c = 'Gas';
        theOppty2.Pricebook2Id = Test.getStandardPricebookId();
        theOppty2.Subscription_Term__c = 36;
        theOppty2.Margin__c = 4;
        theOppty2.Selling_Price__c = 50;
        theOppty2.Supplier_Price__c = 50;
        theOppty2.Gas_Product_of_Choice__c = 'Fixed';
        theOppty2.Supplier__c = supplier.Id;
        theOppty2.Opener__c = opener1.Id;
        theOppty2.Opener_2__c = opener2.Id;
        theOppty2.Closer__c = closer1.Id;
        theOppty2.Closer_2__c = closer2.Id;
        theOppty2.Flow_Date__c = theFlowDate;
        INSERT theOppty2;
        
        theOppty2.StageName = 'Closed Won';
        oppList.add(theOppty2);
        
        UPDATE oppList;
        
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
        INSERT pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.UnitPrice = 50;
        oli.Product2Id = Pro.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Site__c = accSite.id;
        oli.Quantity = 1;
        oli.OpportunityId = theOppty.id;
        INSERT oli;
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.UnitPrice = 50;
        oli2.Product2Id = Pro.Id;
        oli2.PricebookEntryId = pbe.Id;
        oli2.Site__c = accSite.id;
        oli2.Quantity = 1;
        oli2.OpportunityId = theOppty2.id;
        INSERT oli2;
        
        Contract theContract = new Contract();
        theContract.SBQQ__Opportunity__c = theOppty.Id;
        theContract.StartDate = Date.today();
        theContract.Payment_Terms__c = '50% Upfront on flow and 50% Residual - Monthly';
        theContract.ContractTerm = 36;
        theContract.AccountId = acc.Id;
        theContract.CurrentVolume__c = 50;
        theContract.CurrentAmount__c = 50;
        theContract.Status = 'Draft';
        theContract.Supplier_s_contract_ID__c = 'sup - ' + Integer.valueOf(Math.random() * 100);
        INSERT theContract;
        
        Contract theContract2 = new Contract();
        theContract2.SBQQ__Opportunity__c = theOppty2.Id;
        theContract2.StartDate = Date.today();
        theContract2.Payment_Terms__c = '50% Upfront on flow and 50% Residual - Monthly';
        theContract2.ContractTerm = 36;
        theContract2.AccountId = acc.Id;
        theContract2.CurrentVolume__c = 50;
        theContract2.CurrentAmount__c = 50;
        theContract2.Status = 'Draft';
        theContract2.Supplier_s_contract_ID__c = 'sup - ' + Integer.valueOf(Math.random() * 100);
        INSERT theContract2;
        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c = theOppty.id;
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__MasterContract__c = theContract.Id;
        newQuote.SBQQ__StartDate__c = System.today();
        Insert newQuote;
        
        SBQQ__Quote__c newQuote2 = new SBQQ__Quote__c();
        newQuote2.SBQQ__Opportunity2__c = theOppty2.id;
        newQuote2.SBQQ__Primary__c = true;
        newQuote2.SBQQ__MasterContract__c = theContract2.Id;
        newQuote2.SBQQ__StartDate__c = System.today();
        Insert newQuote2;
        
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
        quoteLine2.SBQQ__Quote__c = newQuote2.id;
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
        
        SBQQ__Subscription__c theSubscription2 = new SBQQ__Subscription__c();
        theSubscription2.SBQQ__SubscriptionStartDate__c = Date.today().addDays(-1);
        theSubscription2.SBQQ__SubscriptionEndDate__c = Date.today().addYears(2);
        theSubscription2.SBQQ__Product__c = quoteLine2.SBQQ__Product__c;
        theSubscription2.SBQQ__QuoteLine__c  = quoteLine2.id;        
        theSubscription2.SBQQ__Quantity__c = quoteLine2.SBQQ__Quantity__c;
        theSubscription2.SBQQ__ListPrice__c  = quoteLine2.SBQQ__ListPrice__c;
        theSubscription2.SBQQ__Account__c = acc.Id;
        theSubscription2.Annual_Volume__c = 100;
        theSubscription2.SBQQ__Contract__c = theContract2.Id;
        theSubscription2.SBQQ__Number__c =quoteLine2.SBQQ__Number__c;
        theSubscription2.Site__c = quoteLine2.site__c;
        INSERT theSubscription2;
         
    }
    @isTest
    public static void testActivateBatch(){
        
        Test.startTest();
        FindContractForActivationBatchSchedule testsche = new FindContractForActivationBatchSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}