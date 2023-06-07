/**************************************************
* Class: AddSiteOnOpprtunityController
* Author: Soljit <VW>
* Date: 2019-05-10
* 
****************************************************/
public class AddSiteOnOpprtunityController {
    Set<Id> accountIds;
    public static string market;
    public static Id recordId;
    public String sObjectName{get;set;}
    List<Account> selecAccList ;
    public String siteIdToDelete{get;set;}
 	public static  Map<ID,OpportunityLineItem> existedSite {get;set;}
       
    // Tree Variable
    public String jsonDataForAddressSite {get;set;}
    public Map<Id,TreeWrapper> addressSiteMap {get;set;} 
    public String siteIds {get;set;} 
    /*********************************************************
    @Name 			: AddSiteOnOpprtunityController
    @Parameters 	: ApexPages.StandardController
    @Reutrn type 	: void
    @Description 	: Constructor
	********************************************************/
    public AddSiteOnOpprtunityController(ApexPages.StandardController stdController){
        
        siteIds = '';
        recordId = stdController.getRecord().Id;
        getRecordsInString(recordId);
    }            
    
    public void getRecordsInString(Id parentID){
        String serviceAddressAccount;
        TreeWrapper treewrp ;
        
        Map<Id,TreeWrapper> addressSiteMap = new Map<Id,TreeWrapper>();
        
        Opportunity oppty = [Select id,Commodity_Type__c, accountId,Market__c 
                             From Opportunity Where id=:parentID] ;
        if(oppty.Market__c != null){
            market = oppty.Market__c;
        }
        for(OpportunityLineItem oli :[Select Id, Site__c, Site__r.Account__c 
                                      From OpportunityLineItem Where OpportunityId =:parentID]){
                                          serviceAddressAccount = oli.Site__r.Account__c;
                                      }
        
        ID accId = oppty.accountId;
        List<Account> accountList = [Select Id,Name,Market__r.Name 
                                     From Account Where ParentId=:oppty.accountId 
                                     And Market__c =:market  And RecordType.Name = : ConstantString.SERVICE_ADDRESS]; 
        
        System.debug('accountList::'+accountList);
        for(Account addressAccount: [Select Id,Name,Market__r.Name 
                                     From Account Where ParentId=:oppty.accountId And Market__c =:market 
                                     And RecordType.Name = : ConstantString.SERVICE_ADDRESS] ){
                                         treewrp = new TreeWrapper(parentID,addressAccount) ;  
                                         addressSiteMap.put(addressAccount.Id,treewrp);                            
                                     } 
        
        System.debug('addressSiteMap=='+addressSiteMap);
        
        String Commoditytype;
        existedSite = new Map<ID,OpportunityLineItem>();
        List<Site__c> siteList = new List<Site__c> ();
        
        if(oppty.Market__c != null){
            market = oppty.Market__c;
        }
        if(oppty.Commodity_Type__c != null){
            Commoditytype = oppty.Commodity_Type__c;
        }
        for(OpportunityLineItem oli :[Select Id, Site__c, Site__r.Account__c 
                                      From OpportunityLineItem Where OpportunityId =:parentID]){
                                          existedSite.put(oli.Site__c,oli);
                                          serviceAddressAccount = oli.Site__r.Account__c;
                                      }
        for(Site__c site:[Select Id, name,Market__c,Volume__c,Type__c , Unit_of_Measure__c ,Account__c 
                          From Site__c Where Account__c IN:addressSiteMap.keySet() And Type__c =:Commoditytype]){
                              addressSiteMap.get(site.Account__c).addSite(site, !existedSite.containsKey(site.Id));
                          }
        
        System.debug('addressSiteMap=='+addressSiteMap.size());        
        jsonDataForAddressSite= String.escapeSingleQuotes(JSON.serialize(addressSiteMap));  
        System.debug('jsonDataForAddressSite::'+jsonDataForAddressSite);
    }
    /*********************************************************
    @Name 			: getServiceAccountByOpportunity
    @Parameters 	: ID
    @Reutrn type 	: List<Account>
    @Description 	: This method to get all child Service Address Accounts
                      of Parent account of Opportunity.
	********************************************************/
    @AuraEnabled
    public static List<Account> getServiceAccountByOpportunity(ID parentID){
        String serviceAddressAccount;
        System.debug('parentID::'+parentID);
        Opportunity oppty = [Select id, accountId,Market__c 
                             From Opportunity 
                             Where id=:parentID] ;
        if(oppty.Market__c !=null){
            market = oppty.Market__c;
        }
        for(OpportunityLineItem oli :[Select Id, Site__c, Site__r.Account__c 
                                      From OpportunityLineItem Where OpportunityId =:parentID]){
            serviceAddressAccount = oli.Site__r.Account__c;
        }
        System.debug('serviceAddressAccount::'+serviceAddressAccount);
        ID accId = oppty.accountId ;
        List<Account> accountList = [Select Id,Name,Market__r.Name From Account 
                                     Where ParentId=:oppty.accountId And Market__c =:market  
                                     And RecordType.Name = : ConstantString.SERVICE_ADDRESS] ; 
        System.debug('accountList::'+accountList);
        return accountList ;
        
        
    }
    /*********************************************************
    @Name 			: getSiteList
    @Parameters 	: ID : parentID , ID:oppId
    @Reutrn type 	: List<Site__c
    @Description 	: Get All Site List
	********************************************************/
    @AuraEnabled
    public static  List<Site__c> getSiteList(ID parentID , Id oppId){
        String Commoditytype;
        existedSite = new Map<ID,OpportunityLineItem>();
        List<Site__c> siteList = new List<Site__c> ();
        String serviceAddressAccount;
        Opportunity oppor = [Select id,Commodity_Type__c, accountId,Market__c 
                             From Opportunity Where id=:oppId] ;
        if(oppor.Market__c != null){
            market = oppor.Market__c;
        }
        if(oppor.Commodity_Type__c != null){
            Commoditytype = oppor.Commodity_Type__c;
        }
        for(OpportunityLineItem oli :[Select Id, Site__c, Site__r.Account__c 
                                      From OpportunityLineItem Where OpportunityId =:oppId]){
            existedSite.put(oli.Site__c,oli);
            serviceAddressAccount = oli.Site__r.Account__c;
        }
        for(Site__c site: [Select Id, Opportunity__c,Opportunity__r.Supplier_Price__c,Opportunity__r.Margin__c,Name,Market__c,Volume__c,Type__c , Unit_of_Measure__c  
                           From Site__c Where Account__c =:parentID And Type__c =:Commoditytype ] ){
   
            if(!existedSite.containsKey(site.Id)){
                    siteList.add(site);
             }
        }
        system.debug('site = '+siteList);
        return siteList ;
    } 
    /*********************************************************
    @Name 			: fetchQuoteId
    @Parameters 	: Opportunity Id
    @Reutrn type 	: ID
    @Description 	: Get Quote of related 
	********************************************************/
    @AuraEnabled 
    public static Id fetchQuoteId(Opportunity opp){
        System.debug('oppid:::'+opp);
        SBQQ__Quote__c quot;
        For(SBQQ__Quote__c qt :[Select id 
                                From SBQQ__Quote__c 
                                Where SBQQ__Opportunity2__c =: opp.Id 
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
    /*********************************************************
    @Name 			: getStandardPB
    @Parameters 	: Void
    @Reutrn type 	: String
    @Description 	: Get Standard PriceBook
	********************************************************/
     public static string getStandardPB(){
        For(Pricebook2 pb :[Select id, name 
                            From Pricebook2 
                            Where isStandard = true]){
            if(pb!= null){
                return pb.id;
            }
        }
        return null;
    }
    /*********************************************************
    @Name 			: saveOpportunitySite
    @Parameters 	: Void
    @Reutrn type 	: PageReference
    @Description 	: Save Opportunity Sites
	********************************************************/
    public  PageReference saveOpportunitySite(){
        try{
            recordId = Apexpages.currentPage().getParameters().get('Id');
            Id oppId = recordId;
            // Local variables
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
            Decimal oppSupPrice;
            String serviceAddressAccount;
            Decimal totalVolume = 0;
            Product2 selectedProduct;
            String commodityType ; 
            SBQQ__QuoteLine__c quoteLine; 
            SBQQ__QuoteLine__c existedQLI;
            Opportunity_Site__c oppsite;
            String size = ConstantString.SMALL_TYPE;
            List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
            List<Opportunity_Site__c > siteList = new List<Opportunity_Site__c >();
            Map<ID, Site__c> selectedSites = new Map<ID, Site__c>();
            
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
                productId = qli.SBQQ__Product__c;
                
            }
            System.debug('existedQLI:::'+existedQLI);
            
            //Get Selected Sites
            
            List<String> siteIds = siteIds.split(',');
            totalVolume = oppty.Total_Volume__c;
            For(Site__c site : [Select Id, Opportunity__c,Opportunity__r.Supplier_Price__c,
                                       Opportunity__r.Margin__c,volume__c, type__c,Market__c 
                                From Site__c 
                                Where Id IN:siteIds ]){
                selectedSites.put(site.Id, site);
                if(site.volume__c != null){
                    totalVolume += site.volume__c;
                }
                commodityType = site.type__c;
            }
            system.debug('selectedSites::::' +selectedSites);
            System.debug('totalVolume::'+totalVolume);
            // Check Business Size
            if(commodityType == ConstantString.PRODUCT_GAS){
                if(totalVolume > oppty.Market__r.Gas_Threshold__c ){
                   size = ConstantString.SIZE_LARGE; 
                }
            }else if(commodityType == ConstantString.PRODUCT_ELECTRICITY){
                if(totalVolume > oppty.Market__r.Electricity_Threshold__c ){
                  size = ConstantString.SIZE_LARGE; 
                }
            }
            if(priceType == ConstantString.PRICE_TYPE_CUSTOM){
                size = null;
            }
            //Get Product 
            String proName = ConstantString.PRODUCT_GAS;
            String proCode = '';
            String sizePro;
           for( Product2 product :[Select Id,Name,Size__c,ProductCode 
                                            From Product2 
                                            Where Family =:commodityType
                                            And Price_Type__c  =:priceType and Size__c =:size Limit 1 ])
            {
                        selectedProduct =  product;   
                        proCode = product.ProductCode;
                        sizePro  = product.Size__c;
            }
            system.debug('product::::'+selectedProduct);
            if(proCode.contains(ConstantString.PRODUCT_ELECTRICITY)){
                proName = ConstantString.PRODUCT_ELECTRICITY;
            }
            System.debug('sizePro::'+sizePro);
            System.debug('proName::'+proName);
            Decimal listPrice = 0;
            Map<Id,List<Price_List__c>> priceListMap = new  Map<Id,List<Price_List__c>>();
            //Get latest Price from PriceList
            priceListMap = PriceListUtility.getTodayPriceList(market,proName,sizePro,supplier);
            
            For(List<Price_list__c> plList :priceListMap.values()){
                for(Price_list__c price :plList){
                    if(price.Month_Year__c == monthYear && price.Term__c == String.valueOf(subscriptionTerm) ){
                        listPrice = price.List_Price__c;
                    }
                }
            }
            //Get latest list Price 
            margin = 0;
            oppSupPrice = 0;
            if( oppty.Margin__c != Null){
                margin = oppty.Margin__c;
            }
            if( oppty.Supplier_Price__c != Null){
                    oppSupPrice = oppty.Supplier_Price__c;
            }
            listPriceMargin= listPrice + margin;
            System.debug('listPriceMargin::'+listPriceMargin);
            
            //Create QLI [ Commented as this moved on OppSite Trigger ]
            //CreateQuoteLineUtility.createQLI(selectedProduct.Id,quotId,selectedSites.values(),listPriceMargin,subscriptionTerm,oppty.Margin__c,oppSupPrice);
            System.debug('siteIds = '+siteIds);
            //Fetch existing Opportunity Sites 
            Map<ID,Opportunity_Site__c> existingOppSites = new Map<ID,Opportunity_Site__c>();
            for(Opportunity_Site__c opSite : [Select id,Site__c from Opportunity_Site__c 
                                               Where Opportunity__c =: oppId]){
                  existingOppSites.put(opSite.Site__c,opSite);  
            }
            // Create Opportunity-Site Junction Record 
            for(Site__c st :[Select id From Site__c Where id IN:siteIds]){
                if(!existingOppSites.containsKey(st.id)){
                    oppsite = new Opportunity_Site__c ();
                    oppsite.Market__c = market;
                    oppsite.Site__c = st.id;
                    oppsite.Opportunity__c = oppId;
                    siteList.add(oppsite);
                }
            }
            System.debug('siteList::'+siteList);
            if(siteList.size()>0){
                
                INSERT siteList;
            }
            /*Integer totalSites = siteList.size();
                system.debug('totalSites-Record::'+totalSites); 
                Set<id> OppIdSet = new Set<id>();
                For(Opportunity_Site__c site: siteList){
                    OppIdSet.add(site.Opportunity__c);
                }
                List<Opportunity> OppList = new List<Opportunity>();
                For(Opportunity Opp : [select id,Sites_tied_to_Opportunity__c from Opportunity where id IN: OppIdSet]){
                    if(Opp.Sites_tied_to_Opportunity__c == null || String.isBlank(string.valueOf(Opp.Sites_tied_to_Opportunity__c))){
                        Opp.Sites_tied_to_Opportunity__c = 0; 
                    }
                    Opp.Sites_tied_to_Opportunity__c = Opp.Sites_tied_to_Opportunity__c + totalSites;
                    OppList.add(Opp);
                }
                system.debug('OppList ::'+OppList);
                if(OppList.size()>0){
                    update OppList;
                }*/
            //AmendmentOpportunityTriggerHandler.CreateCalculationOLI(OppList);
        }
        catch(Exception e){
            if(e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            System.debug('exception is -->' + e.getMessage());
            return null;
            }
        
        PageReference oppPage = new PageReference('/' +recordId);
		return oppPage;

        //return null;
    }
    /*********************************************************
    @Name 			: deleteSiteMethod
    @Parameters 	: Void
    @Reutrn type 	: void
    @Description 	: Delete Sites
	********************************************************/
    public void deleteSiteMethod(){
        recordId = Apexpages.currentPage().getParameters().get('Id');
        System.debug('siteIdToDelete = '+siteIdToDelete+'  recordId = '+ recordId);
        try{
            Delete [Select id from Opportunity_Site__c where Site__c =: siteIdToDelete AND Opportunity__c =: recordId limit 1];  
            getRecordsInString(recordId);
        }catch(Exception ex){
            System.debug('Exception: '+ ex.getMessage());
        }
        
    }
    /*********************************************************
    @Name 			: Cancel
    @Parameters 	: Void
    @Reutrn type 	: void
    @Description 	: Cancel
	********************************************************/
    public pageReference Cancel(){
        recordId = Apexpages.currentPage().getParameters().get('Id');
        return new pageReference('/'+recordId);
    }
    /*********************************************************
    @Name 			: SiteWrapper
    @Parameters 	: Void
    @Reutrn type 	: void
    @Description 	: SiteWrapper
	********************************************************/
    public class SiteWrapper{
        
        public Site__c site {get;set;}
        public Boolean isAddedSite {get;set;}
        
        public SiteWrapper(Site__c site, Boolean isAddedSite){
            this.site = site;       
            this.isAddedSite = isAddedSite;
        }
    }
    /*********************************************************
    @Name 			: TreeWrapper
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: 
	********************************************************/
    public class TreeWrapper{
        
        public String parentAccountId {get;set;}
        public Account addressAccount {get;set;}
        public List<SiteWrapper> siteWrap {get;set;}
       
    /*********************************************************
    @Name 			: TreeWrapper
    @Parameters 	: String parentId
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
    public TreeWrapper(String parentId){
        this.parentAccountId = parentId;
        this.addressAccount = new Account();
        this.siteWrap = new List<SiteWrapper>();        
    }  
    /*********************************************************
    @Name 			: TreeWrapper
    @Parameters 	: String parentId, Account acc
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
        public TreeWrapper(String parentId, Account acc){
            this.parentAccountId = parentId;
            this.addressAccount = acc;
            this.siteWrap = new List<SiteWrapper>();
        }
        
    /*********************************************************
    @Name 			: addSite
    @Parameters 	: Site__c site
    @Reutrn type 	: void
    @Description 	: 
	********************************************************/
        public void addSite(Site__c site, Boolean isAddedSite){
            this.siteWrap.add(new SiteWrapper(site, isAddedSite));
        }
	        
    } // End Of Wrapper Class
    
}// End of Controller Class