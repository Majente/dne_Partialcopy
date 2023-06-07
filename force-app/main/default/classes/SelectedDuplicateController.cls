public class SelectedDuplicateController {
    
    public string getUrlId;
    public List<Account_Dups__c> AccDupsList{get;set;}
    public List<Account> AccountList{get;set;}
    public string masterAccountName{get;set;}
    public string masterAccountId{get;set;}
    public string masterRecordId{get;set;}
    //public String test {get;set;}
    public Map<Id, Account> AccDupsListMap;
    public Set<Id> DupId;
    public List<DataWrapper> WrapperList {get; set;}
    public Map<Id, Account_Dups__c> DupMap {get; set;}
    
    public SelectedDuplicateController(){
        DupId = new Set<Id>();
        DupMap = new Map<Id, Account_Dups__c>();
        getUrlId = apexpages.currentpage().getparameters().get('id');      
        system.debug('getUrlId'+getUrlId);
        AccDupsList = [select name,Master_Account__c,Master_Account__r.Name, Duplicate_Account__r.Name, Number_of_Opportunity__c, Last_Activity_Date__c from Account_Dups__c where Master_Account__c =:getUrlId ];  
        system.debug('AccDupsList'+AccDupsList);
        WrapperList = new List<DataWrapper>();
        if(AccDupsList.size() > 0) {
            for(Account_Dups__c ac : AccDupsList) {
                DupId.add(ac.Duplicate_Account__c);
                /*if(!DupMap.containsKey(ac.Duplicate_Account__c)){
                    DupMap.put(ac.Duplicate_Account__c, new List<Account_Dups__c>());
                }
                DupMap.get(ac.Duplicate_Account__c).add(ac);
                system.debug('DupMap' + DupMap);*/ 
                                DupMap.put(ac.Duplicate_Account__c, ac);

                
            }  
        }    
         system.debug('DupMapsize' + DupMap.size());    
        AccountList = [SELECT id,Name FROM Account WHERE Id IN : DupId];
        system.debug('ContactList List is ' + AccountList);
        AccDupsListMap = new Map<Id, Account>();
        if(AccountList.size() > 0) {
            for(Account con : AccountList) {
                AccDupsListMap.put(con.id, con);
            }
        }
        for(Id ContId : AccDupsListMap.keySet()) {
            WrapperList.add(new DataWrapper(DupMap.get(ContId), AccDupsListMap.get(ContId)));
        }
        Account acNew = [select id,name from Account where id=:getUrlId];
       system.debug('acNew'+acNew);
        system.debug('WrapperList'+WrapperList.size());
        WrapperList.add(new DataWrapper(null,acNew));
        system.debug('WrapperList'+WrapperList);
        system.debug('WrapperList'+WrapperList.size());

    }
    
    public void getMasterAccId(){
        String fetchId = ApexPages.currentPage().getParameters().get('fetchId');
        String MstrId = getUrlId;
        system.debug('fetchId :: '+fetchId);
        system.debug('MstrId :: '+MstrId);
        
        List<Account_Dups__c> DupsList = [select name,Master_Account__c,Master_Account__r.Name, Duplicate_Account__r.Name, Number_of_Opportunity__c, Last_Activity_Date__c from Account_Dups__c where Master_Account__c =: MstrId limit 1];
        system.debug('MstrId :: '+DupsList);
        
        List<Account_Dups__c> listTobeDelete = new List<Account_Dups__c>();
        List<Account_Dups__c> listTobeInsert = new List<Account_Dups__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Opportunity opp : [SELECT Id FROM Opportunity WHERE AccountId =: MstrId]){
            oppList.add(opp);
        }
        
        for(Account_Dups__c Dup : DupsList)
        {
            listTobeDelete.addAll(DupsList);
            if(Dup.Duplicate_Account__c != fetchId)
            {
                Account_Dups__c dupRec = new Account_Dups__c();
                dupRec.Master_Account__c = fetchId;
                duprec.Duplicate_Account__c = Dup.Duplicate_Account__c;
                dupRec.Number_of_Opportunity__c = Dup.Number_of_Opportunity__c;
                listTobeInsert.add(dupRec);
            }
        }
        
        Account_Dups__c dupRec = new Account_Dups__c();
        dupRec.Master_Account__c = fetchId;
        dupRec.Duplicate_Account__c = MstrId;
        dupRec.Number_of_Opportunity__c = oppList.size();
        listTobeInsert.add(dupRec);
        
        System.debug('listTobeInsert :: ' + listTobeInsert);
        System.debug('listTobeDelete :: ' + listTobeDelete);
        
        
        try{
            if(listTobeDelete.size() > 0){
                DELETE listTobeDelete;
            }
            if(listTobeInsert.size() > 0){
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Master Account is Changed SuccessFully!'));
                
                INSERT listTobeInsert;   
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Check button is clicked'));
            }
        }
        catch(Exception ex){
            System.debug('exception occured :: ' + ex.getMessage());
        }
    }
    
    public class DataWrapper
    { 
        public Account_Dups__c DupAccData {get;set;}
        public Account AccList {get;set;}
        public DataWrapper(Account_Dups__c DupAccData, Account AccList) {
            this.DupAccData = DupAccData;
            this.AccList = AccList;
        }        
    }
}