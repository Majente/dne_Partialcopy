/**************************************************
* Class: PricingGridController
* Author: Soljit <VW>
* Date: 2019-05-15
****************************************************/
public with sharing class PricingGridController {
    
    public static String tabId {get; set;}
    public static Boolean showSupplierList {get; set;}
    public List<SelectOption> supplierOptions {get; set;}
    public List<String> suppliers;
    public Boolean noSuppliersFound{
        get{
            return showSupplierList && (supplierOptions==null || supplierOptions.isEmpty());
        }
    }
	/*********************************************************
    @Name 			: getMonthsList
    @Parameters 	: 
    @Reutrn type 	: List<String>
    @Description 	: get month list
	********************************************************/
    @AuraEnabled
    public static List<String> getMonthsList(){
        List<String> monthList = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'};
            return monthList;
    }
    /*********************************************************
    @Name 			: getMarketsOption
    @Parameters 	: 
    @Reutrn type 	: List<Market__c>
    @Description 	: get market option
	********************************************************/
    @AuraEnabled
    public static List<Market__c> getMarketsOption(){
        List<Market__c> marketList = new List<Market__c>();
        for(Market__c market : [SELECT Id,Name FROM Market__c ]){
            marketList.add(market);
        }
        if(marketList.size()==0)
            return null;
        return marketList;
    }
    /*********************************************************
    @Name 			: getCommodityOptions
    @Parameters 	: 
    @Reutrn type 	: List<String>
    @Description 	: get commodity options
	********************************************************/
    @AuraEnabled
    public static List<String> getCommodityOptions(){
        List<String> commodityOptions = new List<String>();
        Schema.DescribeSObjectResult objSchema = Daily_Prices__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        
        if(commodityOptions==null || commodityOptions.isEmpty())
        {
            commodityOptions = new List<String>();
            Schema.DisplayType fielddataType = fieldMap.get('Commodity__c').getDescribe().getType();        
            if(fielddataType == Schema.DisplayType.Picklist)
            {
                List<Schema.Picklistentry> fld = fieldmap.get('Commodity__c').getDescribe().getpicklistValues();
                for(Integer i=0; i<fld.size(); i++)
                {
                    commodityOptions.add(fld[i].getvalue());
                }
            }
            
        }
        if(commodityOptions.size() == 0)
            return null;
        return commodityOptions;
    } 
    /*********************************************************
    @Name 			: getSizeOptions
    @Parameters 	: 
    @Reutrn type 	: List<String>
    @Description 	: get size option
	********************************************************/
    @AuraEnabled
    public static List<String> getSizeOptions(){
        List<String> sizeOptions = new List<String>();
        Schema.DescribeSObjectResult objSchema = Daily_Prices__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        if(sizeOptions==null || sizeOptions.isEmpty())
        {
            sizeOptions = new List<String>();        
            Schema.DisplayType fielddataType = fieldMap.get('Size__c').getDescribe().getType();        
            if(fielddataType == Schema.DisplayType.Picklist)
            {
                List<Schema.Picklistentry> fld = fieldmap.get('Size__c').getDescribe().getpicklistValues();
                for(Integer i=0; i<fld.size(); i++)
                {
                    sizeOptions.add(fld[i].getvalue());
                }
            }
        } 
        if(sizeOptions.size() == 0)
            return null;
        return sizeOptions;
    }
    /*********************************************************
    @Name 			: getAllOptions
    @Parameters 	: 
    @Reutrn type 	: Map<String, WrapClass>
    @Description 	: get all option
	********************************************************/
    @AuraEnabled
    public static Map<String, WrapClass> getAllOptions(){
        
        Map<String, WrapClass> response = new Map<String, WrapClass>() ;
        List<Market__c> marketList = new List<Market__c>();
        for(Market__c market : [SELECT Id,Name FROM Market__c]){
            marketList.add(market);
        }
        response.put('marketList', new WrapClass('sObject',null,marketList));
        
        List<String> commodityOptions = new List<String>();
        Schema.DescribeSObjectResult objSchema = Daily_Prices__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        
        if(commodityOptions==null || commodityOptions.isEmpty())
        {
            commodityOptions = new List<String>();
            Schema.DisplayType fielddataType = fieldMap.get('Commodity__c').getDescribe().getType();        
            if(fielddataType == Schema.DisplayType.Picklist)
            {
                List<Schema.Picklistentry> fld = fieldmap.get('Commodity__c').getDescribe().getpicklistValues();
                for(Integer i=0; i<fld.size(); i++)
                {
                    commodityOptions.add(fld[i].getvalue());
                }
            }
            
        }
        response.put('commodityList', new WrapClass('string',commodityOptions,null));
        
        List<String> sizeOptions = new List<String>();
        objSchema = Daily_Prices__c.sObjectType.getDescribe();
        fieldMap = objSchema.fields.getmap();
        if(sizeOptions==null || sizeOptions.isEmpty())
        {
            sizeOptions = new List<String>();        
            Schema.DisplayType fielddataType = fieldMap.get('Size__c').getDescribe().getType();        
            if(fielddataType == Schema.DisplayType.Picklist)
            {
                List<Schema.Picklistentry> fld = fieldmap.get('Size__c').getDescribe().getpicklistValues();
                for(Integer i=0; i<fld.size(); i++)
                {
                    sizeOptions.add(fld[i].getvalue());
                }
            }
        }
        
        response.put('sizeList', new WrapClass('string',sizeOptions,null));
        
        return response ;
        
    }
    
    /*********************************************************
    @Name 			: WrapClass
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: wrapper class
	********************************************************/
    public class WrapClass{
        @AuraEnabled public string dataType;
        @AuraEnabled public List<string> stringData;
        @AuraEnabled public List<sObject> sObjectData;
        
     /*********************************************************
    @Name 			: WrapClass
    @Parameters 	: string dataType,List<string> stringData,List<sObject> sObjectData
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
        public WrapClass(string dataType,List<string> stringData,List<sObject> sObjectData){  
            this.dataType=dataType;
            this.stringData=stringData;
            this.sObjectData=sObjectData;
        }
    }
    
    /*********************************************************
    @Name 			: getSupplierList
    @Parameters 	: String commodity, String market, String size
    @Reutrn type 	: Map<String,String>
    @Description 	: get supplier list
	********************************************************/
    @AuraEnabled
    public static Map<String,String> getSupplierList(String commodity, String market, String size,String type){
        System.debug('type::'+type);
        Map<String,string> supplierList = new Map<String,string>();
        For(Price_List__c pl :[SELECT Id,Supplier__r.Name,Supplier__c FROM Price_List__c where market__c =:market AND 
                               Name =:commodity  AND Latest__c = true and Type__c =:type And size__c =:size]){
                                   supplierList.put(pl.Supplier__c,pl.Supplier__r.Name);              
                               }
        showSupplierList = true;
        System.debug('supplierList::'+supplierList);
        return supplierList;    
    }
    
    /*********************************************************
    @Name 			: getTodayPbmMap
    @Parameters 	: String market,String commodity, String size, String tabId,String pricetype
    @Reutrn type 	: Map<id,List<Price_List__c>>
    @Description 	: get today price by month
	********************************************************/
    @AuraEnabled
    public static Map<id,List<Price_List__c>> getTodayPbmMap(String market,String commodity, String size, String tabId,String pricetype){
        Map<id,List<Price_List__c>> pbmMap = new Map<id,List<Price_List__c>>() ;
        pbmMap = PriceListUtility.getTodayPriceListNewUpdated(market,commodity,size,tabId,pricetype);
        System.debug('pbmMap::'+pbmMap);
        return pbmMap;
    }
}