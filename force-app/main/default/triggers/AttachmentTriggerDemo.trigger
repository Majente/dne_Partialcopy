trigger AttachmentTriggerDemo on Attachment (before insert) {
List<Attachment> toBeUpdatedAttachment = new List<Attachment>();
    Map<String,Attachment> xyz = new map<String,Attachment>();
    for(Attachment objAttachment : Trigger.new){
        if(objAttachment.ParentId.getSobjectType() == SBQQ__Quote__c.SobjectType){
            xyz.put(objAttachment.ParentId, objAttachment);
        }
    }
    for(SBQQ__Quote__c sbqqq :[select id,Custom_Name__c from SBQQ__Quote__c where id=:xyz.keySet() ]){
        if(xyz.containsKey(sbqqq.id)){
            xyz.get(sbqqq.id).Name = sbqqq.Custom_Name__c + '.pdf';

        }
    }
     
}