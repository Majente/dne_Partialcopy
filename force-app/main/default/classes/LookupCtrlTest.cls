@isTest
public class LookupCtrlTest 
{
	@testSetup
	static void createData()
	{
        Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        Id sysAdminProfileId = sysAdminProfile.Id;
        
        User theManager = new User();
        theManager.ProfileId = sysAdminProfileId;
        theManager.FirstName = 'Manager';
        theManager.LastName = 'User';
        theManager.Email = 'manager@testEmail.ro';
        theManager.Username = 'mngrABC@testEmail.ro';
        theManager.Alias = 'manag';
        theManager.EmailEncodingKey = 'ISO-8859-1';
        theManager.LanguageLocaleKey = 'en_US';
        theManager.LocaleSidKey = 'en_US';
        theManager.TimeZoneSidKey = 'America/Los_Angeles';
        theManager.Sales_Agent__c = false;
        insert theManager;
	}
	// -----------------------------------

	@isTest
	static void testMethod_1()
	{
		String objectName = 'User';
		String fld_API_Text = 'Name';
		String fld_API_Val = 'Id';
		Integer lim = 50;
		String fld_API_Search = 'Email';
		String searchText = 'manager@test';
		String extraWhereClause = '';
		String responseString = LookupCtrl.searchDB(objectName, 
													fld_API_Text, 
													fld_API_Val,
													lim,
													fld_API_Search,
													searchText,
													extraWhereClause);
		
		System.assert(responseString.contains('Manager'));
	}
}