/**************************************************
* Class : AmendedOppForCancellationController
* Author: Soljit <VW>
* Date  : AUG 2020
* Description : apex controller used to add sites for amendment opportunity when cancel the contract
****************************************************/
public class AmendedOppForCancellationController {
    public Id OppId;
    public Opportunity selectedOpp;
    public Set<Id> oppIdsWithMainOpportunity;
    public Set<Id> siteIds;
    public Date cancellationDate {get;set;}
    public List<Site__c> siteListForAmendOpp;
    public List<Contract> contractList;
    public boolean isContractAvailable {get; set;}
    
    /*********************************************************
@Name 			: AmendedOppForCancellationController
@Parameters 	: ApexPages.StandardController
@Reutrn type 	: void
@Description 	: Constructor
********************************************************/
    public AmendedOppForCancellationController(ApexPages.StandardController stdController) {
        OppId = stdController.getId();
        System.debug('OppId--->' + OppId);
        oppIdsWithMainOpportunity = new Set<Id>();
        siteIds = new Set<Id>();
        cancellationDate = System.today();
        siteListForAmendOpp = new List<Site__c>();
        contractList = new List<Contract>();
        isContractAvailable = true;
        
        for(Contract cont : [SELECT Id,SBQQ__Opportunity__c,Status FROM Contract WHERE SBQQ__Opportunity__c =: OppId LIMIT 1]){
            contractList.add(cont);
        }
        System.debug('contractList--->' + contractList.size());
        if(contractList.size() == 0){
            isContractAvailable = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.No_Contract_Found_Error_Label));
            return ;                     
        }
        System.debug('isContractAvailable--->' + isContractAvailable);
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
                                    siteListForAmendOpp.add(site);    
                                }
        }
        System.debug('siteListForAmendOpp---->' + siteListForAmendOpp.size());
    }
    
    /*********************************************************
@Name 			: saveSitesForCancellation
@Parameters 	: 
@Reutrn type 	: PageReference
@Description 	: method used for create new amendment opportunity with selected sites when cancel the contract
********************************************************/
    public PageReference saveSitesForCancellation(){
        System.debug('cancellationDate--->' + cancellationDate);
        if(cancellationDate == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Cancel_Date_Error_Label));
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
        for(Site__c siteRec : siteListForAmendOpp){
            Opportunity_Site__c oppSiteRec = new Opportunity_Site__c();
            oppSiteRec.Opportunity__c = amendOpp.Id;
            oppSiteRec.Market__c = siteRec.Market__c;
            oppSiteRec.Site__c = siteRec.Id;
            oppSiteRec.Flag__c = true;
            opportunitySitesList.add(oppSiteRec);
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
@Name 			: cancel
@Parameters 	: 
@Reutrn type 	: PageReference
@Description 	: method used for return on opportunity
********************************************************/
    public PageReference cancel(){
        PageReference pg = new PageReference('/'+OppId);
        pg.setRedirect(true);
        return pg;
    }
}