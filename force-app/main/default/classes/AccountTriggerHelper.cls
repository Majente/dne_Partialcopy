/***************************************************************************************
@Name   		: AccountTriggerHelper
@Date   		: Feb 2019
@Author 		: Soljit VW
@Description    : AccountTriggerHelper for AccountTrigger
***************************************************************************************/
public class AccountTriggerHelper 
{
    
    // set to TRUE if some actions in the trigger must not execute
    public static Boolean bypassTrigger = false;
    
    private static Boolean Primary = true;
    private static string Stage = 'Qualification';
    private static Date closedate = Date.today();
    private static String RecordTypeName = 'Account';
    
     /*********************************************************
    @Name 			: getPersonRecordTypeId
    @Parameters 	: String
    @Reutrn type 	: String
    @Description 	: This method to Fetch recordtypeid from Sbobject Account.
	********************************************************/
    public static String getPersonRecordTypeId(String rtName){
        /*For(RecordType rt :[Select id from RecordType where sObjectType = 'Account' and name =:rtName ]){
            
            if(rt != null){
                return rt.id;
            }
        }
        return null; */
        Id recTypeId = null;
        try
        {
            recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();
        }
        catch(Exception e)
        {
            System.debug('ERROR: Record Type ' + rtName + ' for Account doesn\'t exist');
        }

        return recTypeId;
    }

	/*********************************************************
    @Name 			: createOpportunity
    @Parameters 	: String:oppName,supplier,accountId,Date:closeDate,
    @Reutrn type 	: Id
    @Description 	: create opportubity
	********************************************************/

    Public static Id createOpportunity(String oppName,String accountId,Date closeDate,String stage,String supplier){
        Opportunity opp = new Opportunity();
        opp.Name = oppName;
        opp.CloseDate = closeDate;
        opp.AccountId = accountId;
        opp.StageName = stage;
        opp.Supplier__c = supplier;
        insert opp;
        return opp.id;
    }
    /*********************************************************
    @Name 			: createRecord
    @Parameters 	: List<Account>
    @Reutrn type 	: void
    @Description 	: Create quote and opportunity record when account is convert lead
	********************************************************/
    public static void createRecord(List<Account> account){
        List<Account> accountList = new List<Account>();
       for (Account acc :account ){
           if(acc.Account_Converted__c == true && acc.RecordTypeId ==getPersonRecordTypeId(RecordTypeName)){
                    accountList.add(acc);
                }
        }
        if(accountList!=null && accountList.size()>0){
            For(Account acc : accountList){
                Id oppId =createOpportunity(acc.Name+date.today().format(), acc.Id,closedate, Stage,null); 
                /*if(oppId!=null){
                    
                createQuote(acc.Id,oppId,Primary);  
                }*/
            }
        }
    }
    
    /*********************************************************
    @Name 			: getStandardPB
    @Parameters 	: 
    @Reutrn type 	: string
    @Description 	: Fetch PriceBook
	********************************************************/
    /*public static string getStandardPB(){
        For(Pricebook2 pb :[Select id, name 
                            From Pricebook2 Where isStandard = true]){
            if(pb!=null){
                return pb.id;
            }
        }
        return null;
    }*/
    
     /*********************************************************
    @Name 			: createQuote
    @Parameters 	: String:accountId,oppId, Boolean:primary
    @Reutrn type 	: Id
    @Description 	: Create Quote
	********************************************************/
    /*Public static Id createQuote(String accountId,String oppId,Boolean primary){
        SBQQ__Quote__c quoteCPQ = new SBQQ__Quote__c();
        Account acc = [Select id,BillingCity,BillingStreet,BillingCountry,BillingState,BillingPostalCode,ShippingStreet,
                       ShippingCity,ShippingCountry,ShippingState,ShippingPostalCode 
                       From Account Where Id =: accountId];
        quoteCPQ.SBQQ__Primary__c = primary;
        quoteCPQ.SBQQ__Account__c = accountId;
        quoteCPQ.SBQQ__Opportunity2__c =oppId;
        quoteCPQ.SBQQ__BillingStreet__c = acc.BillingStreet;
        quoteCPQ.SBQQ__BillingCity__c = acc.BillingCity;
        quoteCPQ.SBQQ__BillingCountry__c = acc.BillingCountry;
        quoteCPQ.SBQQ__BillingState__c = acc.BillingState;
        quoteCPQ.SBQQ__BillingPostalCode__c = acc.BillingPostalCode;
        quoteCPQ.SBQQ__ShippingStreet__c = acc.ShippingStreet;
        quoteCPQ.SBQQ__ShippingCity__c = acc.ShippingCity;
        quoteCPQ.SBQQ__ShippingCountry__c = acc.ShippingCountry;
        quoteCPQ.SBQQ__ShippingState__c = acc.ShippingState;
        quoteCPQ.SBQQ__ShippingPostalCode__c = acc.ShippingPostalCode;
        quoteCPQ.SBQQ__StartDate__c = closeDate;
        quoteCPQ.SBQQ__PricebookId__c = getStandardPB(); 
        quoteCPQ.SBQQ__GenerateContractedPrice__c = 'price';
        quoteCPQ.SBQQ__SalesRep__c = UserInfo.getUserId();
        Insert quoteCPQ;
        
        Opportunity opp =[Select id 
                          From opportunity Where id =:oppId];
        opp.Pricebook2Id = quoteCPQ.SBQQ__PricebookId__c;
        update opp;
        return quoteCPQ.ID;
    }*/
    
    
    /*********************************************************
    @Name 			: onStatusChange
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: on status change
	********************************************************/   
    public static void onStatusChange()
    {
        Id client_RTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();

        List<Account> accountList = Trigger.new;
        
        for(Account acc : accountList)
        {
            if(acc.RecordTypeId == client_RTId)
            {
                if(Trigger.isInsert)
                {
                    if(!bypassTrigger)
                    {
                        acc.Last_Status_Change__c = Datetime.now();
                    }
                }

                if(Trigger.isUpdate)
                {
                    Account oldVersion = (Account)Trigger.oldMap.get(acc.Id);
                    if(oldVersion.Status__c != acc.Status__c)
                    {
                        acc.Last_Status_Change__c = Datetime.now();
                    }                
                }
            }                
        }            
    }
}