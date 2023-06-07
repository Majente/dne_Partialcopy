/**************************************************
* Class: AssumptionTriggerHandler
* Author: Soljit <VW>
* Date: 2019-06-12
* Description: AssumptionTriggerHandler for AssumptionTrigger
****************************************************/
public class AssumptionTriggerHandler {
    /**************************************************
* Method Name : checkStatusLead
* Parameters  : List<Assumption__c> assumptionList
* Description : method to check lead status
****************************************************/
    public static void checkStatusLead(List<Assumption__c> assumptionList){
        String assumpKey;
        String assumpMapKey;
        Set<String> suppliers = new Set<String>();
        Set<String> commodities = new Set<String>();
        Set<String> markets = new Set<String>();
        Set<String> updateRecords = new Set<String>();
        Map<String,Assumption__c> assumMap = new Map<String,Assumption__c>();   
        List<String> assumptionKeyList = new List<String>();
        
        // Interate inserted/updated records to make a identical key
        for(Assumption__c assump : assumptionList){
            assumptionKeyList.add(assumpKey);
            suppliers.add(assump.Supplier__c);
            commodities.add(assump.Commodity__c);
            markets.add(assump.Market__c);
            if(assump.Id <> Null){
                updateRecords.add(assump.Id);
            }
        }
        // Fetch relivant records from database
        for(Assumption__c assump : [Select Id, Market__c ,Supplier__c,Assumption_Key__c,Commodity__c,
                                    Business_Size__c,Type__c,Pricing_Type__c,Name
                                    From Assumption__c 
                                    Where Active__c = true AND Market__c IN : markets
                                    AND Supplier__c IN : suppliers AND ID Not IN: updateRecords
                                    AND Commodity__c IN : commodities]){
                                        assumpMapKey = assump.Market__c + '~' + assump.Supplier__c + '~' + assump.Commodity__c + '~' + assump.Business_Size__c + '~' + assump.Type__c + '~' + assump.Pricing_Type__c;
                                        assumMap.put(assumpMapKey, assump);
                                    }
        // Check the record exist in database
        for(Assumption__c assump : assumptionList){
            assumpKey = assump.Market__c + '~' + assump.Supplier__c + '~' + assump.Commodity__c + '~' + assump.Business_Size__c + '~' + assump.Type__c + '~' + assump.Pricing_Type__c;
            if(assump.Active__c && assumMap.containsKey(assumpKey)){ // Check for exiting when insert
                assump.addError(System.Label.Identical_Record_Error_Label  + assumMap.get(assumpKey).Id + ' Record Number : ' + assumMap.get(assumpKey).Name);
            }
        }       
    } 
}