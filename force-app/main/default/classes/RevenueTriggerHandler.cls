/*************************************************************
* Class: RevenueTriggerHandler
* Author: Soljit <VW>
* Date: 2019-12-23
* Description: handler class for Invoice__c trigger
**************************************************************/
public class RevenueTriggerHandler {
/*************************************************************
* Method Name : updateRevenuePaymentStatus
* Parameter   : List<Invoice__c> invList
* Description : method used to update Revenue Payment Status
**************************************************************/
    public static void updateRevenuePaymentStatus(List<Invoice__c> invList){
        System.debug('invList.size() ::: ' + invList.size());
        System.debug('invList ::: ' + invList);
        Set<Id> subscriptionIdSet = new Set<Id>();
        for(Invoice__c inv : invList){
            if(inv.Subscription__c != null){
                subscriptionIdSet.add(inv.Subscription__c);   
            }            
        }
        
        Map<Id,SBQQ__Subscription__c> subscriptionIdMap = new Map<Id,SBQQ__Subscription__c>([Select id, Received_Adder__c, Received_Volume__c, Error_Message__c 
                                                                                             from SBQQ__Subscription__c 
                                                                                             where id IN : subscriptionIdSet]);
        System.debug('subscriptionIdMap.size() ::: ' + subscriptionIdMap.size());
        System.debug('subscriptionIdMap. ::: ' + subscriptionIdMap);
        for(Invoice__c invObj : invList){
            invObj.Processed__c = True;                        
            if(invObj.Received_Amount__c < invObj.Amount__c){
                invObj.Flag__c = ConstantString.INVOICE_LESS_AMOUNT;
                if(subscriptionIdMap.containsKey(invObj.Subscription__c)){
                    subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c = invObj.Flag__c;                    
                }
            }
            else if(invObj.Received_Amount__c > invObj.Amount__c){
                invObj.Flag__c = ConstantString.INVOICE_GREATER_AMOUNT; 
                if(subscriptionIdMap.containsKey(invObj.Subscription__c) &&  subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT){
                    subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c = invObj.Flag__c;                    
                }
            }
            else{
                invObj.Flag__c = ConstantString.INVOICE_RECEIVED_PAYMENT;
                if(subscriptionIdMap.containsKey(invObj.Subscription__c) &&  subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT){
                    subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c = invObj.Flag__c;
                }                            
                if(invObj.Received_Adder__c < invObj.Expected_Adder__c){
                    invObj.Flag__c = ConstantString.INVOICE_LESS_ADDER;                                
                    if(subscriptionIdMap.containsKey(invObj.Subscription__c) && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT){
                        subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c = invObj.Flag__c;
                    }                            
                }
                else if(invObj.Received_Adder__c > invObj.Expected_Adder__c){
                    invObj.Flag__c = ConstantString.INVOICE_GREATER_ADDER; 
                    if(subscriptionIdMap.containsKey(invObj.Subscription__c) && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_ADDER){
                        subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c = invObj.Flag__c;
                    }                            
                }
                else if(invObj.Received_Volume__c < invObj.Expected_Volume__c){
                    invObj.Flag__c = ConstantString.INVOICE_LESS_VOLUME; 
                    if(subscriptionIdMap.containsKey(invObj.Subscription__c) && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_ADDER && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_GREATER_ADDER){
                        subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c = invObj.Flag__c;
                    }                            
                }
                else if(invObj.Received_Volume__c > invObj.Expected_Volume__c){
                    invObj.Flag__c = ConstantString.INVOICE_GREATER_VOLUME;
                    if(subscriptionIdMap.containsKey(invObj.Subscription__c) && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_ADDER && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_GREATER_ADDER && subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c != ConstantString.INVOICE_LESS_VOLUME){
                        subscriptionIdMap.get(invObj.Subscription__c).Error_Message__c = invObj.Flag__c;
                    }                            
                } 
            }                                                                    
        }
        if(subscriptionIdMap.values().size() > 0){
            update subscriptionIdMap.values();
            System.debug('Subscriptions Status Updated successfully.');
        }        
    }
    /*************************************************************
* Method Name : updateCancelledRevenue
* Parameter   : List<Invoice__c> invList
* Description : method used to update flag for invoices
**************************************************************/
    public static void updateCancelledRevenue(List<Invoice__c> invList){
        for (Invoice__c inv : invList){
           inv.Flag__c = 'Payment not received'; 
        } 
    }
}