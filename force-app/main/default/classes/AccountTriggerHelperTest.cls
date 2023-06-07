/**************************************************

* Class: AccountTriggerHelperTest
* Author: Soljit <VW>
* Date: 2019-12-14
* Description: Test class for AccountTriggerHelper

****************************************************/
@IsTest
public class AccountTriggerHelperTest {
    
    /*********************************************************
    @Name 			: leadConvertTest
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: This method is used to cover code of the 
                       AccountTriggerHelper.
	********************************************************/

    @IsTest
    private static void leadConvertTest() {

        // create a Lead
        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry',Number_of_file__c=1,Email = 'mylead@test.com');
       
        insert lead;                
        System.debug('lead ::: ' + lead);
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(True);
        lc.setConvertedStatus('Converted');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        Account acc = [Select id, Status__c from Account where Id = : lcr.getAccountId()];
        System.debug('acc ::: ' + acc);
        acc.Status__c = 'Not interested';
        Update acc;
    }
    
}