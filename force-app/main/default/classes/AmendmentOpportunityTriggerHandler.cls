/* ONLY FOR TESTING TO DATA IMPORT NOT TO USE*/

public class AmendmentOpportunityTriggerHandler {
    public static void saveOLI(List<Opportunity> oppList){
        Map<Id, Opportunity> MainOppAmendOppMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> AmendOppMap = new Map<Id, Opportunity>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        Pricebook2 stdPB = [Select id, name From Pricebook2 Where isStandard = true];  
        Map<Id, Contract> conOppMap = new Map<Id, Contract>();
        Set<Id> contractIdSet = new Set<Id>();
        
        for(Opportunity amendOpp : oppList){
            //AmendOppMap.put(amendOpp.Id,amendOpp);
            MainOppAmendOppMap.put(amendOpp.Main_Opportunity__c,amendOpp);
            
        }
        
        for(Contract con : [Select Id,StartDate,SBQQ__Opportunity__c from Contract where SBQQ__Opportunity__c IN :MainOppAmendOppMap.keyset()]){
            conOppMap.put(con.SBQQ__Opportunity__c,con);
            contractIdSet.add(con.Id);
        }
        
        For(Opportunity Opp : oppList){
            SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
            newQuote.SBQQ__Opportunity2__c = opp.id;
            newQuote.SBQQ__Primary__c = true;
            
            newQuote.SBQQ__PricebookId__c = stdPB.Id;
            
            newQuote.margin__c = opp.margin__c;
            newQuote.Administration_Fee__c = opp.Admin_Fee__c;
            newQuote.Primary_Contact__c = opp.AccountId != null ? opp.account.Primary_Contact__c : null;
            newQuote.Billing_Contact__c = opp.AccountId != null ? opp.account.Primary_Contact__c : null;
            newQuote.Supplier_Price__c = opp.Supplier_Price__c;
            newQuote.Supplier__c = opp.Supplier__c;
            newQuote.Selling_Price__c = opp.Selling_Price__c;        
            if(conOppMap.get(Opp.Id) != null){
                newQuote.SBQQ__MasterContract__c = conOppMap.get(Opp.Main_Opportunity__c).Id;           
            }
            quoteList.add(newQuote);
        }
        
        INSERT quoteList;
        
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        for(SBQQ__Quote__c quot : [SELECT Id,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Main_Opportunity__c 
                                   FROM SBQQ__Quote__c 
                                   WHERE Id IN : quoteList]){
                                       
                                       quoteMap.put(quot.SBQQ__Opportunity2__r.Main_Opportunity__c,quot);
                                   }
        
        SBQQ__QuoteLine__c quoteLine1;
        Opportunity_Site__c oppSite;
        
        List<Opportunity_Site__c> oppSiteList = new List<Opportunity_Site__c>();
        List<SBQQ__QuoteLine__c> oliList = new  List<SBQQ__QuoteLine__c>();
        
        Decimal subTerm = 0;        
        /*  if(remainingTerm != null){
subTerm = remainingTerm/12;
}*/
        Decimal amendedQuantity = 0;
        Decimal subRemainingTerm;
        
        For(SBQQ__Subscription__c sub : [Select Id,Supplier__c,Site__c,SBQQ__Contract__c,SBQQ__Contract__r.Status,site__r.Type__c,
                                         site__r.Market__c,Site__r.name,SBQQ__Contract__r.SBQQ__Opportunity__c,
                                         IsAmended__c,IsNew__c, SBQQ__Discount__c, SBQQ__ListPrice__c,Annual_Volume__c,
                                         SBQQ__Quantity__c, SBQQ__QuoteLine__c, SBQQ__StartDate__c, SBQQ__QuoteLine__r.SBQQ__Product__c,
                                         SBQQ__SubscriptionEndDate__c, SBQQ__SubscriptionStartDate__c,SBQQ__QuoteLine__r.Supplier_Price__c, 
                                         Adder_Margin__c, DNE_Admin_Fee__c,SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c
                                         From SBQQ__Subscription__c where SBQQ__Contract__c IN : contractIdSet AND Site__c != null ORDER by Site__r.name] )
        {
            if(sub.Id != null){
                
                quoteLine1 = new SBQQ__QuoteLine__c();
                quoteLine1.Supplier__c = MainOppAmendOppMap.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__c).Supplier__c;
                quoteLine1.Market__c = MainOppAmendOppMap.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__c).Market__c;
                quoteLine1.Type__c = MainOppAmendOppMap.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__c).recordtype.Name;
                
