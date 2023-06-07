/**************************************************
* Class: InvoiceCSVDataBatch
* Author: Soljit <VW>
* Date: 2019-10-09
* Description: Batch Class to update the Invoices and Subscription and create Invoice entries
****************************************************/
global class InvoiceCSVDataBatch implements Database.Batchable<sObject>, Database.Stateful{
    global List<ErrorLog> errorList;
    global List<Invoice_CSV_Data__c> invoiceCSVDataList;
    global Map<String,Integer> statusMap;
    global String fileName;
    global DateTime reconcillationDateTime ;
    //global InvoiceFlag__c invoiceFlag = InvoiceFlag__c.getOrgDefaults(); 
    global InvoiceCSVDataBatch(String newCSVfileName){
        fileName = newCSVfileName;
        //reconcillationDateTime = dt;
        errorList = new List<ErrorLog>();
        //invoiceCSVDataList = invCSVDataList;
        statusMap = new Map<String,Integer>();
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = 'Select Id, Calculation_Type__c, Commodity__c, Contract_ID__c, LDC_Account_Number__c, Supplier_Name__c,';
        queryString += 'LDC_Status__c, LDC_Contracted_Usage__c, Adder__c, Amount__c, LDC_Actual_Usage__c,';
        queryString += 'Revenue__c, Processed__c, Status__c, Payment_Month__c';
        queryString += ' FROM Invoice_CSV_Data__c';
        queryString += ' WHERE ExternalId__c = :fileName';
        queryString += ' AND Processed__c = false';
        queryString += ' AND HasError__c = false';
        
        // Return this list of invoice CSV Data List, which will get passed to our execute() method below.*/
        return Database.getQueryLocator(queryString);
        //system.debug('invoiceCSVDataList :::::::'+invoiceCSVDataList.size());
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<Invoice_CSV_Data__c> invCSVDataList){
        //Iterate all opportunities
        try 
        {   
            string mapKey = '';
            string subMapKey = '';
            String key = '';
            string subKey = '';  
            Date endDateOfMonth;
            
            set<String> suppSet = new set<String>();
            set<Date> payDateSet = new set<Date>();
            set<String> contractSet = new set<String>();
            set<String> siteSet = new set<String>();
            //set<String> supplierSet = new set<String>();
            //set<String> marketSet = new set<String>();
            
            Map<string,Contract> contractMap = new Map<string,Contract>();
            Map<string,Id> supplierMap = new Map<string,Id>();
            Map<string,SBQQ__Subscription__c> subscriptionMap = new Map<string,SBQQ__Subscription__c>();
            Map<string,Id> siteMap = new Map<string,Id>();
            Map<string,Invoice__c> invoiceMap = new Map<string,Invoice__c>();
            
            Map<string,SBQQ__Subscription__c> SubscriptionMapToUpdate = new Map<string,SBQQ__Subscription__c>();    
            Map<string,Invoice__c> invoiceMapToUpsert = new Map<string,Invoice__c>();
            List<Invoice_Entries__c> invoiceEntryListToInsert = new List<Invoice_Entries__c>();    
            
            for(Integer i=0; i<invCsvDataList.size(); i++){
                if(invCsvDataList[i].Contract_ID__c != null){
                    contractSet.add(invCsvDataList[i].Contract_ID__c);   
                }
                if(invCsvDataList[i].Payment_Month__c != null){
                    system.debug('###PaymentDateMonth:::'+invCsvDataList[i].Payment_Month__c);
                    endDateOfMonth = invCsvDataList[i].Payment_Month__c.tostartOfMonth().addMonths(1).addDays(-1); 
                    payDateSet.add(endDateOfMonth); 
                    system.debug('###endDateOfMonth'+endDateOfMonth);
                }
                if(invCsvDataList[i].Supplier_Name__c != null){
                    suppSet.add(invCsvDataList[i].Supplier_Name__c);
                }
                if(invCsvDataList[i].LDC_Account_Number__c != null){
                    siteSet.add(invCsvDataList[i].LDC_Account_Number__c);
                }
                
                
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
            for(SBQQ__Subscription__c sub : [SELECT Id, Name, SBQQ__Quantity__c, SBQQ__StartDate__c,IsAmended__c, SBQQ__ListPrice__c,Revenue_List_Price__c, SBQQ__Contract__c,SBQQ__Contract__r.Payment_Terms__c,SBQQ__Contract__r.Discount__c,SBQQ__Contract__r.ContractTerm, 
                                             SBQQ__Contract__r.supplier_s_contract_ID__c, Site__c, Site__r.name, Supplier__r.name, Received_Adder__c, Received_Volume__c, Error_Message__c,SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c
                                             From SBQQ__Subscription__c 
                                             Where SBQQ__Contract__r.supplier_s_contract_ID__c IN : contractMap.keySet()
                                             AND Site__r.name IN: siteSet]){
                                                 //generate key                                  
                                                 subMapKey = sub.Supplier__r.name+''+sub.Site__r.Name+''+sub.SBQQ__Contract__r.supplier_s_contract_ID__c;
                                                 system.debug('###subMapKey'+subMapKey);
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
                                  AND ((Payment_Month__c IN :payDateSet) OR (Calculation_Type__c = :ConstantString.INVOICE_TYPE_UPFRONT))])
            {
                //generate key                      
                if(inv.Calculation_Type__c.equalsIgnoreCase(ConstantString.INVOICE_TYPE_UPFRONT)){
                    mapKey = inv.Contract__r.supplier_s_contract_ID__c+''+inv.Supplier__r.Name+''+inv.Site__r.Name+''+inv.Calculation_Type__c;                      
                }
                else{
                    mapKey = inv.Payment_Month__c.Month()+''+inv.Payment_Month__c.year()+''+inv.Contract__r.supplier_s_contract_ID__c+''+inv.Supplier__r.Name+''+inv.Site__r.Name+''+inv.Calculation_Type__c;                            
                }
                system.debug('Invoice mapKey::::::'+mapKey);
                invoiceMap.put(mapKey,inv);          
            }
            system.debug('###invoiceListMap'+invoiceMap.size());        
            
            //Re-Update the invoice calculation type field value
            Map<string,string> calculation_type_Map = new Map<string,string>();
            calculation_type_Map.put('50/50 Upfront','Upfront');
            calculation_type_Map.put('50/50 On Flow','Residual');
            calculation_type_Map.put('On Flow','Residual');
            // Iterate all invoices data row from CSV file
            // List<Invoice_CSV_Data__c> invCsvDataList
            for(Invoice_CSV_Data__c invFromCsv : invCsvDataList){
                //generate key 
                system.debug('ConstantString.INVOICE_TYPE_UPFRONT ::'+ConstantString.INVOICE_TYPE_UPFRONT);
                system.debug('Before Re-assign invFromCsv.Calculation_Type__c ::'+invFromCsv.Calculation_Type__c);
                system.debug('calculation_type_Map ::'+calculation_type_Map);
                if(calculation_type_Map.containsKey(invFromCsv.Calculation_Type__c)){
                    invFromCsv.Calculation_Type__c = calculation_type_Map.get(invFromCsv.Calculation_Type__c);
                }
                system.debug('After Re-assign invFromCsv.Calculation_Type__c ::'+invFromCsv.Calculation_Type__c);
                if(invFromCsv.Calculation_Type__c.equalsIgnoreCase(ConstantString.INVOICE_TYPE_UPFRONT)){
                    Key = invFromCsv.Contract_ID__c+''+invFromCsv.Supplier_Name__c+''+invFromCsv.LDC_Account_Number__c+''+invFromCsv.Calculation_Type__c;
                }
                else{
                    Key = invFromCsv.Payment_Month__c.Month()+''+invFromCsv.Payment_Month__c.Year()+''+invFromCsv.Contract_ID__c+''+invFromCsv.Supplier_Name__c+''+invFromCsv.LDC_Account_Number__c+''+invFromCsv.Calculation_Type__c;                
                    
                }
                
                subKey = invFromCsv.Supplier_Name__c+''+invFromCsv.LDC_Account_Number__c+''+invFromCsv.Contract_ID__c; 
                System.debug('Key :::::'+Key);
                System.debug('subKey :::::'+subKey);
                if(contractMap.containsKey(invFromCsv.Contract_ID__c)){
                    System.debug('Contract :::::'+contractMap.get(invFromCsv.Contract_ID__c));
                    //If subscription exist
                    if(subscriptionMap.containsKey(subKey)){
                        
                        if(subscriptionMap.get(subKey).Error_Message__c == ConstantString.INVOICE_NOT_APPROVED){
                            invFromCsv.Processed__c = True;
                            invFromCsv.Status__c = ConstantString.INVOICE_NOT_APPROVED;
                            if(!statusMap.containsKey(invFromCsv.Status__c)){
                                statusMap.put(invFromCsv.Status__c,0);
                            }
                            Integer i = statusMap.get(invFromCsv.Status__c);
                            i++;
                            statusMap.put(invFromCsv.Status__c,i);
                            system.debug('Status map for Cancelled::::'+statusMap);
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
                            invFromCsv.Status__c = ConstantString.INVOICE_NOT_APPROVED;
                            if(!statusMap.containsKey(invFromCsv.Status__c)){
                                statusMap.put(invFromCsv.Status__c,0);
                            }
                            Integer i = statusMap.get(invFromCsv.Status__c);
                            i++;
                            statusMap.put(invFromCsv.Status__c,i);
                            system.debug('Status map for Cancelled::::'+statusMap);
                        }
                        else if(invoiceMap.containsKey(key)){                        
                            Invoice__c invObj = new Invoice__c();
                            if(invoiceMapToUpsert.containsKey(key)){
                                invObj = invoiceMapToUpsert.get(key);                    
                            }
                            else{
                                invObj = invoiceMap.get(key);
                            }
                            System.debug('invObj :::::'+invObj);
                            invFromCsv.Processed__c = True;
                            
                            invFromCsv.Revenue__c = invObj.id;
                            
                            invObj.Received_Amount__c = invFromCsv.Amount__c;
                            
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
                                if(sub.Error_Message__c != ConstantString.INVOICE_GREATER_AMOUNT){
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
                            invFromCsv.Status__c = invObj.Flag__c;
                            invoiceMapToUpsert.put(key, invObj);  
                            if(!statusMap.containsKey(invObj.Flag__c)){
                                statusMap.put(invObj.Flag__c,0);
                            }
                            Integer i = statusMap.get(invObj.Flag__c);
                            i++;
                            statusMap.put(invObj.Flag__c,i);
                            system.debug('Status Map :::::'+statusMap);
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
                              
                                Decimal amt;
                                //If Condition to check the Payment term of Contract
                                if(subscriptionMap.get(subKey).SBQQ__Contract__r.Payment_Terms__c == '50% Upfront on flow and 50% Residual - Monthly'){ 
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
                                }//end of 50% on flow and 50% residual 
                                else if(subscriptionMap.get(subKey).SBQQ__Contract__r.Payment_Terms__c == '100% Residual - Monthly'){
                                    if(subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c == null){
                                        amt =  ( ( subscriptionMap.get(subKey).SBQQ__Quantity__c * subscriptionMap.get(subKey).Revenue_List_Price__c ) / subscriptionMap.get(subKey).SBQQ__Contract__r.ContractTerm ).setScale( 2 , RoundingMode.HALF_UP );                               
                                    }
                                    else{
                                        amt =  ( ( ( subscriptionMap.get(subKey).SBQQ__Quantity__c * subscriptionMap.get(subKey).Revenue_List_Price__c ) * ( ( 100 - subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c ) / 100 ) ) / subscriptionMap.get(subKey).SBQQ__Contract__r.ContractTerm ).setScale( 2 , RoundingMode.HALF_UP );                               
                                    }
                                    invObj.Amount__c = amt;
                                }
                                else if(subscriptionMap.get(subKey).SBQQ__Contract__r.Payment_Terms__c == '50% Upfront, 50% at year 1'){
                                    if(subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c == null){
                                        amt = ((subscriptionMap.get(subKey).SBQQ__Quantity__c / 12) * (subscriptionMap.get(subKey).SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 2));
                                    }
                                    else{
                                        amt = (((subscriptionMap.get(subKey).SBQQ__Quantity__c / 12)*((100-subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c)/100)) * (subscriptionMap.get(subKey).SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c / 2));
                                    }
                                       invObj.Amount__c = amt;
                                }
                               /* else if(subscriptionMap.get(subKey).SBQQ__Contract__r.Payment_Terms__c == '100% Upfront - Annual'){
                                    if(subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c == null){
                                        amt =  ( ( subscriptionMap.get(subKey).SBQQ__Quantity__c / 12) * subscriptionMap.get(subKey).SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c);                               
                                    }
                                    else{
                                        amt =  ( ( ( subscriptionMap.get(subKey).SBQQ__Quantity__c / 12 ) * ( ( 100 - subscriptionMap.get(subKey).SBQQ__Contract__r.Discount__c ) / 100 ) ) * subscriptionMap.get(subKey).SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c);                               
                                    }
                                    invObj.Amount__c = amt;
                                } */
                                invObj.Received_Amount__c = 0; 
                            }                    
                            invObj.Received_Amount__c = invFromCsv.Amount__c;
                            
                            invObj.Received_Adder__c = invFromCsv.Adder__c;
                            invObj.Received_Volume__c = invFromCsv.LDC_Actual_Usage__c;
                            
                            invObj.Processed__c = True;
                            System.debug('invObj at 267:::::'+invObj);
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
                            invFromCsv.Status__c = invObj.Flag__c;
                            invoiceMapToUpsert.put(key, invObj); 
                            if(!statusMap.containsKey(invObj.Flag__c)){
                                statusMap.put(invObj.Flag__c,0);
                            }
                            Integer i = statusMap.get(invObj.Flag__c);
                            i++;
                            statusMap.put(invObj.Flag__c,i);
                            system.debug('Status Map:::::::'+statusMap);
                        }
                        System.debug('invFromCsv.Status__c '+ invFromCsv.Status__c);
                    }
                    else  // if subscription not exist
                    {
                        invFromCsv.Processed__c = True;
                        invFromCsv.Status__c = 'Correct Contract & Missing Site';
                        Invoice_Entries__c invEntryObj = new Invoice_Entries__c();
                        invEntryObj.Payment_Date__c = invFromCsv.Payment_Month__c;
                        invEntryObj.Calculation_Type__c = invFromCsv.Calculation_Type__c;
                        invEntryObj.Supplier__c = contractMap.get(invFromCsv.Contract_ID__c).SBQQ__Opportunity__r.Supplier__c;
                        invEntryObj.Contract__c = invFromCsv.Contract_ID__c;
                        invEntryObj.ContractName__c = contractMap.get(invFromCsv.Contract_ID__c).Id;
                        invEntryObj.Amount__c = invFromCsv.Amount__c;
                        invEntryObj.Received_Adder__c = invFromCsv.Adder__c;
                        invEntryObj.Received_Volume__c = invFromCsv.LDC_Actual_Usage__c;
                        invEntryObj.Contract_Usage_Volume__c = invFromCsv.LDC_Contracted_Usage__c;
                        invEntryObj.Site__c = invFromCsv.LDC_Account_Number__c;
                        invEntryObj.Status__c = 'Correct Contract & Missing Site';
                        invoiceEntryListToInsert.add(invEntryObj);   
                        if(!statusMap.containsKey(invEntryObj.Status__c)){
                            statusMap.put(invEntryObj.Status__c,0);
                        }
                        Integer i = statusMap.get(invEntryObj.Status__c);
                        i++;
                        statusMap.put(invEntryObj.Status__c,i);
                        system.debug('Status map from Correct Contract Missing Site:::'+statusMap);
                        //invFromCsv.Status__c = invEntryObj.Flag__c;
                    }
                }
                else // If customer's account exist
                    if(siteMap.containsKey(invFromCsv.LDC_Account_Number__c)){
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
                    if(!statusMap.containsKey(invEntryObj.Status__c)){
                            statusMap.put(invEntryObj.Status__c,0);
                    }
                    Integer i = statusMap.get(invEntryObj.Status__c);
                    i++;
                    statusMap.put(invEntryObj.Status__c,i);
                        system.debug('status map for missing contract and correct site::::'+statusMap);
                    //invFromCsv.Status__c = invEntryObj.Flag__c;
                }
                else // else if not contract and no account exist then put in miscellaneous  
                {
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
                    if(!statusMap.containsKey(invEntryObj.Status__c)){
                        statusMap.put(invEntryObj.Status__c,0);
                    }
                    Integer i = statusMap.get(invEntryObj.Status__c);
                    i++;
                    statusMap.put(invEntryObj.Status__c,i);
                    system.debug('Status Map for Missing Contract Missing Site::::'+statusMap);
                    //invFromCsv.Status__c = invEntryObj.Flag__c;                    
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
            if(invCSVDataList.size() > 0){
                UPDATE invCSVDataList;
            }
        }catch(Exception ex){
            List<Invoice_CSV_Data__c> errorCSVList = new List<Invoice_CSV_Data__c>();
            System.debug('**** Exception: '+ ex.getMessage());
            errorList.add(new ErrorLog(ex.getTypeName() ,ex.getMessage() + ' | '+ ex.getStackTraceString()));
            for(Invoice_CSV_Data__c inCSV : [Select id, HasError__c, Processed__c FROM Invoice_CSV_Data__c WHERE id IN : invCSVDataList ]){
                inCSV.HasError__c = true;
                errorCSVList.add(inCSV);
            }
          if(errorCSVList.size() > 0){
                UPDATE errorCSVList;
            }
        }  
    }
    //finish method
    global void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('#### job ::: ' + job);
        System.debug('#### InvoiceCSVDataBatch completed successfully.');  
        System.debug('statusMap :: ' + statusMap );   
        User currentUser = [Select Id, Email FROM User where Id = :UserInfo.getUserId()];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{currentUser.Email}); // Current User's Email
        mail.setTreatTargetObjectAsRecipient(true);
        // Email Subject for System generated error mails when script fails due to system generated errors.
        mail.setSubject(system.label.ImportCSVNotificationSubject);
        mail.setSaveAsActivity(true);
        String body = '';
 		body +=  '<tr>Please find status detail of reconcillation: </tr> ';
        body +=  '<tr>File Name : '+ fileName + '</tr> ';
        //body +=  '<tr>DateTime :  ' + reconcillationDateTime + '</tr> ';      
        body += '<table border="1" cellpadding="0" cellspacing="0" id="licenseList"  style="-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;mso-table-lspace:0pt;mso-table-rspace:0pt;border-collapse:collapse !important;" width="100%">';
        body += '<thead><tr>';
        body += '<td style="text-align: center"> # </td>';
        body += '<td style="ktext-align: center"> Type </td>';
        body += '<td style="text-align: center"> Message/Record Count </td>';    
        body += '</tr></thead><tbody>';
      
        integer row = 1;
        if(errorList.size() > 0  && errorList != null){
            // If error then notifying to respective Current user
           system.Debug('ERRORLIST:::::'+errorList);
            for(ErrorLog log : errorList){
                body += '<tr><td style="-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;font-family:\'Helvetica Neue\', Helvetica, Arial, sans-serif;font-size:15px;line-height:2em;color:#444444;">&nbsp;'+ row++;
                body += '</td><td style="-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;font-family:\'Helvetica Neue\', Helvetica, Arial, sans-serif;font-size:15px;line-height:2em;color:#444444;">&nbsp;&nbsp;'+ log.name;
                body += '</td><td style="-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;font-family:\'Helvetica Neue\', Helvetica, Arial, sans-serif;font-size:15px;line-height:2em;color:#444444;">&nbsp;&nbsp;'+log.msg+'</td></tr>';                    
            }
           
           
        }
        if(statusMap.size() > 0){
             for(String statusString : statusMap.keySet())
             {
                body += '<tr><td style="-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;font-family:\'Helvetica Neue\', Helvetica, Arial, sans-serif;font-size:15px;line-height:2em;color:#444444;">&nbsp;'+ row++;
                body += '</td><td style="-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;font-family:\'Helvetica Neue\', Helvetica, Arial, sans-serif;font-size:15px;line-height:2em;color:#444444;">&nbsp;&nbsp;'+ statusString;
                body += '</td><td style="-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%;font-family:\'Helvetica Neue\', Helvetica, Arial, sans-serif;font-size:15px;line-height:2em;color:#444444;">&nbsp;&nbsp;'+statusMap.get(statusString)+'</td></tr>';  
                 
             }
        }
        body += '</tbody></table>';
        mail.htmlbody = body;
        emails.add(mail);
        Messaging.SendEmailResult [] result = Messaging.sendEmail(emails);
      // DELETE invoiceCSVDataList;
        List<Invoice_CSV_Data__c> csvList = new List<Invoice_CSV_Data__c>();
        for(Invoice_CSV_Data__c indel : [Select Id,ExternalId__c FROM Invoice_CSV_Data__c WHERE ExternalId__c =: fileName OR CreatedDate < today]){
            csvList.add(indel);
        }
        try{
            if( csvList.size() > 0){
                DELETE csvList;
            }
        }catch(exception e){
            System.debug('**** Exception: '+ e.getMessage()); 
        }
    }
    
    public class ErrorLog{
        public string name {get;set;}
        public string msg {get;set;}
        public ErrorLog(string name, string msg){
            this.name = name;
            this.msg = msg;
        }
    }
    
}