global class AccountFlowBatch implements Database.Batchable<sObject> 
{
	public FINAL String CLIENT_RECORD_TYPE_NAME = 'Account';
	public FINAL String MAX_DAYS_IN_COOLER_STATUS = 'Max_Days_in_Cooler_Status';
	public FINAL String MAX_DAYS_IN_PROSPECT_STATUS = 'Max_Days_in_Prospect_Status';

	public Integer maxDaysInCooler {get;set;}
	public Integer maxDaysInProspect {get;set;}

	Datetime maxDatetimeInCooler;
	Datetime maxDatetimeInProspect;
	Date maxDateInProspect;

	// Map<AccountId, List<children Account>>
	Map<Id, List<Account>> parentId_AccList_Map;

	String query;
	
	global AccountFlowBatch() 
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
	// =================================================
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		Id client_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CLIENT_RECORD_TYPE_NAME).getRecordTypeId();

		query = 'SELECT Id, Name, DNE_Last_Activity_Date__c, Last_Status_Change__c, Owner.ManagerId, Status__c ';
		query += 'FROM Account ';
		query += 'WHERE RecordTypeId = :client_RTId ';
		query += 'AND ParentId = null ';
		// AND start
		query += 'AND (';
			// no Activities and has spend the maximum number of days in Prospect 
			query += '((Status__c = \'Prospect\' OR Status__c = \'Callback\') AND Last_Status_Change__c < :maxDatetimeInProspect AND DNE_Last_Activity_Date__c = null) ';// Status__c <= 'Not interested'
			// has Activities and the Last Activity date was more than "the maximum number of days in Prospect" days ago
			query += 'OR ((Status__c = \'Prospect\' OR Status__c = \'Callback\') AND DNE_Last_Activity_Date__c != null AND DNE_Last_Activity_Date__c < :maxDateInProspect) ';// Status__c <= 'Not interested'
		// AND end
		query += ')';

		Database.QueryLocator dbQl = Database.getQueryLocator(query);

		return dbQl;
	}
	//------------------------------

   	global void execute(Database.BatchableContext BC, List<Account> scope) 
   	{
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

   		List<Account> accountsToUpdate = new List<Account>();
   		List<Site__c> sitesToUpdate = new List<Site__c>();

   		System.debug('JTM - execute');
		System.debug('JTM - parentId_AccList_Map. = ' + parentId_AccList_Map);

		for(Account acc : scope)
		{
			if(acc.Name.contains('Account_v3 Test no 3'))
			{
				System.debug('JTM (Batch) - accBefore = ' + acc);
			}

			Id managerId = acc.Owner.ManagerId;

			acc.Status__c = 'Not interested';
			if(managerId!=null)
			{
				acc.OwnerId = managerId;
			}
			accountsToUpdate.add(acc);

			System.debug('JTM - acc = ' + acc);

			List<Account> childrenAccounts = parentId_AccList_Map.get(acc.Id);

			if(childrenAccounts!=null && !childrenAccounts.isEmpty())
			{
				for(Account childAcc : childrenAccounts)
				{
					if(managerId!=null)
					{
						childAcc.OwnerId = managerId;
					}
					childAcc.Status__c = 'Not interested';
					accountsToUpdate.add(childAcc);
				}
			}

			if(acc.Name.contains('Account_v3 Test no 3'))
			{
				System.debug('JTM - accAfter = ' + acc);
			}
		}

		System.debug('JTM - accountsToUpdate = ' + accountsToUpdate.size());
		update accountsToUpdate;
   	}
	//------------------------------
	
	global void finish(Database.BatchableContext BC) 
	{
		System.debug('JTM - finish');
	}
}