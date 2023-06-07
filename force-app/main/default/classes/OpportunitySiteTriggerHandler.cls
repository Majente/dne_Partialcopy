/**************************************************

* Class: OpportunitySiteTriggerHandler
* Author: Soljit <VW>
* Date: 2019-09-10
* Description: OpportunitySiteTriggerHandler for OpportunitySiteTrigger

****************************************************/
public class OpportunitySiteTriggerHandler {
    
    
    /*********************************************************
@Name 			: deleteQuoteLines
@Parameters 	: Void
@Reutrn type 	: void
@Description 	: Delete the QuoteLines
********************************************************/
    public static void  deleteQuoteLines(List<Opportunity_Site__c> oppSiteList){
        
        Map<Id,Id> oppSiteMap = new  Map<Id,Id>();
        List<SBQQ__QuoteLine__c> qliDelete = new List<SBQQ__QuoteLine__c>();
        
        //Get all Opportunity Ids related to OppSite
        for(Opportunity_Site__c oppSite :oppSiteList){
            if(oppSite.Site__c != null && oppSite.Opportunity__c != null ){
                oppSiteMap.put(oppSite.Site__c,oppSite.Opportunity__c);
            }
        }
        
        System.debug('oppSiteMap::'+oppSiteMap);
        
        
        for(SBQQ__QuoteLine__c qli :[Select id,Site__c From SBQQ__QuoteLine__c Where SBQQ__Quote__r.SBQQ__Opportunity2__c IN:oppSiteMap.values()]){
            if(oppSiteMap.containskey(qli.Site__c)){
                qliDelete.add(qli);
            }
        }
        System.debug('qliDelete::'+qliDelete);
        if(qliDelete.size()>0){
            delete qliDelete;
        }
    }
    
