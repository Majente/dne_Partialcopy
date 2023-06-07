/**************************************************
* Class: RenewalOpportunityBatch_Schedulable
* Author: Soljit <VW>
* Date: 2019-10-09
* Description: RenewalOpportunityBatch_Schedulable for RenewalOpportunityBatch
****************************************************/
global class RenewalOpportunityBatch_Schedulable implements Schedulable {
/**************************************************
* Method Name : execute
* Parameter   : SchedulableContext sc
* Description : method used to execute batch class
****************************************************/
     global void execute(SchedulableContext sc)
     {
        RenewalOpportunityBatch b1 = new RenewalOpportunityBatch();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }

}