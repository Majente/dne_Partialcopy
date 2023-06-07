public class PriceChartTreeViewController {

    public static Id recordId;
    public static String selectedMarket;
    public String sObjectName{get;set;}
    Set<Id> accountIds;
    List<Account> selecAccList ;
    
    public Map<Id,TreeWrapper> addressSiteMap {get;set;} 
    
    public String jsonDataForAddressSite {get;set;}
    
    public PriceChartTreeViewController(){
        //recordId = parentID ; 
         recordId = '0010q00000DRz0FAAT' ;
        //selectedMarket = market;
        selectedMarket = 'Alberta';
        
         addressSiteMap = new Map<Id,TreeWrapper>();
        TreeWrapper treewrp ;
        
        for(Account addressAccount: [Select Id, name,ParentId,BillingState,Total_Annual_Volume_ElectrictIy__c,Total_Annual_Volume_Gas__c,
                                     Market__r.Name from Account 
                                     where parentId=:recordId 
                                    ] ){
            treewrp = new TreeWrapper(recordId,addressAccount) ;  
            addressSiteMap.put(addressAccount.Id,treewrp);                            
        } 
        
        System.debug('addressSiteMap=='+addressSiteMap);
        
        for(Site__c site:[Select Id, name,Market__c,Volume__c,Type__c , Unit_of_Measure__c ,Account__c 
                                     from Site__c where Account__c IN:addressSiteMap.keySet()]){
            addressSiteMap.get(site.Account__c).addSite(site);
        }
        
        System.debug('addressSiteMap=='+addressSiteMap);
        
        jsonDataForAddressSite= JSON.serialize(addressSiteMap);
        
    }
    
    @AuraEnabled
    
    public static List<Account> getAccountListByOpportunity(ID parentID , Id market){
        
        recordId =parentID ; 
        selectedMarket = market;
        List<Account> accountList = [Select Id, name,ParentId,BillingState,Total_Annual_Volume_ElectrictIy__c,Total_Annual_Volume_Gas__c,
                                     Market__r.Name from Account 
                                     where parentId=:recordId AND Market__c =:selectedMarket
                                      ] ; 
        
        return accountList ;
        
        
    }
    
    public class TreeWrapper{
        
        public String parentAccountId {get;set;}
        public Account parentAccountDetail {get;set;}
        public Account addressAccount {get;set;}
        public List<Site__c> siteList {get;set;}
        
        public TreeWrapper(String parentId){
            this.parentAccountId = parentId;
            this.addressAccount = new Account();
            this.siteList = new List<Site__c>();
            this.parentAccountDetail = [Select Id, Name from Account where Id=: parentId] ;
        }
        
        public TreeWrapper(String parentId, Account acc){
            this.parentAccountId = parentId;
            this.addressAccount = acc;
            this.siteList = new List<Site__c>();
            this.parentAccountDetail = [Select Id, Name from Account where Id=: parentId] ;
        }
        
        public void addSite(Site__c site){
            this.siteList.add(site);
        }
	        
    }
    
    
    @AuraEnabled
    
    public static List<Site__c> getSiteList(ID parentID, String market, String selectedType){
        
        
        //parentID ='0010q00000MnBlzAAF' ;
        
        List<Site__c> siteList = [Select Id, name,Market__c,Volume__c,Type__c , Unit_of_Measure__c  
                                     from Site__c where Account__c =:parentID And Type__c =:selectedType ] ; 
        
        return siteList ;
        
        
    } 
    
    
}