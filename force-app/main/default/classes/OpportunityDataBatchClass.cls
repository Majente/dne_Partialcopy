global class OpportunityDataBatchClass implements Database.Batchable<sObject> {    
    global String query;
    global string RecordId;
    global OpportunityDataBatchClass(String RecId){
        RecordId = RecId;
        query = 'SELECT Id, Name, Adder__c, Company_Name__c,IsAgainProceed__c, Contract_Price__c, Closer__c, Elec_Volume__c, End_Date__c, Gas_Volume__c, Opportunity_Name__c, Start_Date__c, Supplier__c, Opener__c, Type__c, Term__c, Unit__c FROM Opportunity_Data_Temp__c WHERE ID=: RecordId';
    }
    global OpportunityDataBatchClass(){
        query = 'SELECT Id, Name, Adder__c, Company_Name__c,IsAgainProceed__c, Contract_Price__c, Closer__c, Elec_Volume__c, End_Date__c, Gas_Volume__c, Opportunity_Name__c, Start_Date__c, Supplier__c, Opener__c, Type__c, Term__c, Unit__c FROM Opportunity_Data_Temp__c';
    }
   global Database.QueryLocator start(Database.BatchableContext BC) {
       return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity_Data_Temp__c> tempOppList){
        System.debug('tempOppList^^' + tempOppList.size());
        if(tempOppList.size() > 0){
            Set<String> oppNameSet = new Set<String>();
            Set<Id> opportunityIds = new Set<Id>();
            string ContType;
            Map<string,Opportunity_Data_Temp__c> opportunityTempToBeUpdate = new Map<string,Opportunity_Data_Temp__c>();
            Map<String,Set<String>> oppNameIdMap = new Map<String,Set<String>>();
            Map<String,List<Contract>> contractMap = new Map<String,List<Contract>>();
            for(Opportunity_Data_Temp__c tempData : tempOppList){
                String oppName = tempData.Opportunity_Name__c.toUppercase();
                oppNameSet.add(oppName);
                
            }
            System.debug('oppNameSet^^' + oppNameSet.size());
            System.debug('oppName^^' + oppNameSet);
            if(oppNameSet.size() > 0){
                for(Opportunity opp : [SELECT Id,Name FROM Opportunity WHERE Name IN: oppNameSet]){
                    String oppName = opp.Name.toUppercase();
                    opportunityIds.add(opp.Id);
                    if(!oppNameIdMap.containsKey(oppName)){
                        
                        oppNameIdMap.put(oppName, new Set<String>());
                    }
                    oppNameIdMap.get(oppName).add(opp.Id);
                }
                system.debug('oppNameIdMap^^'+oppNameIdMap);
                if(opportunityIds.size() > 0){
                    for(Contract cont : [SELECT Id,Type__c,Opportunity_Commodity_Type__c,supplier_s_contract_ID__c,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Name,StartDate,EndDate,ContractTerm,
                                         Adder_Margin__c,Selling_Price__c FROM Contract WHERE SBQQ__Opportunity__c IN: opportunityIds order by supplier_s_contract_ID__c asc])
                    {
                        
                        if(!contractMap.containsKey(cont.SBQQ__Opportunity__c))
                        {
                            contractMap.put(cont.SBQQ__Opportunity__c,new List<Contract>());    
                        }
                        contractMap.get(cont.SBQQ__Opportunity__c).add(cont);
                    }
                    System.debug('contractMap^^' + contractMap.size());
                    System.debug('contracts^^' + contractMap);
                    system.debug('tempOppListSize'+tempOppList.size());
                    for(Opportunity_Data_Temp__c tempData : tempOppList){
                        string TempOppType = tempData.Type__c.substring(0,3);
                        String oppName = tempData.Opportunity_Name__c.toUppercase();
                        if(oppNameIdMap.containsKey(oppName)){
                        for(String oppId : oppNameIdMap.get(oppName))
                        {
                            if(contractMap.containsKey(oppId)){
                                for(Contract cont : contractMap.get(oppId)){
                                    ContType = cont.Opportunity_Commodity_Type__c.substring(0,3);
                                    Date ThirtyStartDayAhead = tempData.Start_Date__c.addDays(-30);
                                    Date ThirtyEndDayAhead = tempData.End_Date__c.addDays(-30);
                                    if(cont.StartDate <= tempData.Start_Date__c && cont.StartDate >= ThirtyStartDayAhead 
                                       && cont.EndDate <= tempData.End_Date__c && cont.EndDate >= ThirtyEndDayAhead 
                                       && ContType  == TempOppType 
                                       && cont.ContractTerm == tempData.Term__c 
                                       //&& cont.Adder_Margin__c == tempData.Adder__c 
                                       && cont.Selling_Price__c == tempData.Contract_Price__c)
                                    {
                                        tempData.Opportunity__c = cont.SBQQ__Opportunity__c;
                                        opportunityTempToBeUpdate.put(tempData.Id,tempData);
                                    }
                                }
                            }
                        }
                    }
                    }
                    System.debug('opportunityToBe^^' + opportunityTempToBeUpdate);
                    System.debug('opportunityToBeUpdate^^' + opportunityTempToBeUpdate.size());
                    try{
                        if(opportunityTempToBeUpdate.size() > 0){
                            UPDATE opportunityTempToBeUpdate.Values();
                        }
                        List<Opportunity_Data_Temp__c> OppTempList = new List<Opportunity_Data_Temp__c>();
                        For(Opportunity_Data_Temp__c oppData: [SELECT Id, Closer__c,Is_Opener_Closer_MisMatch__c,IsAgainProceed__c, Opener__c, Opportunity__c,Opportunity__r.Opener__c, Opportunity__r.Closer__c FROM Opportunity_Data_Temp__c where id IN: opportunityTempToBeUpdate.keyset()]){
                            if(oppData.Opportunity__c != null
                               && oppData.Opener__c != oppData.Opportunity__r.Opener__c 
                               || oppData.Closer__c != oppData.Opportunity__r.Closer__c){
                                   oppData.Is_Opener_Closer_MisMatch__c = true;
                                   oppData.IsAgainProceed__c = true;
                                   OppTempList.add(oppData); 
                               }
                        }
                        if(OppTempList.size()>0){
                            UPDATE OppTempList;
                            system.debug('OppTempList'+OppTempList);
                        }
                    }catch(Exception ex){
                        System.debug('exception occured^^' + ex.getMessage());
                    }
                }
            }
        }  
        
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}