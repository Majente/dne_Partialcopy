/**************************************************
* Class : ReconciliationScheduler
* Author: SOLJIT 
* Date  : SEP 2019
* Description : scheduler class for schedule ReconciliationControllerBatch class
****************************************************/

global class ReconciliationScheduler implements Schedulable {
    /**************************************************
* Method Name : execute
* Parameters  : SchedulableContext sc 
* Description : method to execute batch class
****************************************************/
    
    global void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new ReconciliationControllerBatch(), 200);
    }
}