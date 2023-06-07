@isTest
public class CheckExistingPhoneNumber_Test {

    @isTest
    public static void TestCheckExistingPhoneNumber(){
        
        User user1 = new User(Username = 'forecaas_testuser@test.com', FirstName = 'Test_User', LastName = 'ForecaaS', Email = 'forecaas_testuser@test.com', Alias = 'ftestu', 
                              TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_CA', EmailEncodingKey = 'ISO-8859-1', ProfileId = '00ef4000001zcLNAAY', LanguageLocaleKey = 'en_US');
        insert user1;
        
        Contact contact1 = new Contact(FirstName = 'Test', LastName= 'McContact', Phone = '5551234567', OwnerId = user1.Id);
        insert contact1;
        
        List<Lead> myLeadList = new List<Lead>();
        Lead lead1 = new Lead(FirstName = 'Test', LastName = 'McLead DNC', Phone = '5551234568', Status = 'Do Not Call', Reason__c = 'Other', Company = 'Awesome Company', Market__c = 'a1Kf4000002mZs4EAE');
        Lead lead2 = new Lead(FirstName = 'Test', LastName = 'McLead OK', Phone = '5551234569', Status = 'New', Company = 'Super Awesome Company', Market__c = 'a1Kf4000002mZs4EAE');
        myLeadList.add(lead1);
        myLeadList.add(lead2);
        insert myLeadList;
        
        List<String> PhoneNumbersTest = new List<String>();
        PhoneNumbersTest.add('5551234566'); // no contact or lead existing in the DB
        PhoneNumbersTest.add('5551234567'); // existing contact - should find a match
        PhoneNumbersTest.add('5551234568'); // existing lead on DNC list, should find a match
        PhoneNumbersTest.add('5551234569'); // existing lead but not on DNC list, should say ok to proceed

    	Id[] fixedSearchResults = new Id[3];
        fixedSearchResults[0] = contact1.id;
        fixedSearchResults[1] = lead1.id;
        fixedSearchResults[2] = lead2.id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        List<CheckExistingPhoneNumber.LeadOrContactResult> myExpectedTestResults = new List<CheckExistingPhoneNumber.LeadOrContactResult>();
        CheckExistingPhoneNumber.LeadOrContactResult myResult1 = new CheckExistingPhoneNumber.LeadOrContactResult();
        myResult1.isLead = false;
        myResult1.isContact = false;
        myResult1.contOwnerName = null;
        myResult1.leadOwnerName = null;
        CheckExistingPhoneNumber.LeadOrContactResult myResult2 = new CheckExistingPhoneNumber.LeadOrContactResult();
        myResult2.isLead = false;
        myResult2.isContact = true;
        myResult2.contOwnerName = 'Test_User ForecaaS';
        myResult2.leadOwnerName = null;
        CheckExistingPhoneNumber.LeadOrContactResult myResult3 = new CheckExistingPhoneNumber.LeadOrContactResult();
        myResult3.isLead = true;
        myResult3.isContact = false;
        myResult3.contOwnerName = null;
        myResult3.leadOwnerName = null; //'Lead Do Not Call'; fixedsearchresults not taking into account the reassignment to lead queue
        CheckExistingPhoneNumber.LeadOrContactResult myResult4 = new CheckExistingPhoneNumber.LeadOrContactResult();
        myResult4.isLead = false;
        myResult4.isContact = false;
        myResult4.contOwnerName = null;
        myResult4.leadOwnerName = null;        
        myExpectedTestResults.add(myResult1);
        myExpectedTestResults.add(myResult2);
        myExpectedTestResults.add(myResult3);
        myExpectedTestResults.add(myResult4);
        System.debug('Expected : ' + myExpectedTestResults);
                
        List<CheckExistingPhoneNumber.LeadOrContactResult> myActualTestResults = new List<CheckExistingPhoneNumber.LeadOrContactResult>();
        
        test.startTest();
        
        myActualTestResults = CheckExistingPhoneNumber.CheckPhoneNumber(PhoneNumbersTest);
        
        test.stopTest();
        
        system.debug('Actual : ' + myActualTestResults);
        
        for(Integer i =0; i<4; i++){
            system.assertEquals(myExpectedTestResults[i].isLead, myActualTestResults[i].isLead);
            system.assertEquals(myExpectedTestResults[i].isContact, myActualTestResults[i].isContact);
            system.assertEquals(myExpectedTestResults[i].leadOwnerName, myActualTestResults[i].leadOwnerName);
            system.assertEquals(myExpectedTestResults[i].contOwnerName, myActualTestResults[i].contOwnerName);
        }
    }
}