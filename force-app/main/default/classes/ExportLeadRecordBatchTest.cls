@IsTest
public class ExportLeadRecordBatchTest {
    @TestSetup
    static void createRecord(){
        Market__c theMarket = new Market__c();
        theMarket.Name = 'My Market';
        theMarket.Country__c = 'Canada';
        insert theMarket;
        
        Lead theLead = new Lead();
        theLead.LastName = 'Lead_for_' + theMarket.Name;
        theLead.Market__c = theMarket.Id;
        theLead.Company = 'Random Company Ltd';
        theLead.IsConverted = false;
        theLead.Status = 'New';
        Insert theLead;
        
        List<Task> TaskList = new List<Task>();
        Task theTask = new Task();
        theTask.ActivityDate = Date.today().addDays(100);
        theTask.Status = 'Open';
        theTask.Subject = 'Call';
        theTask.WhoId = theLead.Id;
        TaskList.add(theTask);
        
        Task theTask2 = new Task();
        theTask2.ActivityDate = Date.today().addDays(100);
        theTask2.Status = 'Open';
        theTask2.Subject = 'Send Letter';
        theTask2.WhoId = theLead.Id;
        TaskList.add(theTask2);
        
        Insert TaskList; 
        
        /*Datetime dt = DateTime.parse('10/14/2022 11:46 AM');
        String myDtString = dt.format();
        
        Event evnt = new Event();
        evnt.Subject = 'Call';
        evnt.WhoId = theLead.Id;
        evnt.DurationInMinutes = 1500; 
        evnt.ActivityDateTime = DateTime.valueOf(myDtString);
        insert evnt;*/
    }
    @IsTest
    static void Test_Method(){
        Lead ld = [select id,Market__c,IsConverted,Ready_To_Export__c from Lead limit 1];
        Test.StartTest();
        ExportLeadRecordBatch batchable = new ExportLeadRecordBatch(ld.id);
        database.executeBatch(batchable);
        Test.StopTest();
    }
    @IsTest
    static void Test_Method2(){
        Test.StartTest();
        ExportLeadRecordBatch batchable = new ExportLeadRecordBatch();
        database.executeBatch(batchable);
        Test.StopTest();
    }
}