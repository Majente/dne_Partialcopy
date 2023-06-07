public class QuoteLineTriggerHandler {
@future
    public static void updateOli(List<string> itemIdList){
        Set<id> quoteidSet = new Set<id>();
        decimal additionalValues;
        List<SBQQ__QuoteLine__c> QliList = new List<SBQQ__QuoteLine__c>();
        Set<String> siteNameSet = new Set<String>();
        For(SBQQ__QuoteLine__c qli: [select id,SBQQ__Quote__c,Add_On_Fee__c,Site__r.Name from SBQQ__QuoteLine__c where id IN: itemIdList]){
            system.debug('qli.Add_On_Fee__c ::'+qli.Add_On_Fee__c);
            system.debug('qli.Site__r.Name::'+qli.Site__r.Name);
            System.debug('qli.Add_On_Fee__c:::'+qli.Add_On_Fee__c);
            additionalValues = qli.Add_On_Fee__c;
            quoteidSet.add(qli.SBQQ__Quote__c); 
            QliList.add(qli);
        }
        system.debug('QliList ::'+QliList);
        set<id> oppidSet = new set<id>();
        For(SBQQ__Quote__c quoteObj : [Select id,Supplier_Price__c,Selling_Price__c,SBQQ__StartDate__c,SBQQ__Opportunity2__c,
                                       Administration_Fee__c,SBQQ__SubscriptionTerm__c,Supplier__c,margin__c,
                                       SBQQ__Opportunity2__r.Main_Opportunity__r.Flow_Date__c,SBQQ__Opportunity2__r.Main_Opportunity__r.Subscription_Term__c
                                       From SBQQ__Quote__c 
                                       Where id IN: quoteidSet])
        {
            oppidSet.add(quoteObj.SBQQ__Opportunity2__c);
        }
        system.debug('oppidSet ::'+oppidSet);
        Map<string,opportunity> OppMap = new Map<string,opportunity>();
        for(Opportunity OppWithsup : [SELECT Id, Market__c,Supplier__c, Supplier__r.Use_For_calculation__c FROM Opportunity WHERE id IN: oppidSet]){
            if(OppWithsup.Supplier__c != null){
                if(OppWithsup.Supplier__r.Use_For_calculation__c == true){
                    OppMap.put(OppWithsup.Supplier__c, OppWithsup);
                }
            }
        }
        List<OpportunityLineItem> itemlist = new List<OpportunityLineItem>();
        For(OpportunityLineItem oli: [select id,OpportunityId,Opportunity.Supplier__c,TotalPrice,Site__r.Name from OpportunityLineItem where OpportunityId IN: oppidSet]){
            system.debug('oli.TotalPrice :'+oli.TotalPrice);
            system.debug('oli.Site__r.Name::'+oli.Site__r.Name);
            if(OppMap.containsKey(oli.Opportunity.Supplier__c)){
                system.debug('additionalValues::'+additionalValues);
                oli.TotalPrice = oli.TotalPrice + additionalValues;
            }
            itemlist.add(oli);
        }
        system.debug('itemlist ::'+itemlist);
        if(itemlist.size()>0){
            update itemlist;
        }
    }
}