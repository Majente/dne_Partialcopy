/**************************************************
* Class: UpdateCaseOwnerControllerTest
* Author: Soljit <VW>
* Date: 2019-05-15
* Description: Test Class for UpdateCaseOwnerController
***************************************************/
@isTest
public class UpdateCaseOwnerControllerTest {
    @isTest
    public static void UpdateCaseOwner(){
        case c = new case();
        c.status = 'New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        insert c;
        
        Group g = new Group();
        g.Name = 'Operations Queue';
        g.Type = 'Queue';
        insert g;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
      
        Test.startTest();
        UpdateCaseOwnerController.UpdateCase(usr.id,c.id);
		System.assertEquals('New',c.status);
        UpdateCaseOwnerController.UpdateCaseOwnerAsQueue(c.id);
        Test.stopTest();
       
    }
}