/**************************************************
* Class: FindContractForActivationBatch
* Description: Batch class used to find contracts that needs to be activated
****************************************************/
global class FindContractForActivationBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global String oppStage;    
    global FindContractForActivationBatch(){
        oppStage = 'Closed Won';
        query = 'SELECT Id,Name,Flow_Date__c,Subscription_Term__c FROM Opportunity WHERE Subscription_Term__c != null AND Flow_Date__c != null AND StageName =: oppStage';
    }
    // Batch Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    //Batch Execute Method
    global void execute(Database.BatchableContext BC, List<Opportunity> opportList){
        System.debug('opportList^^' + opportList.size());
        if(opportList.size() > 0){
            Map<Id,Opportunity> closedOppMap = new Map<Id,Opportunity>();
            Map<Id,List<OpportunityLineItem>> oppLineItemMap = new Map<Id,List<OpportunityLineItem>>();
            Map<Id,Contract> contractMap = new Map<Id,Contract>();
            Map<Id,List<SBQQ__Subscription__c>> subscriptionMap = new Map<Id,List<SBQQ__Subscription__c>>();
            Set<Id> contractIds = new Set<Id>();
            List<Contract> contractsToBeActivate = new List<Contract>();
            for(Opportunity opp : opportList){
                closedOppMap.put(opp.Id,opp);
            }
            System.debug('closedOppMap^^' + closedOppMap.size());
            if(closedOppMap.size() > 0){
                // get opportunity products related to opportunities
                for(OpportunityLineItem oli : [SELECT Id,OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN: 
                                               closedOppMap.keySet()]){
                                                   if(!oppLineItemMap.containsKey(oli.OpportunityId)){
                                                       oppLineItemMap.put(oli.OpportunityId,new List<OpportunityLineItem>());
                                                   }
                                                   oppLineItemMap.get(oli.OpportunityId).add(oli);
                                               }
                System.debug('oppLineItemMap^^' + oppLineItemMap.size());
                // get contracts related to opportunities which are not activated
                for(Contract cont : [SELECT Id,SBQQ__Opportunity__c,Status,Is_Ready_For_Activate__c FROM Contract WHERE SBQQ__Opportunity__c IN:
                                     closedOppMap.keySet() AND Status != 'Activated' AND Status != 'Revenue Received'
                                     AND Status != 'Cancelled']){
                                         contractMap.put(cont.SBQQ__Opportunity__c,cont);
                                         contractIds.add(cont.Id);
                                     }
                System.debug('contractMap^^' + contractMap.size());
                System.debug('contractIds^^' + contractIds.size());
                if(contractIds.size() > 0){
                    // get subscriptions related to contracts
                    for(SBQQ__Subscription__c subs : [SELECT Id,SBQQ__Contract__c,Site__c,SBQQ__QuoteLine__c FROM SBQQ__Subscription__c 
                                                      WHERE SBQQ__Contract__c IN: contractIds AND Site__c != null AND SBQQ__QuoteLine__c != null]){
                                                          if(!subscriptionMap.containsKey(subs.SBQQ__Contract__c)){
                                                              subscriptionMap.put(subs.SBQQ__Contract__c,new List<SBQQ__Subscription__c>());
                                                          }
                                                          subscriptionMap.get(subs.SBQQ__Contract__c).add(subs);
                                                      }
                }
                System.debug('subscriptionMap^^' + subscriptionMap.size());
                for(Opportunity oppt : closedOppMap.values()){
                    if(contractMap.containsKey(oppt.Id)){
                        Contract cont = contractMap.get(oppt.Id);
                        if(oppLineItemMap.containsKey(oppt.Id) && subscriptionMap.containsKey(cont.Id)){
                            if(oppLineItemMap.get(oppt.Id).size() == subscriptionMap.get(cont.Id).size()){
                                cont.Is_Ready_For_Activate__c = true;
                                contractsToBeActivate.add(cont);
                            }
                        }
                    }
                }
                System.debug('contractsToBeActivate^^' + contractsToBeActivate.size());
                try{
                    if(contractsToBeActivate.size() > 0){
                        UPDATE contractsToBeActivate;
                        System.debug('success');
                    }
                }catch(Exception ex){
                    System.debug('exception occured on contract updation^^' + ex.getMessage());
                }
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
        System.debug('#### FindContractForActivationBatch Finished.');
    }
}