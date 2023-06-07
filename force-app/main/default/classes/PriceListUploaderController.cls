/**************************************************
* Class : PriceListUploaderController
* Author: SOLJIT 
* Date  : 25/04/2019
****************************************************/
public with sharing class PriceListUploaderController {
    public String documentName {get;set;}
    public String csvFileBody{get;set;} 
    //public String[] priceListDataLines;
    public List<jsonReadWrapper> priceListDataLines {get;set;}
    public List<Price_List__c> priceListToUpsert {get;set;}
    public Boolean readSuccess {get;set;}
    public List<String> priceListFieldNames{get;set;}
    Price_List__c priceListObj;
    String priceListDataAsString;
    private List<Price_List__c> priceListToUpdate = new List<Price_List__c>();
    public Price_List__c mockPL {get; set;}
    
    public Set<String> prodCodeSet;
    public Set<String> marketSet;
    public Set<String> supplierSet;
    public Set<String> monthYearSet;
    public Set<String> termSet;
    
    public Map<String,String> prodCodeMap;
    public Map<String,String> marketMap;
    public Map<String,String> supplierMap;
    public Map<string,Price_List__c> completeValueMap;
    //public Map<String,String> monthYearMap {get;set;}
    
    string mapKey = '';
    String prodCode = '';
    String monthYear = '';
    String term = '';
    String market = '';
    String Supplier = '';
   
    /*********************************************************
    @Name 			: PriceListUploaderController
    @Parameters 	: ApexPages.StandardController
    @Reutrn type 	: void
    @Description 	: Constructor
	********************************************************/
    public PriceListUploaderController(ApexPages.StandardSetController cont) {
        csvFileBody ='';
        documentName = '';
        readSuccess = false;
        priceListDataLines = new List<jsonReadWrapper>();        
        priceListToUpsert = new List <Price_List__c> ();
        priceListFieldNames = new List<String>{'Name','Product_Code__c','Market__c','Supplier__c','Month_Year__c','Term__c','Size__c','Type__c','List_Price__c','Effective_From__c','Effective_To__c'};
        priceListDataAsString = '';
        
        mockPL = new Price_List__c();
        prodCodeSet = new Set<String>();
        marketSet = new Set<String>();
        supplierSet = new Set<String>();
        monthYearSet = new Set<String>();
        termSet = new Set<String>();
        
        prodCodeMap = new Map<String,String>();
        marketMap = new Map<String,String>();
        supplierMap = new Map<String,String>();
        completeValueMap = New Map<String,Price_List__c>();
    }
    /*********************************************************
    @Name 			: getProducts
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: get product list
	********************************************************/
    public void getProducts(){
        System.debug('getProducts');
        for(Product2 pro : [SELECT id,Name,ProductCode 
                            FROM Product2 WHERE ProductCode IN : prodCodeSet]){
                                System.debug('pro.ProductCode::'+pro.ProductCode);
                                prodCodeMap.put(pro.ProductCode,pro.Name);
                            }
    }
    /*********************************************************
    @Name 			: getMarket
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: get market list
	********************************************************/
    public void getMarket(){
        for(Market__c mrkt : [SELECT Id,Name 
                              FROM Market__c WHERE Name IN : marketSet]){
                                  marketMap.put(mrkt.Name,mrkt.Id);  
                              }
    }
    /*********************************************************
    @Name 			: getSupplier
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: get supplier list
	********************************************************/
    public void getSupplier(){
        System.debug('**** Supplier Set :: '+supplierSet );
        for(Account acc : [SELECT Id,Name 
                           FROM Account WHERE Name IN : supplierSet
                           AND recordtype.name = 'Supplier']){
                               supplierMap.put(acc.Name,acc.Id);  
                           }
                                       System.debug('**** supplierMap :: ' + supplierMap );

    }
    
    /*********************************************************
    @Name 			: readFromFile
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: read from file
	********************************************************/
    public void readFromFile(){
        System.debug('mockPL::'+mockPL);
        Boolean validationError = false;
        if(mockPL.Effective_From__c==null || mockPL.Effective_To__c==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Please_select_Effective_From_and_Effective_To));
            return;
        }
        if(csvFileBody==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Please_select_a_CSV_file));
            return;
        }
        
        try{
            //priceListDataAsString = csvFileBody.toString();
            System.debug('**** '+ csvFileBody);
               priceListDataLines = (List<jsonReadWrapper>)JSON.deserialize(csvFileBody,List<jsonReadWrapper>.class);
            System.debug('jsonReadWrapper==='+priceListDataLines.size());
            readCSVFile();
            if(priceListToUpsert.size() < 1){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.There_is_invalid_data_in_CSV_file));
            }
            return;
        }
        catch(Exception e){
            readSuccess = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Error_reading_CSV_file);
            ApexPages.addMessage(errorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.Cause + e.getMessage()));
            return;
        }
    }
    /*********************************************************
    @Name 			: readCSVFile
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: read CSV file for price list records
	********************************************************/
    public void readCSVFile() {
        String pSize;
        String pType;
        Map<String,String> monthYearMap = new Map<String,String>();
        Map<String, Month_Year__c> newMapOfMY = new Map<String, Month_Year__c>();
        for(Month_Year__c my : [SELECT Name,Month__c,Year__c FROM Month_Year__c ]){
            monthYearMap.put(my.Name.replaceAll(' ',''),my.Id);
        }
       System.debug('**** priceListDataLines :: '+priceListDataLines);
       
        for(Integer i=0; i<priceListDataLines.size(); i++){
            System.debug('In for loop');
            String[] csvRecordData = new String[] {priceListDataLines[i].Name,priceListDataLines[i].Size,priceListDataLines[i].Type,priceListDataLines[i].Market,priceListDataLines[i].Supplier,priceListDataLines[i].Term,priceListDataLines[i].List_Price,priceListDataLines[i].Month,priceListDataLines[i].Year};
            
            if(String.IsNotBlank(csvRecordData[0]) && String.IsNotBlank(csvRecordData[1]) && String.IsNotBlank(csvRecordData[2]) && isValidateLargeSize(csvRecordData[1].replaceall('"','').normalizeSpace())){
                pSize = validateSize(csvRecordData[1].replaceall('"',''));
                System.debug('**** pSize :: '+pSize);
                pType = validateType(csvRecordData[2].replaceall('"',''));                
                prodCode = csvRecordData[0].replaceall('"','')+'-'+ pSize +' '+ pType;
                prodCodeSet.add(prodCode);
             }
            if(String.IsNotBlank(csvRecordData[3])){
                market = csvRecordData[3].replaceall('"','');
                marketSet.add(market);
             }
            if(String.IsNotBlank(csvRecordData[4])){
                 supplier = csvRecordData[4].replaceall('"','');
                supplierSet.add(supplier);
             }
            if(String.IsNotBlank(csvRecordData[7]) && String.IsNotBlank(csvRecordData[8])){
                String monthText = getMonthInText(csvRecordData[7].replaceall('"',''));
                monthYear = monthText +''+csvRecordData[8].replaceall('"','').substring(0,4);
                monthYearSet.add(monthYear);
                 System.debug('**** monthYear :: '+ monthYear);
                if(!monthYearMap.containsKey(monthYear) && !newMapOfMY.containsKey(monthYear)){
                    Month_Year__c myear = new Month_Year__c(); 
                    myear.Name = monthText +' '+csvRecordData[8].replaceall('"','').substring(0,4);
        			myear.Month__c = Integer.valueOf(csvRecordData[7].replaceall('"',''));
        			myear.Year__c = Integer.valueOf(csvRecordData[8].replaceall('"','').substring(0,4));
                    newMapOfMY.put(monthYear,myear);
                }
                
             }
            if(String.IsNotBlank(csvRecordData[5])){
                term = csvRecordData[5].replaceall('"','');
                termSet.add(term);
            }
        }
        if(prodCodeSet.size()>0 &&  marketSet.size()>0 && supplierSet.size()>0){
            getProducts();
            getMarket();
            getSupplier();
        }
        // Insert Month year and read them again 
        if(!newMapOfMY.isEmpty()){
             System.debug('**** newMapOfMY.KeySet() :: '+newMapOfMY.KeySet());
             System.debug('**** newMapOfMY.values() :: '+newMapOfMY.values());
            insert newMapOfMY.values();
        	for(Month_Year__c my : newMapOfMY.values()){
            	monthYearMap.put(my.Name.replaceAll(' ',''),my.Id);
        	}
        }
        for(Integer i=0; i<priceListDataLines.size(); i++){
            priceListObj = new Price_List__c();
            
            String[] csvRecordData = new String[] {priceListDataLines[i].Name,priceListDataLines[i].Size,priceListDataLines[i].Type,priceListDataLines[i].Market,priceListDataLines[i].Supplier,priceListDataLines[i].Term,priceListDataLines[i].List_Price,priceListDataLines[i].Month,priceListDataLines[i].Year};
           
            System.debug('**** csvRecordData :: '+csvRecordData);
            
            datetime frmDate = mockPL.Effective_From__c;
            datetime toDate = mockPL.Effective_To__c;
            if(!isValidateLargeSize(csvRecordData[1].replaceall('"','').normalizeSpace())){
                continue;
            }
            
            if(String.IsNotBlank(csvRecordData[0]) && 
               String.IsNotBlank(csvRecordData[1]) && 
               String.IsNotBlank(csvRecordData[2]) 
               ){
                   
                pSize = validateSize(csvRecordData[1]);
                pType = validateType(csvRecordData[2]);
                prodCode = csvRecordData[0]+'-'+ pSize+' '+ pType;
               if(prodCodeMap.containsKey(prodCode)){
                    priceListObj.Name = csvRecordData[0].replaceall('"','');
                    priceListObj.Product_Code__c = prodCode;
                    priceListObj.Size__c = pSize;//csvRecordData[1].replaceall('"','');
                    priceListObj.Type__c = pType;//csvRecordData[2].replaceall('"','');
                 }
             }
            if(String.IsNotBlank(csvRecordData[3])){
                if(marketMap.containsKey(csvRecordData[3].replaceall('"',''))){
                    market = csvRecordData[3].replaceall('"','');
                    priceListObj.Market__c = marketMap.get(market);
                }
            }
            if(String.IsNotBlank(csvRecordData[4])){
                if(supplierMap.containsKey(csvRecordData[4].replaceall('"',''))){
                    supplier = csvRecordData[4].replaceall('"','');
                    priceListObj.Supplier__c =  supplierMap.get(supplier);
                }
            }
            if(String.IsNotBlank(csvRecordData[7]) && String.IsNotBlank(csvRecordData[8])){
                
                String monthText = getMonthInText(csvRecordData[7].replaceall('"',''));
                monthYear = monthText +''+csvRecordData[8].replaceall('"','').substring(0,4);
                if(monthYearMap.containsKey(monthYear)){
                    priceListObj.Month_Year__c = monthYearMap.get(monthYear);
                }else{
                 }
                
            }
            if(String.IsNotBlank(csvRecordData[5])){
                priceListObj.Term__c = csvRecordData[5].replaceall('"','');
                term = priceListObj.Term__c;
            }
            if(String.IsNotBlank(csvRecordData[6])){
                priceListObj.List_Price__c = validatePrice( csvRecordData[6].replaceall('"','').replaceall('$',''));
             }
            priceListObj.Latest__c = true;
            priceListObj.Effective_From__c = mockPL.Effective_From__c;
            priceListObj.Effective_To__c = mockPL.Effective_To__c;
            System.debug('priceListObj ::: ' + priceListObj);
            if(String.IsNotBlank(priceListObj.Name) && String.IsNotBlank(priceListObj.Product_Code__c) 
               && String.IsNotBlank(priceListObj.Size__c) && String.IsNotBlank(priceListObj.Type__c)
               && priceListObj.Market__c != null && priceListObj.Supplier__c != null
               && priceListObj.Month_Year__c != null && String.IsNotBlank(priceListObj.Term__c)
               && priceListObj.List_Price__c != null && priceListObj.Effective_From__c != null
               && priceListObj.Effective_To__c != null){
                   System.debug('**** True');
                   priceListToUpsert.add(priceListObj);
               }
            else
               {
                   System.debug('**** False');
               }
            mapKey = prodCode + ''+ term+''+ monthYear+''+ market+''+ supplier;
            string newMapKey = mapKey.replaceAll( '\\s+', '');
            completeValueMap.put(newMapKey,priceListObj);
        }
        
        List<Price_List__c> pcList = [SELECT Id, Product_Code__c, Type__c, Size__c, Term__c, List_Price__c,
                                      Market__c, Currency_ISO_Code__c, Supplier__c,
                                      Month__c, Effective_From__c, Effective_To__c,Month_Year__r.Name,Supplier__r.Name,Market__r.Name, 
                                      Latest__c, Month_Year__c, Is_Valid__c 
                                      FROM Price_List__c Where Supplier__c IN:supplierMap.values() 
                                      AND Month_Year__c IN: monthYearMap.values() 
                                      AND Term__c IN: termSet 
                                      AND Market__c  IN: marketMap.values() 
                                      AND Product_Code__c IN:prodCodeSet AND Latest__c = true];
        for(Price_List__c priceObj : pcList){
            
            String priceListKey = priceObj.Product_Code__c+''+priceObj.Term__c+''+priceObj.Month_Year__r.Name+''+priceObj.Market__r.Name+''+priceObj.Supplier__r.Name;
            string newPriceListKey = priceListKey.replaceAll( '\\s+', '');
            
            if(completeValueMap.containsKey(newPriceListKey)){
                priceObj.Latest__c = false;
                priceListToUpdate.add(priceObj);
             }
        }
        system.debug('###priceUpdate'+priceListToUpdate.Size());
        system.debug('###priceList'+priceListToUpdate);
        
        if(priceListToUpsert.size() > 0){
            //readSuccess = true;
            System.debug('**** Size of priceListToUpsert :: '+priceListToUpsert.size());
        }
    }
    /*********************************************************
    @Name 			: getMonthInText
    @Parameters 	: String:index
    @Reutrn type 	: String
    @Description 	: get months in text
	********************************************************/
    public String getMonthInText(String index){
        Map<String,String> monthMap = new Map<String,String>{'1'=>'January','2'=>'February','3'=>'March','4'=>'April','5'=>'May',
            '6'=>'June','7'=>'July','8'=>'August','9'=>'September','10'=>'October','11'=>'November','12'=>'December'};
        if(monthMap.containsKey(index)){
            return monthMap.get(index);
        }else{
            return index;
        }
    }
    /*********************************************************
    @Name 			: validateType
    @Parameters 	: String:pType
    @Reutrn type 	: String
    @Description 	: check valid type
	********************************************************/
    public String validateType( String pType){
        if(pType.containsIgnoreCase(ConstantString.FIXED_TYPE)){
            return ConstantString.FIXED_TYPE;
         }else if(pType.containsIgnoreCase(ConstantString.VARIABLE_TYPE)){
                    return ConstantString.VARIABLE_TYPE;
        }
        return pType;   
    }
    /*********************************************************
    @Name 			: validatePrice
    @Parameters 	: String:mPrice
    @Reutrn type 	: Double
    @Description 	: check valid price
	********************************************************/
    public Double validatePrice( String mPrice){
        Decimal iValue = 0;
        
        if(isNumeric(mPrice)){
          iValue = Double.valueOf(mPrice);
        }else {
           iValue =-1;
        }
        return iValue;   
    }
    /*********************************************************
    @Name 			: isNumeric
    @Parameters 	: String:s
    @Reutrn type 	: void
    @Description 	: check numeric value
	********************************************************/
    public static Boolean isNumeric(String s){
        Boolean ReturnValue;
        try{
            Double.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
	/*********************************************************
    @Name 			: validateSize
    @Parameters 	: String:pSize
    @Reutrn type 	: String
    @Description 	: check valid size
	********************************************************/
    public String validateSize( String pSize){
        if(pSize.containsIgnoreCase(ConstantString.SIZE_LARGE)){
            return ConstantString.SIZE_LARGE;
         }else if(pSize.containsIgnoreCase(ConstantString.SMALL_TYPE)){
                    return ConstantString.SMALL_TYPE;
        }
        return pSize;
        
    }
    /*********************************************************
    @Name 			: isValidateLargeSize
    @Parameters 	: String:pSize
    @Reutrn type 	: String
    @Description 	: check valid size for Large
	********************************************************/
    public boolean isValidateLargeSize( String pSize){
        if(pSize.toLowerCase() == 'large' || pSize.toLowerCase() == 'large 11' || pSize.containsIgnoreCase('Small')){
            return true;
        }
        return false;        
    }
    /*********************************************************
    @Name 			: saveData
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: save price list data
	********************************************************/
    public void saveData() 
    {       
        try {   
           System.debug('priceListToUpdate'+priceListToUpdate);
            if(priceListToUpdate.size()>0 ){
                    Set<Price_List__c> priceListSet = new Set<Price_List__c>();
					List<Price_List__c> priceListList = new List<Price_List__c>(); 
					priceListSet.addAll(priceListToUpdate);
					priceListList.addAll(priceListSet);

					UPDATE priceListList; 
                
            }
            UPSERT priceListToUpsert;
            System.debug('**** After Insert priceListToUpsert :: '+priceListToUpsert);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO, Label.Price_List_uploaded_successfully);
            ApexPages.addMessage(errorMessage);
            priceListToUpsert = new List<Price_List__c> ();
        } 
        catch(Exception e) 
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, Label.An_error_has_occured_while_saving_data + e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
    }
 
    public void addLastBatchRecord(){
        if(priceListToUpsert.size() > 0 ){
            readSuccess = True;            
        }
        
    }
    

    /*********************************************************
    @Name 			: jsonReadWrapper
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: wrapper class
	********************************************************/
    public class jsonReadWrapper{
        public String Name {get;set;}
        public String Size {get;set;}
        public String Type {get;set;}        
        public String Market {get;set;}  
        public String Supplier {get;set;}
        public String Term {get;set;}
        public String List_Price {get;set;}        
        public String Month {get;set;}  
        public String Year {get;set;}
    }
}