/*************************************************************
* Class: RoundRobinAccountAssignmentBatch_Test
* Author: Soljit <VW>
* Date: 2019-05-24
* Description: test class for RoundRobinAccountAssignmentBatch
**************************************************************/
@isTest
public class RoundRobinAccountAssignmentBatch_Test 
{
	static FINAL String CLIENT_RECORD_TYPE_NAME = 'Account';
	static public FINAL String MAX_DAYS_IN_COOLER_STATUS = 'Max_Days_in_Cooler_Status';
	static public FINAL String MAX_DAYS_IN_PROSPECT_STATUS = 'Max_Days_in_Prospect_Status';

	static FINAL Integer NB_OF_MARKETS = 5;
	static FINAL Integer NB_OF_AGENTS = 5;
	static FINAL Integer MAX_NB_OF_ACCOUNTS_PER_USER = 200;
	static FINAL Integer MAX_NB_OF_LEADS_PER_USER = 1;
	static FINAL Integer NB_OF_ACCOUNTS = (NB_OF_AGENTS-1) * MAX_NB_OF_ACCOUNTS_PER_USER;
	static FINAL Integer NB_OF_CHILDREN_PER_ACCOUNT = 1;

	public static FINAL String EMAIL_SUFFIX = '@dneTest.com';

	@testSetup
	static void createData()
	{
		AccountTriggerHelper.bypassTrigger = true;

		Integer maxDaysInCooler;
		Integer maxDaysInProspect;

		List<Account_Flow_Delay__mdt> accountDelays = [SELECT DeveloperName, Days__c FROM Account_Flow_Delay__mdt];

		for(Account_Flow_Delay__mdt afd : accountDelays)
		{
			if(afd.DeveloperName == MAX_DAYS_IN_COOLER_STATUS)
			{
				maxDaysInCooler = Integer.valueOf(afd.Days__c);
			}
			else if(afd.DeveloperName == MAX_DAYS_IN_PROSPECT_STATUS)
			{
				maxDaysInProspect = Integer.valueOf(afd.Days__c);
			}
		}

		Datetime maxDatetimeInCooler = Datetime.now().addDays(-maxDaysInCooler);
		Datetime maxDatetimeInProspect = Datetime.now().addDays(-maxDaysInProspect);


		List<Market__c> marketsToInsert = new List<Market__c>();
		List<User> agentsToInsert = new List<User>();
		List<Account> accountsToInsert = new List<Account>();
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

		// --------------- CREATING THE ACCOUNTS ---------------
		
		Id client_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CLIENT_RECORD_TYPE_NAME).getRecordTypeId();

		counter = 0;
		while(counter < NB_OF_ACCOUNTS)
		{			
			for(Market__c mkt : marketsToInsert)
			{
				Account acc = new Account();
				acc.RecordTypeId = client_RTId;
				acc.Name = 'Test Account no ' + counter;
				acc.Status__c = (Math.Mod(counter,2)==0?'Disconnected':'Not interested');
				acc.Business_Size__c = 'Small';
				acc.Market__c = mkt.Id;
				acc.Last_Status_Change__c = Date.today().addDays(-(maxDaysInCooler+5));


				accountsToInsert.add(acc);
				counter++;
				if(counter == NB_OF_ACCOUNTS)
				{
					break;
				}
			}
		}
		insert accountsToInsert;

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

		// --------------- CREATING THE CHILDREN ACCOUNTS ---------------
		List<Site__c> siteList = new List<Site__c>();
		List<Account> childrenAccountList = new List<Account>();

