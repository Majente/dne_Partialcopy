/**************************************************

* Class: LeadChartController
* Author: Soljit <MJ>
* Date: 2019-03-07
* Description: LeadChartController for showing daily pricing according supplier

****************************************************/    
public without sharing class LeadChartController{
    private final Lead theLead;
    private final Account theAccount;
    private ApexPages.StandardController stdController;
    private String recordId;
    private String selectedCommGas = 'Gas';
    private String selectedCommElec = 'Electricity';
    public Decimal totalVolume{get; set;}
    public String selectedSupplierId {get; set;}
    public String selectedOfferName {get; set;}
    public String selectedMonthYear {get; set;}
    public String selectedCommodity {get; set;}
    public String selectedMarket {get; set;}
    public String selectedSize {get; set;}
    public String selectedSupplier {get; set;}
    public String selectedSupplierFromChart {get; set;}
    public Decimal Min {get;set;}
    public Decimal Max {get;set;}
    public Map<Id,String> supplier_Id_Name_Map {get; set;}
    public Map<String,String> supplier_IdNameKey_Map {get; set;}
    public Map<Id,List<GraphValue>> graphValuesMap {get; set;}
    Public Map<string,string> monthYearMap {get;set;}
    public String graphValuesJSON {get; set;}
    public String selectedPrice {get; set;}
    public String selectedNbOfYears {get; set;}
    public String selectedOppRow {get;set;}
    
    public Boolean showGraph {get; set;}
    public Boolean showSupplierList {get; set;}
    public Boolean showSaveOfferButton {get; set;}
    
    private Map<String,Decimal> priceAdjustmentMap {get; set;}
    
    public List<SelectOption> commodityOptions {get; set;}
    public List<SelectOption> marketOptions {get; set;}
    public List<SelectOption> sizeOptions {get; set;}
    public List<SelectOption> supplierOptions {get; set;}
    public List<String> suppliers;
    public Map<Integer,List<Decimal>> yearOfContractPrices;//yearOfContract,PriceOfAllSupplier in fix order
    public String supplierString {get;set;}
    public String yearOfContractPricesString {get;set;}
    public String taskComments {get;set;}
    private Set<Id> supplierIdSet {get;set;}
    public Opportunity opp {get;set;}
    public Decimal marginChosen {get;set;}
    public Decimal sellingPrice {get;set;}
    public Decimal totalDeal {get;set;}
    public Boolean isCustomPrice {get;set;}
    public Decimal maxMargin {get;set;}
    public Decimal minMargin {get;set;}
    
    public List<myWrapper> wrrapperList{get;set;}
    public String searchString{get;set;}
    public String searchStr{get;set;}
    public List<myWrapper> selctedAcc{get;set;}
    public String lookupId{get;set;}
    public List<Opportunity> oppor{get;set;}
    public String indexValue{get;set;}
    public String selectedPriceType {get;set;}
    public String siteAccountIds {get;set;}
    public String selectedOppType {get;set;}
    public Boolean isSelectedAcc {get;set;}
    public Map<string,string> Effective_Map {get;set;}
    public string Effective_String {get;set;}
    public List<Price_List__c> todayPriceListFixed {get; set;}
    public List<Price_List__c> todayPriceListVariable {get; set;}
    public Map<Id,List<Price_List__c>> priceMapToShow {get; set;}
    public Map<Id,List<Price_List__c>> currentPriceListMap {get; set;}
    
    public Boolean sellingPriceEditable
    {
        get
        {
            return isCustomPrice && showSaveOfferButton;
        }
        set;
    }
    
    public String leadEstimatedVolume
    {
        get
        {
            if(leadEstimatedVolume==null)
            {
                leadEstimatedVolume = '0';
            }
            return leadEstimatedVolume;
        }
        set;
    }
    public Boolean noSuppliersFound
    {
        get
        {
            return showSupplierList && (supplierOptions==null || supplierOptions.isEmpty());
        }
    }
    
    public Boolean hasLead
    {
        get
        {
            return theLead!=null;
        }
    }
    public Boolean hasAccount
    {
        get
        {
            return theAccount!=null;
        }
    }
    
    //===============================================
    // ================ CONSTRUCTORS ================
    //===============================================
    
    /**************************************************

* Class: LeadChartController
* Author: Soljit <MJ>
* Date: 2019-03-07
* Description: LeadChartController for showing daily pricing according supplier

****************************************************/    
    public LeadChartController(ApexPages.StandardController stdController)
    {
        recordId = stdController.getRecord().Id;
        
        //recordId = ApexPages.currentPage().getParameters().get('id');
        
        opp = new Opportunity();
        opp.name = 'Test Opp';
        opp.CloseDate = date.today();
        isCustomPrice = false;
        
        wrrapperList = new List<myWrapper>();
        searchString = '';
        selctedAcc = new List<myWrapper>();
        oppor = new List<Opportunity>();
        oppor.add(new opportunity());
        supplier_Id_Name_Map = new Map<Id,String>();
        supplier_IdNameKey_Map = new Map<String, String>();
        this.stdController = stdController;
        showSaveOfferButton = false;
        Min = 0;
        Max = 0;
        selectedOppRow = '';
        if(recordId!=null && recordId.startsWith('00Q')){
            try{
                this.theLead = [SELECT Id, State, Business_Size__c, OwnerId, Name, Market__c, Commodity__c
                                FROM Lead
                                WHERE Id = :recordId];
                useLeadValues();
            }
            catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.No_lead_found_label));
            }
        }
        selectedPriceType = 'Fixed';
        isSelectedAcc = false;
        Effective_Map = new Map<string,string>();
        Effective_String = '';
        totalVolumeSelected();
        
    }
    
    /******************************************************************
Method Name    : calculateSellingPrice
Parameter      : 
Description    : method used to calculate selling price
******************************************************************/
    public PageReference calculateSellingPrice(){
        try {
            Decimal years = Integer.valueOf(selectedNbOfYears)/12;
            System.debug('marginChosen : '+ marginChosen);
            String pageMessage = '';
            if(marginChosen > maxMargin || marginChosen < minMargin){
                System.debug('inside if marginChosen : '+ marginChosen);
                pageMessage = 'Margin must be between ' + minMargin +' to '+maxMargin;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                return null;
            }
            sellingPrice = Decimal.valueOf(selectedPrice) + marginChosen;
            totalDeal = (Decimal.valueOf(leadEstimatedVolume) * marginChosen) * years;
            
            Boolean negativeValuesProvided = false;
            if(marginChosen < 0){
                pageMessage = System.Label.Positive_value_for_margin_label;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                negativeValuesProvided = true;
            }
            if(Decimal.valueOf(leadEstimatedVolume) < 0){
                pageMessage = System.Label.Provide_positive_value_for_estimated_volume_label;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                negativeValuesProvided = true;
            }
            if(negativeValuesProvided){
                return null;
            }
        }
        catch(System.TypeException e){
            String pageMessage = System.Label.Provide_value_for_chosen_margin_label;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
        }
        return null;
    }
    //-----------------------------
    /******************************************************************
Method Name    : recalculateMargin
Parameter      : 
Description    : method used to reCalculate margin
******************************************************************/
    public PageReference recalculateMargin(){
        try {
            Decimal years = Integer.valueOf(selectedNbOfYears)/12;
            marginChosen = sellingPrice - Decimal.valueOf(selectedPrice);
            totalDeal = (Decimal.valueOf(leadEstimatedVolume) * marginChosen)*years;
            system.debug('After calculation marginChosen : '+marginChosen);
            Boolean negativeValuesProvided = false;
            String pageMessage = '';
            if(marginChosen < 0){
                pageMessage = System.Label.Positive_value_for_margin_label;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
                negativeValuesProvided = true;
            }
            if(Decimal.valueOf(leadEstimatedVolume) < 0){
                pageMessage = System.Label.Provide_positive_value_for_estimated_volume_label;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
                negativeValuesProvided = true;
            }
            if(negativeValuesProvided){
                return null;
            }
            
        }
        catch(System.TypeException e){
            String pageMessage = System.Label.Provide_value_for_chosen_margin_label;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
        }
        return null;
    }
    
    //-----------------------------
    /******************************************************************
Method Name    : useLeadValues
Parameter      : 
Description    : 
******************************************************************/
    public void useLeadValues(){
        showGraph = false;
        showSupplierList = false;
        getPicklistOptions();
        
        if(String.isNotBlank(theLead.Business_Size__c))
        {
            selectedSize = theLead.Business_Size__c;
        }
        
        if(String.isNotBlank(theLead.Market__c))
        {
            selectedMarket = theLead.Market__c;
        }
        
        if(String.isNotBlank(theLead.Commodity__c))
        {
            selectedCommodity = theLead.Commodity__c;
        }
    }
    //-----------------------------
    /******************************************************************
Method Name    : totalVolumeSelected
Parameter      : 
Description    : method used to calculate total selected volume
******************************************************************/
    public void totalVolumeSelected(){
        
        totalVolume = 0;
        if(recordId != null && hasAccount) {
            if(selectedCommodity == selectedCommGas && theAccount.Total_Annual_Volume_Gas__c >0 ) {
                totalVolume = theAccount.Total_Annual_Volume_Gas__c;
                
            }
            if(selectedCommodity == selectedCommElec && theAccount.Total_Annual_Volume_ElectrictIy__c >0) {
                totalVolume = theAccount.Total_Annual_Volume_ElectrictIy__c;
                
            }
        }
    }
    //-----------------------------
    
    public PageReference backToRecord(){
        return new PageReference('/' + recordId);
    }
    
    /******************************************************************
Method Name    : createOffer
Parameter      : 
Description    : method used to create offers
******************************************************************/
    public pageReference createOffer(){
        if(marginChosen > maxMargin || marginChosen < minMargin){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Margin must be between ' + minMargin + ' to ' + maxMargin));
            return null;
        }
        // =========== INPUTS VALIDATION ===========
        Decimal thePrice;
        try{
            //thePrice = Decimal.valueOf(selectedPrice);
            thePrice = sellingPrice;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.Provide_numeric_value_label));
            return null;
        }
        // -------------
        Decimal estimatedVolume;
        try{
            if(hasLead){
                estimatedVolume = Decimal.valueOf(leadEstimatedVolume);
            }
            else if(hasAccount){
                estimatedVolume = totalVolume;
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.Provide_numeric_value_for_estimated_label));
            return null;
        }
        
        List<sObject> objToInsert = new List<sObject>();
        Task theTask = new Task();
        
        String confirmationMessage = System.Label.Task_created_label;
        
        try{
            // =========== CREATING A TASK ===========
            theTask.Status = 'Completed';
            theTask.Priority = 'Normal';
            theTask.ActivityDate = Date.today();
            theTask.Subject = 'Phone Conversation with ';
            if(hasLead){
                theTask.OwnerId = theLead.OwnerId;
                theTask.WhoId = recordId;
                theTask.Subject += theLead.Name;
            }
            else if(hasAccount){
                theTask.OwnerId = theAccount.OwnerId;
                theTask.WhatId = recordId;
                theTask.Subject += theAccount.Name;
            }
            theTask.Description = taskComments;
            objToInsert.add(theTask);
            
            // =========== CREATING AN OFFER ===========
            
            Offer__c theOffer = new Offer__c();
            theOffer.Commodity__c = selectedCommodity;
            theOffer.Contract_Duration_months__c = Integer.valueOf(selectedNbOfYears);
            theOffer.Market__c = selectedMarket;
            theOffer.Price__c = thePrice;
            theOffer.Starting_Month__c = selectedMonthYear;
            theOffer.Supplier__c = Id.valueOf(getSelectedSupplierId());
            theOffer.Name = selectedOfferName;
            theOffer.Estimated_Volume__c = estimatedVolume;
            theOffer.Comments__c = taskComments;
            theOffer.Margin__c = marginChosen;
            theOffer.Selling_Price__c = sellingPrice;
            
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(now);
            Datetime local = now.addSeconds(offset/1000);
            
            if(hasLead)  {
                theOffer.Lead__c = theLead.Id;
                theOffer.Name = theLead.Name + ' - ' + local;
            }
            else if(hasAccount) {
                theOffer.Customer__c = theAccount.Id;
                theOffer.Name = theAccount.Name + ' - ' + local;
            }
            
            objToInsert.add(theOffer);
            
            // =========== UPDATING THE LEAD ===========
            if(hasLead){
                if(String.isEmpty(theLead.Business_Size__c)) {
                    theLead.Business_Size__c = selectedSize;
                }
                theLead.Offered_Contract_Duration_months__c = Integer.valueOf(selectedNbOfYears);
                theLead.Offered_Price__c = thePrice;
                theLead.Offered_Starting_Month__c = selectedMonthYear;
                theLead.Offered_Supplier__c = selectedSupplierFromChart;
                theLead.Offered_Market__c = selectedMarket;
                theLead.Offered_Commodity__c = selectedCommodity;
                theLead.Last_Offered_Margin__c = marginChosen;
                theLead.Last_Offered_Selling_Price__c = sellingPrice;
                update theLead;
                confirmationMessage += ', Lead Updated';
            }
            
            
            Database.insert(objToInsert,true);
            pageReference pg = new pageReference('/'+theLead.Id);
            pg.setRedirect(true);
            return pg;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'ERROR: An error has occured: ' + e.getMessage()));
            return null;
        }
        
    }
    //-----------------------------
    
    public void resetSearch()
    {
        selectedSupplier = '';
        showGraph = false;
        showSupplierList = false;
        selectedMonthYear = null;
        getPicklistOptions();
        showSaveOfferButton = false;
    }
    //-----------------------------
    /******************************************************************
Method Name    : getSupplierList
Parameter      : 
Description    : method used to get supplier list
******************************************************************/
    public void getSupplierList(){
        GoForSearch();
        priceMapToShow = PriceListUtility.getTodayPriceList(selectedMarket, selectedCommodity, selectedSize, selectedSupplier);
        supplierIdSet = new Set<Id>();
        
        supplierOptions = new List<SelectOption>();
        String key;
        Effective_Map = new Map<string,string>();
        // 25 April 2019 With new price list model
        for(List<Price_List__c> plList :priceMapToShow.values()){
            for(Price_list__c pl : plList) {
                supplier_Id_Name_Map.put(pl.Supplier__c, pl.Supplier__r.Name);
                key = pl.Supplier__c + '_' + pl.Supplier__r.Name;
                supplier_IdNameKey_Map.put(key,pl.Supplier__c);
                supplierIdSet.add(pl.Supplier__c);
                Effective_String = '';
                String effDate = 'Effective from '+String.valueOf(pl.Effective_From__c.format('yyyy-MM-dd hh:mm:ss'))+' to '+String.valueOf(pl.Effective_To__c.format('yyyy-MM-dd hh:mm:ss'));
                Effective_Map.put(pl.Supplier__r.Name,effDate);
            }
        }
        for(Id pbmId : supplier_Id_Name_Map.keySet()) {
            supplierOptions.add(new SelectOption(pbmId, supplier_Id_Name_Map.get(pbmId)));
        }
        
        showSupplierList = true;
        //getAssumptions();
        
    }
    //-----------------------------
    
    /*
called when the picklist "Supplier" is changed. It filters the list of Price_by_Month__c, selecting
for the graph only those related to the selected Supplier
*/
    public void getGraphData() {
        setCurrentPbm();
        todayPriceListFixed = new List<Price_List__c>();
        todayPriceListVariable = new List<Price_List__c>();
        For(List<Price_List__c> plList :priceMapToShow.values()){
            for(Price_List__c pl : plList) {
                /*if(pl.Type__c=='Fixed') {
Effective_String = '';
String effDate = 'Effective from '+String.valueOf(pl.Effective_From__c.format('yyyy-MM-dd hh:mm:ss'))+' to '+String.valueOf(pl.Effective_To__c.format('yyyy-MM-dd hh:mm:ss'));
Effective_Map.put(pl.Supplier__r.Name+''+pl.Type__c,effDate);
todayPriceListFixed.add(pl);
}*/
                if(!String.isBlank(pl.Type__c )) {
                    Effective_String = '';
                    String effDate;
                    if(pl.Effective_To__c < Datetime.now()){
                        effDate = '<span class="expired">Expired On '+ String.valueOf(pl.Effective_To__c.format('yyyy-MM-dd hh:mm:ss'))+'</span>';
                    }else{
                        effDate = '<span class="effective">Effective from '+String.valueOf(pl.Effective_From__c.format('yyyy-MM-dd hh:mm:ss'))+' to '+String.valueOf(pl.Effective_To__c.format('yyyy-MM-dd hh:mm:ss'))+'</span>';                
                    }
                    Effective_Map.put(pl.Supplier__r.Name,effDate);
                    todayPriceListFixed.add(pl);
                } 
            }
        }
        
        // Ends here
        fillPbmMapToShow();
        //setCurrentPbm();
        system.debug('yearOfContractPrices::'+yearOfContractPrices);
        graphValuesJSON=JSON.serialize(graphValuesMap);
        System.debug('### graphValuesMap ' + graphValuesMap);
        System.debug('### graphValuesJSON ' + graphValuesJSON);
        supplierString =JSON.serialize(suppliers);
        System.debug('### suppliers ' + suppliers);
        yearOfContractPricesString=JSON.serialize(yearOfContractPrices);
        showGraph = true;
        showSaveOfferButton = false;
        if(maxMargin != null && minMargin != null && (marginChosen > maxMargin || marginChosen < minMargin)){
            String pageMessage = ' Margin must be between ' + minMargin + ' to ' + maxMargin;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
            return;
        }
    }
    //-----------------------------
    
    public void setCurrentPbm() {
        priceMapToShow = PriceListUtility.getTodayPriceListUpdated(selectedMarket, selectedCommodity, selectedSize, selectedSupplier,selectedPriceType);
        currentPriceListMap = new Map<Id,List<Price_List__c>>();
        if(priceMapToShow.keySet().isEmpty()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.No_Prices_found_label));
            return;
        }
        if(selectedMonthYear==null) {
            for(String supplierId : priceMapToShow.keySet()) {
                selectedMonthYear = priceMapToShow.get(supplierId).get(0).Month_Year__r.Name;
                break;
            }
        }
        System.debug('selectedMonthYear : '+ selectedMonthYear);
        monthYearMap = new Map<string,string>();
        for(String supplierId : priceMapToShow.keySet()) {
            List<Price_List__c> tempPriceList = new List<Price_List__c>();
            for(Price_List__c pl : priceMapToShow.get(supplierId)) {
                System.debug('pl.Month_Year__r.Name : '+ pl.Month_Year__r.Name);
                if(pl.Month_Year__c != null ){ 
                    if( selectedMonthYear == pl.Month_Year__r.Name  || selectedPriceType == 'Variable') {                    
                        tempPriceList.add(pl);
                    }
                }
            }
            currentPriceListMap.put(supplierId, tempPriceList);
        }
        if(currentPriceListMap.keySet().isEmpty() || currentPriceListMap.values().size() ==0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.No_Prices_found_label));
            return;
        }
        setGraphValues();
        selectedPrice = '0';
        if(!test.isRunningTest()){
            marginChosen = 0;
        }
        sellingPrice = 0;
        selectedNbOfYears = '0';
    }
    //-----------------------------
    /******************************************************************
Method Name    : setPricingValues
Parameter      : 
Description    : method used to set pricing values
******************************************************************/
    public void setPricingValues() {
        if(!test.isRunningTest()){
            String priceParam = Apexpages.currentPage().getParameters().get('priceParam');
            String yearsParam = Apexpages.currentPage().getParameters().get('yearsParam');
            String supplierParam = Apexpages.currentPage().getParameters().get('supplierParam');
            selectedPrice = priceParam;
            selectedNbOfYears = yearsParam;
            selectedSupplierFromChart=supplierParam;
        }
        System.debug('Effective_Map = '+Effective_Map);
        System.debug(selectedSupplierFromChart+'   ,  '+selectedPriceType);
        if(Effective_Map.containsKey(selectedSupplierFromChart)){
            Effective_String = Effective_Map.get(selectedSupplierFromChart);
        }else{
            Effective_String = '';
        }
        System.debug('Effective_String = '+Effective_String);
        showSaveOfferButton = true;
        if(getSelectedSupplierId() != null){
            Map<String,Decimal> margins = PriceListUtility.getMaxMinMargin(selectedMarket,selectedCommodity,selectedSize,getSelectedSupplierId(),selectedPriceType);
            System.debug('margins ######### => '+margins);
            maxMargin = margins.get('Margin Max') != null ? margins.get('Margin Max') : 3;
            minMargin = margins.get('Margin Min') != null ? margins.get('Margin Min') : 1;
        }       
        getTotalEstimatedVolume();
        calculateSellingPrice();
    }
    
    //Fetch product using method
    public String fetchProduct(){
        System.debug('selectedCommodity::'+selectedCommodity);
        System.debug('selectedSize::'+selectedSize);
        For(Product2 prod :[select id,Is_Fixed__c from product2 where family =:selectedCommodity AND Size__c =:selectedSize ] ){
            if(prod !=null && prod.Is_Fixed__c == true && selectedPriceType == 'Fixed' ){
                return prod.id;
            }
            else if(prod !=null && prod.Is_Fixed__c == false && selectedPriceType == 'Variable' ){
                return prod.id;
            }
        }
        return null;
    }
    // Get Selected suplier Id
    public String getSelectedSupplierId (){
        String key;
        if(supplierIdSet !=null){
            for(Id suppId : supplierIdSet){
                key = suppId + '_'+ selectedSupplierFromChart;
                if(supplier_IdNameKey_Map.containsKey(key)){
                    return supplier_IdNameKey_Map.get(key);
                }
            }
        }
        return null;
    }
    
    
    
    // ----------------------------------------------
    public void setGraphValues(){ 
        Min = 0;
        Max = 0;
        Boolean MinMaxSetFlag=false;/*MTJ*/
        graphValuesMap = new Map<Id,List<GraphValue>>();
        yearOfContractPrices=new Map<Integer,List<Decimal>>();
        suppliers=new List<String>();
        Set<Integer> graphNumberSet;
        List<GraphValue> gvList;
        String supplierName = '';
        
        System.debug('currentPriceListMap::'+currentPriceListMap);
        for(Id supplierId : currentPriceListMap.keySet()){
            gvList = new List<GraphValue>();
            supplierName = '';
            graphNumberSet = new Set<Integer>();
            for(Price_List__c pl : currentPriceListMap.get(supplierId)){
                if(!graphNumberSet.contains(integer.valueOf(pl.Term__c))){
                    gvList.add(new GraphValue( integer.valueOf(pl.Term__c), pl.List_Price__c));
                    graphNumberSet.add(integer.valueOf(pl.Term__c));
                    System.debug('pl.Supplier__r.Name::'+pl.Supplier__r.Name);
                    if(pl.Supplier__r.Name != Null && !String.isBlank(pl.Supplier__r.Name)){
                        supplierName = pl.Supplier__r.Name;
                    }else if(selectedPriceType == 'Variable' && supplier_Id_Name_Map.containskey(pl.Supplier__c)){
                        supplierName = supplier_Id_Name_Map.get(pl.Supplier__c);
                    }
                }
            }
            
            if(gvList.size() > 0 && gvList.size() < 5 ){
                for(integer i=12; i<=60; i=i+12){
                    if(!graphNumberSet.contains(i)){
                        gvList.add(new GraphValue(i,0)); 
                    }
                }
            }
            system.debug('For Supplier : '+ supplierName + 'gvList::'+gvList);
            graphValuesMap.put(supplierId,gvList);
            // --------- For Chart ---------            
            List<Decimal> contractPrices;
            if(!String.isBlank(supplierName)){
                suppliers.add(supplierName);
            }
            for(Integer i=1; i<=5; i++) {
                if(gvList.size() == 0) break;
                if(!yearOfContractPrices.containsKey(i)) {
                    yearOfContractPrices.put(i,new List<Decimal>());
                }
                contractPrices = yearOfContractPrices.get(i);
                for(GraphValue gp : gvList){
                    if(gp != null && gp.yearsOfContract == i*12){
                        Decimal cp = gp.price;  
                        contractPrices.add(cp==null?0:cp);
                        break;
                    }
                }
                
            }
        } 
        system.debug('yearOfContractPrices::'+yearOfContractPrices);
    }
    //-----------------------------
    
    public List<SelectOption> getMonthOptions(){
        Set<SelectOption> monthOptions = new Set<SelectOption>();
        Integer currentMonth = System.Today().Month();
        Integer currentYear = System.Today().Year();
        for(Month_Year__c my : [SELECT Name,Month__c,Year__c FROM Month_Year__c
                                // Where ID IN:monthYearMap.KeySet()
                                ORDER BY Year__c, Month__c Asc]){
                                    if(selectedMonthYear == null){
                                        selectedMonthYear = my.Name;
                                    }
                                    if(my.Month__c >= currentMonth && my.Year__c >= currentYear){
                                        monthOptions.add(new SelectOption(my.Name,my.Name)); 
                                    }
                                }
        
        System.debug('**** monthOptions : '+monthOptions);
        
        return new List<SelectOption>(monthOptions);
    }
    //-----------------------------
    
    public void getPicklistOptions() {
        
        Schema.DescribeSObjectResult objSchema = Daily_Prices__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        
        if(commodityOptions==null || commodityOptions.isEmpty()){
            commodityOptions = new List<SelectOption>();
            Schema.DisplayType fielddataType = fieldMap.get('Commodity__c').getDescribe().getType();
            if(fielddataType == Schema.DisplayType.Picklist){
                List<Schema.Picklistentry> fld = fieldmap.get('Commodity__c').getDescribe().getpicklistValues();
                for(Integer i=0; i<fld.size(); i++){
                    commodityOptions.add(new SelectOption(fld[i].getvalue(), fld[i].getvalue()));
                }
            }
        }
        if(marketOptions==null || marketOptions.isEmpty()){
            marketOptions = new List<SelectOption>();
            for(Market__c market : [SELECT Id, Name FROM Market__c ORDER BY Name]){
                marketOptions.add(new SelectOption(market.Id, market.Name));
            }
        }
        
        
        if(sizeOptions==null || sizeOptions.isEmpty()){
            sizeOptions = new List<SelectOption>();
            Schema.DisplayType fielddataType = fieldMap.get('Size__c').getDescribe().getType();
            if(fielddataType == Schema.DisplayType.Picklist){
                List<Schema.Picklistentry> fld = fieldmap.get('Size__c').getDescribe().getpicklistValues();
                for(Integer i=0; i<fld.size(); i++){
                    sizeOptions.add(new SelectOption(fld[i].getvalue(), fld[i].getvalue()));
                }
            }
        }
        
    }
    //-----------------------------
    
    public PageReference changePriceType(){
        fillPbmMapToShow();
        return null;
    }
    //-----------------------------
    
    public void fillPbmMapToShow(){
        
        List<Price_List__c> todayPriceListToUse;
        if(selectedPriceType=='Fixed'){
            todayPriceListToUse = todayPriceListFixed;
        } else if(selectedPriceType=='Variable'){
            todayPriceListToUse = todayPriceListVariable;
        }
        priceMapToShow = new Map<Id,List<Price_List__c>>();
        for(Price_List__c pl : todayPriceListToUse == null ?  new List<Price_List__c>() : todayPriceListToUse) {
            String supplierId = pl.Supplier__c;
            if(!priceMapToShow.containsKey(supplierId))
            {
                List<Price_List__c> theValue = new List<Price_List__c>();
                theValue.add(pl);
                priceMapToShow.put(supplierId,theValue);
            } else {
                priceMapToShow.get(supplierId).add(pl);
            }
            
        }
        // Ends here
    }
    
    // --------- Search for child accounts in pop-up ---------
    public void GoForSearch(){
        if(String.isBlank(siteAccountIds)) return;
        System.debug('siteAccountIds = '+siteAccountIds);
        List<String> acctIds = siteAccountIds.split(',');
        
        wrrapperList = new List<myWrapper>();
        selctedAcc = new List<myWrapper>();
        myWrapper childSiteWrapper;
        for(Account acc : [Select id,BillingState,Name,Total_Annual_Volume_ElectrictIy__c,Total_Annual_Volume_Gas__c,Market__c  from Account where Id IN: acctIds  and recordtype.name = 'Client']){
            childSiteWrapper = new myWrapper(acc);
            childSiteWrapper.isSelected = true;
            wrrapperList.add(childSiteWrapper);
            selctedAcc.add(childSiteWrapper);
        }
        System.debug('selctedAcc::'+selctedAcc);
    }
    
    public void getTotalEstimatedVolume(){
        Double totalEstimationVolume = 0;
        for(myWrapper olw :selctedAcc){
            if(selectedCommodity == selectedCommGas && olw.acc.Total_Annual_Volume_Gas__c >0 ){
                totalEstimationVolume+= olw.acc.Total_Annual_Volume_Gas__c;
            }else if(selectedCommodity == selectedCommElec && olw.acc.Total_Annual_Volume_ElectrictIy__c >0 ){
                totalEstimationVolume+= olw.acc.Total_Annual_Volume_ElectrictIy__c;
            }
        }
        leadEstimatedVolume = String.valueOf(totalEstimationVolume);
        
    }
    // ==============================================
    // ================== WRAPPERS ==================
    // ==============================================
    
    public class GraphValue
    {
        public Integer yearsOfContract {get; set;}
        public Decimal price {get; set;}
        
        public GraphValue(Integer yoc, Decimal p)
        {
            this.yearsOfContract = yoc;
            this.price = p;
        }
    }
    
    // --------- Wrapper class for pop-up records ---------
    public class myWrapper {
        public Account acc{get;set;}
        public Boolean isSelected{get;set;}
        public myWrapper(Account a) {
            acc = a;
            isSelected = false;
        }
    }
    
    
}