trigger OpportunityTrigger on Opportunity (Before Insert,After Insert,Before update, after update) {
    public static string OPPSTAGE = 'Activate Change';
    public static string OPPLOSTSTAGE = 'Closed Lost';
    Id RecordTypeIdAmendmentOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
    
    /*  DO NOT UNCOMMENT
     * if(trigger.isAfter && trigger.isInsert){
            List<Opportunity> oppList = new List<Opportunity>();
          for(Opportunity newOpp: trigger.new){
              if(newOpp.RecordTypeId == RecordTypeIdAmendmentOpp){
                   oppList.add(newOpp);
              }
          }
          If(oppList.size() > 0){
               AmendmentOpportunityTriggerHandler.saveOLI(oppList);
          }
        
    }*/
    if(trigger.isBefore && trigger.isInsert){ 
        for(Opportunity opp: trigger.new){
            if(opp.Monthly_Site_Admin_Fee__c == null){
                    opp.Monthly_Site_Admin_Fee__c = 0;
                }
                if(opp.Daily_Site_Admin_Fee__c == null){
                    opp.Daily_Site_Admin_Fee__c = 0;
                }
        }
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        
        List<Opportunity> oppList = new List<Opportunity>();
      
        Map<Id,Opportunity> oppNewMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> oppOldMap = new Map<Id,Opportunity>();
        for(Opportunity newOpp: trigger.new){
            
            Opportunity oldOpp = Trigger.oldMap.get(newOpp.Id);
            if(newOpp.RecordTypeId == RecordTypeIdAmendmentOpp && oldOpp.StageName != newOpp.StageName && newOpp.StageName == OPPSTAGE){
                oppList.add(newOpp);            }
         
            if(oldOpp.DNE_Admin_Fee__c != newOpp.DNE_Admin_Fee__c || oldOpp.Supplier__c != newOpp.Supplier__c || oldOpp.Flow_Date__c != newOpp.Flow_Date__c || oldOpp.Admin_Fee__c != newOpp.Admin_Fee__c || oldOpp.Subscription_Term__c != newOpp.Subscription_Term__c  || oldOpp.Margin__c != newOpp.Margin__c || oldOpp.Supplier_Price__c != newOpp.Supplier_Price__c || oldOpp.Monthly_Site_Admin_Fee__c != newOpp.Monthly_Site_Admin_Fee__c || oldOpp.Daily_Site_Admin_Fee__c != newOpp.Daily_Site_Admin_Fee__c){
                oppNewMap.put(newOpp.Id,newOpp);
                oppOldMap.put(oldOpp.Id,oldOpp);                
            }
        }    
        System.debug('oppNewMap.size() ::: ' + oppNewMap.size());
        System.debug('oppNewMap ::: ' + oppNewMap);
        System.debug('oppOldMap.size() ::: ' + oppOldMap.size());
        System.debug('oppOldMap ::: ' + oppOldMap);        
        If(oppNewMap.size() > 0){
            OpportunityTriggerHandler.updateQuoteLineIteam(oppNewMap, oppOldMap);
            OpportunityTriggerHandler.updateContractAndSubscription(oppNewMap, oppOldMap);            
        }
        If(oppList.size() > 0){
            OpportunityTriggerHandler.updateExistingSubscription(oppList);            
             }
       
    }
    if(trigger.isAfter && trigger.isUpdate){
         List<Id> oppWonLostList = new List<Id>();
            
          for(Opportunity newOpp: trigger.new){ 
              
            if(newOpp.RecordTypeId == RecordTypeIdAmendmentOpp && Trigger.oldMap.get(newOpp.Id).StageName != newOpp.StageName && newOpp.StageName == OPPSTAGE && newOpp.Case__c != null){
                   oppWonLostList.add(newOpp.Case__c);
            }
            else if(newOpp.RecordTypeId == RecordTypeIdAmendmentOpp && Trigger.oldMap.get(newOpp.Id).StageName != newOpp.StageName && newOpp.StageName == OPPLOSTSTAGE && newOpp.Case__c != null){
                oppWonLostList.add(newOpp.Case__c);
            }
        }    
          If(oppWonLostList.size() > 0){
               OpportunityTriggerHandler.updateCaseOfAmendmentOpp(oppWonLostList);           
        }
       
    }
    
}