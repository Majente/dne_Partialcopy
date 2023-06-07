/*************************************************************
* Class: RoundRobinAccount_SchedulableTest
* Author: Soljit <VW>
* Date: 2019-07-09
* Description: test class for RoundRobinAccount_Schedulable
**************************************************************/
@isTest
public class RoundRobinAccount_SchedulableTest {
	 /*************************************************************
* Method Name : test_method_one
* Parameter   : 
* Description : method to test schedule batch
**************************************************************/
	@isTest 
	static void test_method_one() 
	{
		Test.startTest();
		RoundRobinAccount_Schedulable sc = new RoundRobinAccount_Schedulable();
		String schTime = '0 0 23 * * ?';
		System.schedule('My night batch', schTime, sc);
		Test.stopTest();
	}
}