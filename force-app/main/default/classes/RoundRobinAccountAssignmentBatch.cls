/*************************************************************
* Class: RoundRobinAccountAssignmentBatch
* Author: Soljit <VW>
* Date: 2019-05-24
* Description: batch class for Account Assignment
**************************************************************/
global class RoundRobinAccountAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful 
{
	public FINAL String CLIENT_RECORD_TYPE_NAME = 'Account';
	public FINAL String MAX_DAYS_IN_COOLER_STATUS = 'Max_Days_in_Cooler_Status';
	public FINAL String MAX_DAYS_IN_PROSPECT_STATUS = 'Max_Days_in_Prospect_Status';

	public Integer maxDaysInCooler {get;set;}
	public Integer maxDaysInProspect {get;set;}

	Datetime maxDatetimeInCooler;
	Datetime maxDatetimeInProspect;
	Date maxDateInProspect;

	String query;
	global Integer accountAssignmentsSuccess = 0;
	global Integer accountAssignmentsError = 0;

	String emailAddress;
	
	global Map<Id,Integer> userId_NbOfAccounts_Map;	// nb of Accounts currently assigned to this Agent
	global Map<Id,Integer> userId_MaxNbOfAccounts_Map;	// maximum nb of Accounts that can be assigned to this Agent

	// Map<AgentId, Set<MarketId>>
	Map<Id,Set<Id>> agent_MarketSet_Map;

	//List<Id> parentIdList;

	// Map<AccountId, List<children Account>>
	Map<Id, List<Account>> parentId_AccList_Map;

	List<Id> dneMarkets;

	// ===================================================
	/*********************************************************
    @Name 			: RoundRobinAccountAssignmentBatch
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
	global RoundRobinAccountAssignmentBatch() 
	{
		getMaxDaysInStatuses();
	}
	// ---------------------------------------------------
/*********************************************************
    @Name 			: RoundRobinAccountAssignmentBatch
    @Parameters 	: String emailAddr
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
	global RoundRobinAccountAssignmentBatch(String emailAddr)
	{
		/*createAgentAccountMap();
		createAgentMarketMap();*/
		getMaxDaysInStatuses();
		emailAddress = emailAddr;
	}
	// ===================================================
	/*********************************************************
    @Name 			: start
    @Parameters 	: Database.BatchableContext BC
    @Reutrn type 	: Database.QueryLocator
    @Description 	: to get account data
	********************************************************/
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		Id client_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CLIENT_RECORD_TYPE_NAME).getRecordTypeId();

		query = 'SELECT Id, OwnerId, Owner.ManagerId, Market__c ';
		query += 'FROM Account ';
		query += 'WHERE RecordTypeId = :client_RTId ';
		query += 'AND ParentId = null ';
		query += 'AND (Status__c = \'Disconnected\' OR Status__c = \'Not interested\') ';
		query += 'AND Last_Status_Change__c < :maxDatetimeInCooler';

		Database.QueryLocator dbQl = Database.getQueryLocator(query);
