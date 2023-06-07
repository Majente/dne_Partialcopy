public  without sharing  class PaginationController {
    public List<Account> lstAcct = new List<Account>();
    public List<innerClass> lstInner {get;set;}
    public String selectedRowIndex {get;set;}
    public Integer index {get;set;}
    public Integer count = 1;
    public Id recordId;
    
    public Site__c site {get;set;}
    
    /*********************************************************
@Name 			: AddSiteAccountController
@Parameters 	: ApexPages.StandardController
@Reutrn type 	: void
@Description 	: Constructor
********************************************************/
    public PaginationController(ApexPages.StandardController stdController)
    {   
        recordId = stdController.getRecord().Id;
        lstInner = new List<innerClass>();
        addMore();
        selectedRowIndex = '0';
        site = new Site__c();
        
        
    }/*End Constructor*/
    
    /*********************************************************
@Name 			: Add
@Parameters 	: 
@Reutrn type 	: void
********************************************************/
    public void Add()
    {
        count = count+1;
        addMore();   
    }
    
    /*********************************************************
@Name 			: Save
@Parameters 	: 
@Reutrn type 	: PageReference
@Description 	: This method to insert account List.
********************************************************/
    public PageReference  Save()
    {
        System.debug('Calling Save function.');
        PageReference pr = new PageReference('/apex/AddSiteAccount');
        for(Integer j = 0;j<lstInner.size();j++)
        {
            lstAcct.add(lstInner[j].acct);  
        }
        try{
            
            insert lstAcct;
            System.debug('Inserted records' + lstAcct); 
            
            
        }catch(Exception ex){
            System.debug('Error while saving' + ex.getMessage());
        }
        pr.setRedirect(true);
        return pr;
    }
    
    /*********************************************************
@Name 			: addMore
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Begin addMore
********************************************************/
    
    public void addMore()
    {
        //call to the iner class constructor
        innerClass objInnerClass = new innerClass(count);       
        //add the record to the inner class list
        lstInner.add(objInnerClass);    
        system.debug('lstInner---->'+lstInner);            
    }   
    
    /*********************************************************
@Name 			: Remove
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Remove site
********************************************************/
    public void Remove()
    {  
        system.debug('selected row index---->'+ selectedRowIndex);
        lstInner.remove(Integer.valueOf(selectedRowIndex)-1);    
        count = count - 1;
        
    }
    
    /*********************************************************
@Name 			: innerClass
@Parameters 	: 
@Reutrn type 	: 
@Description 	: recCount acts as a index for a row. This will be helpful to identify the row to be deleted 
********************************************************/
    public class innerClass
    {  
        public String recCount {get;set;}       
        public Account acct {get;set;}
        /*Inner Class Constructor*/
        public innerClass(Integer intCount)
        {
            recCount = String.valueOf(intCount);        
            /*create a new account*/
            acct = new Account();
        }/*End Inner class Constructor*/    
    }/*End inner Class*/
    
    /*********************************************************
@Name 			: getTypeValue
@Parameters 	: 
@Reutrn type 	: List<picklistWapper>
@Description 	: 
********************************************************/
    @auraEnabled
    public static List<picklistWapper> getTypeValue(){
        List<picklistWapper> selOption = new List<picklistWapper>();
        list < Schema.PicklistEntry > values = Site__c.getSObjectType().getDescribe().fields.getMap().get('Type__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry pv : values){
            selOption.add(new picklistWapper(pv.getLabel(), pv.getValue(), pv.isDefaultValue()));
        }
        return selOption;
    }
    
    /*********************************************************
@Name 			: getUOMValue
@Parameters 	: 
@Reutrn type 	: List<picklistWapper>
@Description 	: get uom values
********************************************************/
    @auraEnabled
    public static List<picklistWapper> getUOMValue(){
        List<picklistWapper> selOption = new List<picklistWapper>();
        list < Schema.PicklistEntry > values = Site__c.getSObjectType().getDescribe().fields.getMap().get('Unit_of_Measure__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry pv : values){
            selOption.add(new picklistWapper(pv.getLabel(), pv.getValue(), pv.isDefaultValue()));
        }
        return selOption;
    }
    
    /*********************************************************
@Name 			: getUOMValue
@Parameters 	: Id:parentAccId
@Reutrn type 	: List<AccountSiteWapper>
@Description 	: get Account Details
********************************************************/
    @auraEnabled    
    public static List<AccountSiteWapper> getAccountDetail(Id parentAccId){
        Account_Site__c acs = Account_Site__c.getOrgDefaults();
        Integer accSitesLimit = Integer.valueOf(acs.No_of_Account_Sites__c);
        System.debug('parentAccId:::'+parentAccId);
        Account parentAccDetail = [Select Id, Name,ShippingAddress,ShippingStreet,ShippingState,ShippingCountry,ShippingPostalCode,ShippingCity From Account where Id =: parentAccId];
        Map<Id, AccountSiteWapper > seviceAcctMap = new  Map<Id, AccountSiteWapper >();
        AccountSiteWapper accSiteAcct ;
        //LIMIT: accSitesLimit
        //Fetch all Service Address Accounts of Parent Account
        Map<String, List<String>> dependentMapVal = getDependentMap('Site__c', 'Type__c','Unit_of_Measure__c'); 
        system.debug('dependentMapVal::'+dependentMapVal); 
        for(Account serviceAccount : Database.query('Select id,name,BillingAddress,ShippingStreet,ShippingState,ShippingCountry,ShippingPostalCode,ShippingCity,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingAddress,Billing_address_same_as_parent__c,Service_address_same_as_parent__c,Market__c,Market__r.Name,Parent.Name From Account Where ParentId=: parentAccId AND RecordType.Name=\'Service Address\' ')){
            System.debug('serviceAccount:::'+serviceAccount);                              
            
            accSiteAcct = new  AccountSiteWapper(parentAccDetail,serviceAccount,dependentMapVal);
            seviceAcctMap.put(serviceAccount.Id, accSiteAcct);                             
        }
        
        System.debug('seviceAcctMap:::'+seviceAcctMap);
        System.debug('seviceAcctMap.values().size():::'+seviceAcctMap.values().size());
        
        For( Site__c site : [Select Id, Name, Volume__c,Account__c, 
                             Unit_of_Measure__c,Type__c      
                             From Site__c Where Account__c IN : seviceAcctMap.KeySet() ]){
                                 if(seviceAcctMap.containsKey(site.Account__c)){
                                     seviceAcctMap.get(site.Account__c).addSite(site);
                                 }
                             }
        
        if(seviceAcctMap.values().size()>0){
            system.debug('seviceAcctMap.values()::'+seviceAcctMap.values());
            return seviceAcctMap.values(); 
        }else{
            List<AccountSiteWapper> accountSiteWapper=new List<AccountSiteWapper>();
            accountSiteWapper.add(new AccountSiteWapper(parentAccDetail,dependentMapVal));
            return accountSiteWapper;
        }
    }
    
    /*********************************************************
@Name 			: saveAccounts
@Parameters 	: string:ListAccounts,Id:accId
@Reutrn type 	: List<ErrorSiteWapper>
@Description 	: save account
********************************************************/
    @auraEnabled    
    public static List<ErrorSiteWapper> saveAccounts(string ListAccounts, Id accId){
        System.debug('ListAccounts = '+ ListAccounts);
        System.debug('accId = '+ accId);
        List<AccountSiteWapper> wrapperList = (List<AccountSiteWapper>) System.JSON.deserialize(ListAccounts, List<AccountSiteWapper>.class);
        System.debug('wrapperList = '+ JSON.serialize(wrapperList));
        Account parentAccountDetail = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry
                                       From Account Where Id=:accId] ;
        RecordType serviceRT = [Select Id
                                From RecordType Where sObjectType = 'Account' And RecordType.Name='Service Address' Limit 1] ;
        Map<String,Account> uniqueServiceAddress = new Map<String,Account>();
        List<ErrorSiteWapper> errorList = new List<ErrorSiteWapper>();
        
        
        for(AccountSiteWapper accWrapper :wrapperList){
            if(String.isNotEmpty(accWrapper.serviceAddressAccount.Name)){
                String uniqueKey = accWrapper.serviceAddressAccount.Name + accWrapper.serviceAddressAccount.Market__c;
                uniqueKey = uniqueKey.trim();
                accWrapper.serviceAddressAccount.ParentId = accId;
                accWrapper.serviceAddressAccount.RecordTypeId = serviceRT.Id;
                Boolean sameAddrees = accWrapper.serviceAddressAccount.Service_address_same_as_parent__c;
                if(sameAddrees){
                    accWrapper.serviceAddressAccount.ShippingStreet=parentAccountDetail.BillingStreet;
                    accWrapper.serviceAddressAccount.ShippingCity=parentAccountDetail.BillingCity;
                    accWrapper.serviceAddressAccount.ShippingState=parentAccountDetail.BillingState;
                    accWrapper.serviceAddressAccount.ShippingPostalCode=parentAccountDetail.BillingPostalCode;
                    accWrapper.serviceAddressAccount.ShippingCountry=parentAccountDetail.BillingCountry;                
                }
                if(uniqueServiceAddress.containsKey(uniqueKey)){
                    if(uniqueServiceAddress.get(uniqueKey).Id != null && accWrapper.serviceAddressAccount == null){
                        uniqueServiceAddress.put(uniqueKey, uniqueServiceAddress.get(uniqueKey));
                    }else if(uniqueServiceAddress.get(uniqueKey).Id == null && accWrapper.serviceAddressAccount != null){
                        uniqueServiceAddress.put(uniqueKey, accWrapper.serviceAddressAccount);
                    }  
                }else{
                    uniqueServiceAddress.put(uniqueKey, accWrapper.serviceAddressAccount);
                }  
            }
        }
        
        Map<String, Site__c> sitesMap = new Map<String, Site__c>();
        
        String key;
        Market__c albertaMarket = new Market__c();
        for(Market__c mar : [SELECT id
                             FROM Market__c Where Name = 'Alberta']){
                                 albertaMarket = mar;
                             }
        
        for(AccountSiteWapper accWrapper :wrapperList){
            key = accWrapper.serviceAddressAccount.Name + accWrapper.serviceAddressAccount.Market__c;
            key = key.trim();
            
            if(uniqueServiceAddress.containsKey(key)){
                for(Site__c mSite : accWrapper.siteList){
                    if(!sitesMap.containsKey(accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c)){
                        if(albertaMarket.Id == accWrapper.serviceAddressAccount.Market__c && String.isNotEmpty(mSite.Name)){
                            if((mSite.Name).length() == 13){
                                //mSite.Account__c = uniqueServiceAddress.get(key).Id;
                                mSite.Site_Market_Account_Name__c = accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c;
                                mSite.market__c = uniqueServiceAddress.get(key).market__c;
                                sitesMap.put(accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c, mSite);
                            }else{
                                 System.debug('key :'+key);
                                errorList.add(new ErrorSiteWapper(Label.Site_name_must_be_13_character_for_Alberta,accWrapper.serviceAddressAccount.Name,mSite,true));
                                System.debug('Error');
                            }
                        }else{
                            if(String.isNotEmpty(mSite.Name)){
                                //mSite.Account__c = uniqueServiceAddress.get(key).Id;
                                mSite.Site_Market_Account_Name__c = accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c;
                                mSite.market__c = uniqueServiceAddress.get(key).market__c;
                                sitesMap.put(accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c, mSite);
                            }
                        }
                    }else{
                        System.debug('Duplicate Error');
                        errorList.add(new ErrorSiteWapper(Label.Duplicate_site_for_same_service_address_is_not_allow,key,mSite,true));
                    }
                }
            }
        }
        
        if(errorList.size() > 0){
            return errorList;
        }
        List<Database.UpsertResult> results = new List<Database.UpsertResult>();
        
        try{            
            System.debug('uniqueServiceAddress = '+uniqueServiceAddress);
            upsert uniqueServiceAddress.values();
            
            List<Id> serAddressIds = new List<Id>();
            for(Account a : uniqueServiceAddress.values()){
                serAddressIds.add(a.Id);
            }
            system.debug('serAddressIds ::'+serAddressIds);
            if(wrapperList != null && wrapperList.size()>0){ 
                if(wrapperList[0].UploadedFileData != true){
                    DELETE [SELECT id
                            From Account Where Id NOT IN : serAddressIds AND ParentId =: accId AND RecordTypeId=:serviceRT.Id];
                }
            }

            for(AccountSiteWapper accWrapper :wrapperList){
                key = accWrapper.serviceAddressAccount.Name + accWrapper.serviceAddressAccount.Market__c;
                key = key.trim();
                if(uniqueServiceAddress.containsKey(key)){
                    for(Site__c mSite : accWrapper.siteList){
                        if(String.isNotEmpty(mSite.Name)){
                            sitesMap.get(accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c).Account__c = uniqueServiceAddress.get(key).Id;    
                        }
                    }
                }
            }
            
            //results = Database.upsert(sitesMap.values(),false);            
            Upsert sitesMap.values();
            System.debug('sitesMap = '+sitesMap);
            System.debug('results ::: ' + results);
            List<Id> siteIds = new List<Id>();
            for(Site__c s : sitesMap.values()){
                siteIds.add(s.Id);
            }
            if(wrapperList != null && wrapperList.size()>0){ 
                if(wrapperList[0].UploadedFileData != true){
            DELETE [SELECT id
                    From Site__c Where Id NOT IN : siteIds AND Account__c IN : serAddressIds];
                }
            }
        }catch(DmlException excep){
            System.debug('Exception = '+excep);
            AuraHandledException ex;
            String errorMsg = String.valueOf(excep.getMessage());
            if(errorMsg.contains('DUPLICATES_DETECTED')){
                ex = new AuraHandledException(Label.Duplicate_Service_Address);
                ex.setMessage(Label.Duplicate_Service_Address);                            
            }
            else if(errorMsg.contains('DUPLICATE_VALUE')){
                ex = new AuraHandledException(Label.Duplicate_Site_For_Market);
                ex.setMessage(Label.Duplicate_Site_For_Market);                            
            }
            else{
                ex = new AuraHandledException(excep.getMessage());
                ex.setMessage(excep.getMessage());                            
            }
            throw ex;
        }
        
        System.debug('uniqueServiceAddress.values() #### '+uniqueServiceAddress.values());
        System.debug('results = '+results);
        
        /*for(Integer i=0;i<results.size();i++){
if(!results[i].isSuccess()){                
List<Database.Error> errors = results[i].getErrors();
String errMsg = '';
for(Database.Error theError:Errors) {                    
errMsg = theError.getMessage();
}
errorList.add(new ErrorSiteWapper(errMsg, sitesMap.values()[i].Account__c, sitesMap.values()[i], true));
}
}*/
        return errorList ;
    }
    
     
    /*********************************************************
@Name 			: initSite
@Parameters 	: 
@Reutrn type 	: Site__c
@Description 	: This method to initalize new Site.
********************************************************/
    @auraEnabled
    public static Site__c initSite(){
        return new Site__c() ;
    }
    
    /*********************************************************
@Name 			: ErrorSiteWapper
@Parameters 	: 
@Reutrn type 	: 
@Description 	: Wrapper class
********************************************************/
    public class ErrorSiteWapper {
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String serviceAddress {get;set;}
        @AuraEnabled public Site__c site {get;set;}
        @AuraEnabled public Boolean flag {get;set;}
        
        /*********************************************************
@Name 			: ErrorSiteWapper
@Parameters 	: String : message, String : key, Site__c :site, Boolean : flag
@Reutrn type 	: void
@Description 	: Constructor
********************************************************/
        public ErrorSiteWapper(String message, String key, Site__c site, Boolean flag){
            this.message = message;
            this.serviceAddress = key;
            this.site = site;
            this.flag = flag;
        }
    }
    
    /*********************************************************
@Name 			: AccountSiteWapper
@Parameters 	: 
@Reutrn type 	: 
@Description 	: Wrapper class
********************************************************/
    public class AccountSiteWapper {
        @AuraEnabled public String parentAccountId {get;set;}
        @AuraEnabled public Account parentAccountDetail {get;set;}
        @AuraEnabled public Account serviceAddressAccount {get;set;}
        @AuraEnabled public List<Site__c> siteList{get;set;}
        @AuraEnabled public List<string> DataColumn{get;set;}
        @AuraEnabled public Map<String, List<String>> dependentMap {get;set;}
         @AuraEnabled public Boolean UploadedFileData {get;set;}
        /*********************************************************
@Name 			: AccountSiteWapper
@Parameters 	: String : parentid
@Reutrn type 	: void
@Description 	: Constructor
********************************************************/
        public AccountSiteWapper(Account parentAccount, Map<String, List<String>> dependentMapVal){
            this.parentAccountId = parentAccount.Id ;
            this.serviceAddressAccount = new Account();
            this.siteList = new List<Site__c>(); 
            this.parentAccountDetail = parentAccount;
            this.DataColumn = label.Import_Site_Data_Template.split(',');
            this.dependentMap = dependentMapVal;
        }
        
        /*********************************************************
@Name 			: AccountSiteWapper
@Parameters 	: String : parentid, Account : serAddAcc
@Reutrn type 	: void
@Description 	: Constructor
********************************************************/ 
        public AccountSiteWapper(Account parentAccount,Account serAddAcc, Map<String, List<String>> dependentMapVal){
            this.serviceAddressAccount = serAddAcc ; 
            this.parentAccountId = parentAccount.Id ;
            this.siteList = new List<Site__c>(); 
            this.parentAccountDetail = parentAccount;  
            this.DataColumn = label.Import_Site_Data_Template.split(',');
            this.dependentMap = dependentMapVal;
        }
        /*********************************************************
@Name 			: addSite
@Parameters 	: Site__c : site
@Reutrn type 	: void
@Description 	: Add site
********************************************************/
        public void addSite(Site__c site ){
            this.siteList.add(site);
        }
    }
    /*********************************************************
@Name 			: picklistWapper
@Parameters 	: 
@Reutrn type 	: 
@Description 	: Wrapper class
********************************************************/
    public class picklistWapper{
        @auraEnabled public String label;
        @auraEnabled public String value;
        @auraEnabled public Boolean defaultValue;
        
        /*********************************************************
@Name 			: picklistWapper
@Parameters 	: String :label, String :value, Boolean :defaultValue
@Reutrn type 	: void
@Description 	: Constructor
********************************************************/  
        public picklistWapper(String label, String value, Boolean defaultValue){
            this.label = label;
            this.value = value;
            this.defaultValue = defaultValue;
        }
    }
    
    
    /*--------------------------------Dependant picklist -----------------------------------

@Name 			: getDependentMap
@Parameters 	: sObject:objDetail,string:contrfieldApiName,string:depfieldApiName
@Reutrn type 	: Map<String, List<String>>
@Description 	: get dependent map
********************************************************/
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(String objDetail, string contrfieldApiName,string depfieldApiName) {
        System.debug('getDependentMap#######');
        System.debug('objDetail#######'+objDetail);
        System.debug('contrfieldApiName#######'+contrfieldApiName);
        System.debug('depfieldApiName#######'+depfieldApiName);
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        SObjectType objType = Schema.getGlobalDescribe().get(objDetail);
        Map<String,List<String>> objResults = new Map<String,List<String>>(); 
        
        if (objType==null){
            System.debug('objResults####### '+objResults);
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('objResults####### '+objResults);
            return objResults;     
        }
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        System.debug('objResults####### '+objResults);
        return objResults;
    }
    /*********************************************************
@Name 			: refineCSV
@Parameters 	: string:val
@Reutrn type 	: List<String>
@Description 	: Refine the csv data to correct format
********************************************************/
    @auraEnabled
    public static List<CSVDataStoreWrapper> refineCSV(string CsvData) {
        system.debug('CsvData ::'+CsvData);
        List<CSVDataStoreWrapper> wrapperList = new List<CSVDataStoreWrapper>();
        Map<string,List<string>> CSVMAP = new Map<string,List<string>>();
        Id ServiceRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Address').getRecordTypeId();
        String data = JSON.deserializeUntyped(CsvData).toString();
        //List<string> FinalData= new List<string>();
        system.debug('data :'+data);
        list<String> lstCSVLines = data.split('\n');
        system.debug('lstCSVLines :'+lstCSVLines);
        for(Integer i = 1; i < lstCSVLines.size(); i++){
            
            String csvLine = lstCSVLines[i];
            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;
            
            while(csvLine.indexOf('"') > -1){
                
                if(startIndex == null){
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ' ' + csvLine.substring(startIndex+1, csvLine.length());
                }else{
                    if(endIndex == null){
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ' ' + csvLine.substring(endIndex+1, csvLine.length());
                    }
                }
                
                if(startIndex != null && endIndex != null){
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ' ');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }
            system.debug('csvLine ::'+csvLine);
            //FinalData.add(csvLine);
            lstCSVLines[i] = csvLine;
            List<string> cellList = lstCSVLines[i].split(',');
            system.debug('cellList ::'+cellList);
            
            List<string> SiteValuesList = new List<string>();
            SiteValuesList.add(cellList[1]);
            SiteValuesList.add(cellList[2]);
            SiteValuesList.add(cellList[3]);
            SiteValuesList.add(cellList[4]);
            SiteValuesList.add(cellList[5]);
            SiteValuesList.add(cellList[6]);
            SiteValuesList.add(cellList[7]);
            SiteValuesList.add(cellList[8]);
            SiteValuesList.add(cellList[9]);
            SiteValuesList.add(cellList[10]);
            system.debug('SiteValuesList ::'+SiteValuesList);
            
            if(!CSVMAP.containsKey(cellList[0])){
                CSVMAP.put(cellList[0],new List<string>());
            }
            CSVMAP.get(cellList[0]).addAll(SiteValuesList);
            system.debug('CSVMAP ::'+CSVMAP);
            system.debug('CSVMAP-serialized ::'+JSON.serialize(CSVMAP));
        }
        //system.debug('FinalData :'+FinalData);
        
        List<List<string>> ReturnListData = new List<List<string>>();
        Map<string,string> MarketMap = new Map<string,string>();
        Map<String, List<String>> dependentMapVal = getDependentMap('Site__c', 'Type__c','Unit_of_Measure__c'); 
        system.debug('dependentMapVal::'+dependentMapVal); 
        
        for(Market__c markObj : [SELECT Id, Name FROM Market__c]){
            string marketName = markObj.Name.toUppercase();
            MarketMap.put(marketName, markObj.Id);
        }
        system.debug('MarketMap:'+JSON.serialize(MarketMap));
        System.debug('CSVMAP:::'+CSVMAP.values());
        
        Map<string,string> UnitOfMeasureMap = new Map<string,string>();
        
        Schema.DescribeFieldResult fieldResult = Site__c.Unit_of_Measure__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            string measureName = pickListVal.getValue().toUppercase(); 
			UnitOfMeasureMap.put(measureName,pickListVal.getValue());
		}     
        
        for(string key: CSVMAP.keyset()){
            List<List<string>> reassignDataList = new List<List<string>>();
            CSVDataStoreWrapper wrap = new CSVDataStoreWrapper();
            wrap.LocationId = key;
            wrap.recordTypeId = ServiceRecordTypeId; 
            system.debug('list-size::'+CSVMAP.get(Key).size());
            
            ReturnListData = (List<List<string>>) MakeCsvDataLists.doPartions(CSVMAP.get(Key), 10, List<List<string>>.class);
            system.debug('ReturnListData::'+ReturnListData);
            for(List<string> ListVal: ReturnListData){
                string MarkVal = ListVal[0];
                system.debug('MarkVal ::'+MarkVal);
                string marketId;
                if(MarkVal != '' || MarkVal != null){
                    string marketName = MarkVal.toUppercase();
                    system.debug('marketName:'+marketName);
                    if(MarketMap.containsKey(marketName)){
                        system.debug('MarketMap.get:'+MarketMap.get(marketName));
                        marketId = MarketMap.get(marketName);
                    }   
                }
                system.debug('marketId ::'+marketId);
                if(marketId != null){
                    ListVal[0] = marketId;
                    system.debug('ListVal[0] ::'+ListVal[0]);
                    
                }else{
                    ListVal[0] = '';
                    system.debug('ListVal[0] ::'+ListVal[0]);
                   
                }
                
                string unitOfMeas = ListVal[8];
                system.debug('unitOfMeas ::'+unitOfMeas);
                string unitOfMeasAPIVal;
                if(unitOfMeas != '' || unitOfMeas != null){
                    string unitOfMeasName = unitOfMeas.toUppercase();
                    system.debug('unitOfMeasName:'+unitOfMeasName);
                    if(UnitOfMeasureMap.containsKey(unitOfMeasName)){
                        system.debug('UnitOfMeasureMap.get:'+UnitOfMeasureMap.get(unitOfMeasName));
                        unitOfMeasAPIVal = UnitOfMeasureMap.get(unitOfMeasName);
                    }   
                }
                system.debug('unitOfMeasAPIVal ::'+unitOfMeasAPIVal);
                if(unitOfMeasAPIVal != null){
                    ListVal[8] = unitOfMeasAPIVal;
                    system.debug('ListVal[8] ::'+ListVal[8]);
                    
                }else{
                    ListVal[8] = '';
                    system.debug('ListVal[8] ::'+ListVal[8]);
                    
                }
                reassignDataList.add(ListVal);
            }
            system.debug('reassignDataList ::'+reassignDataList);
            wrap.SiteList = reassignDataList;
            wrap.dependentMap = dependentMapVal;
            wrap.UploadedFileData = true;
            wrapperList.add(wrap);
        }
        
        system.debug('wrapperList ::'+JSON.serialize(wrapperList) );
        return wrapperList;
    }
    
    /*********************************************************
@Name 			: decimalToBinary
@Parameters 	: Integer:val
@Reutrn type 	: String
@Description 	: decimal to binary
********************************************************/
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    /*********************************************************
@Name 			: base64ToBits
@Parameters 	: String:validFor
@Reutrn type 	: String
@Description 	: base 64 bits
********************************************************/
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    /*********************************************************
@Name 			: wrapPicklistEntries
@Parameters 	: List<Schema.PicklistEntry> :PLEs
@Reutrn type 	: List<PicklistEntryWrapper>
@Description 	: Wrapper picklist entry
********************************************************/
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    /*********************************************************
@Name 			: PicklistEntryWrapper
@Parameters 	: 
@Reutrn type 	: 
@Description 	: Wrapper class
********************************************************/
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        
        /*********************************************************
@Name 			: PicklistEntryWrapper
@Parameters 	: 
@Reutrn type 	: void
@Description 	: constructor
********************************************************/
        public PicklistEntryWrapper(){            
        }
    }
    /*--------------------------------End Dependant picklist ------------------------------------*/
    public class CSVDataStoreWrapper{
        @AuraEnabled public string LocationId{get;set;}
        @AuraEnabled public List<List<string>> SiteList{get;set;}
        @AuraEnabled public String recordTypeId{get;set;}
        @AuraEnabled public Map<String, List<String>> dependentMap {get;set;}
        @AuraEnabled public Boolean UploadedFileData {get;set;}
    }
    
    
    /*-----------------------------------------------------------------*/ 
    @auraEnabled
    public static List<AccountSiteWapper> getAccountSites(String recordId) {
        Map<Id, AccountSiteWapper > seviceAcctMap = new  Map<Id, AccountSiteWapper >();
        AccountSiteWapper accSiteAcct ;
         Map<String, List<String>> dependentMapVal = getDependentMap('Site__c', 'Type__c','Unit_of_Measure__c'); 
        system.debug('dependentMapVal::'+dependentMapVal); 
        List<Account> serviceAccountList = [Select id,name,BillingAddress,ShippingStreet,ShippingState,ShippingCountry,ShippingPostalCode,ShippingCity,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingAddress,Billing_address_same_as_parent__c,Service_address_same_as_parent__c,Market__c,Parent.Id From Account WHERE Id=: recordId];
        System.debug('serviceAccountList:::'+serviceAccountList);    
        Account parentAccDetail = [Select Id, Name,ShippingAddress,ShippingStreet,ShippingState,ShippingCountry,ShippingPostalCode,ShippingCity From Account where Id =: serviceAccountList[0].Parent.Id];
        accSiteAcct = new  AccountSiteWapper(parentAccDetail,serviceAccountList[0],dependentMapVal);
        seviceAcctMap.put(serviceAccountList[0].Id, accSiteAcct);                             
        For( Site__c site : [Select Id, Name, Volume__c,Account__c, 
                             Unit_of_Measure__c,Type__c      
                             From Site__c Where Account__c IN : seviceAcctMap.KeySet() ]){
                                 if(seviceAcctMap.containsKey(site.Account__c)){
                                     seviceAcctMap.get(site.Account__c).addSite(site);
                                 }
                             }
        if(seviceAcctMap.values().size()>0){
            system.debug('seviceAcctMap.values()::'+seviceAcctMap.values());
            return seviceAcctMap.values(); 
        }else{
            List<AccountSiteWapper> accountSiteWapper=new List<AccountSiteWapper>();
            accountSiteWapper.add(new AccountSiteWapper(parentAccDetail,dependentMapVal));
            return accountSiteWapper;
        }
    }
   
    @auraEnabled    
    public static List<ErrorSiteWapper> saveAccountSites(string ListAccounts, Id accId){
        System.debug('ListAccounts = '+ ListAccounts);
        System.debug('accId = '+ accId);
        List<AccountSiteWapper> wrapperList = (List<AccountSiteWapper>) System.JSON.deserialize(ListAccounts, List<AccountSiteWapper>.class);
        System.debug('wrapperList = '+ JSON.serialize(wrapperList));
        Account parentAccountDetail = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry
                                       From Account Where Id=:accId] ;
        RecordType serviceRT = [Select Id
                                From RecordType Where sObjectType = 'Account' And RecordType.Name='Service Address' Limit 1] ;
        Map<String,Account> uniqueServiceAddress = new Map<String,Account>();
        List<ErrorSiteWapper> errorList = new List<ErrorSiteWapper>();
        
        for(AccountSiteWapper accWrapper :wrapperList){
            if(String.isNotEmpty(accWrapper.serviceAddressAccount.Name)){
                String uniqueKey = accWrapper.serviceAddressAccount.Name + accWrapper.serviceAddressAccount.Market__c;
                uniqueKey = uniqueKey.trim();
                accWrapper.serviceAddressAccount.ParentId = accId;
                accWrapper.serviceAddressAccount.RecordTypeId = serviceRT.Id;
                Boolean sameAddrees = accWrapper.serviceAddressAccount.Service_address_same_as_parent__c;
                if(sameAddrees){
                    accWrapper.serviceAddressAccount.ShippingStreet=parentAccountDetail.BillingStreet;
                    accWrapper.serviceAddressAccount.ShippingCity=parentAccountDetail.BillingCity;
                    accWrapper.serviceAddressAccount.ShippingState=parentAccountDetail.BillingState;
                    accWrapper.serviceAddressAccount.ShippingPostalCode=parentAccountDetail.BillingPostalCode;
                    accWrapper.serviceAddressAccount.ShippingCountry=parentAccountDetail.BillingCountry;                
                }
                if(uniqueServiceAddress.containsKey(uniqueKey)){ 
                    if(uniqueServiceAddress.get(uniqueKey).Id != null && accWrapper.serviceAddressAccount == null){
                        uniqueServiceAddress.put(uniqueKey, uniqueServiceAddress.get(uniqueKey));
                    }else if(uniqueServiceAddress.get(uniqueKey).Id == null && accWrapper.serviceAddressAccount != null){
                        uniqueServiceAddress.put(uniqueKey, accWrapper.serviceAddressAccount);
                    }  
                }else{
                    uniqueServiceAddress.put(uniqueKey, accWrapper.serviceAddressAccount);
                }  
            }
        }
        
        Map<String, Site__c> sitesMap = new Map<String, Site__c>();
        
        String key;
        Market__c albertaMarket = new Market__c();
        for(Market__c mar : [SELECT id
                             FROM Market__c Where Name = 'Alberta']){
                                 albertaMarket = mar;
                             }
        
        for(AccountSiteWapper accWrapper :wrapperList){
            key = accWrapper.serviceAddressAccount.Name + accWrapper.serviceAddressAccount.Market__c;
            key = key.trim();
            
            if(uniqueServiceAddress.containsKey(key)){
                for(Site__c mSite : accWrapper.siteList){
                    system.debug('sitesMap:: '+sitesMap);
                    system.debug('accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c::'+accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c);
                    if(!sitesMap.containsKey(accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c)){
                        system.debug('InsideLoop');
                        if(albertaMarket.Id == accWrapper.serviceAddressAccount.Market__c && String.isNotEmpty(mSite.Name)){
                            if((mSite.Name).length() == 13){
                                 system.debug('mSite.Name:'+mSite.Name);
                                //mSite.Account__c = uniqueServiceAddress.get(key).Id;
                                mSite.Site_Market_Account_Name__c = accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c;
                                mSite.market__c = uniqueServiceAddress.get(key).market__c;
                                sitesMap.put(accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c, mSite);
                            }else{
                                errorList.add(new ErrorSiteWapper(Label.Site_name_must_be_13_character_for_Alberta,key,mSite,true));
                                System.debug('Error');
                            }
                        }else{
                            if(String.isNotEmpty(mSite.Name)){
                                //mSite.Account__c = uniqueServiceAddress.get(key).Id;
                                mSite.Site_Market_Account_Name__c = accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c;
                                mSite.market__c = uniqueServiceAddress.get(key).market__c;
                                sitesMap.put(accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c, mSite);
                            }
                        }
                    }else{
                        System.debug('Duplicate Error');
                        errorList.add(new ErrorSiteWapper(Label.Duplicate_site_for_same_service_address_is_not_allow,key,mSite,true));
                    }
                }
            }
        }
        
        if(errorList.size() > 0){
            return errorList;
        }
        List<Database.UpsertResult> results = new List<Database.UpsertResult>();
        
        try{            
            System.debug('uniqueServiceAddress = '+uniqueServiceAddress);
            upsert uniqueServiceAddress.values();
            
            List<Id> serAddressIds = new List<Id>();
            for(Account a : uniqueServiceAddress.values()){
                serAddressIds.add(a.Id);
            }
            system.debug('serAddressIds ::'+serAddressIds);
            
            
            for(AccountSiteWapper accWrapper :wrapperList){
                key = accWrapper.serviceAddressAccount.Name + accWrapper.serviceAddressAccount.Market__c;
                key = key.trim();
                if(uniqueServiceAddress.containsKey(key)){
                    for(Site__c mSite : accWrapper.siteList){
                        if(String.isNotEmpty(mSite.Name)){
                            sitesMap.get(accWrapper.serviceAddressAccount.Market__c+mSite.Name+mSite.Type__c).Account__c = uniqueServiceAddress.get(key).Id;    
                        }
                    }
                }
            }
            
            //results = Database.upsert(sitesMap.values(),false);            
            Upsert sitesMap.values();
            System.debug('sitesMap = '+sitesMap);
            System.debug('results ::: ' + results);
            List<Id> siteIds = new List<Id>();
            for(Site__c s : sitesMap.values()){
                siteIds.add(s.Id);
            }
            if(wrapperList != null && wrapperList.size()>0){ 
                if(wrapperList[0].UploadedFileData != true){
                    DELETE [SELECT id
                            From Site__c Where Id NOT IN : siteIds AND Account__c IN : serAddressIds];
                }
            }
        }catch(DmlException excep){
            System.debug('Exception = '+excep);
            AuraHandledException ex;
            String errorMsg = String.valueOf(excep.getMessage());
            if(errorMsg.contains('DUPLICATES_DETECTED')){
                ex = new AuraHandledException(Label.Duplicate_Service_Address);
                ex.setMessage(Label.Duplicate_Service_Address);                            
            }
            else if(errorMsg.contains('DUPLICATE_VALUE')){
                ex = new AuraHandledException(Label.Duplicate_Site_For_Market);
                ex.setMessage(Label.Duplicate_Site_For_Market);                            
            }
            else{
                ex = new AuraHandledException(excep.getMessage());
                ex.setMessage(excep.getMessage());                            
            }
            throw ex;
        }
        
        System.debug('uniqueServiceAddress.values() #### '+uniqueServiceAddress.values());
        System.debug('results = '+results);
        
        /*for(Integer i=0;i<results.size();i++){
if(!results[i].isSuccess()){                
List<Database.Error> errors = results[i].getErrors();
String errMsg = '';
for(Database.Error theError:Errors) {                    
errMsg = theError.getMessage();
}
errorList.add(new ErrorSiteWapper(errMsg, sitesMap.values()[i].Account__c, sitesMap.values()[i], true));
}
}*/
        return errorList ;
    }
}