/**************************************************

* Class: AccountChartControllerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test class for AccountChartControllerTest

****************************************************/
@isTest
public class AccountChartControllerTest {
   
    /*********************************************************
    @Name 			: testSample
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: This method is used to cover code of the 
                       AccountChartController.
	********************************************************/
    @isTest
    public static void testSample(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
    /*   Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );*/
        Id pbId = Test.getStandardPricebookId();
        system.debug('pbId:::'+pbId);
        List<Pricebook2> pbList = new List<Pricebook2>();
        for(Pricebook2 pb : [Select Id from Pricebook2 where id =: pbId]){
            pb.IsActive = true;
            pbList.add(pb);
        }
        if(pbList.size() > 0){
             update pbList;
        } 
       
        
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
        
        Contact con = new Contact();
        con.FirstName = 'DNE';
        con.LastName = 'Contact';
        con.AccountId = acc.id;
        INSERT con;
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = DateTime.now().format('MMMM') + ' ' + DateTime.now().year();
        monYea.Month__c = System.now().month();
        monYea.Year__c = System.now().Year();
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
        
        Opportunity opp1 = new Opportunity();
        opp1.name ='Test opp';
        opp1.AccountId = acc.id;
        opp1.CloseDate = Date.today().addDays(5);
        opp1.Market__c = marketTest.id;
        opp1.Month_Year__c = monYea.id;
        opp1.StageName = 'Qualification';
        opp1.Commodity_Type__c = 'Gas';
        INSERT opp1;
        
        Opportunity_Site__c oppSite = new Opportunity_Site__c();
        oppSite.Opportunity__c = opp1.id;
        oppSite.Site__c = accSite.id;
        oppSite.Market__c = marketTest.id;
        Insert oppSite;
        
        PriceListValidateDate__c pricelist = New PriceListValidateDate__c();
        pricelist.Name = 'test';
        pricelist.Validate_Date__c = 165;
        insert pricelist;
          
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        AccountChartController accountControll = new AccountChartController(stdController);
        accountControll.selectedNbOfYears = '12';
        accountControll.selectedMonthYear = DateTime.now().format('MMMM') + ' ' + DateTime.now().year();
        accountControll.selectedMarket = marketTest.Id;
        accountControll.selectedCommodity = 'Gas';
        accountControll.selectedSize = 'Small';
        accountControll.selectedPriceType = 'Fixed';
        Boolean sellingPrice = accountControll.sellingPriceEditable;
        Boolean noSupplier = accountControll.noSuppliersFound;
        Boolean hasAcc = accountControll.hasAccount;
        accountControll.selectedSupplier = String.valueOf(supp.Id);
        accountControll.siteAccountIds = accSite.Id+','+accSite1.Id;
        accountControll.selectedPrice = '2.55';
        accountControll.marginChosen = 2;        
        accountControll.selectedSupplierFromChart = supp.Name;
        PriceListUtility.getTodayPriceList(accountControll.selectedMarket, accountControll.selectedCommodity, accountControll.selectedSize, accountControll.selectedSupplier);
        PriceListUtility.getTodayPriceListNewUpdated(accountControll.selectedMarket, accountControll.selectedCommodity, accountControll.selectedSize, accountControll.selectedSupplier, accountControll.selectedPriceType);
        accountControll.reloadPage();
        accountControll.backToRecord();
        accountControll.backToAccount();
        accountControll.getTreeData();
        accountControll.getMonthOptions();        
        accountControll.getGraphData();   
        accountControll.getSupplierList();        
        accountControll.setPricingValues();
        accountControll.recalculateMargin();
       // accountControll.getStandardPB();
        //accountControll.resetSearch();        
        accountControll.createOppLineData();
        accountControll.marginChosen = 0;
        accountControll.selectedMonthYear = null;
        accountControll.getGraphData();
        accountControll.setCurrentPbm();
        accountControll.recalculateMargin();
        accountControll.calculateSellingPrice();
        accountControll.addNewOpp();
        AccountChartController.TreeWrapper tw = new AccountChartController.TreeWrapper(acc.Id);
        Test.stopTest();
    } // End of test Method

} // End of Test class