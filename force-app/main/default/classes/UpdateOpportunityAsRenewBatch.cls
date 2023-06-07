global class UpdateOpportunityAsRenewBatch implements Database.Batchable<sObject>,Database.Stateful{
    global String query;
    global String recordTypeName;
    global String recordId;
    global UpdateOpportunityAsRenewBatch(String recId){
        recordId = recId;
        recordTypeName = 'Account';
        query = 'SELECT Id,Name,RecordType.Name FROM Account WHERE RecordType.Name =: recordTypeName AND Id =: recordId';
    }
    // Batch Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    //Batch Execute Method
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        System.debug('accountList^^' + accountList.size());
        if(accountList.size() > 0){
            Set<Id> acctIds = new Set<Id>();
            Map<String,Map<String,List<Opportunity>>> opportunityMap = new Map<String,Map<String,List<Opportunity>>>();
            Map<Id,String> opportunitySiteMap = new Map<Id,String>();
            Map<String,Set<Id>> sitesWithOppMap = new Map<String,Set<Id>>();
            Map<Id,Opportunity> oppTobeUpdateMap = new Map<Id,Opportunity>();
            Map<Id,Opportunity> opportunityIdsMap = new Map<Id,Opportunity>();
            for(Account acct : accountList){
                acctIds.add(acct.Id);
            }
            System.debug('acctIds^^' + acctIds.size());
            if(acctIds.size() > 0){
                for(Opportunity opp : [SELECT Id,Name,Commodity_Type__c,Flow_Date__c,SBQQ__Renewal__c FROM Opportunity WHERE 
                                       AccountId IN: acctIds AND Commodity_Type__c != null AND Flow_Date__c != null 
                                       ORDER BY Flow_Date__c ASC]){
                                           opportunityIdsMap.put(opp.Id,opp);
                                       }
                
                System.debug('opportunityIdsMap^^' + opportunityIdsMap.size());
                if(opportunityIdsMap.size() > 0){
                    for(Opportunity_Site__c oppSite : [SELECT Id,Opportunity__c,Site__c,Site__r.Name FROM Opportunity_Site__c 
                                                       WHERE Opportunity__c IN: opportunityIdsMap.keySet() AND Site__c != null 
                                                       ORDER BY Site__r.Name ASC]){
                                                           if(!opportunitySiteMap.containsKey(oppSite.Opportunity__c)){
                                                               opportunitySiteMap.put(oppSite.Opportunity__c,'');
                                                           }
                                                           String sites = opportunitySiteMap.get(oppSite.Opportunity__c);
                                                           sites += oppSite.Site__r.Name + ',';
                                                           opportunitySiteMap.put(oppSite.Opportunity__c,sites);
                                                           
                                                       }
                }
                System.debug('opportunitySiteMap^^' + JSON.serialize(opportunitySiteMap));
                for(String oppId : opportunityIdsMap.keySet()){
                    if(opportunitySiteMap.containsKey(oppId)){
                        String sites = opportunitySiteMap.get(oppId);
                        if(!opportunityMap.containsKey(sites)){
                            opportunityMap.put(sites,new Map<String,List<Opportunity>>());
                        }
                        Map<String,List<Opportunity>> oppWithCommodity = opportunityMap.get(sites);
                        Opportunity oppRec = opportunityIdsMap.get(oppId);
                        if(!oppWithCommodity.containsKey(oppRec.Commodity_Type__c)){
                            oppWithCommodity.put(oppRec.Commodity_Type__c,new List<Opportunity>());
                        }
                        oppWithCommodity.get(oppRec.Commodity_Type__c).add(oppRec);
                        opportunityMap.put(sites,oppWithCommodity);
                    }
                }
                System.debug('opportunityMap^^' + JSON.serialize(opportunityMap));
                if(opportunityMap.size() > 0){
                    for(String sites : opportunityMap.keySet()){
                        Map<String,List<Opportunity>> opptMap = opportunityMap.get(sites);
                        for(String commodityType : opptMap.keySet()){
                            List<Opportunity> opptList = opptMap.get(commodityType);
                            if(opptList.size() > 1){
                                opptList[0].SBQQ__Renewal__c = true;
                                oppTobeUpdateMap.put(opptList[0].Id,opptList[0]);
                            }
                        }
                    }
                }
                
                System.debug('oppTobeUpdateMap^^' + oppTobeUpdateMap.size());
                try{
                    if(oppTobeUpdateMap.size() > 0){
                        UPDATE oppTobeUpdateMap.values();
                        System.debug('success');
                    }
                }catch(Exception ex){
                    System.debug('exception occured on update^^' + ex.getMessage());
                }
            }
            
        }
    }
    // Finish Method
    global void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('#### job ::: ' + job);
        System.debug('#### UpdateOpportunityAsRenewBatch Finished.');
    }
}