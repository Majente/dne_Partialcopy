/**************************************************

* Class: MonthlyInvoiceCompareControllerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: MonthlyInvoiceCompareControllerTest for MonthlyInvoiceCompareController

****************************************************/
@isTest
public class MonthlyInvoiceCompareControllerTest {
    public static String csvFileBody;
    
    //CSV Contains True Data
    static String str  = '[{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 1","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 2","adder":"2","amount":"200","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 3","adder":"2","amount":"400","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 4","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"5000","status":" "},{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 5","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"3000","status":" "},{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 6","adder": "1","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 7","adder":"3","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":" ","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/6/2020","calculationType":"Residual","commodity":"Electricity","contractId":" ","contractUsage":"20000","site":"Test Site Ontario 1","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2020","calculationType":"Residual","commodity":"Electricity","contractId":" ","contractUsage":"20000","site":" ","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "}]';
   //CSV Contains New Invoices
    static String str1  = '[{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 1","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 2","adder":"2","amount":"200","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 3","adder":"2","amount":"400","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 4","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"5000","status":" "},{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 5","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"3000","status":" "},{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 6","adder": "1","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 7","adder":"3","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":" ","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/6/2019","calculationType":"Residual","commodity":"Electricity","contractId":" ","contractUsage":"20000","site":"Test Site Ontario 1","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "},{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":" ","contractUsage":"20000","site":" ","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "}]';
  
