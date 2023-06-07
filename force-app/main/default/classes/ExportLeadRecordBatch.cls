global class ExportLeadRecordBatch implements Database.Batchable<sObject> {
    global String query;
    global String RecordId;
    global Set<Id> MarketIdSet;
    global ExportLeadRecordBatch(){
        List<string> MarketNameList = new List<string>{'Alberta','Illinois','Ohio'};
            MarketIdSet = new Set<id>();
        List<Market__c> MarkList = [select id,Name from Market__c where Name IN: MarketNameList];
        For(Market__c Mark: MarkList){
            MarketIdSet.add(Mark.id);
        }
        system.debug('MarketIdSet ::'+MarketIdSet);
        // collect the batches of records or objects to be passed to execute
        query = 'SELECT Id,Market__c,IsConverted,Ready_To_Export__c FROM Lead Where IsConverted = false';
        query += ' AND Ready_To_Export__c = false'; 
        query += ' AND Market__c != null';
        query += ' AND Market__c NOT IN: MarketIdSet'; 
    }
    global ExportLeadRecordBatch(string RecID){
        RecordId = RecID;
        system.debug('RecordId :'+RecordId);
        List<string> MarketNameList = new List<string>{'Alberta','Illinois','Ohio'};
            MarketIdSet = new Set<id>();
        List<Market__c> MarkList = [select id,Name from Market__c where Name IN: MarketNameList];
        For(Market__c Mark: MarkList){
            MarketIdSet.add(Mark.id);
        }
        system.debug('MarketIdSet ::'+MarketIdSet);
        // collect the batches of records or objects to be passed to execute
        query = 'SELECT Id,Market__c,IsConverted,Ready_To_Export__c FROM Lead Where IsConverted = false';
        query += ' AND Ready_To_Export__c = false';
        query += ' AND Market__c != null'; 
        query += ' AND Market__c NOT IN: MarketIdSet'; 
        query += ' AND id =: RecordId';
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Pass query data's to the execution
        system.debug('query = '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> LeadList) {
        List<Lead> UpdateList = new List<Lead>();
        List<Task> UpdateTaskList = new List<Task>();
        List<Event> UpdateEventList = new List<Event>();
        set<id> LeadIdSet = new set<id>();
        For(Lead ld: LeadList){
            ld.Ready_To_Export__c = true;
            UpdateList.add(ld);
            LeadIdSet.add(ld.Id);
        }
        system.debug('LeadIdSet ::'+LeadIdSet);
        system.debug('UpdateList-size ::'+UpdateList.size());
        /*if(LeadIdSet != null){
            List<Task> TaskList = [select id,WhoId,IsDeleted, IsArchived,Ready_To_Activity_Export__c from Task 
                                   where IsDeleted = false AND WhoId IN:LeadIdSet ALL ROWS];
            For(Task tsk: TaskList){
                tsk.Ready_To_Activity_Export__c = true;
                UpdateTaskList.add(tsk);
            }
            system.debug('UpdateTaskList-size ::'+UpdateTaskList.size());
            
            List<Event> EventList = [select id,WhoId,IsDeleted, IsArchived,Ready_To_Activity_Export__c from Event 
                                     where IsDeleted = false AND WhoId IN:LeadIdSet ALL ROWS];
            For(Event evnt: EventList){
                evnt.Ready_To_Activity_Export__c = true;
                UpdateEventList.add(evnt);
            }
            system.debug('UpdateEventList-size ::'+UpdateEventList.size());
            
        }*/
        if(UpdateList.size() > 0){
            update UpdateList;
            system.debug('UpdateList ::'+UpdateList);
            /*update UpdateTaskList;
            system.debug('UpdateTaskList ::'+UpdateTaskList);
            update UpdateEventList;
            system.debug('UpdateEventList ::'+UpdateEventList);*/
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}