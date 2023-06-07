/**************************************************
* Class: LeadFlowBatch
* Author: Soljit <MJ>
* Date: JUNE 2020
* Description: batch class for assigning leads

****************************************************/ 
global class LeadFlowBatch implements Database.Batchable<sObject>, Database.Stateful 
{
    public FINAL String MAX_DAYS_NO_ACTIVITY = 'Max_Days_No_Activity';
    
    public Integer maxDaysNoActivity {get;set;}
    Datetime maxDatetimeNoActivity;
    Date maxDateNoActivity;
    
    global Integer assignmentSuccesses = 0;
    global Integer assignmentErrors = 0;
    
    private List<String> emailAddresses;
    
    Integer deletionErrors = 0;
    Integer deletionSuccess = 0;
    String query;
    String recId;
    
    Map<String,Id> queueMap {get;set;}
    
    //---------------------------------------------------
    
    public LeadFlowBatch()
    {
        queueMap = LeadTriggerHandler.queryLeadQueues();
        
        List<Lead_Flow_Delays__mdt> leadDelays = [SELECT DeveloperName, Days__c FROM Lead_Flow_Delays__mdt];
        
        for(Lead_Flow_Delays__mdt lfd : leadDelays)
        {
            if(lfd.DeveloperName == MAX_DAYS_NO_ACTIVITY)
            {
                maxDaysNoActivity = Integer.valueOf(lfd.Days__c);
            }
        }
        
        emailAddresses = new List<String>();
        
        List<DNE_Email_Receiver__mdt> emailReceiversMdt = [SELECT Context__c, Email_Address__c 
                                                           FROM DNE_Email_Receiver__mdt 
                                                           WHERE Context__c = 'Lead Reassignment Batch'];
        
        for(DNE_Email_Receiver__mdt dneER : emailReceiversMdt)
        {
            emailAddresses.add(dneER.Email_Address__c);
        }
        
        maxDatetimeNoActivity = Datetime.now().addDays(-maxDaysNoActivity);
        maxDateNoActivity = maxDatetimeNoActivity.date();
        
        query = 'SELECT Id, LastName, Owner.Name, ';
        query += 'Last_Assignment_Date__c, ';
        query += 'Status, ';
        query += 'DNE_Last_Activity_Date__c, ';
        query += 'OwnerId ';
        query += 'FROM Lead ';
        query += 'WHERE (Status = \'New\')';
        // AND start
        query += 'AND (';
        // the Lead was assigned to the user more than "maxDaysNoActivity" days ago and no activity 
        query += '(Last_Assignment_Date__c != null AND Last_Assignment_Date__c < :maxDatetimeNoActivity) ';
        // the last activity on Lead was more than "maxDaysNoActivity" days ago
        query += 'OR (DNE_Last_Activity_Date__c != null AND DNE_Last_Activity_Date__c < :maxDateNoActivity) ';
        // AND end
        query += ')';
        query += 'AND Exclude_from_lead_flow__c = FALSE';
        
        System.debug('JTM - query = ' + query);
        
    }
    public LeadFlowBatch(string RecordId)
    {
        recId = RecordId;
        system.debug('recId :'+recId);
        queueMap = LeadTriggerHandler.queryLeadQueues();
        
        List<Lead_Flow_Delays__mdt> leadDelays = [SELECT DeveloperName, Days__c FROM Lead_Flow_Delays__mdt];
        
        for(Lead_Flow_Delays__mdt lfd : leadDelays)
        {
            if(lfd.DeveloperName == MAX_DAYS_NO_ACTIVITY)
            {
                maxDaysNoActivity = Integer.valueOf(lfd.Days__c);
            }
        }
        
        emailAddresses = new List<String>();
        
        List<DNE_Email_Receiver__mdt> emailReceiversMdt = [SELECT Context__c, Email_Address__c 
                                                           FROM DNE_Email_Receiver__mdt 
                                                           WHERE Context__c = 'Lead Reassignment Batch'];
        
        for(DNE_Email_Receiver__mdt dneER : emailReceiversMdt)
        {
            emailAddresses.add(dneER.Email_Address__c);
        }
        
        maxDatetimeNoActivity = Datetime.now().addDays(-maxDaysNoActivity);
        system.debug('maxDatetimeNoActivity ::'+maxDatetimeNoActivity);
        maxDateNoActivity = maxDatetimeNoActivity.date();
        system.debug('maxDateNoActivity ::'+maxDateNoActivity);
        
        query = 'SELECT Id, LastName, Owner.Name, ';
        query += 'Last_Assignment_Date__c, ';
        query += 'Status, ';
        query += 'DNE_Last_Activity_Date__c, ';
        query += 'OwnerId ';
        query += 'FROM Lead ';
        query += 'WHERE (Status = \'New\') ';
        // AND start
        query += 'AND Id =: recId ';
        query += 'AND (';
        // the Lead was assigned to the user more than "maxDaysNoActivity" days ago and no activity 
        query += '(Last_Assignment_Date__c != null AND Last_Assignment_Date__c < :maxDatetimeNoActivity) ';
        // the last activity on Lead was more than "maxDaysNoActivity" days ago
        query += 'OR (DNE_Last_Activity_Date__c != null AND DNE_Last_Activity_Date__c < :maxDateNoActivity) ';
        // AND end
        query += ')';
        query += ' AND Exclude_from_lead_flow__c = FALSE';
        
        System.debug('JTM - query = ' + query);
        
    }
    // start batch
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Id coolerQueueId = queueMap.get('Lead_Cooler');
        List<Id> queueIdList = queueMap.values();
        
        Database.QueryLocator dbQl = Database.getQueryLocator(query);
        system.debug('dbQl ::'+dbQl);
        //===================>>>
        List<Lead> leadList = new List<Lead>();
        Database.QueryLocatorIterator it =  dbQl.iterator();
        system.debug('it ::'+it);
        // Iterate over the records
        while (it.hasNext())
        {
            Lead a = (Lead)it.next();
            leadList.add(a);
        }
        
        System.debug('JTM - leadList.size() = ' + leadList.size());
        // ================<<<
        
        return dbQl;
    }
    //---------------------------------------------------
    // execute batch
    global void execute(Database.BatchableContext BC, List<Lead> scope) 
    {
        System.debug('JTM - running the batch');
        System.debug('JTM - scope.size() = ' + scope.size());
        Id newLeadQueueId = queueMap.get('Leads_New');
        
        Id coolerQueueId = queueMap.get('Lead_Cooler');
        
        //List<Lead> leadsToUpdate = new List<Lead>();
        
        for(Lead theLead : scope)
        {
            theLead.Status = 'New';
            theLead.OwnerId = newLeadQueueId;
        }
        
        //update leadsToUpdate;
        
        //System.debug('JTM - leadsToUpdate.size() = ' + leadsToUpdate.size());
        
        //if(!leadsToUpdate.isEmpty())
        //{
        List<Database.SaveResult> result = Database.update(scope, false);
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
        //}
    }
    // -----------------------------------------------------
    // finish batch
    global void finish(Database.BatchableContext BC) 
    {
        String emailSubject = 'Lead Reassignment Batch has finished running';
        String emailBody = 'Batch execution summary: ' + assignmentSuccesses + ' Leads successfully reassigned and ' + assignmentErrors + ' Leads failed to reassign';
        System.debug(emailBody);
        
        if(!emailAddresses.isEmpty())
        {
            List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();         
            // String[] toAddresses = new String[] {emailAddresses};         
            mail.setToAddresses(emailAddresses);        
            mail.setSubject(emailSubject);         
            mail.setHtmlBody(emailBody);
            
            singleEmailList.add(mail);
            
            try
            {
                Messaging.sendEmail(singleEmailList);
                System.debug('LeadFlowBatch - EMAIL SENT');
            }
            catch(Exception e)
            {
                System.debug('LeadFlowBatch - Error sending email: ' + e.getMessage());
            }
        }
    }
    
}