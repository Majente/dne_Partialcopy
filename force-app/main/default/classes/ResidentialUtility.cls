/**************************************************
* Class: ResidentialUtility
* Author: Soljit <VW>
* Date: 2019-11-25
* Description: ResidentialUtility
****************************************************/
public class ResidentialUtility {
    
    /*********************************************************
	@Name           : populateResidentialCommissionConfigure
	@Parameters     : List of new Residential Opportunity
	@Reutrn type    : void
	@Description    : Populate Residential Commission Configure
	********************************************************/
   Public static void populateResidentialCommissionConfigure(List<Residential_Opportunity__c> resOppList){
        System.debug('calling populateResidentialCommissionConfigure()');
                
        Map<String,ResidentialCommissionConfigure__c> commissionConfigureMap = createCommissionConfigureMap();
        if(commissionConfigureMap.isEmpty()){
            return;            
        }            
        for(Residential_Opportunity__c resiOpp : resOppList)
        {
            if(resiOpp.ResidentialCommissionConfigure__c == null){
                String Key = resiOpp.PromoCode__c + resiOpp.Supplier__c + resiOpp.Commodity__c + resiOpp.ContractSource__c + resiOpp.Term__c + resiOpp.State__c + resiOpp.Country__c + resiOpp.ECC__c + resiOpp.Type__c;
                System.debug('resiOpp Key ::: ' + Key);
                if(commissionConfigureMap.containsKey(Key)){
                    resiOpp.ResidentialCommissionConfigure__c = commissionConfigureMap.get(Key).Id;
                }
            }             
        }
        System.debug('### After Commission Configure oppList.size() ::: ' + resOppList.size());
        System.debug('### After Commission Configure oppList ::: ' + resOppList);        
    }
       
    /*********************************************************
	@Name 			: populateResidentialCommissionHierarchy
	@Parameters 	: List of new Residential Opportunity
	@Reutrn type 	: void
	@Description 	: To populate commission Hierarchy
	********************************************************/
    public static void populateResidentialCommissionHierarchy(List<Residential_Opportunity__c> resiOppList){
        System.debug('calling populateResidentialCommissionHierarchy()');
        System.debug('resiOppList.size() ::: ' + resiOppList.size());
        System.debug('resiOppList ::: ' + resiOppList);
        Set<String> closerSet = new Set<String>();
        for(Residential_Opportunity__c resiOpp : resiOppList)
        {		
            if(resiOpp.Closer__c != null)
            {
                closerSet.add(resiOpp.Closer__c);
            }
        }
        System.debug('closerSet.size() ::: ' + closerSet.size());
        System.debug('closerSet ::: ' + closerSet);
        if(closerSet.isEmpty())
        {
            System.debug('ResidentialUtility.populateResidentialCommissionHierarchy() - NO CLOSER WAS FOUND for these Opportunities.');
            return;
        }
        
        Datetime todayDateTime = Datetime.now();
        
        List<Residential_Commission_Hierarchy__c> commissionHierarchyList = [SELECT Id, Closer__c,Closer__r.Name 
                                                                             FROM Residential_Commission_Hierarchy__c
                                                                             WHERE Closer__r.Name IN :closerSet
                                                                             AND Effective_From__c < :todayDateTime
                                                                             ORDER BY Effective_From__c DESC];
        
        System.debug('commissionHierarchyList = ' + commissionHierarchyList);
        
        if(commissionHierarchyList.isEmpty())
        {
            System.debug('ERROR in ResidentialUtility.populateResidentialCommissionHierarchy() - no Commission Hierarchy found.');
            return;
        }
        
        // the key = Opener__c (ex: 0030q00000OYa8h)
        Map<String, Residential_Commission_Hierarchy__c> commissionHierarchyMap = new Map<String, Residential_Commission_Hierarchy__c>();
        
        for(Residential_Commission_Hierarchy__c commHier : commissionHierarchyList)
        {
            String theKey = commHier.Closer__r.Name;
            if(!commissionHierarchyMap.containsKey(theKey))
            {
                commissionHierarchyMap.put(theKey, commHier);
            }
        }
        System.debug('commissionHierarchyMap.size() ::: ' + commissionHierarchyMap.size());        
        System.debug('commissionHierarchyMap ::: ' + commissionHierarchyMap);        
        
        for(Residential_Opportunity__c resiOpp : resiOppList)
        {            
            System.debug('Opportunity = ' + resiOpp);
            if(resiOpp.ResidentialCommissionHierarchy__c == null){
                String opportunityKey = resiOpp.Closer__c;
                
                System.debug('opportunityKey = ' + opportunityKey);
                
                Residential_Commission_Hierarchy__c relatedCommHier = commissionHierarchyMap.get(opportunityKey);
                
                System.debug('relatedCommHier = ' + relatedCommHier);
                
                if(relatedCommHier==null)
                {
                    String errorMessage = 'Please create a Commission Hierarchy record for this CLOSER (' + resiOpp.Closer__c + ')';
                    System.debug('ERROR : ' + errorMessage);
                }
                else
                {
                    resiOpp.ResidentialCommissionHierarchy__c = relatedCommHier.Id;
                }                
            }
        }
        System.debug('After Commission Hierarchy resiOppList.size() = ' + resiOppList.size());        
        System.debug('After Commission Hierarchy resiOppList = ' + resiOppList);        
    }
    
    /*********************************************************
	@Name 			: createCommissionConfigureMap
	@Parameters 	: Boolean (If want to use all commission configure record give true as parameter otherwise false)
	@Reutrn type 	: void
	@Description 	: create commission Configure
	********************************************************/
    public static Map<String,ResidentialCommissionConfigure__c> createCommissionConfigureMap(){
        Map<String,ResidentialCommissionConfigure__c> commissionConfigureMap = new Map<String,ResidentialCommissionConfigure__c>();        
        Datetime dateTimeNow = Datetime.now();
        
        for(ResidentialCommissionConfigure__c commConfigure : [SELECT Id,PromoCode__c,Supplier__c,Supplier__r.Name,
                                                               Commodity__c,Contractsource__c,Term__c,ProvinceorState__c,
                                                               Country__c,ECC__c,Type__c,EffectiveFrom__c 
                                                               FROM ResidentialCommissionConfigure__c 
                                                               WHERE EffectiveFrom__c < :dateTimeNow 
                                                               ORDER BY EffectiveFrom__c DESC])
        {
            // CommissionType
            String theKey = commConfigure.PromoCode__c + commConfigure.Supplier__r.Name + commConfigure.Commodity__c + commConfigure.Contractsource__c + commConfigure.Term__c + commConfigure.ProvinceorState__c + commConfigure.Country__c + commConfigure.ECC__c + commConfigure.Type__c;
            if(!commissionConfigureMap.containsKey(theKey))
            {
                commissionConfigureMap.put(theKey,commConfigure);
            }
        }
        System.debug('commissionPercentMap = ' + commissionConfigureMap);
        return commissionConfigureMap;
    }
}