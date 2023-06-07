/**************************************************

* Class: LeadFlowBatch_Test 
* Author: Soljit <MJ>
* Date: JULY 2020
* Description: test class for LeadFlowBatch class
****************************************************/ 
@isTest
private class LeadFlowBatch_Test 
{
	static FINAL Integer NB_OF_LEADS = 200;
	static FINAL Integer NB_OF_AGENTS = 2;

	static FINAL String EMAIL_SUFFIX = '@dneLeadFlowTest.com';

	static FINAL String MAX_DAYS_NO_ACTIVITY = 'Max_Days_No_Activity';

	static FINAL Integer MAX_NB_OF_ACCOUNTS_PER_USER = 1;
	static FINAL Integer MAX_NB_OF_LEADS_PER_USER = 200;
/******************************************************************
Method Name    : createData
Parameter      : 
Description    : method used to create test data
******************************************************************/
	@testSetup
	static void createData()
	{
		Map<String,Id> queueMap = LeadTriggerHandler.queryLeadQueues();
		Id coolerQueueId = queueMap.get('Lead_Cooler');

		List<User> agentsToInsert = new List<User>();
		List<Lead> leadsToInsert = new List<Lead>();
		List<Task> tasksToInsert = new List<Task>();

		Integer maxDaysNoActivity;

		List<Lead_Flow_Delays__mdt> leadDelays = [SELECT DeveloperName, Days__c FROM Lead_Flow_Delays__mdt];

		for(Lead_Flow_Delays__mdt lfd : leadDelays)
		{
			if(lfd.DeveloperName == MAX_DAYS_NO_ACTIVITY)
			{
				maxDaysNoActivity = Integer.valueOf(lfd.Days__c);
			}
		}

		Datetime maxDatetimeNoActivity = Datetime.now().addDays(-maxDaysNoActivity);

		Integer counter = 0;

		// --------------- CREATING THE MANAGER AND THE AGENTS --------------- 
		List<String> profileNames = new List<String>{'Sales Agent', 'System Administrator'};
		List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name IN :profileNames];
		Id salesAgentProfileId;
		Id sysAdminProfileId;
		for(Profile p : profileList)
		{
			if(p.Name == 'Sales Agent')
			{
				salesAgentProfileId = p.Id;
			}
			else if(p.Name == 'System Administrator')
			{
				sysAdminProfileId = p.Id;
			}
		}
		
		User theManager = new User();
		theManager.ProfileId = sysAdminProfileId;
		theManager.FirstName = 'Manager of';
		theManager.LastName = 'The Agents';
		theManager.Email = 'Manager' + EMAIL_SUFFIX;
		theManager.Username = 'Manager_' + EMAIL_SUFFIX;
		theManager.Alias = 'manag';
		theManager.EmailEncodingKey = 'ISO-8859-1';
		theManager.LanguageLocaleKey = 'en_US';
		theManager.LocaleSidKey = 'en_US';
		theManager.TimeZoneSidKey = 'America/Los_Angeles';
		theManager.Sales_Agent__c = false;
		theManager.IsActive = true;
		insert theManager;
		
		counter = 0;
		while(counter < NB_OF_AGENTS)
		{
			User theAgent = new User();
			theAgent.ProfileId = salesAgentProfileId;
			theAgent.FirstName = 'Sales';
			theAgent.LastName = 'Agent_' + counter;
			theAgent.Email = 'SalesAgent_' + counter + EMAIL_SUFFIX;
			theAgent.Username = 'SalesAgent_' + counter + EMAIL_SUFFIX;
			theAgent.Alias = 'sa_' + counter;
			theAgent.EmailEncodingKey = 'ISO-8859-1';
			theAgent.LanguageLocaleKey = 'en_US';
			theAgent.LocaleSidKey = 'en_US';
			theAgent.TimeZoneSidKey = 'America/Los_Angeles';
			theAgent.Sales_Agent__c = true;
			theAgent.Maximum_Number_of_Leads__c = MAX_NB_OF_LEADS_PER_USER;
			theAgent.Maximum_Number_of_Accounts__c = MAX_NB_OF_ACCOUNTS_PER_USER;
			theAgent.ManagerId = theManager.Id;
			theAgent.IsActive = true;
			
			agentsToInsert.add(theAgent);
			counter++;
		}
		insert agentsToInsert;

		// --------------- CREATING THE LEADS AND THE TASKS ---------------
		
		//Last_Assignment_Date__c < :maxDatetimeNoActivity

