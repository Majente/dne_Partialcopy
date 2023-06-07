/*************************************************************
* Class: ResidentialOppotunityHandlerTest
* Author: Soljit <VW>
* Date: 2019-12-2
* Description: Residentail Opportunity trigger test class
**************************************************************/
@isTest
private class ResidentialOppotunityHandlerTest {
    @testSetup
    public static void createData()
    {
            Date d1 = date.today();
            Date EffectiveFrom = d1.addDays(-2);
        
        //--------CREATING THE ACCOUNT--------------
        Account AccountRecord = new Account();
        AccountRecord.Name = 'Test Account Data';
        AccountRecord.RecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();//'0120q000000O2HIAA0';
        Insert AccountRecord;
        
        //--------CREATING THE CONTACT--------------
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName =  'Contact';
        con.AccountId = AccountRecord.Id; 
        Insert con;
      
        
        //--------CREATING THE CONTACT CLOSER--------------
        Contact ContactRecord = new Contact();
        ContactRecord.FirstName = 'Test';
        ContactRecord.LastName = 'Data';
        ContactRecord.AccountId = AccountRecord.Id;
        Insert ContactRecord;
        
        //--------CREATING THE CONTACT RECEIVER 1--------------
        Contact ContactRecord1 = new Contact();
        ContactRecord1.FirstName = 'Test';
        ContactRecord1.LastName = 'Data 01';
        ContactRecord1.AccountId = AccountRecord.Id;
        Insert ContactRecord1;
        
        ////--------CREATING THE CONTACT RECEIVER 2--------------
        Contact ContactRecord2 = new Contact();
        ContactRecord2.FirstName = 'Test';
        ContactRecord2.LastName = 'Data 02';
        ContactRecord2.AccountId = AccountRecord.Id;
        Insert ContactRecord2;
        
        //--------CREATING THE CONTACT RECEIVER 3--------------
        Contact ContactRecord3 = new Contact();
        ContactRecord3.FirstName = 'Test';
        ContactRecord3.LastName = 'Data 03';
        ContactRecord3.AccountId = AccountRecord.Id;
        Insert ContactRecord3;
        
        //--------CREATING THE CONTACT RECEIVER 4--------------
        Contact ContactRecord4 = new Contact();
        ContactRecord4.FirstName = 'Test';
        ContactRecord4.LastName = 'Data 04';
        ContactRecord4.AccountId = AccountRecord.Id;
        Insert ContactRecord4;
        
        //--------CREATING THE CONTACT RECEIVER 5--------------
        Contact ContactRecord5 = new Contact();
        ContactRecord5.FirstName = 'Test';
        ContactRecord5.LastName = 'Data 05';
        ContactRecord5.AccountId = AccountRecord.Id;
        Insert ContactRecord5;
        
        //--------CREATING THE RESIDENTIAL COMMISSION CONFIGUE--------------
        ResidentialCommissionConfigure__c ResidentialCommissionConfigueRecord = new ResidentialCommissionConfigure__c();
        ResidentialCommissionConfigueRecord.Supplier__c = AccountRecord.Id;
        ResidentialCommissionConfigueRecord.EffectiveFrom__c = EffectiveFrom;
        ResidentialCommissionConfigueRecord.Type__c = 'Type value1';
        ResidentialCommissionConfigueRecord.Flat_Fee_Paid_To_DNE__c = 3324;
        ResidentialCommissionConfigueRecord.PromoCode__c = 'test';
        ResidentialCommissionConfigueRecord.Commodity__c = 'Gas';
        ResidentialCommissionConfigueRecord.Contractsource__c = 'Test Value1';
        ResidentialCommissionConfigueRecord.Term__c = 123;
        ResidentialCommissionConfigueRecord.ProvinceorState__c = 'State test';
        ResidentialCommissionConfigueRecord.Country__c = 'Country test';
        ResidentialCommissionConfigueRecord.ECC__c = true;
        ResidentialCommissionConfigueRecord.Closer__c = 2;
        ResidentialCommissionConfigueRecord.Level1__c = 1;
        ResidentialCommissionConfigueRecord.Level2__c = 2.2;
        ResidentialCommissionConfigueRecord.Level3__c = 3.1;
        ResidentialCommissionConfigueRecord.Level4__c = 4;
        ResidentialCommissionConfigueRecord.Level5__c = 1.2;
        ResidentialCommissionConfigueRecord.Clawbacktime__c = 30;
        Insert ResidentialCommissionConfigueRecord;
        
        //--------CREATING THE RESIDENTIAL COMMISSION HIERARCHY--------------
        Residential_Commission_Hierarchy__c ResidentialCommissionHierarchyRecords = new Residential_Commission_Hierarchy__c();
        ResidentialCommissionHierarchyRecords.Effective_From__c = EffectiveFrom;
        ResidentialCommissionHierarchyRecords.Closer__c = ContactRecord.Id;
        ResidentialCommissionHierarchyRecords.Level1__c = ContactRecord1.Id;
        ResidentialCommissionHierarchyRecords.Level2__c = ContactRecord2.Id;
        ResidentialCommissionHierarchyRecords.Level3__c = ContactRecord3.Id;
        ResidentialCommissionHierarchyRecords.Level4__c = ContactRecord4.Id;
        ResidentialCommissionHierarchyRecords.Level5__c = ContactRecord5.Id;
        Insert ResidentialCommissionHierarchyRecords;
    }
 
