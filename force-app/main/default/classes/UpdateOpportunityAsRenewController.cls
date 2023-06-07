public class UpdateOpportunityAsRenewController {
    public Opportunity oppRec {get;set;}
    public String batchStatusCase;
    public UpdateOpportunityAsRenewController(){
        oppRec = new Opportunity();
    }
    public void runRenewOppBatch(){
        System.debug('oppRec.AccountId' + oppRec.AccountId);
        if(oppRec.AccountId == null){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Please select account record.'));
            return;
        }
        UpdateOpportunityAsRenewBatch renewBatch = new UpdateOpportunityAsRenewBatch(oppRec.AccountId);
        id batchIdCase = Database.executeBatch(renewBatch, 1);        
        AsyncApexJob job = [SELECT Id,Status FROM AsyncApexJob WHERE Id =: batchIdCase];
        batchStatusCase = job.Status;
        system.debug('batchStatusCase'+batchStatusCase);
    }

}