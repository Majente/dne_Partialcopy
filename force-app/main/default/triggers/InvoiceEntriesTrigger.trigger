trigger InvoiceEntriesTrigger on Invoice_Entries__c (after Update) {
    
    if(trigger.isAfter && trigger.isUpdate){
               InvoiceEntriesTriggerHandler.updateInvoice(Trigger.new);
    }

}