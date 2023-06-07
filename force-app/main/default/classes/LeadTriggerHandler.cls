/**************************************************
* Class: LeadTriggerHandler
* Author: Soljit <VW>
* Date: 2019-03-27
****************************************************/
public with sharing class LeadTriggerHandler 
{	
    /*********************************************************
    @Name 			: onOwnerUpdate
    @Parameters 	: List<Lead>:newVersionList, Map<String,Id>:queueMap
    @Reutrn type 	: void
    @Description 	: update owner
	********************************************************/
	public static void onOwnerUpdate(List<Lead> newVersionList, Map<String,Id> queueMap)
	{
		Id coolerQueueId = queueMap.get('Lead_Cooler');
		Id newLeadQueueId = queueMap.get('Leads_New');
		Id doNotCallQueueId = queueMap.get('Lead_Do_Not_Call');

		for(Lead newVersion : newVersionList)
		{
			if(Trigger.isInsert)
			{
				// set last assignment datetime
				if(!Test.isRunningTest())
					newVersion.Last_Assignment_Date__c = Datetime.now();

				// if the Lead was just assigned to a User, the Status is set to 'Active'
				/*if(String.valueOf(newVersion.OwnerId).startsWith('005'))
				{
					newVersion.Status = 'Active';	
				}*/

				//if the Lead was put in cooler_queue, the status will be either 'Disconnected' or 'Not interested'
				if(newVersion.OwnerId == coolerQueueId)
				{
					if(newVersion.Status != 'Disconnected')
					{
						newVersion.Status = 'Not interested';	
					}
				}

				//if the Lead was put in doNotCall_queue, the status will be 'Do Not Call'
				if(newVersion.OwnerId == doNotCallQueueId)
				{
					newVersion.Status = 'Do Not Call';
				}

				//if the Lead was put in ready_queue, the status will be 'New'
				if(newVersion.OwnerId == newLeadQueueId)
				{
					newVersion.Status = 'New';
				}
			}
			//---------------------------

			if(Trigger.isUpdate)
			{
				Lead oldVersion = (Lead)Trigger.oldMap.get(newVersion.Id);
				// if the Lead Owner was just changed
				if(oldVersion.OwnerId != newVersion.OwnerId)
				{
					// set last assignment datetime
					if(!Test.isRunningTest())
					{
						newVersion.Last_Assignment_Date__c = Datetime.now();
					}

					// if the Lead was transfered from a queue to a User, the Status will be 'Active'
					/*if(!String.valueOf(oldVersion.OwnerId).startsWith('005') && 
					   String.valueOf(newVersion.OwnerId).startsWith('005'))
					{
						newVersion.Status = 'Active';	
					}*/

					//if the Lead was put in cooler_queue, the status will be either 'Disconnected' or 'Not interested'
					if(newVersion.OwnerId == coolerQueueId)
					{
						if(newVersion.Status != 'Disconnected')
						{
							newVersion.Status = 'Not interested';	
						}
					}
					//if the Lead was put in doNotCall_queue, the status will be 'Do Not Call'
					if(newVersion.OwnerId == doNotCallQueueId)
					{
						newVersion.Status = 'Do Not Call';
					}

					//if the Lead was put in ready_queue, the status will be 'New'
					if(newVersion.OwnerId == newLeadQueueId)
					{
						newVersion.Status = 'New';
					}
				}
                system.debug('newVersion'+newVersion.Status);
			}			
		}
	}

    /*********************************************************
    @Name 			: onStatusUpdate
    @Parameters 	: List<Lead>:newVersionList, Map<String,Id>:queueMap
    @Reutrn type 	: void
    @Description 	: status update
	********************************************************/
	public static void onStatusUpdate(List<Lead> newVersionList, Map<String,Id> queueMap)
	{
		System.debug('JTM - onStatusUpdate - FIRED');
		Id coolerQueueId = queueMap.get('Lead_Cooler');
		Id doNotCallQueueId = queueMap.get('Lead_Do_Not_Call');
		Id newLeadQueueId = queueMap.get('Leads_New');
		Id notServiceableLeadQueueId = queueMap.get('Not_Serviceable_Leads');
		
		for(Lead newVersion : newVersionList)
		{
			if(Trigger.isInsert)
			{
				if(newVersion.Status=='Not interested' || newVersion.Status=='Disconnected')
				{
					newVersion.OwnerId = notServiceableLeadQueueId;
				}
				else if(newVersion.Status == 'Do Not Call')
				{
					newVersion.OwnerId = doNotCallQueueId;
				}
				else if(newVersion.Status == 'Not Serviceable')
				{
					newVersion.OwnerId = notServiceableLeadQueueId;
				}
				/*else if(newVersion.Status == 'New')
				{
					newVersion.OwnerId = newLeadQueueId;
				}*/
			}
			//-----------------

			if(Trigger.isUpdate)
			{
				System.debug('JTM - onStatusUpdate - isUpdate');
				Lead oldVersion = (Lead)Trigger.oldMap.get(newVersion.Id);
				// if the Lead Owner was just changed
				if(oldVersion.Status != newVersion.Status)
				{
					if(newVersion.Status=='Not interested' || newVersion.Status=='Disconnected')
					{
						newVersion.OwnerId = notServiceableLeadQueueId;
						System.debug('JTM - onStatusUpdate - changing to ' + newVersion.Status);
					}
					else if(newVersion.Status == 'Do Not Call')
					{
						newVersion.OwnerId = doNotCallQueueId;
						System.debug('JTM - onStatusUpdate - changing to ' + newVersion.Status);
					}
					else if(newVersion.Status == 'Not Serviceable')
					{
						newVersion.OwnerId = notServiceableLeadQueueId;
						System.debug('JTM - onStatusUpdate - changing to ' + newVersion.Status);
					}
					/*else if(newVersion.Status == 'New')
					{
						newVersion.OwnerId = newLeadQueueId;
					}*/
					
					if(newVersion.Status != 'With Competitor')
					{
						newVersion.Competitor__c = null;
						newVersion.Call_Back_Date__c = null;
						newVersion.End_Date_of_Contract__c = null;
					}
				}
			}				
		}
	}
	//----------------------------------------
/*********************************************************
    @Name 			: queryLeadQueues
    @Parameters 	: Map<String,Id>
    @Reutrn type 	: void
    @Description 	: get lead queue
	********************************************************/
	public static Map<String,Id> queryLeadQueues()
	{
		List<Group> queueList = [SELECT Id, DeveloperName 
                                 FROM Group WHERE Type = 'Queue'];
		Map<String,Id> queueMap = new Map<String,Id>();
		for(Group theQueue : queueList)
		{
			queueMap.put(theQueue.DeveloperName, theQueue.Id);
		}
		return queueMap;
	}
	/*********************************************************
    @Name 			: createCallbackEvent
    @Parameters 	: List<Lead>:newVersionList
    @Reutrn type 	: void
    @Description 	: 
	********************************************************/
    public static void createCallbackEvent(List<Lead> newVersionList)
	{
		List<Event> eventsToInsert = new List<Event>();
		for(Lead newVersion : newVersionList)
		{
			if(Trigger.isInsert)
			{
				if(newVersion.Status == 'With Competitor')
				{
					Event newEvent = createEventPattern(newVersion);
					eventsToInsert.add(newEvent);
				}
			}

			else if(Trigger.isUpdate)
			{
				Lead oldVersion = (Lead)Trigger.oldMap.get(newVersion.Id);

				if(oldVersion.Status != 'With Competitor' && 
				   newVersion.Status == 'With Competitor')
				{
					Event newEvent = createEventPattern(newVersion);
					eventsToInsert.add(newEvent);
				}
			}			
		}

		if(!eventsToInsert.isEmpty())
		{
			insert eventsToInsert;
		}
	}
	/*********************************************************
    @Name 			: createEventPattern
    @Parameters 	: Lead:theLead
    @Reutrn type 	: void
    @Description 	: 
	********************************************************/
	public static Event createEventPattern(Lead theLead)
	{
		Event newEvent = new Event();
		newEvent.StartDateTime = theLead.Call_Back_Date__c;
		newEvent.EndDateTime = theLead.Call_Back_Date__c.addMinutes(15);
		newEvent.Subject = System.Label.Lead_contract_with_competitor_label + theLead.End_Date_of_Contract__c + System.Label.Call_back_lead_label;
		newEvent.WhoId = theLead.Id;
		return newEvent;
	}
}
/*
1. When the Status is changed to "Cooler", the Lead is automatically assigned to the Cooler Queue
2. When a Lead is assigned to a User (not Queue), the status automatically changes to "Assigned" and all the Warning dates and checkboxes are reset
3. if the Status is set to "Assigned", the Owner must be a User, not a Queue
4. Only a Lead Manager can change the status of a Lead currently in one of the following statuses: 'Closed', 'Do Not Call'
5. Only a Lead Manager can transfer Lead 
*/