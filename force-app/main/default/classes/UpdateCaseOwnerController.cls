/*************************************************************
* Class: UpdateCaseOwnerController
* Author: Soljit <VW>
* Date: 2019-05-24
* Description: controller for update case owner
**************************************************************/
public class UpdateCaseOwnerController {
    /*************************************************************
* Method Name : UpdateCase
* Parameter   : Id ownerId, Id caseId
* Description : method to update case owner
**************************************************************/
    @AuraEnabled
    public static Case UpdateCase(Id ownerId, Id caseId) {
        System.debug('ownerId = '+ownerId);
        System.debug('caseId = '+caseId);
        Case c = [SELECT Id, OwnerId from Case where Id =: caseId limit 1];
        c.OwnerId = ownerId;
        try{
            UPDATE c;
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
        }
        return c;
    }
      /*************************************************************
* Method Name : UpdateCaseOwnerAsQueue
* Parameter   : Id caseId
* Description : method to update case owner as queue
**************************************************************/
    @AuraEnabled
    public static Case UpdateCaseOwnerAsQueue(Id caseId) {
        Group opsQ = [select Id,Name from Group where  Type = 'Queue' AND NAME = 'Operations Queue' LIMIT 1];
        if(opsQ == null){
            return null; 
        }
        System.debug('caseId = '+caseId);
        Case c = [SELECT Id, OwnerId from Case where Id =: caseId limit 1];
       
        c.OwnerId = opsQ.Id;
        try{
            UPDATE c;
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
        }
        return c;
    }
}