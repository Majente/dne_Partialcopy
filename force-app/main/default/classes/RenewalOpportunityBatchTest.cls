/**************************************************
* Class: RenewalOpportunityBatchTest
* Author: Soljit <VW>
* Date: 2019-10-14
* Description: RenewalOpportunityBatchTest for RenewalOpportunityBatch
****************************************************/
@isTest
public class RenewalOpportunityBatchTest {
/**************************************************
* Method Name : testMethod1
* Parameter   : 
* Description : method used to create test data for class
****************************************************/
    
    static testMethod void testMethod1(){
        RenewalOppOwner__c renewalCustom = new RenewalOppOwner__c();
        renewalCustom.Second_Warning__c = 60;
        renewalCustom.Third_Warning__c =30;
        renewalCustom.First_Warning__c =90;
        renewalCustom.OwnerId__c = '0050q000001emm7AAA';
        insert renewalCustom;
        
        List<Opportunity> lstOpportunity= new List<Opportunity>();
        for(Integer i=0 ;i <200;i++){
            Opportunity opp = new Opportunity();
            opp.Name ='Name'+i;
            opp.StageName = 'Qualification';
            opp.CloseDate = System.today();
            opp.Type = 'Renewal';
            lstOpportunity.add(opp);
        }
        
        insert lstOpportunity;
       
        
        Test.startTest();

            RenewalOpportunityBatch obj = new RenewalOpportunityBatch();
            Database.executeBatch(obj,200); 
            
        Test.stopTest();
    }

}