/**************************************************

* Class: LeadChartControllerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test class for LeadChartController

****************************************************/
@isTest
public class LeadChartControllerTest {
    
    @isTest
    public static void testLeadChart(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        /*Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;*/
        
        PriceListValidateDate__c priceListCusSetting = new PriceListValidateDate__c();
        priceListCusSetting.Validate_Date__c = 30;
        priceListCusSetting.SetupOwnerId = UserInfo.getOrganizationId();
        insert priceListCusSetting;

        Product2 pro = new Product2();
        pro.Name = 'Gas - Small fixed';
        pro.Family = 'Gas';
        pro.ProductCode = 'Gas-Small Fixed';
        pro.Is_Fixed__c = true;
        pro.Size__c = 'Small';
        pro.Price_Type__c = 'Fixed';
        pro.IsActive = true;
        INSERT pro;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id,
            UnitPrice = 1, IsActive = true);
        insert standardPrice;
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'CANADA';
        INSERT marketTest;
        
        Account acc =new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Market__c = marketTest.id;
        INSERT acc;
        
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
        
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        
        Site__c accSite1 = new Site__c();
        accSite1.Name = 'AccountSite13';
        accSite1.Type__c = 'Gas';
        accSite1.Account__c = accServ1.id;
        accSite1.Market__c = marketTest.id;
        accSite1.Unit_of_Measure__c = 'GJ';
        accSite1.Volume__c = 1000;
        INSERT accSite1;
        
        Lead le = new Lead();
        le.Status = 'Active';
        le.LastName = 'JTM';
        le.Company = 'Scorillo';
        le.Business_Size__c = 'Small';
        le.Commodity__c = 'Gas';
        le.Market__c = marketTest.id;
        INSERT le;
        
        Task theTask = new Task();
        theTask.Status = 'Completed';
        theTask.Priority = 'Normal';
        theTask.ActivityDate = Date.today();
        theTask.Subject = 'Phone Conversation with ';
        theTask.WhoId = le.id;
        theTask.Subject += le.Name;
        INSERT theTask;
        
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
        
        Offer__c theOffer = new Offer__c();
        theOffer.Commodity__c ='Gas';
        theOffer.Contract_Duration_months__c = 12;
        theOffer.Market__c = marketTest.id;
        theOffer.Price__c = 12;
        theOffer.Starting_Month__c = string.valueof(Date.today());
        theOffer.Supplier__c = supp.id;
        theOffer.Name = le.name +' '+date.today();
        theOffer.Estimated_Volume__c = 100;
        theOffer.Comments__c = 'testing';
        theOffer.Margin__c = 2;
        theOffer.Selling_Price__c = 23;
        theOffer.Lead__c = le.Id;
        theOffer.Name = le.Name + ' - ' + local;
        theOffer.Customer__c = acc.Id;
        theOffer.Name = acc.Name + ' - ' + local;
        INSERT theOffer;
        
        System.debug('theOffer::'+theOffer);
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = DateTime.now().format('MMMM') + ' ' + DateTime.now().year();
        monYea.Month__c = System.now().month();
        monYea.Year__c = System.now().year();
        INSERT monYea;
        
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
        priceLi.Effective_From__c = Datetime.now();
        priceLi.Effective_To__c = Date.today().addDays(5);
        priceLi.Month_Year__c = monYea.id;
        Insert priceLi;
        
        Price_List__c priceLi1 = new Price_List__c();
        priceLi1.Name = 'Gas';
        priceLi1.Product_Code__c = 'Gas-Small Fixed';
        priceLi1.Type__c = 'Fixed';
        priceLi1.Size__c = 'Small';
        priceLi1.Term__c = '24';
        priceLi1.List_Price__c = 2.55;
        priceLi1.Market__c = marketTest.id;
        priceLi1.Supplier__c = supp.id;
        priceLi1.Latest__c = true;
        priceLi1.Effective_From__c = Datetime.now();
        priceLi1.Effective_To__c = Date.today().addDays(5);
        priceLi1.Month_Year__c = monYea.id;
        Insert priceLi1;
        
        Test.startTest();
        pageReference pager = page.PricingChart;
        Test.setCurrentPage(pager);
        ApexPages.StandardController stdController = new ApexPages.StandardController(le);
        LeadChartController leadChartCon = new LeadChartController(stdController);
        pager.getParameters().put('selectedNbOfYears','12');
        Boolean sellingPrice = leadChartCon.sellingPriceEditable;
        Boolean noSuppliers = leadChartCon.noSuppliersFound;
        leadChartCon.selectedMonthYear = DateTime.now().format('MMMM') + ' ' + DateTime.now().year();
        leadChartCon.selectedMarket = marketTest.Id;
        leadChartCon.selectedCommodity = 'Gas';
        leadChartCon.selectedSize = 'Small';
        leadChartCon.selectedPriceType = 'Fixed';
        leadChartCon.selectedSupplier = String.valueOf(supp.Id);
        leadChartCon.siteAccountIds = accSite.Id+','+accSite1.Id;
        leadChartCon.selectedPrice = '2.11';
        leadChartCon.selectedNbOfYears = '12';
        leadChartCon.selectedSupplierFromChart = supp.Name;
        leadChartCon.marginChosen = 2;
        
        leadChartCon.backToRecord();
        leadChartCon.getMonthOptions();
        leadChartCon.changePriceType();
        leadChartCon.getGraphData();
        leadChartCon.fetchProduct();
        leadChartCon.getSupplierList();
        leadChartCon.setPricingValues();
        leadChartCon.recalculateMargin();
        leadChartCon.createOffer();
        
        leadChartCon.selectedMonthYear = null;
        leadChartCon.marginChosen = 0;
        leadChartCon.getGraphData();
        leadChartCon.setCurrentPbm();
        leadChartCon.recalculateMargin();
        leadChartCon.calculateSellingPrice();
        leadChartCon.resetSearch();                

        Test.stopTest();
        
    }

}