 /*********************************************************
	@Name           : createResiOpp
	@Parameters     : 
	@Return type    : Void
	@Description    : Method to create Residential Opportunity & 
					  check Residential Commission when Residential Opportunity is changed to closed won
	********************************************************/    
  
    @isTest 
    static void createResiOpp() 
    {
        createData();
        Test.startTest();
        Residential_Opportunity__c ResidentialOpportunityRecords = new Residential_Opportunity__c();
        ResidentialOpportunityRecords.Closer__c = 'Test Data';
        ResidentialOpportunityRecords.AccountName__c = 'Test Account Data';
        ResidentialOpportunityRecords.Type__c = 'Type value1';
        ResidentialOpportunityRecords.StageName__c = 'Qualification';
        ResidentialOpportunityRecords.PromoCode__c = 'test';
        ResidentialOpportunityRecords.CloseDate__c = system.today();
        ResidentialOpportunityRecords.Commodity__c = 'Gas';
        ResidentialOpportunityRecords.Contractsource__c = 'Test Value1';
        ResidentialOpportunityRecords.Term__c = 123;
        ResidentialOpportunityRecords.Country__c = 'Country test';
        ResidentialOpportunityRecords.State__c = 'State test';
        ResidentialOpportunityRecords.Supplier__c = 'Test Account Data';
        ResidentialOpportunityRecords.ECC__c = true;
        Insert ResidentialOpportunityRecords;
        
        system.assertEquals(1, [Select Id from Residential_Opportunity__c].size());
        
        ResidentialOpportunityRecords.StageName__c = 'Closed Won';
        UPDATE ResidentialOpportunityRecords;
        system.assertEquals('Closed Won', ResidentialOpportunityRecords.StageName__c);
        
        List<Residential_Commission__c> wonOppComm = [Select Id, Paid__c, Amount__c From Residential_Commission__c Where Residential_Opportunity__c =: ResidentialOpportunityRecords.Id ];
        system.assertEquals(6, wonOppComm.size());
       
        wonOppComm[0].Paid__c = True;
        wonOppComm[2].Paid__c = True;
	    UPDATE wonOppComm;
        system.debug('wonOppComm#########>' +wonOppComm);
        
       
        ResidentialOpportunityRecords.StageName__c = 'Cancelled';
        ResidentialOpportunityRecords.Cancelled_Date__c = system.today();
        UPDATE ResidentialOpportunityRecords;
        system.assertEquals('Cancelled', ResidentialOpportunityRecords.StageName__c);
       
       	List<Residential_Commission__c> cancelledOppComm = [Select Id, Paid__c, Amount__c From Residential_Commission__c Where Residential_Opportunity__c =: ResidentialOpportunityRecords.Id ];
        system.assertNotEquals(wonOppComm[0].Amount__c, cancelledOppComm[0].Amount__c);
        
        Test.stopTest();
    }
 
/*********************************************************
	@Name           : createResiOppHieCheck
	@Parameters     : 
	@Return type    : Void
	@Description    : Method to create Residential Opportunity When Closer is not in Hierarchy
					 
	********************************************************/        
    
