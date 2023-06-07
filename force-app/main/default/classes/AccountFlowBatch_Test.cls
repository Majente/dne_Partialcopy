@isTest
private class AccountFlowBatch_Test 
{
    static FINAL Integer NB_OF_AGENTS = 2;
    static FINAL Integer MAX_NB_OF_ACCOUNTS_PER_USER = 100;
    static FINAL Integer MAX_NB_OF_LEADS_PER_USER = 1;
    static FINAL Integer NB_OF_ACCOUNTS = NB_OF_AGENTS * MAX_NB_OF_ACCOUNTS_PER_USER;
    static FINAL Integer NB_OF_SITES_PER_ACCOUNT = 3;
    static FINAL Integer NB_OF_CHILDREN_PER_ACCOUNT = 1;

    static FINAL String EMAIL_SUFFIX = '@dneLeadFlowTest.com';

    static public FINAL String CLIENT_RECORD_TYPE_NAME = 'Account';
    static public FINAL String MAX_DAYS_IN_COOLER_STATUS = 'Max_Days_in_Cooler_Status';
    static public FINAL String MAX_DAYS_IN_PROSPECT_STATUS = 'Max_Days_in_Prospect_Status';

    static Integer NB_OF_TESTING_SCENARIOS = 2;

    @testSetup
    static void createData()
    {
        AccountTriggerHelper.bypassTrigger = true;

        Integer maxDaysInCooler;
        Integer maxDaysInProspect;

        List<User> agentsToInsert = new List<User>();
        List<Account> accountsToInsert = new List<Account>();
        List<Task> tasksToInsert = new List<Task>();


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
        insert theManager;
        
        Integer counter = 0;
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
            
            agentsToInsert.add(theAgent);
            counter++;
        }
        insert agentsToInsert;

        // --------------- CREATING THE ACCOUNTS AND THE TASKS ---------------

        Id client_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(CLIENT_RECORD_TYPE_NAME).getRecordTypeId();
        
        // SCENARIO 1: has spend the maximum number of days in Cooler
        // query = '(Status__c = \'Cooler\' AND Last_Status_Change__c < :maxDatetimeInCooler) ';            // Status__c <= 'Prospect'
            
        /*
        counter = 0;
        while(counter < NB_OF_ACCOUNTS)
        {
            Account acc = new Account();
            acc.RecordTypeId = client_RTId;
            acc.Name = 'Account_v1 Test no ' + counter;
            acc.Status__c = 'Cooler';
            acc.Business_Size__c = 'Small';
            acc.Last_Status_Change__c = Date.today().addDays(-(maxDaysInCooler+5));
            acc.OwnerId = agentsToInsert.get(Math.mod(agentsToInsert.size(),NB_OF_AGENTS)).Id;

            accountsToInsert.add(acc);

            counter++;
        }
        insert accountsToInsert;
        // ---------------

        for(Account acc : accountsToInsert)
        {
            Task theTask = new Task();
            theTask.ActivityDate = Date.today().addDays(-(maxDaysInCooler+5));
            theTask.Status = 'Completed';
            theTask.Subject = 'Call';
            theTask.WhatId = acc.Id;
            tasksToInsert.add(theTask);
        }*/

        // SCENARIO 2 - // no Activities and has spend the maximum number of days in Prospect
        // query += '((Status__c = \'Prospect\' OR Status__c = \'Callback\') AND Last_Status_Change__c < :maxDatetimeInProspect AND LastActivityDate = null) ';// Status__c <= 'Cooler'     

        accountsToInsert = new List<Account>();
        counter = 0;

        while(counter < NB_OF_ACCOUNTS)
        {
            Account acc = new Account();
            acc.RecordTypeId = client_RTId;
            acc.Name = 'Account_v2 Test no ' + counter;
            if(Math.Mod(counter, 2)==0)
            {
                acc.Status__c = 'Prospect';
            }
            else
            {
                acc.Status__c = 'Prospect';
            }
            
            acc.Business_Size__c = 'Small';
            acc.Last_Status_Change__c = Date.today().addDays(-(maxDaysInProspect+5));
            acc.OwnerId = agentsToInsert.get(Math.mod(agentsToInsert.size(),NB_OF_AGENTS)).Id;

            accountsToInsert.add(acc);

            counter++;
        }
        insert accountsToInsert;

        // SCENARIO 3 - has Activities and the Last Activity date was more than "the maximum number of days in Prospect" days ago
        // query += 'OR ((Status__c = \'Prospect\' OR Status__c = \'Callback\') AND LastActivityDate != null AND LastActivityDate < :maxDateInProspect) ';// Status__c <= 'Cooler'
            

        accountsToInsert = new List<Account>();
        counter = 0;

        while(counter < NB_OF_ACCOUNTS)
        {
            Account acc = new Account();
            acc.RecordTypeId = client_RTId;
            acc.Name = 'Account_v3 Test no ' + counter;
            if(Math.Mod(counter, 2)==0)
            {
                acc.Status__c = 'Prospect';
            }
            else
            {
                acc.Status__c = 'Prospect';
            }
            acc.Business_Size__c = 'Small';
            acc.Last_Status_Change__c = Date.today().addDays(-(maxDaysInProspect+5));
            acc.OwnerId = agentsToInsert.get(Math.mod(agentsToInsert.size(),NB_OF_AGENTS)).Id;

            accountsToInsert.add(acc);

            counter++;
        }
        insert accountsToInsert;
        // ---------------

