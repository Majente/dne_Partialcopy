/**************************************************
* Class: PriceListUtility
* Author: Soljit <VW>
* Date: 2019-05-06
* 
****************************************************/
public class PriceListUtility {
    public static Map<String,Assumption__c> allAssumption; 
    /*********************************************************
    @Name 			: getTodayPriceList
    @Parameters 	: String selectedMarket,String selectedCommodity,String selectedSize,String selectedSupplier
    @Reutrn type 	: Map<Id,List<Price_List__c>>
    @Description 	: get today price list
	********************************************************/
    public static Map<Id,List<Price_List__c>> getTodayPriceList(String selectedMarket,String selectedCommodity,String selectedSize,String selectedSupplier ){
        String selectedPriceType = ConstantString.FIXED_TYPE;
        Datetime dtNow = Datetime.now();
        List<String> selectedSupplierList = new List<String>();
        if(String.isNotBlank(selectedSupplier)) {
            selectedSupplierList = selectedSupplier.split(';');
        }
        // Get number of days from custom setting , till date we need to show price list
        if(PriceListValidateDate__c.getOrgDefaults() != null){
            PriceListValidateDate__c validDate;
            validDate = PriceListValidateDate__c.getOrgDefaults();
            Integer mDays = Integer.valueOf(validDate.Validate_Date__c);
            dtNow = Datetime.now().addDays(-mDays);
        }
       
        String priceListQuery = 'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, ';
            priceListQuery += 'LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, ';
            priceListQuery += 'LastReferencedDate, Product_Code__c, Type__c, Size__c, Term__c, List_Price__c, ';
            priceListQuery += 'Market__c,Market__r.Name, Currency_ISO_Code__c, Supplier__c, Month__c, Effective_From__c, ';
            priceListQuery += 'Effective_To__c, Month_Year__c,Month_Year__r.Name, Supplier__r.Name ';
            priceListQuery += 'FROM Price_List__c ';
      
        	priceListQuery += ' WHERE ';
        	priceListQuery += ' Size__c = :selectedSize AND Market__c = :selectedMarket ';
        	priceListQuery += 'AND Name = :selectedCommodity   AND Month_Year__c != null ';
        	priceListQuery += 'AND Type__c =:selectedPriceType  '; //AND Latest__c = true
			priceListQuery += 'AND Effective_To__c >= :dtNow ';
        	
        if(!selectedSupplierList.isEmpty()) {
            priceListQuery += 'AND Supplier__c IN :selectedSupplierList ';
        }
        
		
        priceListQuery += 'ORDER BY Term__c,Effective_From__c ASC';
        System.debug('###>  priceListQuery = '+ priceListQuery);
        Map<Id,List<Price_List__c>> priceMapToShow = new Map<Id,List<Price_List__c>>();
        String supplierId;

        List<Price_List__c> plList = Database.query(priceListQuery);
        system.debug('plList:::::' +plList);
        plList = getValidatedPriceList(plList);
        if(plList.isEmpty())
        {
            return priceMapToShow;
        }
        Map<String,Decimal> priceAdjustmentMap = getAllAssumptions(selectedSupplier, selectedPriceType);
        System.debug('JTM - plList = ' + plList.size());
        System.debug('JTM - priceAdjustmentMap = ' + priceAdjustmentMap);
        
        for(Price_List__c pl : plList) 
        {   
            System.debug('JTM - pl-before = ' + pl);
            String theKey = pl.Supplier__c + '~' + pl.Market__c + '~' + selectedCommodity + '~' + selectedSize;
            System.debug('JTM - theKey = ' + theKey);

            //fixing the price to show (+Admin Fee +Discount +MinMargin)
            if(priceAdjustmentMap.containsKey(theKey))
            {
                Decimal adjustmentValue = priceAdjustmentMap.get(theKey);
                pl.List_Price__c += adjustmentValue;
            }
            System.debug('JTM - pl-after = ' + pl);
            System.debug('JTM - --------------- ');

            supplierId = pl.Supplier__c;
            if(!priceMapToShow.containsKey(supplierId)){
                priceMapToShow.put(supplierId,new List<Price_List__c>());
            }
            
            //Check whether list price for Gas or Electricity.   11-06-2019
            if(pl.Market__r.Name == 'Alberta'){
            	pl.List_Price__c = checkListPrice(pl.List_Price__c,pl.Name);   
            }
            
            priceMapToShow.get(supplierId).add(pl);
        }
        return priceMapToShow;
    }
    
