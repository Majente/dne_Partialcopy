/**************************************************
* Class: ReconciliationControllerCopy
* Author: Soljit <VW>
* Date: 2019-06-11
* Description: To show mismatch invoices for particular Supiler's:
1. Filter by Month/Year
2. Filter by Reconcillation Status
****************************************************/
public class ReconciliationControllerCopy {
    public Invoice__c inv {get;set;}
    public SBQQ__Subscription__c sups;
    public List<SBQQ__Subscription__c> subscriptionList;
    public string selectedMonth{get;set;}
    public string selectedYear{get;set;}
    public String selectStatus{get;set;}
    public String caseFilter{get;set;}
    public string disputeStatus{get;set;}
    public String diffMargin{get;set;}    
    public integer currentYear{get;set;}
    public String supp;    
    public Transient List<List<Invoice__c>> invoices{get;set;}
    public string table{get;set;}
    public boolean table1;
    public boolean table2;
    public string dataTableJson;
    public integer ListSize;
    public Decimal diffAmtMargin;
    public Decimal diffAmtMarginNegative;
    public Integer mCurrentMonth ;
    public Integer mCurrentYear ;
    public string docId{get;set;}
    public String flagStatus{get;set;}
    public List<String> statusOfReconcile {get;set;}
    public Integer dataLimit{get;set;}
    public ReconciliationDataSize__c reconcileSetting{get;set;}
    public Boolean showPopupForSelected{get;set;}
    public Boolean showPopupForAll{get;set;}
    public List<revenueWrapper> revenueList{get;set;}
    /*********************************************************
@Name           : ReconciliationControllerCopy
@Parameters     : 
@Reutrn type    : void
@Description    : Constructor
********************************************************/
    Public ReconciliationControllerCopy(){
        diffMargin = '';
        ListSize = 0;
        docId = '';
        // invoices = new List<List<Invoice__c>>();
        subscriptionList = new List<SBQQ__Subscription__c>();        
        inv = new Invoice__c();
        sups = new SBQQ__Subscription__c();
        table1 = false;
        table2 = false;
        // For adding zero with month like 01,02,03...
        if(system.today().month() <= 9){
            selectedMonth = String.valueOf(system.today().month());
            selectedMonth = '0'+selectedMonth ; 
        }else{
            selectedMonth = String.valueOf(system.today().month());
        }
        selectedYear = String.valueOf(system.today().year());
        currentYear = integer.valueOf(selectedYear);
        system.debug('currentYear ##'+currentYear);
        //getShowData();
        reconcileSetting = ReconciliationDataSize__c.getOrgDefaults();
        dataLimit = Integer.valueOf(reconcileSetting.BatchLimit__c);
        showPopupForSelected = false;
        showPopupForAll = false;
    }
    /*********************************************************
@Name           : getSearchQueryString
@Parameters     : 
@Reutrn type    : String
@Description    : Return Query Statement
********************************************************/
    public String getSearchQueryString(){
        //---------------Dynamic SOQL For Retrieve Invoice List--------------------------------------------
        statusOfReconcile = new List<string>{'CANCELLED','Payment Received', 'All'};
            flagStatus = 'Payment Not Received';
        supp = inv.Supplier__c;
        mCurrentMonth = String.isNotEmpty(selectedMonth) ? integer.valueOf(selectedMonth) : system.today().month();
        mCurrentYear = String.isNotEmpty(selectedYear) ? integer.valueOf(selectedYear) : system.today().year();
        
        if(String.isNotBlank(diffMargin) ){
            diffAmtMargin = Decimal.valueOf( diffMargin );
            diffAmtMarginNegative = -Decimal.valueOf( diffMargin );
        }
        String invoiceListQuery = 'SELECT Id,Name,Outstanding_Amount__c,Amount__c,Flag__c,Dispute_Status__c,Site__r.Name,CaseIssue__c,';
        invoiceListQuery += 'Contract__r.ContractNumber,Contract__r.supplier_s_contract_ID__c,Contract__r.Id,Received_Amount__c,Payment_Month__c,Supplier__r.Name,';
        invoiceListQuery += 'Subscription__r.name,Subscription__r.Site__r.Name,Subscription__r.Site__c,Subscription__r.id,Contract__r.Account.Name,Difference_Amount__c,';            
        invoiceListQuery += 'Received_Adder__c,Received_Volume__c,Expected_Adder__c,Expected_Volume__c,Contract__r.Account.OwnerId,Contract__r.SBQQ__Opportunity__c';
        invoiceListQuery += ' FROM Invoice__c';
        invoiceListQuery += ' WHERE';
        invoiceListQuery += ' Supplier__c = :supp';
        invoiceListQuery += ' AND CALENDAR_MONTH(Payment_Month__c) = :mCurrentMonth';
        invoiceListQuery += ' AND CALENDAR_YEAR(Payment_Month__c) = :mCurrentYear';
        IF(String.isNotBlank(diffMargin)){
            invoiceListQuery += ' AND (Difference_Amount__c > :diffAmtMargin OR Difference_Amount__c < :diffAmtMarginNegative )'; 
            invoiceListQuery += ' AND (Flag__c != :flagStatus)'; 
        }
        if(!(selectStatus == 'All' && disputeStatus == 'All' )) {
            if(selectStatus != 'All' && selectStatus == 'Any error') {
                invoiceListQuery += ' AND Flag__c NOT IN :statusOfReconcile';
            }
            else if(selectStatus != 'All'){
                invoiceListQuery += ' AND Flag__c  = :selectStatus'; 
            }
            if(disputeStatus != 'All') {
                invoiceListQuery += ' AND Dispute_Status__c = :disputeStatus';
            }
        }
        if(caseFilter != 'All') {
            invoiceListQuery += ' AND CaseIssue__c = null'; 
        }       
        if(dataLimit > 0){
            invoiceListQuery += ' Order by Contract__r.supplier_s_contract_ID__c LIMIT :dataLimit ';  
        }
        else{
            invoiceListQuery += ' Order by Contract__r.supplier_s_contract_ID__c';
        }       
        System.debug('###>  invoiceListQuery = '+ invoiceListQuery);
        system.debug('selectStatus:::'+selectStatus);
    
        return invoiceListQuery;
    } 
    /*********************************************************
@Name           : getSearchData
@Parameters     : 
@Reutrn type    : PageReference
@Description    : Fetch Data based of Filters
********************************************************/
    public PageReference getSearchData(){
        revenueList = new List<revenueWrapper>();
        reconcileSetting = ReconciliationDataSize__c.getOrgDefaults();
        dataLimit = Integer.valueOf(reconcileSetting.BatchLimit__c);
        String invoiceListQuery = getSearchQueryString();
        Map<Id,List<Invoice__c>> contractInvoice = new  Map<Id,List<Invoice__c>>();
        Map<Id,String> contractNameMap = new  Map<Id,String>();
        //-----------------------------------------------------------
        
        integer totalRec = 0;
        for(Invoice__c inv : Database.query(invoiceListQuery)){
            
            if(!contractInvoice.containsKey(inv.Contract__c))
            {
                contractInvoice.put(inv.Contract__c,new List<Invoice__c>());
                contractNameMap.put(inv.Contract__c,inv.Contract__r.supplier_s_contract_ID__c);
            }
            contractInvoice.get(inv.Contract__c).add(inv);
        }
        
        for(Id contractid : contractInvoice.keySet())
        {
            revenueList.add(new revenueWrapper(contractInvoice.get(contractid),contractid,contractNameMap.get(contractid)));
        }
        
        System.debug('revenueList## '+JSON.serialize(revenueList));
        ListSize = revenueList.size();       
        
        return null;
        
    }
    