        for(Account acc : accountsToInsert)
        {
            Task theTask = new Task();
            theTask.ActivityDate = Date.today().addDays(-(maxDaysInProspect+5));
            theTask.Status = 'Completed';
            theTask.Subject = 'Call';
            theTask.WhatId = acc.Id;
            tasksToInsert.add(theTask);
        }

        // SCENARIO 4 - has Activities and the Last Activity date was more than "the maximum number of days in Progress" days ago
        // query = 'OR (Status__c = \'In Progress\' AND LastActivityDate != null AND LastActivityDate < :maxDatetimeInProgress) ';// Status__c <= 'Cooler'  
/*
        accountsToInsert = new List<Account>();
        counter = 0;

        while(counter < NB_OF_ACCOUNTS)
        {
            Account acc = new Account();
            acc.RecordTypeId = client_RTId;
            acc.Name = 'Account_v4 Test no ' + counter;
            acc.Status__c = 'In Progress';
            acc.Business_Size__c = 'Small';
            acc.Last_Status_Change__c = Date.today().addDays(-(maxDaysInProgress+5));
            acc.OwnerId = agentsToInsert.get(Math.mod(agentsToInsert.size(),NB_OF_AGENTS)).Id;

            accountsToInsert.add(acc);

            counter++;
        }
        insert accountsToInsert;
        // ---------------

        for(Account acc : accountsToInsert)
        {
            Task theTask = new Task();
            theTask.ActivityDate = Date.today().addDays(-(maxDaysInProgress+5));
            theTask.Status = 'Completed';
            theTask.Subject = 'Call';
            theTask.WhatId = acc.Id;
            tasksToInsert.add(theTask);
        }*/

        insert tasksToInsert;

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
                childAcc.Last_Status_Change__c = Date.today().addDays(-(maxDaysInProspect+5));
                childAcc.OwnerId = acc.OwnerId;

                childrenAccountList.add(childAcc);

                accCounter++;
            }
        }
        //insert siteList;
        insert childrenAccountList;
    }
    // =====================================================
    // =====================================================
    // =====================================================
    
    @isTest static void test_method_one() 
    {
        Integer batchSize = NB_OF_TESTING_SCENARIOS*NB_OF_ACCOUNTS;
        System.debug('JTM - NB_OF_TESTING_SCENARIOS = ' + NB_OF_TESTING_SCENARIOS);
        System.debug('JTM - NB_OF_ACCOUNTS = ' + NB_OF_ACCOUNTS);
        System.debug('JTM - batchSize = ' + batchSize);

        String query = 'SELECT Id, Name, LastActivityDate, Last_Status_Change__c, Owner.ManagerId, Status__c, ParentId FROM Account WHERE ParentId = null';
        //String query = 'SELECT Id, Name, LastActivityDate, Last_Status_Change__c, Owner.ManagerId, Status__c, ParentId FROM Account LIMIT :batchSize';

        /*
        List<Account> accountListBefore = [SELECT Id, Name, LastActivityDate, Last_Status_Change__c, Owner.ManagerId, Status__c, ParentId FROM Account];
        for(Account accBefore : accountListBefore)
        {
            if(accBefore.Name.contains('Account_v3 Test no 301'))
            {
                System.debug('JTM - accBefore = ' + accBefore);
            }
        }*/

        

        Test.startTest();
            AccountFlowBatch b = new AccountFlowBatch();
            Id batchJobId = Database.executeBatch(b, batchSize);
        Test.stopTest();

        List<Account> accountList = [SELECT Id, Name, LastActivityDate, Last_Status_Change__c, Owner.ManagerId, Status__c, ParentId 
                                     FROM Account 
                                     WHERE ParentId = null];
        for(Account accAfter : accountList)
        {
            if(accAfter.Name.contains('Account_v3 Test no 301'))
            {
                System.debug('JTM - accAfter(Test) = ' + accAfter);
            }
        }

        System.assertEquals(NB_OF_TESTING_SCENARIOS*NB_OF_ACCOUNTS, accountList.size());

        Integer counterScenario_1 = 0;
        Integer counterScenario_2 = 0;
        Integer counterScenario_3 = 0;
        Integer counterScenario_4 = 0;

        for(Account l : accountList)
        {
            /*if(l.Name.contains('Account_v1'))
            {
                System.assertEquals('Prospect', l.Status__c);
                counterScenario_1++;
            }
            else */if(l.Name.contains('Account_v2'))
            {
                System.assertEquals('Not interested', l.Status__c);
                counterScenario_2++;
            }
            else if(l.Name.contains('Account_v3'))
            {
                System.assertEquals('Not interested', l.Status__c);
                counterScenario_3++;
            }
            /*else if(l.Name.contains('Account_v4'))
            {
                System.assertEquals('Cooler', l.Status__c);
                counterScenario_4++;
            }*/
        }

        //System.assertEquals(NB_OF_ACCOUNTS,counterScenario_1);
        System.assertEquals(NB_OF_ACCOUNTS,counterScenario_2);
        System.assertEquals(NB_OF_ACCOUNTS,counterScenario_3);
        //System.assertEquals(NB_OF_ACCOUNTS,counterScenario_4);

        List<Account> childAccountList = [SELECT Id, OwnerId, Status__c, Parent.OwnerId, Parent.Status__c 
                                          FROM Account
                                          WHERE ParentId != null];
        for(Account acc : childAccountList)
        {
            System.assertEquals(acc.OwnerId, acc.Parent.OwnerId);
            System.assertEquals(acc.Status__c, acc.Parent.Status__c);
        }
    }
    
}