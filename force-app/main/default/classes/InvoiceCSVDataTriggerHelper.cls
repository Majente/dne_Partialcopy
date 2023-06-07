/******************************************************************
Name    : InvoiceCSVDataTriggerHelper
Author  : Soljit <VW>
Description : Helper class for Invoice CSV Data trigger to update invoices
******************************************************************/
public class InvoiceCSVDataTriggerHelper {
    /******************************************************************
Method Name    : updateInvoice
Parameter      : List<Invoice_CSV_Data__c> invCsvDataList
Description    : method for update invoice csv data
******************************************************************/
    public static void updateInvoice(List<Invoice_CSV_Data__c> invCsvDataList){
        try 
        {   
            string mapKey = '';
            string subMapKey = '';
            String key = '';
            string subKey = '';    

            set<String> suppSet = new set<String>();
            set<Date> payDateSet = new set<Date>();
            set<String> contractSet = new set<String>();
            set<String> siteSet = new set<String>();


            Map<string,Contract> contractMap = new Map<string,Contract>();
            Map<string,Id> supplierMap = new Map<string,Id>();
            Map<string,SBQQ__Subscription__c> subscriptionMap = new Map<string,SBQQ__Subscription__c>();
            Map<string,Id> siteMap = new Map<string,Id>();
            Map<string,Invoice__c> invoiceMap = new Map<string,Invoice__c>();

            Map<string,SBQQ__Subscription__c> SubscriptionMapToUpdate = new Map<string,SBQQ__Subscription__c>();    
            Map<string,Invoice__c> invoiceMapToUpsert = new Map<string,Invoice__c>();
            List<Invoice_Entries__c> invoiceEntryListToInsert = new List<Invoice_Entries__c>();    

            for(Integer i=0; i<invCsvDataList.size(); i++){          
                payDateSet.add(invCsvDataList[i].Payment_Month__c);
                suppSet.add(invCsvDataList[i].Supplier_Name__c);
                contractSet.add(invCsvDataList[i].Contract_ID__c);
                siteSet.add(invCsvDataList[i].LDC_Account_Number__c);
            }
            system.debug('###payDateSet'+payDateSet);
            system.debug('###suppSet'+suppSet);
            system.debug('###contractSet'+contractSet);
            system.debug('###siteSet'+siteSet);
            
            for(Contract c : [SELECT Id, Name, StartDate, EndDate, supplier_s_contract_ID__c, SBQQ__Opportunity__r.Supplier__c,
                              ContractTerm, SBQQ__Opportunity__r.Supplier__r.name
                              FROM Contract 
                              WHERE SBQQ__Opportunity__r.Supplier__r.name IN :suppSet
                              AND supplier_s_contract_ID__c IN :contractSet]){
                                  contractMap.put(c.supplier_s_contract_ID__c, c);
                                  supplierMap.put(c.SBQQ__Opportunity__r.Supplier__r.name , c.SBQQ__Opportunity__r.Supplier__c);                             
                              }
            system.debug('###contractMap' + contractMap.size());
            system.debug('###supplierMap'+supplierMap.size());
            
            //Fetch all relevant subscription records from data base
            for(SBQQ__Subscription__c sub : [SELECT Id, Name, SBQQ__Quantity__c, SBQQ__StartDate__c, SBQQ__ListPrice__c,Revenue_List_Price__c, SBQQ__Contract__c,SBQQ__Contract__r.Discount__c,SBQQ__Contract__r.ContractTerm, 
                                             SBQQ__Contract__r.supplier_s_contract_ID__c, Site__c, Site__r.name, Supplier__r.name, Received_Adder__c, Received_Volume__c, Error_Message__c
                                             From SBQQ__Subscription__c 
                                             Where SBQQ__Contract__r.supplier_s_contract_ID__c IN : contractMap.keySet()
                                             AND Site__r.name IN: siteSet]){
                                                 //generate key                                  
                                                 subMapKey = sub.Supplier__r.name+''+sub.Site__r.Name+''+sub.SBQQ__Contract__r.supplier_s_contract_ID__c;
                                                 subscriptionMap.put(subMapKey,sub);
                                                 siteMap.put(sub.Site__r.name, sub.Site__c);
                                             }
            system.debug('###subscriptionMap'+subscriptionMap.size());
            system.debug('###siteMap'+siteMap.size());
            
            // Fetch all Invoices related to Supplier from data base
            for(Invoice__c inv : [Select Id, Amount__c, Payment_Month__c, Calculation_Type__c, Supplier__c, 
                                  Supplier__r.Name, Contract__r.supplier_s_contract_ID__c, Site__r.Name, 
                                  Received_Amount__c, Received_Adder__c, Received_Volume__c, Expected_Adder__c, Expected_Volume__c 
                                  From Invoice__c 
                                  Where Supplier__r.Name IN :suppSet 
                                  AND Contract__r.supplier_s_contract_ID__c IN :contractMap.keySet()
                                  AND Site__r.name IN: siteSet
                                  AND ((Payment_Month__c IN :payDateSet) OR (Calculation_Type__c = :ConstantString.INVOICE_TYPE_UPFRONT))]){
                                      //generate key                      
                                      if(inv.Calculation_Type__c.equalsIgnoreCase(ConstantString.INVOICE_TYPE_UPFRONT)){
                                          mapKey = inv.Contract__r.supplier_s_contract_ID__c+''+inv.Supplier__r.Name+''+inv.Site__r.Name+''+inv.Calculation_Type__c;                      
                                      }
                                      else{
                                          mapKey = inv.Payment_Month__c.Month()+''+inv.Payment_Month__c.year()+''+inv.Contract__r.supplier_s_contract_ID__c+''+inv.Supplier__r.Name+''+inv.Site__r.Name+''+inv.Calculation_Type__c;                            
                                      }
                                      invoiceMap.put(mapKey,inv);          
                                  }
            system.debug('###invoiceListMap'+invoiceMap.size());        
            
            // Iterate all invoices data row from CSV file
            // List<Invoice_CSV_Data__c> invCsvDataList
            for(Invoice_CSV_Data__c invFromCsv : invCsvDataList){
                //generate key 
                if(invFromCsv.Calculation_Type__c.equalsIgnoreCase(ConstantString.INVOICE_TYPE_UPFRONT)){
                    Key = invFromCsv.Contract_ID__c+''+invFromCsv.Supplier_Name__c+''+invFromCsv.LDC_Account_Number__c+''+invFromCsv.Calculation_Type__c;
                }
                else{
                    Key = invFromCsv.Payment_Month__c.Month()+''+invFromCsv.Payment_Month__c.Year()+''+invFromCsv.Contract_ID__c+''+invFromCsv.Supplier_Name__c+''+invFromCsv.LDC_Account_Number__c+''+invFromCsv.Calculation_Type__c;                
                }
                subKey = invFromCsv.Supplier_Name__c+''+invFromCsv.LDC_Account_Number__c+''+invFromCsv.Contract_ID__c;                
                if(contractMap.containsKey(invFromCsv.Contract_ID__c)){
                    if(subscriptionMap.containsKey(subKey)){
                        if(subscriptionMap.get(subKey).Error_Message__c == ConstantString.INVOICE_NOT_APPROVED){
                            invFromCsv.Processed__c = True;
                            continue; 
                        }
                        if(invFromCsv.LDC_Status__c == ConstantString.INVOICE_CANCELLED){
                            invFromCsv.Processed__c = True;
                            //invFromCsv.Status__c = 'Correct Contract & Correct Site';
                            SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                            if(SubscriptionMapToUpdate.containsKey(subKey)){
                                sub = SubscriptionMapToUpdate.get(subKey);                                 
                            }
                            else{
                                sub = subscriptionMap.get(subKey);
                            }
                            sub.Error_Message__c = ConstantString.INVOICE_NOT_APPROVED;
                            sub.Site_Date__c = invFromCsv.Payment_Month__c;
                            SubscriptionMapToUpdate.put(subKey, sub);
                            Invoice__c invObj = new Invoice__c();
                            if(invoiceMapToUpsert.containsKey(key)){
                                invObj = invoiceMapToUpsert.get(key);                    
                                invObj.Flag__c = ConstantString.INVOICE_NOT_APPROVED;
                                invoiceMapToUpsert.put(key, invObj);
                            }
                            else if(invoiceMap.containsKey(key)){
                                invObj = invoiceMap.get(key);
                                invObj.Flag__c = ConstantString.INVOICE_NOT_APPROVED;
                                invoiceMapToUpsert.put(key, invObj);
                            }
                        }
                        else if(invoiceMap.containsKey(key)){                        
                            Invoice__c invObj = new Invoice__c();
                            if(invoiceMapToUpsert.containsKey(key)){
                                invObj = invoiceMapToUpsert.get(key);                    
                            }
                            else{
                                invObj = invoiceMap.get(key);
                            }
                            invFromCsv.Processed__c = True;
                            
                            invFromCsv.Revenue__c = invObj.id;
                            
                            invObj.Received_Amount__c += invFromCsv.Amount__c;
                            
                            invObj.Received_Adder__c = invFromCsv.Adder__c;
                            invObj.Received_Volume__c = invFromCsv.LDC_Actual_Usage__c;
                            
                            invObj.Processed__c = True;
                            
                            SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                            
                            if(SubscriptionMapToUpdate.containsKey(subKey)){
                                sub = SubscriptionMapToUpdate.get(subKey);                                 
                            }
                            else{
                                sub = subscriptionMap.get(subKey);
                            }
                            sub.Received_Adder__c = invObj.Received_Adder__c;
                            sub.Received_Volume__c = invObj.Received_Volume__c;
                            
                            if(invObj.Received_Amount__c < invObj.Amount__c){
                                invObj.Flag__c = ConstantString.INVOICE_LESS_AMOUNT;
                                invFromCsv.Status__c = ConstantString.INVOICE_LESS_AMOUNT;
                                sub.Error_Message__c = invObj.Flag__c;
                                SubscriptionMapToUpdate.put(subKey, sub);
                            }
                            else if(invObj.Received_Amount__c > invObj.Amount__c){
                                invObj.Flag__c = ConstantString.INVOICE_GREATER_AMOUNT; 
                                invFromCsv.Status__c = ConstantString.INVOICE_GREATER_AMOUNT;
                                if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT){
                                    sub.Error_Message__c = invObj.Flag__c;
                                    SubscriptionMapToUpdate.put(subKey, sub);
                                }
                            }
                            else{
                                invObj.Flag__c = ConstantString.INVOICE_RECEIVED_PAYMENT;
                                invFromCsv.Status__c = ConstantString.INVOICE_RECEIVED_PAYMENT;
                                if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT){
                                    sub.Error_Message__c = invObj.Flag__c;
                                }                            
                                if(invObj.Received_Adder__c < invObj.Expected_Adder__c){
                                    invObj.Flag__c = ConstantString.INVOICE_LESS_ADDER; 
                                    if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT){
                                        sub.Error_Message__c = invObj.Flag__c;
                                    }                            
                                }
                                else if(invObj.Received_Adder__c > invObj.Expected_Adder__c){
                                    invObj.Flag__c = ConstantString.INVOICE_GREATER_ADDER; 
                                    if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_LESS_ADDER){
                                        sub.Error_Message__c = invObj.Flag__c;
                                    }                            
                                }
                                else if(invObj.Received_Volume__c < invObj.Expected_Volume__c){
                                    invObj.Flag__c = ConstantString.INVOICE_LESS_VOLUME;                                     
                                    if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_LESS_ADDER && sub.Error_Message__c != ConstantString.INVOICE_GREATER_ADDER){
                                        sub.Error_Message__c = invObj.Flag__c;
                                    }                            
                                }
                                else if(invObj.Received_Volume__c > invObj.Expected_Volume__c){
                                    invObj.Flag__c = ConstantString.INVOICE_GREATER_VOLUME;
                                    if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_LESS_ADDER && sub.Error_Message__c != ConstantString.INVOICE_GREATER_ADDER && sub.Error_Message__c != ConstantString.INVOICE_LESS_VOLUME){
                                        sub.Error_Message__c = invObj.Flag__c;
                                    }                            
                                } 
                                SubscriptionMapToUpdate.put(subKey, sub);
                            }                                                        
                            invoiceMapToUpsert.put(key, invObj);                                                                       
                        }
                        else{
                            invFromCsv.Processed__c = True;
                            Invoice__c invObj = new Invoice__c();
                            if(invoiceMapToUpsert.containsKey(key)){
                                invObj = invoiceMapToUpsert.get(key);                    
                            }
                            else{
                                invObj.Subscription__c = subscriptionMap.get(subKey).Id;
                                invObj.Site__c = subscriptionMap.get(subKey).Site__c;
                                invObj.Contract__c = subscriptionMap.get(subKey).SBQQ__Contract__c;
                                invObj.Supplier__c = subscriptionMap.get(subKey).Supplier__c;
                                invObj.Commodity__c = invFromCsv.Commodity__c;
                                //invObj.Adder__c = invFromCsv.adder;
                                invObj.Contract_Term__c = subscriptionMap.get(subKey).SBQQ__Contract__r.ContractTerm;
                                
                                invObj.Expected_Adder__c = subscriptionMap.get(subKey).Revenue_List_Price__c;
                                if(subscriptionMap.get(subKey).SBQQ__Quantity__c != null && invObj.Contract_Term__c != null){                                    
                                    invObj.Expected_Volume__c = subscriptionMap.get(subKey).SBQQ__Quantity__c / ( invObj.Contract_Term__c / 12 );
                                }

                                invObj.Contract_Usage_Volume__c = invFromCsv.LDC_Contracted_Usage__c;
                                invObj.Calculation_Type__c = invFromCsv.Calculation_Type__c;
                                Integer mon = subscriptionMap.get(subKey).SBQQ__StartDate__c.monthsBetween(invFromCsv.Payment_Month__c);
                                invObj.Start_Date__c = subscriptionMap.get(subKey).SBQQ__StartDate__c.addMonths(mon);
                                invObj.End_Date__c = invObj.Start_Date__c.addMonths(1).addDays(-1);
                                /*Decimal v1 = ((subscriptionMap.get(subKey).SBQQ__Quantity__c * subscriptionMap.get(subKey).Revenue_List_Price__c)/2);
                                system.debug('v1 :: '+ v1);
                                decimal v2 = ((100-subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c)/100);
                                system.debug('v2 :: '+ v2);
                                Decimal amt = (v1*v2).setScale(2, RoundingMode.HALF_UP);*/
                                Decimal amt;
                                if(subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c == null){
                                    amt = ((subscriptionMap.get(subKey).SBQQ__Quantity__c * subscriptionMap.get(subKey).Revenue_List_Price__c)/2).setScale(2, RoundingMode.HALF_UP);
                                }
                                else{
                                    amt = (((subscriptionMap.get(subKey).SBQQ__Quantity__c * subscriptionMap.get(subKey).Revenue_List_Price__c)/2)*((100-subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c)/100)).setScale(2, RoundingMode.HALF_UP);
                                }
                                if(invObj.Calculation_Type__c == ConstantString.INVOICE_TYPE_UPFRONT){
                                    invObj.Amount__c = amt;                         
                                }
                                else{
                                    invObj.Amount__c = (amt/subscriptionMap.get(subKey).SBQQ__Contract__r.ContractTerm).setScale(2, RoundingMode.HALF_UP);                         
                                }
                                invObj.Received_Amount__c = 0; 
                            }                    
                            invObj.Received_Amount__c += invFromCsv.Amount__c;
                            
                            invObj.Received_Adder__c = invFromCsv.Adder__c;
                            invObj.Received_Volume__c = invFromCsv.LDC_Actual_Usage__c;
                            
                            invObj.Processed__c = True;
                            
                            SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                            
                            if(SubscriptionMapToUpdate.containsKey(subKey)){
                                sub = SubscriptionMapToUpdate.get(subKey);                    
                            }
                            else{
                                sub = subscriptionMap.get(subKey);
                            }
                            
                            sub.Received_Adder__c = invObj.Received_Adder__c;
                            sub.Received_Volume__c = invObj.Received_Volume__c;
                            
                            if(invObj.Received_Amount__c < invObj.Amount__c){
                                invObj.Flag__c = ConstantString.INVOICE_LESS_AMOUNT;
                                invFromCsv.Status__c = ConstantString.INVOICE_LESS_AMOUNT;
                                sub.Error_Message__c = invObj.Flag__c;
                                SubscriptionMapToUpdate.put(subKey, sub);
                            }
                            else if(invObj.Received_Amount__c > invObj.Amount__c){
                                invObj.Flag__c = ConstantString.INVOICE_GREATER_AMOUNT; 
                                invFromCsv.Status__c = ConstantString.INVOICE_GREATER_AMOUNT;
                                if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT){
                                    sub.Error_Message__c = invObj.Flag__c;
                                    SubscriptionMapToUpdate.put(subKey, sub);
                                }
                            }
                            else{
                                invObj.Flag__c = ConstantString.INVOICE_RECEIVED_PAYMENT;
                                invFromCsv.Status__c = ConstantString.INVOICE_RECEIVED_PAYMENT;
                                if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT){
                                    sub.Error_Message__c = invObj.Flag__c;
                                }                            
                                if(invObj.Received_Adder__c < invObj.Expected_Adder__c){
                                    invObj.Flag__c = ConstantString.INVOICE_LESS_ADDER;  
                                    
                                    if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT){
                                        sub.Error_Message__c = invObj.Flag__c;
                                    }                            
                                }
                                else if(invObj.Received_Adder__c > invObj.Expected_Adder__c){
                                    invObj.Flag__c = ConstantString.INVOICE_GREATER_ADDER; 
                                    
                                    if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_LESS_ADDER){
                                        sub.Error_Message__c = invObj.Flag__c;
                                    }                            
                                }
                                else if(invObj.Received_Volume__c < invObj.Expected_Volume__c){
                                    invObj.Flag__c = ConstantString.INVOICE_LESS_VOLUME; 
                                    
                                    if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_LESS_ADDER && sub.Error_Message__c != ConstantString.INVOICE_GREATER_ADDER){
                                        sub.Error_Message__c = invObj.Flag__c;
                                    }                            
                                }
                                else if(invObj.Received_Volume__c > invObj.Expected_Volume__c){
                                    invObj.Flag__c = ConstantString.INVOICE_GREATER_VOLUME;
                                    if(sub.Error_Message__c != ConstantString.INVOICE_LESS_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT && sub.Error_Message__c != ConstantString.INVOICE_LESS_ADDER && sub.Error_Message__c != ConstantString.INVOICE_GREATER_ADDER && sub.Error_Message__c != ConstantString.INVOICE_LESS_VOLUME){
                                        sub.Error_Message__c = invObj.Flag__c;
                                    }                            
                                } 
                                SubscriptionMapToUpdate.put(subKey, sub);
                            }
                            invoiceMapToUpsert.put(key, invObj);                                               
                        }
                    }
                    else{
                        invFromCsv.Processed__c = True;
                        invFromCsv.Status__c = 'Correct Contract & Missing Site';
                        Invoice_Entries__c invEntryObj = new Invoice_Entries__c();
                        invEntryObj.Payment_Date__c = invFromCsv.Payment_Month__c;
                        invEntryObj.Calculation_Type__c = invFromCsv.Calculation_Type__c;
                        invEntryObj.Supplier__c = contractMap.get(invFromCsv.Contract_ID__c).SBQQ__Opportunity__r.Supplier__c;
                        invEntryObj.Contract__c = invFromCsv.Contract_ID__c;
                        invEntryObj.Amount__c = invFromCsv.Amount__c;
                        invEntryObj.Received_Adder__c = invFromCsv.Adder__c;
                        invEntryObj.Received_Volume__c = invFromCsv.LDC_Actual_Usage__c;
                        invEntryObj.Contract_Usage_Volume__c = invFromCsv.LDC_Contracted_Usage__c;
                        invEntryObj.Site__c = invFromCsv.LDC_Account_Number__c;
                        invEntryObj.Status__c = 'Correct Contract & Missing Site';
                        invoiceEntryListToInsert.add(invEntryObj);                    
                    }
                }
                else if(siteMap.containsKey(invFromCsv.LDC_Account_Number__c)){
                    invFromCsv.Processed__c = True; 
                    invFromCsv.Status__c = 'Missing Contract & Correct Site';
                    Invoice_Entries__c invEntryObj = new Invoice_Entries__c();
                    invEntryObj.Payment_Date__c = invFromCsv.Payment_Month__c;
                    invEntryObj.Calculation_Type__c = invFromCsv.Calculation_Type__c;
                    invEntryObj.Supplier__c = supplierMap.get(invFromCsv.Supplier_Name__c);
                    invEntryObj.Site__c = invFromCsv.LDC_Account_Number__c;
                    invEntryObj.Amount__c = invFromCsv.Amount__c;
                    invEntryObj.Received_Adder__c = invFromCsv.Adder__c;
                    invEntryObj.Received_Volume__c = invFromCsv.LDC_Actual_Usage__c;
                    invEntryObj.Contract_Usage_Volume__c = invFromCsv.LDC_Contracted_Usage__c;
                    invEntryObj.Contract__c = invFromCsv.Contract_ID__c;
                    invEntryObj.Status__c = 'Missing Contract & Correct Site';
                    invoiceEntryListToInsert.add(invEntryObj);                    
                }
                else{
                    invFromCsv.Processed__c = True;  
                    invFromCsv.Status__c = 'Missing Contract & Missing Site';
                    Invoice_Entries__c invEntryObj = new Invoice_Entries__c();
                    invEntryObj.Payment_Date__c = invFromCsv.Payment_Month__c;
                    invEntryObj.Calculation_Type__c = invFromCsv.Calculation_Type__c;
                    invEntryObj.Supplier__c = supplierMap.get(invFromCsv.Supplier_Name__c);
                    invEntryObj.Amount__c = invFromCsv.Amount__c;
                    invEntryObj.Received_Adder__c = invFromCsv.Adder__c;
                    invEntryObj.Received_Volume__c = invFromCsv.LDC_Actual_Usage__c;
                    invEntryObj.Contract_Usage_Volume__c = invFromCsv.LDC_Contracted_Usage__c;
                    invEntryObj.Contract__c = invFromCsv.Contract_ID__c;
                    invEntryObj.Site__c = invFromCsv.LDC_Account_Number__c;
                    invEntryObj.Status__c = 'Missing Contract & Missing Site';
                    invoiceEntryListToInsert.add(invEntryObj);                     
                }            
            }
            
            System.debug('invoiceMapToUpsert :: ' + invoiceMapToUpsert.size() );                                           
            System.debug('invoiceEntryListToInsert :: ' + invoiceEntryListToInsert.size() );                                           
            System.debug('SubscriptionMapToUpdate :: ' + SubscriptionMapToUpdate.size() );                                           
            
            if(invoiceMapToUpsert.size() > 0){
                System.debug('**** Size of invoiceListToUpsert :: '+invoiceMapToUpsert.size());
                UPSERT invoiceMapToUpsert.values();
                System.debug('UPSERT success');
            }
            if(invoiceEntryListToInsert.size() > 0){
                INSERT invoiceEntryListToInsert;
                System.debug('INSERT success');
                System.debug('**** Size of invoiceEntryListToInsert :: '+invoiceEntryListToInsert);
            }
            if(SubscriptionMapToUpdate.size() > 0){
                UPDATE SubscriptionMapToUpdate.values();
                System.debug('UPDATE success');
                System.debug('**** Size of SubscriptionMapToUpdate :: '+SubscriptionMapToUpdate.size());
            }
        }catch(Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, Label.An_error_has_occured_while_saving_data + e.getMessage());
            ApexPages.addMessage(errorMessage);
        }        
    }
}