/**************************************************

* Class: RenewalOpportunitySync
* Author: Soljit <VW>
* Date: 2020-06-22
* Description: Sync renewal opportunity of contract

****************************************************/
public class RenewalOpportunitySync {
    
    /*********************************************************
    @Name           : syncOpportunity
    @Parameters     : 
    @Return type    : void
    @Description    : 
    ********************************************************/
    @AuraEnabled
    public static Result createRenewalOpportunity(String contractId){
        system.debug('contractId'+contractId);
        Result res = new Result();
        try{     
            
            Contract mContract = [Select Id, SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.RenewalContractId__c,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Market__c,
                                  SBQQ__Opportunity__r.Commodity_Type__c,SBQQ__Opportunity__r.Subscription_Term__c,SBQQ__RenewalForecast__c,
                                  SBQQ__Opportunity__r.Supplier__c,SBQQ__Opportunity__r.Supplier_Price__c,SBQQ__RenewalOpportunity__r.Subscription_Term__c,
                                  SBQQ__Opportunity__r.Flow_Date__c,SBQQ__Opportunity__r.Margin__c,SBQQ__Opportunity__r.DNE_Admin_Fee__c
                                  From Contract 
                                  Where Id =: contractId Limit 1];
            if(mContract.SBQQ__RenewalForecast__c == false && mContract.SBQQ__RenewalOpportunity__c == null){
                mContract.SBQQ__RenewalForecast__c = true;
                UPDATE mContract;
                res.status = 'Success';
                res.msg = System.Label.Renewal_created_successfully_label;
                return res;
            }
            res.status = 'Error';
            res.msg = System.Label.Renewal_already_created_label;
            return res;
        }catch( Exception ex){
            system.debug('Exception Occured While Saving Record:::::::'+ex.getMessage());
            res.status = 'Error';
            res.msg = ex.getMessage();
            return res;  
        }        
    }    
    
