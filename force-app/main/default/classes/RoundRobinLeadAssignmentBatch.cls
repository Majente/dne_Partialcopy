/**************************************************
* Class: RoundRobinLeadAssignmentBatch
* Author: Soljit <VW>
* Date: 2019-03-29
****************************************************/
global class RoundRobinLeadAssignmentBatch implements Database.Batchable<sObject>, Database.Stateful 
{	
	//public static FINAL String MAX_LEADS_PER_AGENT_MDT_NAME = 'Max_Nb_of_Leads_per_Agent';
	//public static FINAL String Leads_New_QUEUE_NAME = 'Leads_New';
	public static FINAL String DAYS_IN_COOLER = 'Days_in_Cooler';
	//Integer maxLeadsPerAgent;
	String emailAddress;

	String query;

	global Integer assignmentSuccesses = 0;
	global Integer assignmentErrors = 0;
	
	//List<User> agentList;
	global Map<Id,Integer> userId_NbOfLeads_Map;	// nb of Lead currently assigned to this Agent

	global Map<Id,Integer> userId_MaxNbOfLeads_Map;	// maximum nb of Leads that can be assigned to this Agent

	// Map<AgentId, Set<MarketId>>
	Map<Id,Set<Id>> agent_MarketSet_Map;
	List<Id> dneMarkets;
	string recId;
    Map<String,Id> queueMap {get;set;}
    Datetime maxDatetimeInCooler;
    /*********************************************************
    @Name 			: RoundRobinLeadAssignmentBatch
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
	global RoundRobinLeadAssignmentBatch() 
	{
		createAgentLeadMap();
		createAgentMarketMap();

		/*DNE_Numeric_Value__mdt maxNbOfLeadsMdt = [SELECT Value__c 
												  FROM DNE_Numeric_Value__mdt 
												  WHERE DeveloperName = :MAX_LEADS_PER_AGENT_MDT_NAME
												  LIMIT 1];
		maxLeadsPerAgent = Integer.valueOf(maxNbOfLeadsMdt.Value__c);*/
        List<Lead_Flow_Delays__mdt> leadDelays = [SELECT DeveloperName, Days__c 
                                                  FROM Lead_Flow_Delays__mdt];

		Integer daysInCooler;

		for(Lead_Flow_Delays__mdt lfd : leadDelays)
		{
			if(lfd.DeveloperName == DAYS_IN_COOLER)
			{
				daysInCooler = Integer.valueOf(lfd.Days__c);
			}
		}
		 maxDatetimeInCooler = Datetime.now().addDays(-daysInCooler);
        system.debug('maxDatetimeInCooler:::'+maxDatetimeInCooler);
		//-------------------

		queueMap = LeadTriggerHandler.queryLeadQueues(); 

		Id coolerQueueId = queueMap.get('Lead_Cooler');
		Id newLeadsQueueId = queueMap.get('Leads_New');

		query = 'SELECT Id, Market__c, Status, OwnerId ';
		query += 'FROM Lead ';
		query += 'WHERE (OwnerId = :newLeadsQueueId ';
		query += 'OR (OwnerId = :coolerQueueId AND Last_Assignment_Date__c <= :maxDatetimeInCooler)) ';
		query += 'AND Market__c IN :dneMarkets ';
		query += 'AND IsConverted = false ';
		query += 'ORDER BY Last_Assignment_Date__c ASC';
	}
	
    /*********************************************************
    @Name 			: RoundRobinLeadAssignmentBatch
    @Parameters 	: String emailAddr
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
	global RoundRobinLeadAssignmentBatch(String emailAddr) 
	{
		createAgentLeadMap();
		createAgentMarketMap();

		/*DNE_Numeric_Value__mdt maxNbOfLeadsMdt = [SELECT Value__c 
												  FROM DNE_Numeric_Value__mdt 
												  WHERE DeveloperName = :MAX_LEADS_PER_AGENT_MDT_NAME
												  LIMIT 1];
		maxLeadsPerAgent = Integer.valueOf(maxNbOfLeadsMdt.Value__c);*/

		emailAddress = emailAddr;
        List<Lead_Flow_Delays__mdt> leadDelays = [SELECT DeveloperName, Days__c 
                                                  FROM Lead_Flow_Delays__mdt];

		Integer daysInCooler;

		for(Lead_Flow_Delays__mdt lfd : leadDelays)
		{
			if(lfd.DeveloperName == DAYS_IN_COOLER)
			{
				daysInCooler = Integer.valueOf(lfd.Days__c);
			}
		}
		 maxDatetimeInCooler = Datetime.now().addDays(-daysInCooler);
        system.debug('maxDatetimeInCooler:::'+maxDatetimeInCooler);
		//-------------------

		queueMap = LeadTriggerHandler.queryLeadQueues(); 

		Id coolerQueueId = queueMap.get('Lead_Cooler');
		Id newLeadsQueueId = queueMap.get('Leads_New');

		query = 'SELECT Id, Market__c, Status, OwnerId ';
		query += 'FROM Lead ';
		query += 'WHERE (OwnerId = :newLeadsQueueId ';
		query += 'OR (OwnerId = :coolerQueueId AND Last_Assignment_Date__c <= :maxDatetimeInCooler)) ';
		query += 'AND Market__c IN :dneMarkets ';
		query += 'AND IsConverted = false ';
		query += 'ORDER BY Last_Assignment_Date__c ASC';
	}
	/*********************************************************
    @Name 			: RoundRobinLeadAssignmentBatch
    @Parameters 	: String RecordId
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
	global RoundRobinLeadAssignmentBatch(string tempId,String RecordId) 
	{
		createAgentLeadMap();
		createAgentMarketMap();
        recId = RecordId;
        List<Lead_Flow_Delays__mdt> leadDelays = [SELECT DeveloperName, Days__c 
                                                  FROM Lead_Flow_Delays__mdt];

		Integer daysInCooler;

		for(Lead_Flow_Delays__mdt lfd : leadDelays)
		{
			if(lfd.DeveloperName == DAYS_IN_COOLER)
			{
				daysInCooler = Integer.valueOf(lfd.Days__c);
			}
		}
	     maxDatetimeInCooler = Datetime.now().addDays(-daysInCooler);
        system.debug('maxDatetimeInCooler:::'+maxDatetimeInCooler);
		//-------------------

		queueMap = LeadTriggerHandler.queryLeadQueues(); 

		Id coolerQueueId = queueMap.get('Lead_Cooler');
		Id newLeadsQueueId = queueMap.get('Leads_New');

		query = 'SELECT Id, Market__c, Status, OwnerId ';
		query += 'FROM Lead ';
		query += 'WHERE (OwnerId = :newLeadsQueueId ';
		query += 'OR (OwnerId = :coolerQueueId AND Last_Assignment_Date__c <= :maxDatetimeInCooler)) ';
        query += ' AND Id =: recId ';
		query += 'AND Market__c IN :dneMarkets ';
		query += 'AND IsConverted = false ';
		query += 'ORDER BY Last_Assignment_Date__c ASC';
	}
     /*********************************************************
    @Name 			: start
    @Parameters 	: Database.BatchableContext BC
    @Reutrn type 	: Database.QueryLocator
    @Description 	: to get Lead_Flow_Delays__mdt metadata
	********************************************************/
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		Id coolerQueueId = queueMap.get('Lead_Cooler');
        Id newLeadsQueueId = queueMap.get('Leads_New');

		Database.QueryLocator dbQl = Database.getQueryLocator(query);
