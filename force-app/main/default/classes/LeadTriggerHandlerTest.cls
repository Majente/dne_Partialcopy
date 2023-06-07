/**************************************************
* Class: LeadTriggerHandlerTest
* Author: Soljit <VW>
* Date: 2019-07-09
* Description: Test class for LeadTriggerHandler
****************************************************/
@isTest
private class LeadTriggerHandlerTest
{
	static FINAL Integer NB_OF_LEADS = 400;
	static public FINAL String COMPETITOR_RECORD_TYPE_NAME = 'Competitor';

    /*********************************************************
    @Name 			: createData
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: create records for required code coverage
	********************************************************/
	@testSetup
	static void createData()
	{
		List<Lead> leadsToInsert = new List<Lead>();
		List<Market__c> marketsToInsert = new List<Market__c>();
		
		// --------------- CREATING THE MARKET ---------------
		Market__c theMarket = new Market__c();
		theMarket.Name = 'My Market';
        theMarket.Country__c = 'Canada';
		insert theMarket;

		// --------------- CREATING THE COMPETITOR ---------------

		Id competitor_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(COMPETITOR_RECORD_TYPE_NAME).getRecordTypeId();
		Account acc = new Account();
		acc.RecordTypeId = competitor_RTId;
		acc.Name = 'The Big Bad Wolf';
		acc.Status__c = 'Competitor';		
		acc.Business_Size__c = 'Small';
		insert acc;


		// --------------- CREATING THE LEADS ---------------
		Integer counter = 0;
		while(counter < NB_OF_LEADS)
		{
			Lead theLead = new Lead();
			theLead.LastName = 'Lead_' + counter + '_for_' + theMarket.Name;
			theLead.Market__c = theMarket.Id;
			theLead.Company = 'Random Company Ltd';
			theLead.IsConverted = false;
			theLead.Status = 'New';

			// half of the Leads have Status = "With Competitor"
			if(Math.Mod(counter,2)==0)
			{
				theLead.Status = 'With Competitor';
				theLead.Competitor__c = acc.Id;
				theLead.Call_Back_Date__c = Datetime.now().addDays(150);
				theLead.End_Date_of_Contract__c = Date.today().addDays(180);
			}				

			leadsToInsert.add(theLead);
			counter++;
		}

		insert leadsToInsert;
	}
	
    /*********************************************************
    @Name 			: test_method_one
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for LeadTriggerHandler
	********************************************************/
	@isTest 
	static void test_method_one() 
	{
		Id competitor_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(COMPETITOR_RECORD_TYPE_NAME).getRecordTypeId();

		Test.startTest();

			List<Lead> leadsToUpdate = [SELECT Id FROM Lead WHERE Status != 'With Competitor'];
			Account theCompetitor = [SELECT Id FROM Account WHERE RecordTypeId = :competitor_RTId];

			for(Lead theLead : leadsToUpdate)
			{
				theLead.Status = 'With Competitor';
				theLead.Competitor__c = theCompetitor.Id;
				theLead.Call_Back_Date__c = Datetime.now().addDays(150);
				theLead.End_Date_of_Contract__c = Date.today().addDays(180);
			}

			update leadsToUpdate;

		Test.stopTest();

		List<Lead> leadsUpToDate = [SELECT Id, Call_Back_Date__c, LastActivityDate FROM Lead];
		for(Lead theLead : leadsUpToDate)
		{
			System.assertEquals(theLead.Call_Back_Date__c.date(), theLead.LastActivityDate);
		}

	}
	// ------------------------------------------

	@isTest 
	static void test_method_two() 
	{
		Map<String,Id> queueMap = LeadTriggerHandler.queryLeadQueues();
		Id coolerQueueId = queueMap.get('Lead_Cooler');
		Id doNotCallQueueId = queueMap.get('Lead_Do_Not_Call');
		Id newLeadQueueId = queueMap.get('Leads_New');
		Id notServiceableLeadQueueId = queueMap.get('Not_Serviceable_Leads');

		List<Lead> leadsToUpdate = [SELECT Id, Status, OwnerId
									FROM Lead 
									WHERE Status = 'With Competitor' 
									ORDER BY LastName 
									LIMIT 4];
		
		Test.startTest();
			leadsToUpdate.get(0).Status = 'Not interested';

			leadsToUpdate.get(1).Status = 'Disconnected';

			leadsToUpdate.get(2).Status = 'Do Not Call';
			leadsToUpdate.get(2).Reason__c = 'Other';

			leadsToUpdate.get(3).Status = 'Not Serviceable';
			leadsToUpdate.get(3).Reason__c = 'Other';

			update leadsToUpdate;

		List<Lead> leadsJustUpdated = [SELECT Id, Status, OwnerId
									   FROM Lead 
									   WHERE Id IN :leadsToUpdate];
		Test.stopTest();		
		
		//System.assertEquals(coolerQueueId, leadsJustUpdated.get(0).OwnerId);
		//System.assertEquals(coolerQueueId, leadsJustUpdated.get(1).OwnerId);
		//System.assertEquals(doNotCallQueueId, leadsJustUpdated.get(2).OwnerId);
		//System.assertEquals(notServiceableLeadQueueId, leadsJustUpdated.get(3).OwnerId);
	}	
}