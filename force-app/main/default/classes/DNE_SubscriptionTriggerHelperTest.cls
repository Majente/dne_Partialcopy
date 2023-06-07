/**************************************************
* Class: DNE_SubscriptionTriggerHelperTest
* Author: Soljit <VW>
* Date: DEC 2019
* Description : test class for DNE_SubscriptionTriggerHelper
****************************************************/
@isTest
private class DNE_SubscriptionTriggerHelperTest 
{
    static FINAL String COMMISSION_RECEIVER_FIRST_NAME = 'Commission_';
    static FINAL String COMMISSION_RECEIVER_LAST_NAME = 'Receiver_';
    static FINAL Integer NB_OF_COMMISSION_LEVELS = 15;
    
    static Contract theContract;
    static Contract theContract2;
    static Contract theContract3;
    static Contract theContract4;
    static List<DNE_Commission_Hierarchy__c> commissionHierarchyList;
    static DNE_Commission_Percent__c commissionPercent;
    static Opportunity theOppty;
    static Opportunity theOppty2;
    static Opportunity theOppty3;
    static Opportunity theOppty4;
    static SBQQ__Subscription__c theSubscription;
    static SBQQ__Subscription__c theSubscription2;
    static SBQQ__Subscription__c theSubscription3;
    static SBQQ__Subscription__c theSubscription4;
    static Contact opener1;
    static Contact closer1;
    static Contact opener2;
    static Contact closer2;
    static Account acc;
    static Opportunity opp;
    static SBQQ__QuoteLine__c quoteLine;
    static SBQQ__QuoteLine__c amendQuote;
    static Case caseRec;
    
