/******************************************************************
Name    : LeadAssignmentController
Author  : Soljit <VW>
Description : apex controller LeadAssignmentPage visualforce page to run batch class
******************************************************************/
public without sharing class LeadAssignmentController 
{
	public String emailAddress {get; set;}
	public Boolean buttonActive {get; set;}
	public String batchToRun {get; set;}

	public LeadAssignmentController() 
	{
		buttonActive = true;
	}
 /******************************************************************
Method Name    : runBatch
Parameter      : List<Invoice_CSV_Data__c> invCsvDataList
Description    : method used to run batch class
******************************************************************/
	public PageReference runBatch()
	{
		String pageMessage;
		if(!emailValid(emailAddress))
		{
			pageMessage = System.Label.Valid_email_address_label;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
			return null;
		}

		if(String.isBlank(batchToRun))
		{
			pageMessage = System.Label.Batch_selection_label;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
			return null;
		}

		try
		{
			System.debug('JTM - batchToRun = ' + batchToRun);
			if(batchToRun.equalsIgnoreCase('AccountBatch'))
			{
				RoundRobinAccountAssignmentBatch b = new RoundRobinAccountAssignmentBatch(emailAddress);
				Id batchJobId = Database.executeBatch(b, 200);
			}
			else if(batchToRun.equalsIgnoreCase('LeadBatch'))
			{
				RoundRobinLeadAssignmentBatch b = new RoundRobinLeadAssignmentBatch(emailAddress);
				Id batchJobId = Database.executeBatch(b, 200);
			}
			

			pageMessage = System.Label.Currently_running_batch_label + ' ' + emailAddress + ' ' + System.Label.Job_done_label;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, pageMessage));
		}
		catch(Exception e)
		{
			pageMessage = e.getMessage();
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, pageMessage));
		}

		buttonActive = false;

		return null;
	}
	// -----------------------------------------
 /******************************************************************
Method Name    : runBatch
Parameter      : List<Invoice_CSV_Data__c> invCsvDataList
Description    : method used to run batch class
******************************************************************/
	public static Boolean emailValid(String emailAddr) 
	{
		String inputEmail = emailAddr;
		String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
		Pattern emailPattern = Pattern.compile(emailRegex);

		Matcher emailMatcher = emailPattern.matcher(inputEmail);

		if (emailMatcher.matches()) 
		{
			return true;
		}
		else 
		{
			return false;
		}
	}
	// -----------------------------------------

	public List<SelectOption> getBatchOptions() 
	{
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('AccountBatch','Account Assignment Batch')); 
        options.add(new SelectOption('LeadBatch','Lead Assignment Batch'));
        return options; 
    }

}