/*
		//===================>>>
		List<Lead> leadList = new List<Lead>();
		Database.QueryLocatorIterator it =  dbQl.iterator();
		// Iterate over the records
		while (it.hasNext())
		{
		    Lead a = (Lead)it.next();
		    leadList.add(a);
		}

		System.debug('JTM - leadList.size() = ' + leadList.size());
		System.debug('JTM - dneMarkets = ' + dneMarkets);
		// ================<<<
*/
		return dbQl;
	}
	
     /*********************************************************
    @Name 			: execute
    @Parameters 	: Database.BatchableContext BC, List<Lead> scope
    @Reutrn type 	: void
    @Description 	: update all the leads
	********************************************************/
   	global void execute(Database.BatchableContext BC, List<Lead> scope) 
   	{
   		System.debug('JTM - scope.size() = ' + scope.size());
		System.debug('JTM - userId_NbOfLeads_Map = ' + userId_NbOfLeads_Map);
   		List<Lead> leadsToUpdate = new List<Lead>();
   		List<Id> agentsToGetLeads = new List<Id>();
   		agentsToGetLeads.addAll(userId_NbOfLeads_Map.keySet());
        system.debug('scope:::'+scope);
        system.debug('agentsToGetLeads::::'+agentsToGetLeads);
   		for(Lead currentLead : scope)
		{
			// if all the Agents have the maximum nb of Leads, we stop the process
			if(!availableAgents())
			{
				break;
			}
			
			for(Integer i=0; i<agentsToGetLeads.size(); i++)
			{
				// don't laugh, we neew the index "i" later in the loop!!!
				Id thisAgentId = agentsToGetLeads.get(i);
                Integer maxLeadsPerThisAgent = userId_MaxNbOfLeads_Map.get(thisAgentId);
				
                system.debug('thisAgentId::::'+thisAgentId +'      maxLeadsPerThisAgent:::'+maxLeadsPerThisAgent);
                system.debug('currently Assigned leads:::'+userId_NbOfLeads_Map.get(thisAgentId));
				//if the agent already has the maximum number of leads, we skip him
				//if(userId_NbOfLeads_Map.get(thisAgentId) >= maxLeadsPerAgent)
				if(userId_NbOfLeads_Map.get(thisAgentId) >= maxLeadsPerThisAgent)
				{
					continue;
				}
				system.debug('currentLead.Market__c::'+currentLead.Market__c);
				// checking if the Agent is assigned to the Lead Market
				if(currentLead.Market__c != null)
				{
                   
					Set<Id> thisAgentMarketSet = agent_MarketSet_Map.get(thisAgentId);
					
                    system.debug('thisAgentMarketSet:::'+thisAgentMarketSet);
                    //system.debug('set contains Market:::'+thisAgentMarketSet.contains(currentLead.Market__c));
					if(thisAgentMarketSet==null || !thisAgentMarketSet.contains(currentLead.Market__c))
					{
                        system.debug('if set not contains');
						continue;
					}
				}

				// assign current Lead to the current Agent
				system.debug('thisAgentId:::'+thisAgentId);
				currentLead.OwnerId = thisAgentId;
				currentLead.Status = 'New';
				leadsToUpdate.add(currentLead);

				Integer newNbOfLeads = userId_NbOfLeads_Map.get(thisAgentId)+1;
				userId_NbOfLeads_Map.put(thisAgentId, newNbOfLeads);
				
				// the agent is removed and added back at the end of the list
				agentsToGetLeads.remove(i);
				//if(newNbOfLeads < maxLeadsPerAgent)
				if(newNbOfLeads < maxLeadsPerThisAgent)
				{
					agentsToGetLeads.add(thisAgentId);
				}
				
				break;
			}

						
		}

		System.debug('JTM - leadsToUpdate = ' + leadsToUpdate.size());


		List<Database.SaveResult> result = Database.update(leadsToUpdate, false);
		Integer counter = 0;
		for (Database.SaveResult sr : result)
		{
		    if (sr.isSuccess())
		    {
		    	assignmentSuccesses++;
		    }
		    else
		    {
		    	assignmentErrors++;
		    }
		}
	}
	
    /*********************************************************
    @Name 			: finish
    @Parameters 	: Database.BatchableContext BC
    @Reutrn type 	: void
    @Description 	: send an email
	********************************************************/
	global void finish(Database.BatchableContext BC) 
	{
		String emailSubject = 'Lead Assignment Batch has finished running';
		String emailBody = 'Batch execution summary: ' + assignmentSuccesses + ' Leads successfully assigned and ' + assignmentErrors + ' Leads failed to assign';
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
                System.debug('RoundRobinLeadAssignmentBatch - EMAIL SENT');
            }
            catch(Exception e)
            {
            	System.debug('RoundRobinLeadAssignmentBatch - Error sending email: ' + e.getMessage());
            }
		}
	}

	// ==================================================================
	// ========================= HELPER METHODS =========================
	// ==================================================================

    /*********************************************************
    @Name 			: availableAgents
    @Parameters 	: 
    @Reutrn type 	: Boolean
    @Description 	: to check available agents
	********************************************************/
	private Boolean availableAgents()
	{
		for(Id agentId : userId_NbOfLeads_Map.keySet())
		{
			Integer leadsPerThisAgent = userId_NbOfLeads_Map.get(agentId);
			Integer maxLeadsPerThisAgent = userId_MaxNbOfLeads_Map.get(agentId);
            system.debug('leadsPerThisAgent:::'+leadsPerThisAgent);
            system.debug('maxLeadsPerThisAgent::::'+maxLeadsPerThisAgent);
			if(leadsPerThisAgent < maxLeadsPerThisAgent)
			{
				return true;
			}
		}
		return false;
		/*
		for(Integer leadsPerAgent : userId_NbOfLeads_Map.values())
		{
			if(leadsPerAgent < maxLeadsPerAgent)
			{
				return true;
			}
		}
		return false;
		*/
	}
	
    /*********************************************************
    @Name 			: createAgentMarketMap
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: create agent market
	********************************************************/
	private void createAgentMarketMap()
	{
		// Map<AgentId, Set<MarketId>>
		agent_MarketSet_Map = new Map<Id,Set<Id>>();
		dneMarkets = new List<Id>();

		Set<Id> dneMarketsSet = new Set<Id>();
		
		List<Agent_On_Market__c> agentsOnMarket = [SELECT Agent__c, Market__c 
												   FROM Agent_On_Market__c WHERE Active__c = true
												   AND Agent__r.IsActive = true];
        system.debug('agentsOnMarket ::'+agentsOnMarket);
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
system.debug('agent_MarketSet_Map:::'+agent_MarketSet_Map);
		dneMarkets.addAll(dneMarketsSet);
	}
	
    /*********************************************************
    @Name 			: createAgentLeadMap
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: create agent Lead
	********************************************************/
	private void createAgentLeadMap()
	{
        system.debug('createAgentLeadmap Method Start::');
		userId_NbOfLeads_Map = new Map<Id,Integer>();
		userId_MaxNbOfLeads_Map = new Map<Id,Integer>();
		List<User> agentList;

		String testEmailSuffix = '%' + RoundRobinLeadAssignmentBatch_Test.EMAIL_SUFFIX + '%';

		if(Test.isRunningTest())
		{
			agentList = [SELECT Id, Maximum_Number_of_Leads__c 
                         FROM User WHERE IsActive = true AND Sales_Agent__c = true AND Email LIKE :testEmailSuffix];
		}
		else
		{
			agentList = [SELECT Id, Maximum_Number_of_Leads__c 
                         FROM User WHERE IsActive = true AND Sales_Agent__c = true];
		}
		System.debug('agentList:::::'+agentList);
        
		for(User agent : agentList)
		{
			userId_NbOfLeads_Map.put(agent.Id, 0);
			userId_MaxNbOfLeads_Map.put(agent.Id, Integer.valueOf(agent.Maximum_Number_of_Leads__c));
		}
		system.debug('userId_NbOfLeads_Map:::'+userId_NbOfLeads_Map);
        system.debug('userId_MaxNbOfLeads_Map::'+userId_MaxNbOfLeads_Map);
        
		List<AggregateResult> aggResList = [SELECT count(Id) numLeads, OwnerId owner
		      						   		FROM Lead WHERE OwnerId IN :agentList
		      						   		AND IsConverted = false
		      						   		GROUP BY OwnerId];
        system.debug('aggResList::'+aggResList);
		
		for (AggregateResult aggRes : aggResList) 
		{
		    Id theKey = (Id) aggRes.get('owner');
		    Integer theValue = (Integer) aggRes.get('numLeads');
		    Integer maxLeadsPerThisAgent = userId_MaxNbOfLeads_Map.get(theKey);
            system.debug('theValue:::'+theValue);
            system.debug('maxLeadsPerThisAgent:::'+maxLeadsPerThisAgent);
		    //if(theValue < maxLeadsPerAgent)
		    if(theValue < maxLeadsPerThisAgent)
		    {
		    	userId_NbOfLeads_Map.put(theKey, theValue);
		    }
		    else
		    {
		    	userId_NbOfLeads_Map.remove(theKey);
		    }
		}
	}
	// ---------------------------------------------------	

	// refresh the list on Agents to get Leads (keeping only those having less than maximum allowed)
	/*private List<Id> refreshAgentList()
	{
		List<Id> agentsToGetLeads = new List<Id>();
		for(Id agentId : userId_NbOfLeads_Map.keySet())
		{
			if(userId_NbOfLeads_Map.get(agentId) < maxLeadsPerAgent)
			{
				agentsToGetLeads.add(agentId);
			}
		}
		return agentsToGetLeads;
	}*/
}
/*
	=============== Nb of LEADS by Owner ===============
SELECT count(Id) numLeads, Owner.Name owner
FROM Lead
GROUP BY Owner.Name


	=============== Increase max nb of leads / Agent ===============
List<User> agentList = [SELECT Id, Maximum_Number_of_Leads__c FROM User WHERE IsActive = true AND Sales_Agent__c = true];
for(User agent : agentList)
{
    agent.Maximum_Number_of_Leads__c += 10;
}
update agentList;

	=============== Put to the Ready_Queue all Leads belonging to a certain User ===============
Map<String,Id> queueMap = LeadTriggerHandler.queryLeadQueues();
Id newLeadsQueueId = queueMap.get('Leads_New');
 	// Soljit Team
List<Lead> leadList = [SELECT Id 
                       FROM Lead 
                       WHERE OwnerId = '005f40000041tTAAAY'
                       AND IsConverted = false 
                       LIMIT 3000];
for(Lead theLead : leadList)
{
    theLead.Status = 'New';
    theLead.OwnerId = newLeadsQueueId;
}
update leadList;

System.debug('JTM - ' + leadList.size() + ' Leads converted');

================== ASSIGNING LEADS TO THE MARKETS WHERE DNE HAS AGENTS ========================

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

Map<String,Id> queueMap = LeadTriggerHandler.queryLeadQueues();
Id newLeadsQueueId = queueMap.get('Leads_New'); //00G0q000001JJukEAG
// Alberta market Id = a1K0q000000qDc4EAE
List<Lead> leadList = [SELECT Id, Market__c
                       FROM Lead 
                       WHERE OwnerId = :newLeadsQueueId
                       AND IsConverted = false 
                       AND Market__c NOT IN :marketIdList 
                       LIMIT 2000];

Integer counter = 0;
for(Lead theLead : leadList)
{
    theLead.Market__c = marketIdList.get(Math.Mod(counter, marketIdList.size()));
    counter++;
}
update leadList;
System.debug('JTM - leadList.size() = ' + leadList.size());

*/


