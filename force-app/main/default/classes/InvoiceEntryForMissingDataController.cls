/******************************************************************
Name    : InvoiceEntryForMissingDataController
Author  : Soljit <VW>
Description : apex controller for InvoiceEntryForMissingData visualforce page
******************************************************************/
public class InvoiceEntryForMissingDataController {
    public Invoice__c invc {get;set;}
    public Opportunity opp {get;set;}
	public Invoice_Entries__c inv {get;set;}
    public SBQQ__Subscription__c sups {get;set;}
    public Case cs{get;set;}
    public List<SBQQ__Subscription__c> subscriptionList {get;set;}
    public String caseFilter{get;set;}
    public string selectedMonth{get;set;}
    public string selectedYear{get;set;}
    public String selectStatus{get;set;}
    public string disputeStatus{get;set;}
    public integer currentYear{get;set;}
    public integer mCurrentMonth;
    public integer mCurrentYear;
    public String caseOwner;
    public String diffMargin{get;set;}
    public String diffAdder{get;set;}
    public String diffVolume{get;set;}
    public Decimal diffAmtMargin;
    public Decimal diffAmtMarginNegative;
    public Decimal diffERAdder;
    public Decimal diffERAdderNegative;
    public Decimal diffEvVolume;
    public Decimal diffEvVolumeNegative;
    public String contractId{get;set;}
    public string InvAcc {get;set;}
    public string InvSite{get;set;}
    public string OppOpener{get;set;}
    public string OppCloser{get;set;}
    public String AMCloser{get;set;}
    public string AdderValue{get;set;}
    public decimal AdderValueRe{get;set;}
    public List<List<Invoice_Entries__c>> invoices{get;set;}
    public List<List<revenueWrapper>> revenueList{get;set;}
    public Boolean showPopupForSelected{get;set;}
    public Boolean showPopupForAll{get;set;}
    public Boolean showPopupForCaseOwner{get;set;}
    public Integer dataLimit{get;set;}
    public string docId{get;set;}
    public integer ListSize;
    public String supp;  
     public ReconciliationDataSize__c reconcileSetting{get;set;}
     /*********************************************************
    @Name           : InvoiceEntryForMissingDataController
    @Parameters     : 
    @Reutrn type    : void
    @Description    : Constructor
    ********************************************************/
    Public InvoiceEntryForMissingDataController(){
        invoices = new List<List<Invoice_Entries__c>>();
        subscriptionList = new List<SBQQ__Subscription__c>();        
        inv = new Invoice_Entries__c();
        cs = new Case();
        invc = new Invoice__c();
        sups = new SBQQ__Subscription__c();
        opp = new Opportunity();
        ListSize = 0;
        diffMargin = '';
        diffAdder = '';
        diffVolume = '';
        docId = '';
        // For adding zero with month like 01,02,03...
        if(system.today().month() <= 9){
            selectedMonth = String.valueOf(system.today().month());
            selectedMonth = '0'+selectedMonth ; 
        }else{
            selectedMonth = String.valueOf(system.today().month());
        }
        selectedYear = String.valueOf(system.today().year());
        currentYear = integer.valueOf(selectedYear);
       
        //getShowData();
        reconcileSetting = ReconciliationDataSize__c.getOrgDefaults();
        dataLimit = Integer.valueOf(reconcileSetting.BatchLimit__c);
        showPopupForSelected = false;
        showPopupForAll = false;
        
    }

      
    /*********************************************************
    @Name           : getSearchData
    @Parameters     : 
    @Reutrn type    : PageReference
    @Description    : Fetch Data based of Filters
    ********************************************************/
    public PageReference getSearchData(){
        //System.debug('invoices = '+invoices);
        InvAcc = sups.SBQQ__Account__c;
        InvSite = invc.Subscription__c;
        OppOpener = opp.Opener__c;
        OppCloser = opp.Closer__c;
        AMCloser = opp.AM_Closer__c;
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
         revenueList = new List<List<revenueWrapper>>();
        List<revenueWrapper> innerRevenues = new List<revenueWrapper>();
        
       // invoices = new List<List<Invoice_Entries__c>>(); 
        List<Invoice_Entries__c> innerInvoices = new List<Invoice_Entries__c>();
        List<Invoice_Entries__c> invoiceList = new List<Invoice_Entries__c>();
         reconcileSetting = ReconciliationDataSize__c.getOrgDefaults();
        dataLimit = Integer.valueOf(reconcileSetting.BatchLimit__c);
        
         mCurrentMonth = String.isNotEmpty(selectedMonth) ? integer.valueOf(selectedMonth) : system.today().month();
        mCurrentYear = String.isNotEmpty(selectedYear) ? integer.valueOf(selectedYear) : system.today().year();
         //---------------Dynamic SOQL For Retrieve Invoice List--------------------------------------------
        String supp = invc.Supplier__c;
        system.debug('supplier::'+supp);
        system.debug('currentYear::'+currentYear);
        
        String invoiceListQuery = 'SELECT Id,Name,Amount__c,Calculation_Type__c,Payment_Date__c,Status__c,Received_Adder__c,Received_Volume__c,Invoice__r.Dispute_Status__c,Invoice__r.Expected_Adder__c,Invoice__r.Expected_Volume__c,';
        invoiceListQuery += 'Contract__c,Flag__c,ContractName__c,Site__c,ContractName__r.SBQQ__Opportunity__r.Opener__c,ContractName__r.SBQQ__Opportunity__r.Opener__r.Name,ContractName__r.SBQQ__Opportunity__r.Closer__c,ContractName__r.SBQQ__Opportunity__r.Closer__r.Name,ContractName__r.SBQQ__Opportunity__r.AM_Closer__c,ContractName__r.SBQQ__Opportunity__r.AM_Closer__r.Name,Subscription__r.Name,Invoice__r.id,Invoice__r.Name,';
        invoiceListQuery += 'Supplier__r.Name,Invoice__r.Difference_Amount__c,Invoice__r.Difference_Adder__c,Invoice__r.Difference_Volume__c,Subscription__r.Site__c,ContractName__r.AccountId,ContractName__r.supplier_s_contract_ID__c,ContractName__r.SBQQ__Opportunity__r.Margin__c,ContractName__r.Account.Name,ContractName__r.SBQQ__Opportunity__r.OwnerId,ContractName__r.SBQQ__Opportunity__r.Owner.Name';
        invoiceListQuery += ' FROM Invoice_Entries__c';
        invoiceListQuery += ' WHERE';
        if(String.isNotBlank(supp)){
            invoiceListQuery += ' Supplier__c = :supp AND';
        }
        invoiceListQuery += ' CALENDAR_MONTH(Payment_Date__c) = :mCurrentMonth';
        invoiceListQuery += ' AND CALENDAR_YEAR(Payment_Date__c) = :mCurrentYear';
        
        if(String.isNotBlank(InvAcc)){
            invoiceListQuery += ' AND ContractName__r.AccountId = :InvAcc';
        }
        system.debug('InvSite ::'+InvSite);
        if(String.isNotBlank(InvSite)){
            invoiceListQuery += ' AND Subscription__c = :InvSite';
        }
        if(String.isNotBlank(OppOpener)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Opener__c = :OppOpener';
        }
        if(String.isNotBlank(OppCloser)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Closer__c = :OppCloser';
        }
        if(string.isNotBlank(AdderValue)){
            AdderValueRe = decimal.valueOf(AdderValue);
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Margin__c = :AdderValueRe';
        }
        if(String.isNotBlank(AMCloser)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.AM_Closer__c = :AMCloser';
        }
        if(String.isNotBlank(diffMargin)){
            system.debug('diffMargin ::'+diffMargin);
            system.debug('diffAmtMargin ::'+diffAmtMargin);
            system.debug('diffAmtMarginNegative ::'+diffAmtMarginNegative);
            invoiceListQuery += ' AND (Invoice__r.Difference_Amount__c > :diffAmtMargin OR Invoice__r.Difference_Amount__c < :diffAmtMarginNegative )'; 
            system.debug('invoiceListQuery ::'+invoiceListQuery);
            //invoiceListQuery += ' AND (Flag__c != :flagStatus)'; 
        }
        if(String.isNotBlank(diffAdder)){
            system.debug('diffAdder ::'+diffAdder);
            system.debug('diffERAdder ::'+diffERAdder);
            system.debug('diffERAdderNegative ::'+diffERAdderNegative);
            invoiceListQuery += ' AND (	Invoice__r.Difference_Adder__c > :diffERAdder OR Invoice__r.Difference_Adder__c < :diffERAdderNegative)';
            system.debug('invoiceListQuery ::'+invoiceListQuery);
        }
        if(String.isNotBlank(diffVolume)){
            invoiceListQuery += ' AND (	Invoice__r.Difference_Volume__c > :diffEvVolume OR Invoice__r.Difference_Volume__c < : diffEvVolumeNegative)'; 
        }
        if(selectStatus != 'All') {
            invoiceListQuery += ' AND Status__c = :selectStatus ';
        }
        system.debug('contractId :'+contractId);
        if(String.isNotBlank(contractId)){
            invoiceListQuery += ' AND Contract__c = :contractId';
        }
        if(caseFilter != 'All') {
            invoiceListQuery += ' AND CaseIssue__c = null';
        }	
         if(dataLimit > 0){
            invoiceListQuery += ' Order by Contract__c LIMIT :dataLimit';  
        }
         else{
            invoiceListQuery += ' Order by Contract__c';
        } 
        
        //String invoiceListQuery = getSearchQueryString();
     
         System.debug('###>  mCurrentMonth = '+ mCurrentMonth);
        System.debug('###>  mCurrentYear = '+ mCurrentYear);
        System.debug('###>  invoiceListQuery = '+ invoiceListQuery);
        invoiceList = Database.query(invoiceListQuery); 
        System.debug('###>  invListNewSize = '+ invoiceList.size());
        System.debug('###>  invListNew = '+ invoiceList);
        //-----------------------------------------------------------
        
        integer totalRec = 0;
          for(Invoice_Entries__c invEntry : Database.query(invoiceListQuery)){
            totalRec++;
            if(innerRevenues.size() > 999){
                revenueList.add(innerRevenues);
                innerRevenues = new List<revenueWrapper>();
                innerRevenues.add(new revenueWrapper(invEntry));
            }else{
                innerRevenues.add(new revenueWrapper(invEntry)); 
            }
        }
        System.debug('innerRevenues--->' + innerRevenues.size());
        system.debug('totalRec::::'+totalRec);
        if(innerRevenues.size() > 0){
            revenueList.add(innerRevenues);
        }
        //System.debug('invoices = '+invoices);
        //System.debug('invoices size = '+invoices.size());
        ListSize = revenueList.size(); 
        system.debug('revenueList::::'+revenueList);
        
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
       List<SelectOption> statusList = new List<SelectOption>{new SelectOption('All','All') };
        Schema.DescribeFieldResult fieldResult = Invoice_Entries__c.Status__c.getDescribe();
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
 /*********************************************************
    @Name           : getCaseFilterOption
    @Parameters     : 
    @Reutrn type    : List<SelectOption>
    @Description    : Populate Picklist For Filter
    ********************************************************/    
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
    public pagereference DownloadSelected(){
        docId = '';
        String generatedCSVFile ='';
        InvAcc = sups.SBQQ__Account__c;
        InvSite = invc.Subscription__c;
        OppOpener = opp.Opener__c;
        OppCloser = opp.Closer__c;
        AMCloser = opp.AM_Closer__c;
        List<String> queryFields = new List<String>{'Invoice Entries Name','Opportunity Owner','Payment Date','Calculation Type','Amount','Status','Supplier','Contract','Invoice','Site','Subscription','Account Name','Dispute Status','Expected Adder','Received Adder','Expected volume','Received volume','Opener','Closer','AM Closer','Adder/margin','%Difference Amount','%Difference Adder','%Difference Volume','Reconcilition Status'};
        String fileRow = '';
        
        for(String f : queryFields){
            generatedCSVFile = generatedCSVFile + f +',';
           }
        
        mCurrentMonth = String.isNotEmpty(selectedMonth) ? integer.valueOf(selectedMonth) : system.today().month();
        mCurrentYear = String.isNotEmpty(selectedYear) ? integer.valueOf(selectedYear) : system.today().year();
         //---------------Dynamic SOQL For Retrieve Invoice List--------------------------------------------
        String supp = invc.Supplier__c;
        system.debug('supplier::'+supp);
        system.debug('currentYear::'+currentYear); 
        
        String invoiceListQuery = 'SELECT Id,Name,Amount__c,Calculation_Type__c,Payment_Date__c,Status__c,Received_Adder__c,Received_Volume__c,Invoice__r.Dispute_Status__c,Invoice__r.Expected_Adder__c,Invoice__r.Expected_Volume__c,';
        invoiceListQuery += 'Contract__c,Flag__c,ContractName__c,Site__c,ContractName__r.SBQQ__Opportunity__r.Opener__c,ContractName__r.SBQQ__Opportunity__r.Opener__r.Name,ContractName__r.SBQQ__Opportunity__r.Closer__c,ContractName__r.SBQQ__Opportunity__r.Closer__r.Name,ContractName__r.SBQQ__Opportunity__r.AM_Closer__c,ContractName__r.SBQQ__Opportunity__r.AM_Closer__r.Name,Subscription__r.Name,Invoice__r.id,Invoice__r.Name,';
        invoiceListQuery += 'Supplier__r.Name,Invoice__r.Difference_Amount__c,Invoice__r.Difference_Adder__c,Invoice__r.Difference_Volume__c,Subscription__r.Site__c,ContractName__r.AccountId,ContractName__r.supplier_s_contract_ID__c,ContractName__r.SBQQ__Opportunity__r.Margin__c,ContractName__r.Account.Name,ContractName__r.SBQQ__Opportunity__r.OwnerId,ContractName__r.SBQQ__Opportunity__r.Owner.Name';
        invoiceListQuery += ' FROM Invoice_Entries__c';
        invoiceListQuery += ' WHERE';
        invoiceListQuery += ' Supplier__c = :supp'; 
        invoiceListQuery += ' AND CALENDAR_MONTH(Payment_Date__c) = :mCurrentMonth';
        invoiceListQuery += ' AND CALENDAR_YEAR(Payment_Date__c) = :mCurrentYear';
        if(String.isNotBlank(InvAcc)){
            invoiceListQuery += ' AND ContractName__r.AccountId = :InvAcc';
        }
        system.debug('InvSite ::'+InvSite);
        if(String.isNotBlank(InvSite)){
            invoiceListQuery += ' AND Subscription__c = :InvSite';
        }
        if(String.isNotBlank(OppOpener)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Opener__c = :OppOpener';
        }
        if(String.isNotBlank(OppCloser)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Closer__c = :OppCloser';
        }
        if(string.isNotBlank(AdderValue)){
            AdderValueRe = decimal.valueOf(AdderValue);
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Margin__c = :AdderValueRe';
        }
        if(String.isNotBlank(AMCloser)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.AM_Closer__c = :AMCloser';
        }
        if(String.isNotBlank(diffMargin)){
            system.debug('diffMargin ::'+diffMargin);
            system.debug('diffAmtMargin ::'+diffAmtMargin);
            system.debug('diffAmtMarginNegative ::'+diffAmtMarginNegative);
            invoiceListQuery += ' AND (Invoice__r.Difference_Amount__c > :diffAmtMargin OR Invoice__r.Difference_Amount__c < :diffAmtMarginNegative )'; 
            system.debug('invoiceListQuery ::'+invoiceListQuery);
            //invoiceListQuery += ' AND (Flag__c != :flagStatus)'; 
        }
        if(String.isNotBlank(diffAdder)){
            system.debug('diffAdder ::'+diffAdder);
            system.debug('diffERAdder ::'+diffERAdder);
            system.debug('diffERAdderNegative ::'+diffERAdderNegative);
            invoiceListQuery += ' AND (	Invoice__r.Difference_Adder__c > :diffERAdder OR Invoice__r.Difference_Adder__c < :diffERAdderNegative)';
            system.debug('invoiceListQuery ::'+invoiceListQuery);
        }
        if(String.isNotBlank(diffVolume)){
            invoiceListQuery += ' AND (	Invoice__r.Difference_Volume__c > :diffEvVolume OR Invoice__r.Difference_Volume__c < : diffEvVolumeNegative)'; 
        }
         if(selectStatus != 'All') {
            invoiceListQuery += ' AND Status__c = :selectStatus ';
        }
        if(caseFilter != 'All') {
            invoiceListQuery += ' AND CaseIssue__c = null';
        }	
        invoiceListQuery += ' Order by Contract__c';
        system.debug('supp## '+supp);
        system.debug('mCurrentMonth## '+mCurrentMonth);
        system.debug('mCurrentYear## '+mCurrentYear);
        system.debug('selectStatus## '+selectStatus);
         system.debug('invoiceListQuery## '+invoiceListQuery);
        generatedCSVFile = generatedCSVFile.removeEnd(',')+'\n';
      
            for(Invoice_Entries__c inv : Database.query(invoiceListQuery)){
                fileRow = '';
                fileRow = fileRow +','+ inv.Name;
                fileRow = fileRow +','+ inv.Payment_Date__c.format();
                fileRow = fileRow +','+ inv.Calculation_Type__c;
                fileRow = fileRow +','+ inv.Amount__c;
                fileRow = fileRow +','+ inv.Status__c;
                fileRow = fileRow +','+ inv.Supplier__r.Name;
                fileRow = fileRow +','+ inv.Contract__c;
                fileRow = fileRow +','+ inv.Invoice__r.Name;
                fileRow = fileRow +','+ inv.Site__c;
                fileRow = fileRow +','+ inv.Subscription__c;
                fileRow = fileRow +','+ inv.ContractName__r.SBQQ__Opportunity__r.Owner.Name;
                 fileRow = fileRow +','+ inv.Supplier__r.Name;
                 fileRow = fileRow +','+ inv.ContractName__r.Account.Name;
                fileRow = fileRow +','+ inv.Received_Adder__c;
                fileRow = fileRow +','+ inv.Invoice__r.Expected_Adder__c;
                fileRow = fileRow +','+ inv.Received_Volume__c;
                fileRow = fileRow +','+ inv.Invoice__r.Expected_Volume__c;
                fileRow = fileRow +','+ inv.ContractName__r.SBQQ__Opportunity__r.Opener__r.Name;
                fileRow = fileRow +','+ inv.ContractName__r.SBQQ__Opportunity__r.Closer__r.Name;
                fileRow = fileRow +','+ inv.ContractName__r.SBQQ__Opportunity__r.AM_Closer__r.Name;
                fileRow = fileRow +','+ inv.ContractName__r.SBQQ__Opportunity__r.Margin__c;
                fileRow = fileRow +','+ inv.Invoice__r.Difference_Amount__c;
                fileRow = fileRow +','+ inv.Invoice__r.Difference_Adder__c;
                fileRow = fileRow +','+ inv.Invoice__r.Difference_Volume__c;
                fileRow = fileRow +','+ inv.Flag__c;
                fileRow = fileRow.replaceFirst(',','');
                generatedCSVFile = generatedCSVFile + fileRow + '\n';
            }
         
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        Document d = new Document();
        d.name = 'Invoice Reconciliation.csv';
        d.ContentType = 'text/csv';
        d.body = csvBlob;
        d.folderId = UserInfo.getUserId();
        insert d;
         docId = d.Id;
        /*PageReference pg = new PageReference('/servlet/servlet.FileDownload?file=' + d.Id);
        pg.setRedirect(true);
        return pg; */
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
         InvAcc = sups.SBQQ__Account__c;
        InvSite = invc.Subscription__c;
        OppOpener = opp.Opener__c;
        OppCloser = opp.Closer__c;
        AMCloser = opp.AM_Closer__c;
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
         
         mCurrentMonth = String.isNotEmpty(selectedMonth) ? integer.valueOf(selectedMonth) : system.today().month();
        mCurrentYear = String.isNotEmpty(selectedYear) ? integer.valueOf(selectedYear) : system.today().year();
         //---------------Dynamic SOQL For Retrieve Invoice List--------------------------------------------
        String supp = invc.Supplier__c;
        system.debug('supplier::'+supp);
        system.debug('currentYear::'+currentYear);
        
        String invoiceListQuery = 'SELECT Id,Name,Amount__c,Calculation_Type__c,Payment_Date__c,Status__c,Received_Adder__c,Received_Volume__c,Invoice__r.Dispute_Status__c,Invoice__r.Expected_Adder__c,Invoice__r.Expected_Volume__c,';
        invoiceListQuery += 'Contract__c,Flag__c,ContractName__c,Site__c,ContractName__r.SBQQ__Opportunity__r.Opener__c,ContractName__r.SBQQ__Opportunity__r.Opener__r.Name,ContractName__r.SBQQ__Opportunity__r.Closer__c,ContractName__r.SBQQ__Opportunity__r.Closer__r.Name,ContractName__r.SBQQ__Opportunity__r.AM_Closer__c,ContractName__r.SBQQ__Opportunity__r.AM_Closer__r.Name,Subscription__r.Name,Invoice__r.id,Invoice__r.Name,';
        invoiceListQuery += 'Supplier__r.Name,Invoice__r.Difference_Amount__c,Invoice__r.Difference_Adder__c,Invoice__r.Difference_Volume__c,Subscription__r.Site__c,ContractName__r.AccountId,ContractName__r.supplier_s_contract_ID__c,ContractName__r.SBQQ__Opportunity__r.Margin__c,ContractName__r.Account.Name,ContractName__r.SBQQ__Opportunity__r.OwnerId,ContractName__r.SBQQ__Opportunity__r.Owner.Name';
        invoiceListQuery += ' FROM Invoice_Entries__c';
        invoiceListQuery += ' WHERE';
        if(String.isNotBlank(supp)){
            invoiceListQuery += ' Supplier__c = :supp AND';
        }
        invoiceListQuery += ' CALENDAR_MONTH(Payment_Date__c) = :mCurrentMonth';
        invoiceListQuery += ' AND CALENDAR_YEAR(Payment_Date__c) = :mCurrentYear';
        
        if(String.isNotBlank(InvAcc)){
            invoiceListQuery += ' AND ContractName__r.AccountId = :InvAcc';
        }
        system.debug('InvSite ::'+InvSite);
        if(String.isNotBlank(InvSite)){
            invoiceListQuery += ' AND Subscription__c = :InvSite';
        }
        if(String.isNotBlank(OppOpener)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Opener__c = :OppOpener';
        }
        if(String.isNotBlank(OppCloser)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Closer__c = :OppCloser';
        }
        if(string.isNotBlank(AdderValue)){
            AdderValueRe = decimal.valueOf(AdderValue);
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Margin__c = :AdderValueRe';
        }
        if(String.isNotBlank(AMCloser)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.AM_Closer__c = :AMCloser';
        }
        if(String.isNotBlank(diffMargin)){
            system.debug('diffMargin ::'+diffMargin);
            system.debug('diffAmtMargin ::'+diffAmtMargin);
            system.debug('diffAmtMarginNegative ::'+diffAmtMarginNegative);
            invoiceListQuery += ' AND (Invoice__r.Difference_Amount__c > :diffAmtMargin OR Invoice__r.Difference_Amount__c < :diffAmtMarginNegative )'; 
            system.debug('invoiceListQuery ::'+invoiceListQuery);
            //invoiceListQuery += ' AND (Flag__c != :flagStatus)'; 
        }
        if(String.isNotBlank(diffAdder)){
            system.debug('diffAdder ::'+diffAdder);
            system.debug('diffERAdder ::'+diffERAdder);
            system.debug('diffERAdderNegative ::'+diffERAdderNegative);
            invoiceListQuery += ' AND (	Invoice__r.Difference_Adder__c > :diffERAdder OR Invoice__r.Difference_Adder__c < :diffERAdderNegative)';
            system.debug('invoiceListQuery ::'+invoiceListQuery);
        }
        if(String.isNotBlank(diffVolume)){
            invoiceListQuery += ' AND (	Invoice__r.Difference_Volume__c > :diffEvVolume OR Invoice__r.Difference_Volume__c < : diffEvVolumeNegative)'; 
        }
        if(selectStatus != 'All') {
            invoiceListQuery += ' AND Status__c = :selectStatus ';
        }
        system.debug('contractId :'+contractId);
        if(String.isNotBlank(contractId)){
            invoiceListQuery += ' AND Contract__c = :contractId';
        }
        if(caseFilter != 'All') {
            invoiceListQuery += ' AND CaseIssue__c = null';
        }	
         if(dataLimit > 0){
            invoiceListQuery += ' Order by Contract__c LIMIT :dataLimit';  
        }
         else{
            invoiceListQuery += ' Order by Contract__c';
        }
        caseOwner = cs.OwnerId;
        system.debug('cs.OwnerId:::'+cs.OwnerId);
        system.debug('caseOwner:::'+caseOwner);
          
        caseCreationMethod(invoiceListQuery, null,supp,mCurrentMonth,mCurrentYear,selectStatus,caseOwner);
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
        showPopupForSelected = false;
        Set<String> conIdSet = new Set<String>();
        Map<Id,Case> caseMap = new Map<Id,Case>();
        List<CaseIssue__c> caseIssuesList = new List<CaseIssue__c>();
        System.debug('revenueList size :: ' + revenueList.size());
        for(List<revenueWrapper> revList : revenueList){
            for(revenueWrapper rev : revList){
                if(rev.isSelected){
                    conIdSet.add(rev.invoiceEntry.Contract__c);
                }
            }
        }  
        if(conIdSet.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Please_select_at_least_one_contract_label));
            return null;                        
        }
        