		counter = 0;
		while(counter < NB_OF_LEADS)
		{
			Lead theLead = new Lead();
			theLead.LastName = 'Lead_v1_' + counter;
			theLead.Status = 'Active';
			theLead.Company = 'Random Company Ltd';
			theLead.Last_Assignment_Date__c = maxDatetimeNoActivity.addDays(-5);

			leadsToInsert.add(theLead);

			counter++;

			/*if(theLead.LastName=='Lead_v1_1')
				{
					//System.debug('JTM - queueIdList = ' + queueIdList);
					System.debug('JTM - theLead.OwnerId = ' + theLead.OwnerId);
					System.debug('JTM - theLead.Owner.Name = ' + theLead.Owner.Name);
					System.debug('JTM - theLead.LastActivityDate = ' + theLead.LastActivityDate);
					System.debug('JTM - theLead.Last_Assignment_Date__c = ' + theLead.Last_Assignment_Date__c);
					System.debug('JTM - maxDatetimeNotReached = ' + maxDatetimeNotReached);
				}*/
		}
		insert leadsToInsert;

		// ---------------
/*		for(Lead theLead : leadsToInsert)
		{
			Task theTask = new Task();
			theTask.ActivityDate = maxDatetimeNoActivity.addDays(-5);
			theTask.Status = 'Completed';
			theTask.Subject = 'Call';
			theTask.WhoId = theLead.Id;
			tasksToInsert.add(theTask);
		}*/

		// (OwnerId NOT IN :queueIdList AND LastActivityDate = null AND Last_Assignment_Date__c < :maxDatetimeNotReached)

		leadsToInsert = new List<Lead>();
		counter = 0;

		while(counter < NB_OF_LEADS)
		{
			Lead theLead = new Lead();
			theLead.LastName = 'Lead_v2_' + counter;
			theLead.Status = 'Active';
			theLead.Company = 'Random Company Ltd';
			theLead.OwnerId = agentsToInsert.get(Math.mod(counter,NB_OF_AGENTS)).Id;
			theLead.Last_Assignment_Date__c = maxDatetimeNoActivity.addDays(-5);

			leadsToInsert.add(theLead);

			counter++;
		}
		insert leadsToInsert;

		// ---------------
		for(Lead theLead : leadsToInsert)
		{
			Task theTask = new Task();
			theTask.ActivityDate = maxDatetimeNoActivity.addDays(-5).date();
			theTask.Status = 'Completed';
			theTask.Subject = 'Call';
			theTask.WhoId = theLead.Id;
			tasksToInsert.add(theTask);
		}
	}
	
	@isTest 
	static void test_method_one() 
	{
		String query = 'SELECT Id, LastName, Owner.Name, Last_Assignment_Date__c, Status, LastActivityDate, OwnerId FROM Lead';

		/*
		List<Lead> leadList = [SELECT Id, LastName, Owner.Name, Last_Assignment_Date__c, Status, Customer_reached__c, LastActivityDate, OwnerId FROM Lead];
		System.debug('JTM - leadList.size()' + leadList.size());
		*/

		Integer testingScenarios = 2;

		Test.startTest();
			LeadFlowBatch b = new LeadFlowBatch();
			Id batchJobId = Database.executeBatch(b, testingScenarios*NB_OF_LEADS);
		Test.stopTest();

		//--------------------------

		Map<String,Id> queueMap = LeadTriggerHandler.queryLeadQueues();
		Id coolerQueueId = queueMap.get('Lead_Cooler');

		List<Lead> leadList = [SELECT Id, LastName, Owner.Name, Last_Assignment_Date__c, Status, Customer_reached__c, LastActivityDate, OwnerId FROM Lead];
		System.assertEquals(testingScenarios*NB_OF_LEADS, leadList.size());

		Integer counterScenario_1 = 0;
		Integer counterScenario_2 = 0;

		for(Lead l : leadList)
		{
			if(l.LastName.contains('Lead_v1_'))
			{
				counterScenario_1++;
			}
			else if(l.LastName.contains('Lead_v2_'))
			{
				counterScenario_2++;
			}
		}

		System.assertEquals(NB_OF_LEADS,counterScenario_1);
		System.assertEquals(NB_OF_LEADS,counterScenario_2);
	}
	@IsTest
    static void testMethod2(){
        Lead theLead = new Lead();
			theLead.LastName = 'Lead_v2_';
			theLead.Status = 'New';
			theLead.Company = 'Random Company Ltd';
			theLead.Last_Assignment_Date__c = Datetime.now().addDays(-120);
        theLead.Exclude_from_lead_flow__c = false;
        insert theLead;
        test.startTest();
        LeadFlowBatch b = new LeadFlowBatch(theLead.id);
			Id batchJobId = Database.executeBatch(b);
        test.stopTest();
    }
}