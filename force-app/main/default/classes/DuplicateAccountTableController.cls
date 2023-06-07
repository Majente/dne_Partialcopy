public class DuplicateAccountTableController {
    
    //public List<Account_Dups__c> AccDupsList { get; set; }
    public List<Account> MasterAccList { get; set; }
    public Map<Id, List<Account_Dups__c>> AccDupsListMap { get; set; }
    Set<Id> MasterAccIds = new Set<Id>();
    Map<Id, Account> AccMap = new Map<Id, Account>();
    public List<DataWrapper> WrapperList { get; set; }
    public String selectedId { get; set; }
    public Integer countDupAcc { get; set; }
    public Map<Id, Integer> AccDupsListSizeMap { get; set; }
    public Map<String, List<Account_Dups__c>> dataMap  { get; set; }
    
    public DuplicateAccountTableController() { 
        try{
            dataMap = new Map<String, List<Account_Dups__c>>();
            Set<String> AccIds = new Set<String>();
            Map<Id,Account> AllAccounts =  new Map<Id,Account> ();
            for(Account_Dups__c ad : [SELECT Id, Name,Master_Account__c,Master_Account__r.id, Duplicate_Account__r.Name, Duplicate_Account__c, Number_of_Opportunity__c FROM Account_Dups__c Limit 1000])
            {
                if(!dataMap.containsKey(ad.Master_Account__c)){
                    dataMap.put(ad.Master_Account__c, new List<Account_Dups__c>());
                }
                dataMap.get(ad.Master_Account__c).add(ad);
                AccIds.add(ad.Master_Account__c);
                AccIds.add(ad.Duplicate_Account__c);
            }
            for(Account a :[Select Id, Name From Account Where Id IN : AccIds]){
                AllAccounts.put(a.Id,a);
            }
            //AccDupsList = [SELECT Id, Name,Master_Account__c,Master_Account__r.id, Duplicate_Account__r.Name, Duplicate_Account__c, Number_of_Opportunity__c FROM Account_Dups__c ];
            AccDupsListMap = new Map<Id, List<Account_Dups__c>>();
            WrapperList = new List<DataWrapper>();
            AccDupsListSizeMap = new Map<Id, Integer>();
            if(dataMap.size() > 0) {
                for(String masertId : dataMap.KeySet()) {
                    //if(!AccDupsListSizeMap.containsKey(adups.Master_Account__r.id)){
                    
                        AccDupsListSizeMap.put(masertId, dataMap.get(masertId).size());
                        system.debug('AccDupsListSizeMap'+AccDupsListSizeMap);
                        MasterAccIds.add(masertId);
                        system.debug('MasterAccIds'+MasterAccIds);
                    //}                                       
                }
                /*
                for(Account_Dups__c adups : dataMap.values()) {
                    if(!AccDupsListMap.containsKey(adups.Master_Account__r.id)){
                        AccDupsListMap.put(adups.Master_Account__r.id, new List<Account_Dups__c>());
                        MasterAccIds.add(adups.Master_Account__r.id);
                        system.debug('MasterAccIds'+MasterAccIds);
                    }
                    if( AccDupsListMap.get(adups.Master_Account__r.id).size()<3){   
                        if(adups.Id != null){
                            AccDupsListMap.get(adups.Master_Account__r.id).add(adups);
                        }                   
                    }
                }
                MasterAccList = [SELECT id,Name FROM Account WHERE id IN : MasterAccIds];
                */
            }                       
                for(String masertId : dataMap.KeySet()) {                                                                   
                    WrapperList.add(new DataWrapper(AllAccounts.get(masertId), dataMap.get(masertId)));                  
                }
           
        }catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'No records available');
            ApexPages.addMessage(msg);
        }
    }
    
    public class DataWrapper {
        public Account AccData { get; set; }
        public List<Account_Dups__c> DupsList { get; set; }
        public Integer CountDupAcc { get; set; }
        public DataWrapper(Account AccData, List<Account_Dups__c> DupsList) {
            this.AccData = AccData;
            this.DupsList = DupsList;
            this.CountDupAcc = DupsList.size();
        }
    }
}