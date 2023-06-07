@isTest
public class AttachmentTriggerDemoTest {
    static testMethod void test1()
    {
        Account a = new Account();
        a.Name = 'testAccount';
        a.Business_Size__c = 'Small';
        insert a;
        
        Opportunity o = new Opportunity();
        
        o.Accountid = a.id;
        o.Name = 'test';
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();
        o.Type = 'New Client';
        o.NextStep = 'Test';
        o.LeadSource = 'Business Development';
        insert o;
        
        SBQQ__Quote__c sbqqq = new SBQQ__Quote__c();
        sbqqq.SBQQ__Account__c = a.id ;
        sbqqq.SBQQ__Opportunity2__c = o.id;
        insert sbqqq;
        
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=sbqqq.id;
        insert attach;
        
    }
}