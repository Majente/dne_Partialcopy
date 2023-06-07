/**************************************************
* Class: ResidentialOpportunityTriggerHandler
* Author: Soljit <VW>
* Date: 2019-11-25
* Description: ResidentialOpportunityTriggerHandler for ResidentialOpportunityTrigger
****************************************************/
public class ResidentialOpportunityTriggerHandler {
    Public static Map<Id,Residential_Commission_Hierarchy__c> residCommHierMap;
    Public static Map<String,ResidentialCommissionConfigure__c> residCommConfigMap;    
    public static FINAL Integer NB_OF_COMMISSION_LEVELS = 16;
   
    /*********************************************************
	@Name           : calculateCommission
	@Parameters     : List of new Residential_Opportunity__c
	@Reutrn type    : Void
	@Description    : Create Commission and calculate commission when Opportunity closed won
	********************************************************/
    Public Static void calculateCommission(List<Residential_Opportunity__c> resOppList){
		Set<Id> commConfigureIdSet = new Set<Id>();
		Set<Id> commHierachyIdSet = new Set<Id>();
		Set<String> closerIdSet = new Set<String>();
        Map<String,Id> closerContactMap = new Map<String,Id>();
		try{
	        For(Residential_Opportunity__c resOpp : resOppList){
	            commConfigureIdSet.add(resOpp.ResidentialCommissionConfigure__c);
	            commHierachyIdSet.add(resOpp.ResidentialCommissionHierarchy__c);
                closerIdSet.add(resOpp.Closer__c);
	        }
	        System.debug('commConfigureIdSet ::: ' + commConfigureIdSet);
	        System.debug('commHierachyIdSet ::: ' + commHierachyIdSet);
	        System.debug('closerIdSet ::: ' + closerIdSet);
            
            For(Contact con : [SELECT Id, Name from Contact where Name IN : closerIdSet]){
                if(!closerContactMap.containsKey(con.Name)){
                    closerContactMap.put(con.Name,con.Id);
                }
            }
			System.debug('closerContactMap.size() ::: ' + closerContactMap.size());
			System.debug('closerContactMap ::: ' + closerContactMap);
            
	        Map<Id,ResidentialCommissionConfigure__c> commissionConfigureMap = new Map<Id,ResidentialCommissionConfigure__c>([SELECT Id,Closer__c,Level1__c,Level2__c,Level3__c,
	                                                                                                                          Level4__c,Level5__c,Level6__c,Level7__c,
	                                                                                                                          Level8__c,Level9__c,Level10__c,Level11__c,
	                                                                                                                          Level12__c,Level13__c,Level14__c,Level15__c,
	                                                                                                                          Level16__c,type__c,EffectiveFrom__c,Flat_Fee_Paid_To_DNE__c 
	                                                                                                                          FROM ResidentialCommissionConfigure__c 
	                                                                                                                          WHERE Id IN : commConfigureIdSet]);
	        Map<Id,Residential_Commission_Hierarchy__c> commissionHierarchyMap = new Map<Id,Residential_Commission_Hierarchy__c>([SELECT Id, Closer__c,Closer__r.Name,
	                                                                                                                              Level1__c,Level2__c,Level3__c,Level4__c,
	                                                                                                                              Level5__c,Level6__c,Level7__c,Level8__c,
	                                                                                                                              Level9__c,Level10__c,Level11__c,Level12__c,
	                                                                                                                              Level13__c,Level14__c,Level15__c,Level16__c
	                                                                                                                              FROM Residential_Commission_Hierarchy__c 
	                                                                                                                              WHERE Id IN : commHierachyIdSet]);
			System.debug('commissionConfigureMap.size() ::: ' + commissionConfigureMap.size());
			System.debug('commissionConfigureMap ::: ' + commissionConfigureMap);
			System.debug('commissionHierarchyMap.size() ::: ' + commissionHierarchyMap.size());
			System.debug('commissionHierarchyMap ::: ' + commissionHierarchyMap);
	        
	        if(commissionConfigureMap.isEmpty()){
	            System.debug('ERROR in ResidentialOpportunityTriggerHandler.calculateCommission() - no Commission Configure found.');
	            return;
	        } 
	        
	        ResidentialCommissionConfigure__c resiCommiCon;
	        Residential_Commission_Hierarchy__c resiCommiHi;
	        List<Residential_Commission__c> resiCommissionList = new List<Residential_Commission__c>();
	        Double commissionTotalAmount = 0;
	        Double receiverCommissionPercentage = 0;
	        Double receiverCommissionAmount = 0;
	        
	        For(Residential_Opportunity__c resOpp :resOppList){
	            resiCommiCon = commissionConfigureMap.get(resOpp.ResidentialCommissionConfigure__c);
	            if(resiCommiCon == null)
	            {
	                String errorMessage = 'Please create a Commission Configure record for this Residential Opportunity Type (' + resOpp.Type__c + ')';
	                System.debug('ERROR : ' + errorMessage);
	                //resOpp.addError(errorMessage);
	            }
	            else{
	                resiCommiHi = commissionHierarchyMap.get(resOpp.ResidentialCommissionHierarchy__c);
	                if(resiCommiHi == null){
	                    if(String.isNotBlank(String.valueOf(resOpp.get('Closer__c')))){
	                        receiverCommissionAmount = ResidentialOpportunityTriggerHandler.calculateCommissionAmount ( resiCommiCon.Flat_Fee_Paid_To_DNE__c,resiCommiCon.Closer__c);
                            if(String.isNotBlank(closerContactMap.get(resOpp.Closer__c))){
                                Residential_Commission__c closerCommission = createCommissionsforReceiver(resOpp, receiverCommissionAmount, 'Closer', closerContactMap.get(resOpp.Closer__c));                
                                resiCommissionList.add(closerCommission);                                
                            }
                            else{
                                System.debug('Not found any contact in SF regarding to closer on opportunity.');                                
                            }
	                    }                    
	                }
	                else{
	                    if(String.isNotBlank(String.valueOf(resiCommiHi.get('Closer__c')))){
	                        System.debug('resiCommiHi.Closer__c ::: ' +resiCommiHi.get('Closer__c'));                        
	                        System.debug('resiCommiCon.Flat_Fee_Paid_To_DNE__c ::: ' +resiCommiCon.Flat_Fee_Paid_To_DNE__c);
	                        System.debug('resiCommiCon.Closer__c ::: ' +resiCommiCon.Closer__c);
	                        
	                        receiverCommissionAmount = ResidentialOpportunityTriggerHandler.calculateCommissionAmount( resiCommiCon.Flat_Fee_Paid_To_DNE__c, resiCommiCon.Closer__c);
	                        System.debug('receiverCommissionAmount ::: ' +receiverCommissionAmount);
	                        Residential_Commission__c closerCommission = createCommissionsforReceiver(resOpp, receiverCommissionAmount, 'Closer', resiCommiHi.Closer__c);                
	                        resiCommissionList.add(closerCommission);
	                    }
	                    for(Integer levelCounter=1; levelCounter<NB_OF_COMMISSION_LEVELS; levelCounter++)
	                    {                    
	                        String receiverType = 'Level' + levelCounter;
	                        String recieverFieldName = 'Level' + levelCounter + '__c';
	                        String receiverId = String.valueOf(resiCommiHi.get(recieverFieldName));
	                        System.debug('Receiver ' + receiverType + ' = ' + receiverId);
	                        if(String.isNotBlank(receiverId))
	                        {
	                            receiverCommissionAmount = ResidentialOpportunityTriggerHandler.calculateCommissionAmount ( resiCommiCon.Flat_Fee_Paid_To_DNE__c ,  Double.valueOf(resiCommiCon.get(recieverFieldName)));
	                            Residential_Commission__c levelCommission = createCommissionsforReceiver(resOpp, receiverCommissionAmount, receiverType, receiverId);                
	                            System.debug('Level Commission ' + receiverType + ' = ' + levelCommission);
	                            resiCommissionList.add(levelCommission);
	                        }
	                    }                
	                }                
	            }
	        }
	        System.debug('Before Insert Commission List::'+resiCommissionList);
	        if(resiCommissionList.size() > 0){
	        	
		        	// delete existing commission records if any
		        	removeExistingCommissions(resOppList);
		        	
		            insert resiCommissionList;
		            System.debug('After Insert Commission List::'+ resiCommissionList);
	        }
	    }catch(Exception exp){
	    	System.debug('Error while inserting commission records  ::');
	    }
    }
    /*********************************************************
	@Name           : calculateCommissionAmount
	@Parameters     : amount and percent
	@Reutrn type    : double 
	@Description    : calculate precent amount
	********************************************************/    
    public static double calculateCommissionAmount(decimal amt, decimal precent){
    	Double receiverCommissionAmount = 0;
    	if(amt != null && precent != null && precent > 0 ){
    		receiverCommissionAmount = amt * precent/100;
    	}
    	return receiverCommissionAmount;
    }
    /*********************************************************
	@Name           : removeExistingCommissions
	@Parameters     : List of Residential_Opportunity__c
	@Reutrn type    : Void
	@Description    : Remove existing commission from residential opportunity
	********************************************************/ 
    public static void removeExistingCommissions (List<Residential_Opportunity__c> resiOpplst ){
    	
    	List<Residential_Commission__c> resiCommissionList = [ Select Id From Residential_Commission__c Where Residential_Opportunity__c IN: resiOpplst ];
        try{
            if(resiCommissionList.size() > 0 ){
                delete resiCommissionList;
            }
        }catch(Exception exp){
            System.debug('Error while existing commission records deleting :: ' + exp);
        }
    }
    
