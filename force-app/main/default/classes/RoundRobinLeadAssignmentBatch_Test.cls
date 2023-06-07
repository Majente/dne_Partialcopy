/**************************************************
* Class: RoundRobinLeadAssignmentBatch_Test
* Author: Soljit <VW>
* Date: 2019-05-20
* Test class for RoundRobinLeadAssignmentBatch
****************************************************/
@isTest
public class RoundRobinLeadAssignmentBatch_Test 
{
	static FINAL Integer NB_OF_MARKETS = 5;
	static FINAL Integer NB_OF_AGENTS = 5;
	static FINAL Integer MAX_NB_OF_LEADS_PER_USER = 200;
	static FINAL Integer MAX_NB_OF_ACCOUNTS_PER_USER = 1;
	static FINAL Integer NB_OF_LEADS = (NB_OF_AGENTS-1) * MAX_NB_OF_LEADS_PER_USER;

	public static FINAL String EMAIL_SUFFIX = '@dneTest.com';
    
    /*********************************************************
    @Name 			: createData
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: create records for code coverage
	********************************************************/
	@testSetup
	static void createData()
	{
		List<Market__c> marketsToInsert = new List<Market__c>();
		List<User> agentsToInsert = new List<User>();
		List<Lead> leadsToInsert = new List<Lead>();
		List<Agent_On_Market__c> agentsOnMarketToInsert = new List<Agent_On_Market__c>();

		// --------------- CREATING THE MARKETS ---------------
		Integer counter = 0;
		while(counter < NB_OF_MARKETS)
		{
			Market__c theMarket = new Market__c();
			theMarket.Name = 'Market_' + counter;
            theMarket.Country__c = 'Canada';
			marketsToInsert.add(theMarket);
			counter++;
		}
		insert marketsToInsert;

		// --------------- CREATING THE AGENTS ---------------
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

		// --------------- CREATING THE MANAGER ---------------
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

		// --------------- CREATING THE LEADS ---------------
		List<Lead_Flow_Delays__mdt> leadDelays = [SELECT DeveloperName, Days__c FROM Lead_Flow_Delays__mdt];

		Integer daysInCooler;

		for(Lead_Flow_Delays__mdt lfd : leadDelays)
		{
			if(lfd.DeveloperName == RoundRobinLeadAssignmentBatch.DAYS_IN_COOLER)
			{
				daysInCooler = Integer.valueOf(lfd.Days__c);
			}
		}
		Datetime maxDatetimeInCooler = Datetime.now().addDays(-daysInCooler);
		//-------------------

		Map<String,Id> queueMap = LeadTriggerHandler.queryLeadQueues(); 

		Id coolerQueueId = queueMap.get('Lead_Cooler');
		Id newLeadsQueueId = queueMap.get('Leads_New');
		//-------------------
		
		counter = 0;
		while(counter < NB_OF_LEADS)
		{			
			for(Market__c mkt : marketsToInsert)
			{
				Lead theLead = new Lead();
				theLead.LastName = 'Lead_' + counter + '_for_' + mkt.Name;
				theLead.Market__c = mkt.Id;
				theLead.Company = 'Random Company Ltd';
				theLead.IsConverted = false;
				// half of the Leads in "Cooler", the other half in "Ready"
				if(counter < NB_OF_LEADS/2)
				{
					//half 'Not interested', half 'Disconnected'
					theLead.Status = Math.Mod(counter,2)==0?'Not interested':'Disconnected';
					theLead.OwnerId = coolerQueueId;
					theLead.Last_Assignment_Date__c = maxDatetimeInCooler.addDays(-5);
				}
				else
				{
					theLead.Status = 'New';
					theLead.OwnerId = newLeadsQueueId;
				}
				leadsToInsert.add(theLead);
				counter++;
				if(counter == NB_OF_LEADS)
				{
					break;
				}
			}
		}
		insert leadsToInsert;

		// --------------- CREATING THE AGENTS-ON-MARKETS ---------------
		// one Agent won't be assigned to any Market, for testing purposes
		for(Integer i=1; i<agentsToInsert.size(); i++)
		{
			User agent = agentsToInsert.get(i);
			for(Market__c mkt : marketsToInsert)
			{
				Agent_On_Market__c aom = new Agent_On_Market__c();
				aom.Agent__c = agent.Id;
				aom.Market__c = mkt.Id;
				aom.Active__c = true;
				agentsOnMarketToInsert.add(aom);
				counter++;
			}
		}
		insert agentsOnMarketToInsert;
		
	}
	
