public class DupsTestController {
    
    @AuraEnabled
    public static List<wrapperData> getaccountsDups(String accId){
        List<wrapperData> wrapData = new List<wrapperData>();
        
        List<Account_Dups__c> DupsList = [Select Id, Name,Duplicate_Account__c, Duplicate_Account__r.Name,Master_Account__c,Master_Account__r.Name, Number_of_Opportunity__c, Last_Activity_Date__c FROM Account_Dups__c Where Master_Account__c =: accId];              
       	List<Account> LstMasterAccount = [select id,name from Account where id =: accId];
        system.debug('acc'+LstMasterAccount);
        for(Account_Dups__c ac : DupsList){
            wrapperData wrp = new wrapperData();
            wrp.accID = ac.Id;
            wrp.Name = ac.Name;
            if(ac.Master_Account__r.Name == null || ac.Master_Account__r.Name == '' || ac.Master_Account__r.Name.length() == 0)
            {
                wrp.MatserAccount = '';
            }
            else
            {
                wrp.MatserAccount = ac.Master_Account__r.Name;
            }
            if(ac.Duplicate_Account__r.Name == null || ac.Duplicate_Account__r.Name == '' || ac.Duplicate_Account__r.Name.length() == 0)
            {
                wrp.DuplicateAccount = '';
            }
            else
            {
                wrp.DuplicateAccount = ac.Duplicate_Account__r.Name;
            }
            wrp.NumberOfOpportunity = ac.Number_of_Opportunity__c;
            wrp.LastActivityDate = ac.Last_Activity_Date__c;
            wrapData.add(wrp);
            
            
        }
     	system.debug(wrapData);
        return wrapData;
    }
    
    @AuraEnabled
    public static void selectedRow(List<String> selectList){
        system.debug(selectList);
    }
    
    public class wrapperData
    {
        @AuraEnabled
        public String accID {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled 
        public String MatserAccount {get;set;}
        @AuraEnabled 
        public String DuplicateAccount {get;set;}
        @AuraEnabled 
        public decimal NumberOfOpportunity {get;set;}
        @AuraEnabled 
        public DateTime LastActivityDate {get;set;}
        
    }
}