    @isTest 
    static void createResiOppHieCheck() 
    {
        createData();
        Test.startTest();
        Residential_Opportunity__c ResidentialOpportunityRecords = new Residential_Opportunity__c();
        ResidentialOpportunityRecords.Closer__c = 'Test Contact';
        ResidentialOpportunityRecords.AccountName__c = 'Test Account Data';
        ResidentialOpportunityRecords.Type__c = 'Type value1';
        ResidentialOpportunityRecords.StageName__c = 'Qualification';
        ResidentialOpportunityRecords.PromoCode__c = 'test';
        ResidentialOpportunityRecords.CloseDate__c = system.today();
        ResidentialOpportunityRecords.Commodity__c = 'Gas';
        ResidentialOpportunityRecords.Contractsource__c = 'Test Value1';
        ResidentialOpportunityRecords.Term__c = 123;
        ResidentialOpportunityRecords.Country__c = 'Country test';
        ResidentialOpportunityRecords.State__c = 'State test';
        ResidentialOpportunityRecords.Supplier__c = 'Test Account Data';
        ResidentialOpportunityRecords.ECC__c = true;
        Insert ResidentialOpportunityRecords;
        
        system.assertEquals(1, [Select Id from Residential_Opportunity__c].size());
        
        ResidentialOpportunityRecords.StageName__c = 'Closed Won';
        update ResidentialOpportunityRecords;
        system.assertEquals('Closed Won', ResidentialOpportunityRecords.StageName__c);
        
        List<Residential_Commission__c> wonOppComm = [Select Id, Paid__c, Amount__c From Residential_Commission__c Where Residential_Opportunity__c =: ResidentialOpportunityRecords.Id ];
        system.assertEquals(1, wonOppComm.size());
        wonOppComm[0].Paid__c = True;
	    UPDATE wonOppComm;
        system.debug('wonOppComm#########>' +wonOppComm);
        
        
        ResidentialOpportunityRecords.StageName__c = 'Cancelled';
        ResidentialOpportunityRecords.Cancelled_Date__c = system.today();
        UPDATE ResidentialOpportunityRecords;
        system.assertEquals('Cancelled', ResidentialOpportunityRecords.StageName__c);
        
        List<Residential_Commission__c> cancelledOppComm = [Select Id, Paid__c, Amount__c From Residential_Commission__c Where Residential_Opportunity__c =: ResidentialOpportunityRecords.Id ];
        system.assertNotEquals(wonOppComm[0].Amount__c, cancelledOppComm[0].Amount__c);
        
        Test.stopTest();
    }  
    
    
    /*********************************************************
	@Name           : ResiOppCloseDateNullCheck
	@Parameters     : 
	@Return type    : Void
	@Description    : Method to create Residential Opportunity and 
					  Commission When  Residential Opportunity Close Date is Null
	********************************************************/  
    @isTest 
    static void ResiOppCloseDateNullCheck() 
    {
        createData();
        Test.startTest();
        Residential_Opportunity__c ResidentialOpportunityRecords = new Residential_Opportunity__c();
        ResidentialOpportunityRecords.Closer__c = 'Test Contact';
        ResidentialOpportunityRecords.AccountName__c = 'Test Account Data';
        ResidentialOpportunityRecords.Type__c = 'Type value1';
        ResidentialOpportunityRecords.StageName__c = 'Qualification';
        ResidentialOpportunityRecords.PromoCode__c = 'test';
        //ResidentialOpportunityRecords.CloseDate__c = system.today();
        ResidentialOpportunityRecords.Commodity__c = 'Gas';
        ResidentialOpportunityRecords.Contractsource__c = 'Test Value1';
        ResidentialOpportunityRecords.Term__c = 123;
        ResidentialOpportunityRecords.Country__c = 'Country test';
        ResidentialOpportunityRecords.State__c = 'State test';
        ResidentialOpportunityRecords.Supplier__c = 'Test Account Data';
        ResidentialOpportunityRecords.ECC__c = true;
        Insert ResidentialOpportunityRecords;
        
        system.assertEquals(1, [Select Id from Residential_Opportunity__c].size());
        
        ResidentialOpportunityRecords.StageName__c = 'Closed Won';
        update ResidentialOpportunityRecords;
        system.assertEquals('Closed Won', ResidentialOpportunityRecords.StageName__c);
        
        List<Residential_Commission__c> wonOppComm = [Select Id, Paid__c, Amount__c From Residential_Commission__c Where Residential_Opportunity__c =: ResidentialOpportunityRecords.Id ];
        system.assertEquals(1, wonOppComm.size());
        wonOppComm[0].Paid__c = True;
	    UPDATE wonOppComm;
        system.debug('wonOppComm#########>' +wonOppComm);
        
        
        ResidentialOpportunityRecords.StageName__c = 'Cancelled';
         ResidentialOpportunityRecords.Cancelled_Date__c = system.today();
        UPDATE ResidentialOpportunityRecords;
        system.assertEquals('Cancelled', ResidentialOpportunityRecords.StageName__c);
        
        List<Residential_Commission__c> cancelledOppComm = [Select Id, Paid__c, Amount__c From Residential_Commission__c Where Residential_Opportunity__c =: ResidentialOpportunityRecords.Id ];
        system.assertEquals(wonOppComm[0].Amount__c, cancelledOppComm[0].Amount__c);
        
        Test.stopTest();
    }  
    
    
    /*********************************************************
	@Name           : ClawbackDateExpiryCheck
	@Parameters     : 
	@Return type    : Void
	@Description    : Method to create Residential Opportunity and 
					  Commission When clawback date is expired
	********************************************************/  
    @isTest 
    static void ClawbackDateExpiryCheck() 
    {
        createData();
        Test.startTest();
        Residential_Opportunity__c ResidentialOpportunityRecords = new Residential_Opportunity__c();
        ResidentialOpportunityRecords.Closer__c = 'Test Contact';
        ResidentialOpportunityRecords.AccountName__c = 'Test Account Data';
        ResidentialOpportunityRecords.Type__c = 'Type value1';
        ResidentialOpportunityRecords.StageName__c = 'Qualification';
        ResidentialOpportunityRecords.PromoCode__c = 'test';
        ResidentialOpportunityRecords.CloseDate__c = system.today().addDays(-40);
        ResidentialOpportunityRecords.Commodity__c = 'Gas';
        ResidentialOpportunityRecords.Contractsource__c = 'Test Value1';
        ResidentialOpportunityRecords.Term__c = 123;
        ResidentialOpportunityRecords.Country__c = 'Country test';
        ResidentialOpportunityRecords.State__c = 'State test';
        ResidentialOpportunityRecords.Supplier__c = 'Test Account Data';
        ResidentialOpportunityRecords.ECC__c = true;
        Insert ResidentialOpportunityRecords;
        
        system.assertEquals(1, [Select Id from Residential_Opportunity__c].size());
        
        ResidentialOpportunityRecords.StageName__c = 'Closed Won';
        update ResidentialOpportunityRecords;
        system.assertEquals('Closed Won', ResidentialOpportunityRecords.StageName__c);
        
        List<Residential_Commission__c> wonOppComm = [Select Id, Paid__c, Amount__c From Residential_Commission__c Where Residential_Opportunity__c =: ResidentialOpportunityRecords.Id ];
        system.assertEquals(1, wonOppComm.size());
        wonOppComm[0].Paid__c = True;
	    UPDATE wonOppComm;
        system.debug('wonOppComm#########>' +wonOppComm);
        
        
        ResidentialOpportunityRecords.StageName__c = 'Cancelled';
        ResidentialOpportunityRecords.Cancelled_Date__c = system.today();
        UPDATE ResidentialOpportunityRecords;
        system.assertEquals('Cancelled', ResidentialOpportunityRecords.StageName__c);
        
        List<Residential_Commission__c> cancelledOppComm = [Select Id, Paid__c, Amount__c From Residential_Commission__c Where Residential_Opportunity__c =: ResidentialOpportunityRecords.Id ];
        system.assertEquals(wonOppComm[0].Amount__c, cancelledOppComm[0].Amount__c);
        
        Test.stopTest();
    }  

    
}