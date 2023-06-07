@isTest
public class LeadDataTriggerTest {
@TestSetup
    static void TestData(){
        Lead ld = new Lead();
        ld.LastName = 'Lead';
        ld.FirstName = 'Test';
        ld.tempMarket__c = 'Quebec';
        ld.Phone = '3387846570 | 3387846512';
        ld.State = 'QC';
        ld.City = 'Blainville';
        ld.Country = 'Canada';
        ld.Email = 'Test@gmail.com';
        ld.Description = 'TestDescription';
        ld.Company = 'TComp';
        insert ld;
    }
    @isTest
    static void testMethod1(){
        
    }
}