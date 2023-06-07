/**************************************************
* Class: FindOpportunityOpenerBatch
* Description: Batch class used to find mismatch opener and closer for opportunity
****************************************************/
global class FindOpportunityOpenerBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global FindOpportunityOpenerBatch(){
        query = 'SELECT Id,Closer__c,Is_Incorrect_Opener__c,Opener__c,Opportunity__c FROM Opportunity_opener__c';
    }
    // Batch Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    //Batch Execute Method
    global void execute(Database.BatchableContext BC, List<Opportunity_opener__c> opportunityOpeners){
        System.debug('opportunityOpeners^^' + opportunityOpeners.size());
        if(opportunityOpeners.size() > 0){
            List<Opportunity_opener__c> openersList = new List<Opportunity_opener__c>();
            for(Opportunity_opener__c oppOpeners : opportunityOpeners){
                if(oppOpeners.Opener__c != oppOpeners.Closer__c){
                    oppOpeners.Is_Incorrect_Opener__c = true;
                    openersList.add(oppOpeners);
                }
            }
            System.debug('openersList^^' + openersList.size());
            try{
                if(openersList.size() > 0){
                    UPDATE openersList;
                }
            }catch(Exception ex){
                System.debug('exception occured on updation ^^' + ex.getMessage());
            }
        }
    }
    // finish method
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('#### job^^' + job);
        System.debug('#### FindOpportunityOpenerBatch Finished.');
    }
}