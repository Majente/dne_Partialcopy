/******************************************************************
Name    : InvoiceEntriesTriggerHandler
Author  : Soljit <VW>
Description : Handler class for Invoice_Entries__c trigger to update invoice data
******************************************************************/
public class InvoiceEntriesTriggerHandler {
    /******************************************************************
Method Name    : updateInvoice
Parameter      : List<Invoice_Entries__c> invoiceEntrList
Description    : method for update invoice csv data
******************************************************************/
    public static void updateInvoice (List<Invoice_Entries__c> invoiceEntrList){
        List<Invoice__c> listUpdateInvoice = new List<Invoice__c>();
        for(Invoice_Entries__c innEt : invoiceEntrList){
            if(innEt.Invoice__c !=null){
                Invoice__c inv = new Invoice__c();
                inv.Id = innEt.Invoice__c;
                inv.Received_Amount__c = innEt.Amount__c;
                inv.Received_Adder__c = innEt.Received_Adder__c;
                inv.Received_Volume__c = innEt.Received_Volume__c;
                listUpdateInvoice.add(inv); 
            }
        } 
        System.debug('listUpdateInvoice::'+listUpdateInvoice);
        if(listUpdateInvoice.size() > 0){
            Update listUpdateInvoice;
            System.debug('Update invoices from Invoice Entries::'+listUpdateInvoice.size());
        }
    }
    
}