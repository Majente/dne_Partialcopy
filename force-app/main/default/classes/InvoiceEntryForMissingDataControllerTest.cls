/**************************************************

* Class: InvoiceEntryForMissingDataControllerTest
* Author: Soljit <VW>
* Date: 2019-08-22
* Description: InvoiceEntryForMissingDataControllerTest for InvoiceEntryForMissingDataController

****************************************************/
@isTest
public class InvoiceEntryForMissingDataControllerTest {
    
    @isTest
    public static void testSample(){
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'Canada';
        INSERT marketTest;

        Account acc =new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Market__c = marketTest.id;
        INSERT acc; 
 
        Account supp = new Account();
        supp.Name = 'Direct Energy - Alberta';
        supp.Market__c = marketTest.id;
        supp.Business_Size__c = 'Small';
        supp.RecordTypeId = RecordTypeIdSupplier;
        INSERT supp; 
        
        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = acc.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 

        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = DateTime.now().format('MMMM') + ' ' + DateTime.now().year();
        monYea.Month__c = System.now().month();
        monYea.Year__c = System.now().Year();
        INSERT monYea;

        Site__c accSite = new Site__c();
        accSite.Name = 'reddeerE9012*';
        accSite.Type__c = 'Electricity';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'KWH';
        accSite.Volume__c = 1200;
        INSERT accSite;

        Opportunity opp1 = new Opportunity();
        opp1.name ='Test opp';
        opp1.AccountId = acc.id;
        opp1.CloseDate = Date.today().addDays(5);
        opp1.Market__c = marketTest.id;
        opp1.Month_Year__c = monYea.id;
        opp1.StageName = 'Qualification';
        opp1.Commodity_Type__c = 'Gas';
        opp1.Supplier__c = supp.Id;
        opp1.Monthly_Site_Admin_Fee__c = 0;
        opp1.Daily_Site_Admin_Fee__c = 0;
        INSERT opp1;

        Contract con = new Contract();
        con.AccountId = acc.Id;
        con.ContractTerm = 12;          
        con.StartDate = date.newInstance(2019, 07, 01);          
        con.Payment_Terms__c = '50% Upfront on flow and 50% Residual - Monthly';         
        con.SBQQ__Opportunity__c = opp1.Id;          
//        con.Selling_Price__c =  2.07;         
        con.Status = 'Draft';          
        con.supplier_s_contract_ID__c = 'Manoj12345';          
		insert con;
        
        con.Status = 'Activated';          
        update con;
        
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
        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c = opp1.id;
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__StartDate__c = System.today();
        Insert newQuote;
        
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
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Account__c = acc.Id;
        sub.SBQQ__Contract__c = con.Id;
        sub.SBQQ__Quantity__c = 20000;
        sub.SBQQ__ListPrice__c = 2.0;
        sub.Supplier__c = supp.Id;
        sub.SBQQ__QuoteLine__c  = quoteLine.id;
        insert sub;
        
        Invoice__c inv = new Invoice__c();
        inv.Amount__c = 841.67;
        inv.Calculation_Type__c = 'Residual';
        inv.Commodity__c = 'Electricity';
        inv.Contract__c = con.Id;
        inv.Contract_Term__c = 12;
        inv.Contract_Usage_Volume__c = 50000;
        inv.Site__c = accSite.Id;
        inv.Start_Date__c = date.newInstance(2019, 08, 01);
        inv.End_Date__c = date.newInstance(2019, 08, 31);
        inv.Subscription__c = sub.id;
        inv.Supplier__c = supp.Id ;
        inv.Expected_Adder__c = 3;
        inv.Expected_Volume__c = 500;
        Insert inv;
        
        inv.Received_Amount__c = 841.67;
        inv.Received_Adder__c = 3;
        inv.Received_Volume__c = 600;
        Update inv;
        inv.Received_Amount__c = 841.67;
        inv.Received_Adder__c = 3;
        inv.Received_Volume__c = 400;
        Update inv;
        inv.Received_Amount__c = 841.67;
        inv.Received_Adder__c = 4;
        inv.Received_Volume__c = 500;
        Update inv;
        inv.Received_Amount__c = 841.67;
        inv.Received_Adder__c = 2;
        inv.Received_Volume__c = 500;
        Update inv;
        inv.Received_Amount__c = 850;
        inv.Received_Adder__c = 3;
        inv.Received_Volume__c = 500;
        Update inv;
        inv.Received_Amount__c = 841;
        inv.Received_Adder__c = 3;
        inv.Received_Volume__c = 500;
        Update inv;
        
        List<Invoice_Entries__c> invEntList = new List<Invoice_Entries__c>();
        Invoice_Entries__c ie = new Invoice_Entries__c();
        ie.Contract__c ='Manoj12345';
        ie.Amount__c = 200;
        ie.Calculation_Type__c = 'Residual';
        ie.Contract_Usage_Volume__c = 1200;
        ie.Received_Volume__c =1000;
        ie.Received_Adder__c = 2;
        ie.Supplier__c = supp.Id;
        ie.Payment_Date__c = System.today();
        ie.Status__c = 'Correct Contract & Missing Site';
        ie.Invoice__c = inv.Id;
        invEntList.add(ie);
        if(invEntList.size()>0){
            Insert invEntList; 
        }
        
        Test.startTest();
        
        InvoiceEntryForMissingDataController invoiceEntryData = new InvoiceEntryForMissingDataController();
        invoiceEntryData.selectStatus = ie.Status__c;
         invoiceEntryData.selectStatus = 'Correct Contract & Missing Site';
        invoiceEntryData.inv.Supplier__c = supp.Id;
       // invoiceEntryData.getSearchQueryString();
        invoiceEntryData.getSearchData();
        
        List<SelectOption> monthOptionList = invoiceEntryData.getMonthOptions();
        System.assert(monthOptionList.size() > 0);
        
        List<SelectOption> yearOptionList = invoiceEntryData.getYearsOptions();
        System.assert(yearOptionList.size() > 0);
        
        List<SelectOption> statusOptionList = invoiceEntryData.getStatusOption();
        System.assert(statusOptionList.size() > 0);
        
        invoiceEntryData.DownloadSelected();
        invoiceEntryData.getHasInvoices();
        
        List<SelectOption> filterOptions = invoiceEntryData.getCaseFilterOption();
        System.assert(filterOptions.size() > 0);
        
         System.assertEquals(null,invoiceEntryData.createCasesForSelected());
        
          for(List<InvoiceEntryForMissingDataController.revenueWrapper> revList : invoiceEntryData.revenueList){
            for(InvoiceEntryForMissingDataController.revenueWrapper rev : revList){
              rev.isSelected = true;  
            }
        }
        System.assertEquals(null,invoiceEntryData.createCasesForSelected());
        System.assertEquals(null,invoiceEntryData.createCasesForAll());
        
        System.assertEquals(false, invoiceEntryData.showPopupForSelected);
        invoiceEntryData.showPopupForSelectedCase();
        System.assertEquals(true, invoiceEntryData.showPopupForSelected);
        
        System.assertEquals(false, invoiceEntryData.showPopupForAll);
        invoiceEntryData.showPopupForAllCase();
        System.assertEquals(true, invoiceEntryData.showPopupForAll);
        
        invoiceEntryData.hidePopup();
        System.assertEquals(false, invoiceEntryData.showPopupForSelected);
        System.assertEquals(false, invoiceEntryData.showPopupForAll);
        invoiceEntryData.showPopupForOwner();
        System.assertEquals(false, invoiceEntryData.showPopupForSelected);
        System.assertEquals(true, invoiceEntryData.showPopupForCaseOwner);
        invoiceEntryData.getDisputeOption();
        invoiceEntryData.changeDifferencePercent();
        InvoiceEntryForMissingDataController.dummyData();
        Test.stopTest();
    }
}