/**************************************************
* Class: CaseSendEmailCustom
* Author: Soljit <VW>
* Date: 2019-06-27
****************************************************/
public without sharing class CaseSendEmailCustom {
    
    public List<documentsWrapperClass> documentsWrappers {get; set;}
    public List<documentsWrapperClass> signedDocs {get; set;}
    
    @AuraEnabled
    public List<ContentDocumentLink> allCDsRelatedToAR {get; set;}
    
    @AuraEnabled
    public ContentDocument signedDoc {get; set;}
    
    @AuraEnabled 
    public static Id ARID {get; set; }
    @AuraEnabled 
    public static Case CaseRequest {get; set;}

    /*********************************************************
    @Name 			: sendMailMethod
    @Parameters 	: string:mMail,string:ccEmail,String:mSubject ,String:mbody,String:attachmentName,List<String>:documentID,String:templateId, string:recordid
    @Reutrn type 	: void
    @Description 	: Send mail method
	********************************************************/
    @AuraEnabled 
    public static void sendMailMethod(String mMail,String ccEmail,String mSubject ,String mbody,String attachmentName,List<String> documentID,String templateId, string recordid){
        
      List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        String[] toAddresses = mMail.split(';', 0);
                 
        //sendTo.add(mMail);
        //mail.setToAddresses(toAddresses);
        mail.setBccAddresses(toAddresses);
        // CC Address
        
        
        if(ccEmail !=''){
            String[] ccAddresses = ccEmail.split(';', 0);            
            mail.setCcAddresses(ccAddresses);
        }
        
        // Create the email attachment        
        
        List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
        
        Integer fileCount = 0 ;         
        for(ContentVersion a : [ SELECT Id, VersionData, ContentDocumentId,Title, FileType 
                                 FROM ContentVersion WHERE ContentDocumentId in : documentID ]){
                fileCount++;
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                Blob b = a.VersionData;
                String fileName=fileCount+a.Title +'.'+ a.FileType;
                efa.setFileName(fileName);
                efa.setBody(b);   
                efaList.add( efa );   
        }        
        
        if(documentID.size()>0){
            mail.setFileAttachments(efaList);
        }
        // Step 3: Set who the email is sent from
        //mail.setReplyTo('noreply@soljit.com'); // change it with your mail address.
        Supplier_Rate_Config__c src = Supplier_Rate_Config__c.getOrgDefaults();
        if(src != null && String.isNotEmpty(src.Email_Service_Address__c)){
            mail.setReplyTo(src.Email_Service_Address__c);
        }
        //mail.setReplyTo('nisar@5voig9djrdakscut0e7vnm5ehhflje255ve44040oddphb6o4.0q-9cmrea2.cs64.case.sandbox.salesforce.com');
        //mail.setSenderDisplayName('salesforce User'); 
               
        // Step 4. Set email contents - you can use variables!
        
        for(Case c : [SELECT id, Email_Thread_Id__c  
                      FROM Case WHERE Id = :recordid LIMIT 1]){
            mSubject  += '[ '+c.Email_Thread_Id__c + ' ]';
            //mbody += c.Email_Thread_Id__c;
        }
        mail.setSubject(mSubject);
        System.debug('Subject :: '+mSubject);
        mail.setHtmlBody(mbody);   
        mail.setSaveAsActivity(true);
        mail.whatId=recordid ;
        //mail.setTargetObjectId(recordid);
       
        // Step 5. Add your email to the master list
        mails.add(mail);
                
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);
    }
    
	/*********************************************************
    @Name 			: getContentDocument
    @Parameters 	: string:appId
    @Reutrn type 	: List<ContentDocument>
    @Description 	: get content document
	********************************************************/
    @auraEnabled
    public static List<ContentDocument> getContentDocument(string appId){
        ID ARID = appId;
        List<ID> contDocIds = new List<ID>();
        For(ContentDocumentLink cdl: [SELECT Id, ContentDocumentId, ContentDocument.Title 
                                      FROM ContentDocumentLink WHERE LinkedEntityId =:ARID ]){
           contDocIds.add(cdl.ContentDocumentId);                               
        }

        List<ContentDocument> document = [SELECT Id, Title, FileType, FileExtension 
                                          FROM ContentDocument WHERE Id IN : contDocIds];
        
        return document;     
        
    }
    /*********************************************************
    @Name 			: getEmails
    @Parameters 	: string:appId
    @Reutrn type 	: List<String>
    @Description 	: get email method
	********************************************************/
    @auraEnabled
    public static List<String> getEmails(string appId)
    { system.debug('appId --->'+appId);
     List<String> SupplierList = new List<String>();
     CaseRequest = [SELECT Id,Opportunity__c,Supplier_1__r.name,Supplier_2__r.name,Supplier_3__r.name,Supplier_4__r.name,Supplier_5__r.name,Market__c  
                    FROM Case WHERE Id =:appId ];
     SupplierList.add(CaseRequest.Supplier_1__r.name);
     SupplierList.add(CaseRequest.Supplier_2__r.name);
     SupplierList.add(CaseRequest.Supplier_3__r.name);
     SupplierList.add(CaseRequest.Supplier_4__r.name);
     SupplierList.add(CaseRequest.Supplier_5__r.name);
     System.debug('SupplierList::'+SupplierList);
     if( (CaseRequest.Market__c != null || CaseRequest.Market__c == '--None--')){
         
         List<String> emailIds = new List<String>();
         for(Account a  : [Select Id, Email__c 
                           From Account Where Name IN : SupplierList AND Market__r.Name =:CaseRequest.Market__c]){
                emailIds.add(a.Email__c);
         }
         System.debug('emailIds:::'+emailIds);
         return emailIds;
     }
        return null;
    }
    /*********************************************************
    @Name 			: getEmailTemplate
    @Parameters 	: string:appId
    @Reutrn type 	: List<EmailTemplate>
    @Description 	: fetch email template
	********************************************************/
    @auraEnabled
    public static List<EmailTemplate> getEmailTemplate(string appId){
        ID ARID = appId;
        String type = '';
        //ARID = 'a2V1k0000003jvyEAA';
        
        //Annual_Volume_Interac__c + Annual_Volume_Mastercard__c + Annual_Volume_Gift_Cards__c  Code_promo__c Commentaires__c
        
        CaseRequest = [SELECT Id,Term__c,Other_terms__c,Opportunity__c,Suppliers__c,Market__c  
                       FROM Case WHERE Id =:ARID ];
        //string terms = CaseRequest.Term__c
        List<EmailTemplate> template = [SELECT Id,Name,HtmlValue, DeveloperName 
                                        FROM EmailTemplate WHERE RelatedEntityType ='Case'];   
        Opportunity opp = null;
        String contactName;
        Contact primaryContact = null;
        System.debug('Before Query:   ');
        for(Opportunity o : [SELECT Id,Commodity_Type__c,Account.Company_Legal_Name__c,Company_Name__c,Account.Name, Account.BillingStreet, Account.BillingCity,
                             Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                             Contact_Name__c,Contact_Phone__c,Business_Address__c,CurrentSupplier__r.Name,
                             CloseDate,Electricity_Product_of_Choice__c,Product_of_Choice__c,CurrentSupplier__c,
                             Gas_Product_of_Choice__c,Subscription_Term__c,Total_Volume__c,
                             Account.Primary_Contact__c,Account.PrimaryContact_Phone__c
                             FROM Opportunity WHERE id =: CaseRequest.Opportunity__c]){
            opp = o; 
                                 
        }
        System.debug('After Query:   ' + opp);
        String phoneNumber = opp.Account.PrimaryContact_Phone__c ; 
        for(Contact con : [Select FirstName,LastName, Phone 
                           From Contact Where Id =:opp.Account.Primary_Contact__c ]){
            primaryContact = con;
            contactName = con.FirstName + ' ' + con.LastName;
           
        }
        System.debug('localBody:   '+opp.Account.PrimaryContact_Phone__c );
        System.debug('phoneNumber:   '+phoneNumber );
        if(!template.isEmpty() && opp != null){
            String localBody = template[0].HtmlValue; 
            //System.debug('localBody:   '+template);
            system.debug('Commodity_Type__c ------>'+opp.Commodity_Type__c);
            localBody = localBody.replace('{{Case.Id}}','{{Case.'+CaseRequest.Id+'}}');
            if(opp.Commodity_Type__c != null){
                if(opp.Account.Company_Legal_Name__c != null){
                    localBody = localBody.replace('{{{Opportunity.Account.Company_Legal_Name__c}}}', opp.Account.Company_Legal_Name__c);}
                else{localBody = localBody.replace('{{{Opportunity.Account.Company_Legal_Name__c}}}', '');}
                if(opp.Company_Name__c != null){
                    localBody = localBody.replace('{{{Opportunity.Account.Name}}}', opp.Account.Name);}
                else{localBody = localBody.replace('{{{Opportunity.Account.Name}}}', '');}
                if(opp.Contact_Name__c != null){
                    localBody = localBody.replace('{{{Opportunity.Contact_Name__c}}}', contactName);}
                else{localBody = localBody.replace('{{{Opportunity.Contact_Name__c}}}', '');}
                if(phoneNumber != null){
                    localBody = localBody.replace('{{{Opportunity.Contact_Phone__c}}}', phoneNumber);}
                else{localBody = localBody.replace('{{{Opportunity.Contact_Phone__c}}}', '');}
                if(opp.Business_Address__c != null){
                    localBody = localBody.replace('{{{Opportunity.Account.BillingAddress}}}', opp.Account.BillingStreet +''+ opp.Account.BillingCity+'<br/>'+ 
                             opp.Account.BillingState+'<br/>'+  opp.Account.BillingPostalCode+'<br/>'+ opp.Account.BillingCountry);}
                else{localBody = localBody.replace('{{{Opportunity.Account.BillingAddress}}}', '');}
                if(opp.CurrentSupplier__c != null){
                    localBody = localBody.replace('{{{Opportunity.CurrentSupplier__c}}}', opp.CurrentSupplier__r.Name);}
                else{localBody = localBody.replace('{{{Opportunity.CurrentSupplier__c}}}', '');}
                if(opp.Commodity_Type__c != null){
                    localBody = localBody.replace('{{{Opportunity.Commodity_Type__c}}}', opp.Commodity_Type__c);}
                else{localBody = localBody.replace('{{{Opportunity.Commodity_Type__c}}}', '');}
                
                if(opp.Commodity_Type__c == 'Electricity'){
                    localBody = localBody.replace('{{{type__c}}}', 'Electricity');
                if(opp.Total_Volume__c  != null){
                    localBody = localBody.replace('{{{Volume__c}}}', string.valueOf(opp.Total_Volume__c));}
                else{localBody = localBody.replace('{{{Volume__c}}}', '');}
                if(opp.CloseDate != null){
                    localBody = localBody.replace('{{{CloseDate}}}', string.valueOf(opp.CloseDate));}
                else{localBody = localBody.replace('{{{CloseDate}}}', '');}
                if(opp.Product_of_Choice__c != null){
                    localBody = localBody.replace('{{{Product_of_Choice__c}}}', opp.Product_of_Choice__c);}
                else{localBody = localBody.replace('{{{Product_of_Choice__c}}}', '');}
                if(CaseRequest.Term__c != null || CaseRequest.Other_terms__c != null){
                    String str = (CaseRequest.Other_terms__c != null)?';'+CaseRequest.Other_terms__c:'';
                    localBody = localBody.replace('{{{Subscription_Term__c}}}', CaseRequest.Term__c + str);}
                    else{localBody = localBody.replace('{{{Subscription_Term__c}}}', '');}
                }
                
                if(opp.Commodity_Type__c == 'Gas'){ 
                    localBody = localBody.replace('{{{type__c}}}', 'Natural Gas');
                if(opp.Total_Volume__c  != null){
                    localBody = localBody.replace('{{{Volume__c}}}', string.valueOf(opp.Total_Volume__c));}
                else{localBody = localBody.replace('{{{Volume__c}}}', '');}
                if(opp.CloseDate != null){
                    localBody = localBody.replace('{{{CloseDate}}}', string.valueOf(opp.CloseDate));}
                else{localBody = localBody.replace('{{{CloseDate}}}', '');}
                if(opp.Product_of_Choice__c != null){
                    localBody = localBody.replace('{{{Product_of_Choice__c}}}', opp.Product_of_Choice__c);}
                else{localBody = localBody.replace('{{{Product_of_Choice__c}}}', '');}
                if(CaseRequest.Term__c != null || CaseRequest.Other_terms__c != null){
                    String str = (CaseRequest.Other_terms__c != null)?';'+CaseRequest.Other_terms__c:'';
                    localBody = localBody.replace('{{{Subscription_Term__c}}}', CaseRequest.Term__c + str);}
                else{localBody = localBody.replace('{{{Subscription_Term__c}}}', '');}
                }
            }
            //localBody = localBody.replace('{!Volume_Acqu_reur__c}', c_Volume_Acquired);
            //localBody = localBody.replace('{!Annual_Volume_Accord_D__c}', Accord_D);
            template[0].HtmlValue = localBody;
            //Create Subject
            String subject = 'Custom Price Request -'+ opp.Account.Company_Legal_Name__c +'-'+ opp.Commodity_Type__c;
            
            template[0].subject = subject;
        }
        return template;
        
    }
    
  /*********************************************************
    @Name 			: getDocuments
    @Parameters 	: 
    @Reutrn type 	: List<documentsWrapperClass>
    @Description 	: Fills the page data
	********************************************************/
    @auraEnabled
    public List<documentsWrapperClass> getDocuments() {
        system.debug('dddd' +allCDsRelatedToAR[0].ContentDocument.Title + 'idddd is ' +allCDsRelatedToAR[0].ContentDocumentId);
        for(ContentDocumentLink cdl : allCDsRelatedToAR){
            documentsWrapperClass dWC = new documentsWrapperClass(false, cdl.ContentDocumentId, cdl.ContentDocument.Title);
            documentsWrappers.add(dWC);
            
        }
        return documentsWrappers;
    }

    /*********************************************************
    @Name 			: getSignedDocuments
    @Parameters 	: 
    @Reutrn type 	: List<documentsWrapperClass>
    @Description 	: Fills the page data with sending signed document
	********************************************************/
    @auraEnabled
    public List<documentsWrapperClass> getSignedDocuments() {
            if(signedDoc != null){
                system.debug('id is ' +signedDoc.Id +  'title is' +signedDoc.Title);
                 signedDocs.add(new documentsWrapperClass(false, string.valueof(signedDoc.Id) , string.valueof(signedDoc.Title)));
            }
        return signedDocs;
    }
    /*********************************************************
    @Name 			: getCaseReferenceId
    @Parameters 	: Id:caseId
    @Reutrn type 	: String
    @Description 	: get case Id
	********************************************************/
    public static String getCaseReferenceId(Id caseId){
        return '';
    }   
    
     /*********************************************************
    @Name 			: documentsWrapperClass
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: Wrapper class for document
	********************************************************/
    public class documentsWrapperClass{
        public Boolean isChecked {get; set;}
        public String documentId {get; set;}
        public String documentTitle {get; set;}
        
        /*********************************************************
    @Name 			: documentsWrapperClass
    @Parameters 	: Boolean isChecked, String documentId, String documentTitle
    @Reutrn type 	: void
    @Description 	: constructor
	********************************************************/
        public documentsWrapperClass(Boolean isChecked, String documentId, String documentTitle){
            this.isChecked = isChecked; 
            this.documentId = documentId;
            this.documentTitle = documentTitle;
        }
    }
}