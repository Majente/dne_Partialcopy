/**************************************************
* Class : ReconciliationSchedularTest
* Author: SOLJIT 
* Date  : SEP 2019
* Description : test class for ReconciliationScheduler class
****************************************************/
@isTest
public class ReconciliationSchedularTest {
     /**************************************************
* Method Name : deleteDocument
* Parameters  :  
* Description : method used to test schedule class
****************************************************/
   @isTest 
    public static void deleteDocument(){
       //Document 1
        Document d = new Document();
        d.Name = 'Invoice reconciliation1.csv';
        d.folderId = UserInfo.getUserId();
        INSERT d;
        
        test.startTest();
        ReconciliationScheduler schedule = new ReconciliationScheduler();
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute());
        String ss = String.valueOf(Datetime.now().second());
        
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobID = System.schedule(d.name,nextFireTime,schedule); 
        test.stopTest();
    }
}