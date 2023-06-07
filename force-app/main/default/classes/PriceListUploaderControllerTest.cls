/**************************************************

* Class: PriceListUploaderControllerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test class for PriceListUploaderController

****************************************************/
@isTest
public class PriceListUploaderControllerTest {
    public static String csvFileBody;
    static String str = '[{"Name":"Gas","Size":"Small","Type":"fixed","Market":"Alberta","Supplier":"Direct Energy - Alberta","Term":"12","List_Price":"23","Month":"May","Year":"2019"}]';
    public static String[] csvFileLines;

    /*********************************************************
    @Name 			: testSample
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for PriceListUploaderController
	********************************************************/
    @isTest
    public static void testSample(){
         Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        /* Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;*/
        
        List<Product2> proList = new List<Product2>();
        Product2 pro = new Product2();
        pro.Name = 'Gas - Small fixed';
        pro.Family = 'Gas';
        pro.ProductCode = 'Gas-Small Fixed';
        pro.Is_Fixed__c = true;
        pro.Size__c = 'Small';
        pro.Price_Type__c = 'Fixed';
        pro.IsActive = true;
        INSERT pro;
        proList.add(pro);
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = pro.Id,
            UnitPrice = 1, IsActive = true);
        insert standardPrice;
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = 'May 2019';
        monYea.Month__c = 5;
        monYea.Year__c = 2019;
        INSERT monYea;
        
        List<Market__c> marList = new List<Market__c>();
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'Canada';
        INSERT marketTest;
        marList.add(marketTest);
        
        List<Account> suppList = new List<Account>();
        Account supp = new Account();
        supp.Name = 'Direct Energy - Alberta';
        supp.Market__c = marketTest.id;
        supp.Business_Size__c = 'Small';
        supp.RecordTypeId = RecordTypeIdSupplier;
        INSERT supp;
        suppList.add(supp);
        
        List<Price_List__c> priceList = new List<Price_List__c>();
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
        priceLi.Effective_From__c = datetime.newInstance(2019, 05, 03, 09, 37, 0);
        priceLi.Effective_To__c = Date.today();
        priceLi.Month_Year__c = monYea.id;
        Insert priceLi;
        priceList.add(priceLi);
        
        
        Test.startTest();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(priceLi);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(priceList);
        PriceListUploaderController priceListcon = new PriceListUploaderController(stdSetController);
        csvFileBody = str;
        priceListcon.csvFileBody = csvFileBody;
        priceListcon.mockPL.Effective_From__c = datetime.newInstance(2019, 05, 03, 09, 37, 0);
        priceListcon.mockPL.Effective_To__c = Date.today().addDays(3);
                
        priceListcon.readFromFile();
        priceListcon.saveData();
        
        Test.stopTest();
    }
}