    //CSV contains Data of Cancelled and Upfront
    static String str2 = '[{"paymentDate":"30/5/2019","calculationType":"Residual","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 2","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":"CANCELLED"},{"paymentDate":"30/5/2019","calculationType":"Upfront","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 3","adder":"2","amount":"20000","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "}]';
    //static String str3 = '[{"paymentDate":"30/5/2019","calculationType":"Test","commodity":"Electricity","contractId":"BEUNIQUE","contractUsage":"20000","site":"Test Site Ontario 1","adder":"2","amount":"333.33","supplier":"Direct Energy - Ontario","actualUsage":"4000","status":" "}]';
    /*********************************************************
    @Name 			: testCSVData
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for MonthlyInvoiceCompareController to update the invoice, Subscription 
					  and create new invoice Entries for Missing Site and Contracts
	********************************************************/
    @isTest
    public static void testCSVData(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Fixed').getRecordTypeId();
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Ontario';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'CANADA';
        INSERT marketTest;

        //New Account
        Account acc =new Account();
        acc.Name = 'DNE';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Market__c = marketTest.id;
        INSERT acc; 
        
        //Create Opener
 		Contact opener = new Contact();
        Opener.AccountId = acc.Id;
        Opener.LastName = 'Opener Contact';
        INSERT opener;
        
        //Create Closer
        Contact closer = new Contact();
        closer.AccountId = acc.Id;
        closer.LastName = 'closer Contact';
        INSERT closer;
            
        //New Supplier
        Account supp = new Account();
        supp.Name = 'Direct Energy - Ontario';
        supp.Market__c = marketTest.id;
        supp.Business_Size__c = 'Small';
        supp.RecordTypeId = RecordTypeIdSupplier;
        INSERT supp; 
        
        //New Service Account
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
        
        //Multiple sites under Service Account
        Integer i;
        integer j =10;
        List<Site__c> siteList = new List<Site__c>();
        for(i=1; i<=40 ; i++){
            Site__c Sites = new Site__c();
            Sites.Name = 'Test Site Ontario '+i;
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
        
        Product2 productTest = new Product2();
        productTest.Name = 'Gas - Small fixed';
        productTest.Family = 'Gas';
        productTest.ProductCode = 'Gas-Small Fixed';
        productTest.Is_Fixed__c = true;
        productTest.Size__c = 'Small';
        productTest.Price_Type__c = 'Fixed';
        productTest.IsActive = true;
        INSERT productTest;
        
		//Create Opportunity
        Opportunity opp = new Opportunity();
        opp.name ='Test opp';
        opp.RecordTypeId = oppRecordTypeId;
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today().addDays(20);
        opp.Market__c = marketTest.id;
        opp.Month_Year__c = monYea.id;
        opp.StageName = 'Qualification';
        opp.Commodity_Type__c = 'Gas';
        opp.Supplier__c = supp.Id;
        opp.Opener__c = opener.Id;
        opp.Closer__c = closer.Id;
        opp.Flow_Date__c = system.today().addDays(2);
        opp.Margin__c = 2;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.Supplier_Price__c = 1.5;
        opp.Selling_Price__c = 3.5;
        opp.Subscription_Term__c = 60;
        opp.Type = 'Renewal';
        INSERT opp;
        
        //Create Opp site
        Opportunity_Site__c oppSite = new Opportunity_Site__c();
        oppSite.Opportunity__c = opp.Id;
        oppSite.Site__c = siteList[0].Id;
        oppSite.Market__c = marketTest.Id;
        insert oppSite;
        
        //Make the Opportunity Closed Won
        opp.StageName = 'Closed Won';
        UPDATE opp;
        
        
        SBQQ__Quote__c quote = [Select Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =: opp.Id LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = [Select Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quote.Id];
        
        /* SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
         quoteLine.SBQQ__Quote__c = quote.Id;
         quoteLine.site__c = siteList[0].Id;
         quoteLine.SBQQ__Quantity__c = 10;
         quoteLine.SBQQ__Product__c = productTest.Id;
         quoteLine.SBQQ__Number__c = 2;
         quoteLine.SBQQ__ListPrice__c = 12;
         INSERT quoteLine;*/
        
        //Create Commission Percent Record
        DNE_Commission_Percent__c commissionPercent = new DNE_Commission_Percent__c();
        commissionPercent.Type__c = 'Renewal';
		commissionPercent.Contract_Type__c = 'Fixed within 12 months';
		commissionPercent.Effective_From__c = Datetime.now().addDays(-1);
		commissionPercent.Max_Payout_Upfront__c = 50000;

		List<String> commissionTypes = new List<String>{'Commission', 'Upfront', 'Flow', 'Residual'};

		for(String ct : commissionTypes)
		{
			commissionPercent.put('Opener_' + ct + '_Percentage__c', 1);
			commissionPercent.put('Closer_' + ct + '_Percentage__c', 0.5);
			for(Integer o=1; o<=16; o++)
			{
				commissionPercent.put('Level_' + o + '_' + ct + '_Percentage__c', 0.1);
			}
		}
		INSERT commissionPercent;
        
        //Custom Setting Record for Commission
        ComissionOwner__c  owner = new ComissionOwner__c();
        Owner.User_Id__c = UserInfo.getUserId();
        Insert owner;
        
        //Create Contract
        Contract con = new Contract();
        con.AccountId = acc.Id;
        con.ContractTerm = 60;          
        con.StartDate = date.newInstance(2020, 05, 01);          
        con.Payment_Terms__c = '50% Upfront on flow and 50% Residual - Monthly';         
        con.SBQQ__Opportunity__c = opp.Id; 
        con.Status = 'Draft';          
        con.supplier_s_contract_ID__c = 'BEUNIQUE'; 
        con.OwnerId = UserInfo.getUserId();
		INSERT con;
        
        //Insert Subscriptions
        List<SBQQ__Subscription__c> subsList = new  List<SBQQ__Subscription__c>();
        For(Site__c st: siteList){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Account__c = acc.Id;
        sub.SBQQ__QuoteLine__c = quoteLine.Id;
        sub.SBQQ__Contract__c = con.Id;
        sub.SBQQ__Quantity__c = 20000;
        sub.SBQQ__ListPrice__c = 2.0;
        sub.Supplier__c = supp.Id;
        sub.Site__c = st.Id;
        subsList.add(sub);
        }
        INSERT subsList;  
        System.debug('Subscription List:::::'+subsList.size());
        //Activate the Contract
        con.Status = 'Activated';          
        UPDATE con;
        
        //Make the Status Revenue Received        
        con.Status = 'Revenue Received'; 
        UPDATE con;
      
        List<Invoice__c> invoiceList = [Select Id,Subscription__c FROM invoice__c where Subscription__c IN : subsList];
        System.debug('Invoice List:::::::'+invoiceList.size());
        
        
        Test.startTest();
        MonthlyInvoiceCompareController invListCon = new MonthlyInvoiceCompareController();
       
        csvFileBody = str;
        System.debug('csvFileBody:::'+csvFileBody);
        invListCon.csvFileBody = csvFileBody; 
        invListCon.uploadInvoice();
        invListCon.saveData();
        
        
        csvFileBody = str1;
        System.debug('csvFileBody:::'+csvFileBody);
        invListCon.csvFileBody = csvFileBody;
        invListCon.uploadInvoice();
        invListCon.saveData();
       
        
        csvFileBody = str2;
        System.debug('csvFileBody:::'+csvFileBody);
        invListCon.csvFileBody = csvFileBody;
        invListCon.uploadInvoice();
        invListCon.saveData();
       
        
        /*csvFileBody = str3;
        System.debug('csvFileBody:::'+csvFileBody);
        invListCon.csvFileBody = csvFileBody;
        invListCon.uploadInvoice();*/
        
        invListCon.errorMsgCsv();
        invListCon.addLastBatchRecord();
        invListCon.getStatusOption();
        invListCon.getInvEntryStatusOption();
        invListCon.resetClearList();
        
        Test.stopTest();
    }
}