    //INSERT OPPSITE
    /*********************************************************
@Name 			: insertQLIForOpportunitySites
@Parameters 	: Void
@Reutrn type 	: void
@Description 	: Insert QLIs for Opportunity Sites 
********************************************************/
    Public static void  insertQLIForOpportunitySites(List<Opportunity_Site__c> oppSiteList){
        Map<Id,List<Opportunity_Site__c>> oppSiteMap = new Map<Id,List<Opportunity_Site__c>>();
        List<SBQQ__Quote__c> newquoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Map<ID,Site__c> siteMap = new Map<ID,Site__c>();
        Map<ID,Decimal> oppVolume = new Map<ID,Decimal>();
        Map<ID,ID> siteOppMap = new Map<ID,ID>();
        ID oppId;
        Decimal vol;
        Decimal subTerm = 0;
        String productKey;
        String productId;
        Boolean checkFlag =false ;
        decimal Monthly_Site_Admin_Fee;
        decimal Daily_Site_Admin_Fee;
        Map<ID,String> opportunityVolSizeMap = new Map<ID,String>();
        Map<ID,SBQQ__Quote__c> oppQuoteMap = new  Map<ID,SBQQ__Quote__c>();
        for(Opportunity_Site__c oppSite :oppSiteList){
            if(oppSite.Site__c != null && oppSite.Opportunity__c != null ){
                if(!oppSiteMap.ContainsKey(oppSite.Opportunity__c )){
                    oppSiteMap.put(oppSite.Opportunity__c, New List<Opportunity_Site__c>());
                }
                oppSiteMap.get(oppSite.Opportunity__c).add(oppSite);
                siteOppMap.Put(oppSite.Site__c,oppSite.Opportunity__c);
                if(oppSite.Flag__c == true){
                    checkFlag = true;
                }
            }
        }
        // If no further process and bypass the trigger
        if(checkFlag == true){
            return;
        }
        
        for( Site__c mSite : [ 	Select Id,Market__c,type__c,Volume__c, Market__r.Gas_Threshold__c,Market__r.Electricity_Threshold__c 
                              From Site__c
                              Where Id IN:siteOppMap.KeySet()]){
                                  siteMap.put(mSite.Id, mSite);
                                  if(siteOppMap.containsKey(mSite.Id)){
                                      oppId = siteOppMap.get(mSite.Id);
                                      if(mSite.Volume__c != null){
                                          if(!oppVolume.ContainsKey(oppId) ){
                                              oppVolume.put(oppId,mSite.Volume__c);
                                          }else{
                                              vol = oppVolume.get(oppId) + mSite.Volume__c;
                                              oppVolume.put(oppId,vol);
                                          }
                                      }
                                  }						
                              }// End OF Site Loop
        
        for( Site__c mSite : siteMap.Values()){
            oppId = siteOppMap.get(mSite.Id);
            //For Gas Commodity
            if(mSite.type__c == ConstantString.PRODUCT_GAS){
                if(oppVolume.get(oppId) > mSite.Market__r.Gas_Threshold__c){
                    opportunityVolSizeMap.put(oppId,ConstantString.SIZE_LARGE);
                }else {
                    opportunityVolSizeMap.put(oppId,ConstantString.SMALL_TYPE);
                }
            }
            //For Electricity Commodity
            if(mSite.type__c == ConstantString.PRODUCT_ELECTRICITY){
                if(oppVolume.get(oppId) >  mSite.Market__r.Electricity_Threshold__c){
                    opportunityVolSizeMap.put(oppId,ConstantString.SIZE_LARGE);
                }
                else {
                    opportunityVolSizeMap.put(oppId,ConstantString.SMALL_TYPE);
                }
            }
        }
        
        oppQuoteMap = CreateQuoteLineUtility.fetchQuoteId(oppSiteMap.KeySet());
        Set<String> productFamily = new Set<String>();
        Set<String> productPriceType = new Set<String>();
        Set<String> productSize = new Set<String>();
        List<Opportunity> opportunityList = [Select id,CloseDate,Electricity_Product_of_Choice__c,Gas_Volume__c,
                                             Gas_Product_of_Choice__c,Total_Volume__c,Supplier__c ,Margin__c,
                                             Commodity_Type__c,DNE_Admin_Fee__c, AccountId,Market__c,Market__r.Gas_Threshold__c,
                                             recordtype.Name,Market__r.Electricity_Threshold__c,Month_Year__c ,
                                             Subscription_Term__c,Supplier_Price__c,Admin_Fee__c,Monthly_Site_Admin_Fee__c,
                                             Daily_Site_Admin_Fee__c,pricebook2id
                                             From Opportunity 
                                             Where Id IN:oppSiteMap.KeySet()];
        for(Opportunity currentOpp : opportunityList)
        {
            productFamily.add(currentOpp.Commodity_Type__c);
            productPriceType.add(currentOpp.recordtype.Name);            
            if(currentOpp.recordtype.Name =='Fixed' || currentOpp.recordtype.Name == 'Variable'){
                productSize.add(opportunityVolSizeMap.get(currentOpp.Id));                
            }     
            else{
                productSize.add(null);
            }            
        }
        System.debug('productFamily ::: ' + productFamily);
        System.debug('productPriceType ::: ' + productPriceType);
        System.debug('productSize ::: ' + productSize);
        Map<String, Product2> allProducts = CreateQuoteLineUtility.getAllProducts(productFamily,productPriceType,productSize);
        System.debug('##### oppQuoteMap.size() ::: ' + oppQuoteMap.size());
        System.debug('##### oppQuoteMap ::: ' + oppQuoteMap);
        System.debug('##### allProducts.size() ::: ' + allProducts.size());
        System.debug('##### allProducts ::: ' + allProducts);
        decimal monthlyFee = 0;
        decimal dailyFee = 0;
        decimal subscriptionTerm;
        for(Opportunity currentOpp :opportunityList)
        {           	
            if( currentOpp.Monthly_Site_Admin_Fee__c != null){
                monthlyFee = currentOpp.Monthly_Site_Admin_Fee__c;
            }
            if( currentOpp.Daily_Site_Admin_Fee__c != null){
            	dailyFee = currentOpp.Daily_Site_Admin_Fee__c;
            }
            
            if(currentOpp.Subscription_Term__c != null){
                subscriptionTerm = currentOpp.Subscription_Term__c;
                subTerm = currentOpp.Subscription_Term__c/12;
            }
            else{
                subscriptionTerm = 1;
                subTerm = 1;
            }
            if(currentOpp.recordtype.Name =='Fixed' || currentOpp.recordtype.Name == 'Variable'){
                productKey = currentOpp.Commodity_Type__c + currentOpp.recordtype.Name	+ opportunityVolSizeMap.get(currentOpp.Id);	
            }     
            else{
                productKey = currentOpp.Commodity_Type__c + currentOpp.recordtype.Name + 'null';   
            }               
            
            if(allProducts.containsKey(productKey)){
                productId = allProducts.get(productKey).Id;	
            }		
            for(Opportunity_Site__c oppSite :oppSiteMap.get(currentOpp.Id)){
                if(siteMap.get(oppSite.Site__c).volume__c == null){
                    continue;
                }
                SBQQ__QuoteLine__c   quoteLine = new SBQQ__QuoteLine__c();
                quoteLine.Supplier__c = currentOpp.Supplier__c;
                quoteLine.Market__c = currentOpp.Market__c;
                quoteLine.Type__c = currentOpp.recordtype.Name;
                quoteLine.Size__c = opportunityVolSizeMap.get(currentOpp.Id);
                quoteLine.SBQQ__Quote__c = oppQuoteMap.get(currentOpp.Id).Id;
                quoteLine.Site__c = oppSite.site__c;
                quoteLine.SBQQ__Product__c = productId;
                if(oppSite.Contract__c != null && oppSite.Adder__c != null){                        
                    quoteLine.SBQQ__ListPrice__c = oppSite.Adder__c;
                }else if(currentOpp.Margin__c > 0){
                    quoteLine.SBQQ__ListPrice__c = currentOpp.Margin__c;
                }
                else if(currentOpp.DNE_Admin_Fee__c > 0){
                    quoteLine.SBQQ__ListPrice__c = currentOpp.DNE_Admin_Fee__c;
                }
                else{
                    quoteLine.SBQQ__ListPrice__c = 1; 
                }
                if(currentOpp.Margin__c > 0 && currentOpp.DNE_Admin_Fee__c > 0){
                    quoteLine.SBQQ__ListPrice__c = currentOpp.Margin__c + currentOpp.DNE_Admin_Fee__c;
                }
                system.debug('quoteLine.SBQQ__ListPrice__c  ::'+quoteLine.SBQQ__ListPrice__c );
                if(oppSite.Contract__c != null && oppSite.Quantity__c > 0){                        
                    quoteLine.SBQQ__Quantity__c = oppSite.Quantity__c;
                    system.debug('quoteLine.SBQQ__Quantity__c in if:::::'+quoteLine.SBQQ__Quantity__c);                       
                }else{
                    quoteLine.SBQQ__Quantity__c = (siteMap.get(oppSite.Site__c).volume__c * subTerm);
                    system.debug('quoteLine.SBQQ__Quantity__c in else:::::'+quoteLine.SBQQ__Quantity__c);
                }
                quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                quoteLine.SBQQ__DefaultSubscriptionTerm__c = currentOpp.Subscription_Term__c;
                quoteLine.Supplier_Price__c = currentOpp.Supplier_Price__c;
                if(currentOpp.Supplier_Price__c !=null && currentOpp.Margin__c != null  ){
                    quoteLine.Selling_Price__c = (((currentOpp.Supplier_Price__c + currentOpp.Margin__c) *quoteLine.SBQQ__Quantity__c )) ;
                }
                quoteLineList.add(quoteLine); 
            }                    	
        }
        System.debug('##### quoteLineList.size() ::: ' + quoteLineList.size());
        System.debug('##### quoteLineList ::: ' + quoteLineList);
        system.debug('subTerm ::'+subTerm); 
        system.debug('subscriptionTerm ::'+subscriptionTerm);
        Monthly_Site_Admin_Fee = monthlyFee  * subscriptionTerm;
        Daily_Site_Admin_Fee =   dailyFee  * (subscriptionTerm/12) * 365;
        
        system.debug('Monthly_Site_Admin_Fee ::'+Monthly_Site_Admin_Fee);
        system.debug('Daily_Site_Admin_Fee ::'+Daily_Site_Admin_Fee);
        
        decimal FinalValue = Monthly_Site_Admin_Fee + Daily_Site_Admin_Fee.setScale(2, RoundingMode.HALF_UP);
        system.debug('FinalValue ::'+FinalValue);
        
        for(SBQQ__QuoteLine__c qli: quoteLineList){
            
            qli.Add_On_Fee__c = FinalValue;
            system.debug('Add_On_Fee__c-afterAddition^^'+qli.Add_On_Fee__c);
        }
        system.debug('quoteLineList ::'+quoteLineList);
        try{
            if(quoteLineList.size()>0){
                insert quoteLineList;
                System.debug('##### QLI insert successfully.');
            }
        }Catch(Exception ex){
            System.debug('Exception throws : '+ ex.getMessage());
            for(Opportunity_Site__c oppSite :oppSiteList){
                oppSite.addError(ex.getMessage());
            }
        }
    }
    
    
}