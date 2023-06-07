@isTest
public class AccountFlowBatch_SchedulableTest {
	
	@isTest 
	static void test_method_one() 
	{
		Test.startTest();
		AccountFlowBatch_Schedulable sc = new AccountFlowBatch_Schedulable();
		String schTime = '0 0 23 * * ?';
		System.schedule('My night batch', schTime, sc);
		Test.stopTest();
	}
}