		for(Account acc : accountsToInsert)
		{
			/*Integer siteCounter = 0;
			while(siteCounter < NB_OF_SITES_PER_ACCOUNT)
			{
				Site__c childSite = new Site__c();
				childSite.Account__c = acc.Id;
				siteList.add(childSite);
				siteCounter++;
			}*/

			Integer accCounter = 0;
			while(accCounter < NB_OF_CHILDREN_PER_ACCOUNT)
			{
				Account childAcc = new Account();
				childAcc.RecordTypeId = client_RTId;
				childAcc.Name = acc.Name + '_Child_' + accCounter;
				childAcc.Status__c = acc.Status__c;
				childAcc.ParentId = acc.Id;
				childAcc.Business_Size__c = 'Small';
				childAcc.Last_Status_Change__c = Date.today();
				//childAcc.OwnerId = acc.OwnerId;

				childrenAccountList.add(childAcc);

				accCounter++;
			}
		}
		//insert siteList;
		insert childrenAccountList;
	}
	// =====================================================

	@isTest
	static void test_method_one() 
	{
		String query = 'SELECT Id, OwnerId, Owner.ManagerId, Market__c FROM Account WHERE ParentId = null';

		Test.startTest();
			RoundRobinAccountAssignmentBatch b = new RoundRobinAccountAssignmentBatch();
			Id batchJobId = Database.executeBatch(b, NB_OF_ACCOUNTS);
		Test.stopTest();

		//--------------------------

		String agentNoAccountsUsername = 'SalesAgent_0' + EMAIL_SUFFIX;
		User agentNoAccounts = [SELECT Id FROM User WHERE LastName = 'Agent_0' AND Username = :agentNoAccountsUsername];

		List<Account> accountList = [SELECT Id, Market__c, Status__c, OwnerId, Owner.Sales_Agent__c FROM Account];

		for(Account acc : accountList)
		{
			// all Accounts should be 'In Progress'
			System.assertEquals('Prospect',acc.Status__c);

			//all Accounts should be assigned to a Sales Agent
			System.assert(acc.Owner.Sales_Agent__c);

			//no Account should be assigned to this Agent, since he's not assigned to any Market
			System.assertNotEquals(agentNoAccounts.Id, acc.OwnerId);
		}

		//----------------------------

		// the first Agent (with no Market) is supposed to have no Lead assigned
		// the rest of the Agents should have the same number of Leads assigned

		String testEmailSuffix = '%' + EMAIL_SUFFIX + '%';
		List<User> agentList = [SELECT Id, Maximum_Number_of_Accounts__c FROM User WHERE Sales_Agent__c = true AND Email LIKE :testEmailSuffix];

		List<AggregateResult> aggResList = [SELECT count(Id) numAccounts, OwnerId owner
		      						   		FROM Account
		      						   		WHERE parentId = null
		      						   		AND OwnerId IN :agentList
		      						   		GROUP BY OwnerId];
		
		System.debug('JTM - aggResList = ' + aggResList);
		for (AggregateResult aggRes : aggResList) 
		{
		    Id currentAgentId = (Id) aggRes.get('owner');
		    Integer nbOfAccount = (Integer) aggRes.get('numAccounts');
		    System.assertEquals(NB_OF_ACCOUNTS/(NB_OF_AGENTS-1), nbOfAccount);
		}
		
	}
	// ---------------------------------

	@isTest
	static void test_method_two() 
	{
		String query = 'SELECT Id, OwnerId, Owner.ManagerId, Market__c FROM Account WHERE ParentId = null';

		Test.startTest();
			RoundRobinAccountAssignmentBatch b = new RoundRobinAccountAssignmentBatch('m@y.com');
			Id batchJobId = Database.executeBatch(b, NB_OF_ACCOUNTS);
		Test.stopTest();

		//--------------------------

		String agentNoAccountsUsername = 'SalesAgent_0' + EMAIL_SUFFIX;
		User agentNoAccounts = [SELECT Id FROM User WHERE LastName = 'Agent_0' AND Username = :agentNoAccountsUsername];

		List<Account> accountList = [SELECT Id, Market__c, Status__c, OwnerId, Owner.Sales_Agent__c FROM Account];

		for(Account acc : accountList)
		{
			// all Accounts should be 'In Progress'
			System.assertEquals('Prospect',acc.Status__c);

			//all Accounts should be assigned to a Sales Agent
			System.assert(acc.Owner.Sales_Agent__c);

			//no Account should be assigned to this Agent, since he's not assigned to any Market
			System.assertNotEquals(agentNoAccounts.Id, acc.OwnerId);
		}

		//----------------------------

		// the first Agent (with no Market) is supposed to have no Lead assigned
		// the rest of the Agents should have the same number of Leads assigned

		String testEmailSuffix = '%' + EMAIL_SUFFIX + '%';
		List<User> agentList = [SELECT Id, Maximum_Number_of_Accounts__c FROM User WHERE Sales_Agent__c = true AND Email LIKE :testEmailSuffix];

		List<AggregateResult> aggResList = [SELECT count(Id) numAccounts, OwnerId owner
		      						   		FROM Account
		      						   		WHERE parentId = null
		      						   		AND OwnerId IN :agentList
		      						   		GROUP BY OwnerId];
		
		System.debug('JTM - aggResList = ' + aggResList);
		for (AggregateResult aggRes : aggResList) 
		{
		    Id currentAgentId = (Id) aggRes.get('owner');
		    Integer nbOfAccount = (Integer) aggRes.get('numAccounts');
		    System.assertEquals(NB_OF_ACCOUNTS/(NB_OF_AGENTS-1), nbOfAccount);
		}
	}
	
}