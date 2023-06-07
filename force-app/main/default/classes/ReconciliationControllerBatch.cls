/**************************************************
* Class: ReconciliationControllerBatch
* Author: Soljit <VW>
* Date:  2020-05-23
* Description : batch class to delete document records
****************************************************/
global class ReconciliationControllerBatch implements Database.Batchable<sObject>, Database.Stateful{
     /**************************************************
* Method Name : start
* Parameters  : Database.BatchableContext bc
* Description : method used to get document records
****************************************************/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String docName = '%' + 'Invoice Reconciliation' + '%.csv';
        String fileId = 'Select Id, Name FROM Document WHERE NAME LIKE : docName';
        system.debug('fileId::::'+fileId);
        return Database.getQueryLocator(fileId);
    }
     /**************************************************
* Method Name : execute
* Parameters  : Database.BatchableContext bc,List<Document> documentList
* Description : method used to delete document records
****************************************************/
     global void execute(Database.BatchableContext BC, List<Document> documentList){
          System.debug('documentList before delete : '+documentList.size());
       
         try{
           if(documentList.size() > 0){
             DELETE documentList;
               System.debug('documentList after delete : '+documentList.size());
           }
         }catch(Exception e){
             System.debug('Exception Occured while delete the document : '+e.getMessage());
         }
       
    }
     /**************************************************
* Method Name : finish
* Parameters  : Database.BatchableContext bc
* Description : method used to execute action after batch completion
****************************************************/
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        //then use the active job id and abort it
        //system.abortJob(a.id);
    }
}