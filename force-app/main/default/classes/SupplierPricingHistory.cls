/*************************************************************
* Class: SupplierPricingHistory
* Author: Soljit <VW>
* Date: 2019-05-24
* Description: apex class for handle supplier price history
**************************************************************/
public class SupplierPricingHistory{
    public static FINAL Integer RECORDS_PER_PAGE = 100;

	private final Account theAccount;
    public List<Price_List__c> allPrices {get; set;}
    public List<Price_List__c> pricesToShow {get; set;}

    // pagination variables
    public Integer counter = 0;                     //To track the number of records parsed
    public Integer limitSize {get; set;}            //Number of records to be displayed
    public Integer totalSize {get; set;}            //To Store the total number of records available
    public Integer totalPages {get; set;}

    public String summaryMessage {get; set;}

    // ========================================

    public SupplierPricingHistory(ApexPages.StandardController stdController) {
        List<String> fieldsToAdd = new List<String>{'Name'};
        stdController.addFields(fieldsToAdd);
        pricesToShow = new List<Price_List__c>();
        this.theAccount = (Account)stdController.getRecord();
        allPrices = [SELECT Id, Name, Product_Code__c, Type__c, Size__c, Term__c, List_Price__c,
                            Market__c, Currency_ISO_Code__c, Supplier__c,
                            Month__c, Effective_From__c, Effective_To__c, Month_Year__r.Name, Market__r.Name, 
                            Latest__c, Month_Year__c, Is_Valid__c 
                     FROM Price_List__c 
                     WHERE Supplier__c = :theAccount.Id 
                     ORDER BY Latest__c DESC, Is_Valid__c DESC, Month_Year__c ];
        
        if(allPrices.isEmpty())
        {
            String pageMessage = Label.PageMessage_No_Price_History;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
        }
    
        // Pagination/Navigation --->>>

        limitSize = RECORDS_PER_PAGE;
        totalSize = allPrices.size();

        totalPages = Integer.valueOf(totalSize/limitSize);
        if(Math.mod(totalSize,limitSize)!=0)
          totalPages+=1;

        //if there are more records than the maximum number of records to show on a page, we only display the first batch (max allowed/page)
        if((counter+limitSize) <= totalSize)
        {
            for(Integer i=0;i<limitSize;i++)
            {
                pricesToShow.add(allPrices.get(i));
            }
        }
        //else, all the records will be shown
        else
        {
            pricesToShow.addAll(allPrices);            
        }
        // Pagination/Navigation ---<<<

        // Showing ~totalSize results on ~totalPages page(s), ~limitSize records/page
        summaryMessage = Label.PageMessage_Price_History_Summary.replace('~totalSize', String.valueOf(totalSize));
        summaryMessage = summaryMessage.replace('~totalPages', String.valueOf(totalPages));
        summaryMessage = summaryMessage.replace('~limitSize', String.valueOf(limitSize));
    }
    // ----------------------------------------

    public String getRecordName() 
    {
        return (String)theAccount.get('Name');
    }

    // =======================================================================
    // ======================== Pagination/Navigation ========================
    // =======================================================================

    /*********************************************************************************
    Method Name    : beginning
    Description    : called when the user wants to navigate to the first page of records to show
    Return Type    : void
    Parameter      : none           
    *********************************************************************************/
    public void beginning(){
   
        pricesToShow.clear();
        counter=0;
        // if there are more records than the maximum number of records to show on a page, we only display the first batch (max allowed/page)
        if((counter + limitSize) <= totalSize)
        {       
            for(Integer i=0;i<limitSize;i++)
            {
                pricesToShow.add(allPrices.get(i));
            }           
        } 
    //else, all the records will be shown
        else
        {       
            for(Integer i=0;i<totalSize;i++)
            {
                pricesToShow.add(allPrices.get(i));
            }               
        }
       
    }
   
    /*********************************************************************************
    Method Name    : next
    Description    : called when the user wants to navigate to the next page of records to show
    Return Type    : void
    Parameter      : none           
    *********************************************************************************/
    public void next(){
   
        pricesToShow.clear();
        counter=counter+limitSize;
       
        // if there are more records than the maximum number of records to show on a page, we only display the first batch (max allowed/page)
        if((counter+limitSize) <= totalSize)
        {
            //for(Integer i=counter-1;i<(counter+limitSize);i++){
            for(Integer i=counter;i<(counter+limitSize);i++)
            {
                pricesToShow.add(allPrices.get(i));
            }
        } 
        //else, all the records will be shown
        else
        {
            for(Integer i=counter;i<totalSize;i++)
            {
                pricesToShow.add(allPrices.get(i));
            }
        }
    }
   
    /*********************************************************************************
    Method Name    : previous
    Description    : called when the user wants to navigate to the previous page of records to show
    Return Type    : void
    Parameter      : none           
    *********************************************************************************/
    public void previous(){
   
        pricesToShow.clear();

        counter=counter-limitSize;       
       
        for(Integer i=counter;i<(counter+limitSize); i++)
        {
            pricesToShow.add(allPrices.get(i));
        }
    }

    /*********************************************************************************
    Method Name    : last
    Description    : called when the user wants to navigate to the last page of records to show
    Return Type    : void
    Parameter      : none           
    *********************************************************************************/
    public void last (){
   
        pricesToShow.clear();
       
        if(math.mod(totalSize , limitSize) == 0)
        {
            counter = limitSize * ((totalSize/limitSize)-1);
        } 
        else if (math.mod(totalSize , limitSize) != 0)
        {
            counter = limitSize * ((totalSize/limitSize));
        }
         // all the records in the previous batch will be added to the list of records to show
        //for(Integer i=counter-1;i<totalSize;i++)
        for(Integer i=counter;i<totalSize;i++)
        {
                pricesToShow.add(allPrices.get(i));
        }
        /*for(Integer i=counter-1;i<totalSize-1;i++)
        {
                pricesToShow.add(allPrices.get(i));
        }*/
       
    }
    
    /*********************************************************************************
    Method Name    : getDisableNext
    Description    : used to enable/disable the button "Next"
    Return Type    : Boolean: TRUE if the button stays enabled, otherwise FALSE 
    Parameter      : none           
    *********************************************************************************/
    public Boolean getDisableNext()
    {   
        //if we have reached the last page of records to show, the button "Next" will be disabled
        if((counter + limitSize) >= totalSize )
            return true ;
        // else, it will stay enabled
        else
            return false ;
    }
   
    /*********************************************************************************
    Method Name    : getDisablePrevious
    Description    : used to enable/disable the button "Previous"
    Return Type    : Boolean: TRUE if the button stays enabled, otherwise FALSE 
    Parameter      : none           
    *********************************************************************************/
    public Boolean getDisablePrevious()
    {   
        //if we are on the first page of records to show, the button "Previous" will be disabled
        if(counter == 0)
            return true ;
        // else, it will stay enabled
        else
            return false ;
    } 

    /*********************************************************************************
    Method Name    : getRenderNavigation
    Description    : used to enable/disable the navigation buttons section
    Return Type    : Boolean: TRUE if the section stays enabled, otherwise FALSE 
    Parameter      : none           
    *********************************************************************************/
    public Boolean getRenderNavigation()
    {   
        //if we have less records than the max number of records to display on the page, navigation won't be displayed
        if(limitSize < totalSize)
            return true ;
        else
            return false ;
    }
}