    /*********************************************************
	@Name           : populateCommHierachyAndCommConfigure
	@Parameters     : List of new Residential_Opportunity__c
	@Reutrn type    : Void
	@Description    : Update commission hierachy and Commission Configure on before Update
	********************************************************/    
    Public static void populateCommHierachyAndCommConfigure(List<Residential_Opportunity__c> resOppList){        
        ResidentialUtility.populateResidentialCommissionHierarchy(resOppList);
        ResidentialUtility.populateResidentialCommissionConfigure(resOppList);
    }
    
    /*********************************************************
	@Name           : createCommissionsforReceiver
	@Parameters     : Residential Opportunity,Amount,Type
	@Reutrn type    : List of Residential Commission
	@Description    : Return list of commission 
	********************************************************/    
    public static Residential_Commission__c createCommissionsforReceiver(Residential_Opportunity__c resiOpp, Decimal amount ,String receiverType, String receiverId){         
        Residential_Commission__c residenCommission = new Residential_Commission__c();
        residenCommission.Amount__c = amount;
        residenCommission.Due_Date__c = resiOpp.CloseDate__c;
        residenCommission.Receiver_Type__c = receiverType;
        residenCommission.Receiver__c = receiverId;
        residenCommission.Residential_Opportunity__c = resiOpp.Id;
        System.debug('residenCommission :::: ' + residenCommission);        
        return residenCommission;
    }
    
    
    /*********************************************************
	@Name 			: commissionClawback
	@Parameters 	: List of new Residential Opportunity
	@Reutrn type 	: void
	@Description 	: To calculate commission clawback.
	********************************************************/
    public static void commissionClawback(List<Residential_Opportunity__c> resiOppList){
        System.debug('calling commissionClawback()');
        System.debug('resiOppList.size() ::: ' + resiOppList.size());
        System.debug('resiOppList ::: ' + resiOppList);
        List<Residential_Commission__c> resiCommList = new List<Residential_Commission__c>();
        for(Residential_Opportunity__c resiOpp : [SELECT Id, ResidentialCommissionConfigure__c, CloseDate__c,
                                                  ResidentialCommissionConfigure__r.Clawbacktime__c,Cancelled_Date__c, 
                                                  (SELECT id, Amount__c, Paid__c from Residential_Commission__r) 
                                                  FROM Residential_Opportunity__c
                                                  WHERE Id IN :resiOppList
                                                 ])
        {		
            if(resiOpp.CloseDate__c == null || resiOpp.ResidentialCommissionConfigure__c == null || resiOpp.ResidentialCommissionConfigure__r.Clawbacktime__c == null)
            {
                System.debug('Error ::: One or more fields are empty amoung these fields Close Date & ResidentialCommissionConfigure lookup on Residential Opportunity and Clawbacktime on Residential Commission Configure object. So cannot find the date for residential commission Clawback.');
               // resiOpp.CloseDate__c.addError('Error ::: One or more fields are empty amoung these fields Close Date & ResidentialCommissionConfigure lookup on Residential Opportunity and Clawbacktime on Residential Commission Configure object. So cannot find the date for residential commission Clawback.');
                continue;
            }
            date clawbackDate = resiOpp.CloseDate__c.addDays((Integer)resiOpp.ResidentialCommissionConfigure__r.Clawbacktime__c);
            System.debug('resiOpp.CloseDate__c ::: ' + resiOpp.CloseDate__c);
            System.debug('resiOpp.Cancelled_Date__c ::: ' + resiOpp.Cancelled_Date__c);
            System.debug('clawbackDate ::: ' + clawbackDate);
            if(clawbackDate < resiOpp.Cancelled_Date__c){
                System.debug('Residential Opportunity Cancel date expires So nothing will be clawback on residential commissions.');
                continue;			
            }
            for(Residential_Commission__c resiComm : resiOpp.Residential_Commission__r){
                if(resiComm.Paid__c == true){
                    resiComm.Amount__c = resiComm.Amount__c * (-1);
                }
                else{
                    resiComm.Amount__c = 0;
                }
                resiCommList.add(resiComm);
            }
        }
        System.debug('resiCommList.size() ::: ' + resiCommList.size());
        System.debug('resiCommList ::: ' + resiCommList);
        try{            
            if(resiCommList.size() > 0){
                UPDATE resiCommList;
                System.debug('Residential Commission updated successfully');		
            }
        }catch(Exception exp){
            System.debug('Error while existing commission records updating :: ' + exp);
        }            
    }

    
}