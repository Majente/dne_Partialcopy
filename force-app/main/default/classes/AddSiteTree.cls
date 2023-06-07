/**************************************************
* Class: AddSiteTree
* Author: Soljit <VW>
* Date: 2019-05-10
* 
****************************************************/
public class AddSiteTree {
    
    public static Id recordId;
    public static string market;
    public static  Map<ID,OpportunityLineItem> existedSite {get;set;}
    public String sObjectName{get;set;}
    Set<Id> accountIds;
    List<Account> selecAccList ;
    Public static String FIXED_TYPE = 'Fixed';
    Public static String VARIABLE_TYPE = 'Variable';
    
    // Tree Variable
    public String jsonDataForAddressSite {get;set;}
    public Map<Id,TreeWrapper> addressSiteMap {get;set;} 
    
    
    public String siteIds {get;set;} 
    
    public AddSiteTree(ApexPages.StandardController stdController){
        siteIds='' ;
        Id parentID = stdController.getRecord().Id;
        
        recordId = stdController.getRecord().Id;
        String serviceAddressAccount;
        
        Opportunity oppty = [select id,Commodity_Type__c, accountId,Market__c from Opportunity where id=:parentID] ;
        if(oppty.Market__c !=null){
            market = oppty.Market__c;
        }
        for(OpportunityLineItem oli :[Select Id, Site__c, Site__r.Account__c 
                                      From OpportunityLineItem 
                                      Where OpportunityId =:parentID]){
                                          serviceAddressAccount = oli.Site__r.Account__c;
                                      }
        
        ID accId = oppty.accountId ;
        List<Account> accountList = [Select Id,Name,Market__r.Name from Account 
                                     where ParentId=:oppty.accountId And Market__c =:market  And RecordType.Name = 'Service Address'] ; 
        
        
        System.debug('accountList::'+accountList);
        
        
        Map<Id,TreeWrapper> addressSiteMap = new Map<Id,TreeWrapper>();
        TreeWrapper treewrp ;
        
        for(Account addressAccount: [Select Id,Name,Market__r.Name from Account 
                                     where ParentId=:oppty.accountId And Market__c =:market  And RecordType.Name = 'Service Address'] ){
                                         treewrp = new TreeWrapper(parentID,addressAccount) ;  
                                         addressSiteMap.put(addressAccount.Id,treewrp);                            
                                     } 
        
        System.debug('addressSiteMap=='+addressSiteMap);
        
        String Commoditytype;
        existedSite = new Map<ID,OpportunityLineItem>();
        List<Site__c> siteList = new List<Site__c> ();
        
        
        
        if(oppty.Market__c !=null){
            market = oppty.Market__c;
        }
        if(oppty.Commodity_Type__c !=null){
            Commoditytype = oppty.Commodity_Type__c;
        }
        for(OpportunityLineItem oli :[Select Id, Site__c, Site__r.Account__c From OpportunityLineItem Where OpportunityId =:parentID]){
            existedSite.put(oli.Site__c,oli);
            serviceAddressAccount = oli.Site__r.Account__c;
        }
        
        
        for(Site__c site:[Select Id, name,Market__c,Volume__c,Type__c , Unit_of_Measure__c ,Account__c 
                          from Site__c where Account__c IN:addressSiteMap.keySet() And Type__c =:Commoditytype]){
                              if(!existedSite.containsKey(site.Id)){
                                  addressSiteMap.get(site.Account__c).addSite(site);
                              }
                          }
        
        System.debug('addressSiteMap=='+addressSiteMap);
        
        jsonDataForAddressSite= JSON.serialize(addressSiteMap);
        
        
    }
    /*********************************************************************
// Method Name : getServiceAccountByOpportunity
// Description : This method to get all child Service Address Accounts 
of Parent account of Opportunity.
*********************************************************************/
    @AuraEnabled
    public static List<Account> getServiceAccountByOpportunity(ID parentID){
        String serviceAddressAccount;
        System.debug('parentID::'+parentID);
        Opportunity oppty = [select id, accountId,Market__c from Opportunity where id=:parentID] ;
        if(oppty.Market__c !=null){
            market = oppty.Market__c;
        }
        for(OpportunityLineItem oli :[Select Id, Site__c, Site__r.Account__c 
                                      From OpportunityLineItem 
                                      Where OpportunityId =:parentID]){
                                          serviceAddressAccount = oli.Site__r.Account__c;
                                      }
        System.debug('serviceAddressAccount::'+serviceAddressAccount);
        ID accId = oppty.accountId ;
        List<Account> accountList = [Select Id,Name,Market__r.Name from Account 
                                     where ParentId=:oppty.accountId And Market__c =:market  And RecordType.Name = 'Service Address'] ; 
        System.debug('accountList::'+accountList);
        return accountList ;
        
        
    }
    /*********************************************************************
// Method Name : getSiteList
// Description : This method to get all site data list
*********************************************************************/
    @AuraEnabled
    public static  List<Site__c> getSiteList(ID parentID , Id oppId){
        String Commoditytype;
        existedSite = new Map<ID,OpportunityLineItem>();
        List<Site__c> siteList = new List<Site__c> ();
        String serviceAddressAccount;
        Opportunity oppor = [select id,Commodity_Type__c, accountId,Market__c from Opportunity where id=:oppId] ;
        if(oppor.Market__c !=null){
            market = oppor.Market__c;
        }
        if(oppor.Commodity_Type__c !=null){
            Commoditytype = oppor.Commodity_Type__c;
        }
        for(OpportunityLineItem oli :[Select Id, Site__c, Site__r.Account__c From OpportunityLineItem Where OpportunityId =:oppId]){
            existedSite.put(oli.Site__c,oli);
            serviceAddressAccount = oli.Site__r.Account__c;
        }
        for(Site__c site: [Select Id, Name,Market__c,Volume__c,Type__c , Unit_of_Measure__c  
                           from Site__c where Account__c =:parentID 
                           and Type__c =:Commoditytype ] ){
                               
                               if(!existedSite.containsKey(site.Id)){
                                   siteList.add(site);
                               }
                           }
        system.debug('site = '+siteList);
        return siteList ;
    } 
    /*********************************************************************
// Method Name : fetchQuoteId
// Description : This method to get primary quote id
*********************************************************************/
    @AuraEnabled 
    public static Id fetchQuoteId(Opportunity opp){
        System.debug('oppid:::'+opp);
        SBQQ__Quote__c quot;
        For(SBQQ__Quote__c qt :[Select id From SBQQ__Quote__c Where SBQQ__Opportunity2__c =: opp.Id 
                                And SBQQ__Primary__c = true limit 1] ){
                                    quot = qt;
                                }
        if(quot != null ){ 
            return quot.id; 
        }else{
            //Create a quote here
            quot  =  CreateQuoteLineUtility.createQuote( opp.Id);
            if(quot != null ){ 
                return quot.id; 
            }
        }
        return null;
    }
    /*********************************************************************
// Method Name : getStandardPB
// Description : This method to get standard pricebook id
*********************************************************************/
    public static string getStandardPB(){
        For(Pricebook2 pb :[select id, name from Pricebook2 where isStandard = true]){
            if(pb!=null){
                return pb.id;
            }
        }
        return null;
    }    
    