    /*********************************************************
    @Name           : syncOpportunity
    @Parameters     : 
    @Return type    : void
    @Description    : 
    ********************************************************/
    @AuraEnabled
    public static Result syncOpportunity(String contractId){
        Opportunity renewalOpps; 
        Opportunity_Site__c oppSite;
        List<Opportunity_Site__c> oppSiteList = new List<Opportunity_Site__c>();
        List<OpportunityLineItem> listOfOLIs = new List<OpportunityLineItem> ();
        Map<String, Opportunity_Site__c> siteOppSiteMap = new  Map<String, Opportunity_Site__c> ();
        Result res = new Result();
        try{     
        
        Contract mContract = [Select Id, SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.RenewalContractId__c,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Market__c,
                              SBQQ__Opportunity__r.Commodity_Type__c,SBQQ__Opportunity__r.Subscription_Term__c,SBQQ__RenewalForecast__c,
                              SBQQ__Opportunity__r.Supplier__c,SBQQ__Opportunity__r.Supplier_Price__c,SBQQ__RenewalOpportunity__r.Subscription_Term__c,
                              SBQQ__Opportunity__r.Flow_Date__c,SBQQ__Opportunity__r.Margin__c,SBQQ__Opportunity__r.DNE_Admin_Fee__c
                              From Contract 
                              Where Id =: contractId Limit 1];
        /*if(mContract.SBQQ__RenewalForecast__c == false && mContract.SBQQ__RenewalOpportunity__c == null){
            mContract.SBQQ__RenewalForecast__c = true;
            UPDATE mContract;
            SBQQ__Quote__c quote = [Select Id, SBQQ__Primary__c from SBQQ__Quote__c where SBQQ__Opportunity2__c = :mContract.SBQQ__RenewalOpportunity__c Limit 1];             
            if(quote != null){
                updateQuote(quote.ID);
                //quote.SBQQ__Primary__c = true;
                //UPDATE quote;
            }
            
            System.debug('quote ::: ' + quote);            
            res.status = 'Success';
            res.msg = System.Label.Renewal_Opportunity_Sync_Successfully;
            return res;
        }
        else if(mContract.SBQQ__RenewalForecast__c == True && mContract.SBQQ__RenewalOpportunity__c != null){
            
            SBQQ__Quote__c quote = [Select Id, SBQQ__Primary__c from SBQQ__Quote__c where SBQQ__Opportunity2__c = :mContract.SBQQ__RenewalOpportunity__c Limit 1];             
            if(quote != null && quote.SBQQ__Primary__c == false){                
                quote.SBQQ__Primary__c = true;
                UPDATE quote;
                res.status = 'Success';
                res.msg = System.Label.Renewal_Opportunity_Sync_Successfully;
                return res;
            }
        }
        /*mContract = [Select Id, SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.RenewalContractId__c,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Market__c,
                              SBQQ__Opportunity__r.Commodity_Type__c,SBQQ__Opportunity__r.Subscription_Term__c,SBQQ__RenewalForecast__c,
                              SBQQ__Opportunity__r.Supplier__c,SBQQ__Opportunity__r.Supplier_Price__c,SBQQ__RenewalOpportunity__r.Subscription_Term__c,
                              SBQQ__Opportunity__r.Flow_Date__c,SBQQ__Opportunity__r.Margin__c,SBQQ__Opportunity__r.DNE_Admin_Fee__c
                              From Contract 
                              Where Id =: contractId Limit 1]; */       
        if(mContract.SBQQ__RenewalOpportunity__c == null){
            system.debug('Contract Without Renewal Opportunity::');
            res.status = 'Error';
            res.msg = System.Label.Contract_without_Renewal_Opportunity;
            return res; 
        }
        system.debug('mContract.SBQQ__RenewalOpportunity__c::'+mContract.SBQQ__RenewalOpportunity__c);
       
        // Fetch Opportunity Products
        listOfOLIs = [Select Id, SortOrder, PricebookEntryId, Product2Id, ProductCode, Quantity, 
                                       UnitPrice, ListPrice, ServiceDate, Description, SBQQ__ParentID__c,OpportunityId, 
                                       SBQQ__QuoteLine__c, SBQQ__SubscriptionType__c, Amend_Quantity__c, Deal_Price__c, 
                                       Month_Year__c, Selling_Price__c, Site__c, Supplier_Price__c,Site__r.Market__c  
                                       From OpportunityLineItem 
                                       Where OpportunityId =:mContract.SBQQ__RenewalOpportunity__c];
        System.debug('listOfOLIs ::: ' + listOfOLIs);
          List<Opportunity_Site__c> opportunitySite =  [Select Id, Market__c,Site__c,
                                                          Opportunity__c,Contract__c,Quantity__c 
                                                          FROM Opportunity_Site__c 
                                                          WHERE Opportunity__c =: mContract.SBQQ__RenewalOpportunity__c];
        
                System.debug('opportunitySite ::: ' + opportunitySite);

            if(opportunitySite.size() > 0){
                system.debug('opportunitySite.size():::::::'+opportunitySite.size());
                DELETE opportunitySite;
            }
            if(listOfOLIs.size() > 0){
                system.debug('listOfOLIs.size():::::::'+listOfOLIs.size());
                DELETE listOfOLIs;
            }  
        
        for(SBQQ__Subscription__c subs : [SELECT Id, SBQQ__Quantity__c, SBQQ__ListPrice__c,
                                          Adder_Margin__c, Site__r.Market__c,Site__c,Annual_Volume__c,
                                          SBQQ__Contract__c,SBQQ__StartDate__c FROM SBQQ__Subscription__c
                                          WHERE SBQQ__Contract__c =: mContract.Id AND Annual_Volume__c != 0])
        {
            if(!siteOppSiteMap.containskey(subs.Site__c)){
                oppSite = new Opportunity_Site__c();
                oppsite.Quantity__c = 0;
                siteOppSiteMap.put(subs.Site__c,oppSite);
            }
            oppSite = siteOppSiteMap.get(subs.Site__c);
            oppsite.Market__c = subs.Site__r.Market__c;
            oppsite.Site__c = subs.Site__c;
            oppsite.Opportunity__c = mContract.SBQQ__RenewalOpportunity__c;
            oppsite.Contract__c = contractId;
            oppsite.Quantity__c = subs.Annual_Volume__c*(mContract.SBQQ__RenewalOpportunity__r.Subscription_Term__c/12);
            system.debug('subs.SBQQ__Quantity__c:::::'+subs.SBQQ__Quantity__c);
        }
        
            
            if(siteOppSiteMap.size() > 0){
                INSERT siteOppSiteMap.values();
                res.status = 'Success';
                res.msg = System.Label.Renewal_Opportunity_Sync_Successfully;
                return res;
            } 
            res.status = 'Success';
            res.msg = System.Label.Renewal_Opportunity_Sync_Successfully;
            return res;            
        }catch( Exception ex){
            system.debug('Exception Occured While Saving Record:::::::'+ex.getMessage());
            res.status = 'Error';
            res.msg = ex.getMessage();
            return res;  
        }
    }
    
     @future
    public static void updateQuote(Id quoteId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId, SBQQ__Primary__c = true);
        UPDATE quote;
        System.debug('quote updated::: ' + quote);            
    } 
         
/***************************************************************************************
@Name           : Result
@Description    : Wrapper class that contains strings to show messages
***************************************************************************************/
    public class Result{
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String msg {get;set;}
    }
    

}