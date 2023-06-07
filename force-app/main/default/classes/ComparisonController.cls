public class ComparisonController {
    @AuraEnabled
    public static DataWrapper OldOpportunities(){
        List<DataWrapper> WrapperList = new List<DataWrapper>();
        DataWrapper wrap = new DataWrapper();
        List<Opportunity> oldOppotunities = new List<Opportunity>();
        Map<string,Opportunity> OldOppMap = new Map<string,Opportunity>();
        List<Opportunity> RenewalOppotunities = new List<Opportunity>();
        
        Map<string,List<Opportunity>> RenewMap = new Map<string,List<Opportunity>>();
        List<string> OppNameList = new List<string>{'Test Account - TEST OPP -15-09-001'};
            //List<string> OppNameListRenew = new List<string>{'Test Account - 15-09-001-2022-11-01 - Renewal','Test Account - 15-09-001-2022-11-01 - Renewal'};   
            For(Opportunity opp: [SELECT Id, AccountId,Account.Name, Name, Commodity_Type__c, Flow_Date__c, End_date__c, Subscription_Term__c, Annual_Volume__c, Margin__c,Amount 
                                  FROM Opportunity where RecordTypeId !='012f4000000fXfZAAU'
                                  limit 80]){
                                      OldOppMap.put(opp.id,opp);
                                      boolean OppWithoutRenewal = (!opp.Name.contains('Renewal'));
                                      system.debug('OppWithoutRenewal'+OppWithoutRenewal);
                                      if(OppWithoutRenewal == true){
                                          oldOppotunities.add(opp);
                                          wrap.OldOpp = oldOppotunities;
                                      }
                                      
                                      For(Opportunity opp2: [SELECT Id,RecordTypeId, AccountId,Account.Name, Name, Commodity_Type__c, Flow_Date__c, End_date__c, Subscription_Term__c, Annual_Volume__c, Margin__c,Amount FROM Opportunity
                                                             where id =:opp.id]){
                                                                 boolean OppWithRenewal = opp2.Name.contains('Renewal');
                                                                 system.debug('OppWithRenewal'+OppWithRenewal);
                                                                 if(OppWithRenewal == true){
                                                                     if(opp2.AccountId == opp.AccountId && opp2.Commodity_Type__c == opp.Commodity_Type__c
                                                                        ){
                                                                            RenewalOppotunities.add(opp2);
                                                                            wrap.RenewalOpp = RenewalOppotunities;
                                                                        }
                                                                 }
                                                             }
                                  }
        
        
        WrapperList.add(wrap);
        system.debug('WrapperList::^'+WrapperList);
        return wrap;
    }
    public class DataWrapper{
        @AuraEnabled public List<Opportunity> OldOpp{get;set;}
        @AuraEnabled public List<Opportunity> RenewalOpp{get;set;}
    }
}