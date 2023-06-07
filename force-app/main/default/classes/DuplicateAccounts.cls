public class DuplicateAccounts {
    public static Map<String,Integer> getRelatedOpp(Set<Id> accountIds){
        Map<String,List<Opportunity>> accWithOpportunity = new Map<String,List<Opportunity>>();
        Map<String,Integer> accIdWithOppCount = new Map<String,Integer>();
        
        for(Opportunity oppt : [SELECT Id,AccountId, Account.LastActivityDate FROM Opportunity WHERE AccountId IN: accountIds]){
            if(!accWithOpportunity.containsKey(oppt.AccountId+'~'+oppt.Account.LastActivityDate)){
                accWithOpportunity.put(oppt.AccountId+'~'+oppt.Account.LastActivityDate, new List<Opportunity>());
            }
            accWithOpportunity.get(oppt.AccountId+'~'+oppt.Account.LastActivityDate).add(oppt);
        }
        System.debug('accWithOpportunity^^' + accWithOpportunity.size());
        if(accWithOpportunity.size() > 0){
            for(String accId : accWithOpportunity.keySet()){
                accIdWithOppCount.put(accId,accWithOpportunity.get(accId).size());
            }
        }
        System.debug('accIdWithOppCount^^' + accIdWithOppCount);
        return accIdWithOppCount;
    }

}