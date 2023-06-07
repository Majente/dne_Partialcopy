/**************************************************
* Class: CreateQuoteLineUtility
* Author: Soljit <VW>
* Description : utility class
****************************************************/
public class CreateQuoteLineUtility{
    // Get standard price book
     public static string getStandardPB(){
        For(Pricebook2 pb :[Select id, name 
                            From Pricebook2 Where isStandard = true]){
            if(pb!=null){
                return pb.id;
            }
        }
        return null;
    }    
    /*********************************************************
    @Name 			: createQuote
    @Parameters 	: Id:oppId
    @Reutrn type 	: SBQQ__Quote__c
    @Description 	: Create Quote Record
	********************************************************/
    public static SBQQ__Quote__c createQuote(String oppId){
        List<Id> OpportunityList = New List<Id>{oppId};
        List<SBQQ__Quote__c> quoteList = createQuoteFromOppSite(OpportunityList);
        System.debug('Before insert quoteList::'+quoteList);
        
        try{
            if(quoteList.size()>0){
          return quoteList[0];
            }
        }catch(Exception ex){
        System.debug(ex.getMessage());
    }
    
    return null;
    
}
    
    /*********************************************************
    @Name 			: createQLI
    @Parameters 	: ID : productId , ID:quotId,List:siteList,Decimal:listPrice,Decimal:term,Decimal:margin
    @Reutrn type 	: List<SBQQ__QuoteLine__c>
    @Description 	: Create QuoteLineItem  
	********************************************************/
    public static List<SBQQ__QuoteLine__c> createQLI(Id productId,Id quotId,List<Site__c> siteList ,Decimal listPrice,Decimal term,Decimal margin){
       Decimal subTerm;
        if(term !=null){
            subTerm= term/12;
        }
        else{
            subTerm=1;
        }
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        For(Site__c site :siteList ){
        SBQQ__QuoteLine__c   quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quotId;
        quoteLine.Site__c = site.id;
        quoteLine.SBQQ__Product__c = productId;
        quoteLine.SBQQ__ListPrice__c = margin;
        quoteLine.SBQQ__Quantity__c = (site.Volume__c * subTerm);
        quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine.SBQQ__DefaultSubscriptionTerm__c = term;
        quoteLine.Supplier_Price__c = listPrice;
        quoteLine.Selling_Price__c = ((listPrice * site.Volume__c *subTerm )) ;
        quoteLineList.add(quoteLine); 
        }
    if(quoteLineList.size()>0){
            INSERT quoteLineList;
    }
    return quoteLineList;
}
    /*********************************************************
    @Name 			: createQLI
    @Parameters 	: ID : productId , ID:quotId,List:siteList,Decimal:listprice,Decimal:term,Decimal:margin,Decimal:supplierPrice
    @Reutrn type 	: List<SBQQ__QuoteLine__c> 
    @Description 	: create QuoteLineItem for manual opportunity
	********************************************************/
    public static List<SBQQ__QuoteLine__c> createQLI(Id productId,Id quotId,List<Site__c> siteList ,Decimal listPrice,Decimal term,Decimal margin,Decimal supplierPrice){
       Decimal subTerm = 0;
        if(term !=null){
            subTerm= term/12;
        }
        else{
            subTerm=1;
        }
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        For(Site__c site :siteList ){
        SBQQ__QuoteLine__c   quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quotId;
        quoteLine.Site__c = site.id;
        quoteLine.SBQQ__Product__c = productId;
        quoteLine.SBQQ__ListPrice__c = margin;
        quoteLine.SBQQ__Quantity__c = (site.Volume__c * subTerm);
        quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine.SBQQ__DefaultSubscriptionTerm__c = term;
        quoteLine.Supplier_Price__c = supplierPrice;
        quoteLine.Selling_Price__c = (((supplierPrice + margin) * site.Volume__c *subTerm )) ;
        quoteLineList.add(quoteLine); 
        }
    if(quoteLineList.size()>0){
            INSERT quoteLineList;
    }
    return quoteLineList;
}
    /*********************************************************
    @Name 			: createQuoteFromOppSite
    @Parameters 	: Set Of Opportunity Ids
    @Reutrn type 	: List of newly inserted quote
    @Description 	: Create quote records and Insert
	********************************************************/
    //
    public static List<SBQQ__Quote__c> createQuoteFromOppSite(List<ID> oppList){
        String stdPB = getStandardPB();
       List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        
        For(Opportunity opp :[Select id,margin__c,Account.Primary_Contact__c,Selling_Price__c,Supplier_Price__c, 
                              Subscription_Term__c,Admin_Fee__c,Supplier__c,CloseDate,Flow_Date__c 
                              from Opportunity where id IN:oppList]){
                                 SBQQ__Quote__c quoteObj = New SBQQ__Quote__c();
                                  if(opp.Admin_Fee__c !=null){
                                     quoteObj.Administration_Fee__c = opp.Admin_Fee__c;
                                   }
                                  if(opp.Supplier_Price__c !=null){
                                     quoteObj.Supplier_Price__c = opp.Supplier_Price__c;
                                  }
                                  if(opp.Supplier__c !=null){
                                      quoteObj.Supplier__c = opp.Supplier__c;
                                  }
                                  if(opp.Selling_Price__c !=null){
                                       quoteObj.Selling_Price__c = opp.Selling_Price__c;
                                  
                                  }
                                  quoteObj.SBQQ__Opportunity2__c = opp.Id;
                                  quoteObj.SBQQ__Primary__c = true;
                                  quoteObj.margin__c = opp.margin__c;
                                  quoteObj.SBQQ__PricebookId__c = stdPB;
                                  quoteObj.Primary_Contact__c = opp.account.Primary_Contact__c;
                                  quoteObj.Billing_Contact__c = opp.account.Primary_Contact__c;
                                  quoteObj.SBQQ__StartDate__c = opp.Flow_Date__c;
                                  if(opp.Subscription_Term__c > 0){
                                      quoteObj.SBQQ__SubscriptionTerm__c = opp.Subscription_Term__c;
                                  }else{
                                      quoteObj.SBQQ__SubscriptionTerm__c = 12;
                                  }
                                  quoteObj.SBQQ__ExpirationDate__c = opp.CloseDate;
                                  quoteList.add(quoteObj);
                              }
      try{
        	if(quoteList.Size() >0 ){
        		System.debug('New Quotes Inserting '+ quoteList);
        		Insert quoteList;
        	}
        	  System.debug(' After insert quoteList::'+quoteList);
       
        }Catch(Exception ex){
        	System.debug('Error While Inserting '+ ex.getMessage());
        }
        return quoteList;
        
    }
    /*********************************************************
    @Name 			: fetchQuoteId
    @Parameters 	: Set Of Opportunity Ids
    @Reutrn type 	: Map of Quote with Opportunity Id as Key
    @Description 	: Check if Quote not exist than insert
	********************************************************/
    public static Map<ID,SBQQ__Quote__c> fetchQuoteId(Set<ID> oppList){
       List<SBQQ__Quote__c> quotList = new List<SBQQ__Quote__c>();
       List<ID> newQuoteList = new List<ID>();
       Map<ID,SBQQ__Quote__c> oppQuoteMap = new Map<ID,SBQQ__Quote__c>();
       // Fetch all existing quotes for related opportunity
       For(SBQQ__Quote__c qt :[	Select id ,SBQQ__Opportunity2__c,Primary_Contact__c,Billing_Contact__c,SBQQ__SubscriptionTerm__c,SBQQ__StartDate__c
                                From SBQQ__Quote__c 
                                Where SBQQ__Opportunity2__c IN: oppList 
                                And SBQQ__Primary__c = true ] ){
                                	
                 if(!oppQuoteMap.containsKey(qt.SBQQ__Opportunity2__c)){
                       oppQuoteMap.Put(qt.SBQQ__Opportunity2__c, qt);
                 }
        }
        // Seprating opportunity Ids if corresponding Quote is not exist.
        For(ID oppID : oppList){
        	if(!oppQuoteMap.containsKey(oppID)){
        		newQuoteList.add(oppID);
        	}
        }
        // Create Quotes which are not exists
        if(newQuoteList.size()>0 ){ 
        	 quotList  = createQuoteFromOppSite(newQuoteList);
        	 for(SBQQ__Quote__c qt : quotList){
        	 	oppQuoteMap.Put(qt.SBQQ__Opportunity2__c, qt);
        	 }
        }
        return oppQuoteMap;
    }
    /*********************************************************
    @Name 			: getAllProducts
    @Parameters 	: None
    @Reutrn type 	: Map<String, Product2>
    @Description 	: Return all product with key String
	********************************************************/    
    public static Map<String, Product2> getAllProducts(Set<String> productFamily, Set<String> productPriceType, Set<String> productSize){
    	Map<String, Product2> productMap = new Map<String, Product2>();
    	String Key ;
    	for( Product2 product :[Select Id,Name,Size__c,ProductCode,Family,Price_Type__c                                        
                                From Product2  
                                Where Family IN :productFamily AND 
                                Price_Type__c IN :productPriceType 
                                AND Size__c IN :productSize]){                                    
               Key = product.Family + product.Price_Type__c + product.Size__c;
              productMap.put(Key,product);
        }
        return productMap;
    }
    
}