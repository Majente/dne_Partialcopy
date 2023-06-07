public class MergeUtility {
    
    public static void mergeData(String winningAcctId, List<Id> duplicateAccounts){
        List<Opportunity> opptList = new List<Opportunity>();
        List<Contact> contList = new List<Contact>();
        List<Contract> contractList = new List<Contract>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<Site__c> siteList = new List<Site__c>();
        List<Site__c> listTobeDelete = new List<Site__c>();
        
        // fetch All Opportunities
        for(Opportunity opp : [SELECT Id,AccountId FROM Opportunity WHERE AccountId IN: duplicateAccounts]){
            opp.AccountId = winningAcctId;
            opptList.add(opp);
        }
        System.debug('opptList^^' + opptList.size());
        
        // Fetch All Contacts
        for(Contact cont : [SELECT Id,AccountId FROM Contact WHERE AccountId IN: duplicateAccounts]){
            cont.AccountId = winningAcctId;
            contList.add(cont);
        }
        System.debug('contList^^' + contList.size());
        
        // Fetch All Sites
        for(Site__c siteRec : [SELECT Id,Contract__c,Contract_type__c,Account__c,Market__c,Opportunity__c,
                               Service_Address_As_Parent__c,Site_Market_Account_Name__c,Name,Type__c,Unit_of_Measure__c,
                               Volume__c FROM Site__c WHERE Account__c IN: duplicateAccounts])
        {
            listTobeDelete.add(siteRec);
            Site__c newSite = new Site__c();
            newSite = siteRec;
            newSite.Account__c = winningAcctId;
            siteList.add(newSite);
        }
        System.debug('siteList^^' + siteList.size());
        System.debug('listTobeDelete^^' + listTobeDelete.size());
        
        // Fetch All Contracts
        for(Contract cont : [SELECT Id,AccountId FROM Contract WHERE AccountId IN: duplicateAccounts])
        {
            cont.AccountId = winningAcctId;
            contractList.add(cont);
        }
        System.debug('contractList^^' + contractList.size());
        // Fetch All Notes
        // Fetch All Files
        // Fetch All Quotes
        for(SBQQ__Quote__c quoteRec : [SELECT Id,SBQQ__Account__c FROM SBQQ__Quote__c WHERE SBQQ__Account__c 
                                       IN: duplicateAccounts])
        {
            quoteRec.SBQQ__Account__c = winningAcctId;
            quoteList.add(quoteRec);   
        }
        System.debug('quoteList^^' + quoteList.size());
        
        try{
            if(opptList.size() > 0){
                UPDATE opptList;
                System.debug('opportunity updated.');
            }
            if(contList.size() > 0){
                UPDATE contList;
                System.debug('contact updated.');
            }
            if(listTobeDelete.size() > 0){
                UPDATE listTobeDelete;
                System.debug('site deleted.');
            }
            if(siteList.size() > 0){
                UPDATE siteList;
                System.debug('site updated.');
            }
            /*if(contractList.size() > 0){
                UPDATE contractList;
                System.debug('contract updated.');
            }*/
            if(quoteList.size() > 0){
                UPDATE quoteList;
                System.debug('quote updated.');
            }
        }catch(Exception ex){
            System.debug('exception occured on merge data^^' + ex.getMessage());
        }
    }
    
}