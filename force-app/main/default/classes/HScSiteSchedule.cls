public class HScSiteSchedule{

    public String quoteId{get; set;}
    public List<HSwSite> siteScheduleList{get; private set;}
    
    
    
    public HScSiteSchedule(){
        quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        siteScheduleList = new List<HSwSite>();
        
        if(quoteId != null && quoteId.length() > 0){
            loadSiteSchedule();
        }
    }
    
    public void loadSiteSchedule(){
        
        
        List<SBQQ__QuoteLine__c> QuoteLineList = [select id,Site__c,Site__r.name, Site__r.Account__r.Name ,Site__r.Address__c, Site__r.Volume__c, Site__r.Account__r.ShippingCity, Site__r.Account__r.ShippingPostalCode, SBQQ__Quote__r.SBQQ__StartDate__c ,SBQQ__Quote__r.Company_Address__c,  SBQQ__Quote__r.Company_State__c, SBQQ__Quote__r.Company_Country__c, SBQQ__Quote__r.Company_City__c, SBQQ__Quote__r.Company_Postal_Code__c, SBQQ__Quote__r.Company_Legal_Name__c, SBQQ__Quote__r.Selling_Price__c, SBQQ__DefaultSubscriptionTerm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId order by SBQQ__Number__c];  
        
        if(QuoteLineList != null && QuoteLineList.size() > 0){
            Integer count = 1;
            for(SBQQ__QuoteLine__c QuoteLineObj : QuoteLineList){
                HSwSite hSite = new HSwSite();
                hSite.rowNumber = count;
                hSite.SiteName = QuoteLineObj.Site__r.name;
                hSite.SiteLocationName = QuoteLineObj.Site__r.Account__r.Name;
                hSite.AnnualConsumption = QuoteLineObj.Site__r.Volume__c;
                hSite.ServiceAddress = QuoteLineObj.Site__r.Address__c;
                hSite.City = QuoteLineObj.Site__r.Account__r.ShippingCity;
                hSite.PostalCode = QuoteLineObj.Site__r.Account__r.ShippingPostalCode;
                
                hSite.StartDate = QuoteLineObj.SBQQ__Quote__r.SBQQ__StartDate__c;
                hSite.CompanyAddress = QuoteLineObj.SBQQ__Quote__r.Company_Address__c;
                hSite.CompanyState = QuoteLineObj.SBQQ__Quote__r.Company_State__c;
                hSite.CompanyCountry = QuoteLineObj.SBQQ__Quote__r.Company_Country__c;
                hSite.CompanyCity = QuoteLineObj.SBQQ__Quote__r.Company_City__c;
                hSite.CompanyPostalCode = QuoteLineObj.SBQQ__Quote__r.Company_Postal_Code__c;
                
                hSite.SiteID = QuoteLineObj.Site__r.id;
                hSite.LegalCustomerName = QuoteLineObj.SBQQ__Quote__r.Company_Legal_Name__c;
                hSite.QSellingPrice = QuoteLineObj.SBQQ__Quote__r.Selling_Price__c;
                if(QuoteLineObj.SBQQ__DefaultSubscriptionTerm__c != null) {
                    hSite.QLTerm = QuoteLineObj.SBQQ__DefaultSubscriptionTerm__c/12;
                }
                siteScheduleList.add(hSite);
                count++;
            }
        }
    }
    
    public class HSwSite {
        public Integer rowNumber {get; set;}
        public String SiteID {get; set;}
        public String SiteName {get; set;}
        
        public String LegalCustomerName {get; set;}
        public Decimal QSellingPrice {get; set;}
        public Decimal QLTerm {get; set;}
        
        public String SiteLocationName {get; set;}
        public Decimal AnnualConsumption {get; set;}
        public String ServiceAddress {get; set;}
        public String City {get; set;}
        public String PostalCode {get; set;}
        public Date StartDate {get; set;}
        public String CompanyAddress {get; set;}
        public String CompanyState {get; set;}
        public String CompanyCountry {get; set;}
        public String CompanyCity {get; set;}
        public String CompanyPostalCode {get; set;}                                        

    }
}