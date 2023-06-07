/**************************************************
* Class: MonthlyInvoiceCompareController
* Author: Soljit <VW>
* Date: 2019-06-17
****************************************************/
public with sharing class MonthlyInvoiceCompareController {
    
    
    public String csvFileBody{get;set;}
    public String csvFileNameHidden{get;set;}
    public Boolean readSuccess {get;set;}
    public Boolean isValidCSV {get;set;}
    public Boolean showInsert {get;set;}
    public boolean clearList {get;set;}
    public  List<String> DataColumn{get;set;}
    public  List<jsonReadWrapper> priceListDataLines{get;set;} 
    public  List<Invoice_CSV_Data__c> csvDataList{get;set;}
    public set<Id> invoiceID{get;set;}
    public String newCSVfileName{get;set;}
    public integer count{get;set;}
    //Private  List<List<Invoice_CSV_Data__c>> csvAllDataList ;   
    
    
    /*********************************************************
@Name 			: MonthlyInvoiceCompareController
@Parameters 	: ApexPages.StandardController
@Reutrn type 	: void
@Description 	: constructor
********************************************************/
    public MonthlyInvoiceCompareController(){
        readSuccess = false;
        showInsert = false;
        clearList = true;
        count= 0;
        csvDataList = new List<Invoice_CSV_Data__c>();
        //csvAllDataList = new List<List<Invoice_CSV_Data__c>>();
        csvFileBody = '' ;
        csvFileNameHidden='';
        priceListDataLines = new List<jsonReadWrapper>();
        isValidCSV = true;
          DataColumn = label.Import_Supplier_Invoice_Template.split(',');
     }
    /*********************************************************
@Name 			: uploadInvoice
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Invoice upload
********************************************************/
    public void uploadInvoice(){
        try {
            if(!Test.isRunningTest())
            {
                if(clearList){
                    newCSVfileName = csvFileNameHidden +  (Math.random() * 10);
                    csvDataList.clear();
                    count = 0;
                    clearList = false;
                }
               
            }
            isValidCSV = true;
            priceListDataLines.clear();
            if(csvFileBody==null){
                System.debug('Error :: Records not found ');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Please_select_a_CSV_file));
                return;
            }
            priceListDataLines = (List<jsonReadWrapper>)JSON.deserialize(csvFileBody, List<jsonReadWrapper>.class); 
            csvFileBody ='';
            System.debug('priceListDataLines.size() === ' + priceListDataLines.size());
            for(Integer i=0;i<priceListDataLines.size();i++){
                System.debug('inside For Loop ' + priceListDataLines.size());
               Invoice_CSV_Data__c invCsvRecord = new Invoice_CSV_Data__c();
                if(priceListDataLines[i].paymentDate.contains('/')){
                    String[] ddmmyy = priceListDataLines[i].paymentDate.normalizeSpace().split('/');
                    invCsvRecord.Payment_Month__c = Date.newInstance(integer.valueOf(ddmmyy[2]), integer.valueOf(ddmmyy[1]), integer.valueOf(ddmmyy[0]));
                     System.debug('first if Condition ' + priceListDataLines.size());
                }
                else if(priceListDataLines[i].paymentDate.contains('-')){
                     String[] ddmmyy = priceListDataLines[i].paymentDate.normalizeSpace().split('-');
                    invCsvRecord.Payment_Month__c = Date.newInstance(integer.valueOf(ddmmyy[2]), integer.valueOf(ddmmyy[1]), integer.valueOf(ddmmyy[0]));
                     System.debug('Else if Condition ' + priceListDataLines.size());
                }
                if(priceListDataLines[i].calculationType.normalizeSpace().equalsIgnoreCase(ConstantString.INVOICE_TYPE_UPFRONT)){
                    invCsvRecord.Calculation_Type__c = ConstantString.INVOICE_TYPE_UPFRONT;
                    System.debug('second if Condition ' + priceListDataLines.size());
                 }
                else if(priceListDataLines[i].calculationType.normalizeSpace().equalsIgnoreCase(ConstantString.INVOICE_TYPE_RESIDUAL)){
                    invCsvRecord.Calculation_Type__c = ConstantString.INVOICE_TYPE_RESIDUAL;  
                    System.debug('else if Condition ' + priceListDataLines.size());
                }
                else{
                    invCsvRecord.Calculation_Type__c = priceListDataLines[i].calculationType.normalizeSpace(); 
                    System.debug('else Condition ' + priceListDataLines.size());
                }
                invCsvRecord.Commodity__c = priceListDataLines[i].commodity.normalizeSpace();
                System.debug('commodity Condition ' + priceListDataLines.size());
                invCsvRecord.Contract_ID__c = priceListDataLines[i].contractId.normalizeSpace();
                System.debug('Contract Condition ' + priceListDataLines.size());
                if(String.isNotBlank(priceListDataLines[i].contractUsage)){
                    invCsvRecord.LDC_Contracted_Usage__c = double.valueOf(priceListDataLines[i].contractUsage.normalizeSpace().replaceall(',',''));   
                    System.debug('Contract usage Condition ' + priceListDataLines.size());
                 }
                else{
                    invCsvRecord.LDC_Contracted_Usage__c = 0;
                    System.debug('Contract usage Condition ' + priceListDataLines.size());
                }
                if(String.isNotBlank(priceListDataLines[i].actualUsage)){
                    invCsvRecord.LDC_Actual_Usage__c = Double.valueOf(priceListDataLines[i].actualUsage.normalizeSpace().replaceall(',',''));  
                    System.debug('Actual usage Condition ' + priceListDataLines.size());
                 }
                else{
                    invCsvRecord.LDC_Actual_Usage__c = 0;
                    System.debug('Actual usage Condition ' + priceListDataLines.size());
                 }
                invCsvRecord.LDC_Account_Number__c = priceListDataLines[i].site.normalizeSpace();
                if(String.isNotBlank(priceListDataLines[i].adder)){
                    invCsvRecord.Adder__c = Double.valueOf(priceListDataLines[i].adder.normalizeSpace().replace('$', '').replaceall(',','')); 
                     System.debug('Adder usage Condition ' + priceListDataLines.size());
                 }
                else{
                    invCsvRecord.Adder__c = 0;  
                    System.debug('Adder usage Condition ' + priceListDataLines.size());
                 }
                if(String.isNotBlank(priceListDataLines[i].amount)){
                    invCsvRecord.Amount__c = Double.valueOf(priceListDataLines[i].amount.normalizeSpace().replace('$', '').replaceall(',','')); 
                    System.debug('Amount usage Condition ' + priceListDataLines.size());
                  }
                else{
                    invCsvRecord.Amount__c = 0;  
                    System.debug('Amount usage Condition ' + priceListDataLines.size());
                 }
                invCsvRecord.Supplier_Name__c = priceListDataLines[i].supplier.normalizeSpace();
                System.debug('Status ' + priceListDataLines[i].status.normalizeSpace());
                if(priceListDataLines[i].status.normalizeSpace().equalsIgnoreCase('CANCELLED')){
                   invCsvRecord.LDC_Status__c = 'CANCELLED';
                  }
                else{
                    invCsvRecord.LDC_Status__c = priceListDataLines[i].status.normalizeSpace();
                 }
                invCsvRecord.ExternalId__c = newCSVfileName;
                csvDataList.add(invCsvRecord);
                showInsert = true;
                
                
              }
            System.debug('New file Name of CSV:::'+newCSVfileName);
            System.debug('csvDataList Before insert:::'+csvDataList);
            INSERT csvDataList;
            count += csvDataList.size();
            System.debug('csvDataList after insert:::'+csvDataList);
            csvDataList.clear();
            }catch(Exception e) {
              isValidCSV = false;
                showInsert = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.CSV_file_data_error_label + e.getMessage());
            ApexPages.addMessage(errorMessage);
        } 
    }
