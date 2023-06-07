/**************************************************

* Class: ContractTrigger
* Author: Soljit <VW>
* Date: 2019-05-27
* Description: ContractTrigger for ContractTriggerHandler

****************************************************/
trigger ContractTrigger on Contract (before update, before insert, after update, after insert) 
{
    public static string STATUS = 'Activated';
    public static string STATUS2 = 'Revenue Received';
    
    // Update flag for Renewal if contract status is avtivated
    if(Trigger.isBefore){
        if(Trigger.isUpdate)  {
              Map<Id, Contract> renewalConMap = new Map<Id,Contract>();
            
            for(Contract newCon: Trigger.new) {
                if(newCon.Status == STATUS && trigger.oldmap.get(newcon.Id).status != STATUS){
                    if(!Test.isRunningTest()){ // For skipping these two line if test class is running.
                        renewalConMap.put(newCon.Id, newCon);
                        //newcon.SBQQ__RenewalForecast__c = true;
                        //newcon.SBQQ__RenewalQuoted__c = true;
                    }
                }
            }
             if(renewalConMap.size() > 0){
                ContractTriggerHandler.renewalOpportunityUpdate(renewalConMap);
            }
        }
        if(Trigger.isInsert){
            // On Before Insert populate Adder from Opportunity to Contract
            ContractTriggerHandler.populateReveneuAndCommission(Trigger.new);
        }
    }
    
    if(Trigger.isAfter){
        // This for create and calculate DNE commissions when Contract is activated.
        //ContractTriggerHandler.createDNECommissions(trigger.NewMap, trigger.OldMap, trigger.isUpdate, trigger.isInsert);
        
        if(Trigger.isInsert){
            ContractTriggerHandler.populateCommissionHierarchy(trigger.NewMap.keySet());
            ContractTriggerHandler.populateCommissionPercent(trigger.NewMap.keySet());
        }
        if(Trigger.isUpdate){
            List<Contract> conList = new List<Contract>();
            List<Contract> conCancelledList = new List<Contract>();
           
            for(Contract newCon: Trigger.new){
                // This for create revenue when Contract is stage is marked as "Revenue Received".
                if(newCon.Status == STATUS2 && trigger.oldmap.get(newcon.Id).status != STATUS2){
                    conList.add(newCon);
                }    
                
                if(newCon.Status == 'Cancelled' && trigger.oldmap.get(newcon.Id).status != 'Cancelled'){
                    conCancelledList.add(newCon);
                } 
                
            }
            if(conList.size() > 0){
                ContractTriggerHandler.generateTransactionInvoice(conList);
            }
           
            // Check and update subscriptions if any Adder changed on Contract
            ContractTriggerHandler.updateReveneuAndCommission(trigger.OldMap,trigger.NewMap);
            
            if(conCancelledList.size() > 0){
                ContractTriggerHandler.createAmendmentOpp(new Map<Id, Contract> (conCancelledList));
            }
            
            
        }
    }
}