/**************************************************
* Class: FindContractForActivationBatchSchedule
* Description: Schedular class for schedule FindContractForActivationBatch class
****************************************************/
global class FindContractForActivationBatchSchedule implements Schedulable{ 
    // execute method
    global void execute(SchedulableContext SC){
        FindContractForActivationBatch activateBatch = new FindContractForActivationBatch();
        Database.executeBatch(activateBatch,10);
    }
}