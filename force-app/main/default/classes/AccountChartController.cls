/**************************************************

* Class: AccountChartController
* Author: Soljit <VW>
* Date: 2019-03-07
* Description: AccountChartController for showing daily pricing according supplier

****************************************************/
public without sharing class AccountChartController{
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
    public String redirectUrl  {get; set;}
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
    public Boolean showCalculation {get; set;}
    private Map<String,Decimal> priceAdjustmentMap {get; set;}
    
    public List<SelectOption> commodityOptions {get; set;}
    public List<SelectOption> marketOptions {get; set;}
    public List<SelectOption> sizeOptions {get; set;}
    public List<SelectOption> supplierOptions {get; set;}
    public List<String> suppliers;
    public Map<Integer,List<Decimal>> yearOfContractPrices;//yearOfContract,PriceOfAllSupplier in fix order
    public String supplierString {get;set;}
    public String yearOfContractPricesString {get;set;}
    private Set<Id> supplierIdSet {get;set;}
    public Opportunity opp {get;set;}
    
    public Decimal marginChosen {get;set;}
    public Decimal sellingPrice {get;set;}
    public Decimal totalDeal {get;set;}
    public Boolean isCustomPrice {get;set;}
    public Decimal maxMargin {get;set;}
    public Decimal minMargin {get;set;}
    
    public List<siteWrapper> wrrapperList{get;set;}
    public String searchString{get;set;}
    public String searchStr{get;set;}
    public List<siteWrapper> selctedAcc{get;set;}
    public String lookupId{get;set;}
    public List<Opportunity> oppor{get;set;}
    public String indexValue{get;set;}
    public List<oppListWrapper> oppListWr{get;set;}
    
    public String selectedPriceType {get;set;}
    public String siteAccountIds {get;set;}
    public String selectedOppType {get;set;}
    public Boolean isSite {get;set;}
    public Boolean isSelectedAcc {get;set;}
    public Map<string,string> Effective_Map {get;set;}
    public string Effective_String {get;set;}
    public string NoDataAvailabe_ErrorMessage {get;set;}
    // Start here for new PriceList approach
    public List<Price_List__c> todayPriceListFixed {get; set;}
    public List<Price_List__c> todayPriceListVariable {get; set;}
    public Map<Id,List<Price_List__c>> priceMapToShow {get; set;}
    public Map<Id,List<Price_List__c>> currentPriceListMap {get; set;}
    // Tree Variable
    public String jsonDataForAddressSite {get;set;}
    public Map<Id,TreeWrapper> addressSiteMap {get;set;} 
    
    public Boolean sellingPriceEditable
    {
        get
        {
            return isCustomPrice && showCalculation;
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
    public Boolean hasAccount
    {
        get
        {
            return theAccount!=null;
        }
    }
  /*********************************************************
    @Name 			: AccountChartController
    @Parameters 	: ApexPages.StandardController
    @Reutrn type 	: void
    @Description 	: Constructor
	********************************************************/
    public AccountChartController(ApexPages.StandardController stdController) {
        currentPriceListMap = new Map<Id,List<Price_List__c>>();
        recordId = stdController.getRecord().Id;
        opp = new Opportunity();
        opp.name = 'Test Opp';
        opp.CloseDate = date.today();
        isCustomPrice = false;
        marginChosen = 0;
        wrrapperList = new List<siteWrapper>();
        oppListWr = new List<oppListWrapper>();
        oppListWr.add(new oppListWrapper(new opportunity()));
        searchString = '';
        selctedAcc = new List<siteWrapper>();
        oppor = new List<Opportunity>();
        oppor.add(new opportunity());
        supplier_Id_Name_Map = new Map<Id,String>();
        supplier_IdNameKey_Map = new Map<String, String>();
        this.stdController = stdController;
        showCalculation = false;
        Min = 0;
        Max = 0;    
        selectedOppRow = '';
        try
        {
            this.theAccount = [SELECT Id, OwnerId, Name, Market__c, Total_Annual_Volume_ElectrictIy__c, Total_Annual_Volume_Gas__c,
                               Business_Size__c,  BillingState
                               FROM Account 
                               WHERE Id = :recordId];
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.No_Account_found));
        }
        
        isSite = false;
        for(Account acc : [Select id,Name From Account 
                           Where ParentId =: recordId AND recordtype.name = 'Service Address' limit 1]){
                               isSite = true;  
                           } 
        showGraph = false;
        showSupplierList = false;
        getPicklistOptions();
        selectedPriceType = ConstantString.FIXED_TYPE;
        isSelectedAcc = false;
        Effective_Map = new Map<string,string>();
        Effective_String = '';
        selectedCommodity = selectedCommGas;
        jsonDataForAddressSite='[]';
        selectedMarket = this.theAccount.Market__c;
    }
    
    /*********************************************************
    @Name 			: calculateSellingPrice
    @Reutrn type 	: PageReference
    @Description 	: Provide Estimated Volume and positive value for the Margin.
	********************************************************/
    public PageReference calculateSellingPrice(){
        try
        {
            Decimal years = Integer.valueOf(selectedNbOfYears)/12;
            // Decimal marginChosenDecimal = Decimal.valueOf(marginChosen);
            System.debug('marginChosen : '+ marginChosen);
            System.debug('maxMargin :: ' + maxMargin + ', minMargin :: ' + minMargin);
            String pageMessage = '';
            if(maxMargin != null && minMargin != null && (marginChosen > maxMargin || marginChosen < minMargin)){
                System.debug('inside if marginChosen : '+ marginChosen);
                pageMessage = Label.Margin_must_be  + ' Min : ' + minMargin +' and Max : '+ maxMargin;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                return null;                
            }
            else if(maxMargin != null && marginChosen > maxMargin){
                System.debug('inside if marginChosen : '+ marginChosen);
                pageMessage = Label.Margin_must_be  + ' Max : '+ maxMargin;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                return null;                                
            }
            else if(minMargin != null && marginChosen < minMargin){
                System.debug('inside if marginChosen : '+ marginChosen);
                pageMessage = Label.Margin_must_be  + ' Min : ' + minMargin;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                return null;                                                
            }
            sellingPrice = Decimal.valueOf(selectedPrice) + marginChosen;
            totalDeal = (totalVolume * marginChosen) * years;
            
            Boolean negativeValuesProvided = false;
            if(marginChosen < 0)
            {
                pageMessage = Label.Please_provide_a_positive_value_for_the_Margin;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                negativeValuesProvided = true;
            }
            if(totalVolume < 0)
            {
                pageMessage = Label.Please_provide_a_positive_value_for_the_Estimated_Volume;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                negativeValuesProvided = true;
            }
            if(negativeValuesProvided)
            {
                return null;
            }
            showCalculation = true;
        }
        catch(System.TypeException e)
        {
            String pageMessage = Label.Please_provide_a_valid_value_for_the_Chosen_Margin_and_Estimated_Volume;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
        }
        return null;
    }
    /*********************************************************
    @Name 			: recalculateMargin
    @Reutrn type 	: PageReference
    @Description 	: recalculate provide margin
	********************************************************/
   public PageReference recalculateMargin(){
       try
       {    
           Decimal years = Integer.valueOf(selectedNbOfYears)/12;
           marginChosen = sellingPrice - Decimal.valueOf(selectedPrice);
           totalDeal = (totalVolume * marginChosen)*years;
           system.debug('After calculation marginChosen : '+marginChosen);
           Boolean negativeValuesProvided = false;
           String pageMessage = '';
           if(marginChosen < 0)  
           {
               pageMessage = Label.Please_provide_a_positive_value_for_the_Margin;
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
               negativeValuesProvided = true; 
           }
           if(totalVolume < 0)
           {
               pageMessage = Label.Please_provide_a_positive_value_for_the_Estimated_Volume;
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
               negativeValuesProvided = true;
           }
           if(negativeValuesProvided)
           {
               return null;
           }
       }
       catch(System.TypeException e)
       {
           String pageMessage = Label.Please_provide_a_valid_value_for_the_Chosen_Margin_and_Estimated_Volume;
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
       }
       return null;
   }
    /*********************************************************
    @Name 			: backToRecord
    @Reutrn type 	: PageReference
    @Description 	: return pagereference record Id.
	********************************************************/
    public PageReference backToRecord(){
        return new PageReference('/' + recordId);
    }
    
    /*********************************************************
    @Name 			: resetSearch
    @Reutrn type 	: Void
    @Description 	: Search supplier 
	********************************************************/
    public void resetSearch()
    {
        selectedSupplier = '';
        showGraph = false;
        showSupplierList = false;
        selectedMonthYear = null;
        //getTodayPbmList();
        getPicklistOptions();
        showCalculation = false;
    }
   /*********************************************************
    @Name 			: getSupplierList
    @Reutrn type 	: void
    @Description 	: getSupplierList
	********************************************************/    
    public void getSupplierList(){
        GoForSearch();
        system.debug('selectedMarket::' +selectedMarket + 'selectedCommodity:: ' +selectedCommodity);
        system.debug('selectedSize::' +selectedSize + 'selectedSupplier:: ' +selectedSupplier + 'selectedPriceType' +selectedPriceType);
        priceMapToShow = PriceListUtility.getTodayPriceListUpdated(selectedMarket, selectedCommodity, selectedSize, selectedSupplier,selectedPriceType);
        supplierIdSet = new Set<Id>();
        supplierOptions = new List<SelectOption>();
        String key;
        String effDate;
        Effective_Map = new Map<string,string>();
        system.debug('priceMapToShow::: ' +priceMapToShow);
        for(List<Price_List__c> plList :priceMapToShow.values()){
            for(Price_List__c pl : plList) {
                if(pl.Supplier__c != null){
                    supplier_Id_Name_Map.put(pl.Supplier__c, pl.Supplier__r.Name);
                    key = pl.Supplier__c + '_' + pl.Supplier__r.Name;
                    supplier_IdNameKey_Map.put(key,pl.Supplier__c);
                    supplierIdSet.add(pl.Supplier__c);
                    Effective_String = '';
                    //System.debug('pl.Effective_To__c :::: ' + pl.Effective_To__c);
                    if(pl.Effective_To__c < Datetime.now()){
                        effDate = '<span class="expired">Expired On '+ String.valueOf(pl.Effective_To__c.format('yyyy-MM-dd hh:mm:ss'))+'</span>';
                    }else{
                        effDate = '<span class="effective">Effective from '+String.valueOf(pl.Effective_From__c.format('yyyy-MM-dd hh:mm:ss'))+' to '+String.valueOf(pl.Effective_To__c.format('yyyy-MM-dd hh:mm:ss'))+'</span>';                 
                    }
                    if(!Effective_Map.containsKey(pl.Supplier__r.Name + selectedMonthYear)){
                        Effective_Map.put(pl.Supplier__r.Name + selectedMonthYear,effDate);  
                    }
                    //System.debug('pl.Supplier__r.Name :::: ' + pl.Supplier__r.Name + 'effDate :::: ' + effDate);
                    //System.debug('**** pl : ' + pl);
                    
                }
            }
        }
        System.debug('Effective_Map keyset : ' + Effective_Map.keySet()); 
        System.debug('Effective_Map  : ' + Effective_Map); 
        // Ends here
        for(Id pbmId : supplier_Id_Name_Map.keySet())
        {
            supplierOptions.add(new SelectOption(pbmId, supplier_Id_Name_Map.get(pbmId)));
            
        }
        //System.debug('supplierOptions = '+supplierOptions);
        showSupplierList = true;
    }
    /*********************************************************
    @Name 			: getGraphData
    @Reutrn type 	: void
    @Description 	: This method get graph data
	********************************************************/
    public void getGraphData(){ 
        setCurrentPbm();
        System.debug('***** getGraphData : ');
        todayPriceListFixed = new List<Price_List__c>();
        todayPriceListVariable = new List<Price_List__c>();
        For(List<Price_List__c> plList :priceMapToShow.values()){
            System.debug('plList : ' +plList);
            for(Price_List__c pl : plList) {
                System.debug('pl :::: ' + pl);
                if(!String.isBlank(pl.Type__c )) {
                    Effective_String = '';
                    String effDate;
                    System.debug('pl.Effective_To__c :::: ' + pl.Effective_To__c);
                    if(pl.Effective_To__c < Datetime.now()){
                        effDate = '<span class="expired">Expired On '+ String.valueOf(pl.Effective_To__c.format('yyyy-MM-dd hh:mm:ss'))+'</span>';
                    }else{
                        effDate = '<span class="effective">Effective from '+String.valueOf(pl.Effective_From__c.format('yyyy-MM-dd hh:mm:ss'))+' to '+String.valueOf(pl.Effective_To__c.format('yyyy-MM-dd hh:mm:ss'))+'</span>';                
                    }
                    if(!Effective_Map.containsKey(pl.Supplier__r.Name + selectedMonthYear)){
                        Effective_Map.put(pl.Supplier__r.Name + selectedMonthYear,effDate);  
                    }
                    System.debug('pl.Supplier__r.Name :::: ' + pl.Supplier__r.Name + 'effDate :::: ' + effDate);
                    System.debug('**** pl : ' + pl);
                    todayPriceListFixed.add(pl);
                } 
            }
        }
        System.debug('Effective_Map keyset : ' + Effective_Map.keySet()); 
        System.debug('Effective_Map  : ' + Effective_Map); 

        // Ends here
        fillPbmMapToShow();
        graphValuesJSON=JSON.serialize(graphValuesMap);
        supplierString =JSON.serialize(suppliers);
        System.debug('### suppliers ' + suppliers);
        System.debug('supplierString::'+supplierString);
        yearOfContractPricesString=JSON.serialize(yearOfContractPrices);
        showGraph = true;
        showCalculation = false;
        /*if(maxMargin != null && minMargin != null && (marginChosen > maxMargin || marginChosen < minMargin)) 
        {
            String pageMessage = Label.Margin_must_be_between + minMargin + ' and ' + maxMargin;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
            return;
        }*/

    }
   /*********************************************************
    @Name 			: setCurrentPbm
    @Reutrn type 	: void
    @Description 	: Set priceing for today
	********************************************************/    
    public void setCurrentPbm() {
        priceMapToShow = PriceListUtility.getTodayPriceListUpdated(selectedMarket, selectedCommodity, selectedSize, selectedSupplier,selectedPriceType);
        currentPriceListMap = new Map<Id,List<Price_List__c>>();
        if(priceMapToShow.keySet().isEmpty()) {
             return;
        }
        if(selectedMonthYear == null) {
            getMonthOptions();
            //for(String supplierId : priceMapToShow.keySet()) {
                //selectedMonthYear = priceMapToShow.get(supplierId).get(0).Month_Year__r.Name;
                //break;
            //}
        }
        System.debug('selectedMonthYear : '+ selectedMonthYear);
        monthYearMap = new Map<string,string>();
        for(String supplierId : priceMapToShow.keySet()) {
            List<Price_List__c> tempPriceList = new List<Price_List__c>();
            System.debug('priceMapToShow.get(supplierId) ::: ' + priceMapToShow.get(supplierId));
            for(Price_List__c pl : priceMapToShow.get(supplierId)) {
                System.debug('pl.Month_Year__r.Name : '+ pl.Month_Year__r.Name);
                if(pl.Month_Year__c != null ){
                   if(selectedMonthYear == pl.Month_Year__r.Name || selectedPriceType == ConstantString.VARIABLE_TYPE ) {
                        tempPriceList.add(pl);
                   }
                }
            }
            //System.debug('supplierId :::: ' + supplierId + 'tempPriceList :::: ' + tempPriceList);
            currentPriceListMap.put(supplierId, tempPriceList);
        }
        System.debug('currentPriceListMap ::: ' + currentPriceListMap);
        if(currentPriceListMap.keySet().isEmpty() || currentPriceListMap.values().size() ==0) {
            System.debug('No Prices for today found');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.No_Prices_for_today_found));
            return;
        }
        // Ends Here
        setGraphValues();
        selectedPrice = '0';
        if(!test.isRunningTest()){
            marginChosen = 0;
        }
        sellingPrice = 0;
        selectedNbOfYears = '0';
    }
    /*********************************************************
    @Name 			: setPricingValues
    @Reutrn type 	: void
    @Description 	: Set calculate price values
	********************************************************/   
    public void setPricingValues(){
        if(!test.isRunningTest()){
            String priceParam = Apexpages.currentPage().getParameters().get('priceParam');
            String yearsParam = Apexpages.currentPage().getParameters().get('yearsParam');
            String supplierParam = Apexpages.currentPage().getParameters().get('supplierParam');
            selectedPrice = priceParam;
            selectedNbOfYears = yearsParam;
            selectedSupplierFromChart=supplierParam;  
        }
        
        if(Effective_Map.containsKey(selectedSupplierFromChart + selectedMonthYear)){
            Effective_String = Effective_Map.get(selectedSupplierFromChart + selectedMonthYear);
        }else{
            Effective_String = '';
        }
        System.debug('***** Effective_String : '+ Effective_String);
        showCalculation = true;
       
        
        if(getSelectedSupplierId() != null){
            Map<String,Decimal> margins = PriceListUtility.getMaxMinMargin(selectedMarket,selectedCommodity,selectedSize,getSelectedSupplierId(), selectedPriceType);
            maxMargin = margins.get(ConstantString.MARGIN_MAX) != null ? margins.get(ConstantString.MARGIN_MAX) : null;
            minMargin = margins.get(ConstantString.MARGIN_MIN) != null ? margins.get(ConstantString.MARGIN_MIN) : null;
            
              System.debug('minMargin -->' + minMargin);
            
            System.debug('***** margins : '+ margins);
        }
        calculateSellingPrice();
    }
    /*********************************************************
    @Name 			: fetchProduct
    @Reutrn type 	: String
    @Description 	: Fetch product using method
	********************************************************/
    public String fetchProduct(){
        //System.debug('selectedSize::'+selectedSize);
        For(Product2 prod :[Select id,Is_Fixed__c 
                            From product2 Where family =:selectedCommodity AND Size__c =:selectedSize ] ){
                                if(prod !=null && prod.Is_Fixed__c == true && selectedPriceType == ConstantString.FIXED_TYPE ){
                                    return prod.id;
                                }
                                else if(prod !=null && prod.Is_Fixed__c == false && selectedPriceType == ConstantString.VARIABLE_TYPE ){
                                    return prod.id;
                                }
                            }
        return null;
    }
    /*********************************************************
    @Name 			: backToAccount
    @Reutrn type 	: PageReference
    @Description 	: back to account set recordId
	********************************************************/
    public pageReference backToAccount(){
        pageReference pg = new pageReference('/'+recordId);
        return pg;
    }
    /*********************************************************
    @Name 			: getSelectedSupplierId
    @Reutrn type 	: String
    @Description 	: Get Selected suplier Id
	********************************************************/
    public String getSelectedSupplierId (){
        String key;
        System.debug('supplierIdSet = '+supplierIdSet);
        if(supplierIdSet !=null){
            for(Id suppId : supplierIdSet){
                key = suppId + '_'+ selectedSupplierFromChart;
                System.debug('key = '+key);
                System.debug('supplier_IdNameKey_Map = '+supplier_IdNameKey_Map);
                if(supplier_IdNameKey_Map.containsKey(key)){
                    return supplier_IdNameKey_Map.get(key);
                }
            }
        }
        return null;
    }
   /*********************************************************
    @Name 			: setGraphValues
    @Reutrn type 	: void
    @Description 	: Set min max values for graph
	********************************************************/    
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

        for(Id supplierId : currentPriceListMap.keySet()){
            gvList = new List<GraphValue>();
            supplierName = '';
            graphNumberSet = new Set<Integer>();
            for(Price_List__c pl : currentPriceListMap.get(supplierId)){
                system.debug('supplierId :' + supplierId +'  pl.Term__c: '+ pl.Term__c);
                if(!graphNumberSet.contains(integer.valueOf(pl.Term__c))){
                    gvList.add(new GraphValue( integer.valueOf(pl.Term__c), pl.List_Price__c));
                    graphNumberSet.add(integer.valueOf(pl.Term__c));
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
                       system.debug('Adding Zero for month: '+i);
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
    }
    /*********************************************************
    @Name 			: getMonthOptions
    @Reutrn type 	: List<SelectOption>
    @Description 	: get Month and year values
	********************************************************/
    public List<SelectOption> getMonthOptions() {
        Set<SelectOption> monthOptions = new Set<SelectOption>();
        Integer currentMonth = System.Today().Month();
        Integer currentYear = System.Today().Year();
        for(Month_Year__c my : [SELECT Name,Month__c,Year__c 
                                FROM Month_Year__c
                                ORDER BY Year__c, Month__c Asc]){
                                   
                                    if(my.Month__c >= currentMonth && my.Year__c >= currentYear){
                                        monthOptions.add(new SelectOption(my.Name,my.Name)); 
                                        if(selectedMonthYear == null){
                                        	selectedMonthYear = my.Name;
                                    	}
                                    }
                                }
        
        System.debug('**** monthOptions : '+monthOptions);
        System.debug('**** selectedMonthYear : '+selectedMonthYear);
        return new List<SelectOption>(monthOptions);
    }
   /*********************************************************
    @Name 			: getPicklistOptions
    @Reutrn type 	: void
    @Description 	: get picklist options
	********************************************************/    
    public void getPicklistOptions() {
        
        Schema.DescribeSObjectResult objSchema = Daily_Prices__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        
        if(commodityOptions==null || commodityOptions.isEmpty())
        {
            commodityOptions = new List<SelectOption>();
            Schema.DisplayType fielddataType = fieldMap.get('Commodity__c').getDescribe().getType();        
            if(fielddataType == Schema.DisplayType.Picklist)
            {
                List<Schema.Picklistentry> fld = fieldmap.get('Commodity__c').getDescribe().getpicklistValues();
                for(Integer i=0; i<fld.size(); i++)
                {
                    commodityOptions.add(new SelectOption(fld[i].getvalue(), fld[i].getvalue()));
                }
            }
        }
        if(marketOptions==null || marketOptions.isEmpty())
        {
            marketOptions = new List<SelectOption>();
            for(Market__c market : [SELECT Id, Name 
                                    FROM Market__c ORDER BY Name])
            {
                marketOptions.add(new SelectOption(market.Id, market.Name));
            }
        }
    }
    
   /*********************************************************
    @Name 			: fillPbmMapToShow
    @Reutrn type 	: void
    @Description 	: show value of price map
	********************************************************/
    public void fillPbmMapToShow(){
        
        List<Price_List__c> todayPriceListToUse;
        if(selectedPriceType == ConstantString.FIXED_TYPE){
            todayPriceListToUse = todayPriceListFixed;
        } else if(selectedPriceType == ConstantString.VARIABLE_TYPE){
            todayPriceListToUse = todayPriceListVariable;
        }
        priceMapToShow = new Map<Id,List<Price_List__c>>();
        for(Price_List__c pl : todayPriceListToUse == null ?  new List<Price_List__c>() : todayPriceListToUse) {
            String supplierId = pl.Supplier__c;
            if(!priceMapToShow.containsKey(supplierId)){
                List<Price_List__c> theValue = new List<Price_List__c>();
                theValue.add(pl);
                priceMapToShow.put(supplierId,theValue);
             } else {
                 priceMapToShow.get(supplierId).add(pl);
             }
        }
        // Ends here
    }
      /*********************************************************
    @Name 			: GoForSearch 
    @Reutrn type 	: void
    @Description 	: Search for child accounts in pop-up
	********************************************************/
    public void GoForSearch(){
        if(String.isBlank(siteAccountIds)) return;
        System.debug('siteAccountIds = '+siteAccountIds);
        List<String> siteIds = siteAccountIds.split(',');
        wrrapperList = new List<siteWrapper>();
        selctedAcc = new List<siteWrapper>();
        siteWrapper childSiteWrapper;
        totalVolume = 0 ;
        String Commodity;
        
        for(Site__c seleSite : [Select id,Name,Volume__c,Type__c,Market__c  
                                From Site__c 
                                Where Id IN: siteIds ]){
            childSiteWrapper = new siteWrapper(seleSite);
            childSiteWrapper.isSelected = true;
            wrrapperList.add(childSiteWrapper);
            selctedAcc.add(childSiteWrapper);
            if(seleSite.Volume__c != null){
            	totalVolume += seleSite.Volume__c;
            }
            Commodity = seleSite.Type__c;
        }
        System.debug('selctedAcc::'+selctedAcc);
        Market__c selectedMarketRecord ;
        For(Market__c market :[Select Id,Gas_Threshold__c, Electricity_Threshold__c 
                               From Market__c Where Id = :selectedMarket]){
            selectedMarketRecord = market;
        }
        if(Commodity == selectedCommGas){
            if(totalVolume < selectedMarketRecord.Gas_Threshold__c){
                selectedSize = ConstantString.SMALL_TYPE;
            }else{
                selectedSize = ConstantString.SIZE_LARGE;
            }
        }else if(Commodity == selectedCommElec){ 
            if(totalVolume < selectedMarketRecord.Electricity_Threshold__c){
                selectedSize = ConstantString.SMALL_TYPE;
            }else{
                selectedSize = ConstantString.SIZE_LARGE;
            }
        }
        System.debug('selectedSize = '+selectedSize);
    }
    /*********************************************************
    @Name 			: addNewOpp
    @Reutrn type 	: List<oppListWrapper>
    @Description 	: add new Opportunity
	********************************************************/
    public List<oppListWrapper> addNewOpp(){
        oppListWr.add(new oppListWrapper(new opportunity()));
        return oppListWr;
    }
    /*********************************************************
    @Name 			: getStandardPB
    @Reutrn type 	: string
    @Description 	: Get Standard Pricebook
	********************************************************/
    public static string getStandardPB(){
        if (Test.isRunningTest())   return Test.getStandardPricebookId();
        For(Pricebook2 pb :[select id, name 
                            From Pricebook2 Where isStandard = true]){
            if(pb!=null){
                return pb.id;
            }
        }
        
        return null;
    }    
    /*********************************************************
    @Name 			: getMonthMap
    @Parameters 	: 
    @Reutrn type 	: Map<String,Integer>
    @Description 	: get month
	********************************************************/
        public static Map<String,Integer> getMonthMap(){
            return new Map<String,Integer>{
                'january'=>1,
                    'february'=>2,
                    'march'=>3,
                    'april'=>4,
                    'may'=>5,
                    'june'=>6,
                    'july'=>7,
                    'august'=>8,
                    'september'=>9,
                    'october'=>10,
                    'november'=>11,
                    'december'=>12          
                    };
                        } 
    
    /*********************************************************
    @Name 			: createOppLineData
    @Reutrn type 	: PageReference
    @Description 	: Create OPPLine Item
	********************************************************/
    public PageReference createOppLineData(){
        String pageMessage = '';
        if(maxMargin != null && minMargin != null && (marginChosen > maxMargin || marginChosen < minMargin)){
            System.debug('inside if marginChosen : '+ marginChosen);
            pageMessage = Label.Margin_must_be  + ' Min : ' + minMargin +' and Max : '+ maxMargin;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
            return null;                
        }
        else if(maxMargin != null && marginChosen > maxMargin){
            System.debug('inside if marginChosen : '+ marginChosen);
            pageMessage = Label.Margin_must_be  + ' Max : '+ maxMargin;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
            return null;                                
        }
        else if(minMargin != null && marginChosen < minMargin){
            System.debug('inside if marginChosen : '+ marginChosen);
            pageMessage = Label.Margin_must_be  + ' Min : ' + minMargin;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
            return null;                                                
        }
        Account parentAcc = [Select id,name,Status__c,Primary_Contact__c 
                             From account where id =:recordId];
        System.debug('parentAcc::'+parentAcc);
        Opportunity opp ;
        String stdPB = getStandardPB();
        String proId = fetchProduct();
        System.debug('selectedMonthYear : '+selectedMonthYear);
        Month_Year__c monthYear = [Select id 
                                   From Month_Year__c Where name =:selectedMonthYear limit 1];
        System.debug('stdPB::'+stdPB);
        System.debug('proId::'+proId);
        System.debug('selectedPriceType : '+selectedPriceType);
        RecordType selectedRecodType;
        for(RecordType rt : [SELECT  ID, Name, sObjectType 
                             From RecordType Where sObjectType = 'Opportunity' ]){
                                 if(selectedPriceType == rt.Name){
                                     selectedRecodType = rt;                 
                                 }                      
                             }
        pricebookentry pbe = [Select id , Product2Id 
                              From pricebookentry Where pricebook2id = :stdPB and product2id =:proId  limit 1];
        System.debug('selectedSupplierFromChart::'+selectedSupplierFromChart);
        List<String> stDateList = selectedMonthYear.split(' ');
        String SelectedSupplierID;
        if(getSelectedSupplierId() != null ){
          SelectedSupplierID = Id.valueOf(getSelectedSupplierId());  
        }
        system.debug('SelectedSupplierID ::'+ SelectedSupplierID);
        Decimal DNEAdminFee = PriceListUtility.getDNEAdminFee(SelectedSupplierID,selectedPriceType,selectedCommodity,selectedSize,selectedMarket);
        system.debug('DNEAdminFee ::'+DNEAdminFee);
        For(oppListWrapper owr :oppListWr){
            opp = new Opportunity();
            opp.DNE_Admin_Fee__c = DNEAdminFee;
            owr.oppty.RecordType = selectedRecodType;
            if(parentAcc.Status__c != 'Contracted'){
                owr.oppty.type = 'New Business';
            }
            if(parentAcc.Status__c == 'Contracted'){
                owr.oppty.type = 'Renewal';
            }
            owr.oppty.name = theAccount.name +'-'+String.valueOf(System.today());
            owr.oppty.closedate = system.today();
            owr.oppty.Pricebook2Id = stdPB;
            owr.oppty.accountId = recordId;
            owr.oppty.Subscription_Term__c = Integer.valueOf(selectedNbOfYears);
            owr.oppty.Margin__c = marginChosen;
            owr.oppty.Market__c = selectedMarket;
            owr.oppty.Selling_Price__c = sellingPrice;
            if(selectedPriceType == ConstantString.FIXED_TYPE){
                owr.oppty.Supplier_Price__c  = Decimal.valueOf(selectedPrice);
            }else if(selectedPriceType == ConstantString.VARIABLE_TYPE){
                owr.oppty.Admin_Fee__c = Decimal.valueOf(selectedPrice);
            }
            System.debug('selectedCommodity::'+selectedCommodity);
            owr.oppty.Commodity_Type__c = selectedCommodity;
            if(selectedCommodity == selectedCommGas){
                owr.oppty.Gas_Product_of_Choice__c = selectedPriceType;
            }
            if(selectedCommodity == selectedCommElec){
                owr.oppty.Electricity_Product_of_Choice__c = selectedPriceType;
            }
            if(monthYear != null){
                owr.oppty.Month_Year__c = monthYear.id;
            }
            if(SelectedSupplierID != null){
            	owr.oppty.Supplier__c = SelectedSupplierID;
        	}
            owr.oppty.Flow_Date__c =Date.newInstance(Integer.valueOf(stDateList.get(1)), getMonthMap().get(stDateList.get(0).toLowerCase()), 1);
            opp = owr.oppty;
            system.debug('opp.name::'+opp.name);
        }
        if(opp!=null && selctedAcc.size()>0){
            try{
                system.debug('New Opp :: -->'+opp.DNE_Admin_Fee__c);
                INSERT opp;
            }
            catch(Exception ex){
                System.debug(ex.getMessage());
            }
        }
        // Create CPQ quote
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(oppListWrapper owr :oppListWr){
            owr.newQuote = new SBQQ__Quote__c();
            owr.newQuote.SBQQ__Opportunity2__c = owr.oppty.id;
            owr.newQuote.SBQQ__Primary__c = true;
            owr.newQuote.margin__c = marginChosen;
            owr.newQuote.SBQQ__PricebookId__c = stdPB;
            owr.newQuote.SBQQ__StartDate__c = Date.newInstance(Integer.valueOf(stDateList.get(1)), getMonthMap().get(stDateList.get(0).toLowerCase()), 1);//Date.valueOf(selectedMonthYear);
            owr.newQuote.SBQQ__SubscriptionTerm__c = Integer.valueOf(selectedNbOfYears);
            owr.newQuote.Supplier__c = SelectedSupplierID;
            owr.newQuote.Administration_Fee__c  = owr.oppty.Admin_Fee__c;
            owr.newQuote.Selling_Price__c = sellingPrice;
            owr.newQuote.Supplier_Price__c  = Decimal.valueOf(selectedPrice);
            if(parentAcc.Primary_Contact__c !=NULL){
                
                owr.newQuote.Billing_Contact__c = parentAcc.Primary_Contact__c;
            }
            if(parentAcc.Primary_Contact__c !=NULL){
                
                owr.newQuote.Primary_Contact__c = parentAcc.Primary_Contact__c;
            }
            owr.newQuote.SBQQ__ExpirationDate__c = opp.CloseDate;
            quoteList.add(owr.newQuote);
        }
        if(quoteList.size()>0){
            try{
                INSERT quoteList;
            }catch(Exception ex){
                System.debug(ex.getMessage());
            }
        }
      
        List<Opportunity_Site__c> siteList = new List<Opportunity_Site__c>();
        Opportunity_Site__c site;
        For(oppListWrapper owr :oppListWr){
            for(siteWrapper olw :selctedAcc){
                site = new Opportunity_Site__c();
                site.Market__c = owr.oppty.market__c;
                site.Site__c = olw.Site.id;
                site.Opportunity__c = owr.oppty.id;
                siteList.add(site);
            }
        }
        System.debug('siteList::'+siteList);
        if(siteList.size()>0){
            try{
                INSERT siteList;
            }catch(Exception ex){
                System.debug(ex.getMessage());
            }
        }
    
        System.debug('opp::'+opp);
        opp.DNE_Admin_Fee__c = DNEAdminFee;
        Update opp;
        PageReference pr;
        if(opp.id != null && selctedAcc.size()>0){
            pr = new PageReference('/'+opp.id); 
            pr.setRedirect(true);}
        return pr;
    }
    /*********************************************************
    @Name 			: reloadPage
    @Reutrn type 	: PageReference
    @Description 	: reload pricing chart page
    ********************************************************/
    public PageReference reloadPage() {
        redirectUrl = '/apex/PricingChartForAll?id ='+recordId;
        return null;
    }
    /*********************************************************
    @Name 			: GraphValue
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: Wrapper class for Graph values
    ********************************************************/
    public class GraphValue{
        public Integer yearsOfContract {get; set;}
        public Decimal price {get; set;}
        
        public GraphValue(Integer yoc, Decimal p)
        {
            this.yearsOfContract = yoc;
            this.price = p;
        }
    }
    /*********************************************************
    @Name 			: siteWrapper
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: Wrapper class for site
    ********************************************************/
    
    public class siteWrapper {
        public Site__c site {get;set;}
        public Boolean isSelected{get;set;}
        public siteWrapper(Site__c a) {
            site = a;
            isSelected = false;
        }  
    }
    /*********************************************************
    @Name 			: oppListWrapper
    @Description 	: Wrapper class for different site data
	********************************************************/
    public class oppListWrapper {
        public Opportunity oppty{get;set;}
        Public SBQQ__Quote__c  newQuote{get;set;}
        public List<siteWrapper> selectedsitewr{get;set;}
        public oppListWrapper(Opportunity op) {
            oppty = op;
            oppty.StageName = 'Qualification';
            selectedsitewr = new List<siteWrapper>();
        }
    }
    
    /*********************************************************
    @Name 			: getTreeData
    @Reutrn type 	: PageReference
    @Description 	: get selected market 
	********************************************************/
    public PageReference getTreeData(){
        
        //selectedMarket = 'Alberta';
        
        addressSiteMap = new Map<Id,TreeWrapper>();
        TreeWrapper treewrp ;
        
        for(Account addressAccount: [Select Id, name,ParentId,BillingState,Total_Annual_Volume_ElectrictIy__c,Total_Annual_Volume_Gas__c,
                                     Market__r.Name 
                                     From Account 
                                     Where parentId=:recordId AND Market__c =:selectedMarket
                                    ] ){
            treewrp = new TreeWrapper(recordId,addressAccount) ;  
            addressSiteMap.put(addressAccount.Id,treewrp);                            
        } 
        
        System.debug('addressSiteMap=='+addressSiteMap);
        
        for(Site__c site:[Select Id, name,Market__c,Volume__c,Type__c , Unit_of_Measure__c ,Account__c 
                          From Site__c Where Account__c IN:addressSiteMap.keySet() And Type__c =:selectedCommodity]){
            addressSiteMap.get(site.Account__c).addSite(site);
        }
        
        System.debug('addressSiteMap=='+addressSiteMap);
        
        jsonDataForAddressSite= String.escapeSingleQuotes(JSON.serialize(addressSiteMap));
            
        System.debug('jsonDataForAddressSite::'+jsonDataForAddressSite);
        return null ;
    }
    /*********************************************************
    @Name 			: TreeWrapper
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: 
    ********************************************************/  
    public class TreeWrapper{
        
        public String parentAccountId {get;set;}
        public Account parentAccountDetail {get;set;}
        public Account addressAccount {get;set;}
        public List<Site__c> siteList {get;set;}
        
        /*********************************************************
		@Name 			: TreeWrapper
		@Parameters 	: String, Id:parentId
		@Description 	: Constructor
		********************************************************/
        
        public TreeWrapper(String parentId){
            this.parentAccountId = parentId;
            this.addressAccount = new Account();
            this.siteList = new List<Site__c>();
            this.parentAccountDetail = [Select Id, Name 
                                        From Account Where Id=: parentId] ;
        }
        /*********************************************************
    	@Name 			: TreeWrapper
    	@Parameters 	: String, Id:parentId, Account:acc
    	@Description 	: Constructor
		********************************************************/
        public TreeWrapper(String parentId, Account acc){
            this.parentAccountId = parentId;
            this.addressAccount = acc;
            this.siteList = new List<Site__c>();
            this.parentAccountDetail = [Select Id, Name 
                                        From Account Where Id =: parentId] ;
        }
        /*********************************************************
        @Name 			: addSite
        @Parameters 	: Site__c:site
        @Reutrn type 	: void
        @Description 	: add site
        ********************************************************/
        public void addSite(Site__c site){
            this.siteList.add(site);
        }
            
    } // End Of Wrapper Class      
} // End of Controller Class