    /*********************************************************************
// Method Name : saveOpportunitySite
// Description : This method to save opportunity site data
*********************************************************************/ 
    public  PageReference saveOpportunitySite(){
        System.debug('siteIds===='+recordId);
        recordId =Apexpages.currentPage().getParameters().get('Id');
        Id oppId =recordId;
        System.debug('siteIds===='+siteIds);
        System.debug('after recordd' +recordId);
        
        
        // Local variables
        String serviceAddressAccount;
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Opportunity_Site__c > siteList = new List<Opportunity_Site__c >();
        Map<ID, Site__c> selectedSites = new Map<ID, Site__c>();
        Decimal totalVolume = 0;
        Product2 selectedProduct;
        String commodityType ; 
        String size = 'Small';
        SBQQ__QuoteLine__c quoteLine; 
        SBQQ__QuoteLine__c existedQLI;
        Opportunity_Site__c oppsite;
        String market;
        String productId;
        String supplier;
        Decimal subscriptionTerm;
        String priceType;
        Decimal listPriceMargin;
        Decimal sellingPrice;
        String monthYear;
        Decimal margin;
        Decimal oppSupplierPrice;
        Opportunity oppty = [Select id,CloseDate,Electricity_Product_of_Choice__c,Gas_Volume__c,
                             Gas_Product_of_Choice__c,Total_Volume__c,Supplier__c ,Margin__c,
                             Commodity_Type__c, AccountId,Market__c,Market__r.Gas_Threshold__c,
                             recordtype.Name,Market__r.Electricity_Threshold__c,Month_Year__c ,
                             Subscription_Term__c,Supplier_Price__c,Admin_Fee__c,pricebook2id
                             From Opportunity Where id=:oppId];
        
        if(oppty.Pricebook2Id == null){
            oppty.Pricebook2Id = getStandardPB();
            Update oppty;
        }
        System.debug('oppty::'+oppty.recordtype.Name);
        market = oppty.Market__c;
        supplier = oppty.Supplier__c;
        priceType = oppty.recordtype.Name;
        subscriptionTerm = oppty.Subscription_Term__c;
        monthYear = oppty.Month_Year__c;
        oppSupplierPrice = oppty.Supplier_Price__c;
        Id quotId = fetchQuoteId(oppty);
        // Check for existing QLI under quote to get relevant 
        For(SBQQ__QuoteLine__c qli : [Select Market__c,Selling_Price__c,Site__r.Account__c,
                                      Supplier_Price__c,SBQQ__DefaultSubscriptionTerm__c,
                                      SBQQ__ListPrice__c,SBQQ__ProductCode__c,SBQQ__Product__c 
                                      From SBQQ__QuoteLine__c 
                                      Where SBQQ__Quote__c =:quotId limit 1 ]){
                                          existedQLI = qli;
                                          serviceAddressAccount = qli.Site__r.Account__c; 
                                          
                                      }
        System.debug('existedQLI:::'+existedQLI);
        
        //Get Selected Sites
        
        List<String> siteIds = siteIds.split(',');
        For(Site__c site : [Select Id, volume__c, type__c,Market__c From Site__c Where Id IN:siteIds ]){
            selectedSites.put(site.Id, site);
            totalVolume += site.volume__c;
            commodityType = site.type__c;
        }
        // Check Business Size
        if(commodityType == 'Gas'){
            if(totalVolume > oppty.Market__r.Gas_Threshold__c ){
                size = 'Large'; 
            }
        }else if(commodityType == 'Electricity'){
            if(totalVolume > oppty.Market__r.Electricity_Threshold__c ){
                size = 'Large';  
            }
        }
        if(priceType == 'Custom'){
            size =null;
        }
        //Get Product 
        String proName = 'Gas';
        String proCode;
        String sizePro;
        for( Product2 product :[Select Id,Name,Size__c,ProductCode From Product2 
                                Where Family =:commodityType And Size__c =:size
                                And Price_Type__c  =:priceType Limit 1 ]){
                                    selectedProduct =  product;   
                                    proCode = product.ProductCode;
                                    sizePro  = product.Size__c;
                                }
        if(proCode.contains('Electricity')){
            proName = 'Electricity';
        }
        Decimal listPrice =0;
        Map<Id,List<Price_List__c>> priceListMap = new  Map<Id,List<Price_List__c>>();
        priceListMap = PriceListUtility.getTodayPriceList(market,proName,sizePro,supplier);
        For(List<Price_list__c> plList :priceListMap.values()){
            for(Price_list__c price :plList){
                if(price.Month_Year__c == monthYear && price.Term__c ==String.valueOf(subscriptionTerm) ){
                    listPrice = price.List_Price__c;
                }
            }
            
        }
        //Get latest list Price 
        margin = 0;
        if( oppty.Margin__c != Null){
            margin = oppty.Margin__c;
        }
        listPriceMargin= listPrice + margin;
        
        System.debug('listPriceMargin::'+listPriceMargin);
        CreateQuoteLineUtility.createQLI(selectedProduct.Id,quotId,selectedSites.values(),listPriceMargin,subscriptionTerm,oppty.Margin__c);
        
        // Create Opportunity-Site Junction Record 
        For(Site__c st :[select id from Site__c where id IN:siteIds]){
            oppsite = new Opportunity_Site__c ();
            oppsite.Market__c = market;
            oppsite.Site__c = st.id;
            oppsite.Opportunity__c = oppId;
            siteList.add(oppsite);
        }
        System.debug('siteList::'+siteList);
        if(siteList.size()>0){
            try{ 
                INSERT siteList;
            }catch(Exception ex){
                System.debug(ex.getMessage());
                // return ex.getMessage();
            }
        }
        
        PageReference oppPage = new PageReference('/' +recordId);
        return oppPage;
        
        //return null;
    }
    