/*********************************************************
@Name 			: errorMsgCsv
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Method to show error when data row are greater than 10000
********************************************************/

    public void errorMsgCsv(){
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, System.Label.CSV_upload_label);    
        ApexPages.addMessage(errorMessage);
    }
    
    public void addLastBatchRecord(){
        if(csvDataList.size() > 0){
            readSuccess = True;
        }
    }    
        
    
/*********************************************************
@Name 			: saveData
@Parameters 	: 
@Reutrn type 	: void
@Description 	: data save
********************************************************/
    public void saveData() 
    {  
        
        try {   
             InvoiceCSVBatchSize__c batchSize =  InvoiceCSVBatchSize__c.getOrgDefaults();
             System.debug('DEBUG BEFORE INSERT'+csvDataList.size());
            System.debug('DEBUG BEFORE INSERT batchSize'+batchSize);
            if(count > 0){
               // INSERT csvDataList;
                InvoiceCSVDataBatch invCSVDataBC = new InvoiceCSVDataBatch(newCSVfileName);
                if(batchSize.Id != null){
                    Database.executeBatch(invCSVDataBC, (Integer)batchSize.BatchSize__c);  
                }else{
                   Database.executeBatch(invCSVDataBC, 1000);  
                }
               
                System.debug(' DEBUG AFTER INSERT'+csvDataList.size());
            }
             count = 0;
           /* Map<String,Integer> statusMap = getStatusOption();
            Map<String,Integer> invEntrystatusMap = getInvEntryStatusOption();
            for(Invoice_CSV_Data__c invCsv : [Select Id, Status__c from Invoice_CSV_Data__c where  Id IN : csvDataList]){
                if(statusMap.containsKey(invCsv.Status__c)){
                    Integer i = statusMap.get(invCsv.Status__c);
                    i++;
                    statusMap.put(invCsv.Status__c,i);
                }
                else if(invEntrystatusMap.containsKey(invCsv.Status__c)){
                    Integer i = invEntrystatusMap.get(invCsv.Status__c);
                    i++;
                    invEntrystatusMap.put(invCsv.Status__c,i);
                }
            }
            for(String status : statusMap.keySet()){
                ApexPages.Message AmtLessThanExpected = new ApexPages.Message(ApexPages.severity.INFO, status + ' --> ' + statusMap.get(status));
            	ApexPages.addMessage(AmtLessThanExpected);
            }
            for(String status : invEntrystatusMap.keySet()){
                ApexPages.Message AmtLessThanExpected = new ApexPages.Message(ApexPages.severity.INFO, status + ' --> ' + invEntrystatusMap.get(status));
            	ApexPages.addMessage(AmtLessThanExpected);
            }*/
            ApexPages.Message successMessage = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.CSVImportSuccessMessage);
            ApexPages.addMessage(successMessage);
            csvDataList.clear();
            
        } 
        catch(Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, Label.An_error_has_occured_while_savinupdating_data + e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
    }
  
 /*********************************************************
@Name 			: getStatusOption
@Parameters 	: 
@Reutrn type 	: Map<String,Integer>
@Description 	: Method to get the values from Picklist Field of Revenue(Invoice)
********************************************************/    
   public Map<String,Integer> getStatusOption(){
       Map<String,Integer> statusMap = new  Map<String,Integer>();
        Schema.DescribeFieldResult fieldResult = Invoice__c.Flag__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            statusMap.put(pickListVal.getLabel(),0);
        }
        return statusMap;
    }  