/*
		//===================>>>
		List<Account> accountList = new List<Account>();
		Database.QueryLocatorIterator it =  dbQl.iterator();
		// Iterate over the records
		while (it.hasNext())
		{
		    Account a = (Account)it.next();
		    accountList.add(a);
		}

		System.debug('JTM - accountList.size() = ' + accountList.size());
		// ================<<<

		//parentIdList = new List<Id>();
		parentId_AccList_Map = new Map<Id, List<Account>>();
		parentId_SiteList_Map = new Map<Id, List<Site__c>>();

		Database.QueryLocatorIterator it =  dbQl.iterator();
		// Iterate over the records
		while (it.hasNext())
		{
		    Account a = (Account)it.next();
		    //parentIdList.add(a.Id);
		    parentId_AccList_Map.put(a.Id, a.ChildAccounts);
		    parentId_SiteList_Map.put(a.Id, a.Sites__r);
		}

		//System.debug('JTM - parentIdList.size() = ' + parentIdList.size());
*/
		Database.QueryLocatorIterator it =  dbQl.iterator();

		List<Account> accList = new List<Account>();
		// Iterate over the records
		while (it.hasNext())
		{
		    Account a = (Account)it.next();
		    accList.add(a);
		}

		System.debug('JTM - accList.size() (START) = ' + accList.size());


		createAgentAccountMap();
		createAgentMarketMap();


		return dbQl;
	}
	// ---------------------------------------------------
    /*********************************************************
    @Name 			: execute
    @Parameters 	: Database.BatchableContext BC, List<Account> scope
    @Reutrn type 	: void
    @Description 	: update all the accounts
	********************************************************/
   	global void execute(Database.BatchableContext BC, List<Account> scope) 
   	{

		//getGrandChildrenSites();

		System.debug('JTM - scope (EXECUTE) = ' + scope.size());

		parentId_AccList_Map = new Map<Id, List<Account>>();

		List<Account> allChildrenAccounts = [SELECT Id, ParentId FROM Account WHERE ParentId IN :scope];
		if(!allChildrenAccounts.isEmpty())
		{
			for(Account child : allChildrenAccounts)
			{
				Id theKey = child.ParentId;
				List<Account> theValue;

				if(parentId_AccList_Map.containsKey(theKey))
				{
					theValue = parentId_AccList_Map.get(theKey);
				}
				else
				{
					theValue = new List<Account>();
				}

				theValue.add(child);

				parentId_AccList_Map.put(theKey, theValue);
			}
		}

   		System.debug('JTM - scope.size() = ' + scope.size());
   		List<Account> accountsToUpdate = new List<Account>();
   		List<Site__c> sitesToUpdate = new List<Site__c>();
   		List<Id> agentsToGetAccounts = new List<Id>();

   		agentsToGetAccounts.addAll(userId_NbOfAccounts_Map.keySet());

   		System.debug('JTM - agentsToGetAccounts.size() = ' + agentsToGetAccounts.size());
   		System.debug('JTM - availableAgents() = ' + availableAgents());

   		for(Account currentAccount : scope)
		{
			// if all the Agents have the maximum nb of Accounts, we stop the process
			if(!availableAgents())
			{
				break;
			}
			
			for(Integer i=0; i<agentsToGetAccounts.size(); i++)
			{
				// don't laugh, we neew the index "i" later in the loop!!!
				Id thisAgentId = agentsToGetAccounts.get(i);

				Integer maxAccountsPerThisAgent = userId_MaxNbOfAccounts_Map.get(thisAgentId);
				
				//if the agent already has the maximum number of accounts, we skip him
				//if(userId_NbOfAccounts_Map.get(thisAgentId) >= maxAccountsPerAgent)
				if(userId_NbOfAccounts_Map.get(thisAgentId) >= maxAccountsPerThisAgent)
				{
					continue;
				}

				// checking if the Agent is assigned to the Lead Market
				if(currentAccount.Market__c != null)
				{
					Set<Id> thisAgentMarketSet = agent_MarketSet_Map.get(thisAgentId);
					
					if(thisAgentMarketSet==null || !thisAgentMarketSet.contains(currentAccount.Market__c))
					{
						continue;
					}
				}

				// assign current Account to the current Agent
				currentAccount.OwnerId = thisAgentId;
				currentAccount.Status__c = 'Prospect';
				accountsToUpdate.add(currentAccount);

				Integer newNbOfAccounts = userId_NbOfAccounts_Map.get(thisAgentId) + 1;

				//List<Site__c> allRelatedSites = parentId_SiteList_Map.get(currentAccount.Id);
				List<Account> childrenAccounts = parentId_AccList_Map.get(currentAccount.Id);

				/*if(allRelatedSites!=null && !allRelatedSites.isEmpty())
				{
					for(Site__c theSite : allRelatedSites)
					{
						theSite.OwnerId = thisAgentId;
						sitesToUpdate.add(theSite);
					}
				}*/

				if(childrenAccounts!=null && !childrenAccounts.isEmpty())
				{
					for(Account acc : childrenAccounts)
					{
						acc.OwnerId = thisAgentId;
						acc.Status__c = 'Prospect';
						accountsToUpdate.add(acc);
					}

					// newNbOfAccounts += childrenAccounts.size();
				}

				userId_NbOfAccounts_Map.put(thisAgentId, newNbOfAccounts);
				
				// the agent is removed and added back at the end of the list
				agentsToGetAccounts.remove(i);
				
				//if(newNbOfAccounts < maxAccountsPerAgent)
				if(newNbOfAccounts < maxAccountsPerThisAgent)
				{
					agentsToGetAccounts.add(thisAgentId);
				}
				
				break;
			}						
		}

		System.debug('JTM - accountsToUpdate = ' + accountsToUpdate.size());
		//System.debug('JTM - sitesToUpdate = ' + sitesToUpdate.size());

		// update accountsToUpdate;

		if(!accountsToUpdate.isEmpty())
		{
			List<Database.SaveResult> result = Database.update(accountsToUpdate, false);
			Integer counter = 0;
			for (Database.SaveResult sr : result)
			{
			    if (sr.isSuccess())
			    {
			    	accountAssignmentsSuccess++;
			    }
			    else
			    {
			    	accountAssignmentsError++;
			    }
			}
		}
/*
		if(!sitesToUpdate.isEmpty())
		{
			List<Database.SaveResult> result = Database.update(sitesToUpdate, false);
			Integer counter = 0;
			for (Database.SaveResult sr : result)
			{
			    if (sr.isSuccess())
			    {
			    	siteAssignmentsSuccess++;
			    }
			    else
			    {
			    	siteAssignmentsError++;
			    }
			}
		}
*/			
   	}
   	// ---------------------------------------------------
	/*********************************************************
    @Name 			: finish
    @Parameters 	: Database.BatchableContext BC
    @Reutrn type 	: void
    @Description 	: send an email
	********************************************************/
	global void finish(Database.BatchableContext BC) 
	{
		String emailSubject = 'Account Assignment Batch has finished running';
		String emailBody = 'Batch execution summary: ' + accountAssignmentsSuccess + ' Accounts successfully assigned and ' + accountAssignmentsError + ' Accounts failed to assign. ';
		//emailBody += ('' +  siteAssignmentsSuccess + ' Sites successfully assigned and ' + siteAssignmentsError + ' Sites failed to assign');
		System.debug(emailBody);
		
		if(emailAddress != null)
		{
			List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();         
            String[] toAddresses = new String[] {emailAddress};         
            mail.setToAddresses(toAddresses);         
            mail.setSubject(emailSubject);         
            mail.setHtmlBody(emailBody);

            singleEmailList.add(mail);

            try
            {
                Messaging.sendEmail(singleEmailList);
                System.debug('RoundRobinAccountAssignmentBatch - EMAIL SENT');
            }
            catch(Exception e)
            {
            	System.debug('RoundRobinAccountAssignmentBatch - Error sending email: ' + e.getMessage());
            }
		}
	}
	// ==================================================================
	// ========================= HELPER METHODS =========================
	// ==================================================================

	private void getMaxDaysInStatuses()
	{
		// ---------------------- MAX DAYS IN STATUSES ----------------------

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

		maxDatetimeInCooler = Datetime.now().addDays(-maxDaysInCooler);
		maxDatetimeInProspect = Datetime.now().addDays(-maxDaysInProspect);
		maxDateInProspect = Date.today().addDays(-maxDaysInProspect);
	}
	// ---------------------------------------------------