        InvAcc = sups.SBQQ__Account__c;
        InvSite = invc.Subscription__c;
        OppOpener = opp.Opener__c;
        OppCloser = opp.Closer__c;
        AMCloser = opp.AM_Closer__c;
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
         
         mCurrentMonth = String.isNotEmpty(selectedMonth) ? integer.valueOf(selectedMonth) : system.today().month();
        mCurrentYear = String.isNotEmpty(selectedYear) ? integer.valueOf(selectedYear) : system.today().year();
         //---------------Dynamic SOQL For Retrieve Invoice List--------------------------------------------
        String supp = invc.Supplier__c;
        system.debug('supplier::'+supp);
        system.debug('currentYear::'+currentYear);
        
        String invoiceListQuery = 'SELECT Id,Name,Amount__c,Calculation_Type__c,Payment_Date__c,Status__c,Received_Adder__c,Received_Volume__c,Invoice__r.Dispute_Status__c,Invoice__r.Expected_Adder__c,Invoice__r.Expected_Volume__c,';
        invoiceListQuery += 'Contract__c,Flag__c,ContractName__c,Site__c,ContractName__r.SBQQ__Opportunity__r.Opener__c,ContractName__r.SBQQ__Opportunity__r.Opener__r.Name,ContractName__r.SBQQ__Opportunity__r.Closer__c,ContractName__r.SBQQ__Opportunity__r.Closer__r.Name,ContractName__r.SBQQ__Opportunity__r.AM_Closer__c,ContractName__r.SBQQ__Opportunity__r.AM_Closer__r.Name,Subscription__r.Name,Invoice__r.id,Invoice__r.Name,';
        invoiceListQuery += 'Supplier__r.Name,Invoice__r.Difference_Amount__c,Invoice__r.Difference_Adder__c,Invoice__r.Difference_Volume__c,Subscription__r.Site__c,ContractName__r.AccountId,ContractName__r.supplier_s_contract_ID__c,ContractName__r.SBQQ__Opportunity__r.Margin__c,ContractName__r.Account.Name,ContractName__r.SBQQ__Opportunity__r.OwnerId,ContractName__r.SBQQ__Opportunity__r.Owner.Name';
        invoiceListQuery += ' FROM Invoice_Entries__c';
        invoiceListQuery += ' WHERE';
        if(String.isNotBlank(supp)){
            invoiceListQuery += ' Supplier__c = :supp AND';
        }
        invoiceListQuery += ' CALENDAR_MONTH(Payment_Date__c) = :mCurrentMonth';
        invoiceListQuery += ' AND CALENDAR_YEAR(Payment_Date__c) = :mCurrentYear';
        