    /*********************************************************
    @Name 			: getTodayPriceListUpdated
    @Parameters 	: String selectedMarket,String selectedCommodity,String selectedSize,String selectedSupplier,String selectedPriceType 
    @Reutrn type 	: Map<Id,List<Price_List__c>>
    @Description 	: getLatestPriceUpdated from Price List Object
	********************************************************/
    public static Map<Id,List<Price_List__c>> getTodayPriceListUpdated(String selectedMarket,String selectedCommodity,String selectedSize,String selectedSupplier,String selectedPriceType ){
       
        Datetime dtNow ;
        String priceType =selectedPriceType;
        List<String> selectedSupplierList = new List<String>();
        Map<Id,List<Price_List__c>> priceMapToShow = new Map<Id,List<Price_List__c>>();
        List<Price_List__c> plList  = new List<Price_List__c>();
        String supplierId;
        String priceListQuery;
        System.debug('priceType::'+priceType);
        System.debug('JTM - getTodayPriceList ');
        if(String.isNotBlank(selectedSupplier)) {
            selectedSupplierList = selectedSupplier.split(';');
        }
         // Get number of days from custom setting , till date we need to show price list
        if(PriceListValidateDate__c.getOrgDefaults() != null){
            PriceListValidateDate__c validDate;
            validDate = PriceListValidateDate__c.getOrgDefaults();
            Integer mDays = Integer.valueOf(validDate.Validate_Date__c);
            dtNow = Datetime.now().addDays(-mDays);
        }
        Month_Year__c mmyear = [Select Id From Month_Year__c 
                                Where month__c =: System.now().month() And
                                year__c =: System.now().year() limit 1]; 

        priceListQuery = 'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, ';
        priceListQuery += 'LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, ';
        priceListQuery += 'LastReferencedDate, Product_Code__c, Type__c, Size__c, Term__c, List_Price__c, ';
        priceListQuery += 'Market__c,Market__r.Name, Currency_ISO_Code__c, Supplier__c, Month__c, Effective_From__c, ';
        priceListQuery += 'Effective_To__c, Month_Year__c,Month_Year__r.Name, Supplier__r.Name ';
        priceListQuery += 'FROM Price_List__c ';
        priceListQuery += 'WHERE ';
        priceListQuery += ' Size__c = :selectedSize AND Market__c = :selectedMarket ';
        priceListQuery += 'AND Name = :selectedCommodity   AND Month_Year__c != null ';
        priceListQuery += 'AND Type__c =:priceType  ';//AND Latest__c = true
        priceListQuery += 'AND Effective_To__c >= :dtNow ';
        if(!selectedSupplierList.isEmpty()) {
            priceListQuery += 'AND Supplier__c IN :selectedSupplierList ';
        }
        priceListQuery += 'ORDER BY Effective_From__c,Term__c ASC';
        System.debug('###>  priceListQuery = '+ priceListQuery);
        system.debug('###selectedSupplierList' +selectedSupplierList);
        plList  = Database.query(priceListQuery);
        plList = getValidatedPriceList(plList);
        System.debug('##### plList size :::: ' + plList.size());
        if(priceType == ConstantString.VARIABLE_TYPE && plList.size() < 1){
            Price_List__c dummyPoint;
            for(String supplier : selectedSupplierList){
                for(Integer i=12 ; i<=60; i+=12){
                    dummyPoint = new Price_List__c();
                    dummyPoint.Name = selectedCommodity;
                    dummyPoint.Supplier__c = supplier;
                    dummyPoint.Latest__c = true;
                    dummyPoint.List_Price__c = 0;
                    dummyPoint.Market__c = selectedMarket;
                    dummyPoint.Month_Year__c = mmyear.Id;
                    dummyPoint.Term__c = String.valueOf(i);
                    dummyPoint.Type__c = priceType;
                    dummyPoint.Effective_From__c = Datetime.now();
                    dummyPoint.Effective_To__c = Datetime.now().addDays(2);
                    plList.add(dummyPoint);
                }
            }            
        } 
                
        if(plList.isEmpty())
        {
            return priceMapToShow;
        }
        
        Map<String,Decimal> priceAdjustmentMap = getAllAssumptions(selectedSupplier, selectedPriceType);

        System.debug('JTM - plList = ' + plList.size());
        System.debug('JTM - priceAdjustmentMap = ' + priceAdjustmentMap);
        
        for(Price_List__c pl : plList) 
        {   
            System.debug('JTM - pl-before = ' + pl);
            String theKey = pl.Supplier__c + '~' + pl.Market__c + '~' + selectedCommodity + '~' + selectedSize;
            System.debug('JTM - theKey = ' + theKey);

            //fixing the price to show (+Admin Fee +Discount +MinMargin)
            if(priceAdjustmentMap.containsKey(theKey))
            {
                Decimal adjustmentValue = priceAdjustmentMap.get(theKey);
                pl.List_Price__c += adjustmentValue;
                if(priceType == ConstantString.VARIABLE_TYPE && allAssumption.ContainsKey(pl.Supplier__c)){
                   pl.Effective_From__c = allAssumption.get(pl.Supplier__c).Start_Date__c;
                   pl.Effective_To__c = allAssumption.get(pl.Supplier__c).End_Date__c;
                }
            }
            System.debug('JTM - pl-after = ' + pl);
            System.debug('JTM - --------------- ');

            supplierId = pl.Supplier__c;
            if(!priceMapToShow.containsKey(supplierId)){
                priceMapToShow.put(supplierId,new List<Price_List__c>());
            }
            //Check whether list price for Gas or Electricity.   11-06-2019
            if(pl.Market__r.Name == 'Alberta'){
            	pl.List_Price__c = checkListPrice(pl.List_Price__c,pl.Name);   
            }
            priceMapToShow.get(supplierId).add(pl);
            System.debug('##### pl ::::: ' + pl);
        }
        return priceMapToShow;
    }
    //-----------------------------
    public static Map<Id,List<Price_List__c>> getTodayPriceListNewUpdated(String selectedMarket,
                                                                          String selectedCommodity,
                                                                          String selectedSize,
                                                                          String selectedSupplier ,
                                                                          String selectedPriceType)
    {
        Map<Id,List<Price_List__c>> priceMapToShow = new Map<Id,List<Price_List__c>>();
        List<Price_List__c> plList = new List<Price_List__c>();
        String supplierId;
        String monthyearId;
        List<String> selectedSupplierList = new List<String>();
        if(String.isNotBlank(selectedSupplier)) {
            selectedSupplierList = selectedSupplier.split(';');
        }
        String priceType =selectedPriceType;
        Datetime dtNow = Datetime.now();
        Market__c selectedMarketRecord ;
        For(Market__c market :[Select Id,Name From Market__c Where Id = :selectedMarket]){
            selectedMarketRecord = market;
        }
         // Get number of days from custom setting , till date we need to show price list
        if(PriceListValidateDate__c.getOrgDefaults() != null){
            PriceListValidateDate__c validDate;
            validDate = PriceListValidateDate__c.getOrgDefaults();
            Integer mDays = Integer.valueOf(validDate.Validate_Date__c);
            dtNow = Datetime.now().addDays(-mDays);
        }
        System.debug('dtNow::'+dtNow);
         Month_Year__c mmyear = [SELECT Id 
                                  FROM Month_Year__c WHERE Month__c =: System.now().month()
                                  AND Year__c =: System.now().year() 
                                  LIMIT 1]; 
        
        String priceListQuery = 'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, ';
        priceListQuery += 'LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, ';
        priceListQuery += 'LastReferencedDate, Product_Code__c, Type__c, Size__c, Term__c, List_Price__c, ';
        priceListQuery += 'Market__c, Currency_ISO_Code__c, Supplier__c, Month__c, Effective_From__c, ';
        priceListQuery += 'Effective_To__c, Month_Year__c,Month_Year__r.Name, Supplier__r.Name ';
        priceListQuery += 'FROM Price_List__c ';
        priceListQuery += 'WHERE ';
        priceListQuery += 'Size__c = :selectedSize AND Market__c = :selectedMarket ';
        priceListQuery += 'AND Name = :selectedCommodity   AND Month_Year__c != null ';
        priceListQuery += 'AND Type__c =:priceType  '; //AND Latest__c = true
        priceListQuery += 'AND Effective_To__c >= :dtNow ';
        if(!selectedSupplierList.isEmpty()) {
            priceListQuery += 'AND Supplier__c IN :selectedSupplierList ';
        }
        priceListQuery += 'ORDER BY Month_Year__r.Year__c,Month_Year__r.Month__c,Effective_From__c ASC';
        System.debug('###>  priceListQuery = '+ priceListQuery);
        plList = Database.query(priceListQuery);
		plList = getValidatedPriceList(plList);
        if(plList.isEmpty()){
            return priceMapToShow;
        }
        
        Map<String,Decimal> priceAdjustmentMap = getAllAssumptions(selectedSupplier, selectedPriceType);
        
        for(Price_List__c pl : plList) {
            String theKey = pl.Supplier__c + '~' + pl.Market__c + '~' + selectedCommodity + '~' + selectedSize;
            //fixing the price to show (+Admin Fee +Discount +MinMargin)
           if(priceAdjustmentMap.containsKey(theKey))
            {
                Decimal adjustmentValue = priceAdjustmentMap.get(theKey);
                pl.List_Price__c += adjustmentValue;
                if(priceType == ConstantString.VARIABLE_TYPE && allAssumption.ContainsKey(pl.Supplier__c)){
                   pl.Effective_From__c = allAssumption.get(pl.Supplier__c).Start_Date__c;
                   pl.Effective_To__c = allAssumption.get(pl.Supplier__c).End_Date__c;
                }
            }
            System.debug('pl :: ' + pl); 

            monthyearId = pl.Month_Year__c;
         
            if(!priceMapToShow.containsKey(monthyearId))
            {
                Price_List__c dummyPrice = pl.clone(false, true, false, false);
                dummyPrice.List_Price__c = 0;

                priceMapToShow.put(monthyearId,new List<Price_List__c>());
                priceMapToShow.get(monthyearId).add(dummyPrice);                
                //priceMapToShow.get(monthyearId).get(0).set(List_Price__c = 0);
                
                priceMapToShow.get(monthyearId).add(new Price_List__c(List_Price__c = 0));
                priceMapToShow.get(monthyearId).add(new Price_List__c(List_Price__c = 0));
                priceMapToShow.get(monthyearId).add(new Price_List__c(List_Price__c = 0));
                priceMapToShow.get(monthyearId).add(new Price_List__c(List_Price__c = 0));
            }
            if(pl.Term__c == '12'){
                    priceMapToShow.get(monthyearId).set(0,pl);  
                }
                else if(pl.Term__c == '24'){
                    priceMapToShow.get(monthyearId).set(1,pl);  
                }
                else if(pl.Term__c == '36'){
                    priceMapToShow.get(monthyearId).set(2,pl);  
                }
                else if(pl.Term__c == '48'){
                    priceMapToShow.get(monthyearId).set(3,pl);  
                }
                else if(pl.Term__c == '60'){
                    priceMapToShow.get(monthyearId).set(4,pl);  
                }
           // priceMapToShow.get(monthyearId).add(pl);            
        }
        System.debug('priceMapToShow ::: ' + priceMapToShow);
        return priceMapToShow;
    }
    
