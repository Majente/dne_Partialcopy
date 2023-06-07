/*************************************************************
* Class: TaskTriggerHelper
* Author: Soljit <VW>
* Date: 2019-07-05
* Description: helper class for Task trigger to populate last activity date on parent
**************************************************************/
public class TaskTriggerHelper 
{
	/* 
	populates the field Account.DNE_Last_Activity_Date__c 
	and Lead.DNE_Last_Activity_Date__c
	with the value of Task.ActivityDate of the latest Task
	*/
	public static void populateDNELastActivityDate()
	{
		List<Id> parentAccountIdList = new List<Id>();
		List<Id> parentLeadIdList = new List<Id>();

		List<Task> taskList;
		if(Trigger.isDelete)
		{
			taskList = (List<Task>)Trigger.old;
		}
		else
		{
			taskList = (List<Task>)Trigger.new;
		}

		for(Task theTask : taskList)
		{
			// the Task is related to an Account
			if(theTask.WhatId != null)
			{
				String parentId = theTask.WhatId;
				if(parentId.startsWith('001'))
				{
					parentAccountIdList.add(theTask.WhatId);
				}
			}

			// the Task is related to a Lead
			else if(theTask.WhoId != null)
			{
				String parentId = theTask.WhoId;
				if(parentId.startsWith('00Q'))
				{
					parentLeadIdList.add(theTask.WhoId);
				}
			}
		}


		List<Account> parentAccountList = new List<Account>();

		if(!parentAccountIdList.isEmpty())
		{
			if(Trigger.isDelete)
			{
				parentAccountList = [SELECT Id, DNE_Last_Activity_Date__c, 
										    (SELECT ActivityDate 
										     FROM Tasks 
										     WHERE Id NOT IN :taskList
										     ORDER BY ActivityDate DESC) 
								     FROM Account 
								     WHERE Id IN :parentAccountIdList];
			}
			else
			{
				parentAccountList = [SELECT Id, DNE_Last_Activity_Date__c, 
										    (SELECT ActivityDate 
										     FROM Tasks 
										     ORDER BY ActivityDate DESC) 
								     FROM Account 
								     WHERE Id IN :parentAccountIdList];
			}
				
		}
			
		
		List<Lead> parentLeadList = new List<Lead>();
		if(!parentLeadIdList.isEmpty())
		{
			if(Trigger.isDelete)
			{
				parentLeadList = [SELECT Id, DNE_Last_Activity_Date__c, 
									     (SELECT ActivityDate
									      FROM Tasks 
										  WHERE Id NOT IN :taskList
									      ORDER BY ActivityDate DESC) 
							   	  FROM Lead 
							      WHERE Id IN :parentLeadIdList];
			}
			else
			{
				parentLeadList = [SELECT Id, DNE_Last_Activity_Date__c, 
									     (SELECT ActivityDate
									      FROM Tasks 
									      ORDER BY ActivityDate DESC) 
							   	  FROM Lead 
							      WHERE Id IN :parentLeadIdList];
			}
				
		}

		System.debug('JTM - parentLeadList = ' + parentLeadList);

		if(parentAccountList.isEmpty() && 
		   parentLeadList.isEmpty())
		{
			return;
		}

		List<sObject> recordsToUpdate = new List<sObject>();

		if(!parentAccountList.isEmpty())
		{
			for(Account acc : parentAccountList)
			{
				if(!acc.Tasks.isEmpty())
				{
					if(acc.DNE_Last_Activity_Date__c != acc.Tasks.get(0).ActivityDate)
					{
						acc.DNE_Last_Activity_Date__c = acc.Tasks.get(0).ActivityDate;
						recordsToUpdate.add(acc);
					}
				}
				else
				{
					acc.DNE_Last_Activity_Date__c = null;
					recordsToUpdate.add(acc);
				}
			}
		}

		if(!parentLeadList.isEmpty())
		{
			for(Lead theLead : parentLeadList)
			{
				if(!theLead.Tasks.isEmpty())
				{
					if(theLead.DNE_Last_Activity_Date__c != theLead.Tasks.get(0).ActivityDate)
					{
						theLead.DNE_Last_Activity_Date__c = theLead.Tasks.get(0).ActivityDate;
						recordsToUpdate.add(theLead);
					}
				}
				else
				{
					theLead.DNE_Last_Activity_Date__c = null;
					recordsToUpdate.add(theLead);
				}
			}
		}

		if(!recordsToUpdate.isEmpty())
		{
			update recordsToUpdate;
		}			
		
	}
    
    //Update task last activity date
    
    public static void lastActivityDate (List<Task> taskList){
        Map<id,opportunity> opps = new Map<id,opportunity>();
        for(Task tsk:taskList) {
            if(tsk.whatid != null && tsk.whatid.getsobjecttype() == opportunity.sobjecttype) {
                opps.put(tsk.whatid, new opportunity(id=tsk.whatid, last_updated_activity__c= tsk.lastmodifieddate ));
            }
        }
        update opps.values();
    }

}