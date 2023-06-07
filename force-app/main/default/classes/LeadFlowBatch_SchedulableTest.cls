/**************************************************

* Class: LeadFlowBatch_SchedulableTest
* Author: Soljit <MJ>
* Date: JULY 2020
* Description: test class for LeadFlowBatch_Schedulable class
****************************************************/ 
@isTest
public class LeadFlowBatch_SchedulableTest {
	
	@isTest 
	static void test_method_one() 
	{
		Test.startTest();
		LeadFlowBatch_Schedulable sc = new LeadFlowBatch_Schedulable();
		String schTime = '0 0 23 * * ?';
		System.schedule('My night batch', schTime, sc);
		Test.stopTest();
	}
}