    /*********************************************************
@Name           : getMonthOptions
@Parameters     : 
@Reutrn type    : List<SelectOption>
@Description    : Populate Month Picklist For Filter
********************************************************/
    public List<SelectOption> getMonthOptions() {
        List<SelectOption> monthOptions = new List<SelectOption>();
        monthOptions.add(new SelectOption('01','Jan'));
        monthOptions.add(new SelectOption('02','Feb'));
        monthOptions.add(new SelectOption('03','Mar'));
        monthOptions.add(new SelectOption('04','Apr'));
        monthOptions.add(new SelectOption('05','May'));
        monthOptions.add(new SelectOption('06','Jun'));
        monthOptions.add(new SelectOption('07','Jul'));
        monthOptions.add(new SelectOption('08','Aug'));
        monthOptions.add(new SelectOption('09','Sep'));
        monthOptions.add(new SelectOption('10','Oct'));
        monthOptions.add(new SelectOption('11','Nov'));
        monthOptions.add(new SelectOption('12','Dec'));
        
        return monthOptions;
    }
    /*********************************************************
@Name           : getYearsOptions
@Parameters     : 
@Reutrn type    : List<SelectOption>
@Description    : Populate Year Picklist For Filter
********************************************************/
    public List<SelectOption> getYearsOptions() {
        List<SelectOption> yearOptions = new List<SelectOption>();
        yearOptions.add(new SelectOption(string.valueOf(currentYear+5),string.valueOf(currentYear+5)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear+4),string.valueOf(currentYear+4)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear+3),string.valueOf(currentYear+3)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear+2),string.valueOf(currentYear+2)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear+1),string.valueOf(currentYear+1)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear),string.valueOf(currentYear)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear-1),string.valueOf(currentYear-1)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear-2),string.valueOf(currentYear-2)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear-3),string.valueOf(currentYear-3)));
        yearOptions.add(new SelectOption(string.valueOf(currentYear-4),string.valueOf(currentYear-4)));
        
        return yearOptions;
    }
    /*********************************************************
@Name           : getStatusOption
@Parameters     : 
@Reutrn type    : List<SelectOption>
@Description    : Populate Status Picklist For Filter
********************************************************/
    public List<SelectOption> getStatusOption(){
        List<SelectOption> statusList = new List<SelectOption>{new SelectOption('All','All'), new SelectOption('Any Error','Any Error') };
             Schema.DescribeFieldResult fieldResult = Invoice__c.Flag__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
for( Schema.PicklistEntry pickListVal : ple){
statusList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
}
            return statusList;
    }
    Public List<SelectOption> getDisputeOption(){
        List<SelectOption> statusList = new List<SelectOption>{new SelectOption('All','All') };
            Schema.DescribeFieldResult fieldResult = Invoice__c.Dispute_Status__c.getDescribe();  
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            statusList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
        }
        return statusList;
    }
    Public List<SelectOption> getCaseFilterOption(){
        List<SelectOption> statusList = new List<SelectOption>{new SelectOption('All','All'),new SelectOption('Case not created','Case not created')};
            return statusList;
    }    
    /*********************************************************
@Name           : DownloadSelected
@Parameters     : 
@Reutrn type    : pagereference
@Description    : download selected checkbox
********************************************************/
    public PageReference DownloadSelected(){
        String generatedCSVFile ='';
        docId = '';
        List<String> queryFields = new List<String>{'Contract','Subscription','Account Name','Invoice Number','Total Amount','Received Amount','Outstanding Amount','Payment Month','Dispute Status','Expected Adder','Received Adder','Expected volume','Received volume','% Difference Amount','Reconciliation Status'};
            String fileRow = '';
        
        for(String f : queryFields){
            generatedCSVFile = generatedCSVFile + f +',';
        }
        dataLimit = 0;
        String invoiceListQuery = getSearchQueryString();
        
        system.debug('invoiceListQuery## '+invoiceListQuery);
        generatedCSVFile = generatedCSVFile.removeEnd(',')+'\n';
        
        for(Invoice__c inv : Database.query(invoiceListQuery)){
            fileRow = '';
            fileRow = fileRow +','+'"'+ inv.Contract__r.supplier_s_contract_ID__c +'"';
            fileRow = fileRow +','+'"'+ inv.Subscription__r.Site__r.Name +'"';
            fileRow = fileRow +','+'"'+ inv.Contract__r.Account.Name +'"';
            fileRow = fileRow +','+ inv.Name;
            fileRow = fileRow +','+ inv.Amount__c;
            fileRow = fileRow +','+ inv.Received_Amount__c;
            fileRow = fileRow +','+ inv.Outstanding_Amount__c;
            fileRow = fileRow +','+ inv.Payment_Month__c.format();
            fileRow = fileRow +','+ inv.Dispute_Status__c;
            fileRow = fileRow +','+ inv.Expected_Adder__c;
            fileRow = fileRow +','+ inv.Received_Adder__c;
            fileRow = fileRow +','+ inv.Expected_Volume__c;
            fileRow = fileRow +','+ inv.Received_Volume__c;
            fileRow = fileRow +','+ inv.Difference_Amount__c;
            fileRow = fileRow +','+ inv.Flag__c;
            fileRow = fileRow.replaceFirst(',','');
            generatedCSVFile = generatedCSVFile + fileRow + '\n';
        }
        
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        Document d = new Document();
        String fName = 'Invoice Reconciliation';  
        d.name = fName + String.valueOf( (Math.random() * 10)) + '.csv';
        d.ContentType = 'text/csv';
        d.body = csvBlob;
        d.folderId = UserInfo.getUserId();
        
        insert d;
        System.debug('Document ##'+ d);
        docId = d.Id;
        ListSize = 0;
        //getSearchData();
        /*PageReference pg = new PageReference('/servlet/servlet.FileDownload?file=' + d.Id);
pg.setRedirect(false);*/       
        return null;   
    }
    
    /*********************************************************
@Name           : subscriptionData
@Parameters     : 
@Reutrn type    : PageReference
@Description    : To get subscription data list
********************************************************/
    Public PageReference subscriptionData(){
        
        system.debug('==='+sups);
        subscriptionList = [SELECT Id,Name,Dispute_Status__c,Dispute_Resolution_Date__c,
                            Residual_Amount__c,Upfront_Amount__c,SBQQ__Contract__r.ContractNumber,
                            Site__r.Name,Supplier__r.Name,SBQQ__Contract__r.Account.Name
                            FROM SBQQ__Subscription__c Where supplier__c = :sups.Supplier__c AND Dispute_Status__c = 'In Dispute'];
        return null;
    }
    
    /*********************************************************
@Name           : CheckRadioValue
@Parameters     : 
@Reutrn type    : PageReference
@Description    : TO check radio value
********************************************************/
    public PageReference CheckRadioValue() {
        invoices.clear();
        subscriptionList.clear();
        if(table == '1'){
            table1 = true;
            table2 = false;
            
        }
        else{
            table2 = true;
            table1 = false;
            
        }
        return null;
    }
    
    /*********************************************************
@Name           : getHasInvoices
@Parameters     : 
@Reutrn type    : boolean
@Description    : 
********************************************************/  
    public boolean getHasInvoices() {
        
        return ListSize > 0;
    }
    
    /*********************************************************
@Name           : changeDifferencePercent
@Parameters     : 
@Reutrn type    : 
@Description    : to update the Difference margin on vf Page
********************************************************/  
    public void changeDifferencePercent(){
        
        if(selectStatus == 'Payment Not Received'){
            diffMargin = null;
        }
        
    }
    
    /*********************************************************
@Name           : createCasesForAll
@Parameters     : 
@Reutrn type    : PageReference
@Description    : create cases for all contract shown on screen
********************************************************/
    public PageReference createCasesForAll(){
        showPopupForAll = false;
        dataLimit = 0;
        System.debug('revenueList size :: ' + revenueList.size());
        if(revenueList.isEmpty()){
            return null; 
        }
        caseCreationMethod(getSearchQueryString(), null,flagStatus,supp,mCurrentMonth,mCurrentYear,diffAmtMargin,diffAmtMarginNegative,selectStatus,disputeStatus);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Cases for the all contract will be created. Please check after some time.'));
        return null;        
    }
    
    /*********************************************************
@Name           : createCasesForSelected 
@Parameters     : 
@Reutrn type    : PageReference
@Description    : create cases for all contract shown on screen
********************************************************/
    public PageReference createCasesForSelected(){
        showPopupForSelected = false;
        Set<Id> conIdSet = new Set<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<CaseIssue__c> caseIssuesList = new List<CaseIssue__c>();
        //Map<Id, List<revenueWrapper>> conIdRevenueMap = new Map<Id, List<revenueWrapper>>();
        Map<Id, Map<Id, revenueWrapper>> conIdRevenueMap = new Map<Id, Map<Id, revenueWrapper>>();
        System.debug('revenueList size :: ' + revenueList.size());
        for(revenueWrapper revList : revenueList){
            if(revList.isSelected){
                conIdSet.add(revList.contractId);
                
            }
        }  
        if(conIdSet.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please select atleast one contract.'));
            return null;                        
        }
        
        dataLimit = 0;
        caseCreationMethod(getSearchQueryString(), conIdSet,flagStatus,supp,mCurrentMonth,mCurrentYear,diffAmtMargin,diffAmtMarginNegative,selectStatus,disputeStatus);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Cases for the selected contract will be created. Please check after some time.'));
        return null;        
    }
    
    @future
    public static void caseCreationMethod(String invoiceListQuery, Set<Id> conIdSet,String flagStatus,String supp,Integer mCurrentMonth,Integer mCurrentYear,Decimal diffAmtMargin,Decimal diffAmtMarginNegative,String selectStatus,String disputeStatus)
    {   
        
        System.debug('Before invoiceListQuery ::: ' + invoiceListQuery);          
        if(conIdSet != null && conIdSet.size() > 0){
            Integer index = invoiceListQuery.indexOf('Order by');
            
            invoiceListQuery = invoiceListQuery.substring(0,index) + 'AND Contract__c IN :conIdSet ' + invoiceListQuery.substring(index);
            System.debug('After invoiceListQuery ::: ' + invoiceListQuery);  
        }
        
        Map<Id, List<Invoice__c>> conIdRevenueMap = new Map<Id, List<Invoice__c>>();
        for(Invoice__c inv : Database.query(invoiceListQuery)){
                if(!conIdRevenueMap.containsKey(inv.Contract__c)){
                    conIdRevenueMap.put(inv.Contract__c, new List<Invoice__c>());
                }
                conIdRevenueMap.get(inv.Contract__c).add(inv);
        }
        Map<Id,Case> caseMap = new Map<Id,Case>();
        Group opsQ = [select Id,Name from Group where  Type = 'Queue' AND DeveloperNAME = 'Operations_Queue' LIMIT 1];
        Id RecordTypeIdReconcileCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Reconcile').getRecordTypeId();
        List<Invoice__c> revenueUpdateList = new List<Invoice__c>();
        Map<Invoice__c,CaseIssue__c> caseIssuesInvoiceMap = new Map<Invoice__c,CaseIssue__c>();     
        Map<String,Integer> statusPriorityMap = new Map<String,Integer>{
             ConstantString.INVOICE_LESS_AMOUNT  => 0,
             ConstantString.INVOICE_GREATER_AMOUNT  => 1,
             ConstantString.INVOICE_LESS_ADDER  => 2,
             ConstantString.INVOICE_GREATER_ADDER  => 3,
             ConstantString.INVOICE_LESS_VOLUME  => 4,
             ConstantString.INVOICE_GREATER_VOLUME  => 5,
             ConstantString.INVOICE_CANCELLED  => 6,
             ConstantString.INVOICE_NOT_APPROVED  => 7,
             ConstantString.INVOICE_NOT_RECEIVED_PAYMENT  => 8,
             ConstantString.INVOICE_RECEIVED_PAYMENT  => 9
        };
        for(Id conId : conIdRevenueMap.keySet()){
            
            Case newCase = new Case();
            newCase.Contract__c = conId;
                newCase.Origin = 'Reconcile';
            if(opsQ != null){
                newCase.OwnerId = opsQ.Id;
            }
            newCase.RecordTypeId = RecordTypeIdReconcileCase;
            newCase.Opportunity__c = conIdRevenueMap.get(conId).get(0).Contract__r.SBQQ__Opportunity__c;
            newCase.AccountId = conIdRevenueMap.get(conId).get(0).Contract__r.AccountId;
            newCase.Subject = 'Reconile error - ' + conIdRevenueMap.get(conId).get(0).Contract__r.supplier_s_contract_ID__c;
            newCase.Type = conIdRevenueMap.get(conId).get(0).Flag__c;
            for(Invoice__c inv : conIdRevenueMap.get(conId)){
                if(statusPriorityMap.get(newCase.Type) > statusPriorityMap.get(inv.Flag__c)){
                     newCase.Type = inv.Flag__c;
                }
            }            
            caseMap.put(conId,newCase);
        }
        System.debug('caseMap.size ::: ' + caseMap.size());
        INSERT caseMap.values();
        System.debug('Cases per contracts created successfully ');        
        for(Id conId : conIdRevenueMap.keySet()){            
            for(Invoice__c inv : conIdRevenueMap.get(conId)){
                CaseIssue__c newCaseIssue = new CaseIssue__c();
                newCaseIssue.Case__c = caseMap.get(conId).Id;
                newCaseIssue.Subscription__c = inv.Subscription__c;
                newCaseIssue.ErrorType__c = inv.Flag__c;
                newCaseIssue.AccountOwner__c = inv.Contract__r.Account.OwnerId;
                newCaseIssue.ExpectedAmount__c = inv.Amount__c;
                newCaseIssue.ReceivedAmount__c = inv.Received_Amount__c;
                newCaseIssue.ExpectedFee__c = inv.Expected_Adder__c;
                newCaseIssue.ReceivedFee__c = inv.Received_Adder__c;
                newCaseIssue.ExpectedVolume__c = inv.Expected_Volume__c;
                newCaseIssue.ReceivedVolume__c = inv.Received_Volume__c;
                newCaseIssue.Status__c = 'Open';
                newCaseIssue.Site__c = inv.Subscription__r.Site__C;
                //caseIssuesList.add(newCaseIssue);
                caseIssuesInvoiceMap.put(inv,newCaseIssue);
            }
        }
      //System.debug('caseIssuesList.size ::: ' + caseIssuesList.size());
        System.debug('caseIssuesInvoiceMap befor ::: ' + caseIssuesInvoiceMap);
        INSERT caseIssuesInvoiceMap.values();      
        System.debug('Case Subscriptions created successfully.');        
        for(Invoice__c inv : caseIssuesInvoiceMap.keySet()){
            inv.CaseIssue__c = caseIssuesInvoiceMap.get(inv).Id;
            revenueUpdateList.add(inv);
        }       
        System.debug('caseIssuesInvoiceMap ::: ' + caseIssuesInvoiceMap);
        UPDATE revenueUpdateList;
    }  
    
    public void showPopupForSelectedCase(){
        showPopupForSelected = true;
    }
    
    public void showPopupForAllCase(){
        showPopupForAll = true;
    }
    public void hidePopup(){
        showPopupForSelected = false;
        showPopupForAll = false;
    }
    
    /*********************************************************
@Name           : revenueWrapper
@Parameters     : Void
@Reutrn type    : void
@Description    : revenueWrapper
********************************************************/
    public class revenueWrapper{
        
        public Boolean isSelected {get;set;}
        public Integer rowSpan {get;set;}
        public String contractId {get;set;}
        public String Name {get;set;}
        public List<Invoice__c> contractInvoice{get;set;}
        
        public revenueWrapper(List<Invoice__c> invoiceList, String contractId,String contractName){
            this.contractId = contractId; 
            this.contractInvoice = invoiceList;
            this.isSelected = false;
            this.rowSpan = invoiceList.size();
            this.Name = contractName;
        }
    }        
}