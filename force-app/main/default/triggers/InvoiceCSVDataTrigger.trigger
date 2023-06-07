trigger InvoiceCSVDataTrigger on Invoice_CSV_Data__c (Before insert) {
    if(Trigger.isBefore && Trigger.isInsert){
      // InvoiceCSVDataTriggerHelper.updateInvoice(Trigger.new);
    }
}