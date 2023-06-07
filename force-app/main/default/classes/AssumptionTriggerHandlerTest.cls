/**************************************************
* Class: AssumptionTriggerHandlerTest
* Author: Soljit <VW>
* Date: JUNE 2019
* Description: test class for AssumptionTriggerHandler
****************************************************/
@isTest
public class AssumptionTriggerHandlerTest {
    /**************************************************
* Method Name : testSample
* Parameters  : 
* Description : method to create test data and test method
****************************************************/
@isTest
    public static void testSample(){
        
                Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Account acc= new Account();
        acc.name = 'Test Acc';
        acc.RecordTypeId = RecordTypeIdSupplier;
        INSERT acc;
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        markettest.Country__c = 'Canada';
        INSERT marketTest;
        
        Assumption__c assumption = new Assumption__c();
        assumption.Supplier__c = acc.Id ;
        assumption.Market__c = marketTest.Id;
        assumption.Business_Size__c = 'Small';
        assumption.Commodity__c = 'Gas';
        assumption.End_Date__c = System.today()+1;
        assumption.Start_Date__c = System.today();
        assumption.Amount__c = 25000;
        assumption.Type__c = 'Margin Min';
        assumption.Pricing_Type__c = 'Fixed';
        Insert assumption;
        
    }
}