    /*********************************************************************
// Method Name : saveSitesdata
// Description : This method to save opportunity site data for opportunity
*********************************************************************/ 
    @AuraEnabled 
    public static String saveSitesdata(String[] siteIds ,Id oppId){
        if(oppId == null){
            return System.Label.Unidentified_Opporunity_Label;
        }
        if(siteIds == null){
            return System.Label.No_Site_Selected_Error_Label;
        }
        // Local variables
        String serviceAddressAccount;
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        List<Opportunity_Site__c > siteList = new List<Opportunity_Site__c >();
        Map<ID, Site__c> selectedSites = new Map<ID, Site__c>();
        Decimal totalVolume = 0;
        Product2 selectedProduct;
        String commodityType ; 
        String size = 'Small';
        SBQQ__QuoteLine__c quoteLine; 
        SBQQ__QuoteLine__c existedQLI;
        Opportunity_Site__c oppsite;
        String market;
        String productId;
        String supplier;
        Decimal subscriptionTerm;
        String priceType;
        Decimal listPriceMargin;
        Decimal sellingPrice;
        String monthYear;
        Decimal margin;
        Decimal oppSupplierPrice;
        Opportunity oppty = [Select id,CloseDate,Electricity_Product_of_Choice__c,Gas_Volume__c,
                             Gas_Product_of_Choice__c,Total_Volume__c,Supplier__c ,Margin__c,
                             Commodity_Type__c, AccountId,Market__c,Market__r.Gas_Threshold__c,
                             recordtype.Name,Market__r.Electricity_Threshold__c,Month_Year__c ,
                             Subscription_Term__c,Supplier_Price__c,Admin_Fee__c,pricebook2id
                             From Opportunity Where id=:oppId];
        
        if(oppty.Pricebook2Id == null){
            oppty.Pricebook2Id = getStandardPB();
            Update oppty;
        }
        System.debug('oppty::'+oppty.recordtype.Name);
        market = oppty.Market__c;
        supplier = oppty.Supplier__c;
        priceType = oppty.recordtype.Name;
        subscriptionTerm = oppty.Subscription_Term__c;
        monthYear = oppty.Month_Year__c;
        oppSupplierPrice = oppty.Supplier_Price__c;
        Id quotId = fetchQuoteId(oppty);
        System.debug('subscriptionTerm:::::::'+subscriptionTerm);
        System.debug('monthYear:::::::'+monthYear);
        // Check for existing QLI under quote to get relevant 
        For(SBQQ__QuoteLine__c qli : [Select Market__c,Selling_Price__c,Site__r.Account__c,
                                      Supplier_Price__c,SBQQ__DefaultSubscriptionTerm__c,
                                      SBQQ__ListPrice__c,SBQQ__ProductCode__c,SBQQ__Product__c 
                                      From SBQQ__QuoteLine__c 
                                      Where SBQQ__Quote__c =:quotId limit 1 ]){
                                          existedQLI = qli;
                                          serviceAddressAccount = qli.Site__r.Account__c; 
                                          
                                      }
        System.debug('existedQLI:::'+existedQLI);
        //Check Quote LineItems if Fixed type 
        
        if(existedQLI == null && priceType =='Fixed' ){
            return System.Label.Opportunity_have_no_product_label;
        }
        //Get Selected Sites
        For(Site__c site : [Select Id, volume__c, type__c,Market__c From Site__c Where Id IN:siteIds ]){
            selectedSites.put(site.Id, site);
            totalVolume += site.volume__c;
            commodityType = site.type__c;
        }
        // Check Business Size
        if(commodityType == 'Gas'){
            if(totalVolume > oppty.Market__r.Gas_Threshold__c ){
                size = 'Large'; 
            }
        }else if(commodityType == 'Electricity'){
            if(totalVolume > oppty.Market__r.Electricity_Threshold__c ){
                size = 'Large';  
            }
        }
        if(priceType == 'Custom'){
            size =null;
        }
        //Get Product 
        String proName = 'Gas';
        String proCode;
        String sizePro;
        for( Product2 product :[Select Id,Name,Size__c,ProductCode From Product2 
                                Where Family =:commodityType And Size__c =:size
                                And Price_Type__c  =:priceType Limit 1 ]){
                                    selectedProduct =  product;   
                                    proCode = product.ProductCode;
                                    sizePro  = product.Size__c;
                                }
        if(proCode.contains('Electricity')){
            proName = 'Electricity';
        }
        Decimal listPrice;
        Map<Id,List<Price_List__c>> priceListMap = new  Map<Id,List<Price_List__c>>();
        priceListMap = PriceListUtility.getTodayPriceList(market,proName,sizePro,supplier);
        system.debug('map is' +  priceListMap);
        For(List<Price_list__c> plList :priceListMap.values()){
            for(Price_list__c price :plList){
                system.debug('price.Month_Year__c:::::' +  price.Month_Year__c);
                system.debug('price.Term__c:::::' +  price.Term__c);
                system.debug('monthYear:::::' +  monthYear);
                system.debug('subscriptionTerm:::::' +  subscriptionTerm);
                if(price.Month_Year__c == monthYear && price.Term__c == String.valueOf(Math.round(subscriptionTerm))){
                    listPrice = price.List_Price__c;
                }
            }
            
        }
        //Get latest list Price 
        margin = 0;
        if( oppty.Margin__c != Null){
            margin = oppty.Margin__c;
        }
        listPriceMargin= listPrice + margin;
        
        System.debug('listPriceMargin::'+listPriceMargin);
        //Create QLI
        CreateQuoteLineUtility.createQLI(selectedProduct.Id,quotId,selectedSites.values(),listPriceMargin,subscriptionTerm,oppty.Margin__c);
        
        // Create Opportunity-Site Junction Record 
        For(Site__c st :[select id from Site__c where id IN:siteIds]){
            oppsite = new Opportunity_Site__c ();
            oppsite.Market__c = market;
            oppsite.Site__c = st.id;
            oppsite.Opportunity__c = oppId;
            siteList.add(oppsite);
        }
        System.debug('siteList::'+siteList);
        if(siteList.size()>0){
            try{ 
                INSERT siteList;
            }catch(Exception ex){
                System.debug(ex.getMessage());
                // return ex.getMessage();
            }
        }
        
        
        return null;
    }
    /*********************************************************************
// Class Name : TreeWrapper
// Description: wrapper class contains string,Account and list of site instance
*********************************************************************/   
    public class TreeWrapper{
        
        public String parentAccountId {get;set;}
        //public Account parentAccountDetail {get;set;}
        public Account addressAccount {get;set;}
        public List<Site__c> siteList {get;set;}
        
        public TreeWrapper(String parentId){
            this.parentAccountId = parentId;
            this.addressAccount = new Account();
            this.siteList = new List<Site__c>();
            //this.parentAccountDetail = [Select Id, Name from Account where Id=: parentId] ;
        }
        
        public TreeWrapper(String parentId, Account acc){
            this.parentAccountId = parentId;
            this.addressAccount = acc;
            this.siteList = new List<Site__c>();
            //this.parentAccountDetail = [Select Id, Name from Account where Id=: parentId] ;
        }
        
        public void addSite(Site__c site){
            this.siteList.add(site);
        }
        
    }
    
}