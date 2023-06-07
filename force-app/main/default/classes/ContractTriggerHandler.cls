/**************************************************
* Class: ContractTriggerHandler
* Author: Soljit <VW>
* Date: 2019-05-27
* Description: ContractTriggerHandler for Insert transction/invoice for Contract
****************************************************/
public class ContractTriggerHandler {
    public static List<Invoice__c> invoiceList = new List<Invoice__c>();
    //public static Date startDate = System.today();   20/6/2019
    public static Date startDate;
    public static Decimal monthlyInvAmount;
    public static Invoice__c inv;
    public static List<String> newContractTypes = new List<String>{'New Business'};
        public static List<String> renewContractTypes = new List<String>{'Existing Business', 'Renewal'};
            public static List<String> retentionContractTypes = new List<String>{'Retention'};
                public static Map<String,DNE_Commission_Percent__c> commissionPercentMap;
    public static Map<Id,Id> contactUserIdMap;
    public static FINAL Integer NB_OF_COMMISSION_LEVELS = 16;
    public static Map<Id,DNE_Commission_Percent__c> commissionPercentIdMap;
    
    /*********************************************************
@Name 			: generateTransactionInvoice
@Parameters 	: List<Contract>:conList
@Reutrn type 	: void
@Description 	: Method for creating all invoices corresponding to subscriptions;
********************************************************/
    public static void generateTransactionInvoice(List<Contract> conList){
        System.debug('conList is ' + conList);
        List<Invoice__c> tempInvoiceList;
        //List<SBQQ__Subscription__c> 
        Invoice__c inv; 
        List<SBQQ__Subscription__c> subscList = new List<SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c subscriptionCon : [Select id,Supplier__c,Site__c,SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c,SBQQ__ProductName__c,SBQQ__Product__r.family,Name,SBQQ__StartDate__c,IsAmended__c,IsNew__c,
                                                     SBQQ__EndDate__c,SBQQ__Contract__r.name,SBQQ__Contract__r.Discount__c,SBQQ__Contract__r.ContractTerm,Revenue_List_Price__c,
                                                     SBQQ__Quantity__c,SBQQ__ListPrice__c,Adder_Margin__c,SBQQ__Contract__r.SBQQ__Opportunity__c,SBQQ__Contract__r.Payment_Terms__c
                                                     From SBQQ__Subscription__c Where  SBQQ__Contract__c IN:conList AND Site__c != null]){                                                         
                                                         subscList.add(subscriptionCon);                                                                                      
                                                     }
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
                for(Integer i = 0; i <= subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c.round(System.RoundingMode.CEILING); i++){
                    inv = new Invoice__c();
                    inv.Subscription__c = subs.id;
                    inv.Site__c = subs.Site__c;
                    inv.Contract__c = subs.SBQQ__Contract__C;
                    inv.Commodity__c = subs.SBQQ__Product__r.family;
                    inv.Expected_Adder__c = subs.Revenue_List_Price__c;
                    inv.Supplier__c = subs.Supplier__c;
                    inv.Contract_Term__c = subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c;
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
                        monthlyInvAmount =  (inv.Amount__c/subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c).setScale(2, RoundingMode.HALF_UP);               
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
                    monthlyInvAmount =  ( ( subs.SBQQ__Quantity__c * subs.Revenue_List_Price__c ) / subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c ).setScale( 2 , RoundingMode.HALF_UP );                               
                }
                else{
                    monthlyInvAmount =  ( ( ( subs.SBQQ__Quantity__c * subs.Revenue_List_Price__c ) * ( ( 100 - subs.SBQQ__Contract__r.Discount__c ) / 100 ) ) / subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c ).setScale( 2 , RoundingMode.HALF_UP );                               
                }
                subs.Residual_Amount__c = monthlyInvAmount; 
                for(Integer i = 0; i < subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c; i++){
                    inv = new Invoice__c();
                    inv.Subscription__c = subs.id;
                    inv.Site__c = subs.Site__c;
                    inv.Contract__c = subs.SBQQ__Contract__C;
                    inv.Commodity__c = subs.SBQQ__Product__r.family;
                    inv.Expected_Adder__c = subs.Revenue_List_Price__c;
                    inv.Supplier__c = subs.Supplier__c;
                    inv.Contract_Term__c = subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c;
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
                    monthlyInvAmount = ((subs.SBQQ__Quantity__c / 12) * (subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 2) );
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
                    inv.Calculation_Type__c = 'Upfront';
                    }else if(i == 1){
                        inv.Start_Date__c = startDate.addMonths(12);
                        inv.Calculation_Type__c = 'Residual';
                    }
                    inv.End_Date__c = inv.Start_Date__c.addMonths(1).addDays(-1);
                    
