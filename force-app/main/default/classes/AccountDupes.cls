public with sharing class AccountDupes
{

    public List<DupsInfoWrapper> DupesWrapper {get; set;}    
    //added for paginnation
    public List<List<DupsInfoWrapper>> listofDupesWrapper {get; set;}
    
    public AccountDupes()
    {
  DupesWrapper = new List<DupsInfoWrapper>();
  listofDupesWrapper = new List<List<DupsInfoWrapper>>();
        getDups();
    } 
     
    public void getDups()   
    {
        for(Account_Dups__c s:[Select id, Name, Duplicate_Account__r.Name,Master_Account__r.Name, Number_of_Opportunity__c, Last_Activity_Date__c FROM Account_Dups__c])
        {            
            DupesWrapper.add(new DupsInfoWrapper(s)); 
            if(DupesWrapper.size() == 999)
   {
    listofDupesWrapper.add(DupesWrapper);
     DupesWrapper= new List<DupsInfoWrapper>();
            }                
        } 
        if(DupesWrapper.size() != 0){
   listofDupesWrapper.add(DupesWrapper);
     }   
        
    }
    
 //Wrapper class
    public class DupsInfoWrapper
    {
        public Account_Dups__c dObj{get;set;}
        public Boolean checked {get;set;}
        public DupsInfoWrapper(Account_Dups__c dup)
        {
            dObj = dup;  
            checked=false;  
        } 
    }
}