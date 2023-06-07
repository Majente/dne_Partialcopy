/**************************************************
* Class: Name of the Class = AddSiteAccountController
* Author: Soljit <Your intials>
* Date: YYYY-MM-DD 15/05/2019
* Description: A short description

****************************************************/

@isTest
public class AddSiteAccountControllerTest {
    @testSetup
    static void createData(){
        Account_Site__c acs = new Account_Site__c();
        acs.No_of_Account_Sites__c =10;
        insert acs;
    }
    
     /*********************************************************
    @Name           : addacccon
    @Parameters     : 
    @Reutrn type    : void
    @Description    : test method for AddSiteAccountController
    ********************************************************/
    @isTest
    public static void addacccon(){
        Id RecordTypeIdServiceAddre = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        Account acc = new Account();
        acc.name = 'Client 1';
        insert acc;
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'Canada';
        INSERT marketTest;
        
        Account accServ =new Account();
        accServ.Name = 'Service Account 1';
        accServ.RecordTypeId = RecordTypeIdServiceAddre;
        accServ.Market__c = marketTest.id;
        accServ.ParentId = acc.id;
        accServ.Business_Size__c = 'Small';
        INSERT accServ; 
        
        Site__c accSite = new Site__c();
        accSite.Name = 'AccountSite12';
        accSite.Type__c = 'Gas';
        accSite.Account__c = accServ.id;
        accSite.Market__c = marketTest.id;
        accSite.Unit_of_Measure__c = 'GJ';
        accSite.Volume__c = 1200;
        INSERT accSite;
        
        
        Test.startTest();    
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AddSiteAccountController controller = New AddSiteAccountController(sc);
        controller.Add();
        controller.selectedRowIndex = '1';
        controller.addMore();
        controller.Remove();
        /*AddSiteAccountController.addSite(accSite);*/
        List<AddSiteAccountController.AccountSiteWapper> accSiteWrapperList = new List<AddSiteAccountController.AccountSiteWapper>();
         Schema.DescribeFieldResult f = Schema.sObjectType.Account.fields.SBQQ__ContractCoTermination__c;
        Schema.DescribeFieldResult f2 = Schema.sObjectType.Account.fields.SBQQ__CoTerminationEvent__c;  
        String ctrlField = f.getName();
        String dependField = f2.getName();
        AddSiteAccountController.base64ToBits('Test');
     //   Map<String, List<String>> dependentMap= AddSiteAccountController.getDependentMap('Account', ctrlField, dependField);
        AddSiteAccountController.AccountSiteWapper accSiteWraper = new AddSiteAccountController.AccountSiteWapper(acc,accServ);
        AddSiteAccountController.AccountSiteWapper accSiteWraper2 = new AddSiteAccountController.AccountSiteWapper(acc);
        accSiteWraper.addSite(accSite);
        accSiteWrapperList.add(accSiteWraper);
        System.debug('**** accSiteWraper : ' + accSiteWraper);
        AddSiteAccountController.getAccountDetail(acc.Id);
        AddSiteAccountController.getTypeValue();
        AddSiteAccountController.getUOMValue();
        AddSiteAccountController.saveAccounts(System.JSON.serialize(accSiteWrapperList) ,acc.Id);
        AddSiteAccountController.initSite();
        AddSiteAccountController.innerClass inerClass = new AddSiteAccountController.innerClass(2);
        inerClass.acct.Name = 'test inner class'; 
        AddSiteAccountController.decimalToBinary(5); 
        AddSiteAccountController.PicklistEntryWrapper pickWrapper = new AddSiteAccountController.PicklistEntryWrapper();
        pickWrapper.active = 'test active';
        pickWrapper.defaultValue = 'test';
        pickWrapper.value = 'value';
        controller.Save();
        String key = accServ.Name + accServ.Market__c;
        AddSiteAccountController.ErrorSiteWapper errorWrapper = new AddSiteAccountController.ErrorSiteWapper('test message',key,accSite,true);
        Test.stopTest();
    }// End of test method
    @isTest
    public static void CSVData(){
        String testData = 'Location_Name,MARKET,STREET_ADDRESS,CITY,PROVINCE/STATE,POSTALCODE/ZIP,COUNTRY,SITE_ID,TYPE,UNIT_OF_MEASURE,VOLUME\nLocation1,a1Kf4000002mZs4EAE,"B1 44/21 Panchwati Apartment,near International Hotal",Jaipur,Rajasthan,302021,INDIA,1.23E+12,GAS,DTH,1\nLocation2,a1Kf4000002mZs4EAE,ploat no. 22  Panchwati Apartment,Jaipur,Rajasthan,302021,INDIA,1.23E+12,ElecTricity,KWh,2\nLocation3,a1Kf4000002mZs4EAE,LTC Carol Reid 171145 new street FPO AP 4569894398,Jaipur,Rajasthan,302021,INDIA,1.23E+12,Gas,DTH,3\nLocation4,a1Kf4000002mZs4EAE,"Billy Pilgrim 2604 5th Ave, Apt 901 San Diego, CA 92103-5432",Jaipur,Rajasthan,302021,INDIA,1.23E+12,Gas,GJ,4\nLocation5,a1Kf4000002mZs4EAE,B1 Panchwati Apartment Teh. Mozmabad ,Jaipur,Rajasthan,E30021,INDIA,1.23E+12,Electricity,KWh,5';
       string SiteData = '((a1Kf4000002mZs4EAE,  B1 44/21 Panchwati Apartment near International Hotal , Jaipur, Rajasthan, 302021, INDIA, 1.23E+12, GAS, DTH, 1), (a1Kf4000002mZs4EAE, ploat no. 22  Panchwati Apartment, Jaipur, Rajasthan, 302021, INDIA, 1.23E+12, ElecTricity, KWh, 2), (a1Kf4000002mZs4EAE, LTC Carol Reid 171145 new street FPO AP 4569894398, Jaipur, Rajasthan, 302021, INDIA, 1.23E+12, Gas, DTH, 3), (a1Kf4000002mZs4EAE,  Billy Pilgrim 2604 5th Ave  Apt 901 San Diego  CA 92103-5432 , Jaipur, Rajasthan, 302021, INDIA, 1.23E+12, Gas, GJ, 4), (a1Kf4000002mZs4EAE, B1 Panchwati Apartment Teh. Mozmabad , Jaipur, Rajasthan, E30021, INDIA, 1.23E+12, Electricity, KWh, 5))';
        List<String> CSVmapData = new List<String>{SiteData};
          Test.startTest(); 
        AddSiteAccountController.refineCSV(JSON.serialize(testData));
        MakeCsvDataLists.doPartions(CSVmapData, 10, List<List<string>>.class);
         Test.stopTest();
    }
}// End of Test class