/*********************************************************
@Name 			: getInvEntryStatusOption
@Parameters 	: 
@Reutrn type 	: Map<String,Integer>
@Description 	: Method to get the values from Picklist Field of Invoice Entry Object
********************************************************/  
   public Map<String,Integer> getInvEntryStatusOption(){
       Map<String,Integer> invEntrystatusMap = new  Map<String,Integer>();
        Schema.DescribeFieldResult fieldResult = Invoice_Entries__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            invEntrystatusMap.put(pickListVal.getLabel(),0);
        }
        return invEntrystatusMap;
    }  

/*********************************************************
@Name 			: resetClearList
@Parameters 	: 
@Reutrn type 	: void
@Description 	: Method to clear the List
********************************************************/  
    public void resetClearList(){
        clearList = true;
    }
    /*********************************************************
@Name 			: jsonReadWrapper
@Parameters 	: 
@Reutrn type 	: 
@Description 	: wrapper class
********************************************************/
    public class jsonReadWrapper{
        public String adder {get;set;}
        public String amount {get;set;}
        public String calculationType {get;set;}
        public String contractId {get;set;}      
        public String commodity {get;set;}
        public String site {get;set;}
        public String actualUsage {get;set;}
        public String contractUsage {get;set;}
        public String status {get;set;}
        public String paymentDate {get;set;}
        public String supplier {get;set;}
    }
}