/*

================== COUNT LEADS ASSIGNED TO SALES AGENTS ========================

SELECT Owner.Name owner, count(Id) numLeads
FROM Lead
WHERE OwnerId IN (SELECT Id FROM User WHERE Profile.Name = 'Sales Agent')
GROUP BY Owner.Name

================== LEADS ASSIGNED TO SALES AGENTS ========================

SELECT Id, Market__c, Market__r.Name, Status, OwnerId, Owner.Name
FROM Lead 
WHERE OwnerId IN (SELECT Id FROM User WHERE Profile.Name = 'Sales Agent')

================== COUNT LEADS ASSIGNED TO SALES AGENTS ========================

SELECT Owner.Name owner, count(Id) numLeads
FROM Lead
WHERE OwnerId = '00G0q000001JJukEAG'
GROUP BY Owner.Name

================== LEADS IN READY_QUEUE ========================

SELECT Id, Market__c, Market__r.Name, Status, OwnerId, Owner.Name 
FROM Lead WHERE OwnerId = '00G0q000001JJukEAG'

================== TO PUT THE LEADS BACK IN READY_QUEUE ========================

List<Lead> leadList = [SELECT Id FROM Lead WHERE OwnerId IN (SELECT Id FROM User WHERE Profile.Name = 'Sales Agent')];
for(Lead theLead : leadList)
{
    //theLead.Status = 'Ready';
    theLead.OwnerId = '00G0q000001JJukEAG';
}
update leadList;

*/