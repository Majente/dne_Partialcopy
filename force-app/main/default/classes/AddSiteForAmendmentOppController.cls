/**************************************************
* Class : AddSiteForAmendmentOppController
* Author: Soljit <VW>
* Date  : AUG 2020
* Description : apex controller used to add sites for amendment opportunity
****************************************************/
public class AddSiteForAmendmentOppController {
    public Id OppId;
    public Opportunity selectedOpp;
    public Set<Id> oppIdsWithMainOpportunity;
    public Set<Id> siteIds;
    public Date cancellationDate {get;set;}
    public List<SiteWrapper> siteWrapperList {get;set;}
    
    /*********************************************************
@Name 			: AddSiteForAmendmentOppController
@Parameters 	: ApexPages.StandardController
@Reutrn type 	: void
@Description 	: Constructor
********************************************************/
    public AddSiteForAmendmentOppController(ApexPages.StandardController std){
        OppId = std.getId();
        System.debug('OppId--->' + OppId);
        oppIdsWithMainOpportunity = new Set<Id>();
        siteIds = new Set<Id>();
        cancellationDate = System.today();
        siteWrapperList = new List<SiteWrapper>();
        for(Opportunity opp : [SELECT Id,Main_Opportunity__c,AccountId,Market__c,Pricebook2Id,Supplier__c,Commodity_Type__c,
                               Month_Year__c,Selling_Price__c,Supplier_Price__c, Margin__c,Admin_Fee__c,DNE_Admin_Fee__c,
                               Type,Product_of_Choice__c,Subscription_Term__c FROM Opportunity WHERE Id =: OppId LIMIT 1]){
                                   selectedOpp = opp;
                                   oppIdsWithMainOpportunity.add(opp.Id);
                               }
        System.debug('selectedOpp---->' + selectedOpp);
        if(selectedOpp.Main_Opportunity__c != null){
            for(Opportunity opp : [SELECT Id,Main_Opportunity__c FROM Opportunity WHERE Main_Opportunity__c =: selectedOpp.Main_Opportunity__c]){
                oppIdsWithMainOpportunity.add(opp.Id);
            }   
        }
        System.debug('oppIdsWithMainOpportunity---->' + oppIdsWithMainOpportunity.size());
        if(oppIdsWithMainOpportunity.size() > 0){
            for(Opportunity_Site__c oppSite : [SELECT Id,Opportunity__c,Site__c FROM Opportunity_Site__c WHERE 
                                               Opportunity__c IN: oppIdsWithMainOpportunity]){
                                                   siteIds.add(oppSite.Site__c);   
                                               }
        }
        System.debug('siteIds--->' + siteIds.size());
        if(siteIds.size() > 0){
            for(Site__c site : [SELECT Id,Contract_type__c,Account__c,Market__c,Market__r.Name,Opportunity__c,Site_Market_Account_Name__c,
                                Name,Type__c,Volume__c,Unit_of_Measure__c FROM Site__c WHERE Id IN: siteIds]){
                                    siteWrapperList.add(new SiteWrapper(false,site));    
                                }
        }
        System.debug('siteWrapperList---->' + siteWrapperList.size());
    }
    /*********************************************************
@Name 			: goToOpportunity
@Parameters 	: 
@Reutrn type 	: PageReference
@Description 	: method used for return on opportunity
********************************************************/
    public PageReference goToOpportunity(){
        PageReference pg = new PageReference('/'+ OppId);
        pg.setRedirect(true);
        return pg;    
    }
    /*********************************************************
@Name 			: saveSitesOnOpportunity
@Parameters 	: 
@Reutrn type 	: PageReference
@Description 	: method used for create new amendment opportunity with selected sites
********************************************************/
    public PageReference saveSitesOnOpportunity(){
        Integer unSelectedRecords = 0;
        List<Opportunity_Site__c> opportunitySitesList = new List<Opportunity_Site__c>();
        for(SiteWrapper sWrapper : siteWrapperList){
            if(!sWrapper.isSiteSelected){
                unSelectedRecords ++;
            }
        }
        System.debug('unSelectedRecords--->' + unSelectedRecords);
        System.debug('siteWrapperList---->' + siteWrapperList.size());
        if(unSelectedRecords == siteWrapperList.size()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, System.Label.No_Record_Selected_Error_Label);
            ApexPages.addMessage(myMsg);
            return null;
        }
        Id amendRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        // create new amendment opportunity
        Opportunity amendOpp = new Opportunity();
        amendOpp.Name = 'Amendment Opportunity - ' + System.today().format();
        amendOpp.AccountId = selectedOpp.AccountId;
        amendOpp.StageName = 'Qualification';
        amendOpp.CloseDate = System.today();
        amendOpp.Main_Opportunity__c = selectedOpp.Main_Opportunity__c;
        amendOpp.RecordTypeId = amendRecordTypeId;
        amendOpp.Market__c = selectedOpp.Market__c;
        amendOpp.Pricebook2Id = selectedOpp.Pricebook2Id;
        amendOpp.Supplier__c = selectedOpp.Supplier__c;
        amendOpp.DNE_Admin_Fee__c = selectedOpp.DNE_Admin_Fee__c;
        amendOpp.Commodity_Type__c = selectedOpp.Commodity_Type__c;
        amendOpp.Supplier_Price__c = selectedOpp.Supplier_Price__c;
        amendOpp.Selling_Price__c = selectedOpp.Selling_Price__c;
        amendOpp.Subscription_Term__c  = selectedOpp.Subscription_Term__c;
        amendOpp.Month_Year__c = selectedOpp.Month_Year__c;
        amendOpp.Margin__c = selectedOpp.Margin__c;
        amendOpp.Admin_Fee__c = selectedOpp.Admin_Fee__c;
        amendOpp.Product_of_Choice__c = selectedOpp.Product_of_Choice__c;
        amendOpp.Type = selectedOpp.Type;
        
