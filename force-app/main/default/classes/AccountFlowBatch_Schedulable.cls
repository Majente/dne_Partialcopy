global class AccountFlowBatch_Schedulable implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        AccountFlowBatch b1 = new AccountFlowBatch();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }
}