   /*********************************************************
    @Name 			: getAllAssumptions
    @Parameters 	: String selectedSupplier, String selectedPriceType 
    @Reutrn type 	: Map<String,Decimal>
    @Description 	: get all assumptions
	********************************************************/
    public static Map<String,Decimal> getAllAssumptions(String selectedSupplier, String selectedPriceType){
        // key = Supplier__c~Market__c~Commodity__c~Business_Size__c
        Map<String,Decimal> priceAdjustmentMap = new Map<String,Decimal>();     // adjustment value Map (+adminFee -discount)
        
        List<Id> supplierIdList = new List<Id>();
        if(String.isNotBlank(selectedSupplier)) {
            supplierIdList = selectedSupplier.split(';');
        }

        Date todayDate = Date.today();

        String theQuery = 'SELECT Amount__c,Pricing_Type__c, Business_Size__c, Commodity__c, Market__c, Supplier__c, Type__c,Start_Date__c,End_Date__c ';
        theQuery += 'FROM Assumption__c ';
        theQuery += 'WHERE Active__c = true ';
        theQuery += 'AND Pricing_Type__c = :selectedPriceType ';
        if(!supplierIdList.isEmpty()) {
            theQuery += 'AND Supplier__c IN :supplierIdList ';
        }
        theQuery += 'ORDER BY LastModifiedDate DESC ';


        List<Assumption__c> assumptionList = new List<Assumption__c>();
        try{
            assumptionList = Database.query(theQuery);
        }
        catch(Exception e){
            System.debug('ERROR: PriceListUtility.getAssumptions(): ' + e.getMessage());
            return priceAdjustmentMap;
        }

        System.debug('JTM - assumptionList.size() = ' + assumptionList.size());
        Map<String,Decimal> adminFeeMap = new Map<String,Decimal>();        // admin fees
        Map<String,Decimal> discountMap = new Map<String,Decimal>();        // discounts
        allAssumption =  new Map<String,Assumption__c>();
        for(Assumption__c assump : assumptionList){
            String theKey = assump.Supplier__c + '~' + assump.Market__c + '~' + assump.Commodity__c + '~' + assump.Business_Size__c;
            allAssumption.Put(assump.Supplier__c,assump);
            if(assump.Type__c == ConstantString.ADMIN_FEE && !adminFeeMap.containsKey(theKey)){
                adminFeeMap.put(theKey,assump.Amount__c);
            }
            if(assump.Type__c == ConstantString.DNE_ADMIN_FEE && !adminFeeMap.containsKey(theKey)){
                adminFeeMap.put(theKey,assump.Amount__c);
            }
            if(assump.Type__c == ConstantString.DISCOUNT && !discountMap.containsKey(theKey)){
                discountMap.put(theKey,assump.Amount__c);
            }
        }        
        
        // adding the admin fees to the price adjustment map
        for(String theKey : adminFeeMap.keySet()){
            priceAdjustmentMap.put(theKey,adminFeeMap.get(theKey));
        }
        System.debug('JTM - priceAdjustmentMap 1 = ' + priceAdjustmentMap);
        
        // removing the discounts from the price adjustment map (adding negative amount)
        for(String theKey : discountMap.keySet()){
            // if an admin fee was already added to the map, from the amount we subtract the discount
            if(priceAdjustmentMap.containsKey(theKey)){
                Decimal theValue = priceAdjustmentMap.get(theKey);
                theValue = theValue + discountMap.get(theKey);
                priceAdjustmentMap.put(theKey, theValue);
            }
            // if no admin fee, we add the discount as a negative amount
            else{
                priceAdjustmentMap.put(theKey, discountMap.get(theKey));
            }
        }
        System.debug('JTM - priceAdjustmentMap 2 = ' + priceAdjustmentMap);
        return priceAdjustmentMap;
    }
    
