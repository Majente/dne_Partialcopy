/**************************************************
* Class: ReconciliationController
* Author: Soljit <VW>
* Date: 2019-06-11
* Description: To show mismatch invoices for particular Supiler's:
1. Filter by Month/Year
2. Filter by Reconcillation Status
****************************************************/
public class ReconciliationController {
    public Invoice__c inv {get;set;}
    public Opportunity opp {get;set;}
    public SBQQ__Subscription__c sups{get;set;}
    public Case cs{get;set;}
    public List<SBQQ__Subscription__c> subscriptionList;
    public string selectedMonth{get;set;}
    public string selectedYear{get;set;}
    public String selectStatus{get;set;}
    public String caseFilter{get;set;}
    public string disputeStatus{get;set;}
    public String diffMargin{get;set;}
    public String diffAdder{get;set;} 
    public String diffVolume{get;set;}
    public integer currentYear{get;set;}
    public String caseOwner;
    public String supp; 
    public String contractId{get;set;}
    public string InvAcc {get;set;}
    public string AdderValue{get;set;}
    public decimal AdderValueRe{get;set;}
    public string InvSite{get;set;}
    public string OppOpener{get;set;}
    public string OppCloser{get;set;}
    public String AMCloser{get;set;}
    public Transient List<List<Invoice__c>> invoices{get;set;}
    public List<List<revenueWrapper>> revenueList{get;set;}
    public string table{get;set;}
    public boolean table1;
    public boolean table2;
    public string dataTableJson;
    public integer ListSize;
    public Decimal diffAmtMargin;
    public Decimal diffAmtMarginNegative;
    public Decimal diffERAdder;
    public Decimal diffERAdderNegative;
    public Decimal diffEvVolume;
    public Decimal diffEvVolumeNegative;
    public Integer mCurrentMonth ;
    public Integer mCurrentYear ;
    public string docId{get;set;}
    public String flagStatus{get;set;}
    public List<String> statusOfReconcile {get;set;}
    public Integer dataLimit{get;set;}
    public Integer dataLimitVF{get;set;}
    public ReconciliationDataSize__c reconcileSetting{get;set;}
    public Boolean showPopupForSelected{get;set;}
    public Boolean showPopupForAll{get;set;}
    public Boolean showPopupForCaseOwner{get;set;}
    public List<ReconciliationController.revenueWrapper> selectedContracts {get;set;}
    public set<string> StoredId;
    public string SuppContractId;
     public string differenceValue{get;set;}
    /*********************************************************
@Name           : ReconciliationController
@Parameters     : 
@Reutrn type    : void
@Description    : Constructor
********************************************************/
    Public ReconciliationController(){
        //StoredId = new set<string>();
        selectedContracts = new List<ReconciliationController.revenueWrapper>();
        diffMargin = '';
        diffAdder = ''; 
        diffVolume = '';
        ListSize = 0;
        docId = '';
        contractId = '';
        differenceValue = null;
        // invoices = new List<List<Invoice__c>>();
        subscriptionList = new List<SBQQ__Subscription__c>();        
        inv = new Invoice__c();
        sups = new SBQQ__Subscription__c();
        opp = new Opportunity();
        cs = new Case();
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
        dataLimitVF = Integer.valueOf(reconcileSetting.BatchLimit__c);
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
        InvAcc = sups.SBQQ__Account__c;
        InvSite = inv.Site__c;
        OppOpener = opp.Opener__c;
        OppCloser = opp.Closer__c;
        AMCloser = opp.AM_Closer__c;
        SuppContractId = contractId;
        system.debug('SuppContractId:'+SuppContractId);
        system.debug('OppOpener:'+OppOpener);
        mCurrentMonth = String.isNotEmpty(selectedMonth) ? integer.valueOf(selectedMonth) : system.today().month();
        mCurrentYear = String.isNotEmpty(selectedYear) ? integer.valueOf(selectedYear) : system.today().year();
        if(String.isNotBlank(diffMargin) ){
            diffAmtMargin = Decimal.valueOf( diffMargin );
            diffAmtMarginNegative = -Decimal.valueOf( diffMargin );
            system.debug('diffAmtMargin ::'+diffAmtMargin);
            system.debug('diffAmtMarginNegative ::'+diffAmtMarginNegative);
        }
         if(String.isNotBlank(diffAdder) ){
            diffERAdder = Decimal.valueOf( diffAdder );
            diffERAdderNegative = -Decimal.valueOf( diffAdder);
             system.debug('diffERAdder ::'+diffERAdder);
            system.debug('diffERAdderNegative ::'+diffERAdderNegative);
        }
        if(String.isNotBlank(diffVolume) ){
            diffEvVolume = Decimal.valueOf( diffVolume );
            diffEvVolumeNegative = -Decimal.valueOf( diffVolume);
        }
        String invoiceListQuery = 'SELECT Id,Name,Outstanding_Amount__c,Amount__c,Flag__c,Dispute_Status__c,Site__r.Name,Calculation_Type__c,';
        invoiceListQuery += 'Contract__r.SBQQ__Opportunity__r.Owner.Name,Contract__r.SBQQ__Opportunity__r.Opener__c,Contract__r.SBQQ__Opportunity__r.AM_Closer__c,Contract__r.SBQQ__Opportunity__r.Closer__c,Contract__r.SBQQ__Opportunity__r.Opener__r.Name,Contract__r.SBQQ__Opportunity__r.Closer__r.Name,Contract__r.SBQQ__Opportunity__r.OwnerId,Contract__r.supplier_s_contract_ID__c,Contract__r.Id,Received_Amount__c,Payment_Month__c,';
        invoiceListQuery += 'Subscription__r.Site__r.Name,Contract__r.SBQQ__Opportunity__r.Margin__c,Subscription__r.Site__c,Subscription__r.id,Contract__r.AccountId,Contract__r.Account.Name,Difference_Amount__c,Difference_Volume__c,Difference_Adder__c,';            
        invoiceListQuery += 'Received_Adder__c,Received_Volume__c,Expected_Adder__c,Expected_Volume__c,Contract__r.Account.OwnerId,Contract__r.SBQQ__Opportunity__c';
        invoiceListQuery += ' FROM Invoice__c';
        invoiceListQuery += ' WHERE';
        invoiceListQuery += ' Supplier__c = :supp';
        if(String.isNotBlank(SuppContractId)){
            invoiceListQuery += ' AND Contract__r.supplier_s_contract_ID__c = :SuppContractId'; 
        }
        if(String.isNotBlank(InvAcc)){
            invoiceListQuery += ' AND Contract__r.AccountId = :InvAcc';
        }
        if(String.isNotBlank(InvSite)){
            invoiceListQuery += ' AND Subscription__r.Site__c = :InvSite';
        }
         if(String.isNotBlank(OppOpener)){
            invoiceListQuery += ' AND Contract__r.SBQQ__Opportunity__r.Opener__c = :OppOpener';
        }
         if(String.isNotBlank(OppCloser)){
            invoiceListQuery += ' AND Contract__r.SBQQ__Opportunity__r.Closer__c = :OppCloser';
        }
        if(string.isNotBlank(AdderValue)){
            AdderValueRe = decimal.valueOf(AdderValue);
             invoiceListQuery += ' AND Contract__r.SBQQ__Opportunity__r.Margin__c = :AdderValueRe';
        }
        if(String.isNotBlank(AMCloser)){
            invoiceListQuery += ' AND Contract__r.SBQQ__Opportunity__r.AM_Closer__c = :AMCloser';
        }
        //invoiceListQuery += ' AND CALENDAR_MONTH(Payment_Month__c) = :mCurrentMonth';
        //invoiceListQuery += ' AND CALENDAR_YEAR(Payment_Month__c) = :mCurrentYear';
        if(String.isNotBlank(diffMargin)){
            system.debug('diffMargin ::'+diffMargin);
            system.debug('diffAmtMargin ::'+diffAmtMargin);
            system.debug('diffAmtMarginNegative ::'+diffAmtMarginNegative);
            invoiceListQuery += ' AND (Difference_Amount__c > :diffAmtMargin OR Difference_Amount__c < :diffAmtMarginNegative )'; 
            system.debug('invoiceListQuery ::'+invoiceListQuery);
            invoiceListQuery += ' AND (Flag__c != :flagStatus)'; 
        }
        if(String.isNotBlank(diffAdder)){
            system.debug('diffAdder ::'+diffAdder);
            system.debug('diffERAdder ::'+diffERAdder);
            system.debug('diffERAdderNegative ::'+diffERAdderNegative);
            invoiceListQuery += ' AND (	Difference_Adder__c > :diffERAdder OR Difference_Adder__c < :diffERAdderNegative)';
            system.debug('invoiceListQuery ::'+invoiceListQuery);
        }
        if(String.isNotBlank(diffVolume)){
            invoiceListQuery += ' AND (	Difference_Volume__c > :diffEvVolume OR Difference_Volume__c < : diffEvVolumeNegative)'; 
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
        return invoiceListQuery;
    } 
    /*********************************************************
@Name           : getSearchData
@Parameters     : 
@Reutrn type    : PageReference
@Description    : Fetch Data based of Filters
********************************************************/
    public PageReference getSearchData(){
        System.debug('invoices = '+invoices);
        invoices = new List<List<Invoice__c>>();
        revenueList = new List<List<revenueWrapper>>();
        List<revenueWrapper> innerRevenues = new List<revenueWrapper>();
        
        List<Invoice__c> innerInvoices = new List<Invoice__c>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        reconcileSetting = ReconciliationDataSize__c.getOrgDefaults();
        dataLimit = Integer.valueOf(reconcileSetting.BatchLimit__c);
        String invoiceListQuery = getSearchQueryString();
        //-----------------------------------------------------------
        
        integer totalRec = 0;
        /*for(Invoice__c inv : Database.query(invoiceListQuery)){
totalRec++;
if(innerInvoices.size() > 999){
invoices.add(innerInvoices);
innerInvoices = new List<Invoice__c>();
innerInvoices.add(inv);
}else{
innerInvoices.add(inv); 
}
}
invoices.add(innerInvoices);
System.debug('invoices = '+invoices);
System.debug('invoices size = '+invoices.size());
ListSize = invoices.size();*/
        
        for(Invoice__c inv : Database.query(invoiceListQuery)){
             decimal diffAmount = inv.Outstanding_Amount__c;
            system.debug('diffamount ::'+diffAmount);
            totalRec++;
            if(differenceValue != null && string.isNotBlank(differenceValue)){
                if(diffAmount >= Decimal.valueOf(differenceValue) && Decimal.valueOf(differenceValue) >= 0){
                    if(innerRevenues.size() > 999){
                        revenueList.add(innerRevenues);
                        innerRevenues = new List<revenueWrapper>();
                        innerRevenues.add(new revenueWrapper(inv));
                    }else{
                        innerRevenues.add(new revenueWrapper(inv)); 
                    }
                }
                else if(diffAmount <= Decimal.valueOf(differenceValue) && Decimal.valueOf(differenceValue) < 0){
                    system.debug('differenceValue:: '+differenceValue);
                    if(innerRevenues.size() > 999){
                        revenueList.add(innerRevenues);
                        innerRevenues = new List<revenueWrapper>();
                        innerRevenues.add(new revenueWrapper(inv));
                    }else{
                        innerRevenues.add(new revenueWrapper(inv)); 
                    }
                }
            }else{
                if(innerRevenues.size() > 999){
                    revenueList.add(innerRevenues);
                    innerRevenues = new List<revenueWrapper>();
                    innerRevenues.add(new revenueWrapper(inv));
                }else{
                    innerRevenues.add(new revenueWrapper(inv)); 
                }
            }
        }
        System.debug('innerRevenues--->' + innerRevenues.size());
        if(innerRevenues.size() > 0){
            revenueList.add(innerRevenues);
        }
        System.debug('revenueList = '+revenueList);
        System.debug('invoices = '+invoices);
        System.debug('invoices size = '+invoices.size());
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
        List<SelectOption> statusList = new List<SelectOption>{new SelectOption('All','All'), new SelectOption('Any Error','Any Error')};
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
        List<String> queryFields = new List<String>{'Contract','Opportunity Owner','Subscription','Account Name','Invoice Number','Total Amount','Received Amount','Outstanding Amount','Payment Month','Dispute Status','Expected Adder','Received Adder','Expected volume','Received volume','Opener','Closer','Adder/Margin','% Difference Amount','Reconciliation Status'};
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
            fileRow = fileRow +','+ inv.Contract__r.SBQQ__Opportunity__r.Owner.Name;
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
            fileRow = fileRow +','+ inv.Contract__r.SBQQ__Opportunity__r.Opener__r.Name;
            fileRow = fileRow +','+ inv.Contract__r.SBQQ__Opportunity__r.Closer__r.Name;
            fileRow = fileRow +','+ inv.Contract__r.SBQQ__Opportunity__r.Margin__c;
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
        // ListSize = 0;
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
        showPopupForCaseOwner = false;
        dataLimit = 0;
        System.debug('revenueList size :: ' + revenueList.size());
        System.debug('ListSize ::' + ListSize);
        if(revenueList.isEmpty()){
            return null; 
        }
        caseOwner = cs.OwnerId;
        system.debug('cs.OwnerId:::'+cs.OwnerId);
        system.debug('caseOwner:::'+caseOwner);
        caseCreationMethod(getSearchQueryString(), null,SuppContractId,flagStatus,supp,mCurrentMonth,mCurrentYear,diffAmtMargin,diffAmtMarginNegative,selectStatus,disputeStatus,caseOwner,InvAcc,InvSite,OppOpener,OppCloser,AdderValueRe,AMCloser,diffERAdder,diffERAdderNegative,diffEvVolume,diffEvVolumeNegative);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.Case_creation_for_all_contract_label));
        cs.OwnerId = null;
        return null;        
    }
    
    /*********************************************************
@Name           : createCasesForSelected 
@Parameters     : 
@Reutrn type    : PageReference
@Description    : create cases for all contract shown on screen
********************************************************/
    public PageReference createCasesForSelected(){
        system.debug('StoredId ::'+StoredId);
        
        showPopupForSelected = false;
        Set<Id> conIdSet = new Set<Id>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<CaseIssue__c> caseIssuesList = new List<CaseIssue__c>();
        //Map<Id, List<revenueWrapper>> conIdRevenueMap = new Map<Id, List<revenueWrapper>>();
        Map<Id, Map<Id, revenueWrapper>> conIdRevenueMap = new Map<Id, Map<Id, revenueWrapper>>();
        System.debug('revenueList size :: ' + revenueList.size());
        System.debug('selectedContracts :: ' + selectedContracts);
      for(string rev : StoredId){
                System.debug('rev :: ' + rev);
                    conIdSet.add(rev);
            }
        System.debug('conIdSet :: ' + conIdSet);
        if(conIdSet.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Please_select_at_least_one_contract_label));
            return null;                        
        }
        
        dataLimit = 0;
        caseOwner = cs.OwnerId;
        system.debug('cs.OwnerId:::'+cs.OwnerId);
        system.debug('caseOwner:::'+caseOwner);
        caseCreationMethod(getSearchQueryString(), conIdSet,SuppContractId,flagStatus,supp,mCurrentMonth,mCurrentYear,diffAmtMargin,diffAmtMarginNegative,selectStatus,disputeStatus,caseOwner,InvAcc,InvSite,OppOpener,OppCloser,AdderValueRe,AMCloser,diffERAdder,diffERAdderNegative,diffEvVolume,diffEvVolumeNegative);
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.Case_creation_for_selected_contract_label));
        cs.OwnerId = null;
        return null;        
    }
    /*********************************************************
@Name           : caseCreationMethod 
@Parameters     : String invoiceListQuery, Set<Id> conIdSet,String flagStatus,String supp,Integer mCurrentMonth,Integer mCurrentYear,Decimal diffAmtMargin,Decimal diffAmtMarginNegative,String selectStatus,String disputeStatus
@Reutrn type    : void
@Description    : create case record
********************************************************/
    @future
    public static void caseCreationMethod(String invoiceListQuery, Set<Id> conIdSet,string SuppContractId,String flagStatus,String supp,Integer mCurrentMonth,Integer mCurrentYear,Decimal diffAmtMargin,Decimal diffAmtMarginNegative,String selectStatus,String disputeStatus,String caseOwner,string InvAcc,string InvSite,string OppOpener,string OppCloser,decimal AdderValueRe,string AMCloser,decimal diffERAdder,decimal diffERAdderNegative,decimal diffEvVolume,decimal diffEvVolumeNegative)
    {   
        
        Savepoint sp;
        try{            
            List<String> reconcileStatus = new List<String>{'CANCELLED','Payment Received'};
                System.debug('conIdSet-->' + conIdSet);    
            System.debug('Before invoiceListQuery ::: ' + invoiceListQuery); 
            Integer orderByIndex = invoiceListQuery.indexOf('Order by');
            //Integer yearIndex = invoiceListQuery.indexOf('mCurrentYear');
            if(invoiceListQuery.contains('CaseIssue__c = null')){
             //   invoiceListQuery = invoiceListQuery.substring(0,yearIndex) + ' Flag__c NOT IN :reconcileStatus AND CaseIssue__c = null ' + invoiceListQuery.substring(orderByIndex); 
            }
            else{
            //    invoiceListQuery = invoiceListQuery.substring(0,yearIndex) + ' Flag__c NOT IN :reconcileStatus ' + invoiceListQuery.substring(orderByIndex); 
            }
            
            if(conIdSet != null && conIdSet.size() > 0){
                orderByIndex = invoiceListQuery.indexOf('Order by');
                invoiceListQuery = invoiceListQuery.substring(0,orderByIndex) + ' AND Contract__c IN :conIdSet ' + invoiceListQuery.substring(orderByIndex);
                
            }
            System.debug('After invoiceListQuery ::: ' + invoiceListQuery); 
            System.debug('supp ::: ' + supp); 
            System.debug('mCurrentMonth ::: ' + mCurrentMonth); 
            System.debug('mCurrentYear ::: ' + mCurrentYear); 
            System.debug('reconcileStatus ::: ' + reconcileStatus); 
            System.debug('conIdSet ::: ' + conIdSet); 
            Map<Id, List<Invoice__c>> conIdRevenueMap = new Map<Id, List<Invoice__c>>();
            for(Invoice__c inv : Database.query(invoiceListQuery)){
                System.debug('inv-->' + inv.Contract__c);
                if(!conIdRevenueMap.containsKey(inv.Contract__c)){
                    conIdRevenueMap.put(inv.Contract__c, new List<Invoice__c>());
                }
                conIdRevenueMap.get(inv.Contract__c).add(inv);
            }
            System.debug('conIdRevenueMap-->' + conIdRevenueMap);
            Map<Id,Case> caseMap = new Map<Id,Case>();
            Group opsQ = [select Id,Name from Group where  Type = 'Queue' AND DeveloperNAME = 'Operations_Queue' LIMIT 1];
            Id RecordTypeIdReconcileCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Reconcile').getRecordTypeId();
            List<Invoice__c> revenueUpdateList = new List<Invoice__c>();
            Map<Invoice__c,CaseIssue__c> caseIssuesInvoiceMap = new Map<Invoice__c,CaseIssue__c>();
            Map<String,Case> allCaseRelatedToContract = new Map<String,Case>();
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
                        for(Case caseRelatedContract : [SELECT Id, Contract__c, Suppliers__c, ContractName__c, subject,Type FROM Case WHERE Contract__c IN: conIdSet]){
                           caseRelatedContract.Type = caseRelatedContract.Type.toUppercase();
                            allCaseRelatedToContract.put(caseRelatedContract.Contract__c ,caseRelatedContract);
                        }
              System.debug('allCaseRelatedToContract:: '+allCaseRelatedToContract);
                        for(Id conId : conIdRevenueMap.keySet()){                
                            Case newCase = new Case();
                            newCase.Contract__c = conId;
                            newCase.Origin = 'Reconcile';
                            if(String.isNotEmpty(caseOwner)){
                                 newCase.OwnerId = caseOwner;
                            }
                            else if(opsQ != null){
                                newCase.OwnerId = opsQ.Id;
                            }
                            newCase.RecordTypeId = RecordTypeIdReconcileCase;
                            newCase.Opportunity__c = conIdRevenueMap.get(conId).get(0).Contract__r.SBQQ__Opportunity__c;
                            newCase.AccountId = conIdRevenueMap.get(conId).get(0).Contract__r.AccountId;
                            newCase.Subject = 'Reconcile error - ' + conIdRevenueMap.get(conId).get(0).Contract__r.supplier_s_contract_ID__c;
                            newCase.Type = conIdRevenueMap.get(conId).get(0).Flag__c;
                            for(Invoice__c inv : conIdRevenueMap.get(conId)){
                                if(statusPriorityMap.get(newCase.Type) > statusPriorityMap.get(inv.Flag__c)){
                                    newCase.Type = inv.Flag__c;
                                }
                            } 
                            caseMap.put(conId,newCase);
                        }
            System.debug('caseMap.size ::: ' + caseMap.size());
            sp = Database.setSavepoint();
            Map<Id,Case> insertcaseMap = new Map<Id,Case>();
            for(case csRec: caseMap.values()){
                System.debug(' csRec.Type:: '+ csRec.Type);
                string caseType = csRec.Type.toUppercase();
                if(allCaseRelatedToContract.containsKey(csRec.Contract__c) && allCaseRelatedToContract.get(csRec.Contract__c).Type == caseType){
                    system.debug('Case already exist with this type of error!');
                }else{
                    system.debug('Else-Condition-646');
                    insertcaseMap.Put(csRec.Contract__c,csRec);
                }
            }
            system.debug('insertcaseMap.values() ::'+insertcaseMap.values());
            INSERT insertcaseMap.values();
            System.debug('Cases per contracts created successfully '); 
            
            for(Id conId : insertcaseMap.keySet()){  
                system.debug('conId ::'+conId);
                system.debug('Invoice ::'+conIdRevenueMap.get(conId)); 
                for(Invoice__c inv : conIdRevenueMap.get(conId)){
                    CaseIssue__c newCaseIssue = new CaseIssue__c();
                    newCaseIssue.Case__c = insertcaseMap.get(conId).Id;
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
                    newCaseIssue.Site__c = inv.Subscription__r.Site__c;
                    newCaseIssue.CalculationType__c = inv.Calculation_Type__c;
                    //caseIssuesList.add(newCaseIssue);
                    caseIssuesInvoiceMap.put(inv,newCaseIssue);
                }
            }
            //System.debug('caseIssuesList.size ::: ' + caseIssuesList.size());
            System.debug('caseIssuesInvoiceMap befor ::: ' + caseIssuesInvoiceMap);
            INSERT caseIssuesInvoiceMap.values();      
            System.debug('Case Issues created successfully.');        
            for(Invoice__c inv : caseIssuesInvoiceMap.keySet()){
                inv.CaseIssue__c = caseIssuesInvoiceMap.get(inv).Id;
                revenueUpdateList.add(inv);
            }		
            System.debug('caseIssuesInvoiceMap ::: ' + caseIssuesInvoiceMap);
            UPDATE revenueUpdateList;
            System.debug('Revenues updated successfully.');
            // send email on case creation
            sendEmailOnCaseCreation(caseMap.values(), null);
            System.debug('Case creation success mail sent.');
        }catch(Exception ex){
            // send error email on case creation
            System.debug('email exception-->' + ex.getMessage());
            Database.rollback(sp);
           sendEmailOnCaseCreation(null, ex);
            System.debug('Case creation error mail sent.');
        }            
    }  
    /*********************************************************
@Name           : showPopupForSelectedCase 
@Parameters     : 
@Reutrn type    : void
@Description    : show popup for selected case record
********************************************************/
    public void showPopupForSelectedCase(){
        showPopupForCaseOwner = False;
        showPopupForSelected = true;
        system.debug('showPopupForSelected ::'+showPopupForSelected);
        system.debug('selectedContracts ::'+selectedContracts);
        StoredId = new set<string>();
         for(revenueWrapper rev : selectedContracts){
                if(rev.isSelected == true){
                    system.debug('rev.inv.isSelected ::'+rev.isSelected);
                    system.debug('rev.inv.Contract__c ::'+rev.inv.Contract__c);
                    StoredId.add(rev.inv.Contract__c);
                }
            }
       system.debug('StoredId ::'+StoredId);
    }
    /*********************************************************
@Name           : sendEmailOnCaseCreation 
@Parameters     : List<Case> caseData, Exception excep
@Reutrn type    : void
@Description    : send email to logged in user when case record is created
********************************************************/
 public static void sendEmailOnCaseCreation(List<Case> caseData, Exception excep){
        ReconciliationController controller = new ReconciliationController();
            controller.selectedContracts = null;
        User currentUser = [Select Id, Email FROM User where Id = :UserInfo.getUserId() LIMIT 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{currentUser.Email}); // Current User's Email
        mail.setSubject('Case Creation Notification');
        mail.setSaveAsActivity(true);
        String body = '';
        // If error then notifying to respective Current user
        if(caseData == null && excep != null){
            body += 'There is error in Case creation process and below is the detail.'+'<br/><br/>'; 
            body += 'Error Type : ' + excep.getTypeName() + '<br/>Error Message : ' + excep.getMessage() + '<br/>Error Stack Trace : '+ excep.getStackTraceString();
            body += '<br/><br/>Thank You'+'<br/>';
            mail.setHtmlBody(body);
            emails.add(mail);    
        }
        else if(caseData.size() > 0){
            if(caseData.size() == 1){
                body += 'There is ' + caseData.size() + ' Case has been created.'+'<br/>';    
            }else if(caseData.size() > 1){
                body += 'There are ' + caseData.size() + ' Cases have been created.'+'<br/>';
            }
            body += '<br/>';
            body += 'Thank You'+'<br/>';
            mail.setHtmlBody(body);
            emails.add(mail);    
        }
        System.debug('emails--->' + emails.size());
        if(emails.size() > 0){
            Messaging.SendEmailResult [] result = Messaging.sendEmail(emails);
            System.debug('mail result--->' + result);
        }
    }
    /*********************************************************
@Name           : showPopupForAllCase 
@Parameters     : 
@Reutrn type    : void
@Description    : show popup for all cases
********************************************************/
    public void showPopupForAllCase(){
        showPopupForAll = true;
    }
     public void showPopupForOwner(){
        showPopupForCaseOwner = true;
          showPopupForSelected = False;
    }
    
    /*********************************************************
@Name           : hidePopup 
@Parameters     : 
@Reutrn type    : void
@Description    : hide popup for all cases
********************************************************/
    public void hidePopup(){
        showPopupForSelected = false;
        showPopupForAll = false;
        showPopupForCaseOwner = false;
    }
    /*********************************************************
@Name           : SelectedCheckBox 
@Parameters     : 
@Reutrn type    : void
@Description    : Store selected checkbox entries
********************************************************/
    public void SelectedCheckBox(){
        for(List<revenueWrapper> revList : revenueList){
            for(revenueWrapper rev : revList){
                if(rev.isSelected){
                    system.debug('rev.inv.isSelected ::'+rev.isSelected);
                    system.debug('rev.inv.Contract__c ::'+rev.inv.Contract__c);
                    selectedContracts.add(rev);
                }
            }
        }
        system.debug('selectedContracts ::'+selectedContracts);
    }
    /*********************************************************
@Name 			: revenueWrapper
@Parameters 	: Void
@Reutrn type 	: void
@Description 	: revenueWrapper
********************************************************/
    public class revenueWrapper{
        
        public Invoice__c inv {get;set;}
        public Boolean isSelected {get;set;}
        
        public revenueWrapper(Invoice__c inv){
            this.inv = inv;       
            this.isSelected = false;
        }
    }        
}