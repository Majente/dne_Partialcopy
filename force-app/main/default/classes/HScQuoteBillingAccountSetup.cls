public class HScQuoteBillingAccountSetup {

    public List<HSwQuoteDetail> QuoteDetailList {get; private set;}
    public String quoteId {get; set;}
    
    public HScQuoteBillingAccountSetup(){
        QuoteDetailList = new List<HSwQuoteDetail>();
        quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        if(quoteId != null && quoteId.length() > 0){
            loadQuoteDetails();
        }
    }
    
    public void loadQuoteDetails(){
        List<SBQQ__QuoteLine__c> QuoteLineList = [select id,SBQQ__Number__c,Site__c,Site__r.name,Site__r.Address__c,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__Quote__r.SBQQ__Account__r.name,SBQQ__Quote__r.SBQQ__Account__r.BillingStreet, SBQQ__Quote__r.SBQQ__Account__r.BillingCity, SBQQ__Quote__r.SBQQ__Account__r.BillingState, SBQQ__Quote__r.SBQQ__Account__r.BillingPostalCode, SBQQ__Quote__r.SBQQ__Account__r.BillingCountry from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId order by SBQQ__Number__c];  
        Map<String,List<SBQQ__QuoteLine__c>> QuoteLineMap = new Map<String,List<SBQQ__QuoteLine__c>>();
        List<String> accountIdList = new List<String>();
        if(QuoteLineList != null && QuoteLineList.size() > 0){
            for(SBQQ__QuoteLine__c QuoteLineObj : QuoteLineList){
                if(QuoteLineMap != null && QuoteLineMap.containskey(QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__c)){
                    List<SBQQ__QuoteLine__c> TempQuoteLineList = QuoteLineMap.get(QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__c);
                    TempQuoteLineList.add(QuoteLineObj);                    
                    QuoteLineMap.put(QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__c,TempQuoteLineList);
                }
                else{
                    List<SBQQ__QuoteLine__c> TempQuoteLineList = new List<SBQQ__QuoteLine__c>();
                    TempQuoteLineList.add(QuoteLineObj);
                    QuoteLineMap.put(QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__c,TempQuoteLineList);
                    accountIdList.add(QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__c);
                }
            }
        }
        integer count = 1;
        if(accountIdList != null && accountIdList.size() > 0){
            for(String accountId : accountIdList){
                if(QuoteLineMap != null && QuoteLineMap.containskey(accountId)){
                    List<SBQQ__QuoteLine__c> TempQuoteLineList = QuoteLineMap.get(accountId);
                    if(TempQuoteLineList != null && TempQuoteLineList.size() > 0){
                        List<HSwSite> siteList = new List<HSwSite>();
                        String AccountName = null;
                        String BillingStreet = null;
                        String BillingCity = null;
                        String BillingState = null;
                        String BillingPostalCode = null;
                        String BillingCountry = null;
                        String BillingMailingAddress = null;
                        for(SBQQ__QuoteLine__c QuoteLineObj : TempQuoteLineList){
                            HSwSite siteObj = new HSwSite();
                            siteObj.SiteIDs = QuoteLineObj.Site__r.name;
                            siteObj.SiteAddress = QuoteLineObj.Site__r.Address__c;
                            siteList.add(siteObj);
                            AccountName = QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__r.name;
                            
                            BillingStreet = QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__r.BillingStreet;
                            BillingCity = QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__r.BillingCity;
                            BillingState = QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__r.BillingState;
                            BillingPostalCode = QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__r.BillingPostalCode;
                            BillingCountry = QuoteLineObj.SBQQ__Quote__r.SBQQ__Account__r.BillingCountry;
                            

                            siteObj.AccountName = AccountName;
                            siteObj.BillingStreet = BillingStreet;
                            siteObj.BillingCity = BillingCity;
                            siteObj.BillingState = BillingState;
                            siteObj.BillingPostalCode = BillingPostalCode;
                            siteObj.BillingCountry = BillingCountry;
                            
                        }
                        if(AccountName != null && AccountName.length() > 0){
                            HSwQuoteDetail obj = new HSwQuoteDetail();
                            obj.BillingAccountNo = count;
                            obj.AccountName = AccountName;
                            obj.BillingStreet = BillingStreet;
                            obj.BillingCity = BillingCity;
                            obj.BillingState = BillingState;
                            obj.BillingPostalCode = BillingPostalCode;
                            obj.BillingCountry = BillingCountry;
                            obj.siteList = siteList;
                            obj.NumberRowsSpanned = 0;
                            if(siteList != null && siteList.size() > 0){
                                obj.NumberRowsSpanned = siteList.size();
                            }
                            QuoteDetailList.add(obj);
                            count = count+1;
                        }
                    }
                }    
            }
        }
        
    }
    
    
    
    public class HSwQuoteDetail {
        public Integer BillingAccountNo {get; set;}
        public Integer NumberRowsSpanned {get; set;}
        public String AccountName {get; set;}
        public String BillingStreet {get; set;}
        public String BillingCity {get; set;}
        public String BillingState {get; set;}
        public String BillingPostalCode {get; set;}
        public String BillingCountry {get; set;}
        public String getBillingAddress(){
            return BillingStreet+'/n'+BillingCity;
        }
        
        
        public List<HSwSite> siteList {get; set;}
        
    }
    
    public class HSwSite {
        public String SiteIDs {get; set;}
        public String SiteAddress {get; set;}
        public String AccountName {get; set;}
        public String BillingStreet {get; set;}
        public String BillingCity {get; set;}
        public String BillingState {get; set;}
        public String BillingPostalCode {get; set;}
        public String BillingCountry {get; set;}
    }
}