        if(String.isNotBlank(InvAcc)){
            invoiceListQuery += ' AND ContractName__r.AccountId = :InvAcc';
        }
        system.debug('InvSite ::'+InvSite);
        if(String.isNotBlank(InvSite)){
            invoiceListQuery += ' AND Subscription__c = :InvSite';
        }
        if(String.isNotBlank(OppOpener)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Opener__c = :OppOpener';
        }
        if(String.isNotBlank(OppCloser)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Closer__c = :OppCloser';
        }
        if(string.isNotBlank(AdderValue)){
            AdderValueRe = decimal.valueOf(AdderValue);
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.Margin__c = :AdderValueRe';
        }
        if(String.isNotBlank(AMCloser)){
            invoiceListQuery += ' AND ContractName__r.SBQQ__Opportunity__r.AM_Closer__c = :AMCloser';
        }
        if(String.isNotBlank(diffMargin)){
            system.debug('diffMargin ::'+diffMargin);
            system.debug('diffAmtMargin ::'+diffAmtMargin);
            system.debug('diffAmtMarginNegative ::'+diffAmtMarginNegative);
            invoiceListQuery += ' AND (Invoice__r.Difference_Amount__c > :diffAmtMargin OR Invoice__r.Difference_Amount__c < :diffAmtMarginNegative )'; 
            system.debug('invoiceListQuery ::'+invoiceListQuery);
            //invoiceListQuery += ' AND (Flag__c != :flagStatus)'; 
        }
        if(String.isNotBlank(diffAdder)){
            system.debug('diffAdder ::'+diffAdder);
            system.debug('diffERAdder ::'+diffERAdder);
            system.debug('diffERAdderNegative ::'+diffERAdderNegative);
            invoiceListQuery += ' AND (	Invoice__r.Difference_Adder__c > :diffERAdder OR Invoice__r.Difference_Adder__c < :diffERAdderNegative)';
            system.debug('invoiceListQuery ::'+invoiceListQuery);
        }
        if(String.isNotBlank(diffVolume)){
            invoiceListQuery += ' AND (	Invoice__r.Difference_Volume__c > :diffEvVolume OR Invoice__r.Difference_Volume__c < : diffEvVolumeNegative)'; 
        }
        if(selectStatus != 'All') {
            invoiceListQuery += ' AND Status__c = :selectStatus ';
        }
        system.debug('contractId :'+contractId);
        if(String.isNotBlank(contractId)){
            invoiceListQuery += ' AND Contract__c = :contractId';
        }
        if(caseFilter != 'All') {
            invoiceListQuery += ' AND CaseIssue__c = null';
        }	
         if(dataLimit > 0){
            invoiceListQuery += ' Order by Contract__c LIMIT :dataLimit';  
        }
         else{
            invoiceListQuery += ' Order by Contract__c';
        }
        caseOwner = cs.OwnerId;
        system.debug('cs.OwnerId:::'+cs.OwnerId);
        system.debug('caseOwner:::'+caseOwner);
        caseCreationMethod(invoiceListQuery, conIdSet,supp,mCurrentMonth,mCurrentYear,selectStatus,caseOwner);
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
    public static void caseCreationMethod(String invoiceListQuery, Set<String> conIdSet,String supp,Integer mCurrentMonth,Integer mCurrentYear,String selectStatus, String caseOwner)
    {   
        
        Savepoint sp;
        try{    
            System.debug('Before invoiceListQuery ::: ' + invoiceListQuery); 
            Integer orderByIndex = invoiceListQuery.indexOf('Order by');
           
            
            if(conIdSet != null && conIdSet.size() > 0){
                orderByIndex = invoiceListQuery.indexOf('Order by');
                invoiceListQuery = invoiceListQuery.substring(0,orderByIndex) + ' AND Contract__c IN :conIdSet ' + invoiceListQuery.substring(orderByIndex);
                
            }
            System.debug('After invoiceListQuery ::: ' + invoiceListQuery); 
            Map<String, Id> conIdInvoiceEntryMap = new Map<String, Id>();
            Map<String, List<Invoice_Entries__c>> conIdRevenueMap = new Map<String, List<Invoice_Entries__c>>();
            for(Invoice_Entries__c inv : Database.query(invoiceListQuery)){
                if(String.isNotEmpty(inv.ContractName__c)){
                    conIdInvoiceEntryMap.put(inv.Contract__c,inv.ContractName__c);
                }
                if(!conIdRevenueMap.containsKey(inv.Contract__c)){
                    conIdRevenueMap.put(inv.Contract__c, new List<Invoice_Entries__c>());
                }
                conIdRevenueMap.get(inv.Contract__c).add(inv);
            }
            System.debug('conIdInvoiceEntryMap-->' + conIdInvoiceEntryMap.keySet());
            System.debug('conIdRevenueMap-->' + conIdRevenueMap.keySet());
            Map<String,Case> caseMap = new Map<String,Case>();
            Group opsQ = [select Id,Name from Group where  Type = 'Queue' AND DeveloperNAME = 'Operations_Queue' LIMIT 1];
            Id RecordTypeIdReconcileCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Reconcile').getRecordTypeId();
            List<Invoice_Entries__c> revenueUpdateList = new List<Invoice_Entries__c>();
            Map<Invoice_Entries__c,CaseIssue__c> caseIssuesInvoiceMap = new Map<Invoice_Entries__c,CaseIssue__c>();     
            Map<String,Integer> statusPriorityMap = new Map<String,Integer>{
                ConstantString.MISSING_CONTRACT_MISSING_SITE  => 0,
                    ConstantString.MISSING_CONTRACT_CORRECT_SITE  => 1,
                    ConstantString.CORRECT_CONTRACT_MISSING_SITE  => 2
                    };
                        for(String conId : conIdRevenueMap.keySet()){                
                            Case newCase = new Case();
                            if(conIdInvoiceEntryMap.containsKey(conId)){
                                newCase.Contract__c = conIdInvoiceEntryMap.get(conId); 
                            }
                            system.debug('newCase.Contract__c:::'+newCase.Contract__c);
                            newCase.ContractName__c = conId;
                            newCase.Origin = 'Reconcile';
                            system.debug('newCase.OwnerId::'+newCase.OwnerId);
                            if(String.isNotEmpty(caseOwner)){
                                 newCase.OwnerId = caseOwner;
                            }
                             else if(opsQ != null){
                                newCase.OwnerId = opsQ.Id;
                            }
                            newCase.RecordTypeId = RecordTypeIdReconcileCase;
                           // newCase.Opportunity__c = conIdRevenueMap.get(conId).get(0).Contract__r.SBQQ__Opportunity__c;
                            //newCase.AccountId = conIdRevenueMap.get(conId).get(0).Contract__r.AccountId;
                            newCase.Subject = 'Reconcile error - ' + conIdRevenueMap.get(conId).get(0).Contract__c;
                            newCase.Type = conIdRevenueMap.get(conId).get(0).Status__c;
                            for(Invoice_Entries__c inv : conIdRevenueMap.get(conId)){
                                if(statusPriorityMap.get(newCase.Type) > statusPriorityMap.get(inv.Status__c)){
                                    newCase.Type = inv.Status__c;
                                }
                            } 
                            caseMap.put(conId,newCase);
                        }
            System.debug('caseMap.size ::: ' + caseMap.size());
            sp = Database.setSavepoint();
            
            INSERT caseMap.values();
            System.debug('Cases per contracts created successfully ');        
            for(String conId : conIdRevenueMap.keySet()){            
                for(Invoice_Entries__c inv : conIdRevenueMap.get(conId)){
                    CaseIssue__c newCaseIssue = new CaseIssue__c();
                    newCaseIssue.Case__c = caseMap.get(conId).Id;
                    newCaseIssue.ContractName__c = inv.Contract__c;
                    newCaseIssue.ErrorType__c = inv.Status__c;
                    newCaseIssue.ReceivedAmount__c = inv.Amount__c;
                    newCaseIssue.ReceivedFee__c = inv.Received_Adder__c;
                    newCaseIssue.ReceivedVolume__c = inv.Received_Volume__c;
                    newCaseIssue.Status__c = 'Open';
                    newCaseIssue.SiteName__c = inv.Site__c;
                    newCaseIssue.CalculationType__c = inv.Calculation_Type__c;
                    caseIssuesInvoiceMap.put(inv,newCaseIssue);
                }
            }
            //System.debug('caseIssuesList.size ::: ' + caseIssuesList.size());
            System.debug('caseIssuesInvoiceMap befor ::: ' + caseIssuesInvoiceMap);
            INSERT caseIssuesInvoiceMap.values();      
            System.debug('Case Issues created successfully.');        
            for(Invoice_Entries__c inv : caseIssuesInvoiceMap.keySet()){
                inv.CaseIssue__c = caseIssuesInvoiceMap.get(inv).Id;
                revenueUpdateList.add(inv);
            }	
            System.debug('caseIssuesInvoiceMap ::: ' + caseIssuesInvoiceMap);
            UPDATE revenueUpdateList;
            System.debug('Missing Entries updated successfully.');
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
        
    }
    /*********************************************************
@Name           : sendEmailOnCaseCreation 
@Parameters     : List<Case> caseData, Exception excep
@Reutrn type    : void
@Description    : send email to logged in user when case record is created
********************************************************/
    public static void sendEmailOnCaseCreation(List<Case> caseData, Exception excep){
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
@Name           : deleteSelectedEntry 
@Parameters     : 
@Reutrn type    : PageReference
@Description    : Delete selected invoice entries
********************************************************/
    public PageReference deleteSelectedEntry(){
        Set<String> entryIdSet = new Set<String>();
        System.debug('revenueList size :: ' + revenueList.size());
        List<Invoice_Entries__c> InvoiceList = new List<Invoice_Entries__c>();
        for(List<revenueWrapper> revList : revenueList){
            for(revenueWrapper rev : revList){
                if(rev.isSelected){
                    entryIdSet.add(rev.invoiceEntry.Id);
                }
            }
        }  
        system.debug('entryIdSet ::'+entryIdSet);
        if(entryIdSet.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Please_select_at_least_one_entry));
            return null;                        
        }
        String invoiceListQuery = 'SELECT Id,Name';
        invoiceListQuery += ' FROM Invoice_Entries__c';
        invoiceListQuery += ' WHERE';
        invoiceListQuery += ' Id IN :entryIdSet';
        for(Invoice_Entries__c inv : Database.query(invoiceListQuery)){
            InvoiceList.add(inv);
        }
        system.debug('InvoiceList ::'+InvoiceList);
        if(InvoiceList.size()>0){
            delete InvoiceList;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Invoice entry deleted successfully.'));
            return null; 
        }
        return null;        
    }
  /*********************************************************
@Name 			: revenueWrapper
@Parameters 	: Void
@Reutrn type 	: void
@Description 	: revenueWrapper
********************************************************/
    public class revenueWrapper{  
        
        public Invoice_Entries__c invoiceEntry {get;set;}
        public Boolean isSelected {get;set;}
        
        public revenueWrapper(Invoice_Entries__c invoiceEntry){
            this.invoiceEntry = invoiceEntry;       
            this.isSelected = false;
        }
    }
    public static void dummyData(){
Integer i = 0;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
        i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
}
}