/**************************************************
* Class: OpportunityTriggerHandler
* Author: Soljit VW
* Date: 2019-05-07
* Description: Update Opportunity Line item when Opportunity Type Custom 
****************************************************/

public class OpportunityTriggerHandler {
    /*********************************************************
@Name 			: updateQuoteLineIteam
@Parameters 	: List<Opportunity>:oppList
@Reutrn type 	: void
@Description 	: Update Quote line item on Primary Quote on Opportunity
********************************************************/
    public static void updateQuoteLineIteam(Map<Id,Opportunity> oppNewMap,Map<Id,Opportunity> oppOldMap){
        System.debug('In OpportunityTriggerHandler.updateQuoteLineIteam() method.');
        Id RecordTypeIdAmendmentOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        Map<String,String> oppIdQuoteIdMap = new Map<String,String>();
        Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>();
        Map<String, List<SBQQ__QuoteLine__c>> quoteQLIMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        String quoteId;
        
        //fetch primay quoteID on opportunity
        For(SBQQ__Quote__c quoteObj : [Select id,Supplier_Price__c,Selling_Price__c,SBQQ__StartDate__c,SBQQ__Opportunity2__c,
                                       Administration_Fee__c,SBQQ__SubscriptionTerm__c,Supplier__c,margin__c,
                                       SBQQ__Opportunity2__r.Main_Opportunity__r.Flow_Date__c,SBQQ__Opportunity2__r.Main_Opportunity__r.Subscription_Term__c
                                       From SBQQ__Quote__c 
                                       Where SBQQ__Opportunity2__c IN: oppNewMap.keySet() AND SBQQ__Primary__c = True])
        {
            System.debug('quoteObj ::: ' + quoteObj);
            quoteMap.put(quoteObj.Id,quoteObj);
            if(quoteObj.SBQQ__Opportunity2__c != null){
                oppIdQuoteIdMap.put(quoteObj.SBQQ__Opportunity2__c,quoteObj.Id);
            }
        }
        System.debug('quoteMap.size() ::: ' + quoteMap.size());
        System.debug('quoteMap ::: ' + quoteMap);
        System.debug('oppIdQuoteIdMap.size() ::: ' + oppIdQuoteIdMap.size());
        System.debug('oppIdQuoteIdMap ::: ' + oppIdQuoteIdMap);
        
        // fetch All QLIs 
        For(SBQQ__QuoteLine__c qli :[Select Supplier__c,Add_On_Fee__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.Name, id,Site__r.volume__c,Selling_Price__c,SBQQ__Quote__c,SBQQ__DefaultSubscriptionTerm__c,
                                     SBQQ__SubscriptionTerm__c,SBQQ__ListPrice__c,Supplier_Price__c,SBQQ__Quantity__c 
                                     From SBQQ__QuoteLine__c where SBQQ__Quote__c IN : quoteMap.keySet()])
        {
            System.debug('qli ::: ' + qli);
            if(qli.SBQQ__Quote__c != null ){
                if( !quoteQLIMap.containsKey(qli.SBQQ__Quote__c)){
                    quoteQLIMap.put(qli.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>());
                }   
                quoteQLIMap.get(qli.SBQQ__Quote__c).add(qli);
            }
        }
        System.debug('quoteQLIMap.size() ::: ' + quoteQLIMap.size());
        System.debug('quoteQLIMap ::: ' + quoteQLIMap);
        
        // Get OppSites 
        List<Opportunity_Site__c> siteList = new List<Opportunity_Site__c>();
        Map<String, Map<String, Opportunity_Site__c>> OppSiteMap = new  Map<String, Map<String, Opportunity_Site__c>> ();
        Map<String, Opportunity_Site__c> siteOppSiteMap = new  Map<String, Opportunity_Site__c> ();
        for(Opportunity_Site__c opsite : [Select Id,Quantity__c,Opportunity__c, Contract__c,
                                          Site__c, Market__c  
                                          From Opportunity_Site__c 
                                          Where Opportunity__c IN: oppNewMap.keyset()])
        {
            if(!OppSiteMap.containsKey(opsite.Opportunity__c)){
                siteOppSiteMap = new  Map<String, Opportunity_Site__c>();
                OppSiteMap.put(opsite.Opportunity__c, siteOppSiteMap);
            }
            siteList.add(opsite);
            siteOppSiteMap = OppSiteMap.get(opsite.Opportunity__c); 
            siteOppSiteMap.put(opsite.Site__c,opsite);
        }
        decimal Monthly_Site_Admin_Fee;
        decimal Daily_Site_Admin_Fee;
        decimal OldMonthly_Site_Admin_Fee;
        decimal OldDaily_Site_Admin_Fee;
        decimal OldFinalValue;
        decimal subsTerm;
        //OldOppValueMap
        for(Opportunity oppObj : oppOldMap.values()){
            if(oppObj.Subscription_Term__c == null){
                subsTerm = 1;
            }else{
                subsTerm = oppObj.Subscription_Term__c;
            }
            OldMonthly_Site_Admin_Fee = oppObj.Monthly_Site_Admin_Fee__c * subsTerm;
            OldDaily_Site_Admin_Fee =   oppObj.Daily_Site_Admin_Fee__c  * (subsTerm/12) * 365;
            
            system.debug('Old-Monthly_Site_Admin_Fee ::'+OldMonthly_Site_Admin_Fee);
            system.debug('Old-Daily_Site_Admin_Fee ::'+OldDaily_Site_Admin_Fee);
            
            OldFinalValue = OldMonthly_Site_Admin_Fee + OldDaily_Site_Admin_Fee.setScale(2, RoundingMode.HALF_UP);
            if(quoteQLIMap.values().size() == 0){
              OldFinalValue = OldFinalValue;  
            }else{
                OldFinalValue = OldFinalValue / quoteQLIMap.values().size();
            }
            
            system.debug('Old-FinalValue ::'+OldFinalValue);
        }
        //Fetch existing quote line item on quote and update field 
        for(Opportunity oppObj : oppNewMap.values()){
            if(oppObj.Margin__c == null){
                oppObj.Margin__c = 0;
            }
            if(oppObj.DNE_Admin_Fee__c != oppOldMap.get(oppObj.Id).DNE_Admin_Fee__c && oppOldMap.get(oppObj.Id).Supplier_Price__c != NULL){
                system.debug('DNE_Admin_Fee__c :'+oppObj.DNE_Admin_Fee__c);
                system.debug('Supplier_Price__c :'+oppObj.Supplier_Price__c);
                
                oppObj.Supplier_Price__c += ( ( oppObj.DNE_Admin_Fee__c != NUll ? oppObj.DNE_Admin_Fee__c : 0 ) - ( oppOldMap.get(oppObj.Id).DNE_Admin_Fee__c != NULL ? oppOldMap.get(oppObj.Id).DNE_Admin_Fee__c : 0 ) );
                system.debug('AfterCalculation-Supplier_Price__c :'+oppObj.Supplier_Price__c);
                oppObj.Selling_Price__c = oppObj.Supplier_Price__c + oppObj.Margin__c;
                system.debug('Margin__c :'+oppObj.Margin__c);
                system.debug('Selling_Price__c :'+oppObj.Selling_Price__c);
            }
            quoteId = oppIdQuoteIdMap.get(oppObj.Id);
            if(quoteId == null || quoteMap.get(quoteId) == null){
                continue;
            }
            SBQQ__Quote__c quoteObj = quoteMap.get(quoteId);
            
            if(oppObj.Flow_Date__c != NULL && oppObj.Flow_Date__c != oppOldMap.get(oppObj.Id).Flow_Date__c && oppObj.RecordTypeId == RecordTypeIdAmendmentOpp && quoteObj.SBQQ__Opportunity2__r.Main_Opportunity__c != null){
                oppObj.Subscription_Term__c = calculateRemainingTerm(quoteObj.SBQQ__Opportunity2__r.Main_Opportunity__r.Flow_Date__c, oppObj.Flow_Date__c, quoteObj.SBQQ__Opportunity2__r.Main_Opportunity__r.Subscription_Term__c);
            } 
            system.debug('term:'+oppObj.Subscription_Term__c);
            
            if(oppObj.Subscription_Term__c != oppOldMap.get(oppObj.Id).Subscription_Term__c){
                quoteObj.SBQQ__SubscriptionTerm__c = oppObj.Subscription_Term__c;
            }
            system.debug('quoteObj.SBQQ__SubscriptionTerm__c :'+quoteObj.SBQQ__SubscriptionTerm__c);
            decimal subscriptionTerm;
            if(oppObj.Subscription_Term__c == null){
                subscriptionTerm = 1;
            }else{
                subscriptionTerm = oppObj.Subscription_Term__c;
            }
            if(oppObj.Monthly_Site_Admin_Fee__c == null){
                oppObj.Monthly_Site_Admin_Fee__c = 0; 
            }
            if(oppObj.Daily_Site_Admin_Fee__c == null){
                oppObj.Daily_Site_Admin_Fee__c = 0;
            }
            
            Monthly_Site_Admin_Fee = oppObj.Monthly_Site_Admin_Fee__c  * subscriptionTerm;
            Daily_Site_Admin_Fee =   oppObj.Daily_Site_Admin_Fee__c  * (subscriptionTerm/12) * 365;
            
            system.debug('Monthly_Site_Admin_Fee ::'+Monthly_Site_Admin_Fee);
            system.debug('Daily_Site_Admin_Fee ::'+Daily_Site_Admin_Fee);
            
            decimal FinalValue = Monthly_Site_Admin_Fee + Daily_Site_Admin_Fee.setScale(2, RoundingMode.HALF_UP);
            if(quoteQLIMap.values().size() == 0){
                 FinalValue = FinalValue;
            }else{
                FinalValue = FinalValue / quoteQLIMap.values().size();
            }
            system.debug('FinalValue ::'+FinalValue);
            if(oppObj.Supplier__c != oppOldMap.get(oppObj.Id).Supplier__c){
                quoteObj.Supplier__c = oppObj.Supplier__c;
            }
            if(oppObj.Admin_Fee__c != oppOldMap.get(oppObj.Id).Admin_Fee__c){
                quoteObj.Administration_Fee__c = oppObj.Admin_Fee__c;
            }
            if(oppObj.Flow_Date__c != oppOldMap.get(oppObj.Id).Flow_Date__c){
                quoteObj.SBQQ__StartDate__c = oppObj.Flow_Date__c;  
            }
            if(oppObj.Margin__c != oppOldMap.get(oppObj.Id).Margin__c){
                quoteObj.margin__c = oppObj.Margin__c;
            }
            if(oppObj.Supplier_Price__c != oppOldMap.get(oppObj.Id).Supplier_Price__c){
                quoteObj.Supplier_Price__c = oppObj.Supplier_Price__c;
            }
            quoteObj.Selling_Price__c = (quoteObj.Supplier_Price__c != null ? quoteObj.Supplier_Price__c : 0) + (quoteObj.margin__c != null ? quoteObj.margin__c : 0);			
            //quoteObj.SBQQ__EndDate__c = null;
            
            quoteList.add(quoteObj);
            
            If(quoteQLIMap.get(quoteId) == NULL){
                continue;
            }
            siteOppSiteMap = OppSiteMap.get(oppObj.Id);
            
            for(SBQQ__QuoteLine__c qli : quoteQLIMap.get(quoteId)){
                Opportunity_Site__c opsite;
                if(qli.Site__c != null && siteOppSiteMap != null && siteOppSiteMap.containsKey(qli.Site__c)){
                    opsite = siteOppSiteMap.get(qli.Site__c);
                }
                if(oppObj.Subscription_Term__c != oppOldMap.get(oppObj.Id).Subscription_Term__c){
                    qli.SBQQ__DefaultSubscriptionTerm__c = oppObj.Subscription_Term__c;
                }
                if(oppObj.Supplier__c != oppOldMap.get(oppObj.Id).Supplier__c){
                    qli.Supplier__c = oppObj.Supplier__c;
                }
                decimal listPrice = 0;
                system.debug('NewMargin__c::'+oppObj.Margin__c);
                system.debug('NewAdminFee::'+oppObj.DNE_Admin_Fee__c);
                listPrice +=( oppObj.Margin__c != NUll ? oppObj.Margin__c : 0 ) + ( oppObj.DNE_Admin_Fee__c != NUll ? oppObj.DNE_Admin_Fee__c : 0 ); 
                
                if(listPrice == null || listPrice == 0){
                        listPrice = 1;
                    }
                system.debug('listPrice ::'+listPrice);
                qli.SBQQ__ListPrice__c = listPrice;
                system.debug('SBQQ__ListPrice__c ::'+qli.SBQQ__ListPrice__c);
                system.debug('Add_On_Fee__c-BeforeAddition^^'+qli.Add_On_Fee__c);
                if(qli.Add_On_Fee__c == null){
                    qli.Add_On_Fee__c = 0;
                }
                qli.Add_On_Fee__c = (qli.Add_On_Fee__c - OldFinalValue) + FinalValue;
                system.debug('Add_On_Fee__c-afterAddition^^'+qli.Add_On_Fee__c);
                
                if(oppObj.Supplier_Price__c != oppOldMap.get(oppObj.Id).Supplier_Price__c){
                    qli.Supplier_Price__c = oppObj.Supplier_Price__c ;
                }
                if(oppObj.Subscription_Term__c != NULL && oppOldMap.get(oppObj.Id).Subscription_Term__c != NULL && qli.SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.Name == 'Amendment'){                    
                    qli.SBQQ__Quantity__c = ( ( qli.SBQQ__Quantity__c ) * ( oppObj.Subscription_Term__c ) ) / oppOldMap.get(oppObj.Id).Subscription_Term__c;
                } 
                else if(oppObj.Subscription_Term__c != NULL && qli.SBQQ__Quote__r.SBQQ__Opportunity2__r.RecordType.Name != 'Amendment'){
                    qli.SBQQ__Quantity__c = ( ( qli.Site__r.volume__c != null ? qli.Site__r.volume__c :0) * ( oppObj.Subscription_Term__c ) ) / 12;   
                    system.debug('Quant2^^'+qli.SBQQ__Quantity__c);
                }
                if(opsite != null && opsite.contract__c != null && opsite.Quantity__c > 0){
                    qli.SBQQ__Quantity__c = ( ( opsite.Quantity__c ) * ( oppObj.Subscription_Term__c ) ) / oppOldMap.get(oppObj.Id).Subscription_Term__c;
                    system.debug('Quant^^'+qli.SBQQ__Quantity__c);
                }
                qli.Selling_Price__c = ( ( ( qli.Supplier_Price__c != NULL ? qli.Supplier_Price__c : 0 ) + ( qli.SBQQ__ListPrice__c != NULL ? qli.SBQQ__ListPrice__c : 0 ) ) * (qli.SBQQ__Quantity__c != NULL ? qli.SBQQ__Quantity__c : 0 ) );                    
                system.debug('Selling_Price__c^^'+qli.Selling_Price__c);
                
                quoteLineList.add(qli);                    
            }            
        }  
        if(quoteList.size()>0){
            System.debug('quoteList.size() ::: ' + quoteList.size());
            System.debug('quoteList ::: ' + quoteList);
            UPDATE quoteList;
            System.debug('Quotes updated successfully.');
        }
        if(quoteLineList.size()>0){
            System.debug('quoteLineList.size() ::: ' + quoteLineList.size());
            System.debug('quoteLineList ::: ' + quoteLineList);
            UPDATE quoteLineList;
            System.debug('QuoteLines updated successfully.');
        }        
    }
    public static void updateContractAndSubscription(Map<Id,Opportunity> oppNewMap,Map<Id,Opportunity> oppOldMap){
        Map<Id,Contract> contractWithOppMap = new Map<Id,Contract>();
        Map<Id,List<SBQQ__Subscription__c>> subscriptionMap = new Map<Id,List<SBQQ__Subscription__c>>();
        Map<id,Contract> contractsToBeUpdate = new Map<id,Contract>();
        Map<id,SBQQ__Subscription__c> subscriptionUpdateMap = new Map<id,SBQQ__Subscription__c>();
        Set<Id> contractIds = new Set<Id>();
        Set<Id> QuoteIds = new Set<Id>();
        for(Contract cont : [SELECT Id,ContractTerm,DNE_Admin_Fee__c,StartDate,Adder_Margin__c,SBQQ__Quote__c,CurrentVolume__c,SBQQ__Opportunity__c FROM 
                             Contract WHERE SBQQ__Opportunity__c IN: oppNewMap.keySet()]){
                                 contractWithOppMap.put(cont.SBQQ__Opportunity__c,cont); 
                                 contractIds.add(cont.Id);
                                 QuoteIds.add(cont.SBQQ__Quote__c);
                             }
        if(contractIds.size() > 0){
            for(SBQQ__Subscription__c subs : [SELECT Id,Original_Annual_Quanity__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.Supplier_Price__c,OriginalQuantity__c,Site__c,SBQQ__Quantity__c,Term_in_month__c,SBQQ__SubscriptionStartDate__c,Annual_Volume__c,SBQQ__Contract__c,Supplier__c,Adder_Margin__c,DNE_Admin_Fee__c FROM 
                                              SBQQ__Subscription__c WHERE SBQQ__Contract__c 
                                              IN: contractIds]){
                                                  if(!subscriptionMap.containsKey(subs.SBQQ__Contract__c)){
                                                      subscriptionMap.put(subs.SBQQ__Contract__c, new List<SBQQ__Subscription__c>());
                                                  }
                                                  subscriptionMap.get(subs.SBQQ__Contract__c).add(subs);
                                              }
        }
        Map<Id, List<SBQQ__QuoteLine__c>> oppQuoteQLIMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        if(QuoteIds.size() > 0){
            For(SBQQ__QuoteLine__c qli : [Select Id,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__MasterContract__c,
                                          AnnualVolumeForSite__c, SBQQ__DefaultSubscriptionTerm__c,
                                          SBQQ__Quote__r.SBQQ__MasterContract__r.CurrentVolume__c, 
                                          SBQQ__Quote__r.SBQQ__MasterContract__r.CurrentAmount__c, Supplier_Price__c,
                                          SBQQ__ListPrice__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__ListTotal__c,SBQQ__Quote__r.SBQQ__StartDate__c,
                                          Site__c,SBQQ__Quote__c,SBQQ__Quantity__c,SBQQ__EffectiveQuantity__c, SBQQ__Product__c, 
                                          SBQQ__Quote__r.SBQQ__Opportunity2__r.DNE_Admin_Fee__c, Supplier__c 
                                          From SBQQ__QuoteLine__c 
                                          where SBQQ__Quote__c IN : QuoteIds])
            {
                System.debug('qli ::: ' + qli);
                if(!oppQuoteQLIMap.containsKey(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                    oppQuoteQLIMap.put(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c, new List<SBQQ__QuoteLine__c>());
                }   
                oppQuoteQLIMap.get(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(qli); 
                
            }
        }
        decimal CurrentVol = 0;
        for(Opportunity oppObj : oppNewMap.values()){
            
            if(contractWithOppMap.containsKey(oppObj.Id)){
                Contract contRec = contractWithOppMap.get(oppObj.Id);
                if(oppObj.Subscription_Term__c != oppOldMap.get(oppObj.Id).Subscription_Term__c){
                    contRec.ContractTerm = Integer.valueOf(oppObj.Subscription_Term__c);
                }
                if(oppObj.Admin_Fee__c != oppOldMap.get(oppObj.Id).Admin_Fee__c){
                    contRec.DNE_Admin_Fee__c = oppObj.Admin_Fee__c;
                }
                if(oppObj.Flow_Date__c != oppOldMap.get(oppObj.Id).Flow_Date__c){
                    contRec.StartDate = oppObj.Flow_Date__c;  
                }
                if(oppObj.Margin__c != oppOldMap.get(oppObj.Id).Margin__c){
                    contRec.Adder_Margin__c = oppObj.Margin__c;
                }
                contractsToBeUpdate.put(contRec.id,contRec);
                if(subscriptionMap.containsKey(contRec.Id)){
                    if(contractWithOppMap.containsKey(contRec.SBQQ__Opportunity__c)){
                        for(SBQQ__QuoteLine__c qli : oppQuoteQLIMap.get(oppObj.id)){
                            for(SBQQ__Subscription__c subs : subscriptionMap.get(contRec.Id)){
                                if(qli.Site__c == subs.Site__c){
                                    subs.SBQQ__Quantity__c = qli.SBQQ__Quantity__c;
                                    system.debug('subsQuantity'+subs.SBQQ__Quantity__c);
                                }
                                subs.OriginalQuantity__c = subs.SBQQ__Quantity__c;
                                subs.Annual_Volume__c = (subs.OriginalQuantity__c/(subs.Term_in_month__c/12.0));
                                subs.OriginalAmount__c = (subs.SBQQ__Quantity__c * ( ( subs.Adder_Margin__c != null ? subs.Adder_Margin__c : 0 ) + ( subs.DNE_Admin_Fee__c != null ? subs.DNE_Admin_Fee__c : 0 ) ) ).setScale(2, RoundingMode.HALF_UP);
                                
                                if(oppObj.Supplier__c != oppOldMap.get(oppObj.Id).Supplier__c){
                                    subs.Supplier__c = oppObj.Supplier__c;
                                }
                                if(oppObj.Margin__c != oppOldMap.get(oppObj.Id).Margin__c){
                                    subs.Adder_Margin__c = oppObj.Margin__c;
                                }
                                if(oppObj.Admin_Fee__c != oppOldMap.get(oppObj.Id).Admin_Fee__c){
                                    subs.DNE_Admin_Fee__c = oppObj.Admin_Fee__c;
                                }
                                if(oppObj.Flow_Date__c != oppOldMap.get(oppObj.Id).Flow_Date__c){
                                    subs.SBQQ__SubscriptionStartDate__c  = oppObj.Flow_Date__c;
                                    system.debug('Date'+subs.SBQQ__SubscriptionStartDate__c);
                                } 
                                if(subs.SBQQ__QuoteLine__r.Supplier_Price__c == null){
                                subs.SBQQ__QuoteLine__r.Supplier_Price__c = 0;
                            }
                                subs.Selling_Price__c = subs.SBQQ__Quantity__c*(subs.Adder_Margin__c + subs.SBQQ__QuoteLine__r.Supplier_Price__c);
                                subscriptionUpdateMap.put(subs.Id,subs);
                                //CurrentVol = subscriptionUpdateMap.get(subs.id).OriginalQuantity__c/(subscriptionUpdateMap.get(subs.id).Term_in_month__c/12);
                                //system.debug('CurrentVol'+CurrentVol);
                            }
                        }
                    }
                }
                //contractsToBeUpdate.get(contRec.id).CurrentVolume__c  = CurrentVol;
                //system.debug('CurrentVolume'+contractsToBeUpdate.get(contRec.id).CurrentVolume__c);
                //contractsToBeUpdate.put(contRec.id,contRec);       
            }
        }
        System.debug('contractsToBeUpdate^^' + contractsToBeUpdate);
        System.debug('subscriptionUpdateMap^^' + subscriptionUpdateMap);
        System.debug('contractsToBeUpdate^^' + contractsToBeUpdate.size());
        System.debug('subscriptionUpdateMapSize^^' + subscriptionUpdateMap.size()); 
        try{
            if(contractsToBeUpdate.size() > 0){
                UPDATE contractsToBeUpdate.values();
            }
            if(subscriptionUpdateMap.size() > 0){
                UPDATE subscriptionUpdateMap.values();
                system.debug('subscriptionUpdateMap'+subscriptionUpdateMap.size());
            }
            
            Contract con; 
            Map<Id, Contract> contractMap = new  Map<Id, Contract>();
            
                    for(SBQQ__Subscription__c sub: [SELECT Id,Original_Annual_Quanity__c,OriginalQuantity__c,Site__c,SBQQ__Quantity__c,Term_in_month__c,SBQQ__SubscriptionStartDate__c,Annual_Volume__c,SBQQ__Contract__c,Supplier__c,Adder_Margin__c,DNE_Admin_Fee__c FROM 
                                              SBQQ__Subscription__c WHERE SBQQ__Contract__c 
                                              IN: contractIds]){
                        if(!contractMap.containskey(sub.SBQQ__Contract__c)){
                            con = new Contract();        
                            con.Id = sub.SBQQ__Contract__c;
                            con.CurrentVolume__c = 0;
                            contractMap.put(con.Id, con);
                        }
                        system.debug('Original_Annual_Quanity__c'+sub.Original_Annual_Quanity__c);
                        contractMap.get(con.Id).CurrentVolume__c += sub.Original_Annual_Quanity__c; 
                        system.debug('CurrentVolume__c'+contractMap.get(con.Id).CurrentVolume__c);
                    }
               
            try{
                if(contractMap.size()>0){
                    system.debug('contractMap'+contractMap.values());
                    Update contractMap.values();
                }
            }catch(Exception ex){
                System.debug('exception^^' + ex.getMessage());
            }
            
        }catch(Exception ex){
            System.debug('exception^^' + ex.getMessage());
        }
    }
    public static Decimal calculateRemainingTerm(Date mainOppFlowDate, Date amendOppFlowDate, Decimal subscriptionTerm){
        Decimal termRemaining = 0;
        if(mainOppFlowDate < amendOppFlowDate){
            system.debug('opp Flow Date :::'+mainOppFlowDate);
            decimal monthDiff = mainOppFlowDate.monthsBetween(amendOppFlowDate);
            Integer daysEnd = Date.daysInMonth(amendOppFlowDate.year(), amendOppFlowDate.month());
            Decimal day_s = mainOppFlowDate.day();
            Decimal day_e = amendOppFlowDate.day();
            Decimal factor = 0;
            if(day_s != day_e){
                factor = (day_e - day_s)/daysEnd;
            }       
            termRemaining = subscriptionTerm - ( monthDiff + factor ).setScale(2, RoundingMode.HALF_UP);
        }
        else{
            termRemaining = subscriptionTerm;
        }
        System.debug('termRemaining :: ' + termRemaining);
        return termRemaining;
    }    
    
    public static void updateExistingSubscription(List<Opportunity> oppList){
        system.debug('oppList :::'+oppList);
        Set<Id> contractSet = new Set<Id>();
        List<SBQQ__Subscription__c> subsListToInsert = new List<SBQQ__Subscription__c>();
        Map<Id, Contract> contractMap = new  Map<Id, Contract>();
        List<Contract> contractList = new List<Contract>();
        
        Set<Id> quoteIdSet = new Set<Id>();
        set<id> mainOppIdSet = new set<id>();
        for(Opportunity opp : oppList){
            if(opp.Main_Opportunity__c != null){
            mainOppIdSet.add(opp.Main_Opportunity__c);
            }
            if(opp.SBQQ__PrimaryQuote__c != null){
                quoteIdSet.add(opp.SBQQ__PrimaryQuote__c);                
            }
        }            
        string contractIdSet;
        for(Contract contr: [select id,SBQQ__Opportunity__c from Contract where SBQQ__Opportunity__c IN: mainOppIdSet]){
            contractIdSet = contr.Id;
        }
        List<SBQQ__Quote__c> QuoteList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote: [select id,SBQQ__MasterContract__c from SBQQ__Quote__c where id IN: quoteIdSet]){
            quote.SBQQ__MasterContract__c = contractIdSet;
            QuoteList.add(quote);
        }
        if(QuoteList.size()>0){
            update QuoteList;
        }
        Map<Id, List<SBQQ__QuoteLine__c>> oppQuoteQLIMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        Map<Id, Id> oppIdContractIdMap = new Map<Id, Id>();
        For(SBQQ__QuoteLine__c qli : [Select Id,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__MasterContract__c,
                                      AnnualVolumeForSite__c, SBQQ__DefaultSubscriptionTerm__c,
                                      SBQQ__Quote__r.SBQQ__MasterContract__r.CurrentVolume__c, 
                                      SBQQ__Quote__r.SBQQ__MasterContract__r.CurrentAmount__c, Supplier_Price__c,
                                      SBQQ__ListPrice__c,SBQQ__Quote__r.SBQQ__Account__c,SBQQ__ListTotal__c,SBQQ__Quote__r.SBQQ__StartDate__c,
                                      Site__c,SBQQ__Quote__c,SBQQ__Quantity__c,SBQQ__EffectiveQuantity__c, SBQQ__Product__c, 
                                      SBQQ__Quote__r.SBQQ__Opportunity2__r.DNE_Admin_Fee__c, Supplier__c 
                                      From SBQQ__QuoteLine__c 
                                      where SBQQ__Quote__c IN : quoteIdSet])
        {
            System.debug('qli ::: ' + qli);
            if(!oppQuoteQLIMap.containsKey(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                oppQuoteQLIMap.put(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c, new List<SBQQ__QuoteLine__c>());
            }   
            oppQuoteQLIMap.get(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(qli); 
            system.debug('oppQuoteQLIMap :'+oppQuoteQLIMap);
            if(qli.SBQQ__Quote__r.SBQQ__MasterContract__c != null){
                oppIdContractIdMap.put(qli.SBQQ__Quote__r.SBQQ__Opportunity2__c, qli.SBQQ__Quote__r.SBQQ__MasterContract__c);            
            }
            
        }
        System.debug('oppIdContractIdMap ::: ' + oppIdContractIdMap);
        Map<Id, Map<Id,SBQQ__Subscription__c>> oppIdSubscriptionMap = new Map<Id, Map<Id,SBQQ__Subscription__c>>();
        Map<Id, List<SBQQ__Subscription__c>> conIdSubscriptionMap = new Map<Id, List<SBQQ__Subscription__c>>();        
        for(SBQQ__Subscription__c subs : [Select id,Site__c,SBQQ__Contract__c,SBQQ__Quantity__c,SBQQ__Contract__r.SBQQ__Opportunity__c,
                                          Adder_Margin__c,Selling_Price__c,SBQQ__QuoteLine__r.Supplier_Price__c,Term_in_month__c,
                                          SBQQ__StartDate__c,Dispute_Resolution_Date__c,DNE_Admin_Fee__c,SBQQ__Contract__r.SBQQ__RenewalOpportunity__c
                                          From SBQQ__Subscription__c 
                                          Where SBQQ__Contract__c IN : oppIdContractIdMap.values() AND Site__c != null])
        {
            if(subs.SBQQ__Contract__c != null){
                if(!oppIdSubscriptionMap.containsKey(subs.SBQQ__Contract__c)){
                    oppIdSubscriptionMap.put(subs.SBQQ__Contract__c, new Map<Id,SBQQ__Subscription__c>());
                    conIdSubscriptionMap.put(subs.SBQQ__Contract__c, new List<SBQQ__Subscription__c>());
                }   
                oppIdSubscriptionMap.get(subs.SBQQ__Contract__c).put(subs.Site__c,subs);
                conIdSubscriptionMap.get(subs.SBQQ__Contract__c).add(subs);
            }
        }   
        System.debug('oppIdSubscriptionMap ::: ' + oppIdSubscriptionMap);
        System.debug('conIdSubscriptionMap ::: ' + conIdSubscriptionMap);
        Map<Id,SBQQ__Subscription__c> subUpdateMap = new Map<Id,SBQQ__Subscription__c>();
        Map<Id,Opportunity> renewalOppUpdateMap = new Map<Id,Opportunity>();
        for(Opportunity opp :  oppList){
            if(oppQuoteQLIMap.containskey(opp.Id)){
                for(SBQQ__QuoteLine__c qli : oppQuoteQLIMap.get(opp.Id)){
                    if(oppIdSubscriptionMap.containsKey(qli.SBQQ__Quote__r.SBQQ__MasterContract__c) && oppIdSubscriptionMap.get(qli.SBQQ__Quote__r.SBQQ__MasterContract__c).containsKey(qli.Site__c))
                    {
                        SBQQ__Subscription__c sub = oppIdSubscriptionMap.get(qli.SBQQ__Quote__r.SBQQ__MasterContract__c).get(qli.Site__c);
                        
                        System.debug('Before sub ::: ' + sub);
                        if(subUpdateMap.containsKey(sub.Id)){
                            sub = subUpdateMap.get(sub.Id);
                        }
                        System.debug('After sub ::: ' + sub);
                        system.debug('qli.SBQQ__DefaultSubscriptionTerm__c:::'+qli.SBQQ__DefaultSubscriptionTerm__c);
                        if(qli.AnnualVolumeForSite__c != null){
                            sub.Annual_Volume__c =  qli.AnnualVolumeForSite__c;
                            if(opp.Flow_Date__c < sub.SBQQ__StartDate__c)
                            {
                                sub.SBQQ__Quantity__c = sub.Annual_Volume__c*(sub.Term_in_month__c/12); 
                                sub.Adder_Margin__c = opp.Margin__c;
                                system.debug('sub Term_in_month__c in if:::'+sub.Term_in_month__c);
                                system.debug('sub SBQQ__Quantity__c in if:::'+sub.SBQQ__Quantity__c);
                            }
                            else
                            {
                                sub.SBQQ__Quantity__c = sub.Annual_Volume__c*(qli.SBQQ__DefaultSubscriptionTerm__c/12);
                                sub.Adder_Margin__c = opp.Margin__c;
                                SYSTEM.debug('qUANTITY IN ELSE::'+sub.SBQQ__Quantity__c);
                            }
                            system.debug('sub.SBQQ__Quantity__c'+sub.SBQQ__Quantity__c);
                            system.debug('sub.Adder_Margin__c'+sub.Adder_Margin__c);
                            system.debug('sub.SBQQ__QuoteLine__r.Supplier_Price__c'+sub.SBQQ__QuoteLine__r.Supplier_Price__c);
                            if(sub.SBQQ__QuoteLine__r.Supplier_Price__c == null){
                                sub.SBQQ__QuoteLine__r.Supplier_Price__c = 0;
                            }
                            sub.Selling_Price__c = sub.SBQQ__Quantity__c*(sub.Adder_Margin__c + sub.SBQQ__QuoteLine__r.Supplier_Price__c);
                        }
                        else{
                            sub.Annual_Volume__c = 0;
                            sub.SBQQ__Quantity__c = 0;
                            sub.Selling_Price__c = 0;
                        }
                        if(sub.Annual_Volume__c == 0){
                            sub.Error_Message__c = 'CANCELLED' ;
                        }
                        else{
                            sub.Error_Message__c = '';
                        }
                        sub.Dispute_Resolution_Date__c = opp.Flow_Date__c;
                        sub.IsAmended__c = true;
                        /*if(Sub.SBQQ__Contract__r.Status == 'Cancelled'){
sub.Error_Message__c = 'CANCELLED' ;
}*/
                        subUpdateMap.put(sub.Id,sub);
                        contractSet.add(sub.SBQQ__Contract__c);
                        System.debug('sub ::: ' + sub);
                        if(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null && !renewalOppUpdateMap.containsKey(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c)){
                            renewalOppUpdateMap.put(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,new Opportunity(Id = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, Margin__c = opp.Margin__c));
                        }
                    }
                    else if(qli.SBQQ__Quote__r.SBQQ__MasterContract__c != null){
                        SBQQ__Subscription__c sub = new  SBQQ__Subscription__c();
                        //sub.Adder_Margin__c = qli.SBQQ__ListPrice__c;
                        sub.DNE_Admin_Fee__c = qli.SBQQ__Quote__r.SBQQ__Opportunity2__r.DNE_Admin_Fee__c;
                        sub.IsNew__c = true;
                        sub.SBQQ__Account__c = qli.SBQQ__Quote__r.SBQQ__Account__c;
                        sub.SBQQ__Contract__c = qli.SBQQ__Quote__r.SBQQ__MasterContract__c;
                        // sub.SBQQ__EndDate__c
                        sub.SBQQ__SubscriptionStartDate__c = qli.SBQQ__Quote__r.SBQQ__StartDate__c;
                        sub.SBQQ__Product__c = qli.SBQQ__Product__c;
                        sub.SBQQ__Quantity__c = qli.SBQQ__Quantity__c;
                        sub.Annual_Volume__c = qli.AnnualVolumeForSite__c;
                        sub.Adder_Margin__c = opp.Supplier_Price__c+opp.Margin__c;
                        sub.SBQQ__QuoteLine__c = qli.Id;
                        sub.Site__c = qli.Site__c;
                        sub.Supplier__c =qli.Supplier__c;
                        // sub.Term_in_month__c = qli.SBQQ__DefaultSubscriptionTerm__c;
                        subsListToInsert.add(sub);  
                        contractSet.add(sub.SBQQ__Contract__c);
                        if(conIdSubscriptionMap.containsKey(sub.SBQQ__Contract__c)){                            
                            conIdSubscriptionMap.get(sub.SBQQ__Contract__c).add(sub);
                        }
                        if(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c != null && !renewalOppUpdateMap.containsKey(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c)){
                            renewalOppUpdateMap.put(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,new Opportunity(Id = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, Margin__c = opp.Margin__c));
                        }                        
                        System.debug('sub ::: ' + sub);
                    }
                }
            }            
        }
        
        Contract con;        
        for(Id conId : conIdSubscriptionMap.keySet()){
            if(conIdSubscriptionMap.containsKey(conId)){
                for(SBQQ__Subscription__c sub : conIdSubscriptionMap.get(conId)){
                    if(!contractMap.containskey(sub.SBQQ__Contract__c)){
                        con = new Contract();        
                        con.Id = sub.SBQQ__Contract__c;
                        con.CurrentAmount__c = 0;
                        con.CurrentVolume__c = 0;
                        contractMap.put(con.Id, con);
                    }
                    contractMap.get(con.Id).CurrentVolume__c += sub.SBQQ__Quantity__c;
                    system.debug('CurrentVolume__c'+contractMap.get(con.Id).CurrentVolume__c);
                    contractMap.get(con.Id).CurrentAmount__c += (sub.SBQQ__Quantity__c * ( ( sub.Adder_Margin__c != null ? sub.Adder_Margin__c : 0 ) + ( sub.DNE_Admin_Fee__c != null ? sub.DNE_Admin_Fee__c : 0 ) ) ).setScale(2, RoundingMode.HALF_UP);                
                	//contractMap.get(con.Id).CurrentAmount__c += (sub.SBQQ__Quantity__c * ( sub.Adder_Margin__c  + sub.DNE_Admin_Fee__c ) ).setScale(2, RoundingMode.HALF_UP);                
                    contractMap.get(con.Id).Adder_Margin__c = sub.Adder_Margin__c;
                    
                     System.debug('CurrentAmount__c :: ' +contractMap.get(con.Id).CurrentAmount__c);
                }
            }
        }
       
        System.debug('oppIdSubscriptionMap :: ' +oppIdSubscriptionMap);
        System.debug('conIdSubscriptionMap ::: ' + conIdSubscriptionMap);        
        System.debug('subUpdateMap :: ' +subUpdateMap);
        if(subUpdateMap.size() > 0){
            UPDATE subUpdateMap.values();
        }
        if(subsListToInsert.size() > 0){
            INSERT subsListToInsert;
        }
        if(contractMap.size() > 0){
            UPDATE contractMap.values();
        }
        System.debug('Existing Subscriptions updated successfully.');
        if(renewalOppUpdateMap.size() > 0 ){
            UPDATE renewalOppUpdateMap.values();
        }
        if(contractSet.size() > 0){
            syncRenewalOpportunity(contractSet);
        }
        
    }
    
    public static void updateCaseOfAmendmentOpp(List<Id> amendedOppCaseIds){
        System.debug('amendedOppCaseIds ::: ' + amendedOppCaseIds);
        String oppWonStage = 'Activate Change';
        String oppLostStage = 'Closed Lost';
        Id RecordTypeIdAmendmentOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        List<Case> caseUpdateList = new List<Case>();
        Set<Id> openAmendedOppCaseIdSet = new Set<Id>();
        for(Opportunity opp : [Select Id, StageName, Case__c from Opportunity where Case__c IN : amendedOppCaseIds AND RecordTypeId = :RecordTypeIdAmendmentOpp AND StageName != :oppWonStage AND StageName != :oppLostStage]){       
            if(opp.Case__c != null){
                openAmendedOppCaseIdSet.add(opp.Case__c);
            }
        } 
        System.debug('openAmendedOppCaseIdSet ::: ' + openAmendedOppCaseIdSet);
        for(Id caseId : amendedOppCaseIds){
            If(!openAmendedOppCaseIdSet.contains(caseId)){ 
                System.debug('In if');
                case c = new Case(Id=caseId,Status = 'Closed'); 
                caseUpdateList.add(c);
            }            
        }
        System.debug('caseUpdateList ::: ' + caseUpdateList);
        if(caseUpdateList.size() > 0){
            UPDATE caseUpdateList; 
        }
    }
    
    public static void syncRenewalOpportunity(Set<Id> contractIdSet){
        Opportunity renewalOpps; 
        Opportunity_Site__c oppSite;
        Map<Id, Id > contractRenewalOppIdMap = new Map<Id, Id>();
        
        List<Opportunity_Site__c> oppSiteList = new List<Opportunity_Site__c>();
        List<OpportunityLineItem> listOfOLIs = new List<OpportunityLineItem> ();
        
        
        try{     
            
            for(Contract mContract : [Select Id, SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.RenewalContractId__c,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Market__c,
                                      SBQQ__Opportunity__r.Commodity_Type__c,SBQQ__Opportunity__r.Subscription_Term__c,SBQQ__RenewalForecast__c,
                                      SBQQ__Opportunity__r.Supplier__c,SBQQ__Opportunity__r.Supplier_Price__c,SBQQ__RenewalOpportunity__r.Subscription_Term__c,
                                      SBQQ__Opportunity__r.Flow_Date__c,SBQQ__Opportunity__r.Margin__c,SBQQ__Opportunity__r.DNE_Admin_Fee__c
                                      From Contract 
                                      Where Id IN : contractIdSet])
            {
                if(mContract.SBQQ__RenewalOpportunity__c != null){		  
                    contractRenewalOppIdMap.put(mContract.Id, mContract.SBQQ__RenewalOpportunity__c);                      
                }
            }
            
            
            system.debug('mContract.SBQQ__RenewalOpportunity__c::'+contractRenewalOppIdMap);
            
            // Fetch Opportunity Products
            listOfOLIs = [Select Id, SortOrder, PricebookEntryId, Product2Id, ProductCode, Quantity, 
                          UnitPrice, ListPrice, ServiceDate, Description, SBQQ__ParentID__c,OpportunityId, 
                          SBQQ__QuoteLine__c, SBQQ__SubscriptionType__c, Amend_Quantity__c, Deal_Price__c, 
                          Month_Year__c, Selling_Price__c, Site__c, Supplier_Price__c,Site__r.Market__c  
                          From OpportunityLineItem 
                          Where OpportunityId IN :contractRenewalOppIdMap.values()];
            
            System.debug('listOfOLIs ::: ' + listOfOLIs);
            List<Opportunity_Site__c> opportunitySite =  [Select Id, Market__c,Site__c,
                                                          Opportunity__c,Contract__c,Quantity__c 
                                                          FROM Opportunity_Site__c 
                                                          WHERE Opportunity__c IN :contractRenewalOppIdMap.values()];
            
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
                                              SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,Adder_Margin__c, 
                                              Site__r.Market__c,Site__c,Annual_Volume__c,SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Subscription_Term__c,
                                              SBQQ__Contract__c,SBQQ__StartDate__c
                                              FROM SBQQ__Subscription__c
                                              WHERE SBQQ__Contract__c IN :contractRenewalOppIdMap.keyset() AND Annual_Volume__c != 0 AND Site__c != null])
            {   
                oppSite = new Opportunity_Site__c();
                oppsite.Market__c = subs.Site__r.Market__c;
                oppsite.Site__c = subs.Site__c;
                oppsite.Opportunity__c = subs.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c;
                oppsite.Contract__c = subs.SBQQ__Contract__c;
                oppsite.Adder__c = subs.Adder_Margin__c;
                oppsite.Quantity__c = subs.Annual_Volume__c*(subs.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Subscription_Term__c/12);
                oppSiteList.add(oppSite);
                system.debug('subs.SBQQ__Quantity__c:::::'+subs.SBQQ__Quantity__c);
            }
            
            
            if(oppSiteList.size() > 0){
                INSERT oppSiteList;
                
            } 
            
        }catch( Exception ex){
            system.debug('Exception Occured While Saving Record:::::::'+ex.getMessage());
            
        }
    }
}