    /*********************************************************
    @Name 			: getMaxMinMargin
    @Parameters 	: String selectedMarket, String selectedCommodity, String selectedSize, String selectedSupplier, String selectedPriceType 
    @Reutrn type 	: Map<String,Decimal>
    @Description 	: get max min margin
	********************************************************/
    public static Map<String,Decimal> getMaxMinMargin(String selectedMarket, String selectedCommodity, String selectedSize, String selectedSupplier, String selectedPriceType){
        Map<String,Decimal> margins = new Map<String,Decimal>();
        Date todayDate = Date.today();
        List<Id> supplierIdList = new List<Id>();
        if(String.isNotBlank(selectedSupplier)){
            supplierIdList = selectedSupplier.split(';');
        }
        String theQuery = 'SELECT Amount__c,Pricing_Type__c, Business_Size__c, Commodity__c, Market__c, Supplier__c, Type__c ';
        theQuery += 'FROM Assumption__c ';
        theQuery += 'WHERE Active__c = true ';
        theQuery += 'AND Pricing_Type__c = :selectedPriceType ';
        theQuery += 'AND Commodity__c =  :selectedCommodity ';
        theQuery += 'AND Business_Size__c =  :selectedSize ';
        theQuery += 'AND Market__c =  :selectedMarket ';
        if(!supplierIdList.isEmpty()){
            theQuery += 'AND Supplier__c IN :supplierIdList ';
        }
        theQuery += 'ORDER BY LastModifiedDate DESC ';
        List<Assumption__c> assumptionList = new List<Assumption__c>();
        try{
            for(Assumption__c rec : Database.query(theQuery)){
                margins.put(rec.Type__c, rec.Amount__c);
            }
        }catch(Exception e){
            System.debug('ERROR: PriceListUtility.getMaxMargin(): ' + e.getMessage());
        }

        System.debug('JTM - margins = ' + margins);

        return margins;
    }
    