        try{
            INSERT amendOpp;
        }Catch(Exception ex){
            System.debug('exception is -->' + ex.getMessage());
            if(ex.getTypeName() == 'System.DmlException' || ex.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
            return null;
        }
        
        // add sites for amend opportunity
        for(SiteWrapper sWrapper : siteWrapperList){
            if(sWrapper.isSiteSelected){
                Opportunity_Site__c siteRec = new Opportunity_Site__c();
                siteRec.Opportunity__c = amendOpp.Id;
                siteRec.Market__c = sWrapper.selectedSite.Market__c;
                siteRec.Site__c = sWrapper.selectedSite.Id;
                siteRec.Flag__c = true;
                opportunitySitesList.add(siteRec);
            }
        }
        
        try{
            if(opportunitySitesList.size() > 0){
                INSERT opportunitySitesList;
                
            } 
        }catch(Exception ex){
            System.debug('site exception is -->' + ex.getMessage());
            if(ex.getTypeName() == 'System.DmlException' || ex.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
            return null;
        }
        PageReference pr = new PageReference('/'+ amendOpp.id); 
        pr.setRedirect(true);
        return pr;   
    }
    /*********************************************************
@Name 			: saveSitesForCancellation
@Parameters 	: 
@Reutrn type 	: PageReference
@Description 	: method used for create new amendment opportunity with selected sites when cancel the contract
********************************************************/
    public PageReference saveSitesForCancellation(){
        List<Contract> contractList = new List<Contract>();
        for(Contract cont : [SELECT Id,SBQQ__Opportunity__c,Status FROM Contract WHERE SBQQ__Opportunity__c =: OppId LIMIT 1]){
            contractList.add(cont);
        }
        System.debug('contractList--->' + contractList.size());
        if(contractList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.No_Contract_Found_Error_Label));
            return null;                     
        }
        
        try{
            contractList[0].Status = 'Cancelled';
            UPDATE contractList[0];
        }Catch(Exception ex){
            System.debug('exception is -->' + ex.getMessage());
            if(ex.getTypeName() == 'System.DmlException' || ex.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
            return null;
        }
        List<Opportunity_Site__c> opportunitySitesList = new List<Opportunity_Site__c>();
        Id amendRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        // create new amendment opportunity
        Opportunity amendOpp = new Opportunity();
        amendOpp.Name = 'Amendment Opportunity - ' + System.today().format();
        amendOpp.AccountId = selectedOpp.AccountId;
        amendOpp.StageName = 'Qualification';
        amendOpp.CloseDate = System.today();
        amendOpp.Main_Opportunity__c = selectedOpp.Main_Opportunity__c;
        amendOpp.RecordTypeId = amendRecordTypeId;
        amendOpp.Market__c = selectedOpp.Market__c;
        amendOpp.Pricebook2Id = selectedOpp.Pricebook2Id;
        amendOpp.Supplier__c = selectedOpp.Supplier__c;
        amendOpp.DNE_Admin_Fee__c = selectedOpp.DNE_Admin_Fee__c;
        amendOpp.Commodity_Type__c = selectedOpp.Commodity_Type__c;
        amendOpp.Supplier_Price__c = selectedOpp.Supplier_Price__c;
        amendOpp.Selling_Price__c = selectedOpp.Selling_Price__c;
        amendOpp.Subscription_Term__c  = selectedOpp.Subscription_Term__c;
        amendOpp.Month_Year__c = selectedOpp.Month_Year__c;
        amendOpp.Margin__c = selectedOpp.Margin__c;
        amendOpp.Admin_Fee__c = selectedOpp.Admin_Fee__c;
        amendOpp.Product_of_Choice__c = selectedOpp.Product_of_Choice__c;
        amendOpp.Type = selectedOpp.Type;
        
        try{
            INSERT amendOpp;
        }Catch(Exception ex){
            System.debug('exception is -->' + ex.getMessage());
            if(ex.getTypeName() == 'System.DmlException' || ex.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
            return null;
        }
        
        // add sites for amend opportunity
        for(SiteWrapper sWrapper : siteWrapperList){
            Opportunity_Site__c siteRec = new Opportunity_Site__c();
            siteRec.Opportunity__c = amendOpp.Id;
            siteRec.Market__c = sWrapper.selectedSite.Market__c;
            siteRec.Site__c = sWrapper.selectedSite.Id;
            siteRec.Flag__c = true;
            opportunitySitesList.add(siteRec);
        }
        
        try{
            if(opportunitySitesList.size() > 0){
                INSERT opportunitySitesList;
                
            } 
        }catch(Exception ex){
            System.debug('site exception is -->' + ex.getMessage());
            if(ex.getTypeName() == 'System.DmlException' || ex.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
            return null;
        }
        PageReference pr = new PageReference('/'+ amendOpp.id); 
        pr.setRedirect(true);
        return pr;
    }
    /*********************************************************
@Name 			: SiteWrapper
@Description 	: wrapper class contains boolean,site and date instance
********************************************************/
    public class SiteWrapper{
        public boolean isSiteSelected {get;set;}
        public Site__c selectedSite {get;set;}
        public Date effectiveDate {get;set;}
        
        public SiteWrapper(boolean isSiteSelected,Site__c selectedSite){
            this.isSiteSelected = isSiteSelected;
            this.selectedSite = selectedSite;
        }
    }
    
}