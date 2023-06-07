/**************************************************
* Class: ResidentialOpportunityTrigger
* Author: Soljit <VW>
* Date: 2019-11-25
* Description: ResidentialOpportunityTrigger for insert,update on ResidentialOpportunity
****************************************************/
trigger ResidentialOpportunityTrigger on Residential_Opportunity__c (before insert,before update ,after insert, after update) {
    public static string StageName = 'Closed Won';
    public static string StageNameCancel = 'Cancelled';
    
    if(Trigger.isBefore ){
        if(Trigger.isInsert){
            //Fill address value on opportunity from account
            System.debug(' Processing for populateCommHierachyAndCommConfigure '+ Trigger.new);
            ResidentialOpportunityTriggerHandler.populateCommHierachyAndCommConfigure(Trigger.new);
        }
        if(Trigger.isUpdate){
            //Update both lookup Commission Hierachy and Commission configure when not fill by End user
            List<Residential_Opportunity__c> resiOppList = new List<Residential_Opportunity__c>();
            For(Residential_Opportunity__c resOpp :Trigger.new){
                if(resOpp.StageName__c == StageName && trigger.oldmap.get(resOpp.Id).StageName__c != StageName){
                    resiOppList.add(resOpp);
                }
            }
            System.debug(' Processing for populateCommHierachyAndCommConfigure '+ resiOppList);
            if(resiOppList.size() > 0){
                ResidentialOpportunityTriggerHandler.populateCommHierachyAndCommConfigure(resiOppList);
            }
        }
    }
    if(Trigger.isAfter){
        //When Opportunity is closed won ,Create commission 
        List<Residential_Opportunity__c> oppList = new List<Residential_Opportunity__c>();
        List<Residential_Opportunity__c> resiOppList = new List<Residential_Opportunity__c>();
        
        for(Residential_Opportunity__c resOpp :Trigger.new){
        	
            if(Trigger.isUpdate && resOpp.StageName__c == StageNameCancel && trigger.oldmap.get(resOpp.Id).StageName__c != StageNameCancel){
                resiOppList.add(resOpp);
            }
        	if(resOpp.StageName__c == StageName){ // Only Close Won
        		
        		if(Trigger.isUpdate  && trigger.oldmap.get(resOpp.Id).StageName__c != StageName){
        			oppList.add(resOpp);
        		}else if( Trigger.isInsert){
        			oppList.add(resOpp);
        		}
        	}
        }
        
        System.debug(' Processing for Commission calculation on Close Won '+ oppList);
        if(oppList.size() > 0 ){
            ResidentialOpportunityTriggerHandler.calculateCommission(oppList);
        }
        System.debug(' Processing for Commission Clawback on Cancelled '+ oppList);
        if(resiOppList.size() > 0 ){
            ResidentialOpportunityTriggerHandler.commissionClawback(resiOppList);
        }
        
    }

}