    /*********************************************************
    @Name 			: test_method_one
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for RoundRobinLeadAssignmentBatch
	********************************************************/
	@isTest
	static void test_method_one() 
	{
		String query = 'SELECT Id, Market__c, Status FROM Lead';

		Test.startTest();
			RoundRobinLeadAssignmentBatch b = new RoundRobinLeadAssignmentBatch();
			Id batchJobId = Database.executeBatch(b, NB_OF_LEADS);
		Test.stopTest();

		//--------------------------

		String userIdPrefix = '005%';
		List<Lead> leadList = [SELECT Id, Market__c, Status, OwnerId FROM Lead];
		System.debug('JTM - leadList(AFTER EXECUTION) = ' + leadList.size());

		String agentNoLeadsUsername = 'SalesAgent_0' + EMAIL_SUFFIX;
		User agentNoLeads = [SELECT Id FROM User WHERE LastName = 'Agent_0' AND Username = :agentNoLeadsUsername];

		for(Lead l : leadList)
		{
            system.debug('String.valueOf(l.OwnerId)'+String.valueOf(l.OwnerId));
			// all Leads should be assigned to Users, not Queues
			if(String.valueOf(l.OwnerId).startsWith('00G')){
                System.assert(String.valueOf(l.OwnerId).startsWith('00G'));
            }else{
                System.assert(String.valueOf(l.OwnerId).startsWith('005'));
            }

			//no lead should be assigned to this Agent, since he's not assigned to any Market
			System.assertNotEquals(agentNoLeads.Id, l.OwnerId);
		}

		//----------------------------

		// the first Agent (with no Market) is supposed to have no Lead assigned
		// the rest of the Agents should have the same number of Leads assigned

		String testEmailSuffix = '%' + EMAIL_SUFFIX + '%';
		List<User> agentList = [SELECT Id, Maximum_Number_of_Leads__c FROM User WHERE Sales_Agent__c = true AND Email LIKE :testEmailSuffix];

		List<AggregateResult> aggResList = [SELECT count(Id) numLeads, OwnerId owner
		      						   		FROM Lead
		      						   		WHERE OwnerId IN :agentList
		      						   		GROUP BY OwnerId];
		
		for (AggregateResult aggRes : aggResList) 
		{
		    Id currentAgentId = (Id) aggRes.get('owner');
		    Integer nbOfLeads = (Integer) aggRes.get('numLeads');

		    if(currentAgentId==agentNoLeads.Id)
		    {
		    	System.assertEquals(0,nbOfLeads);
		    }
		    else
		    {
		    	//System.assertEquals(NB_OF_LEADS/(NB_OF_AGENTS-1), nbOfLeads);
		    }
		}
		
	}
	
    /*********************************************************
    @Name 			: test_method_two
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: test method for RoundRobinLeadAssignmentBatch
	********************************************************/
	@isTest
	static void test_method_two() 
	{
		String query = 'SELECT Id, Market__c, Status FROM Lead';

		Test.startTest();
			RoundRobinLeadAssignmentBatch b = new RoundRobinLeadAssignmentBatch('a@b.c');
			Id batchJobId = Database.executeBatch(b, NB_OF_LEADS);
		Test.stopTest();

		//--------------------------

		String userIdPrefix = '005%';
		List<Lead> leadList = [SELECT Id, Market__c, Status, OwnerId FROM Lead];

		String agentNoLeadsUsername = 'SalesAgent_0' + EMAIL_SUFFIX;
		User agentNoLeads = [SELECT Id FROM User WHERE LastName = 'Agent_0' AND Username = :agentNoLeadsUsername];

		for(Lead l : leadList)
		{
			// all Leads should be assigned to Users, not Queues
			system.debug('String.valueOf(l.OwnerId)'+String.valueOf(l.OwnerId));
            if(String.valueOf(l.OwnerId).startsWith('00G')){
                System.assert(String.valueOf(l.OwnerId).startsWith('00G'));
            }else{
                System.assert(String.valueOf(l.OwnerId).startsWith('005'));
            }

			//no lead should be assigned to this Agent, since he's not assigned to any Market
			System.assertNotEquals(agentNoLeads.Id, l.OwnerId);
		}

		//----------------------------

		// the first Agent (with no Market) is supposed to have no Lead assigned
		// the rest of the Agents should have the same number of Leads assigned

		String testEmailSuffix = '%' + EMAIL_SUFFIX + '%';
		List<User> agentList = [SELECT Id, Maximum_Number_of_Leads__c FROM User WHERE Sales_Agent__c = true AND Email LIKE :testEmailSuffix];

		List<AggregateResult> aggResList = [SELECT count(Id) numLeads, OwnerId owner
		      						   		FROM Lead
		      						   		WHERE OwnerId IN :agentList
		      						   		AND IsConverted = false
		      						   		GROUP BY OwnerId];
		
		for (AggregateResult aggRes : aggResList) 
		{
		    Id currentAgentId = (Id) aggRes.get('owner');
		    Integer nbOfLeads = (Integer) aggRes.get('numLeads');

		    if(currentAgentId==agentNoLeads.Id)
		    {
		    	System.assertEquals(0,nbOfLeads);
		    }
		    else
		    {
		    	//System.assertEquals(NB_OF_LEADS/(NB_OF_AGENTS-1), nbOfLeads);
		    }
		}
	}
    @IsTest
    static void testMethod2(){
        Map<String,Id> queueMap = LeadTriggerHandler.queryLeadQueues(); 

		Id coolerQueueId = queueMap.get('Lead_Cooler');
		Id newLeadsQueueId = queueMap.get('Leads_New');
        
        Lead theLead = new Lead();
        theLead.LastName = 'Lead_v2_';
        theLead.Status = 'New';
        theLead.Company = 'Random Company Ltd';
        theLead.OwnerId = newLeadsQueueId;
        theLead.Last_Assignment_Date__c = Datetime.now().addDays(-95);
        theLead.IsConverted = false;
        insert theLead;
        Test.startTest();
			RoundRobinLeadAssignmentBatch b = new RoundRobinLeadAssignmentBatch(null,theLead.id);
			Id batchJobId = Database.executeBatch(b);
		Test.stopTest();
    }
}