                    startDate = inv.End_Date__c.addDays(1);
                    inv.Amount__c = monthlyInvAmount;
                    invoiceList.add(inv);
                }
            }
           /* else if(subs.SBQQ__Contract__r.Payment_Terms__c == '100% Upfront - Annual'){
                if(subs.SBQQ__Contract__r.Discount__c == null){
                    monthlyInvAmount =  ((subs.SBQQ__Quantity__c / 12) * subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c );
                }
                else{
                    monthlyInvAmount =  ( ( ( subs.SBQQ__Quantity__c / 12 ) * ( ( 100 - subs.SBQQ__Contract__r.Discount__c ) / 100 ) ) * subs.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c );                               
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
@Name 			: createDNECommissions
@Parameters 	: 
@Reutrn type 	: void
@Description 	: after insert, after update
********************************************************/
 /*  public static void createDNECommissions(Map <ID, Contract> newContract, Map <Id, Contract> OldContract, Boolean isUpdate, Boolean isInsert)
    {
        List<DNE_Commission__c> commissionToInsertList = new List<DNE_Commission__c>();
        
        List<DNE_Commission__c> allCommissions = new List<DNE_Commission__c>();
        
        Set<Id> contractsJustActivatedIdList = new Set<Id>();
        
        Set<id> relatedContactIdSet = new Set<id>();
        
        for (Contract newVersion : newContract.Values()) 
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
        }
        System.debug('### contractsJustActivatedIdList.size() ::: ' + contractsJustActivatedIdList.size());
        System.debug('### contractsJustActivatedIdList ::: ' + contractsJustActivatedIdList);
        
        if(contractsJustActivatedIdList.size() > 0){
            //Calling method for populate Commission Hierarchy lookup on contract.
            populateCommissionHierarchy(contractsJustActivatedIdList);
            
            //Calling method for populate Commission Percent lookup and update DNE_Activation_Date__c on contract.
            populateCommissionPercent(contractsJustActivatedIdList);            
        }
        
        List<SBQQ__Subscription__c> relatedSubscriptionList = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__ListPrice__c, Adder_Margin__c, Opener__c, Closer__c, Opener_2__c, Closer_2__c, 
            Level_1__c, Level_2__c, Level_3__c, Level_4__c, 
            Level_5__c, Level_6__c, Level_7__c, Level_8__c, 
            Level_9__c, Level_10__c, Level_11__c, Level_12__c, 
            Level_13__c, Level_14__c, Level_15__c, Level_16__c,
            Level_1_2__c, Level_2_2__c, Level_3_2__c, Level_4_2__c, 
            Level_5_2__c, Level_6_2__c, Level_7_2__c, Level_8_2__c, 
            Level_9_2__c, Level_10_2__c, Level_11_2__c, Level_12_2__c, 
            Level_13_2__c, Level_14_2__c, Level_15_2__c, Level_16_2__c,
            SBQQ__Contract__c,SBQQ__StartDate__c,
            SBQQ__Contract__r.Opportunity_Type__c, 
            SBQQ__Contract__r.SBQQ__Opportunity__r.Closer__c, 
            SBQQ__Contract__r.SBQQ__Opportunity__r.Opener__c,
            SBQQ__Contract__r.SBQQ__Opportunity__r.Subscription_Term__c, 
            SBQQ__Contract__r.SBQQ__Opportunity__r.Type, 
            SBQQ__Contract__r.StartDate,SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c,
            SBQQ__Contract__r.DNE_Activation_Date__c,
            SBQQ__Contract__r.DNE_Commission_Percent__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Contract__c IN :contractsJustActivatedIdList AND IsAmended__c = False
        ];
        
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
            
            /*String subsType = 'New';
if(renewContractTypes.contains(relatedSub.SBQQ__Contract__r.SBQQ__Opportunity__r.Type))
{
subsType = 'Renewal';
}
else if(retentionContractTypes.contains(relatedSub.SBQQ__Contract__r.SBQQ__Opportunity__r.Type))
{
subsType = 'Retention';
}
*/
  /*          String subsType = relatedSub.SBQQ__Contract__r.SBQQ__Opportunity__r.Type;
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
                Contract parentContract = newContract.get(relatedSub.SBQQ__Contract__c);
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
@Name 			: createCommissionsforReceiver
@Parameters 	: SBQQ__Subscription__c:sub,String:receiverType,DNE_Commission_Percent__c:thisCommPerc,Boolean secondReceiver
@Reutrn type 	: List<DNE_Commission__c>
@Description 	: This Method is used for the create the commissions for the receiver
********************************************************/
 /*   public static List<DNE_Commission__c> createCommissionsforReceiver(SBQQ__Subscription__c sub, DNE_Commission_Percent__c thisCommPerc, String receiverType, Boolean secondReceiver)
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
        DNE_Commission__c receiverFlowCommission = createSingleCommission(receiverFlowCommissionAmount, sub.Id, sub.SBQQ__StartDate__c, receiverId, receiverType + ' - Flow');
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
        
   /*     return commissionsToInsert;
    }
    */
    /*********************************************************
@Name 			: createReceiverResidualCommissions
@Parameters 	: Decimal:amount,SBQQ__Subscription__c:sub,Id:recId,String:typ
@Reutrn type 	: List<DNE_Commission__c>
@Description 	: create receiver commission
********************************************************/
  /*  public static List<DNE_Commission__c> createReceiverResidualCommissions(Decimal amount, SBQQ__Subscription__c sub, Id recId, String typ)
    {
        List<DNE_Commission__c> residualCommissions = new List<DNE_Commission__c>();
        Decimal theTerm = sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c;
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
            newCommission.Due_Date__c = sub.SBQQ__StartDate__c.addMonths(i);
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
    /*********************************************************
@Name 			: createCommissionPercentageMap
@Parameters 	: pexPages.StandardController
@Reutrn type 	: void
@Description 	: create commission percentage
********************************************************/
    public static void createCommissionPercentageMap(Boolean seeAllComPer){
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
    }
    
    /*********************************************************
@Name 			: fetchUser
@Parameters 	: 
@Reutrn type 	: Id
@Description 	: To fetch active internal user who has the same email address as the contact for the commission
********************************************************/
 /*   public static void fetchUser(Set<Id> conIdSet){
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
@Name 			: populateCommissionHierarchy
@Parameters 	: 
@Reutrn type 	: void
@Description 	: To populate commission Hierarchy
********************************************************/
    public static void populateCommissionHierarchy(Set<Id> contractsActivatedIdList)
    {
        System.debug('JTM - calling populateCommissionHierarchy()');
        
        Map<Id,Contract> contractMap;
        List<Contract> contractUpdateList = new List<Contract>();
        contractMap = new Map<Id,Contract>([SELECT Id, 
                                            Selling_Price__c, 
                                            Type__c, 
                                            StartDate,
                                            DNE_Commission_Hierarchy__c,
                                            DNE_Commission_Hierarchy_2__c,
                                            SBQQ__Opportunity__r.Opener__c,
                                            SBQQ__Opportunity__r.Opener__r.name,
                                            SBQQ__Opportunity__r.Closer__c,  
                                            SBQQ__Opportunity__r.Opener_2__c, 
                                            SBQQ__Opportunity__r.Opener_2__r.name,
                                            SBQQ__Opportunity__r.Closer_2__c,
                                            SBQQ__Opportunity__r.Subscription_Term__c
                                            FROM Contract
                                            WHERE ID IN : contractsActivatedIdList]);
        
        System.debug('JTM - contractMap = ' + contractMap);
        
        Set<Id> openerIdSet = new Set<Id>();
        for(Contract cont : contractMap.values())
        {		
            if(cont.SBQQ__Opportunity__r.Opener__c != null)
            {
                openerIdSet.add(cont.SBQQ__Opportunity__r.Opener__c);
            }
            if(cont.SBQQ__Opportunity__r.Opener_2__c != null)
            {
                openerIdSet.add(cont.SBQQ__Opportunity__r.Opener_2__c);
            }
        }
        
        if(openerIdSet.isEmpty())
        {
            System.debug('ContractTriggerHandler.populateCommissionHierarchy() - NO OPENER WAS FOUND for these Contracts.');
            return;
        }
        
        Datetime todayDateTime = Datetime.now();
        
        List<DNE_Commission_Hierarchy__c> commissionHierarchyList = 
            [SELECT Id, Type__c, Opener__c
             FROM DNE_Commission_Hierarchy__c
             WHERE Opener__c IN :openerIdSet
             AND Effective_From__c < :todayDateTime
             ORDER BY Effective_From__c DESC];
        
        System.debug('JTM - commissionHierarchyList = ' + commissionHierarchyList);
        
        if(commissionHierarchyList.isEmpty())
        {
            System.debug('ERROR in ContractTriggerHandler.populateCommissionHierarchy() - no Commission Hierarchy found.');
            return;
        }
        
        // the key = Opener__c~Type__c (ex: 0030q00000OYa8h~Renewal)
        Map<String, DNE_Commission_Hierarchy__c> commissionMap = new Map<String, DNE_Commission_Hierarchy__c>();
        
        for(DNE_Commission_Hierarchy__c commHier : commissionHierarchyList)
        {
            String theKey = commHier.Opener__c + '~' + commHier.Type__c;
            if(!commissionMap.containsKey(theKey))
            {
                commissionMap.put(theKey, commHier);
            }
        }
        
        Contract newCon;
        for(Contract con : contractMap.values())
        {            
            Boolean contractUpdate = false;
            System.debug('JTM - Contract = ' + con);
            newCon = new Contract();
            newCon.Id = con.Id;
            String contractType = con.Type__c;
            /*if(newContractTypes.contains(con.Type__c))
{
contractType = 'New';
}
else if(renewContractTypes.contains(con.Type__c))
{
contractType = 'Renewal';
}
else if(retentionContractTypes.contains(con.Type__c))
{
contractType = 'Retention';
}*/
            
            if(con.DNE_Commission_Hierarchy__c == null){
                String contractKey1 = con.SBQQ__Opportunity__r.Opener__c + '~' + contractType;
                
                System.debug('JTM - contractKey1 = ' + contractKey1);
                
                DNE_Commission_Hierarchy__c relatedCommHier1 = commissionMap.get(contractKey1);
                
                System.debug('JTM - relatedCommHier1 = ' + relatedCommHier1);
                
                if(relatedCommHier1==null)
                {
                    String errorMessage = System.Label.Commission_Hierarchy_Record_Label + con.SBQQ__Opportunity__r.Opener__r.name;
                    errorMessage += ') and Contract Type (' + contractType + ')';
                    System.debug('ERROR : ' + errorMessage);
                    //con.addError(Label.No_Commission_Error_found);
                }
                else
                {
                    //con.DNE_Commission_Hierarchy__c = relatedCommHier1.Id;
                    newCon.DNE_Commission_Hierarchy__c = relatedCommHier1.Id;
                    contractUpdate = true;
                }                
            }
            if(con.DNE_Commission_Hierarchy_2__c == null){
                String contractKey2 = con.SBQQ__Opportunity__r.Opener_2__c + '~' + contractType;
                
                System.debug('JTM - contractKey2 = ' + contractKey2);
                
                DNE_Commission_Hierarchy__c relatedCommHier2 = commissionMap.get(contractKey2);
                
                System.debug('JTM - relatedCommHier2 = ' + relatedCommHier2);
                
                if(relatedCommHier2==null)
                {
                    String errorMessage = System.Label.Commission_Hierarchy_Record_Label + con.SBQQ__Opportunity__r.Opener_2__r.name;
                    errorMessage += ') and Contract Type (' + contractType + ')';
                    System.debug('ERROR : ' + errorMessage);
                    //con.addError(Label.No_Commission_Error_found);
                }
                else
                {
                    //con.DNE_Commission_Hierarchy_2__c = relatedCommHier2.Id;
                    newCon.DNE_Commission_Hierarchy_2__c = relatedCommHier2.Id;
                    contractUpdate = true;
                }                
            }
            //Check if Comission Hierarchy found then update on contract
            if(contractUpdate){
                contractUpdateList.add(newCon);
            }
        }
        System.debug('JTM - contractUpdateList.size() = ' + contractUpdateList.size());        
        System.debug('JTM - contractUpdateList = ' + contractUpdateList);        
        if(contractUpdateList.size()>0){
            UPDATE contractUpdateList;
            System.debug('#### Contract updated successfully.');            
        }
    }
    
    /*********************************************************
@Name 			: populateCommissionPercent
@Parameters 	: 
@Reutrn type 	: void
@Description 	: To populate commission percent and update DNE_Activation_Date__c.
********************************************************/
    public static void populateCommissionPercent(Set<Id> contractsActivatedIdList){
        System.debug('JTM - calling populateCommissionPercent()');
        
        List<Contract> activatedContractUpdateList = new List<Contract>();
        
        createCommissionPercentageMap(false);
        
        for(Contract cont : [SELECT Id,
                             StartDate,
                             DNE_Activation_Date__c,
                             ActivatedDate,
                             DNE_Commission_Percent__c,
                             Opportunity_Type__c,
                             SBQQ__Opportunity__r.Type
                             FROM Contract
                             WHERE ID IN : contractsActivatedIdList])
        {
            Contract con = new Contract();
            Boolean contractUpdate = false;
            
            // This condition update contract DNE_Activation_Date__c field only when contract is activated and DNE_Activation_Date__c field value is null. 
            System.debug('cont.DNE_Activation_Date__c ::: ' + cont.DNE_Activation_Date__c);
            if(cont.DNE_Activation_Date__c == null && cont.ActivatedDate != null){
                con.DNE_Activation_Date__c = cont.ActivatedDate.date();
                contractUpdate = true;
            }
            
            if(cont.DNE_Commission_Percent__c == null){
                /*String subsType = 'New';
if(renewContractTypes.contains(cont.SBQQ__Opportunity__r.Type))
{
subsType = 'Renewal';
}
else if(retentionContractTypes.contains(cont.SBQQ__Opportunity__r.Type))
{
subsType = 'Retention';
}*/
                
                String subsType = cont.SBQQ__Opportunity__r.Type;
                String contractType;
                if(cont.Opportunity_Type__c == ConstantString.VARIABLE_TYPE)
                {
                    contractType = 'Index';
                }
                else
                {
                    if(cont.StartDate <= Date.today().addMonths(12))
                    {
                        contractType = 'Fixed within 12 months';
                    }
                    else
                    {
                        contractType = 'Fixed after 12 months';
                    }
                }
                
                String subsKey = subsType + '~' + contractType;
                if(commissionPercentMap.containsKey(subsKey)){
                    con.DNE_Commission_Percent__c = commissionPercentMap.get(subsKey).Id;
                    contractUpdate = true;                        
                }
            } 
            
            //Check if Comission percent found then update on contract
            if(contractUpdate){
                con.Id = cont.Id;
                activatedContractUpdateList.add(con);
            }
        }
        System.debug('### activatedContractUpdateList.size() ::: ' + activatedContractUpdateList.size());
        if(activatedContractUpdateList.size()>0){
            UPDATE activatedContractUpdateList;
            System.debug('### Contract updated successfully.');
        }
        
    }
    //For renewal Opportunity
    /*********************************************************
@Name 			: renewalOpportunityUpdate
@Parameters 	: list of contracts
@Reutrn type 	: void
@Description 	: to update opportunity and create respective opportunity Sites
********************************************************/
    public static void renewalOpportunityUpdate(Map<Id, Contract> conMap){
        Map<Id,Id> ContractOppMap = new Map<Id,Id>();
        Map<Id,Opportunity> renewalOppInsertMap = new Map<Id,Opportunity>();
        
        System.debug('conMap::'+conMap);
        for(Contract con : conMap.values())
        {
            ContractOppMap.put(con.SBQQ__Opportunity__c, con.Id);
        }
        System.debug('ContractOppMap::'+ContractOppMap.values());
        
        Opportunity oppRen;
        For(Opportunity opp :[Select id,account.name,Supplier__c,Supplier_Price__c,
                              Commodity_Type__c,Flow_Date__c,Margin__c,Market__c,Pricebook2Id,
                              Month_Year__c,Opportunity_Site__c,Product_of_Choice__c,RecordtypeId,
                              Selling_Price__c,Subscription_Term__c,DNE_Admin_Fee__c 
                              From opportunity Where id IN:ContractOppMap.keyset()])
        {
            
            oppRen = new Opportunity();    
            oppRen.Name = (opp.account.name +'-'+String.valueOf(opp.Flow_Date__c.addMonths(Integer.valueof(opp.Subscription_Term__c)))).Left(110) +' - Renewal';              
            oppRen.AccountId = opp.AccountId;
            oppRen.Commodity_Type__c = opp.Commodity_Type__c;
            oppRen.Margin__c = opp.Margin__c;
            oppRen.Market__c = opp.Market__c;
            oppRen.Type = 'Renewal';
            oppRen.StageName = 'Qualification';
            oppRen.Closedate = conMap.get(ContractOppMap.get(opp.id)).EndDate;
            oppRen.Flow_Date__c = conMap.get(ContractOppMap.get(opp.id)).EndDate.addDays(1);
            oppRen.Selling_Price__c = opp.Selling_Price__c;
            oppRen.Product_of_Choice__c = opp.Product_of_Choice__c;
            oppRen.Subscription_Term__c = opp.Subscription_Term__c;
            oppRen.Supplier__c = opp.Supplier__c;
            oppRen.Supplier_Price__c = opp.Supplier_Price__c;
            oppRen.DNE_Admin_Fee__c = opp.DNE_Admin_Fee__c;
            oppRen.Pricebook2Id = opp.Pricebook2Id;
            oppren.RecordtypeId = opp.RecordTypeId;
            oppRen.RenewalContractId__c = ContractOppMap.get(opp.id);
            renewalOppInsertMap.put(ContractOppMap.get(opp.id),oppRen);
        }
        System.debug('#### renewalOppInsertMap.size() :: ' + renewalOppInsertMap.size()); 
        if(renewalOppInsertMap.size() > 0 ){
            // DML statement
            Database.SaveResult[] srList = Database.insert(renewalOppInsertMap.values(), false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('The fields that affected this error: ' + err.getFields());
                    }
                }
            }//End of for loop 
        }
        
        
         System.debug('#### renewalOppInsertMap.size() :: ' + renewalOppInsertMap);
        try{  
            
            List<Opportunity_Site__c> oppSiteList = new List<Opportunity_Site__c>();
            Opportunity_Site__c oppSite;
            for(SBQQ__Subscription__c subs : [SELECT Id, SBQQ__Quantity__c, SBQQ__ListPrice__c,
                                              SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Subscription_Term__c,
                                              Adder_Margin__c, Site__r.Market__c,Site__c,Annual_Volume__c,
                                              SBQQ__Contract__c,SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,SBQQ__StartDate__c 
                                              FROM SBQQ__Subscription__c
                                              WHERE SBQQ__Contract__c IN : ContractOppMap.values() AND Site__c != null ])
            {
                oppSite = new Opportunity_Site__c();
                oppsite.Market__c = subs.Site__r.Market__c;
                oppsite.Site__c = subs.Site__c;
                oppsite.Opportunity__c = renewalOppInsertMap.get(subs.SBQQ__Contract__c).Id;
                oppsite.Contract__c = subs.SBQQ__Contract__c;
                oppsite.Adder__c = subs.Adder_Margin__c;
                oppsite.Quantity__c = subs.Annual_Volume__c*(renewalOppInsertMap.get(subs.SBQQ__Contract__c).Subscription_Term__c/12);
                OppSiteList.add(oppsite);
                system.debug('oppsite.Quantity__c ::::: ' + oppsite.Quantity__c );
            }
            
            if(OppSiteList.size() > 0){
                INSERT OppSiteList;
            }   
            for(Id conId : renewalOppInsertMap.keyset()){
                conMap.get(conId).SBQQ__RenewalOpportunity__c = renewalOppInsertMap.get(conId).Id;
            }
        }catch( Exception ex){
            system.debug('Exception Occured While Saving Record:::::::'+ex.getMessage());
        }
        
        // Create Opportunity Site for above opportunities
        /* List<Opportunity_Site__c> oppSiteList = new List<Opportunity_Site__c>();
Opportunity_Site__c oppNewSite;
For(Opportunity_Site__c oppSite : [Select id,name,Site__c,Opportunity__c,Market__c,Contract__c,Flag__c 
From Opportunity_Site__c Where Opportunity__c IN:renewalOppMap.keySet()]) {

oppNewSite = new Opportunity_Site__c();
oppNewSite.Opportunity__c =renewalOppMap.get(oppSite.Opportunity__c) ;
oppNewSite.Market__c = oppSite.Market__c;
oppNewSite.Site__c = oppSite.Site__c;
oppNewSite.Flag__c = true;
oppSiteList.add(oppNewSite);
}
System.debug('oppSiteList.size()::'+oppSiteList.size());
if(oppSiteList.size()>0){
// DML statement
Database.SaveResult[] srList = Database.insert(oppSiteList, false);
for (Database.SaveResult sr : srList) {
if (!sr.isSuccess()){
// Operation failed, so get all errors                
for(Database.Error err : sr.getErrors()) {
System.debug('The following error has occurred.');                    
System.debug(err.getStatusCode() + ': ' + err.getMessage());
System.debug('The fields that affected this error: ' + err.getFields());
}
}
}//End of for loop 
}// End of update condition */
    }
    
    /*********************************************************
@Name 			: updateReveneuAndCommission
@Parameters 	: list of contracts
@Reutrn type 	: void
@Description 	: On update of DNE Admin Fee ( DNE Adder) Or Adder
update Invoice( Reveneu)and Commission
********************************************************/
    public static void updateReveneuAndCommission(Map<ID,Contract> oldMap,Map<ID,Contract> newMap ){
        Map<Id,Contract> filteredContract = new Map<Id,Contract>();
        List<SBQQ__Subscription__c> updateSubscriptions = new List<SBQQ__Subscription__c>();
        boolean isAdded = false;      
        for(ID conId : newMap.keySet()){
            //check if Any Adder Change Adder_Margin__c ,DNE_Admin_Fee__c 
            if((oldMap.get(conId).Adder_Margin__c != newMap.get(conId).Adder_Margin__c)
               || oldMap.get(conId).DNE_Admin_Fee__c != newMap.get(conId).DNE_Admin_Fee__c){
                   filteredContract.put(conId,newMap.get(conId)); 
               }
            
        }
        
        
        for(SBQQ__Subscription__c subscriptionCon : [Select id,Adder_Margin__c ,DNE_Admin_Fee__c, SBQQ__Contract__c
                                                     From SBQQ__Subscription__c Where  SBQQ__Contract__c IN:filteredContract.keySet() AND Site__c != null])
        {
            isAdded = false;   
            if(subscriptionCon.Adder_Margin__c != filteredContract.get(subscriptionCon.SBQQ__Contract__c).Adder_Margin__c){
                subscriptionCon.Adder_Margin__c = filteredContract.get(subscriptionCon.SBQQ__Contract__c).Adder_Margin__c;  
                isAdded = true;   
            } 
            if(subscriptionCon.DNE_Admin_Fee__c != filteredContract.get(subscriptionCon.SBQQ__Contract__c).DNE_Admin_Fee__c){
                subscriptionCon.DNE_Admin_Fee__c = filteredContract.get(subscriptionCon.SBQQ__Contract__c).DNE_Admin_Fee__c;
                isAdded = true;   
            }
            if(isAdded ){
                updateSubscriptions.add(subscriptionCon);  
            }                                                                                      
        }
        //check for updateSubscriptions has records
        if(updateSubscriptions.size() > 0){
            update updateSubscriptions;
        }
    }
    
    /*********************************************************
@Name 			: populateReveneuAndCommission
@Parameters 	: list of contracts
@Reutrn type 	: void
@Description 	: Populate DNE Admin Fee ( DNE Adder) Or Adder
update Invoice( Reveneu)and Commission
********************************************************/
    public static void populateReveneuAndCommission(List<Contract> contractList ){
        Map<ID,Contract> oppIdContractMap = new Map<ID,Contract>();  
        for(Contract con : contractList){
            oppIdContractMap.put(con.SBQQ__Opportunity__c,con);  
        }
        for(Opportunity opp :[Select Id,Margin__c , DNE_Admin_Fee__c,Total_Volume__c,Amount 
                              From Opportunity 
                              Where Id IN: oppIdContractMap.keySet()])
        {
            if(oppIdContractMap.containsKey(opp.Id)){
                oppIdContractMap.get(opp.Id).Adder_Margin__c = opp.Margin__c;
                oppIdContractMap.get(opp.Id).DNE_Admin_Fee__c = opp.DNE_Admin_Fee__c;
                oppIdContractMap.get(opp.Id).CurrentVolume__c = opp.Total_Volume__c;
                oppIdContractMap.get(opp.Id).CurrentAmount__c = opp.Amount;
            }
        }
    }
    
    /*********************************************************
@Name 			: createAmendmentOpp
@Parameters 	: list of cancelled contracts
@Reutrn type 	: void
@Description 	: 
********************************************************/
    public static void createAmendmentOpp(Map<Id,Contract> contractMap ){
        List<opportunity> amendmentOppList = new List<opportunity>();
        Map<Id, Opportunity> amendmentOppMap = new Map<Id, Opportunity>();
        Map<Id, List<SBQQ__Subscription__c>> conWithSubscription = new Map<Id, List<SBQQ__Subscription__c>>(); //Getting Contract Id as key
        Map<Contract, Opportunity> amendmentOppConMap = new Map<Contract, Opportunity>();
        List<Opportunity_Site__c> newOppSite = new List<Opportunity_Site__c>();
        Map<Id, Id> conIdRenewalOppMap = new Map<Id, Id>();
        
        System.debug('contractMap ::::'+contractMap);
        System.debug('contractMap ::::'+contractMap.size());
        
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        for(Contract con: [SELECT Id, SBQQ__Opportunity__r.Name, SBQQ__Opportunity__r.Pricebook2Id,ContractTerm,
                           AccountId, Account.Name, Account.Primary_Contact__c,DateofCancellation__c,SBQQ__Opportunity__r.Closer__c,
                           SBQQ__Opportunity__r.Market__c, SBQQ__Opportunity__r.Commodity_Type__c,SBQQ__Opportunity__r.Opener__c,
                           SBQQ__Opportunity__r.Type, SBQQ__Opportunity__r.Supplier__c,SBQQ__Opportunity__r.Supplier_Price__c,
                           SBQQ__Opportunity__r.Selling_Price__c,SBQQ__Opportunity__r.Admin_Fee__c,StartDate,
                           SBQQ__Opportunity__r.Month_Year__c,SBQQ__Opportunity__r.Margin__c,SBQQ__RenewalOpportunity__c,
                           SBQQ__Opportunity__r.DNE_Admin_Fee__c, SBQQ__Opportunity__r.Product_of_Choice__c  
                           FROM Contract Where Id IN: contractMap.Keyset()])
        {
            
            Opportunity opp = new Opportunity();
            opp.Name = (con.Account.Name != null?'Amendment Cancelled Opportunity'+' '+ con.Account.Name + '-' + String.valueOf(System.today()):'Amendment Cancelled Opportunity'+ '-' + String.valueOf(System.today())).Left(120); 
            System.debug(' opp.Name:::::' +  opp.Name);
            opp.CloseDate = System.today();
            opp.RecordTypeId = recordTypeId;
            opp.Main_Opportunity__c = con.SBQQ__Opportunity__c;  
            opp.Pricebook2Id = con.SBQQ__Opportunity__r.Pricebook2Id;
            opp.AccountId = con.AccountId;
            opp.StageName = 'Proposal';    
            opp.Subscription_Term__c = calculateRemainingTerm(con.StartDate,con.DateofCancellation__c, con.ContractTerm);
            opp.Market__c = con.SBQQ__Opportunity__r.Market__c;
            opp.Commodity_Type__c = con.SBQQ__Opportunity__r.Commodity_Type__c;
            opp.Type = con.SBQQ__Opportunity__r.Type;
            opp.Product_of_Choice__c = con.SBQQ__Opportunity__r.Product_of_Choice__c;
            opp.Flow_Date__c = con.DateofCancellation__c;
            opp.Supplier__c = con.SBQQ__Opportunity__r.Supplier__c;
            opp.Supplier_Price__c = con.SBQQ__Opportunity__r.Supplier_Price__c;
            opp.Selling_Price__c = con.SBQQ__Opportunity__r.Selling_Price__c;
            opp.DNE_Admin_Fee__c = con.SBQQ__Opportunity__r.DNE_Admin_Fee__c;
            opp.Month_Year__c = con.SBQQ__Opportunity__r.Month_Year__c;
            opp.Margin__c = con.SBQQ__Opportunity__r.Margin__c;
            opp.Opener__c = con.SBQQ__Opportunity__r.Opener__c;
            opp.Closer__c = con.SBQQ__Opportunity__r.Closer__c;
            opp.Cancelled__c = true;
            //amendmentOppList.add(opp);
            amendmentOppConMap.put(con, opp);
            if(con.SBQQ__RenewalOpportunity__c != null){
                conIdRenewalOppMap.put(con.Id,con.SBQQ__RenewalOpportunity__c);                            
            }
        }
        
        
        
        //Insert amendmentOppList;
        Database.SaveResult[] srList = Database.insert(amendmentOppConMap.values());
        
        for(SBQQ__Subscription__c sub: [SELECT Id, SBQQ__Contract__r.SBQQ__Opportunity__c,Annual_Volume__c,
                                        SBQQ__StartDate__c,Term_in_month__c,Adder_Margin__c,
                                        Site__c, SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__Contract__r.DateofCancellation__c 
                                        FROM SBQQ__Subscription__c 
                                        WHERE SBQQ__Contract__c IN: contractMap.Keyset() AND Site__c != null])
        {
            if(!conWithSubscription.containsKey(sub.SBQQ__Contract__c)){
                conWithSubscription.put(sub.SBQQ__Contract__c, new List<SBQQ__Subscription__c>());
            }
            conWithSubscription.get(sub.SBQQ__Contract__c).add(sub);
        }
        
        for(Contract con: amendmentOppConMap.keyset()){
            for(SBQQ__Subscription__c sub: conWithSubscription.get(con.Id)){
                Opportunity_Site__c oppSite = new Opportunity_Site__c();
                oppSite.Opportunity__c = amendmentOppConMap.get(con).Id;
                oppSite.Market__c = amendmentOppConMap.get(con).Market__c;
                oppSite.Site__c = sub.Site__c;
                oppSite.Flag__c = true;
                newOppSite.add(oppSite);
            }
        }
        
        insert newOppSite;
        
        
        createQuote(amendmentOppConMap, conWithSubscription);
        for(Opportunity opp : amendmentOppConMap.values()){
            opp.StageName = 'Activate Change';   
        }
        System.debug('amendmentOppConMap ::: ' + amendmentOppConMap);
        UPDATE amendmentOppConMap.values();
        List<Opportunity> renewalOppUpdateList = new List<Opportunity>();
        for(Id renewalOppId : conIdRenewalOppMap.values()){
            Opportunity renewalOpp = new Opportunity(Id = renewalOppId, StageName = 'Closed Lost'); 
            renewalOppUpdateList.add(renewalOpp);
        }
        if(renewalOppUpdateList.size() > 0){
            UPDATE renewalOppUpdateList;
        }
    }
    
    public static Decimal calculateRemainingTerm(Date conStartDate, Date amendFlowDate, Decimal subscriptionTerm){
        Decimal termRemaining = 0;
        if(conStartDate < amendFlowDate){
            system.debug('opp Flow Date :::'+conStartDate);
            decimal monthDiff = conStartDate.monthsBetween(amendFlowDate);
            Integer daysEnd = Date.daysInMonth(amendFlowDate.year(), amendFlowDate.month());
            Decimal day_s = conStartDate.day();
            Decimal day_e = amendFlowDate.day();
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
@Name 			: createQuote
@Parameters 	: 
@Reutrn type 	: void
@Description 	: 
********************************************************/
    public static void createQuote(Map<Contract,Opportunity> amendmentOppConMap, Map<Id, List<SBQQ__Subscription__c>> conWithSub){
        Map<Id,SBQQ__Quote__c> amdQuote = new Map<Id,SBQQ__Quote__c>();
        Set<Id> quoteIds = new Set<Id>();
        for(Contract con: amendmentOppConMap.Keyset()){
            SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
            newQuote.SBQQ__Opportunity2__c = amendmentOppConMap.get(con).Id;
            newQuote.SBQQ__Primary__c = true;
            
            newQuote.SBQQ__PricebookId__c = amendmentOppConMap.get(con).Pricebook2Id;
            //newQuote.margin__c = opp.margin__c;
            //newQuote.Administration_Fee__c = opp.Admin_Fee__c;
            newQuote.Primary_Contact__c = con.AccountId != null ? con.Account.Primary_Contact__c : null;
            newQuote.Billing_Contact__c = con.AccountId != null ? con.Account.Primary_Contact__c : null;
            //newQuote.Supplier_Price__c = opp.Supplier_Price__c;
            //newQuote.Supplier__c = opp.Supplier__c;
            //newQuote.Selling_Price__c = opp.Selling_Price__c;        
            newQuote.SBQQ__MasterContract__c = con.Id;
            
            amdQuote.put(con.Id, newQuote);
        }
        
        Database.SaveResult[] srList = Database.insert(amdQuote.values());
        createQLIs(amdQuote ,conWithSub);
        
    }
    
    /*********************************************************
@Name 			: createQLIs
@Parameters 	: 
@Reutrn type 	: void
@Description 	: 
********************************************************/
    public static void createQLIs(Map<Id, SBQQ__Quote__c> contractAndQuoteIds, Map<Id, List<SBQQ__Subscription__c>> conWithSub){
        Map<Id,Map<Id,OpportunityLineItem>> quoteAndOpp = new Map<Id,Map<Id,OpportunityLineItem>>();
        List<SBQQ__QuoteLine__c> newQLI = new List<SBQQ__QuoteLine__c>();
        
        for(Id contractId: contractAndQuoteIds.keySet()){
            for( SBQQ__Subscription__c sub : conWithSub.get(contractId)){
                SBQQ__QuoteLine__c QLI = New SBQQ__QuoteLine__c();
                QLI.SBQQ__Quote__c = contractAndQuoteIds.get(contractId).Id;
                QLI.Site__c = sub.Site__c;
                QLI.SBQQ__Quantity__c = (0-sub.Annual_Volume__c)*((calculateRemainingTerm(sub.SBQQ__StartDate__c, sub.SBQQ__Contract__r.DateofCancellation__c, sub.Term_in_month__c)/12));
                QLI.SBQQ__Product__c = sub.SBQQ__Product__c;
                QLI.SBQQ__ListPrice__c = sub.Adder_Margin__c;
                newQLI.add(QLI);
            }
            
        }
        Database.SaveResult[] srList = Database.insert(newQLI);
        
        
    }
}