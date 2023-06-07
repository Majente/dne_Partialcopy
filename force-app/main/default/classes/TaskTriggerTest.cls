/*************************************************************
* Class: TaskTriggerTest
* Author: Soljit <VW>
* Date: 2019-07-05
* Description: test class for task trigger
**************************************************************/
@isTest
private class TaskTriggerTest 
{
	public static FINAL String CLIENT_RECORD_TYPE_NAME = 'Account';
    public static FINAL Integer NB_OF_PARENT_RECORDS = 50;
    public static FINAL Integer NB_OF_TASKS_PER_PARENT = 4;

    public static List<Account> accountsToInsert;
    public static List<Lead> leadsToInsert;
    public static List<Task> tasksToInsert;
/*************************************************************
* Method Name : createTasks
* Description : method to create test data
**************************************************************/
    static void createTasks()
    {
        AccountTriggerHelper.bypassTrigger = true;
        accountsToInsert = new List<Account>();
        leadsToInsert = new List<Lead>();

        tasksToInsert = new List<Task>();

        // --------------- CREATING THE ACCOUNTS AND THE TASKS --------------- 

        Id client_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CLIENT_RECORD_TYPE_NAME).getRecordTypeId();
        
        accountsToInsert = new List<Account>();

        Integer counter = 0;
        while(counter < NB_OF_PARENT_RECORDS)
        {
            Account acc = new Account();
            acc.RecordTypeId = client_RTId;
            acc.Name = 'Account_v2 Test no ' + counter;
            acc.Status__c = 'Prospect';            
            acc.Business_Size__c = 'Small';
            acc.Last_Status_Change__c = Date.today().addDays(-5);

            accountsToInsert.add(acc);

            counter++;
        }

        insert accountsToInsert;

        

        for(Account acc : accountsToInsert)
        {
            Integer taskCounter = 0;
            while(taskCounter < NB_OF_TASKS_PER_PARENT)
            {
            	Task theTask = new Task();
	            theTask.ActivityDate = Date.today().addDays(100);
	            theTask.Status = 'Open';
	            theTask.Subject = 'Call';
	            theTask.WhatId = acc.Id;
	            tasksToInsert.add(theTask);
	            taskCounter++;
            }	            
        }

        counter = 0;
        while(counter < NB_OF_PARENT_RECORDS)
        {
            Lead theLead = new Lead();
			theLead.LastName = 'Lead_v2_' + counter;
			theLead.Status = 'Active';
			theLead.Company = 'Random Company Ltd';
			theLead.Last_Assignment_Date__c = Date.today().addDays(-5);
			leadsToInsert.add(theLead);

            counter++;
        }

        insert leadsToInsert;

        

        for(Lead l : leadsToInsert)
        {
            Integer taskCounter = 0;
            while(taskCounter < NB_OF_TASKS_PER_PARENT)
            {
            	Task theTask = new Task();
	            theTask.ActivityDate = Date.today().addDays(100);
	            theTask.Status = 'Open';
	            theTask.Subject = 'Call';
	            theTask.WhoId = l.Id;
	            tasksToInsert.add(theTask);
	            taskCounter++;
            }	            
        }
    }
	/*************************************************************
* Method Name : test_method_one
* Description : method to test task trigger to populate last activity date on parent data
**************************************************************/
	@isTest static void test_method_one() 
	{
		createTasks();

		// TESTING INSERT

		insert tasksToInsert;
		System.assertEquals(2*NB_OF_PARENT_RECORDS*NB_OF_TASKS_PER_PARENT, tasksToInsert.size());

		
		// TESTING UPDATE

		Date todayPlus300 = Date.today().addDays(300);
		List<Task> tasksToUpdate = new List<Task>();

		// we modify the Activity date for only one Task for each Lead and Account
		Set<Id> accountsAlreadyModified = new Set<Id>();
		Set<Id> leadsAlreadyModified = new Set<Id>();
		for(Task theTask : tasksToInsert)
		{
			if(accountsAlreadyModified.contains(theTask.WhatId) || 
				leadsAlreadyModified.contains(theTask.WhoId) 
			)
			{
				continue;
			}

			if(theTask.WhatId != null)
			{
				theTask.ActivityDate = todayPlus300;
				accountsAlreadyModified.add(theTask.WhatId);
				tasksToUpdate.add(theTask);
			}
			else if(theTask.WhoId != null)
			{
				theTask.ActivityDate = todayPlus300;
				leadsAlreadyModified.add(theTask.WhoId);
				tasksToUpdate.add(theTask);
			}
		}

		update tasksToUpdate;

		List<Account> updatedRelatedAccounts = 
									[SELECT Id, DNE_Last_Activity_Date__c 
								     FROM Account 
								     WHERE Id IN :accountsAlreadyModified];

		List<Lead> updatedRelatedLeads = 
									[SELECT Id, DNE_Last_Activity_Date__c
									 FROM Lead 
									 WHERE Id IN :leadsAlreadyModified];

		for(Account acc : updatedRelatedAccounts)
		{
			System.assertEquals(todayPlus300, acc.DNE_Last_Activity_Date__c);
		}

		for(Lead theLead : updatedRelatedLeads)
		{
			System.assertEquals(todayPlus300, theLead.DNE_Last_Activity_Date__c);
		}


		// TESTING DELETE

		delete tasksToInsert;

		for(Account acc : accountsToInsert)
		{
			System.assertEquals(null, acc.DNE_Last_Activity_Date__c);
		}

		for(Lead theLead : leadsToInsert)
		{
			System.assertEquals(null, theLead.DNE_Last_Activity_Date__c);
		}
	}
	
}