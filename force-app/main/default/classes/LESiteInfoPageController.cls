/**************************************************
* Class: LESiteInfoPageController
* Author: Soljit <VW>
* Date: 2019-06-26
****************************************************/
public class LESiteInfoPageController {
    
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
    public Decimal amount1Cents{get; set;}
    public Decimal amount2Cents{get; set;}
    public Decimal amount3Cents{get; set;}
    public Decimal amount4Cents{get; set;}
    public Decimal amount5Cents{get; set;}
    public Decimal amount6Cents{get; set;}
    
    public String quoteLineItemAnnualVolume2{get; set;}
    public String quoteLineItemAnnualVolume3{get; set;}
    public String quoteLineItemAnnualVolume4{get; set;}
    public String quoteLineItemAnnualVolume5{get; set;}
    public SBQQ__Quote__c quoteList1 {get; private set;}
    public String flowdate{get; set;}
    public String annualVolume{get; set;}
    public Decimal amount{get; set;}
    public Decimal adminfee{get; set;}
    public String adminfeeCents{get; set;}
    public Decimal sellingPrice{get; set;}
    public String sellingPriceCents{get; set;}
    public boolean checkCon{get; set;}
    public SBQQ__QuoteLine__c quoteLineItemList2 {get; private set;}
    public SBQQ__QuoteLine__c quoteLineItemList3 {get; private set;}
    public SBQQ__QuoteLine__c quoteLineItemList4 {get; private set;}
    public SBQQ__QuoteLine__c quoteLineItemList5 {get; private set;}
    protected Id quoteId;
    public system.url baseUrl{get;set;}
    
    /*********************************************************
@Name           : LESiteInfoPageController
@Parameters     : 
@Reutrn type    : void
@Description    : Constructor
********************************************************/
    public LESiteInfoPageController() {
        quoteLineItemList = new List<SBQQ__QuoteLine__c>();
        quoteId = (Id)ApexPages.currentPage().getParameters().get('qid');
        checkCon = false;
        baseUrl = System.Url.getOrgDomainUrl();
    }
    /*********************************************************
@Name           : get Sites Count and Volume
@Parameters     : 
@Reutrn type    : PageReference
@Description    : get quote line itim
********************************************************/
    public Integer NoOfGasSites{get; set;}
    public Integer NoOfElectricitySites{get; set;}
    
    public Decimal AggregatedGasVolume{get; set;}
    public Decimal AggregatedElectricityVolume{get; set;}
    
