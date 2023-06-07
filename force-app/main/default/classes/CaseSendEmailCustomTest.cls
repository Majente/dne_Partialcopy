/**************************************************

* Class: CaseSendEmailCustomTest
* Author: Soljit <VW>
* Date: 2019-05-16
* Description: Test class for CaseSendEmailCustom

****************************************************/
@isTest(SeeAllData=true)
public class CaseSendEmailCustomTest {
    
    @isTest
    public static void testSample(){
        Id RecordTypeIdSupplier = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        
        Account acc= new Account();
        acc.name = 'Test Acc';
        acc.Company_Legal_Name__c = 'TEST PVT LTD';
        INSERT acc;
        
        Contact con = new Contact();
        con.LastName = 'DNE';
        con.AccountId = acc.id;
        Insert con;
        
        Month_Year__c monYea = new Month_Year__c();
        monYea.Name = 'May 2019';
        monYea.Month__c = 5;
        monYea.Year__c = 2019;
        INSERT monYea;
        
        Market__c marketTest = new Market__c();
        marketTest.Name = 'Alberta';
        marketTest.Gas_Threshold__c = 2500;
        marketTest.Electricity_Threshold__c = 250000;
        marketTest.Country__c = 'Canada';
        INSERT marketTest;
        
        Account supp = new Account();
        supp.Name = 'Direct Energy - Alberta';
        supp.Market__c = marketTest.id;
        supp.Business_Size__c = 'Small';
        supp.RecordTypeId = RecordTypeIdSupplier;
        INSERT supp;
        
        Opportunity opp = new Opportunity();
        opp.name ='Test opp';
        opp.AccountId = acc.id;
        opp.CloseDate = Date.newInstance(2019, 06, 20);
        opp.Market__c = marketTest.id;
        opp.Month_Year__c = monYea.id;
        opp.StageName = 'Qualification';
        opp.Commodity_Type__c = 'Gas';
        opp.Supplier__c = supp.id;
        INSERT opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.name ='Test opp';
        opp1.AccountId = acc.id;
        opp1.CloseDate = Date.newInstance(2019, 06, 20);
        opp1.Market__c = marketTest.id;
        opp1.Month_Year__c = monYea.id;
        opp1.StageName = 'Qualification';
        opp1.Commodity_Type__c = 'Gas';
        opp1.Supplier__c = supp.id;
        INSERT opp1;
        
        Case cs1 = new Case();
        cs1.Opportunity__c = opp1.id;
        cs1.AccountId =acc.id;
        cs1.Suppliers__c = 'Direct Energy - Alberta';
        cs1.Market__c = 'Alberta';
        cs1.Status = 'New';
        cs1.Origin = 'Agent';
        cs1.Term__c = '12';
        Insert cs1;
     
        Case cs = new Case();
        cs.Opportunity__c = opp.id;
        cs.AccountId =acc.id;
        cs.Suppliers__c = 'Direct Energy - Alberta';
        cs.Market__c = 'Alberta';
        cs.Status = 'New';
        cs.Origin = 'Agent';
        cs.Term__c = '12';
        Insert cs;
       
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title != NULL limit 1];
        List<String> documentList = new List<String>();
        documentList.add(documents[0].ID);
        
       /* ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            ContentDocumentId = documents[0].Id,
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;*/
       
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V'; 
        insert cdl;
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        cdlList.add(cdl);
        
        EmailTemplate e = [Select Id From EmailTemplate LIMIT 1];
        
        Test.startTest();
        CaseSendEmailCustom caseSendEmai = new CaseSendEmailCustom();
        caseSendEmai.allCDsRelatedToAR = cdlList;
        CaseSendEmailCustom.documentsWrapperClass wrapp = new CaseSendEmailCustom.documentsWrapperClass(false,documents[0].Id,documents[0].Title);
        CaseSendEmailCustom.getEmails(cs.Id);
        CaseSendEmailCustom.getEmailTemplate(cs.id);
        CaseSendEmailCustom.getContentDocument(acc.id);        
        caseSendEmai.getSignedDocuments();
        CaseSendEmailCustom.getCaseReferenceId(cs.Id);
        CaseSendEmailCustom.sendMailMethod('test@gmail.com','test@test.com','test subject','test body','test attachment',documentList,e.Id,cs.Id);
        delete cdlList;
        List<ContentDocumentLink> conDocList = [select id from ContentDocumentLink where LinkedEntityId =:acc.id  ];
        undelete conDocList;
        Test.stopTest();
        
    }
    
}