/*
	private void getGrandChildrenSites()
	{
		List<Id> childAccountIdList = new List<Id>();
		for(List<Account> accList : parentId_AccList_Map.values())
		{
			for(Account acc : accList)
			{
				childAccountIdList.add(acc.Id);
			}
		}

		if(childAccountIdList.isEmpty())
		{
			return;
		}

		List<Site__c> grandChildrenSitesList = [SELECT Id, Account__r.ParentId 
												FROM Site__c 
												WHERE Account__c IN :childAccountIdList];

		for(Site__c theSite : grandChildrenSitesList)
		{
			Id theKey = theSite.Account__r.ParentId;
			List<Site__c> theValue;
			if(parentId_SiteList_Map.containsKey(theKey))
			{
				theValue = parentId_SiteList_Map.get(theKey);
			}
			else
			{
				theValue = new List<Site__c>();
			}

			theValue.add(theSite);
			parentId_SiteList_Map.put(theKey, theValue);
		}
	}*/
	// ---------------------------------------------------

	private Boolean availableAgents()
	{
		for(Id agentId : userId_NbOfAccounts_Map.keySet())
		{
			Integer accountsPerThisAgent = userId_NbOfAccounts_Map.get(agentId);
			Integer maxAccountsPerThisAgent = userId_MaxNbOfAccounts_Map.get(agentId);
			if(accountsPerThisAgent < maxAccountsPerThisAgent)
			{
				return true;
			}
		}
		return false;
	}
	// ---------------------------------------------------

	private void createAgentAccountMap()
	{
		Id client_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CLIENT_RECORD_TYPE_NAME).getRecordTypeId();

		userId_NbOfAccounts_Map = new Map<Id,Integer>();
		userId_MaxNbOfAccounts_Map = new Map<Id,Integer>();
		List<User> agentList;
		
		String testEmailSuffix = '%' + RoundRobinAccountAssignmentBatch_Test.EMAIL_SUFFIX + '%';
		
		if(Test.isRunningTest())
		{
			agentList = [SELECT Id, Maximum_Number_of_Accounts__c FROM User WHERE IsActive = true AND Sales_Agent__c = true AND Email LIKE :testEmailSuffix];
		}
		else
		{
			agentList = [SELECT Id, Maximum_Number_of_Accounts__c FROM User WHERE IsActive = true AND Sales_Agent__c = true];
		}
		
		for(User agent : agentList)
		{
			userId_NbOfAccounts_Map.put(agent.Id, 0);
			userId_MaxNbOfAccounts_Map.put(agent.Id, Integer.valueOf(agent.Maximum_Number_of_Accounts__c));
		}

		List<AggregateResult> aggResList = [SELECT count(Id) numAccounts, OwnerId owner
		      						   		FROM Account
		      						   		WHERE OwnerId IN :agentList
		      						   		AND RecordTypeId = :client_RTId
		      						   		AND Status__c != 'Contracted'
		      						   		GROUP BY OwnerId];
		System.debug('JTM - aggResList = ' + aggResList);
		for (AggregateResult aggRes : aggResList) 
		{
		    Id theKey = (Id) aggRes.get('owner');
		    Integer theValue = (Integer) aggRes.get('numAccounts');
		    Integer maxAccountsPerThisAgent = userId_MaxNbOfAccounts_Map.get(theKey);
		    //if(theValue < maxAccountsPerAgent)
		    if(theValue < maxAccountsPerThisAgent)
		    {
		    	userId_NbOfAccounts_Map.put(theKey, theValue);
		    }
		    else
		    {
		    	userId_NbOfAccounts_Map.remove(theKey);
		    }
		}
	}
	// ---------------------------------------------------

	private void createAgentMarketMap()
	{
		// Map<AgentId, Set<MarketId>>
		agent_MarketSet_Map = new Map<Id,Set<Id>>();
		dneMarkets = new List<Id>();

		Set<Id> dneMarketsSet = new Set<Id>();
		
		List<Agent_On_Market__c> agentsOnMarket = [SELECT Agent__c, Market__c 
												   FROM Agent_On_Market__c 
												   WHERE Agent__r.IsActive = true
												   AND Active__c = true];
		for(Agent_On_Market__c aom : agentsOnMarket)
		{
			Id theKey = aom.Agent__c;
			Set<Id> theValue;
			if(agent_MarketSet_Map.containsKey(theKey))
			{
				theValue = agent_MarketSet_Map.get(theKey);
			}
			else
			{
				theValue = new Set<Id>();
			}
			theValue.add(aom.Market__c);

			agent_MarketSet_Map.put(theKey,theValue);

			dneMarketsSet.add(aom.Market__c);
		}

		dneMarkets.addAll(dneMarketsSet);
	}
	
}
/*
Id client_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
client_RTId = 0120q000000O2LkAAK

// ==================== INCREASE Nb Of Accounts/Sales Agent ====================
List<User> agentList = [SELECT Id, Maximum_Number_of_Accounts__c FROM User WHERE IsActive = true AND Sales_Agent__c = true];
for(User agent : agentList)
{
    agent.Maximum_Number_of_Accounts__c += 10;
}
update agentList;

// ==================== Nb Of Accounts/Sales Agent ====================
SELECT count(Id) numAccounts, Owner.Name owner
FROM Account
WHERE RecordTypeId = '0120q000000O2LkAAK'
AND Status__c != 'Client'
AND Owner.Sales_Agent__c = true
GROUP BY Owner.Name

// ==================== DNE Markets ====================
List<Id> marketIdList = new List<Id>();
Set<Id> dneMarketsSet = new Set<Id>();
List<Agent_On_Market__c> agentsOnMarket = [SELECT Agent__c, Market__c 
										   FROM Agent_On_Market__c 
										   WHERE Active__c = true
										   AND Agent__r.IsActive = true];
for(Agent_On_Market__c aom : agentsOnMarket)
{
	dneMarketsSet.add(aom.Market__c);
}
marketIdList.addAll(dneMarketsSet);

// ==================== CREATE ACCOUNTS FOR TESTS ====================

AccountTriggerHelper.bypassTrigger = true;

List<Id> marketIdList = new List<Id>();
Set<Id> dneMarketsSet = new Set<Id>();
List<Agent_On_Market__c> agentsOnMarket = [SELECT Agent__c, Market__c 
										   FROM Agent_On_Market__c 
										   WHERE Active__c = true
										   AND Agent__r.IsActive = true];
for(Agent_On_Market__c aom : agentsOnMarket)
{
	dneMarketsSet.add(aom.Market__c);
}
marketIdList.addAll(dneMarketsSet);

List<Account> accountsToInsert = new List<Account>();

Integer marketCounter = 0;
for(Id marketId : marketIdList)
{
    Integer counter = 0;
    while(counter < 200)
    {
        Account acc = new Account();
        acc.RecordTypeId = '0120q000000O2LkAAK';
        acc.Name = '2019.05.03.Test Account no ' + counter + '-' + marketCounter;
        acc.Status__c = (Math.Mod(counter,2)==0?'Disconnected':'Not interested');
        acc.Business_Size__c = 'Small';
        acc.Market__c = marketId;
        acc.Last_Status_Change__c = Date.today().addDays(-100);        
        
        accountsToInsert.add(acc);
        counter++;
    }
    marketCounter++;
}

insert accountsToInsert;

System.debug('JTM - ' + accountsToInsert.size() + ' inserted.');

// ==================== DELETE ACCOUNTS FOR TESTS ====================

List<Account> accList = [SELECT Id FROM Account WHERE Name LIKE '2019.05.03.Test Account%'];
System.debug('JTM - deleted ' + accList.size() + ' Accounts');
delete accList;

*/