    /*********************************************************
    @Name 			: checkListPrice
    @Parameters 	: Decimal listPrice, String name 
    @Reutrn type 	: Double
    @Description 	: check list price
	********************************************************/
    //Check whether list price for Gas or Electricity. If electricity then we calculate list price for MWh.   11-06-2019
    public static Double checkListPrice(Decimal listPrice, String name) {        
       if(name == ConstantString.PRODUCT_ELECTRICITY){
            return listPrice / 1000;
        }
        else{
            return listPrice;            
        }
    }
    
    /*********************************************************
    @Name 			: getValidatedPriceList
    @Parameters 	: List<Price_List__c> plList
    @Reutrn type 	: List<Price_List__c>
    @Description 	: To Extract only latest records
	********************************************************/
    public static List<Price_List__c>  getValidatedPriceList(List<Price_List__c> plList ){
    	Map<String, Map<String,Price_List__c>> mapOfPriceList = new Map<String, Map<String,Price_List__c>>();
    	Map<String,Price_List__c> termMap;
    	List<Price_List__c> latestList =  new List<Price_List__c>();
        String key;
        system.debug('utility plist:::' +plList);
    	for(Price_List__c plist : plList){
            key = plist.Month_Year__c + ''+ plist.Term__c;
    		if(!mapOfPriceList.containsKey(plist.supplier__c)){
    			termMap = new Map<String,Price_List__c>();
    			termMap.put(key,plist);
    			mapOfPriceList.put(plist.supplier__c,termMap);
    		}else{
                termMap = mapOfPriceList.get(plist.supplier__c);
                termMap.put(key,plist);
    		}
    	} 
        integer i=0;
    	for(String supplier : mapOfPriceList.keySet()){
            //system.debug('PriceList Class : ' + mapOfPriceList.get(supplier));
            i++;
    		for(Price_List__c p : mapOfPriceList.get(supplier).Values()){
                system.debug( i+'. Suplier : '  + p.Supplier__r.Name + '  Month Year : ' + p.Month_Year__r.Name+ '  List Price : ' + p.List_Price__c);
    			latestList.add(p);
                System.debug('###### p ::: ' + p);
    		}
    	}
    	return latestList;
    }
    /*********************************************************
    @Name 			: getDNEAdminFee
    @Parameters 	: selectedSupplier ,selectedPriceType
    @Reutrn type 	: Decimal
    @Description 	: get DNE fee value
	********************************************************/
    
    public static Decimal getDNEAdminFee(String selectedSupplier, String selectedPriceType, String selectedCommodity, String selectedSize,String selectedMarket)
    {   
        Decimal dneAdminFee = 0;
        for(Assumption__c AssumptionRecord : [SELECT Amount__c FROM Assumption__c WHERE Active__c = true
                                              AND Pricing_Type__c = :selectedPriceType
                                              AND  Type__c =: ConstantString.DNE_ADMIN_FEE
                                              AND Supplier__c =: selectedSupplier 
                                              AND Commodity__c =: selectedCommodity
                                              AND Business_Size__c =: selectedSize
                                              AND Market__c =: selectedMarket ])
        {
            if(AssumptionRecord.Amount__c != null){
              dneAdminFee = AssumptionRecord.Amount__c;
               break;
            }
        }
        return dneAdminFee;
    }
}