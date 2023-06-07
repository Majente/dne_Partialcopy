/**************************************************
* Name : ContentDocumentLinkTriggerHandler
* Author: Soljit NA
* Date: 2019-05-16
* 
* Description: Trigger on the ContentDocumentLink object to do rollup on lead and account initially
*
****************************************************/

trigger ContentDocumentLinkTriggerHandler on ContentDocumentLink (after insert, after delete, after undelete) {
    switch on Trigger.OperationType {
        when BEFORE_INSERT {
            // BEFORE INSERT
            ContentDocumentLinkTriggerMaster.beforeInsert(Trigger.new);
        } 
        when AFTER_INSERT {
            // AFTER INSERT
            ContentDocumentLinkTriggerMaster.afterInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            // BEFORE UPDATE
            ContentDocumentLinkTriggerMaster.beforeUpdate(Trigger.newMap, Trigger.oldMap); 
        }
        when AFTER_UPDATE {
            // AFTER UPDATE
            ContentDocumentLinkTriggerMaster.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        when BEFORE_DELETE {
            // BEFORE DELETE
            ContentDocumentLinkTriggerMaster.beforeDelete(Trigger.old);
        }
        when AFTER_DELETE {
            // AFTER DELTE
            ContentDocumentLinkTriggerMaster.afterDelete(Trigger.old);
        }
        when AFTER_UNDELETE {
            // BEFORE UNDELETE
            ContentDocumentLinkTriggerMaster.afterUndelete(Trigger.new);
        }
    }
}