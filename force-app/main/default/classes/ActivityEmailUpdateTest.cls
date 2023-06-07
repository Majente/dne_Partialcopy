@isTest
public class ActivityEmailUpdateTest {
    @TestSetup
    static void createRecord(){
        Lead ld = new Lead(LastName='Test', Company='Test', Status='Marketing Engaged');
        insert ld;
        Task tsk = new Task(Subject='Test', WhoId=ld.Id);
        insert tsk;
        EmailMessage msg = new EmailMessage();
        msg.ToAddress = 'kamlesh.mawaliya@virtuowhiz.com';
        msg.Subject='Test';
        insert msg;        
    }
    @isTest static void TestEmailUpdate(){
        Test.startTest();
        Lead[] leads = new Lead[] {
            new Lead(LastName='Test', Company='Test', Status='Marketing Engaged') 
                };
                    insert leads;
        Event[] events = new Event[] {
            new Event(Subject='Test', WhoId=leads[0].Id,StartDateTime=system.DateTime.now(),EndDateTime=system.DateTime.now())
                };                     
                    insert events;
        Task[] Tasks = new Task[] {
            new Task(Subject='Test', WhoId=leads[0].Id)
                };
                    insert Tasks;
        
        
        
        Test.stopTest();
    }
}