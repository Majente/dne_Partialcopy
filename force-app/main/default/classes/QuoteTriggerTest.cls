@isTest
public class QuoteTriggerTest {
    @isTest
    public static void testQuoteUpdate(){
        SBQQ__Quote__c qt = new SBQQ__Quote__c(SBQQ__EndDate__c = System.today());
        insert qt;
        qt.SBQQ__EndDate__c = System.today() + 1;
        Update qt;
        System.assertEquals(null , [Select id , SBQQ__EndDate__c from SBQQ__Quote__c limit 1].SBQQ__EndDate__c);        
    }
}