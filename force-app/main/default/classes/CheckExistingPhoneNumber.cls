public class CheckExistingPhoneNumber {
    
    @InvocableMethod
    public static List<LeadOrContactResult> CheckPhoneNumber(List<String> myPhoneNumbers) {
        
        List<LeadOrContactResult> MyResults=New List<LeadOrContactResult>();
        
        if(!myPhoneNumbers.isEmpty()) {
            
            List<String> myPhoneNumbersNoBlank = new List<String>();
            for (String currString:myPhoneNumbers){
                if (!String.isBlank(currString)){
                    myPhoneNumbersNoBlank.add(currString);
                }
            }
            
            boolean MatchContacts = false, MatchLeads = false;
            
            if(!myPhoneNumbersNoBlank.isEmpty()){
            
                String mySearchString = String.join(myPhoneNumbersNoBlank, ' OR ');
                System.debug('--mySearchString: ' + mySearchString);
                List<List<SObject>> searchList = [FIND :mySearchString 
                                                  IN PHONE FIELDS 
                                                  RETURNING Contact (Id, Clean_Phone_Contact__c, Owner.Name), 
                                                    Lead (Id, Clean_phone2__c, Owner.Name WHERE Status = 'Do Not Call')];

                List<Contact> myContacts = new List<Contact>();
                List<Lead> myLeads = new List<Lead>();
                
                if((List<Contact>)searchList[0] != null && !((List<Contact>)searchList[0]).isEmpty()){
                    myContacts = (List<Contact>)searchList[0];
                    //System.debug('---Contact: ' + (List<Contact>)searchList[0]);
                }
                if((List<Lead>)searchList[1] != null && !((List<Lead>)searchList[1]).isEmpty()){
                    myLeads = (List<Lead>)searchList[1];
                    //System.debug('---Lead: ' + (List<Lead>)searchList[1]);
                }
                    
                for(String currPhone:myPhoneNumbersNoBlank){
                    MatchContacts = false;
                    MatchLeads = false;
                    LeadOrContactResult myRes = new LeadOrContactResult();
                    if(!myContacts.isEmpty()){
                        for(Contact currContact:myContacts){
                            if(currContact.Clean_Phone_Contact__c == currPhone){
                                //match on Contact
                                MatchContacts = true;
                                myRes.contOwnerName = currContact.Owner.Name;
                                break;
                            }
                        }
                    }
                    if(!myLeads.isEmpty()){
                        for(Lead currLead:myLeads){
                            if(currLead.Clean_phone2__c == currPhone){
                                //match on Lead
                                MatchLeads = true;
                                myRes.leadOwnerName = currLead.Owner.Name;
                                break;
                            }
                        }
                    }
                    myRes.isLead = MatchLeads;
                    myRes.isContact = MatchContacts;
                    myResults.add(myRes);
                }
            }        
        }  
        return MyResults;
    }
    
    public class LeadOrContactResult{
        @InvocableVariable
        public Boolean isLead;
        
        @InvocableVariable
        public Boolean isContact;

        @InvocableVariable
        public String leadOwnerName;
        
        @InvocableVariable
        public String contOwnerName;
    }
}