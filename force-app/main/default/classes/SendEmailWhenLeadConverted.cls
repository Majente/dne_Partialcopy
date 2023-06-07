public class SendEmailWhenLeadConverted
{
    @InvocableMethod(label='SendEmail' description='sends an email')
    public static void sendEmailWithAttachment(List<id> leadIds)
    {

               ContentVersion cversion = [SELECT title, PathOnClient, FileType,versiondata FROM contentversion WHERE title = 'attachment1' LIMIT 1];
               blob attacheentBody = cversion.versiondata;
               Lead currentLead = [Select id,Name,Email from Lead where Id IN :leadIds LIMIT 1];
               If(String.isBlank(currentLead.email) == false)
               {
               Messaging.SingleEmailMessage semail= new Messaging.SingleEmailMessage();
               Messaging.EmailFileAttachment attach= new Messaging.EmailFileAttachment();
               attach.setBody(attacheentBody);
               semail.setSubject('Lead Conversion Email to :'+ currentLead.email);
               attach.setFileName(cversion.title);
               attach.setcontenttype('text/plain');
               String[] emailIds= new String[]{currentLead.email,'kr.suraesh@gmail.com'};
               semail.setToAddresses(emailIds);
               semail.setReplyTo('customersuccess@dneresources.com');
               semail.setSenderDisplayName('DNE Customer Success Team');
                   
                   String body = 'Hi ' + currentLead.Name + ',<br/> ';
                   body += 'This is the Sample Email Content';
                   body += '<br/><br/>';
                   body += 'Thanks and Regards <br/>';
                   body += 'DNE Resource Team';
               semail.setHtmlBody(body);
               semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
               Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
               }
    }

}