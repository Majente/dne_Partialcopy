/**************************************************

* Class: LeadFlowBatch_Schedulable
* Author: Soljit <MJ>
* Date: JULY 2020
* Description: schedule class for scheduling LeadFlowBatch class
****************************************************/ 
global class LeadFlowBatch_Schedulable implements Schedulable
{
    // execute method
    global void execute(SchedulableContext sc) 
    {
        LeadFlowBatch b1 = new LeadFlowBatch();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }
}