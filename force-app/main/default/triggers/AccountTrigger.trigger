/***************************************************************************************
@Name   : AccountTriggerHelper
@Date   : Feb 2019
@Author : Soljit VW
@Description    : AccountTrigger
***************************************************************************************/
trigger AccountTrigger on Account (before insert, before update, after insert) 
{	
	if(Trigger.isBefore)
	{
		if(Trigger.isInsert)
		{
			AccountTriggerHelper.onStatusChange();
		}
		if(Trigger.isUpdate)
		{
			AccountTriggerHelper.onStatusChange();
		}
	}
	// -------------------
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
		{
			AccountTriggerHelper.createRecord(Trigger.new);
		}
		if(Trigger.isUpdate)
		{}
	}

	/*if(Trigger.isInsert && Trigger.isAfter)
	{
	 AccountTriggerHelper.createRecord(Trigger.new);
	}*/
   
}