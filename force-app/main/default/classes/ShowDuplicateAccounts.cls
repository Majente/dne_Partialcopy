public class ShowDuplicateAccounts {
    
    public string getUrlId;
    public List<DataWrapper> WrapperList {get; set;}
    public String newMasterId {get; set;}
    public List<String> SelectedDuplicate {get; set;}
    public string SelectedMasterId {get;set;}
    public set<id> SelectedDuplicateSet {get; set;}
    
    public showDuplicateAccounts(){
        SelectedDuplicate = new List<string>();
        SelectedDuplicateSet = new set<id>();
        getUrlId = apexpages.currentpage().getparameters().get('id');      
        system.debug('getUrlId'+getUrlId);
        WrapperList = new List<DataWrapper>();
        DataWrapper dw =  new DataWrapper(null);
        List<AggregateResult> aggList = [Select count(id) cnt, AccountId, Account.LastActivityDate lad from Opportunity group by AccountId, Account.LastActivityDate having AccountId = : getUrlId order by count(id) desc];
        dw.RecId = getUrlId;
        if(aggList.size() > 0 ){
            dw.NoOfOpps = Integer.valueOf(aggList[0].get('cnt'));
            dw.LastActivityDate = Date.valueOf(aggList[0].get('lad'));
        }
        dw.isMaster = true;
        WrapperList.add(dw);
        for(Account_Dups__c ac : [Select name,Master_Account__c,Master_Account__r.Name, Duplicate_Account__r.Name, Number_of_Opportunity__c, Last_Activity_Date__c 
                                  From Account_Dups__c 
                                  Where Master_Account__c =:getUrlId ]) {
                                      if(WrapperList.size() == 1){
                                          WrapperList[0].Name =  ac.Master_Account__r.Name;
                                      }
                                      dw =  new DataWrapper(ac);
                                      dw.RecId = ac.Duplicate_Account__c;
                                      dw.Name = ac.Duplicate_Account__r.Name;
                                      dw.NoOfOpps = Integer.valueOf(ac.Number_of_Opportunity__c);
                                      dw.LastActivityDate = ac.Last_Activity_Date__c;
                                      WrapperList.add(dw);
                                  }  
    }
    
    public PageReference changeMasterAccount(){ 
        
        boolean isSelected = true;
        
        getSelectedMaster();
        string SMasterID = SelectedMasterId;
        system.debug('SMasterID'+SMasterID);
        for(DataWrapper dWrapper : WrapperList){
            if(dWrapper.isSelected == false){
                system.debug('dWrapper.isSelected'+dWrapper.isSelected);
                if(dWrapper.RecId != SMasterID){
                    SelectedDuplicateSet.add(dWrapper.RecId); 
                }
            }
        }
        system.debug('SelectedDuplicateSet'+SelectedDuplicateSet);
        
        for(DataWrapper dWrapper : WrapperList){
            if(!dWrapper.isMaster){
                isSelected = false; 
            }else{
                isSelected = true;
                newMasterId = dWrapper.RecId;
                break;
            }
        }
        
        System.debug('isSelected^^' + isSelected);
        system.debug('newMasterId :: '+newMasterId);
        
        if(!isSelected){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select atleast one account for master account.'));
            
        }
        List<Account_Dups__c> listTobeDelete = new List<Account_Dups__c>();
        List<Account_Dups__c> listTobeInsert = new List<Account_Dups__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Opportunity opp : [SELECT Id FROM Opportunity WHERE AccountId =: getUrlId]){
            oppList.add(opp);
        }
        
        for(DataWrapper dWrapper : WrapperList)
        {
            if(newMasterId != getUrlId){
                
                if(dWrapper.dupRecord != null){
                    listTobeDelete.add(dWrapper.dupRecord);
                }
                
                if(dWrapper.RecId != newMasterId)
                {
                    
                    Account_Dups__c dupRec = new Account_Dups__c();
                    dupRec.Master_Account__c = newMasterId;
                    duprec.Duplicate_Account__c = dWrapper.RecId;
                    dupRec.Number_of_Opportunity__c = dWrapper.NoOfOpps;
                    listTobeInsert.add(dupRec);
                }
            }
        }
        System.debug('listTobeInsert :: ' + listTobeInsert.size());
        System.debug('listTobeDelete :: ' + listTobeDelete.size());
        
        
        try{
            if(listTobeDelete.size() > 0){
                DELETE listTobeDelete;
                system.debug('listTobeDelete'+listTobeDelete);
            }
            if(listTobeInsert.size() > 0){
                INSERT listTobeInsert;   
                system.debug('listTobeInsert'+listTobeInsert);
            }
        }
        catch(Exception ex){
            System.debug('exception occured :: ' + ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,String.valueOf(ex)));
            
        } 
        string masterId;
        for(Account_Dups__c InsertedDubs: listTobeInsert){
            masterId = InsertedDubs.Master_Account__c;
        }
        
        if(masterId == null){
            masterId = getUrlId;
        }
        system.debug('masterId'+masterId);
      	system.debug('SelectedDuplicateSet' +SelectedDuplicateSet);
        ChangeDuplicates(masterId);
        PageReference pgRef = new PageReference('/apex/SelectedDuplicate?id='+masterId);
        pgRef.setRedirect(true);
        return pgRef;
        
    }
    public void getSelectedMaster(){
        
        for(DataWrapper dWrapper : WrapperList){
            if(!dWrapper.isMaster){
                SelectedMasterId = getUrlId; 
            }else{
                SelectedMasterId = dWrapper.RecId;
                break;
            }
        }
        system.debug('SelectedMasterId :: '+SelectedMasterId);
        
    }
 /*   public void getSelectedDups(){
        
        getSelectedMaster();
        string SMasterID = SelectedMasterId;
        system.debug('SMasterID'+SMasterID);
        for(DataWrapper dWrapper : WrapperList){
            if(dWrapper.isSelected == false){
                system.debug('dWrapper.isSelected'+dWrapper.isSelected);
                if(dWrapper.RecId != SMasterID){
                    SelectedDuplicateSet.add(dWrapper.RecId); 
                }
            }
        }
        system.debug('SelectedDuplicateSet'+SelectedDuplicateSet);
        
    }*/
    
    public void ChangeDuplicates(string masterId){
        string selectedMasterID = masterId;
        system.debug('SelectedDuplicateSet' +SelectedDuplicateSet);
        
        List<Account_Dups__c> listTobeDelete = new List<Account_Dups__c>();
        
        
        for(id DupsId: SelectedDuplicateSet){
            for(Account_Dups__c dups: [SELECT Id,Name, Master_Account__c, Duplicate_Account__c FROM Account_Dups__c 
                                       where Master_Account__c =:selectedMasterID AND Duplicate_Account__c =:DupsId]){
                                           system.debug('dups ###'+dups);
                                           listTobeDelete.add(dups);                  
                                       }
        }
        system.debug('listTobeDelete ^^^'+listTobeDelete);
        system.debug('listTobeDeleteSize ^^^'+listTobeDelete.size());
        try{
            if(listTobeDelete.size() > 0){
                DELETE listTobeDelete;
                system.debug('listTobeDelete'+listTobeDelete);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Changes Made Successfully!'));
                //return pgRef;
            }
        }
        catch(Exception ex){
            System.debug('exception occured :: ' + ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,String.valueOf(ex)));
            //return null;
        } 
        
        getUrlId = selectedMasterID;
        system.debug('getUrlId'+getUrlId);
        //return pgRef;
    }
    
    
    public class DataWrapper
    { 
        public String RecId {get;set;}
        public String Name {get;set;}
        public Integer NoOfOpps {get;set;}
        public DateTime LastActivityDate {get;set;}
        Public Boolean isMaster  {get;set;}
        Public Boolean isSelected  {get;set;}
        public Account_Dups__c dupRecord {get;set;}
        public DataWrapper(Account_Dups__c dupRecord) {
            isMaster = false;
            isSelected = true;
            NoOfOpps = 0;
            this.dupRecord = dupRecord;
        }        
    }
}