/**************************************************
* Class: RenewalOpportunityBatch
* Author: Soljit <VW>
* Date: 2019-10-09
* Description: RenewalOpportunityBatch for renewal opportunity assign and create task
****************************************************/
global class RenewalOpportunityBatch implements Database.Batchable<sObject> {
    
    global List<String> errorMessages = new List<String>();
    global Date closeDateWithInNinety;
    global Date closeDateWithInSixty;
    global Date lastActivityDate; 
    global String renewalOppOwnerId;
    global String renewalOppOwnerName;
    global RenewalOppOwner__c renewalOppCusSetting;
    
    // Constructor
    global RenewalOpportunityBatch(){
    	
        if(RenewalOppOwner__c.getOrgDefaults() != null){
            renewalOppCusSetting = RenewalOppOwner__c.getOrgDefaults();
            renewalOppOwnerId = renewalOppCusSetting.OwnerId__c;
            renewalOppOwnerName = renewalOppCusSetting.Owner_Name__c;
            closeDateWithInNinety = Date.today().addDays((Integer)renewalOppCusSetting.First_Warning__c);
            closeDateWithInSixty = Date.today().addDays((Integer)renewalOppCusSetting.Second_Warning__c); 
            lastActivityDate = Date.today().addDays(-(Integer)renewalOppCusSetting.Third_Warning__c);
            
            System.debug('renewalOppOwnerId = ' + renewalOppOwnerId + ', renewalOppOwnerName = ' + renewalOppOwnerName + ', closeDateWithInNinety = ' + closeDateWithInNinety + ', closeDateWithInSixty = ' + closeDateWithInSixty + ', lastActivityDate = ' + lastActivityDate);
        }
    }
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
         String queryString = 'Select  id, Name, OwnerId, AccountId,Warning_Message_Sent__c,last_updated_activity__c, LastActivityDate, Owner.Email, CloseDate FROM opportunity';
         queryString += ' WHERE isClosed = false AND type = \'Renewal\' AND (Id = \'006030000023ihcAAA\' OR Id = \'006030000023ihXAAQ\' OR Id = \'006030000023ihSAAQ\')';
        
        // Return this list of opportunities, which will get passed to our execute() method below.
        return Database.getQueryLocator(queryString);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        system.debug('oppList:::::'+oppList);
        system.debug('oppList:::::'+oppList.size());
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<Task> taskList = new List<Task>();
        DateTime latestActivityDate;
        Date opportunityCloseDate;
        String TaskSubject;
        //Iterate all opportunities
        for(opportunity opp: oppList){
        	opportunityCloseDate = date.newinstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day());
        	// If opportunity in First warning stage ( close date with in 90 days)
        	if(opportunityCloseDate <= closeDateWithInNinety) {
        		Task tsk = new Task();
                tsk.ActivityDate = System.today();
                tsk.WhatId = opp.Id;
                tsk.IsReminderSet = True;
                tsk.ReminderDateTime = System.now() + 1;

        	    // Get latest  activity done date ( custom field on opporunity hold a modified task date and other update on standard fields)
        	    latestActivityDate = opp.LastActivityDate;
                
        	    if(opp.LastActivityDate == null || opp.last_updated_activity__c > opp.LastActivityDate){
        	 		latestActivityDate = opp.last_updated_activity__c;
        	 	}
                system.debug('latestActivityDate::::::'+latestActivityDate);
                system.debug('LastActivityDate::::::'+LastActivityDate);
                system.debug('oppclose date::::::'+opportunityCloseDate);
                system.debug('within60days::::::'+closeDateWithInSixty);
        	 	// Check for activities happen in last 30 days then transfer the opportunity to manager
        	 	system.debug('LastActivityDate& latest::::::'+ (latestActivityDate < lastActivityDate));
                system.debug('close vs 90::::::'+ (opportunityCloseDate <= closeDateWithInSixty));
                
        	 	if(( latestActivityDate == null || latestActivityDate < lastActivityDate ) || (opportunityCloseDate <= closeDateWithInSixty)) {
                     system.debug('in first If LIne 71::::::');
                    if(renewalOppOwnerId != null && opp.OwnerId <> renewalOppOwnerId){
                        system.debug('in second If LIne 73::::::');
                        opp.OwnerId = renewalOppOwnerId;
                        updateOppList.add(opp);
                        tsk.OwnerId = opp.OwnerId;
                        taskSubject =  'Opportunity "' + opp.Name + '" was transferred to "' + renewalOppOwnerName + '"';
                        tsk.Subject = TaskSubject.left(255);
                        taskList.add(tsk);  
                    }
                
                }else if(opp.OwnerId <> renewalOppOwnerId && opp.Warning_Message_Sent__c == false && renewalOppOwnerName != null){ // Warning task for initial opportunity owner
                    system.debug('in else If LIne 83::::::');
                    tsk.OwnerId = opp.OwnerId;
                    opp.Warning_Message_Sent__c = true; 
                    taskSubject = 'Opportunity "' + opp.Name + '" will be transferred to "' + renewalOppOwnerName + '"' + ' in 30 days if no activity is created ';
                    tsk.Subject = TaskSubject.left(255);
                    taskList.add(tsk); 
                    updateOppList.add(opp); 
                }
            }
        }
        
        System.debug('#### updateOppList.size() ::: ' + updateOppList.size());
        if(updateOppList.size()>0){
            Database.SaveResult[] srList = Database.update(updateOppList, false);
	        for (Database.SaveResult sr : srList) {
	            if (!sr.isSuccess()){
	                // Operation failed, so get all errors                
	                for(Database.Error err : sr.getErrors()) {
	                    System.debug('The following error has occurred.');                    
	                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
	                    System.debug('The fields that affected this error: ' + err.getFields());
	                }
	            }
	        }//End of for loop 
        }
        System.debug('#### taskList.size() ::: ' + taskList.size());
        if(taskList.size() >0 ){
           
            // DML statement
	        Database.SaveResult[] srList = Database.insert(taskList, false);
	        for (Database.SaveResult sr : srList) {
	            if (!sr.isSuccess()){
	                // Operation failed, so get all errors                
	                for(Database.Error err : sr.getErrors()) {
	                    System.debug('The following error has occurred.');                    
	                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
	                    System.debug('The fields that affected this error: ' + err.getFields());
	                }
	            }
	        }//End of for loop 
        }
    }
    
  
    
    //finish method
    global void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('#### job ::: ' + job);
        System.debug('#### RenewalOpportunityBatch completed successfully.');        
    }
}