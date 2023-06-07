/**************************************************
* Class: DNE_SubscriptionTriggerHelper
* Author: Soljit <VW>
* Date: 2019-04-07
* Description : Helper class for subscription trigger to calculate commission
****************************************************/
public class DNE_SubscriptionTriggerHelper {
    public static List<Invoice__c> invoiceList = new List<Invoice__c>();
    public static Invoice__c inv;
    public static Date startDate;
    public static Decimal monthlyInvAmount;
    public static Map<String,DNE_Commission_Percent__c> commissionPercentMap;
    public static Map<Id,Id> contactUserIdMap;
    public static FINAL Integer NB_OF_COMMISSION_LEVELS = 16;
    public static Map<Id,DNE_Commission_Percent__c> commissionPercentIdMap;
    
    /*********************************************************
@Name 			: recalculateCommissions
@Parameters 	: 
@Reutrn type 	: void
@Description 	: recalculate commission after update
********************************************************/
    /*   public static void recalculateCommissions()
{
System.debug('Recalculating Commissions');
List<DNE_Commission__c> commissionToUpsertList = new List<DNE_Commission__c>();
List<Id> affectedSubscriptionId = new List<Id>();

// <Subscription_Id, adjustment_ratio> - newAmount/oldAmount
// ex: 8000/10000 => 0.8 - adjust the Commission amount by 0.8 => ratio < 1 - receiver pays
// ex: 12000/10000 => 1.2 - adjust the Commission amount by 1.2 => ratio > 1 - receiver gets more money
Map<Id, Decimal> ratioMap = new Map<Id, Decimal>();
Decimal oldMargin;
Decimal newMargin;
for(SBQQ__Subscription__c newVersion : (List<SBQQ__Subscription__c>)Trigger.new)
{
SBQQ__Subscription__c oldVersion = (SBQQ__Subscription__c)(Trigger.oldMap.get(newVersion.Id));
oldMargin = oldVersion.Adder_Margin__c != null ? oldVersion.Adder_Margin__c : 0;
newMargin = newVersion.Adder_Margin__c != null ? newVersion.Adder_Margin__c : 0;
Decimal oldAmount = oldVersion.SBQQ__Quantity__c * oldMargin;
Decimal newAmount = newVersion.SBQQ__Quantity__c * newMargin;

if(oldAmount != newAmount)
{
affectedSubscriptionId.add(newVersion.Id);
if(oldAmount == null || oldAmount == 0){
ratioMap.put(newVersion.Id, newAmount);                    
}
else{
ratioMap.put(newVersion.Id, newAmount/oldAmount);                                        
}
}
}

if(affectedSubscriptionId.isEmpty())
return;

List<SBQQ__Subscription__c> affectedSubscriptionDetailedList = 
[SELECT Id, 
(SELECT Id, Amount__c, Paid__c, Receiver__c, Due_Date__c 
FROM DNE_Commissions__r
ORDER BY Due_Date__c ASC)
FROM SBQQ__Subscription__c
WHERE Id IN :affectedSubscriptionId];

for(SBQQ__Subscription__c sub : affectedSubscriptionDetailedList)
{
Decimal theRatio = ratioMap.get(sub.Id);
Date aMonthFromNow = Date.today().addMonths(1);
Date clawBackDueDate = Date.newInstance(aMonthFromNow.year(), aMonthFromNow.month(), 1);

// Receiver_Id, List<Commission>
Map<Id,List<DNE_Commission__c>> receiverId_paidCommissionList_Map = new Map<Id,List<DNE_Commission__c>>();

List<DNE_Commission__c> unpaidCommissionList = new List<DNE_Commission__c>();

for(DNE_Commission__c comm : sub.DNE_Commissions__r)
{
if(comm.Paid__c)
{
List<DNE_Commission__c> theValue;
if(receiverId_paidCommissionList_Map.containsKey(comm.Receiver__c))
{
theValue = receiverId_paidCommissionList_Map.get(comm.Receiver__c);
}
else
{
theValue = new List<DNE_Commission__c>();
}

theValue.add(comm);
receiverId_paidCommissionList_Map.put(comm.Receiver__c, theValue);
}
else
{
unpaidCommissionList.add(comm);
}					
}

// creating Clawback Commissions
for(Id receiverId : receiverId_paidCommissionList_Map.keySet())
{
List<DNE_Commission__c> paidCommissionList = receiverId_paidCommissionList_Map.get(receiverId);
if(paidCommissionList==null || paidCommissionList.isEmpty())
{
continue;
}

Decimal totalAmountPaid = 0;

for(DNE_Commission__c paidComm : paidCommissionList)
{
totalAmountPaid += paidComm.Amount__c;
}

// creating an Adjustment Commission
DNE_Commission__c newCommission = new DNE_Commission__c();
newCommission.Amount__c = -totalAmountPaid*(1-theRatio);
newCommission.Subscription__c = sub.Id;
newCommission.Due_Date__c = clawBackDueDate;
newCommission.Receiver__c = receiverId;
newCommission.Type__c = 'Clawback';

commissionToUpsertList.add(newCommission);
}

// adjusting unpaid Commissions
for(DNE_Commission__c unpaidComm : unpaidCommissionList)
{
System.debug('JTM - theRatio = ' + theRatio);
System.debug('JTM - unpaidComm.Amount__c = ' + unpaidComm.Amount__c);
unpaidComm.Amount__c *= theRatio;
commissionToUpsertList.add(unpaidComm);
}
}

if(!commissionToUpsertList.isEmpty())
{
upsert commissionToUpsertList;
}
} */
    
    /*********************************************************
@Name 			: cancelCommissions
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Cancel commission after update when site is cancelled.
********************************************************/
    /*   public static void cancelCommissions()
{
System.debug('Cancel Commissions');
List<DNE_Commission__c> commissionToUpdateList = new List<DNE_Commission__c>();
List<Id> affectedSubscriptionId = new List<Id>();

for(SBQQ__Subscription__c newVersion : (List<SBQQ__Subscription__c>)Trigger.new)
{
SBQQ__Subscription__c oldVersion = (SBQQ__Subscription__c)(Trigger.oldMap.get(newVersion.Id));            
if(newVersion.Error_Message__c != oldVersion.Error_Message__c && newVersion.Error_Message__c == 'CANCELLED')
{
affectedSubscriptionId.add(newVersion.Id);
}
}

if(affectedSubscriptionId.isEmpty())
return;

List<SBQQ__Subscription__c> affectedSubscriptionDetailedList = 
[SELECT Id, 
(SELECT Id, Amount__c, Paid__c, Receiver__c, Due_Date__c 
FROM DNE_Commissions__r WHERE Paid__c = false)
FROM SBQQ__Subscription__c
WHERE Id IN :affectedSubscriptionId];

for(SBQQ__Subscription__c sub : affectedSubscriptionDetailedList)
{
if(!sub.DNE_Commissions__r.isEmpty()){
for(DNE_Commission__c comm : sub.DNE_Commissions__r)
{
comm.Amount__c = 0;
commissionToUpdateList.add(comm);
}                
}            
}        
if(!commissionToUpdateList.isEmpty())
{
update commissionToUpdateList;
}
}    
*/    
    
