/**************************************************
* Class: RenewalOpportunityBatch_SchedulableTest
* Author: Soljit <VW>
* Date: 2019-10-09
* Description: test class for RenewalOpportunityBatch_Schedulable
****************************************************/
@isTest
public class RenewalOpportunityBatch_SchedulableTest {
    
	@isTest 
	static void test_method_one() {
		Test.startTest();
        RenewalOppOwner__c renewalCustom = new RenewalOppOwner__c();
        renewalCustom.Second_Warning__c = 60;
        renewalCustom.Third_Warning__c =90;
        renewalCustom.First_Warning__c =30;
        renewalCustom.OwnerId__c = '0050q000001emm7AAA';
        insert renewalCustom;
        
		RenewalOpportunityBatch_Schedulable sc = new RenewalOpportunityBatch_Schedulable();
		String schTime = '0 0 23 * * ?';
		System.schedule('My night batch', schTime, sc);
		Test.stopTest();
	} 

}