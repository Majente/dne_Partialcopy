/**************************************************
* Class: RoundRobinLead_SchedulableTest
* Author: Soljit <VW>
* Date: 2019-07-09
* Description : test class for RoundRobinLead_Schedulable
****************************************************/
@isTest
public class RoundRobinLead_SchedulableTest {
	
	@isTest static void test_method_one() 
	{
		Test.startTest();
		RoundRobinLead_Schedulable sc = new RoundRobinLead_Schedulable();
		String schTime = '0 0 23 * * ?';
		System.schedule('My night batch', schTime, sc);
		Test.stopTest();
	}
}