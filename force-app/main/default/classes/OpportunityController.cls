public class OpportunityController {
	@AuraEnabled
    public static List <Opportunity> fetchOpportunity() {
        //Qyery 10 accounts
        List<Opportunity> oppList = [SELECT Id, Name,Account.Name,Owner.Name FROM Opportunity ];
        //return list of accounts
        return oppList;
    }
}