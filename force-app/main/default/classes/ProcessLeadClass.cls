public class ProcessLeadClass {
@AuraEnabled
    public static void ProcessLeadMethod(string RecId){
     LeadFlowBatch batchable = new LeadFlowBatch(RecId);
        database.executeBatch(batchable);
    }
    @AuraEnabled
    public static void ProcessLeadMethod2(string RecId){
        RoundRobinLeadAssignmentBatch batchable = new RoundRobinLeadAssignmentBatch(null,RecId);
        database.executeBatch(batchable);
    }
}