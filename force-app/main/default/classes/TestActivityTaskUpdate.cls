@isTest
public class TestActivityTaskUpdate {
	@isTest
   public static void updateTaskDate(){
       Lead[] leads = new Lead[] {
         new Lead(LastName='Test', Company='Test', Status='Marketing Engaged') 
             };
    insert leads;
    Task[] tasks = new Task[] {
        new Task(Subject='Test', WhoId=leads[0].Id, Status='Completed')
    };
    Test.startTest();
    insert tasks;
    Test.stopTest();
    }
}