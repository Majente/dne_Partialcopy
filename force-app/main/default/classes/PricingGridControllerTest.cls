/**************************************************

* Class: PricingGridControllerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test class for PricingGridController

****************************************************/
@isTest
public class PricingGridControllerTest {
    
    /*********************************************************
    @Name 			: testData
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for PricingGridController
	********************************************************/
    @isTest
    public static void testData(){
        
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();
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
            Pricebook2Id = pricebookId, Product2Id = pro.Id,
            UnitPrice = 1, IsActive = true);
        insert standardPrice;
        
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
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = 'May 2019';
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
        priceLi.Effective_From__c = datetime.newInstance(2019, 5, 12, 12, 30, 0);
        priceLi.Effective_To__c = datetime.newInstance(2019, 5, 30, 12, 30, 0);
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
        priceLi1.Effective_From__c = datetime.newInstance(2019, 5, 12, 12, 30, 0);
        priceLi1.Effective_To__c = datetime.newInstance(2019, 5, 30, 12, 30, 0);
        priceLi1.Month_Year__c = monYea.id;
        Insert priceLi1;
        
        PriceListValidateDate__c plv = new PriceListValidateDate__c();
        plv.Validate_Date__c = 90;
        Insert plv;
        
       Test.startTest();
        String selectedMarket = marketTest.Id;
        String selectedCommodity = 'Gas';
        String selectedSize = 'Small';
        String selectedSupplier = String.valueOf(supp.Id);
       PriceListUtility.getTodayPriceList(selectedMarket, selectedCommodity, selectedSize, selectedSupplier); 
       PricingGridController.getMarketsOption();
       PricingGridController.getMonthsList();
       PricingGridController.getCommodityOptions();
       PricingGridController.getSizeOptions();
       PricingGridController.getAllOptions();
       PricingGridController.getSupplierList(priceLi.Name, priceLi.Market__c, priceLi.Size__c,priceLi.Type__c); 
       PricingGridController.getTodayPbmMap(priceLi.Market__c, priceLi.Name, priceLi.Size__c, supp.Name, 'Fixed'); 
       Test.stopTest(); 
    }

}