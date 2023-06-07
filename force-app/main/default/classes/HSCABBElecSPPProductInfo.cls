public class HSCABBElecSPPProductInfo {
    
    public List<SBQQ__QuoteLine__c> quoteLineItemList {get; private set;}
    public List<SBQQ__Quote__c> quoteList {get; private set;}
    public SBQQ__QuoteLine__c listunitprice {get; private set;}
    public Decimal Subscriptionterm{get; set;}
    public Decimal amount1{get; set;}
    public Decimal amount2{get; set;}
    public Decimal amount3{get; set;}
    public Decimal amount4{get; set;}
    public Decimal amount5{get; set;}
    public Decimal amount6{get; set;}
    public SBQQ__Quote__c quoteList1 {get; private set;}
    public String flowdate{get; set;}
    public String annualVolume{get; set;}
    public Decimal amount{get; set;}
    public Decimal adminfee{get; set;}
    public boolean checkCon{get; set;}
    public SBQQ__QuoteLine__c quoteLineItemList2 {get; private set;}
    public SBQQ__QuoteLine__c quoteLineItemList3 {get; private set;}
    public SBQQ__QuoteLine__c quoteLineItemList4 {get; private set;}
    public SBQQ__QuoteLine__c quoteLineItemList5 {get; private set;}
    protected Id quoteId;
    
  
    public HSCABBElecSPPProductInfo() {
        quoteLineItemList = new List<SBQQ__QuoteLine__c>();
        quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        checkCon = false;
    }
   
    public PageReference init() {
        quoteLineItemList =[Select Id, Site__r.Name, Annual_Volume__c,Site_Address__c,SBQQ__ProductFamily__c ,SBQQ__Product__r.Is_Fixed__c,SBQQ__Product__c,SBQQ__Number__c 
                            From SBQQ__QuoteLine__c Where SBQQ__Quote__c =:quoteId OR SBQQ__Quote__r.SBQQ__OriginalQuote__c =:quoteId order by SBQQ__Number__c ASC];
        if(quoteLineItemList.size()==0){
            quoteLineItemList.add(new SBQQ__QuoteLine__c());// to show empty on pdf row .
        }
        return null;
    }
  
    public void chooseplan() {
        
        for(SBQQ__QuoteLine__c quotelineref : [Select ID, SBQQ__ListPrice__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c =:quoteId]){
            if(quotelineref.Id != null){
                quoteLineItemList.add(quotelineref);     
            }
        }
        if(quoteLineItemList.size()!=0){
            for(SBQQ__QuoteLine__c quoteLineObj :[Select ID, SBQQ__ListPrice__c, SBQQ__Quote__r.Selling_Price__c, Annual_Volume__c 
                               From SBQQ__QuoteLine__c Where id IN :quoteLineItemList and ( SBQQ__Quote__c =:quoteId OR SBQQ__Quote__r.SBQQ__OriginalQuote__c =:quoteId) limit 1] ){
                listunitprice = quoteLineObj;
            }
        }
        system.debug('listunitprice'+listunitprice);
        for(SBQQ__Quote__c quoteObj :[Select Id, SBQQ__Opportunity2__r.Flow_Date__c,Flow_Date_CPQ_Template__c,SBQQ__NetAmount__c ,SBQQ__SubscriptionTerm__c,Start_Date_CpqTemplate__c,Administration_Fee__c 
                                      From SBQQ__Quote__c Where id =:quoteId]){
                                          //flowdate = String.valueof(quoteObj.SBQQ__Opportunity2__r.Flow_Date__c.format('mm/dd/yyyy')); 
                                          flowdate=quoteObj.Flow_Date_CPQ_Template__c; 
                                          adminfee=quoteObj.Administration_Fee__c;
                                          annualVolume = (listunitprice !=null)?listunitprice.Annual_Volume__c:'';
                                          
                                          if(quoteObj.SBQQ__SubscriptionTerm__c == 12){
                                              amount1 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              checkCon =true;
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c == 24){
                                              amount2 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0; 
                                              checkCon =true;
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c == 36){
                                              amount3 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              checkCon =true;
                                              system.debug('amount3'  +amount3);
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c == 48){
                                              amount4 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              checkCon =true;
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c == 60){
                                              amount5 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              checkCon =true;
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c > 60){
                                              // Subscriptionterm = quoteObj.SBQQ__SubscriptionTerm__c/12;
                                              amount6 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              checkCon =true;
                                              // system.debug('Subscriptionterm' +Subscriptionterm);
                                              
                                          }
                                      } 
    }
    
}