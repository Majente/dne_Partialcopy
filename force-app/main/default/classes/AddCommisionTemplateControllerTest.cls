/**************************************************
* Class: AddCommisionTemplateControllerTest
* Author: Soljit <VW> 
* Date: 2019-09-23
* Description : test class for AddCommisionTemplateController
****************************************************/
@isTest
public class AddCommisionTemplateControllerTest 
{
	static FINAL String COMMISSION_RECEIVER_FIRST_NAME = 'Commission_';
	static FINAL String COMMISSION_RECEIVER_LAST_NAME = 'Receiver_';
	static FINAL Integer NB_OF_COMMISSION_LEVELS = 16;

	@testSetup
	static void createData()
	{}
	// ===========================================
	
	@isTest 
	static void test_method_one() 
	{
		Account dneAccount = new Account();
		dneAccount.Name = 'DNE';
		insert dneAccount;

		//Id commRec_RTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Commission_Receiver').getRecordTypeId();
		List<Contact> commissionReceiverList = new List<Contact>();

		for(Integer i=0; i<NB_OF_COMMISSION_LEVELS; i++)
		{
			Contact comm_rec = new Contact();
			//comm_rec.RecordTypeId = commRec_RTId;
			comm_rec.AccountId = dneAccount.Id;
			comm_rec.FirstName = COMMISSION_RECEIVER_FIRST_NAME;
			comm_rec.LastName = COMMISSION_RECEIVER_LAST_NAME + i;
			commissionReceiverList.add(comm_rec);
		}
		insert commissionReceiverList;

		Contact opener1 = new Contact();
		//opener1.RecordTypeId = commRec_RTId;
		opener1.AccountId = dneAccount.Id;
		opener1.FirstName = COMMISSION_RECEIVER_FIRST_NAME;
		opener1.LastName = 'Opener_1';
		insert opener1;

		// -------- CREATING THE COMMISSION HIERARCHIES --------

		DNE_Commission_Hierarchy__c ch1 = new DNE_Commission_Hierarchy__c();
		//ch1.Opener__c = opener1.Id;
		ch1.Effective_From__c = Datetime.now().addDays(-1);
		ch1.Type__c = 'New Business';

		/*for(Integer i=0; i<NB_OF_COMMISSION_LEVELS; i++)
		{
			ch1.put('Level_' + (i+1) + '__c', commissionReceiverList.get(i).Id);
		}*/






		AddCommisionTemplateController.getPicklistsOptions();

		// -------------- OPENER MISSING --------------
		String returnMessage = 
			AddCommisionTemplateController.saveCommissionHierarchy(ch1, null,
																   commissionReceiverList.get(0).Id,
																   commissionReceiverList.get(1).Id,
																   commissionReceiverList.get(2).Id,
																   commissionReceiverList.get(3).Id,
																   commissionReceiverList.get(4).Id,
																   commissionReceiverList.get(5).Id,
																   commissionReceiverList.get(6).Id,
																   commissionReceiverList.get(7).Id,
																   commissionReceiverList.get(8).Id,
																   commissionReceiverList.get(9).Id,
																   commissionReceiverList.get(10).Id,
																   commissionReceiverList.get(11).Id,
																   commissionReceiverList.get(12).Id,
																   commissionReceiverList.get(13).Id,
																   commissionReceiverList.get(14).Id,
																   commissionReceiverList.get(15).Id);
		System.assertEquals('ERROR: The Opener is required.', returnMessage);


		// -------------- EFFECTIVE FROM MISSING --------------
		ch1.Effective_From__c = null;
		returnMessage = 
			AddCommisionTemplateController.saveCommissionHierarchy(ch1, opener1.Id,
																   commissionReceiverList.get(0).Id,
																   commissionReceiverList.get(1).Id,
																   commissionReceiverList.get(2).Id,
																   commissionReceiverList.get(3).Id,
																   commissionReceiverList.get(4).Id,
																   commissionReceiverList.get(5).Id,
																   commissionReceiverList.get(6).Id,
																   commissionReceiverList.get(7).Id,
																   commissionReceiverList.get(8).Id,
																   commissionReceiverList.get(9).Id,
																   commissionReceiverList.get(10).Id,
																   commissionReceiverList.get(11).Id,
																   commissionReceiverList.get(12).Id,
																   commissionReceiverList.get(13).Id,
																   commissionReceiverList.get(14).Id,
																   commissionReceiverList.get(15).Id);
		System.assertEquals('ERROR: The Effective From field is required.', returnMessage);


		// -------------- LEVEL 1 MISSING --------------
		ch1.Effective_From__c = Datetime.now().addDays(-1);
		returnMessage = 
			AddCommisionTemplateController.saveCommissionHierarchy(ch1, opener1.Id,
																   null,
																   commissionReceiverList.get(1).Id,
																   commissionReceiverList.get(2).Id,
																   commissionReceiverList.get(3).Id,
																   commissionReceiverList.get(4).Id,
																   commissionReceiverList.get(5).Id,
																   commissionReceiverList.get(6).Id,
																   commissionReceiverList.get(7).Id,
																   commissionReceiverList.get(8).Id,
																   commissionReceiverList.get(9).Id,
																   commissionReceiverList.get(10).Id,
																   commissionReceiverList.get(11).Id,
																   commissionReceiverList.get(12).Id,
																   commissionReceiverList.get(13).Id,
																   commissionReceiverList.get(14).Id,
																   commissionReceiverList.get(15).Id);
		System.assertEquals('ERROR: At least one Level is required for a Commission Hierarchy.', returnMessage);



		// -------------- RECORD OK --------------
		returnMessage = 
			AddCommisionTemplateController.saveCommissionHierarchy(ch1, opener1.Id,
																   commissionReceiverList.get(0).Id,
																   commissionReceiverList.get(1).Id,
																   commissionReceiverList.get(2).Id,
																   commissionReceiverList.get(3).Id,
																   commissionReceiverList.get(4).Id,
																   commissionReceiverList.get(5).Id,
																   commissionReceiverList.get(6).Id,
																   commissionReceiverList.get(7).Id,
																   commissionReceiverList.get(8).Id,
																   commissionReceiverList.get(9).Id,
																   commissionReceiverList.get(10).Id,
																   commissionReceiverList.get(11).Id,
																   commissionReceiverList.get(12).Id,
																   commissionReceiverList.get(13).Id,
																   commissionReceiverList.get(14).Id,
																   commissionReceiverList.get(15).Id);
		System.assert(returnMessage.contains('SUCCESS'));
	}

}