                quoteLine1.SBQQ__Quote__c = quoteMap.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__c).Id;
                quoteLine1.Site__c = sub.Site__r.Id;
                quoteLine1.SBQQ__Product__c = sub.SBQQ__QuoteLine__r.SBQQ__Product__c;
                
                quoteLine1.SBQQ__ListPrice__c = sub.Adder_Margin__c;
                quoteLine1.Supplier_Price__c = sub.SBQQ__QuoteLine__r.Supplier_Price__c;
                quoteLine1.SBQQ__Existing__c = true;
                quoteLine1.AnnualVolumeForSite__c = sub.Annual_Volume__c;
                
                amendedQuantity = sub.Annual_Volume__c;// - sub.Annual_Volume__c;//old Quantity
                subRemainingTerm = calculateSubterm(sub);
                quoteLine1.SBQQ__Quantity__c = amendedQuantity * (subRemainingTerm/12);
                System.debug('quoteLine1.SBQQ__PriorQuantity__c ::: ' + quoteLine1.SBQQ__PriorQuantity__c);
                System.debug('amendedQuantity ::: ' + amendedQuantity);
                System.debug('quoteLine1.SBQQ__Quantity__c ::: ' + quoteLine1.SBQQ__Quantity__c);
                
                quoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                quoteLine1.SBQQ__DefaultSubscriptionTerm__c =  MainOppAmendOppMap.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__c).Subscription_Term__c;
                quoteLine1.Selling_Price__c = ( ( quoteLine1.Supplier_Price__c != null ? quoteLine1.Supplier_Price__c : 0 ) + ( quoteLine1.SBQQ__ListPrice__c != null ? quoteLine1.SBQQ__ListPrice__c : 0 ) ) * quoteLine1.SBQQ__Quantity__c ;                
                System.debug('amendedQuantity ::: ' + amendedQuantity);
                System.debug('quoteLine1 ::: ' + quoteLine1);                
                oliList.add(quoteLine1);
                
                oppSite = new Opportunity_Site__c();
                oppsite.Market__c =  MainOppAmendOppMap.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__c).Market__c;
                oppsite.Site__c = sub.Site__r.Id;
                oppsite.Opportunity__c =  MainOppAmendOppMap.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__c).id;
                // By passing QLI insertion on trigger
                oppsite.Flag__c = true;
                oppSiteList.add(oppSite);
                
            }  
        }
        
        
        /*    For(SiteWrapper wp :selctedAcc){
quoteLine1 = new SBQQ__QuoteLine__c();
quoteLine1.Supplier__c = opp.Supplier__c;
quoteLine1.Market__c = opp.Market__c;
quoteLine1.Type__c = opp.recordtype.Name;
quoteLine1.SBQQ__Quote__c = newQuote.id;
quoteLine1.Site__c = wp.site.Id;
quoteLine1.SBQQ__Existing__c = false;
quoteLine1.SBQQ__Product__c = ProductId;
quoteLine1.SBQQ__PricebookEntryId__c = PBEId;
quoteLine1.SBQQ__ListPrice__c = wp.margin;
quoteLine1.Supplier_Price__c = wp.supplierPrice;
quoteLine1.AnnualVolumeForSite__c = wp.site.Volume__c;
quoteLine1.SBQQ__Quantity__c = wp.site.Volume__c * subTerm;
quoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
quoteLine1.SBQQ__DefaultSubscriptionTerm__c = opp.Subscription_Term__c;
quoteLine1.Selling_Price__c = ( ( quoteLine1.Supplier_Price__c != null ? quoteLine1.Supplier_Price__c : 0 ) + ( quoteLine1.SBQQ__ListPrice__c != null ? quoteLine1.SBQQ__ListPrice__c : 0 ) ) * quoteLine1.SBQQ__Quantity__c ;                            
oliList.add(quoteLine1);

oppSite = new Opportunity_Site__c();
oppsite.Market__c = opp.Market__c;
oppsite.Site__c = wp.site.id;
oppsite.Opportunity__c = opp.id;
oppsite.Flag__c = true;
oppSiteList.add(oppsite);
}*/
        
        try{
            if(oliList.size() >0 ){
                insert oliList;
            }
            if(oppSiteList.size() > 0){
                insert oppSiteList;
            }            
        }catch(Exception e){
            if(e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            System.debug('exception is -->' + e.getMessage());
        }  
    }
    
    public static Decimal calculateSubterm(SBQQ__Subscription__c sub){
        Decimal subRemainingTerm;
        if(sub.SBQQ__StartDate__c < system.today()){
            
            decimal monthDiff = sub.SBQQ__StartDate__c.monthsBetween(system.today());
            Integer daysEnd = Date.daysInMonth(system.today().year(), system.today().month());
            Decimal day_s = sub.SBQQ__StartDate__c.day();
            Decimal day_e = system.today().day();
            Decimal factor = 0;
            System.debug('sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c ** ' + sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c);
            if(day_s != day_e){
                factor = (day_e - day_s)/daysEnd;
            }       
            subRemainingTerm = sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c - ( monthDiff + factor ).setScale(2, RoundingMode.HALF_UP);
        }
        else{
            subRemainingTerm = sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c;
        }    
        return subRemainingTerm;
    } 
    
}