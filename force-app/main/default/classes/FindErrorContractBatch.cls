global class FindErrorContractBatch implements Database.Batchable<sObject> {
    global String query;
    global string RecordId;
    global FindErrorContractBatch(String RecId){
        RecordId = RecId;
        query = 'SELECT Id, StageName, Amount, Flow_Date__c, Margin__c,Total_Volume__c , Subscription_Term__c, Annual_Volume__c, End_date__c FROM Opportunity where id =: RecordId';
    }
    global FindErrorContractBatch(){
        query = 'SELECT Id, StageName, Amount, Flow_Date__c, Margin__c,Total_Volume__c , Subscription_Term__c, Annual_Volume__c, End_date__c FROM Opportunity';
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> OppList){
        System.debug('OppList^^' + OppList.size());
        if(OppList.size() > 0){
            Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>();
            Map<Id,List<OpportunityLineItem>> oppLineItemMap = new Map<Id,List<OpportunityLineItem>>();
            Map<Id,Contract> contractMap = new Map<Id,Contract>();
            Map<Id,List<SBQQ__Subscription__c>> subscriptionMap = new Map<Id,List<SBQQ__Subscription__c>>();
            Set<Id> contractIds = new Set<Id>();
            List<Opportunity_Temp__c> TempOppToBeUpdate = new List<Opportunity_Temp__c>();
            for(Opportunity opp : OppList){
                OppMap.put(opp.Id,opp);
            }
            System.debug('OppMap^^' + OppMap.size());
            if(OppMap.size() > 0){
                // get opportunity products related to opportunities
                for(OpportunityLineItem oli : [SELECT Id,OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN: 
                                               OppMap.keySet()]){
                                                   if(!oppLineItemMap.containsKey(oli.OpportunityId)){
                                                       oppLineItemMap.put(oli.OpportunityId,new List<OpportunityLineItem>());
                                                   }
                                                   oppLineItemMap.get(oli.OpportunityId).add(oli);
                                               }
                System.debug('oppLineItemMap^^' + oppLineItemMap.size());
                // get contracts related to opportunities which are not activated
                for(Contract cont : [SELECT Id, StartDate, EndDate, ContractTerm, SBQQ__Opportunity__c, Amount__c,Adder_Margin__c, DNE_Admin_Fee__c, OriginalVolume__c FROM Contract WHERE SBQQ__Opportunity__c IN:
                                     OppMap.keySet()]){
                                         contractMap.put(cont.SBQQ__Opportunity__c,cont);
                                         contractIds.add(cont.Id);
                                     }
                System.debug('contractMap^^' + contractMap.size());
                System.debug('contractIds^^' + contractIds.size());
                if(contractIds.size() > 0){
                    // get subscriptions related to contracts
                    for(SBQQ__Subscription__c subs : [SELECT Id,SBQQ__Contract__c,Site__c,SBQQ__QuoteLine__c FROM SBQQ__Subscription__c 
                                                      WHERE SBQQ__Contract__c IN: contractIds]){
                                                          if(!subscriptionMap.containsKey(subs.SBQQ__Contract__c)){
                                                              subscriptionMap.put(subs.SBQQ__Contract__c,new List<SBQQ__Subscription__c>());
                                                          }
                                                          subscriptionMap.get(subs.SBQQ__Contract__c).add(subs);
                                                      }
                }
                System.debug('subscriptionMap^^' + subscriptionMap.size());
                
                for(Opportunity oppt : OppMap.values()){
                    if(contractMap.containsKey(oppt.Id)){
                        Contract cont = contractMap.get(oppt.Id);
                        decimal oppAmount;
                        decimal contAmount; 
                        decimal oppMargin;
                        decimal contMargin;
                        decimal oppVol;
                        decimal contVol;
                        system.debug('Before^oppt.Amount'+oppt.Amount);
                        system.debug('Before^cont.Amount__c'+cont.Amount__c );
                        
                        
                        if(oppt.Amount != null){
                            oppAmount = oppt.Amount.setScale(2,System.RoundingMode.HALF_UP);
                            system.debug('oppAmount'+oppAmount);
                        }
                        if(cont.Amount__c != null){
                            contAmount  = cont.Amount__c.setScale(2,System.RoundingMode.HALF_UP);
                            system.debug('contAmount'+contAmount);
                        }
                        system.debug('Before^oppt.Margin__c'+oppt.Margin__c);
                        system.debug('Before^cont.Adder_Margin__c'+cont.Adder_Margin__c);
                        if(oppt.Margin__c != null){
                            oppMargin = oppt.Margin__c.setScale(4,System.RoundingMode.HALF_UP);
                        }
                        if(cont.Adder_Margin__c != null){
                            contMargin = cont.Adder_Margin__c.setScale(4,System.RoundingMode.HALF_UP);
                        }
                        system.debug('oppMargin'+oppMargin);
                        system.debug('contMargin'+contMargin);
                        
                        system.debug('Before^oppt.Total_Volume__c'+oppt.Total_Volume__c);
                        system.debug('Before^cont.OriginalVolume__c'+cont.OriginalVolume__c);
                        if(oppt.Total_Volume__c != null){
                            oppVol = oppt.Total_Volume__c.setScale(2,System.RoundingMode.HALF_UP);
                        }
                        if(cont.OriginalVolume__c != null){
                            contVol = cont.OriginalVolume__c.setScale(2,System.RoundingMode.HALF_UP);
                        }
                        system.debug('oppVol'+oppVol);
                        system.debug('contVol'+contVol);
                        
                        if(oppLineItemMap.containsKey(oppt.Id) && subscriptionMap.containsKey(cont.Id)){
                            if(oppLineItemMap.get(oppt.Id).size() == subscriptionMap.get(cont.Id).size() &&
                               oppt.Flow_Date__c == cont.StartDate &&
                               oppAmount == contAmount && oppVol == contVol && 
                               oppt.Subscription_Term__c == cont.ContractTerm && 
                               oppMargin == contMargin && 
                               oppt.End_date__c == cont.EndDate){
                                   system.debug('Everything is correct');
                               }else{
                                   
                                   Opportunity_Temp__c opptemp = new Opportunity_Temp__c();
                                   opptemp.Opportunity__c = oppt.id;
                                   opptemp.contract__c = cont.id;
                                   opptemp.Stage__c = oppt.stageName;
                                   opptemp.Flow_Date__c = oppt.Flow_Date__c;
                                   opptemp.Amount__c = oppAmount;
                                   opptemp.Volume__c = oppVol;
                                   opptemp.Term__c = oppt.Subscription_Term__c;
                                   opptemp.Margin__c = oppMargin;
                                   opptemp.End_Date__c = oppt.End_date__c;
                                   opptemp.No_of_products__c = oppLineItemMap.get(oppt.Id).size();
                                   opptemp.No_of_subscriptions__c = subscriptionMap.get(cont.Id).size();
                                   opptemp.Reason_of_Error__c = '';
                                   if(oppLineItemMap.get(oppt.Id).size() != subscriptionMap.get(cont.Id).size()){
                                       opptemp.Reason_of_Error__c += 'Subscription Size Error';
                                   }
                                   if(oppt.Flow_Date__c != cont.StartDate){
                                       opptemp.Reason_of_Error__c += ',' ;
                                       opptemp.Reason_of_Error__c += 'Start Date Error';
                                   }
                                   if(oppAmount != contAmount){
                                       opptemp.Reason_of_Error__c += ',' ;
                                       opptemp.Reason_of_Error__c += 'Amount Error';
                                   }
                                   if(oppVol != contVol){
                                       opptemp.Reason_of_Error__c += ',' ;
                                       opptemp.Reason_of_Error__c += 'Volume Error';
                                   }
                                   if(oppt.Subscription_Term__c != cont.ContractTerm){
                                       opptemp.Reason_of_Error__c += ',' ;
                                       opptemp.Reason_of_Error__c += 'Term Error';
                                   }
                                   if(oppMargin != contMargin){
                                       opptemp.Reason_of_Error__c += ',' ;
                                       opptemp.Reason_of_Error__c += 'Margin Error';
                                   }
                                   if(oppt.End_date__c != cont.EndDate){
                                       opptemp.Reason_of_Error__c += ',' ;
                                       opptemp.Reason_of_Error__c += 'End Date Error';
                                   }
                                   system.debug('opptemp^^^::'+opptemp);
                                   TempOppToBeUpdate.add(opptemp);
                               }
                        }
                    }
                }
                System.debug('TempOppToBeUpdate^^' + TempOppToBeUpdate.size());
                try{
                    if(TempOppToBeUpdate.size() > 0){
                        //Insert TempOppToBeUpdate;
                        System.debug('TempOppToBeUpdate'+TempOppToBeUpdate);
                    }
                }catch(Exception ex){
                    System.debug('exception occured on contract updation^^' + ex.getMessage());
                }
            }  
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }    
}