/**************************************************
* Class: ReconciliationControllerTest
* Author: Soljit <VW>
* Date: 2019-09-23
* Description : test class for ReconciliationController
****************************************************/
@isTest
public class ReconciliationControllerTest {
     /**************************************************
* Method Name : testReconciliation
* Parameters  :  
* Description : method used to test ReconciliationController
****************************************************/
    @isTest
    public static void testReconciliation(){
        
       
        Account acc =new Account();
        acc.Name = 'DNE';
        INSERT acc; 

        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();        

        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'India';
        INSERT marketTest;
        
        Id serviceAddress_RTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = serviceAddress_RTId;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = acc.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ;
        
        
        Account supp = new Account();
        supp.Name = 'Direct Energy - Alberta';
        supp.Market__c = marketTest.id;
        supp.Business_Size__c = 'Small';
        supp.RecordTypeId = RecordTypeIdSupplier;
        INSERT supp;
        
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

        
        Contact con = new Contact();
        con.FirstName = 'Soljit';
        con.LastName = 'Test';
        con.AccountId = acc.id;
        INSERT con;
        
        Opportunity opp1 = new Opportunity();
        opp1.name ='Test opp';
        opp1.AccountId = acc.id;
        opp1.Opener__c = con.id;
        opp1.Closer__c = con.id;
        opp1.CloseDate = Date.today().addDays(5);
        opp1.StageName = 'Qualification';
        opp1.Commodity_Type__c = 'Gas';
        opp1.Flow_Date__c = System.today();
        opp1.Subscription_Term__c = 12;
        opp1.Margin__c = 2;
        opp1.Supplier_Price__c = 5;
        opp1.Supplier__c = supp.Id;
        opp1.Monthly_Site_Admin_Fee__c = 0;
        opp1.Daily_Site_Admin_Fee__c = 0;
        INSERT opp1;
        
        Integer i;
        integer j =10;
        List<Site__c> siteList = new List<Site__c>();
        for( i=0; i<10 ; i++){
            Site__c Sites = new Site__c();
            Sites.Name = 'Test-Site-TS'+ i;
            Sites.Type__c = 'Electricity';
            Sites.Account__c = accServ.id;
            Sites.Market__c = marketTest.id;
            Sites.Unit_of_Measure__c = 'KWH';
            Sites.Volume__c = 1200 + j;
            siteList.add(Sites);
            J += 10;
        }
        INSERT siteList;
        System.debug('Site List:::::'+siteList.size());
        
        //Create Opp site
        Opportunity_Site__c oppSite = new Opportunity_Site__c();
        oppSite.Opportunity__c = opp1.Id;
        oppSite.Site__c = siteList[0].Id;
        oppSite.Market__c = marketTest.Id;
        insert oppSite;
        
        //Make the Opportunity Closed Won
        opp1.StageName = 'Closed Won';
        UPDATE opp1;
        
        
        SBQQ__Quote__c quote = [Select Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =: opp1.Id LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = [Select Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quote.Id];
        
        //Create Contract
        Contract contractRec = new Contract();
        contractRec.AccountId = acc.Id;
        contractRec.ContractTerm = 60;          
        contractRec.StartDate = System.today();          
        contractRec.Payment_Terms__c = '50% Upfront on flow and 50% Residual - Monthly';         
        contractRec.SBQQ__Opportunity__c = opp1.Id; 
        contractRec.Status = 'Draft';          
        contractRec.supplier_s_contract_ID__c = 'BEUNIQUE'; 
        contractRec.OwnerId = UserInfo.getUserId();
		INSERT contractRec;
        
        //Insert Subscriptions
        List<SBQQ__Subscription__c> subsList = new  List<SBQQ__Subscription__c>();
        For(Site__c st: siteList){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Account__c = acc.Id;
        sub.SBQQ__QuoteLine__c = quoteLine.Id;
        sub.SBQQ__Contract__c = contractRec.Id;
        sub.SBQQ__Quantity__c = 20000;
        sub.SBQQ__ListPrice__c = 2.0;
        sub.Supplier__c = supp.Id;
        sub.Site__c = st.Id;
        subsList.add(sub);
        }
        INSERT subsList;  
        System.debug('Subscription List:::::'+subsList.size());
        //Activate the Contract
        contractRec.Status = 'Activated';          
        UPDATE contractRec;
        
        //Make the Status Revenue Received        
        contractRec.Status = 'Revenue Received'; 
        UPDATE contractRec;
      
        List<Invoice__c> invoiceList = [Select Id,Dispute_Status__c,Supplier__c,CaseIssue__c,Subscription__c,Start_Date__c,Flag__c FROM invoice__c where Subscription__c IN : subsList];
        System.debug('Invoice List:::::::'+invoiceList.size());
        for(Invoice__c invoice : invoiceList){
            invoice.Start_Date__c = System.today();
            invoice.Flag__c = 'Payment Not Received';
            invoice.Dispute_Status__c = 'Ok';
            invoice.CaseIssue__c = null;
            invoice.Supplier__c = supp.Id;
        }
        UPDATE invoiceList;
        
        Test.startTest();
        
        ReconciliationController reco = new ReconciliationController();
        reco.selectStatus = 'Payment Not Received';
        reco.disputeStatus = 'Ok';
        reco.inv.Supplier__c = supp.Id;
        reco.getSearchData();
        string ContractId = contractRec.id;
        set<string> ids = new set<string>{ContractId};
        reco.StoredId = ids;
        List<SelectOption> monthOptions = reco.getMonthOptions();
        System.assert(monthOptions.size() > 0);
        
        List<SelectOption> yearOptions = reco.getYearsOptions();
        System.assert(yearOptions.size() > 0);
        
        List<SelectOption> disputeOptions = reco.getDisputeOption();
        System.assert(disputeOptions.size() > 0);
        
        List<SelectOption> statusOptions = reco.getStatusOption();
        System.assert(statusOptions.size() > 0);
        
        reco.getHasInvoices();
        reco.CheckRadioValue();
        reco.subscriptionData();
        reco.DownloadSelected();
        reco.changeDifferencePercent();
        List<SelectOption> filterOptions = reco.getCaseFilterOption();
        System.assert(filterOptions.size() > 0);
        
        System.assertEquals(null,reco.createCasesForSelected());
        
        for(List<ReconciliationController.revenueWrapper> revList : reco.revenueList){
            for(ReconciliationController.revenueWrapper rev : revList){
              rev.isSelected = true;  
            }
        }
        System.assertEquals(null,reco.createCasesForSelected());
        System.assertEquals(null,reco.createCasesForAll());
        
        System.assertEquals(false, reco.showPopupForSelected);
        reco.showPopupForSelectedCase();
        System.assertEquals(true, reco.showPopupForSelected);
        
        System.assertEquals(false, reco.showPopupForAll);
        reco.showPopupForAllCase();
        System.assertEquals(true, reco.showPopupForAll);
        
        reco.hidePopup();
        System.assertEquals(false, reco.showPopupForSelected);
        System.assertEquals(false, reco.showPopupForAll);
        
        Test.stopTest();
        
    }

}