    public PageReference siteCountVolume() {
        NoOfGasSites = 0;
        NoOfElectricitySites = 0;
        AggregatedGasVolume = 0;
        AggregatedElectricityVolume = 0;
        
        List<SBQQ__QuoteLine__c> lstQuoteLineItemSiteList =[Select Id, Site__r.Name, Site__r.Volume__c, Annual_Volume__c,Site_Address__c,SBQQ__ProductFamily__c ,SBQQ__Product__r.Is_Fixed__c,SBQQ__Product__c,SBQQ__Number__c 
                            From SBQQ__QuoteLine__c Where (Site__c !=null) AND (SBQQ__Quote__c =:quoteId OR SBQQ__Quote__r.SBQQ__OriginalQuote__c =:quoteId) order by SBQQ__Number__c ASC];
        System.debug('lstQuoteLineItemSiteList:'+lstQuoteLineItemSiteList);
        System.debug('lstQuoteLineItemSiteList.size():'+lstQuoteLineItemSiteList.size());
        if(lstQuoteLineItemSiteList.size()!=0){
            
            
            for(SBQQ__QuoteLine__c quoteLineObj :lstQuoteLineItemSiteList){
                if(quoteLineObj.SBQQ__ProductFamily__c  == 'Gas'){
                    NoOfGasSites = NoOfGasSites+1;
                    AggregatedGasVolume = AggregatedGasVolume + quoteLineObj.Site__r.Volume__c;
                }else if(quoteLineObj.SBQQ__ProductFamily__c  == 'Electricity'){
                    NoOfElectricitySites = NoOfElectricitySites+1;
                    AggregatedElectricityVolume = AggregatedElectricityVolume + quoteLineObj.Site__r.Volume__c;
                }
            }
            
        }
        return null;
    }
    /*********************************************************
@Name           : init
@Parameters     : 
@Reutrn type    : PageReference
@Description    : get quote line itom
********************************************************/
    public PageReference init() {
        quoteLineItemList =[Select Id, Site__r.Name, Annual_Volume__c,Site_Address__c,SBQQ__ProductFamily__c ,SBQQ__Product__r.Is_Fixed__c,SBQQ__Product__c,SBQQ__Number__c 
                            From SBQQ__QuoteLine__c Where (Site__c !=null) AND (SBQQ__Quote__c =:quoteId OR SBQQ__Quote__r.SBQQ__OriginalQuote__c =:quoteId) order by SBQQ__Number__c ASC];
        if(quoteLineItemList.size()==0){
            quoteLineItemList.add(new SBQQ__QuoteLine__c());// to show empty on pdf row .
        }
        return null;
    }
    /*********************************************************
@Name           : chooseplan
@Parameters     : 
@Reutrn type    : void
@Description    : plan choose based terms
********************************************************/
    public void chooseplan() {
        
        for(SBQQ__QuoteLine__c quotelineref : [Select ID, Site_Name__c, Site_Address__c, Annual_Volume__c, SBQQ__ListPrice__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c =:quoteId]){
            if(quotelineref.Id != null){
                quoteLineItemList.add(quotelineref);     
            }
        }
        Decimal annualVolumeInt = 0;
        String unitOfMeasure = '';
        if(quoteLineItemList.size()!=0){
            Integer loopCount = 1; 
            for(SBQQ__QuoteLine__c quoteLineObj :[Select ID,Site__r.Volume__c, Site__r.Unit_of_Measure__c, SBQQ__ListPrice__c, SBQQ__Quote__r.Selling_Price__c, SBQQ__Quote__r.SPCents__c , Annual_Volume__c 
                               From SBQQ__QuoteLine__c Where id IN :quoteLineItemList and ( SBQQ__Quote__c =:quoteId OR SBQQ__Quote__r.SBQQ__OriginalQuote__c =:quoteId)] ){
                if(loopCount == 1){
                    listunitprice = quoteLineObj;
                    ++loopCount;
                }
                annualVolumeInt = annualVolumeInt + quoteLineObj.Site__r.Volume__c;
                unitOfMeasure = quoteLineObj.Site__r.Unit_of_Measure__c;
            }
        }
        annualVolume = annualVolumeInt+' '+unitOfMeasure;
        system.debug('listunitprice'+listunitprice);
        for(SBQQ__Quote__c quoteObj :[Select Id, Selling_Price__c, SPCents__c, SBQQ__Opportunity2__r.Flow_Date__c,Flow_Date_CPQ_Template__c,SBQQ__NetAmount__c ,SBQQ__SubscriptionTerm__c,Start_Date_CpqTemplate__c,Administration_Fee__c ,AdministrationFeeCents__c
                                      From SBQQ__Quote__c Where id =:quoteId]){
                                          //flowdate = String.valueof(quoteObj.SBQQ__Opportunity2__r.Flow_Date__c.format('mm/dd/yyyy')); 
                                          flowdate=quoteObj.Flow_Date_CPQ_Template__c; 
                                          adminfee=quoteObj.Administration_Fee__c;
                                          adminfeeCents=quoteObj.AdministrationFeeCents__c;
                                          sellingPrice = quoteObj.Selling_Price__c;
                                          sellingPriceCents = quoteObj.SPCents__c;
                                          //annualVolume = (listunitprice !=null)?listunitprice.Annual_Volume__c:'';
                                          
                                          Subscriptionterm = quoteObj.SBQQ__SubscriptionTerm__c;
                                          
                                          if(quoteObj.SBQQ__SubscriptionTerm__c == 12){
                                              amount1 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              amount1Cents = (listunitprice !=null)?decimal.valueOf(listunitprice.SBQQ__Quote__r.SPCents__c):0;
                                              checkCon =true;
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c == 24){
                                              amount2 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0; 
                                              amount2Cents = (listunitprice !=null)?decimal.valueOf(listunitprice.SBQQ__Quote__r.SPCents__c):0; 
                                              checkCon =true;
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c == 36){
                                              amount3 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              amount3Cents = (listunitprice !=null)?decimal.valueOf(listunitprice.SBQQ__Quote__r.SPCents__c):0;
                                              checkCon =true;
                                              system.debug('amount3'  +amount3);
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c == 48){
                                              amount4 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              amount4Cents = (listunitprice !=null)?decimal.valueOf(listunitprice.SBQQ__Quote__r.SPCents__c):0;
                                              checkCon =true;
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c == 60){
                                              amount5 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              amount5Cents = (listunitprice !=null)?decimal.valueOf(listunitprice.SBQQ__Quote__r.SPCents__c):0;
                                              checkCon =true;
                                          }
                                          else if(quoteObj.SBQQ__SubscriptionTerm__c > 60){
                                              // Subscriptionterm = quoteObj.SBQQ__SubscriptionTerm__c/12;
                                              amount6 = (listunitprice !=null)?listunitprice.SBQQ__Quote__r.Selling_Price__c:0;
                                              amount6Cents = (listunitprice !=null)?decimal.valueOf(listunitprice.SBQQ__Quote__r.SPCents__c):0;
                                              checkCon =true;
                                              // system.debug('Subscriptionterm' +Subscriptionterm);
                                              
                                          }
                                      } 
    }
    /*********************************************************
@Name           : chooseplan2
@Parameters     : 
@Reutrn type    : void
@Description    : plan choose based on product family
********************************************************/
    public void chooseplan2() {
        Decimal AnnualVolume2 = 0;
        Decimal AnnualVolume3 = 0;
        Decimal AnnualVolume4 = 0;
        Decimal AnnualVolume5 = 0;
        Integer count2 = 0;
        Integer count3 = 0;
        Integer count4 = 0;
        Integer count5 = 0;
        quoteLineItemList =[select Id, SBQQ__ListPrice__c,Site__r.Name, Site__r.Volume__c,Client_Initials__c, Site__r.Unit_of_Measure__c, Annual_Volume__c,Site_Address__c,SBQQ__ProductFamily__c ,SBQQ__Product__r.Is_Fixed__c,SBQQ__Product__c,SBQQ__Number__c,SBQQ__Quote__r.SBQQ__SubscriptionTerm__c,SBQQ__Quote__r.Start_Date_CpqTemplate__c, SBQQ__Quote__r.Administration_Fee__c,SBQQ__Quote__r.owner.name, SBQQ__Quote__r.Selling_Price__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quoteId OR SBQQ__Quote__r.SBQQ__OriginalQuote__c =:quoteId order by SBQQ__Number__c ASC];
        
        for(SBQQ__QuoteLine__c quoteLineObj :quoteLineItemList ){
            if(quoteLineObj.SBQQ__ProductFamily__c  == 'Gas' && quoteLineObj.SBQQ__Product__r.Is_Fixed__c == true ){
                quoteLineItemList2 = quoteLineObj;
                if(quoteLineObj.Site__r.Volume__c != null){
                    AnnualVolume2 += quoteLineObj.Site__r.Volume__c;                    
                }
                count2++;
            }
            else if(quoteLineObj.SBQQ__ProductFamily__c  == 'Electricity' && quoteLineObj.SBQQ__Product__r.Is_Fixed__c == true ){
                quoteLineItemList3 = quoteLineObj;
                if(quoteLineObj.Site__r.Volume__c != null){
                    AnnualVolume3 += quoteLineObj.Site__r.Volume__c;
                }
                count3++;
            }
            else if(quoteLineObj.SBQQ__ProductFamily__c  == 'Gas' && quoteLineObj.SBQQ__Product__r.Is_Fixed__c == false ){
                quoteLineItemList4 = quoteLineObj;
                if(quoteLineObj.Site__r.Volume__c != null){
                    AnnualVolume4 += quoteLineObj.Site__r.Volume__c;
                }
                count4++;
            }
            else if(quoteLineObj.SBQQ__ProductFamily__c  == 'Electricity' && quoteLineObj.SBQQ__Product__r.Is_Fixed__c == false ){
                quoteLineItemList5 = quoteLineObj;
                if(quoteLineObj.Site__r.Volume__c != null){
                    AnnualVolume5 += quoteLineObj.Site__r.Volume__c;
                }
                count5++;
            }
        }
        
        if(quoteLineItemList2 != null && AnnualVolume2 != 0){
            quoteLineItemAnnualVolume2 = AnnualVolume2 + ' ' + (quoteLineItemList2.Site__r.Unit_of_Measure__c != null ? quoteLineItemList2.Site__r.Unit_of_Measure__c : '');
            System.debug('quoteLineItemAnnualVolume2 ::: ' + quoteLineItemAnnualVolume2);            
        }
        if(quoteLineItemList3 != null && AnnualVolume3 != 0){
            quoteLineItemAnnualVolume3 = AnnualVolume3 + ' ' + (quoteLineItemList3.Site__r.Unit_of_Measure__c != null ? quoteLineItemList3.Site__r.Unit_of_Measure__c : '');
            System.debug('quoteLineItemAnnualVolume3 ::: ' + quoteLineItemAnnualVolume3);            
        }
        if(quoteLineItemList4 != null && AnnualVolume4 != 0){
            quoteLineItemAnnualVolume4 = AnnualVolume4 + ' ' + (quoteLineItemList4.Site__r.Unit_of_Measure__c != null ? quoteLineItemList4.Site__r.Unit_of_Measure__c : '');
            System.debug('quoteLineItemAnnualVolume4 ::: ' + quoteLineItemAnnualVolume4);            
        }
        if(quoteLineItemList5 != null && AnnualVolume5 != 0){
            quoteLineItemAnnualVolume5 = AnnualVolume5 + ' ' + (quoteLineItemList5.Site__r.Unit_of_Measure__c != null ? quoteLineItemList5.Site__r.Unit_of_Measure__c : '');
            System.debug('quoteLineItemAnnualVolume5 ::: ' + quoteLineItemAnnualVolume5);            
        }
    }
    
}