/**************************************************
* Class: RoundRobinLead_Schedulable
* Author: Soljit <VW>
* Date: 2019-07-09
* Description : schedule class for schedule RoundRobinLeadAssignmentBatch
****************************************************/
global class RoundRobinLead_Schedulable implements Schedulable
{
    /*********************************************************
    @Name 			: execute
    @Parameters 	: SchedulableContext sc
    @Description 	: method used to execute batch class
	********************************************************/
    global void execute(SchedulableContext sc) 
    {
        RoundRobinLeadAssignmentBatch b1 = new RoundRobinLeadAssignmentBatch();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }
}