    //@testSetup
    static void createData()
    {
        List<Contact> commissionReceiverList = new List<Contact>();
        commissionHierarchyList = new List<DNE_Commission_Hierarchy__c>();
        commissionPercent = new DNE_Commission_Percent__c();
        theOppty = new Opportunity();
        theContract = new Contract();
        theSubscription = new SBQQ__Subscription__c();
        theOppty2 = new Opportunity();
        theOppty3 = new Opportunity();
        theOppty4 = new Opportunity();
        theContract2 = new Contract();
        theContract3 = new Contract();
        theContract4 = new Contract();
        theSubscription2 = new SBQQ__Subscription__c();
        theSubscription3 = new SBQQ__Subscription__c();
        theSubscription4 = new SBQQ__Subscription__c();
        // -------- CREATING THE MARKET --------
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'CANADA';        
        insert marketTest;
        
        // -------- CREATING THE ACCOUNTS --------   
        
        List<Account> accToInsertList = new List<Account>();
        
        Id account_RTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        acc =new Account();
        acc.Name = 'Test Account';
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
        
        insert accToInsertList;
        
        // -------- CREATING THE SITE -------- 
        
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        insert accSite;
        
        Site__c amendSite = new Site__c();
        amendSite.Name = 'AmendSite 001';
        amendSite.Type__c = 'Gas';
        amendSite.Account__c = accServ.id;
        amendSite.Market__c = marketTest.id;
        amendSite.Unit_of_Measure__c = 'GJ';
        amendSite.Volume__c = 1200;
        insert amendSite;
        
        
        // -------- CREATING THE CONTACTS --------
        
        //Id commRec_RTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Commission_Receiver').getRecordTypeId();
        Account dneAccount = new Account();
        dneAccount.Name = 'DNE';
        insert dneAccount;
        
        for(Integer i=0; i<NB_OF_COMMISSION_LEVELS; i++)
        {
            Contact comm_rec = new Contact();
            comm_rec.AccountId = dneAccount.Id;
            comm_rec.FirstName = COMMISSION_RECEIVER_FIRST_NAME;
            comm_rec.LastName = COMMISSION_RECEIVER_LAST_NAME + i;
            commissionReceiverList.add(comm_rec);
        }
        
        opener1 = new Contact();
        opener1.AccountId = dneAccount.Id;
        opener1.FirstName = COMMISSION_RECEIVER_FIRST_NAME;
        opener1.LastName = 'Opener_1';
        commissionReceiverList.add(opener1);
        
        closer1 = new Contact();
        closer1.AccountId = dneAccount.Id;
        closer1.FirstName = COMMISSION_RECEIVER_FIRST_NAME;
        closer1.LastName = 'Closer_1';
        commissionReceiverList.add(closer1);
        
        opener2 = new Contact();
        opener2.AccountId = dneAccount.Id;
        opener2.FirstName = COMMISSION_RECEIVER_FIRST_NAME;
        opener2.LastName = 'Opener_2';
        commissionReceiverList.add(opener2);
        
        closer2 = new Contact();
        closer2.AccountId = dneAccount.Id;
        closer2.FirstName = COMMISSION_RECEIVER_FIRST_NAME;
        closer2.LastName = 'Closer_2';
        commissionReceiverList.add(closer2);
        
        insert commissionReceiverList;
        
        // --------Creating case record----------
        caseRec = new Case();
        caseRec.Type = 'To Operations';
        caseRec.Status = 'New';
        caseRec.Priority = 'Medium';
        caseRec.Term__c = '12';
        caseRec.Subject = 'Test Case Subject';
        caseRec.Origin = 'Email';
        INSERT caseRec;
        
        // -------- CREATING THE COMMISSION HIERARCHIES --------
        
        DNE_Commission_Hierarchy__c ch1 = new DNE_Commission_Hierarchy__c();
        ch1.Opener__c = opener1.Id;
        ch1.Effective_From__c = Datetime.now().addDays(-1);
        ch1.Type__c = 'New Business';
        
        for(Integer i=0; i<NB_OF_COMMISSION_LEVELS; i++)
        {
            ch1.put('Level_' + (i+1) + '__c', commissionReceiverList.get(i).Id);
        }
        commissionHierarchyList.add(ch1);
        
        DNE_Commission_Hierarchy__c ch2 = new DNE_Commission_Hierarchy__c();
        ch2.Opener__c = opener2.Id;
        ch2.Effective_From__c = Datetime.now().addDays(-1);
        ch2.Type__c = 'New Business';
        
        for(Integer i=NB_OF_COMMISSION_LEVELS; i>0; i--)
        {
            ch2.put('Level_' + i + '__c', commissionReceiverList.get(i).Id);
        }
        commissionHierarchyList.add(ch2);
        
        insert commissionHierarchyList;
        
        // -------- CREATING THE COMMISSION PERCENTS --------
        
        commissionPercent.Type__c = 'New Business';
        commissionPercent.Contract_Type__c = 'Fixed within 12 months';
        commissionPercent.Effective_From__c = Datetime.now().addDays(-1);
        commissionPercent.Max_Payout_Upfront__c = 50000;
        
        List<String> commissionTypes = new List<String>{'Commission', 'Upfront', 'Flow', 'Residual'};
            
            for(String ct : commissionTypes)
        {
            commissionPercent.put('Opener_' + ct + '_Percentage__c', 1);
            commissionPercent.put('Closer_' + ct + '_Percentage__c', 0.5);
            for(Integer i=1; i<=16; i++)
            {
                commissionPercent.put('Level_' + i + '_' + ct + '_Percentage__c', 0.1);
            }
        }
        
        insert commissionPercent;
        
        // -------- CREATING THE USER --------
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        Integer randomNumber = Integer.valueof((Math.random() * 100));
        
        User userTest = new User();
        userTest.FirstName = 'Test';
        userTest.LastName =  'User'+ randomNumber;
        userTest.Username = 'test.user'+ randomNumber +'@myorg.com';
        userTest.Alias = 'tuser';
        userTest.Email = 'test.user' + randomNumber +'@myorg.com';
        userTest.EmailEncodingKey = 'UTF-8';
        userTest.LocaleSidKey = 'en_US';
        userTest.TimeZoneSidKey ='America/Los_Angeles';
        userTest.LanguageLocaleKey = 'en_US';
        userTest.ProfileId = p.Id;
        userTest.IsActive = True;
        insert userTest;
        
        // -------- CREATING THE CUSTOM SETTING --------
        
        ComissionOwner__c commOwnCusSetting = new ComissionOwner__c();
        commOwnCusSetting.User_Id__c = userTest.Id;
        commOwnCusSetting.SetupOwnerId = UserInfo.getOrganizationId();
        insert commOwnCusSetting;
        
        // -------- CREATING THE OPPORTUNITY --------
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = DateTime.now().format('MMMM') + ' ' + DateTime.now().year();
        monYea.Month__c = System.now().month();
        monYea.Year__c = System.now().Year();
        insert monYea;
        
        //create product 
        /*  Pricebook2 standardPricebook = new Pricebook2(
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
        pro.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        pro.SBQQ__SubscriptionTerm__c = 12;
        pro.SBQQ__SubscriptionType__c = 'Renewable';
        INSERT pro;
        
        Id fixedOppty_RTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Fixed').getRecordTypeId();
        theOppty.RecordTypeId = fixedOppty_RTId;
        theOppty.Type = 'New Business';
        theOppty.Name ='Test opp';
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
        theOppty.Product_of_Choice__c = 'Fixed';
        theOppty.Supplier__c = supplier.Id;
        theOppty.Opener__c = opener1.Id;
        theOppty.Opener_2__c = opener2.Id;
        theOppty.Closer__c = closer1.Id;
        theOppty.Closer_2__c = closer2.Id;
        
        Date aMonthFromNow = Date.today().addMonths(1);
        Date theFlowDate = Date.newInstance(aMonthFromNow.year(), aMonthFromNow.month(), 1);
        theOppty.Flow_Date__c = theFlowDate;
        
        insert theOppty;
        
        theOppty2.RecordTypeId = fixedOppty_RTId;
        theOppty2.Type = 'New Business';
        theOppty2.Name ='Test opp';
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
        theOppty2.Product_of_Choice__c = 'Fixed';
        theOppty2.Supplier__c = supplier.Id;
        theOppty2.Opener__c = opener1.Id;
        theOppty2.Opener_2__c = opener2.Id;
        theOppty2.Closer__c = closer1.Id;
        theOppty2.Closer_2__c = closer2.Id;
        
        Date aMonthFromNow2 = Date.today().addMonths(1);
        Date theFlowDate2 = Date.newInstance(aMonthFromNow.year(), aMonthFromNow.month(), 1);
        theOppty2.Flow_Date__c = theFlowDate2;
        
        insert theOppty2;
        
        theOppty3.RecordTypeId = fixedOppty_RTId;
        theOppty3.Type = 'New Business';
        theOppty3.Name ='Test opp';
        theOppty3.AccountId = acc.Id;
        theOppty3.CloseDate = Date.today().addDays(5);
        theOppty3.Market__c = marketTest.Id;
        theOppty3.Month_Year__c = monYea.Id;
        theOppty3.StageName = 'Closed Won';
        theOppty3.Commodity_Type__c = 'Gas';
        theOppty3.Pricebook2Id = Test.getStandardPricebookId();
        theOppty3.Subscription_Term__c = 36;
        theOppty3.Margin__c = 4;
        theOppty3.Selling_Price__c = 50;
        theOppty3.Supplier_Price__c = 50;
        theOppty3.Product_of_Choice__c = 'Fixed';
        theOppty3.Supplier__c = supplier.Id;
        theOppty3.Opener__c = opener1.Id;
        theOppty3.Opener_2__c = opener2.Id;
        theOppty3.Closer__c = closer1.Id;
        theOppty3.Closer_2__c = closer2.Id;
        
        Date aMonthFromNow3 = Date.today().addMonths(1);
        Date theFlowDate3 = Date.newInstance(aMonthFromNow.year(), aMonthFromNow.month(), 1);
        theOppty3.Flow_Date__c = theFlowDate3;
        
        insert theOppty3;
        
        theOppty4.RecordTypeId = fixedOppty_RTId;
        theOppty4.Type = 'New Business';
        theOppty4.Name ='Test opp';
        theOppty4.AccountId = acc.Id;
        theOppty4.CloseDate = Date.today().addDays(5);
        theOppty4.Market__c = marketTest.Id;
        theOppty4.Month_Year__c = monYea.Id;
        theOppty4.StageName = 'Closed Won';
        theOppty4.Commodity_Type__c = 'Gas';
        theOppty4.Pricebook2Id = Test.getStandardPricebookId();
        theOppty4.Subscription_Term__c = 36;
        theOppty4.Margin__c = 4;
        theOppty4.Selling_Price__c = 50;
        theOppty4.Supplier_Price__c = 50;
        theOppty4.Product_of_Choice__c = 'Fixed';
        theOppty4.Supplier__c = supplier.Id;
        theOppty4.Opener__c = opener1.Id;
        theOppty4.Opener_2__c = opener2.Id;
        theOppty4.Closer__c = closer1.Id;
        theOppty4.Closer_2__c = closer2.Id;
        
        Date aMonthFromNow4 = Date.today().addMonths(1);
        Date theFlowDate4 = Date.newInstance(aMonthFromNow.year(), aMonthFromNow.month(), 1);
        theOppty4.Flow_Date__c = theFlowDate4;
        
        insert theOppty4;
        
        System.debug('Opportunity::'+theOppty);
        Opportunity_Site__c oppSite = new Opportunity_Site__c();
        oppSite.Opportunity__c = theOppty.Id;
        oppSite.Site__c = accSite.Id;
        oppSite.Market__c = marketTest.Id;
        insert oppSite;
        
        
        
    }
    // ===========================================
    
    @isTest 
    static void test_method_one() 
    {
        createData();
        opp =[select id, SBQQ__PrimaryQuote__c, account.name, CloseDate, Flow_Date__c, Subscription_Term__c, Commodity_Type__c, Margin__c, Market__c, Selling_Price__c, Product_of_Choice__c, Supplier__c, Supplier_Price__c from opportunity where id =:theOppty.id];
        quoteLine = [select id,site__c,SBQQ__Quantity__c,SBQQ__Product__c,SBQQ__Number__c,SBQQ__ListPrice__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:opp.SBQQ__PrimaryQuote__c limit 1];
        Test.startTest();
        amendQuote = new SBQQ__QuoteLine__c();
        amendQuote.SBQQ__Quote__c = opp.SBQQ__PrimaryQuote__c;
        amendQuote.site__c = quoteLine.site__c;
        amendQuote.SBQQ__Quantity__c = 10;
        amendQuote.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
        amendQuote.SBQQ__Number__c = 2;
        amendQuote.SBQQ__DefaultSubscriptionTerm__c = 12;
        amendQuote.SBQQ__ListPrice__c = 12;
        INSERT amendQuote;
        
        // -------- CREATING THE CONTRACT --------
        theContract.SBQQ__Opportunity__c = theOppty.Id;
        theContract.SBQQ__Quote__c = opp.SBQQ__PrimaryQuote__c;
        theContract.StartDate = Date.today();
        theContract.Payment_Terms__c = '100% Residual - Monthly';
        theContract.ContractTerm = 36;
        theContract.AccountId = acc.Id;
        theContract.DNE_Admin_Fee__c = 50;
        theContract.Supplier_s_contract_ID__c = 'sadasldjweqdjsddsfsdfsd';
        theContract.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        theContract.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        
        theContract2.SBQQ__Opportunity__c = theOppty2.Id;
        theContract2.SBQQ__Quote__c = opp.SBQQ__PrimaryQuote__c;
        theContract2.StartDate = Date.today();
        theContract2.Payment_Terms__c = '50% Upfront, 50% at year 1';
        theContract2.ContractTerm = 36;
        theContract2.AccountId = acc.Id;
        theContract2.DNE_Admin_Fee__c = 50;
        theContract2.Supplier_s_contract_ID__c = 'sadasldjweqdjsddasa';
        theContract2.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        theContract2.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        
        theContract3.SBQQ__Opportunity__c = theOppty3.Id;
        theContract3.SBQQ__Quote__c = opp.SBQQ__PrimaryQuote__c;
        theContract3.StartDate = Date.today();
        theContract3.Payment_Terms__c = '100% Residual - Monthly';
        theContract3.ContractTerm = 36;
        theContract3.AccountId = acc.Id;
        theContract3.DNE_Admin_Fee__c = 50;
        theContract3.Supplier_s_contract_ID__c = 'sadasldjweqdjaddasd';
        theContract3.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        theContract3.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        
        theContract4.SBQQ__Opportunity__c = theOppty4.Id;
        theContract4.SBQQ__Quote__c = opp.SBQQ__PrimaryQuote__c;
        theContract4.StartDate = Date.today();
        theContract4.Payment_Terms__c = '100% Residual - Monthly';
        theContract4.ContractTerm = 36;
        theContract4.AccountId = acc.Id;
        theContract4.DNE_Admin_Fee__c = 50;
        theContract4.Supplier_s_contract_ID__c = 'sadsaasdcsacas';
        theContract4.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        theContract4.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        
        
        insert theContract;
        insert theContract2;
        insert theContract3;
        insert theContract4;
        
        System.debug('JTM - theContract = ' + theContract);
        theSubscription.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
        theSubscription.SBQQ__QuoteLine__c  = quoteLine.id;
        theSubscription.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
        theSubscription.SBQQ__ListPrice__c  = quoteLine.SBQQ__ListPrice__c;
        theSubscription.SBQQ__Account__c = acc.Id;
        theSubscription.SBQQ__Contract__c = theContract.Id;
        //theSubscription.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        //theSubscription.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        theSubscription.SBQQ__Number__c =quoteLine.SBQQ__Number__c;
        theSubscription.Site__c = quoteLine.site__c;
        insert theSubscription;
        
        theSubscription2.SBQQ__SubscriptionStartDate__c = Date.today();
        theSubscription2.SBQQ__SubscriptionEndDate__c = Date.today().addYears(2);
        theSubscription2.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
        theSubscription2.SBQQ__QuoteLine__c  = quoteLine.id;        
        theSubscription2.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
        theSubscription2.SBQQ__ListPrice__c  = quoteLine.SBQQ__ListPrice__c;
        theSubscription2.SBQQ__Account__c = acc.Id;
        theSubscription2.SBQQ__Contract__c = theContract2.Id;
        //theSubscription.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        //theSubscription.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        theSubscription2.SBQQ__Number__c =quoteLine.SBQQ__Number__c;
        theSubscription2.Site__c = quoteLine.site__c;
        
        insert theSubscription2;
        
        theSubscription3.SBQQ__SubscriptionStartDate__c = Date.today();
        theSubscription3.SBQQ__SubscriptionEndDate__c = Date.today().addYears(2);
        theSubscription3.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
        theSubscription3.SBQQ__QuoteLine__c  = quoteLine.id;        
        theSubscription3.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
        theSubscription3.SBQQ__ListPrice__c  = quoteLine.SBQQ__ListPrice__c;
        theSubscription3.SBQQ__Account__c = acc.Id;
        theSubscription3.SBQQ__Contract__c = theContract3.Id;
        //theSubscription.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        //theSubscription.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        theSubscription3.SBQQ__Number__c =quoteLine.SBQQ__Number__c;
        theSubscription3.Site__c = quoteLine.site__c;
        
        insert theSubscription3;
        
        theSubscription4.SBQQ__SubscriptionStartDate__c = Date.today();
        theSubscription4.SBQQ__SubscriptionEndDate__c = Date.today().addYears(2);
        theSubscription4.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
        theSubscription4.SBQQ__QuoteLine__c  = quoteLine.id;        
        theSubscription4.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
        theSubscription4.SBQQ__ListPrice__c  = quoteLine.SBQQ__ListPrice__c;
        theSubscription4.SBQQ__Account__c = acc.Id;
        theSubscription4.SBQQ__Contract__c = theContract4.Id;
        //theSubscription.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        //theSubscription.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        theSubscription4.SBQQ__Number__c =quoteLine.SBQQ__Number__c;
        theSubscription4.Site__c = quoteLine.site__c;
        
        insert theSubscription4;
        
        Opportunity oppRen = new Opportunity();
        oppRen.Name = opp.account.name +'-'+String.valueOf(opp.Flow_Date__c.addMonths(Integer.valueof(opp.Subscription_Term__c)).addDays(-1)) +'- Renewal';              
        oppRen.Commodity_Type__c = opp.Commodity_Type__c;
        oppRen.Margin__c = opp.Margin__c;
        oppRen.Market__c = opp.Market__c;
        oppRen.Case__c = caseRec.Id;
        oppRen.Type = 'Renewal';
        oppRen.Selling_Price__c = opp.Selling_Price__c;
        oppRen.Product_of_Choice__c = opp.Product_of_Choice__c;
        oppRen.Subscription_Term__c = opp.Subscription_Term__c;
        oppRen.Supplier__c = opp.Supplier__c;
        oppRen.Supplier_Price__c = opp.Supplier_Price__c;
        oppRen.StageName = 'Qualification';
        oppRen.CloseDate = theContract.StartDate.addMonths((Integer)opp.Subscription_Term__c) - 1;
        insert oppRen;
        
        System.debug('theContract::'+theContract);
        theContract.SBQQ__RenewalOpportunity__c = oppRen.Id;
        theContract.Status = 'Activated';
        theContract2.Status = 'Activated';
        theContract3.Status = 'Activated';
        theContract4.Status = 'Activated';
        List<Contract> conList = new List<Contract>();
        conList.add(theContract);
        conList.add(theContract2);
        conList.add(theContract3);
        conList.add(theContract4);
        
        List<DNE_Commission__c> commissionList = [SELECT Id, Paid__c, Amount__c 
                                                  FROM DNE_Commission__c 
                                                  WHERE Subscription__c = :theSubscription.Id];
        //System.assert(!commissionList.isEmpty());
        // testing recalculateCommissions()
        update conList;
        Integer nbOfCommissionsToPay = 10;
        List<DNE_Commission__c> commissionsToPayList = new List<DNE_Commission__c>();
        
        /*for(Integer i=0; i<nbOfCommissionsToPay; i++)
{
DNE_Commission__c commissionToPay = commissionList.get(i);
commissionToPay.Paid__c = true;
commissionsToPayList.add(commissionToPay);
}
update commissionsToPayList;
*/
        conList[0].Status = 'Revenue Received';        	
        conList[1].Status = 'Revenue Received';
        conList[2].Status = 'Revenue Received';
       	conList[3].Status = 'Revenue Received';
        UPDATE conList;
        
        theSubscription.SBQQ__Quantity__c += 1;
        theSubscription.DNE_Admin_Fee__c = 3;
        update theSubscription;
        theSubscription2.SBQQ__Quantity__c += 1;
        theSubscription2.DNE_Admin_Fee__c = 3;
        update theSubscription2;
        
        List<DNE_Commission__c> clawbackCommissionList = [SELECT Id, Amount__c
                                                          FROM DNE_Commission__c 
                                                          WHERE Subscription__c = :theSubscription.Id 
                                                          AND Type__c = 'Clawback'];
        
        //System.assert(!clawbackCommissionList.isEmpty());
        
        
        // testing fixInvoicesOnResolution()
        theSubscription.Adder_Margin__c = 2;
        theSubscription.Dispute_Resolution_Date__c = Date.today().addDays(40);
        update theSubscription;
        
        theSubscription2.Adder_Margin__c = 2;
        theSubscription2.Dispute_Resolution_Date__c = Date.today().addDays(40);
        update theSubscription2;
        
        System.debug('JTM - theContract = ' + theContract);
        SBQQ__Subscription__c amendSubscription = new SBQQ__Subscription__c();
        amendSubscription.SBQQ__Product__c = amendQuote.SBQQ__Product__c;
        amendSubscription.SBQQ__QuoteLine__c  = amendQuote.id;
        amendSubscription.SBQQ__Quantity__c = 20;
        amendSubscription.SBQQ__ListPrice__c  = 100;
        amendSubscription.SBQQ__Account__c = acc.Id;
        amendSubscription.SBQQ__Contract__c = theContract.Id;
        //theSubscription.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        //theSubscription.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        amendSubscription.SBQQ__Number__c =amendQuote.SBQQ__Number__c;
        amendSubscription.Site__c = amendQuote.site__c;
        amendSubscription.SBQQ__SubscriptionStartDate__c = System.today();
        amendSubscription.IsNew__c = true;
        insert amendSubscription;
        
        SBQQ__Subscription__c amendSubscription2 = new SBQQ__Subscription__c();
        amendSubscription2.SBQQ__Product__c = amendQuote.SBQQ__Product__c;
        amendSubscription2.SBQQ__QuoteLine__c  = amendQuote.id;
        amendSubscription2.SBQQ__Quantity__c = 20;
        amendSubscription2.SBQQ__ListPrice__c  = 100;
        amendSubscription2.SBQQ__Account__c = acc.Id;
        amendSubscription2.SBQQ__Contract__c = theContract2.Id;
        //theSubscription.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        //theSubscription.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        amendSubscription2.SBQQ__Number__c =amendQuote.SBQQ__Number__c;
        amendSubscription2.Site__c = amendQuote.site__c;
        amendSubscription2.SBQQ__SubscriptionStartDate__c = System.today();
        amendSubscription2.IsNew__c = true;
        insert amendSubscription2;
        
        SBQQ__Subscription__c amendSubscription3 = new SBQQ__Subscription__c();
        amendSubscription3.SBQQ__Product__c = amendQuote.SBQQ__Product__c;
        amendSubscription3.SBQQ__QuoteLine__c  = amendQuote.id;
        amendSubscription3.SBQQ__Quantity__c = 20;
        amendSubscription3.SBQQ__ListPrice__c  = 100;
        amendSubscription3.SBQQ__Account__c = acc.Id;
        amendSubscription3.SBQQ__Contract__c = theContract3.Id;
        //theSubscription.DNE_Commission_Hierarchy__c = commissionHierarchyList.get(0).Id;
        //theSubscription.DNE_Commission_Hierarchy_2__c = commissionHierarchyList.get(1).Id;
        amendSubscription3.SBQQ__Number__c =amendQuote.SBQQ__Number__c;
        amendSubscription3.Site__c = amendQuote.site__c;
        amendSubscription3.SBQQ__SubscriptionStartDate__c = System.today();
        amendSubscription3.IsNew__c = true;
        insert amendSubscription3;
        
        SBQQ__Subscription__c amendSubscription4 = new SBQQ__Subscription__c();
        amendSubscription4.SBQQ__Product__c = amendQuote.SBQQ__Product__c;
        amendSubscription4.SBQQ__QuoteLine__c  = amendQuote.id;
        amendSubscription4.SBQQ__Quantity__c = 20;
        amendSubscription4.SBQQ__ListPrice__c  = 100;
        amendSubscription4.SBQQ__Account__c = acc.Id;
        amendSubscription4.SBQQ__Contract__c = theContract4.Id;
        amendSubscription4.SBQQ__Number__c =amendQuote.SBQQ__Number__c;
        amendSubscription4.Site__c = amendQuote.site__c;
        amendSubscription4.SBQQ__SubscriptionStartDate__c = System.today();
        amendSubscription4.IsNew__c = true;
        insert amendSubscription4;
        
        theContract.Payment_Terms__c = '100% Residual - Monthly';
        UPDATE theContract;
        
        amendSubscription.Adder_Margin__c = 5;
        amendSubscription2.Adder_Margin__c = 7;
        amendSubscription3.Adder_Margin__c = 7;
        amendSubscription4.Adder_Margin__c = 7;
        UPDATE amendSubscription;
        UPDATE amendSubscription2;
        UPDATE amendSubscription3;
        UPDATE amendSubscription4;
        
        amendSubscription.Dispute_Resolution_Date__c = System.today();
        UPDATE amendSubscription;
        amendSubscription2.Dispute_Resolution_Date__c = System.today();
        UPDATE amendSubscription2;
        amendSubscription3.Dispute_Resolution_Date__c = System.today();
        UPDATE amendSubscription3;
        amendSubscription4.Dispute_Resolution_Date__c = System.today();
        UPDATE amendSubscription4;
    }
    
}