    /*********************************************************
@Name 			: populateCustomMarjinInListPrice
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Copy the value of custom "Adder_Margin__c" field into "listprice" field of subscription.
********************************************************/
    public static void populateCustomMarjinInListPrice(){
        System.debug('In populateCustomMarjinInListPrice method');
        for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)Trigger.new)
        {
            if(sub.Adder_Margin__c != null){
                sub.SBQQ__ListPrice__c = sub.Adder_Margin__c;
            }
        }
    }
    
    /*********************************************************
@Name 			: populateCustomMarjinInListPrice
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Copy the value of "listprice" field into custom "Adder_Margin__c" field of subscription.
********************************************************/
    public static void populateListPriceInCustomMarjin(){
        System.debug('In populateListPriceInCustomMarjin method');
        for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)Trigger.new)
        {
            if(sub.SBQQ__ListPrice__c != null){
                sub.Adder_Margin__c = sub.SBQQ__ListPrice__c;
            }
        }
    }
    
    /*********************************************************
@Name 			: populateOriginalAmountQuantityvolume
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Copy the value of "listprice" field into custom "Adder_Margin__c" field of subscription.
********************************************************/
    public static void populateOriginalAmountQuantityvolume(){
        System.debug('In populateOriginalAmountQuantity method');
        for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)Trigger.new)
        {
            sub.OriginalQuantity__c = sub.SBQQ__Quantity__c;
            //  Integer monthDiff = getTerm();
            system.debug('term in months'+sub.Term_in_month__c);
            //system.debug('monthDiff:::::'+monthDiff);
            system.debug('OriginalQuantity__c'+sub.OriginalQuantity__c);
            if(sub.OriginalQuantity__c > 0 && sub.Term_in_month__c > 0){
                sub.Annual_Volume__c = (sub.OriginalQuantity__c/(sub.Term_in_month__c/12.0));
            }
            system.debug('Annual_Volume__c:::'+sub.Annual_Volume__c);
            sub.OriginalAmount__c = (sub.SBQQ__Quantity__c * ( ( sub.Adder_Margin__c != null ? sub.Adder_Margin__c : 0 ) + ( sub.DNE_Admin_Fee__c != null ? sub.DNE_Admin_Fee__c : 0 ) ) ).setScale(2, RoundingMode.HALF_UP);
            System.debug('OriginalAmount__c ::: ' + sub.OriginalAmount__c);
        }
    }
    
    
    /*********************************************************
@Name 			: getTerm
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Copy the value of "listprice" field into custom "Adder_Margin__c" field of subscription.
********************************************************/
    /*public static Integer getTerm(){

integer monthdiff;
for(SBQQ__Subscription__c sub : (List<SBQQ__Subscription__c>)Trigger.new)
{
Integer yearDiff = sub.SBQQ__EndDate__c.Year() - sub.SBQQ__StartDate__c.Year();
Integer yearDiffGreater = sub.SBQQ__EndDate__c.Year() - (sub.SBQQ__StartDate__c.Year() + 1) ;
if(yearDiff == 0){
monthdiff = sub.SBQQ__EndDate__c.month() - sub.SBQQ__StartDate__c.month() ;
}

else if(yearDiffGreater >= 1){
//monthdiff = ((yearDiffGreater)*12) + ((12- (SBQQ__StartDate__c).month()) + (SBQQ__EndDate__c).month());
monthdiff = ((sub.SBQQ__EndDate__c.Year() - (sub.SBQQ__StartDate__c.Year() + 1))*12) + ((12- sub.SBQQ__StartDate__c.month()) + sub.SBQQ__EndDate__c.month());
} 
else{
monthdiff = (12 - sub.SBQQ__StartDate__c.month()) + sub.SBQQ__EndDate__c.month();
}
}
system.debug('monthdiff::::::::'+monthdiff); 
return monthdiff;

}
/*********************************************************
@Name 			: populateAnnualVolume
@Parameters 	: 
@Reutrn type 	: void
@Description 	: 
********************************************************/
    /*   public static void updateAnnualQuantity(Map<ID,SBQQ__Subscription__c> oldMap,Map<ID,SBQQ__Subscription__c> newMap){
for(Id subId : newMap.keyset())
{
if(newMap.get(subId).Annual_Volume__c != oldMap.get(subId).Annual_Volume__c){
newMap.get(subId).SBQQ__Quantity__c =  newMap.get(subId).Annual_Volume__c*(newMap.get(subId).Term_in_month__c/12);
}
if(newMap.get(subId).SBQQ__Quantity__c != oldMap.get(subId).SBQQ__Quantity__c){
newMap.get(subId).Annual_Volume__c =  newMap.get(subId).SBQQ__Quantity__c/(newMap.get(subId).Term_in_month__c/12);
}

}
}
*/
    /*********************************************************
@Name 			: updateRevenue
@Parameters 	: Map of Old and New subscriptions
@Reutrn type 	: void
@Description 	: update Invoice( revenue) if any adder change
********************************************************/
    public static void updateRevenue(Map<ID,SBQQ__Subscription__c> oldMap,Map<ID,SBQQ__Subscription__c> newMap){
        Set<Id> filteredSubscriptionIdSet = new Set<Id>();
        Set<Id> dateChangeSubIdSet = new Set<Id>();
        Set<Id> quantityMarginDateChangeSubIdSet = new Set<Id>();        
        List<Invoice__c> revenueUpdateList = new List<Invoice__c>();
        List<SBQQ__Subscription__c> subUpdateList = new List<SBQQ__Subscription__c>();
        
        //Filter only mismatched subscriptions
        for(Id subId : newMap.keyset()){
            /*if((newMap.get(subId).Adder_Margin__c != oldMap.get(subId).Adder_Margin__c)
|| (newMap.get(subId).DNE_Admin_Fee__c != oldMap.get(subId).DNE_Admin_Fee__c) 
|| (newMap.get(subId).SBQQ__Quantity__c != oldMap.get(subId).SBQQ__Quantity__c)
|| (newMap.get(subId).Dispute_Resolution_Date__c != oldMap.get(subId).Dispute_Resolution_Date__c))
{
filteredSubscriptionIdSet.add(subId);
}*/
            
            system.debug('Old Quantity::::::'+oldMap.get(subId).SBQQ__Quantity__c);
            system.debug('new Quantity::::::'+newMap.get(subId).SBQQ__Quantity__c);
            system.debug('Old Resolution Date:::'+oldMap.get(subId).Dispute_Resolution_Date__c);
            system.debug('new Resolution Date:::'+oldMap.get(subId).Dispute_Resolution_Date__c);
            if(((newMap.get(subId).Adder_Margin__c != oldMap.get(subId).Adder_Margin__c)
                || (newMap.get(subId).DNE_Admin_Fee__c != oldMap.get(subId).DNE_Admin_Fee__c) 
                || (newMap.get(subId).SBQQ__Quantity__c != oldMap.get(subId).SBQQ__Quantity__c) 
                && newMap.get(subId).Dispute_Resolution_Date__c != null))
            {
                system.debug('Quantity Changed::::::');
                quantityMarginDateChangeSubIdSet.add(subId);
            }
            else if(newMap.get(subId).Dispute_Resolution_Date__c != oldMap.get(subId).Dispute_Resolution_Date__c 
                    && newMap.get(subId).Dispute_Resolution_Date__c != null)
            {
                dateChangeSubIdSet.add(subId);
            }			            
        } 
        // Proceed with only addre changed subscriptions 
        if(quantityMarginDateChangeSubIdSet.size() > 0 || dateChangeSubIdSet.size() > 0){
            Decimal InvAmount;
            Decimal monthlyInvAmount;
            // Fetch all subscription with Invoice Records
            for(SBQQ__Subscription__c sub : [SELECT Id, Dispute_Resolution_Date__c, Upfront_Amount__c, Residual_Amount__c,
                                             Error_Message__c,Supplier__c,Site__c,SBQQ__ProductName__c,SBQQ__Product__r.family,
                                             Name,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Contract__r.name,SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c,
                                             SBQQ__Contract__r.Discount__c,SBQQ__Contract__r.ContractTerm,Revenue_List_Price__c,
                                             SBQQ__Quantity__c,SBQQ__ListPrice__c,SBQQ__Contract__r.SBQQ__Opportunity__c,
                                             SBQQ__Contract__r.Payment_Terms__c,
                                             (SELECT Id, Subscription__c, Calculation_Type__c, Payment_Month__c,
                                              Expected_Adder__c,Expected_Volume__c
                                              FROM Invoices__r)
                                             FROM SBQQ__Subscription__c
                                             WHERE Id IN :quantityMarginDateChangeSubIdSet OR Id IN :dateChangeSubIdSet])
            {   
                
                decimal subsTerm =  calculateRemainingTerm(sub.SBQQ__StartDate__c,sub.Dispute_Resolution_Date__c, sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c);
                //If payment term is 50% on flow and 50% residual
                if(sub.SBQQ__Contract__r.Payment_Terms__c == '50% Upfront on flow and 50% Residual - Monthly'){
                    if(sub.SBQQ__Contract__r.Discount__c == null){
                        InvAmount = ((sub.SBQQ__Quantity__c * sub.Revenue_List_Price__c)/2).setScale(2, RoundingMode.HALF_UP);
                    }
                    else{
                        InvAmount = (((sub.SBQQ__Quantity__c * sub.Revenue_List_Price__c)/2)*((100-sub.SBQQ__Contract__r.Discount__c)/100)).setScale(2, RoundingMode.HALF_UP);                                 
                    }                
                    monthlyInvAmount = (InvAmount/subsTerm).setScale(2, RoundingMode.HALF_UP);
                    
                    if(dateChangeSubIdSet.contains(sub.Id)){
                        system.debug('InvAmount before if:::'+InvAmount);
                        system.debug('sub.Upfront_Amount__c before if:::'+sub.Upfront_Amount__c);
                        
                        if(sub.SBQQ__StartDate__c.month() >= sub.Dispute_Resolution_Date__c.month()){
                            sub.Upfront_Amount__c = InvAmount;  
                        }
                        system.debug('InvAmount after if:::'+InvAmount);
                        system.debug('sub.Upfront_Amount__c after if:::'+sub.Upfront_Amount__c);
                        sub.Residual_Amount__c = monthlyInvAmount;
                    }
                    else{
                        system.debug('Else on Quantity change before sub.Upfront_Amount__c :::'+sub.Upfront_Amount__c);
                        if(sub.Dispute_Resolution_Date__c <= sub.SBQQ__StartDate__c.addMonths(1).addDays(-1)){
                            sub.Upfront_Amount__c = InvAmount;  
                        }
                        system.debug('Else on Quantity change after sub.Upfront_Amount__c :::'+sub.Upfront_Amount__c);                        
                        sub.Residual_Amount__c = monthlyInvAmount;				
                    }
                } // If payment term is 100% residual
                else if(sub.SBQQ__Contract__r.Payment_Terms__c == '100% Residual - Monthly'){ 
                    
                    if(sub.SBQQ__Contract__r.Discount__c == null){
                        monthlyInvAmount =  ( ( sub.SBQQ__Quantity__c * sub.Revenue_List_Price__c ) / subsTerm ).setScale( 2 , RoundingMode.HALF_UP );                               
                    }
                    else{
                        monthlyInvAmount =  ( ( ( sub.SBQQ__Quantity__c * sub.Revenue_List_Price__c ) * ( ( 100 - sub.SBQQ__Contract__r.Discount__c ) / 100 ) ) / subsTerm ).setScale( 2 , RoundingMode.HALF_UP );                               
                    }
                    if(dateChangeSubIdSet.contains(sub.Id)){
                        if(sub.Residual_Amount__c == null){
                            sub.Residual_Amount__c = monthlyInvAmount;
                        }                
                    }
                    else{
                        sub.Residual_Amount__c = monthlyInvAmount;
                    }
                }
                else if(sub.SBQQ__Contract__r.Payment_Terms__c == '50% Upfront, 50% at year 1'){
                    if(sub.SBQQ__Contract__r.Discount__c == null){
                        monthlyInvAmount = ((sub.SBQQ__Quantity__c / 12) * (sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 2) );
                    }
                    else{
                        monthlyInvAmount =  ( ( ( sub.SBQQ__Quantity__c / 12 ) * ( ( 100 - sub.SBQQ__Contract__r.Discount__c ) / 100 ) ) * (sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 2));
                    }                
                    
                    if(dateChangeSubIdSet.contains(sub.Id)){
                        system.debug('sub.Upfront_Amount__c before if:::'+sub.Upfront_Amount__c);
                        
                        if(sub.SBQQ__StartDate__c.month() >= sub.Dispute_Resolution_Date__c.month()){
                            sub.Upfront_Amount__c = monthlyInvAmount;  
                        }
                        system.debug('sub.Upfront_Amount__c after if:::'+sub.Upfront_Amount__c);
                        sub.Residual_Amount__c = monthlyInvAmount;
                    }
                    else{
                        system.debug('Else on Quantity change before sub.Upfront_Amount__c :::'+sub.Upfront_Amount__c);
                        if(sub.Dispute_Resolution_Date__c <= sub.SBQQ__StartDate__c.addMonths(1).addDays(-1)){
                            sub.Upfront_Amount__c = monthlyInvAmount;  
                        }
                        system.debug('Else on Quantity change after sub.Upfront_Amount__c :::'+sub.Upfront_Amount__c);                        
                        sub.Residual_Amount__c = monthlyInvAmount;				
                    }
                }
               /* else if(sub.SBQQ__Contract__r.Payment_Terms__c == '100% Upfront - Annual'){
                    if(sub.SBQQ__Contract__r.Discount__c == null){
                        monthlyInvAmount =  ((sub.SBQQ__Quantity__c / 12) * sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c );
                    }
                    else{
                        monthlyInvAmount =  ( ( ( sub.SBQQ__Quantity__c / 12 ) * ( ( 100 - sub.SBQQ__Contract__r.Discount__c ) / 100 ) ) * sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c );                               
                    }
                    if(dateChangeSubIdSet.contains(sub.Id)){
                        system.debug('sub.Upfront_Amount__c before if:::'+sub.Upfront_Amount__c);
                        
                        if(sub.SBQQ__StartDate__c.month() >= sub.Dispute_Resolution_Date__c.month()){
                            sub.Upfront_Amount__c = monthlyInvAmount;  
                        }
                        system.debug('sub.Upfront_Amount__c after if:::'+sub.Upfront_Amount__c);
                        sub.Residual_Amount__c = monthlyInvAmount;
                    }
                    else{
                        system.debug('Else on Quantity change before sub.Upfront_Amount__c :::'+sub.Upfront_Amount__c);
                        if(sub.Dispute_Resolution_Date__c <= sub.SBQQ__StartDate__c.addMonths(1).addDays(-1)){
                            sub.Upfront_Amount__c = monthlyInvAmount;  
                        }
                        system.debug('Else on Quantity change after sub.Upfront_Amount__c :::'+sub.Upfront_Amount__c);                        
                        sub.Residual_Amount__c = monthlyInvAmount;				
                    }
                } */
                // Update invoices of subscription      
                
                for(Invoice__c inv : sub.Invoices__r)
                {
                    system.debug('Invoices::::'+inv);
                    if(dateChangeSubIdSet.contains(sub.Id) || quantityMarginDateChangeSubIdSet.contains(sub.Id)){
                        if(inv.Payment_Month__c < sub.Dispute_Resolution_Date__c)
                        {   
                            continue;
                        }
                        system.debug('Out of IF::::Invoices::::'+inv);
                        if(sub.Error_Message__c == 'CANCELLED'){
                            inv.Amount__c = 0;
                            inv.Expected_Adder__c = 0;
                            inv.Expected_Volume__c = 0;
                            inv.Flag__c = 'CANCELLED';
                            revenueUpdateList.add(inv);
                            continue;
                        }				
                    }				
                    if(inv.Calculation_Type__c == 'Upfront'){
                        inv.Amount__c = sub.Upfront_Amount__c;
                    }else{
                        inv.Amount__c = sub.Residual_Amount__c;
                    }
                    inv.Expected_Adder__c = sub.Revenue_List_Price__c;
                    inv.Expected_Volume__c = sub.SBQQ__Quantity__c / ( sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 12 );
                    revenueUpdateList.add(inv);
                }
                subUpdateList.add(sub);
            }
            if(subUpdateList.size()>0){
                System.debug('Before update subUpdateList : '+ subUpdateList);
                update subUpdateList;
                System.debug('Subscription updated successfully.');                
            }
            if(revenueUpdateList.size() > 0){
                System.debug('Before update revenueUpdateList : '+ revenueUpdateList);
                update revenueUpdateList;
                System.debug('Revenue updated successfully.');
            }
        }
    }
    
    public static Decimal calculateRemainingTerm(Date SubStartDate, Date disputeResoDate, Decimal subscriptionTerm){
        Decimal termRemaining = 0;
        if(SubStartDate < disputeResoDate){
            system.debug('opp Flow Date :::'+SubStartDate);
            decimal monthDiff = SubStartDate.monthsBetween(disputeResoDate);
            Integer daysEnd = Date.daysInMonth(disputeResoDate.year(), disputeResoDate.month());
            Decimal day_s = SubStartDate.day();
            Decimal day_e = disputeResoDate.day();
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
    
    /*********************************************************
@Name 			: populateDNEAdminFeeFromContract
@Parameters 	: 
@Reutrn type 	: void
@Description 	: 
********************************************************/
    public static void populateDNEAdminFeeFromContract(){
        System.debug('In populateDNEAdminFeeFromContract method');
        Set<Id> contractIdSet = new Set<Id>();
        for(SBQQ__Subscription__c subs : (List<SBQQ__Subscription__c>)Trigger.new){
            contractIdSet.add(subs.SBQQ__Contract__c);
        }
        
        Map<Id,Contract> contractMap = new Map<Id,Contract>([Select Id, DNE_Admin_Fee__c 
                                                             From Contract 
                                                             Where Id IN : contractIdSet]);
        for(SBQQ__Subscription__c subs : (List<SBQQ__Subscription__c>)Trigger.new){
            if(contractMap.containsKey(subs.SBQQ__Contract__c) && contractMap.get(subs.SBQQ__Contract__c).DNE_Admin_Fee__c != null && subs.IsAmended__c == false && subs.IsNew__c == false){
                subs.DNE_Admin_Fee__c = contractMap.get(subs.SBQQ__Contract__c).DNE_Admin_Fee__c;
            }
        }
    }
    /*********************************************************
@Name 			: checkAmendment
@Parameters 	: 
@Reutrn type 	: void
@Description 	: 
********************************************************/
    /*   public static void checkAmendment(List<SBQQ__Subscription__c> subsList){
List<SBQQ__Subscription__c> newSubsList = new  List<SBQQ__Subscription__c>();
List<Id> oldSubsListToDelete = new  List<Id>();
System.debug('In checkAmendment method');
Set<Id> contractSet = new Set<Id>();
for(SBQQ__Subscription__c sub : subsList){
contractSet.add(sub.SBQQ__Contract__c);

}
Map<Id,SBQQ__Subscription__c> existingSubscriptionSet = new Map<Id,SBQQ__Subscription__c>();
Set<Id> newSubscriptionSet = new Set<Id>();
System.debug('Contract Size'+contractSet.size());
System.debug('Contract Values'+contractSet);
Contract con = new Contract();
con.CurrentVolume__c = 0;
con.CurrentAmount__c = 0;
for(SBQQ__Subscription__c subscriptionCon : [Select Id,Supplier__c,SBQQ__OriginalQuoteLine__c,IsAmended__c,
Site__c,SBQQ__Contract__c,SBQQ__Quantity__c,Adder_Margin__c,DNE_Admin_Fee__c,
SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Flow_Date__c
From SBQQ__Subscription__c Where SBQQ__Contract__c IN:contractSet ])
{
if(subscriptionCon.SBQQ__Quantity__c != null){
con.CurrentVolume__c += subscriptionCon.SBQQ__Quantity__c;
con.CurrentAmount__c += (subscriptionCon.SBQQ__Quantity__c * ( ( subscriptionCon.Adder_Margin__c != null ? subscriptionCon.Adder_Margin__c : 0 ) + ( subscriptionCon.DNE_Admin_Fee__c != null ? subscriptionCon.DNE_Admin_Fee__c : 0 ) ) );
}

if(subscriptionCon.IsAmended__c == false){
existingSubscriptionSet.put(subscriptionCon.Site__c,subscriptionCon);                
}
System.debug('Subscription Site Inside For Loop'+subscriptionCon.Site__c); 

}
if(existingSubscriptionSet.isEmpty()){
return;
}
for(SBQQ__Subscription__c subscriptionCon : subsList)
{

if(existingSubscriptionSet.ContainsKey(subscriptionCon.Site__c)){
SBQQ__Subscription__c sub = existingSubscriptionSet.get(subscriptionCon.Site__c);
system.debug('Amendment = True'); 
sub.IsAmended__c = true;
//subscriptionCon.SBQQ__OriginalQuoteLine__c = existingSubscriptionSet.get(subscriptionCon.Site__c).SBQQ__OriginalQuoteLine__c;
sub.SBQQ__Quantity__c += subscriptionCon.SBQQ__Quantity__c;
sub.Dispute_Resolution_Date__c = subscriptionCon.SBQQ__StartDate__c;
newSubsList.add(sub);
subscriptionCon.SBQQ__QuoteLine__c = null;
subscriptionCon.Site__c = null;

system.debug('subscriptionCon.SBQQ__QuoteLine__c:::'+subscriptionCon.SBQQ__QuoteLine__c);
system.debug('subscriptionCon.Site__c::'+subscriptionCon.Site__c);
system.debug(' sub.Dispute_Resolution_Date__c:::'+ sub.Dispute_Resolution_Date__c);
system.debug(' subscriptionCon.SBQQ__StartDate__c:::'+ subscriptionCon.SBQQ__StartDate__c);
}
else{
subscriptionCon.IsNew__c = true;
system.debug('Amendment = false'); 
system.debug('create contract or Subscription = true'); 
}
con.Id = subscriptionCon.SBQQ__Contract__c;
if(subscriptionCon.SBQQ__Quantity__c != null){
con.CurrentVolume__c += subscriptionCon.SBQQ__Quantity__c;
con.CurrentAmount__c += (subscriptionCon.SBQQ__Quantity__c * ( ( subscriptionCon.Adder_Margin__c != null ? subscriptionCon.Adder_Margin__c : 0 ) + ( subscriptionCon.DNE_Admin_Fee__c != null ? subscriptionCon.DNE_Admin_Fee__c : 0 ) ) );
}
System.debug('contract CurrentVolume__c'+con.CurrentVolume__c);
System.debug('Subscription Inside For Loop'+subscriptionCon.Site__c); 

}
if(newSubsList.size() > 0){
UPDATE newSubsList;
}

if(con.Id != null){
UPDATE con;
}
} 
*/ 
    
    
    /*********************************************************
@Name 			: createInvoiceAndCommissions
@Parameters 	: 
@Reutrn type 	: void
@Description 	: 
********************************************************/
    public static void createInvoiceAndCommissions(List<SBQQ__Subscription__c> subsList){
        
        System.debug('In createInvoiceAndCommissions method');
        List<SBQQ__Subscription__c> activatedSubsSet = new list<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> revenueRecSubsSet = new list<SBQQ__Subscription__c>();
        // System.debug('Contract Size'+contractSet.size());
        //System.debug('Contract Values'+contractSet);
        for(SBQQ__Subscription__c subscriptionCon : [Select Id,Supplier__c,Site__c,SBQQ__Contract__c,SBQQ__Contract__r.Status,IsAmended__c,IsNew__c
                                                     From SBQQ__Subscription__c Where  IsNew__c = true AND ID IN : subsList ])
        {
            if(subscriptionCon.SBQQ__Contract__r.Status == 'Activated')
            {
                activatedSubsSet.add(subscriptionCon);
            }
            else if(subscriptionCon.SBQQ__Contract__r.Status == 'Revenue Received'){
                revenueRecSubsSet.add(subscriptionCon);   
            }
        }
        if(activatedSubsSet.isEmpty() && revenueRecSubsSet.isEmpty()){
            return;
        }
        if(activatedSubsSet.size() > 0){
            //createDNECommissions(activatedSubsSet);
        }
        if(revenueRecSubsSet.size() > 0){
            // createDNECommissions(revenueRecSubsSet);
            generateTransactionInvoice(revenueRecSubsSet);
        }
    }
    
    /*********************************************************
@Name 			: createDNECommissions
@Parameters 	: 
@Reutrn type 	: void
@Description 	: after insert, after update
********************************************************/
    /*   public static void createDNECommissions(List<SBQQ__Subscription__c> subsList)
{   
system.debug('debug in createDNECommissions:::');
List<DNE_Commission__c> commissionToInsertList = new List<DNE_Commission__c>();

List<DNE_Commission__c> allCommissions = new List<DNE_Commission__c>();

// Set<Id> contractsJustActivatedIdList = new Set<Id>();

Set<id> relatedContactIdSet = new Set<id>();

/*for (Contract newVersion : newContract.Values()) 
//for(Contract newVersion : (List<Contract>)Trigger.new)
{
Contract oldVersion;
if(isUpdate)
{
//oldVersion = (Contract)Trigger.oldMap.get(newVersion.Id);
oldVersion = OldContract.get(newVersion.Id);
}

if((isUpdate && oldVersion.Status!='Activated' && newVersion.Status=='Activated') ||
(isInsert && newVersion.Status=='Activated'))
{
contractsJustActivatedIdList.add(newVersion.Id);
}
}*/
    // System.debug('### contractsJustActivatedIdList.size() ::: ' + contractsJustActivatedIdList.size());
    // System.debug('### contractsJustActivatedIdList ::: ' + contractsJustActivatedIdList);
    
    /* if(contractsJustActivatedIdList.size() > 0){
//Calling method for populate Commission Hierarchy lookup on contract.
populateCommissionHierarchy(contractsJustActivatedIdList);

//Calling method for populate Commission Percent lookup and update DNE_Activation_Date__c on contract.
populateCommissionPercent(contractsJustActivatedIdList);            
}*/
    
    /*      List<SBQQ__Subscription__c> relatedSubscriptionList = [
SELECT Id, SBQQ__Quantity__c, SBQQ__ListPrice__c, Adder_Margin__c, Opener__c, Closer__c, Opener_2__c, Closer_2__c, 
Level_1__c, Level_2__c, Level_3__c, Level_4__c, 
Level_5__c, Level_6__c, Level_7__c, Level_8__c, 
Level_9__c, Level_10__c, Level_11__c, Level_12__c, 
Level_13__c, Level_14__c, Level_15__c, Level_16__c,
Level_1_2__c, Level_2_2__c, Level_3_2__c, Level_4_2__c, 
Level_5_2__c, Level_6_2__c, Level_7_2__c, Level_8_2__c, 
Level_9_2__c, Level_10_2__c, Level_11_2__c, Level_12_2__c, 
Level_13_2__c, Level_14_2__c, Level_15_2__c, Level_16_2__c,
SBQQ__Contract__c, 
SBQQ__Contract__r.Opportunity_Type__c, 
SBQQ__Contract__r.SBQQ__Opportunity__r.Closer__c, 
SBQQ__Contract__r.SBQQ__Opportunity__r.Opener__c,
SBQQ__Contract__r.SBQQ__Opportunity__r.Subscription_Term__c, 
SBQQ__Contract__r.SBQQ__Opportunity__r.Type, 
SBQQ__Contract__r.StartDate,
SBQQ__Contract__r.DNE_Activation_Date__c,SBQQ__StartDate__c,
SBQQ__Contract__r.DNE_Commission_Percent__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c
FROM SBQQ__Subscription__c
WHERE Id IN : subsList];

System.debug('JTM - relatedSubscriptionList : ' + relatedSubscriptionList);

for(SBQQ__Subscription__c sub : relatedSubscriptionList){
List<Id> relatedContactIdList = new List<Id>{ sub.Opener__c, sub.Closer__c, sub.Opener_2__c, sub.Closer_2__c, 
sub.Level_1__c, sub.Level_2__c, sub.Level_3__c, sub.Level_4__c, 
sub.Level_5__c, sub.Level_6__c, sub.Level_7__c, sub.Level_8__c, 
sub.Level_9__c, sub.Level_10__c, sub.Level_11__c, sub.Level_12__c, 
sub.Level_13__c, sub.Level_14__c, sub.Level_15__c, sub.Level_16__c,
sub.Level_1_2__c, sub.Level_2_2__c, sub.Level_3_2__c, sub.Level_4_2__c, 
sub.Level_5_2__c, sub.Level_6_2__c, sub.Level_7_2__c, sub.Level_8_2__c, 
sub.Level_9_2__c, sub.Level_10_2__c, sub.Level_11_2__c, sub.Level_12_2__c, 
sub.Level_13_2__c, sub.Level_14_2__c, sub.Level_15_2__c, sub.Level_16_2__c };
relatedContactIdSet.addAll(relatedContactIdList);
}
System.debug('#### relatedContactIdSet.size() : ' + relatedContactIdSet.size());
System.debug('#### relatedContactIdSet : ' + relatedContactIdSet);
relatedContactIdSet.remove(null);
if(relatedContactIdSet.size() > 0)
{
fetchUser(relatedContactIdSet);
}

//This will create a map with Id as key and commission percent object record as value of map.
createCommissionPercentageMap(True);

for(SBQQ__Subscription__c relatedSub : relatedSubscriptionList)
{
// CommissionType~ContractType (Ex: New~Index or Renewal~Fixed within 12 months)
Boolean secondOpener = relatedSub.Opener_2__c != null;
Boolean secondCloser = relatedSub.Closer_2__c != null;


String subsType = relatedSub.SBQQ__Contract__r.SBQQ__Opportunity__r.Type;
String contractType;
if(relatedSub.SBQQ__Contract__r.Opportunity_Type__c == ConstantString.VARIABLE_TYPE)
{
contractType = 'Index';
}
else
{
if(relatedSub.SBQQ__Contract__r.StartDate <= Date.today().addMonths(12))
{
contractType = 'Fixed within 12 months';
}
else
{
contractType = 'Fixed after 12 months';
}
}

String subsKey = subsType + '~' + contractType;

DNE_Commission_Percent__c thisCommPerc = commissionPercentIdMap.get(relatedSub.SBQQ__Contract__r.DNE_Commission_Percent__c);

if(thisCommPerc == null)
{
String errorMessage = System.Label.Commission_Percent_Record_Label + subsType;
errorMessage += ') and Contract Type (' + contractType + ')';
System.debug('ERROR : ' + errorMessage);
Contract parentContract = new Contract();
parentContract.Id = relatedSub.SBQQ__Contract__c;
System.debug('parentContract : ' + parentContract);
parentContract.addError(errorMessage);
return;
}

if(String.isNotBlank(String.valueOf(relatedSub.get('Opener__c')))){
List<DNE_Commission__c> openerCommissions = createCommissionsforReceiver(relatedSub, thisCommPerc, 'Opener', secondOpener);                
allCommissions.addAll(openerCommissions);
}                
List<DNE_Commission__c> closerCommissions = createCommissionsforReceiver(relatedSub, thisCommPerc, 'Closer', secondCloser);

allCommissions.addAll(closerCommissions);

Integer levelCounter = 1;
for(levelCounter=1; levelCounter<NB_OF_COMMISSION_LEVELS; levelCounter++)
{
String receiverType = 'Level_' + levelCounter;
String receiverFieldName = 'Level_' + levelCounter + '__c';

String receiverId = String.valueOf(relatedSub.get(receiverFieldName));

System.debug('JTM - Receiver ' + receiverType + ' = ' + receiverId);

if(String.isNotBlank(receiverId))
{
List<DNE_Commission__c> levelCommissions = createCommissionsforReceiver(relatedSub, thisCommPerc, receiverType, false);
System.debug('JTM - Level Commissions ' + receiverType + ' = ' + levelCommissions.size());
allCommissions.addAll(levelCommissions);
}
}

if(secondOpener)
{
if(String.isNotBlank(String.valueOf(relatedSub.get('Opener_2__c')))){
List<DNE_Commission__c> opener2Commissions = createCommissionsforReceiver(relatedSub, thisCommPerc, 'Opener_2', true);
allCommissions.addAll(opener2Commissions);
}                

Integer level2Counter = 1;
for(level2Counter=1; level2Counter<NB_OF_COMMISSION_LEVELS; level2Counter++)
{
String receiverType = 'Level_' + level2Counter + '_2';
String receiverFieldName = 'Level_' + level2Counter + '_2__c';

String receiverId = String.valueOf(relatedSub.get(receiverFieldName));

System.debug('JTM - Receiver ' + receiverType + ' = ' + receiverId);

if(String.isNotBlank(receiverId))
{
List<DNE_Commission__c> levelCommissions = createCommissionsforReceiver(relatedSub, thisCommPerc, receiverType, false);
System.debug('JTM - Level Commissions ' + receiverType + ' = ' + levelCommissions.size());
allCommissions.addAll(levelCommissions);
}
}
}
if(secondCloser)
{
List<DNE_Commission__c> closer2Commissions = createCommissionsforReceiver(relatedSub, thisCommPerc, 'Closer_2', true);
allCommissions.addAll(closer2Commissions);
}

System.debug('JTM - Total Commissions ' + ' = ' + allCommissions.size());
}

System.debug('JTM - allCommissions = ' + allCommissions.size());
if(allCommissions.size() > 0 ){
insert allCommissions;
System.debug('JTM - allCommissions inserted successfully.');            
}
}
*/
    /*********************************************************
@Name 			: generateTransactionInvoice
@Parameters 	: List<Contract>:conList
@Reutrn type 	: void
@Description 	: Method for creating all invoices corresponding to subscriptions;
********************************************************/
    public static void generateTransactionInvoice(List<SBQQ__Subscription__c> subsList){   
        system.debug('debug in generateTransactionInvoice:::');
        
        List<Invoice__c> tempInvoiceList;
        //List<SBQQ__Subscription__c> 
        Invoice__c inv; 
        List<SBQQ__Subscription__c> subscList = new List<SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c subscriptionCon : [Select id,Supplier__c,Site__c,SBQQ__ProductName__c,SBQQ__Product__r.family,Name,SBQQ__StartDate__c,
                                                     SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c,SBQQ__EndDate__c,SBQQ__Contract__r.name,SBQQ__Contract__r.Discount__c,SBQQ__Contract__r.ContractTerm,Revenue_List_Price__c,
                                                     SBQQ__Quantity__c,SBQQ__ListPrice__c,SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c,Adder_Margin__c,SBQQ__Contract__r.SBQQ__Opportunity__c,SBQQ__Contract__r.Payment_Terms__c
                                                     From SBQQ__Subscription__c Where  Id IN:subsList ]){
                                                         
                                                         subscList.add(subscriptionCon);                                                                                      
                                                     }
        if(subscList.size() > 0){
            tempInvoiceList = createInvoice(subscList);
            System.debug('subscList ::: ' + subscList);
            if(tempInvoiceList.size()>0){
                invoiceList.addAll(tempInvoiceList);
            }  
            try{
                if(invoiceList.size()>0){
                    insert invoiceList;        
                    System.debug('invoiceList is ' + invoiceList);
                }
                if(subscList.size()>0){
                    update subscList;
                    System.debug('Subscription updated successfully');                
                }            
            }catch(Exception e){
                System.debug('invoice error is ' +e.getMessage());
            }  
        }
    } 
    
    
    /*********************************************************
@Name 			: fetchUser
@Parameters 	: 
@Reutrn type 	: Id
@Description 	: To fetch active internal user who has the same email address as the contact for the commission
********************************************************/
    /*  public static void fetchUser(Set<Id> conIdSet){

contactUserIdMap = new Map<Id,Id>();
System.debug('#### conIdSet : ' + conIdSet);
Map<String,Id> conIdEmailMap = new Map<String,Id>();
for(Contact con : [select id, email from Contact where id IN :conIdSet]){
conIdEmailMap.put(con.email,con.id);
}
conIdEmailMap.remove(null);
System.debug('#### conIdEmailMap :: ' + conIdEmailMap);
For(User u :[select id,email from user where isactive =true and email IN : conIdEmailMap.keyset()]){

contactUserIdMap.put(conIdEmailMap.get(u.Email), u.Id);
}
System.debug('#### contactUserIdMap :: ' + contactUserIdMap);
} 
*/
    /*********************************************************
@Name 			: createCommissionPercentageMap
@Parameters 	: pexPages.StandardController
@Reutrn type 	: void
@Description 	: create commission percentage
********************************************************/
    /*  public static void createCommissionPercentageMap(Boolean seeAllComPer){
commissionPercentMap = new Map<String,DNE_Commission_Percent__c>();
commissionPercentIdMap = new Map<Id,DNE_Commission_Percent__c>();
Datetime dateTimeNow = Datetime.now();
String theQuery;
if(seeAllComPer)
{
theQuery = 'SELECT x FROM DNE_Commission_Percent__c';
}
else{
theQuery = 'SELECT x FROM DNE_Commission_Percent__c WHERE Effective_From__c < :dateTimeNow ORDER BY Effective_From__c DESC';		
}

List<String> fieldsToQuery = new List<String>();

fieldsToQuery.add('Type__c');
fieldsToQuery.add('Contract_Type__c');
fieldsToQuery.add('Max_Payout_Upfront__c');

fieldsToQuery.add('Opener_Commission_Percentage__c');
fieldsToQuery.add('Opener_Upfront_Percentage__c');
fieldsToQuery.add('Opener_Flow_Percentage__c');
fieldsToQuery.add('Opener_Residual_Percentage__c');

fieldsToQuery.add('Closer_Commission_Percentage__c');
fieldsToQuery.add('Closer_Upfront_Percentage__c');
fieldsToQuery.add('Closer_Flow_Percentage__c');
fieldsToQuery.add('Closer_Residual_Percentage__c');

for(Integer i=1; i<=NB_OF_COMMISSION_LEVELS; i++)
{
fieldsToQuery.add('Level_' + i + '_Commission_Percentage__c');
fieldsToQuery.add('Level_' + i + '_Upfront_Percentage__c');
fieldsToQuery.add('Level_' + i + '_Flow_Percentage__c');
fieldsToQuery.add('Level_' + i + '_Residual_Percentage__c');
}

String fieldsString = String.join(fieldsToQuery, ',');
theQuery = theQuery.replace('x', fieldsString);

System.debug('JTM - theQuery = ' + theQuery);

List<DNE_Commission_Percent__c> commPercList = Database.query(theQuery);

for(DNE_Commission_Percent__c commPerc : commPercList)
{
if( seeAllComPer )
{
commissionPercentIdMap.put(commPerc.Id,commPerc);				
}         
else{
// CommissionType~ContractType 
String theKey = commPerc.Type__c + '~' + commPerc.Contract_Type__c;
if(!commissionPercentMap.containsKey(theKey))
{
commissionPercentMap.put(theKey,commPerc);
}
}
}
System.debug('JTM - commissionPercentMap = ' + commissionPercentMap);
System.debug('JTM - commissionPercentIdMap = ' + commissionPercentIdMap);
}*/
    /*********************************************************
@Name 			: createInvoice
@Parameters 	: List<SBQQ__Subscription__c>:subsList
@Reutrn type 	: List<Invoice__c>
@Description 	: Method for creating invoices corresponding to per subscription;
********************************************************/
    public static List<Invoice__c> createInvoice(List<SBQQ__Subscription__c> subsList){ 
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        for(SBQQ__Subscription__c subs : subsList){
            startDate = subs.SBQQ__StartDate__c;
            if(subs.SBQQ__Contract__r.Payment_Terms__c == '50% Upfront on flow and 50% Residual - Monthly'){
                
                for(Integer i = 0; i <= subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c; i++){
                    inv = new Invoice__c();
                    inv.Subscription__c = subs.id;
                    inv.Site__c = subs.Site__c;
                    inv.Contract__c = subs.SBQQ__Contract__C;
                    inv.Commodity__c = subs.SBQQ__Product__r.family;
                    inv.Expected_Adder__c = subs.Revenue_List_Price__c;
                    inv.Supplier__c = subs.Supplier__c;
                    inv.Contract_Term__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c;
                    inv.Contract_Usage_Volume__c = subs.SBQQ__Quantity__c;
                    inv.Expected_Volume__c = subs.SBQQ__Quantity__c / ( inv.Contract_Term__c / 12 );
                    // This IF true condition code block for checking whether this is upfront invoice or not.
                    if(i==0){
                        if(subs.SBQQ__Contract__r.Discount__c == null){
                            inv.Amount__c = ((subs.SBQQ__Quantity__c * subs.Revenue_List_Price__c)/2).setScale(2, RoundingMode.HALF_UP);
                        }
                        else{
                            inv.Amount__c = (((subs.SBQQ__Quantity__c * subs.Revenue_List_Price__c)/2)*((100-subs.SBQQ__Contract__r.Discount__c)/100)).setScale(2, RoundingMode.HALF_UP);                                 
                        }                        
                        inv.Start_Date__c = startDate;
                        inv.End_Date__c = startDate;
                        inv.Calculation_Type__c = 'Upfront';
                        monthlyInvAmount =  (inv.Amount__c/subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c).setScale(2, RoundingMode.HALF_UP);               
                        subs.Upfront_Amount__c = inv.Amount__c;
                        subs.Residual_Amount__c = monthlyInvAmount;
                    }
                    // This IF false condition code block for remaining invoices except upfront invoice.
                    else{
                        inv.Amount__c = monthlyInvAmount;     
                        inv.Start_Date__c = startDate;
                        inv.End_Date__c = inv.Start_Date__c.addMonths(1).addDays(-1);
                        inv.Calculation_Type__c = 'Residual';
                        startDate = inv.End_Date__c.addDays(1);
                    }
                    invoiceList.add(inv);
                } 
                
            }
            else if(subs.SBQQ__Contract__r.Payment_Terms__c == '100% Residual - Monthly'){ 
                if(subs.SBQQ__Contract__r.Discount__c == null){
                    monthlyInvAmount =  ( ( subs.SBQQ__Quantity__c * subs.Revenue_List_Price__c ) / subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c ).setScale( 2 , RoundingMode.HALF_UP );                               
                }
                else{
                    monthlyInvAmount =  ( ( ( subs.SBQQ__Quantity__c * subs.Revenue_List_Price__c ) * ( ( 100 - subs.SBQQ__Contract__r.Discount__c ) / 100 ) ) / subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c ).setScale( 2 , RoundingMode.HALF_UP );                               
                }
                subs.Residual_Amount__c = monthlyInvAmount;                
                for(Integer i = 0; i < subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c; i++){
                    inv = new Invoice__c();
                    inv.Subscription__c = subs.id;
                    inv.Site__c = subs.Site__c;
                    inv.Contract__c = subs.SBQQ__Contract__C;
                    inv.Commodity__c = subs.SBQQ__Product__r.family;
                    inv.Expected_Adder__c = subs.Revenue_List_Price__c;
                    inv.Supplier__c = subs.Supplier__c;
                    inv.Contract_Term__c = subs.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c;
                    inv.Contract_Usage_Volume__c = subs.SBQQ__Quantity__c;
                    inv.Expected_Volume__c = subs.SBQQ__Quantity__c / ( inv.Contract_Term__c / 12 );
                    inv.Start_Date__c = startDate;
                    inv.End_Date__c = inv.Start_Date__c.addMonths(1).addDays(-1);
                    inv.Calculation_Type__c = 'Residual';
                    startDate = inv.End_Date__c.addDays(1);
                    inv.Amount__c = monthlyInvAmount;
                    invoiceList.add(inv);
                }
            }
            else if(subs.SBQQ__Contract__r.Payment_Terms__c == '50% Upfront, 50% at year 1'){ 
                if(subs.SBQQ__Contract__r.Discount__c == null){
                    monthlyInvAmount =  ((subs.SBQQ__Quantity__c / 12) * (subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 2) );
                }
                else{
                    monthlyInvAmount =  ( ( ( subs.SBQQ__Quantity__c / 12 ) * ( ( 100 - subs.SBQQ__Contract__r.Discount__c ) / 100 ) ) * (subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 2));                               
                }
                subs.Residual_Amount__c = monthlyInvAmount; 
                subs.Upfront_Amount__c = monthlyInvAmount;
                for(Integer i = 0; i < 2; i++){
                    inv = new Invoice__c();
                    inv.Subscription__c = subs.id;
                    inv.Site__c = subs.Site__c;
                    inv.Contract__c = subs.SBQQ__Contract__C;
                    inv.Commodity__c = subs.SBQQ__Product__r.family;
                    inv.Expected_Adder__c = subs.Revenue_List_Price__c;
                    inv.Supplier__c = subs.Supplier__c;
                    inv.Contract_Term__c = subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c;
                    inv.Contract_Usage_Volume__c = subs.SBQQ__Quantity__c;
                    inv.Expected_Volume__c = ((subs.SBQQ__Quantity__c / 12) * (subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 2) );
                    if(i == 0){
                        inv.Start_Date__c = startDate;
                    }else if(i == 1){
                        inv.Start_Date__c = startDate.addMonths(12);
                    }
                    inv.End_Date__c = inv.Start_Date__c.addMonths(1).addDays(-1);
                    inv.Calculation_Type__c = 'Upfront';
                    startDate = inv.End_Date__c.addDays(1);
                    inv.Amount__c = monthlyInvAmount;
                    invoiceList.add(inv);
                }
            }
          /*  else if(subs.SBQQ__Contract__r.Payment_Terms__c == '100% Upfront - Annual'){
                if(subs.SBQQ__Contract__r.Discount__c == null){
                    monthlyInvAmount =  ((subs.SBQQ__Quantity__c / 12) * subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c );
                }
                else{
                    monthlyInvAmount =  ( ( ( subs.SBQQ__Quantity__c / 12 ) * ( ( 100 - subs.SBQQ__Contract__r.Discount__c ) / 100 ) ) * (subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c));                               
                }
                subs.Residual_Amount__c = monthlyInvAmount;  
                subs.Upfront_Amount__c = monthlyInvAmount;
                inv = new Invoice__c();
                inv.Subscription__c = subs.id;
                inv.Site__c = subs.Site__c;
                inv.Contract__c = subs.SBQQ__Contract__C;
                inv.Commodity__c = subs.SBQQ__Product__r.family;
                inv.Expected_Adder__c = subs.Revenue_List_Price__c;
                inv.Supplier__c = subs.Supplier__c;
                inv.Contract_Term__c = subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c;
                inv.Contract_Usage_Volume__c = subs.SBQQ__Quantity__c;
                inv.Expected_Volume__c = ((subs.SBQQ__Quantity__c / 12) * subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c );
                inv.Start_Date__c = startDate;
                inv.End_Date__c = inv.Start_Date__c.addMonths(1).addDays(-1);
                inv.Calculation_Type__c = 'Upfront';
                startDate = inv.End_Date__c.addDays(1);
                inv.Amount__c = monthlyInvAmount;
                invoiceList.add(inv);
            } */
        }
        return invoiceList;
    }
    
    /*********************************************************
@Name 			: createCommissionsforReceiver
@Parameters 	: SBQQ__Subscription__c:sub,String:receiverType,DNE_Commission_Percent__c:thisCommPerc,Boolean secondReceiver
@Reutrn type 	: List<DNE_Commission__c>
@Description 	: This Method is used for the create the commissions for the receiver
********************************************************/
    /*  public static List<DNE_Commission__c> createCommissionsforReceiver(SBQQ__Subscription__c sub, DNE_Commission_Percent__c thisCommPerc, String receiverType, Boolean secondReceiver)
{
List<DNE_Commission__c> commissionsToInsert = new List<DNE_Commission__c>();

Decimal theAmount = sub.SBQQ__Quantity__c * (sub.Adder_Margin__c != null ? sub.Adder_Margin__c : 0);
System.debug('JTM - ===================>>>');
System.debug('JTM - sub.SBQQ__Quantity__c = ' + sub.SBQQ__Quantity__c);
System.debug('JTM - sub.Adder_Margin__c = ' + sub.Adder_Margin__c);
System.debug('JTM - theAmount = ' + theAmount);
if(secondReceiver)
{
theAmount = theAmount/2;
}

Decimal openerCommPerc = thisCommPerc.Opener_Commission_Percentage__c;
Decimal openerTotalCommission = theAmount * openerCommPerc/100;
Decimal openerResidualCommissionAmount = openerTotalCommission * thisCommPerc.Opener_Residual_Percentage__c/100;
Decimal openerFlowCommissionAmount = openerTotalCommission * thisCommPerc.Opener_Flow_Percentage__c/100;
Decimal openerUpfrontCommissionAmount = openerTotalCommission * thisCommPerc.Opener_Upfront_Percentage__c/100;


Decimal receiverCommPerc;
Decimal receiverTotalCommission;
Decimal receiverResidualPercentage;
Decimal receiverResidualCommissionAmount;
Decimal receiverFlowPercentage;
Decimal receiverFlowCommissionAmount;
Decimal receiverUpfrontPercentage;
Decimal receiverUpfrontCommissionAmount;

String receiverTypeInCommissionPercentage = receiverType;
// Level_1_2 - for these situations, "_2" must be removed; special situation: Level_2 must not be changed!
Integer underscore2Index = receiverType.lastIndexOf('_2');
if(underscore2Index>5)
{
receiverTypeInCommissionPercentage = receiverType.substring(0,underscore2Index);
}

receiverCommPerc = Decimal.valueOf(String.valueOf(thisCommPerc.get(receiverTypeInCommissionPercentage + '_Commission_Percentage__c')));
receiverResidualPercentage = Decimal.valueOf(String.valueOf(thisCommPerc.get(receiverTypeInCommissionPercentage + '_Residual_Percentage__c')));
receiverFlowPercentage = Decimal.valueOf(String.valueOf(thisCommPerc.get(receiverTypeInCommissionPercentage + '_Flow_Percentage__c')));
receiverUpfrontPercentage = Decimal.valueOf(String.valueOf(thisCommPerc.get(receiverTypeInCommissionPercentage + '_Upfront_Percentage__c')));
System.debug('JTM - receiverCommPerc = ' + receiverCommPerc);
System.debug('JTM - receiverResidualPercentage = ' + receiverResidualPercentage);
System.debug('JTM - receiverFlowPercentage = ' + receiverFlowPercentage);
System.debug('JTM - receiverUpfrontPercentage = ' + receiverUpfrontPercentage);
System.debug('JTM - <<<===================');

receiverTotalCommission = theAmount * receiverCommPerc/100;
receiverResidualCommissionAmount = receiverTotalCommission * receiverResidualPercentage/100;
receiverFlowCommissionAmount = receiverTotalCommission * receiverFlowPercentage/100;
receiverUpfrontCommissionAmount = receiverTotalCommission * receiverUpfrontPercentage/100;

// only the Max_Payout_Upfront__c amount will be paid Upfront, the rest will be transfered to the Flow
if(receiverUpfrontCommissionAmount > thisCommPerc.Max_Payout_Upfront__c)
{
Decimal difference = receiverUpfrontCommissionAmount - thisCommPerc.Max_Payout_Upfront__c;
receiverUpfrontCommissionAmount = thisCommPerc.Max_Payout_Upfront__c;
receiverFlowCommissionAmount += difference;
}

// DNE_Commission_Hierarchy__r.Level_11__c
//Id receiverId = String.ValueOf(newVersion.get(receiverType + '__c'));
Id receiverId = String.ValueOf(sub.get(receiverType + '__c'));
System.debug('#### Receiver Api name ::: ' + receiverType + '__c');
System.debug('#### ReceiverId ::: ' + receiverId);
//DNE_Commission__c receiverUpfrontCommission = createSingleCommission(receiverUpfrontCommissionAmount, sub.Id, Date.today(), receiverId, receiverType + ' - Upfront');     commented date 16/10/19
DNE_Commission__c receiverUpfrontCommission = createSingleCommission(receiverUpfrontCommissionAmount, sub.Id, sub.SBQQ__Contract__r.DNE_Activation_Date__c, receiverId, receiverType + ' - Upfront');
DNE_Commission__c receiverFlowCommission = createSingleCommission(receiverFlowCommissionAmount, sub.Id, sub.SBQQ__Contract__r.StartDate, receiverId, receiverType + ' - Flow');
//DNE_Commission__c receiverFlowCommission = createSingleCommission(receiverFlowCommissionAmount, sub.Id, sub.SBQQ__Contract__r.DNE_Activation_Date__c, receiverId, receiverType + ' - Flow');    commented date 16/10/19
List<DNE_Commission__c> receiverResidualCommissionList = createReceiverResidualCommissions(receiverResidualCommissionAmount, sub, receiverId, receiverType + ' - Residual');

commissionsToInsert.add(receiverUpfrontCommission);
commissionsToInsert.add(receiverFlowCommission);
commissionsToInsert.addAll(receiverResidualCommissionList);

System.debug('JTM - receiverUpfrontCommission = ' + receiverUpfrontCommission);
System.debug('JTM - receiverFlowCommission = ' + receiverFlowCommission);
System.debug('JTM - receiverResidualCommissionList = ' + receiverResidualCommissionList.size());

/*Integer levelCounter = 1;
for(levelCounter=1; levelCounter<NB_OF_COMMISSION_LEVELS; levelCounter++)
{
String receiverFieldName = 'Level_' + levelCounter + '__c';
String percentageFieldName = 'Level_' + levelCounter + '_Percentage__c';
}*/
    
    /*    return commissionsToInsert;
}
*/
    /*********************************************************
@Name 			: createReceiverResidualCommissions
@Parameters 	: Decimal:amount,SBQQ__Subscription__c:sub,Id:recId,String:typ
@Reutrn type 	: List<DNE_Commission__c>
@Description 	: create receiver commission
********************************************************/
    /*   public static List<DNE_Commission__c> createReceiverResidualCommissions(Decimal amount, SBQQ__Subscription__c sub, Id recId, String typ)
{
List<DNE_Commission__c> residualCommissions = new List<DNE_Commission__c>();
Decimal theTerm = sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Subscription_Term__c;
Decimal monthlyAmount = amount/theTerm;
Id useID;
if(ComissionOwner__c.getOrgDefaults() != null){
ComissionOwner__c usId;
usId = ComissionOwner__c.getOrgDefaults();
useID = usId.User_Id__c;
}
//Id uId = fetchUser(recId);
Id uId = contactUserIdMap.get(recId);
System.debug('uId::'+uId);
for(Integer i=0; i<theTerm; i++)
{
DNE_Commission__c newCommission = new DNE_Commission__c();
newCommission.Amount__c = monthlyAmount;
newCommission.Subscription__c = sub.Id;
// newCommission.Due_Date__c = sub.SBQQ__Contract__r.StartDate.addMonths(i);
newCommission.Due_Date__c = sub.SBQQ__StartDate__c.addMonths(i) ;
newCommission.Receiver__c = recId;
newCommission.Type__c = typ;
if(uId !=null){
newCommission.OwnerId = uId;
}
else{
newCommission.OwnerId = useID;
}

residualCommissions.add(newCommission);
}

return residualCommissions;
}
*/
    /*********************************************************
@Name 			: createSingleCommission
@Parameters 	: pexPages.StandardController
@Reutrn type 	: DNE_Commission__c
@Description 	: Decimal:am,Id:subId,Date:dd,Id:recId,string:typ
********************************************************/
    /*  public static DNE_Commission__c createSingleCommission(Decimal am, Id subId, Date dd, Id recId, String typ){  
Id useID;
if(ComissionOwner__c.getOrgDefaults() != null){
ComissionOwner__c usId;
usId = ComissionOwner__c.getOrgDefaults();
useID = usId.User_Id__c;
}
//Id uId = fetchUser(recId);
Id uId = contactUserIdMap.get(recId);
DNE_Commission__c newCommission = new DNE_Commission__c();
newCommission.Amount__c = am;
newCommission.Subscription__c = subId;
newCommission.Due_Date__c = dd;
newCommission.Receiver__c = recId;
newCommission.Type__c = typ;
if(uId !=null){
newCommission.OwnerId = uId;
}
else{
newCommission.OwnerId = useID;
}

return newCommission;
}
*/
}