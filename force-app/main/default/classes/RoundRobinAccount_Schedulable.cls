/*************************************************************
* Class: RoundRobinAccount_Schedulable
* Author: Soljit <VW>
* Date: 2019-07-09
* Description: schedule class for schedule RoundRobinAccountAssignmentBatch
**************************************************************/
global class RoundRobinAccount_Schedulable implements Schedulable
{
    /*************************************************************
* Method Name : execute
* Parameter   : SchedulableContext sc
* Description : method used to execute batch class
**************************************************************/
    global void execute(SchedulableContext sc) 
    {
        RoundRobinAccountAssignmentBatch b1 = new RoundRobinAccountAssignmentBatch();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }
}