public class LeadDataTriggerHandler {
    public static void leadDataSetMethod(List<Lead> newLeadRecordList){
        system.debug('newLeadRecordList ::'+newLeadRecordList);
        User us = [select id,Name from User where name ='Mounir Kazi-Aoual'];
        set<string> marketNameSet = new set<string>();
        For(Lead ld: newLeadRecordList){
            marketNameSet.add(ld.tempMarket__c);
        }
        Map<string,id> marketMap = new Map<string,id>();
        For(Market__c mrk: [select id,Name from Market__c where Name IN: marketNameSet]){
            marketMap.put(mrk.Name, mrk.id);
        }
        system.debug('marketMap::'+marketMap);
        For(Lead ld: newLeadRecordList){
            system.debug('newInsertingRecord::'+ld);
            string phonefieldVal = ld.Phone;
            string firstPhoneVal;
            string secondPhoneVal;
            string descriptionVal = '';
            system.debug('phonefieldVal ::'+phonefieldVal);
            if(phonefieldVal.contains('|')){
                system.debug('if-Condition');
                firstPhoneVal = phonefieldVal.substringBefore('|');
                secondPhoneVal = phonefieldVal.substringAfter('|');
                system.debug('firstPhoneVal ::'+firstPhoneVal);
                system.debug('Phone ::'+ld.Phone);
                if(firstPhoneVal != null){
                    system.debug('substring1 ::'+firstPhoneVal.substring(0, 3));
                    system.debug('substring2 ::'+firstPhoneVal.substring(3, 6));
                    system.debug('substring3 ::'+firstPhoneVal.substringAfter(firstPhoneVal.substring(3, 6)));
                    system.debug('substring4 ::'+firstPhoneVal.substringAfterLast(firstPhoneVal.substring(3, 6)));
                    ld.Phone = '(' + firstPhoneVal.substring(0, 3) + ') ' + firstPhoneVal.substring(3, 6) + '-' + firstPhoneVal.substringAfterLast(firstPhoneVal.substring(3, 6));
                system.debug('PhoneIN ::'+ld.Phone); 
                }
                if(secondPhoneVal != null){
                    descriptionVal += secondPhoneVal;
                }
            }else{
                system.debug('else-Condition');
                ld.Phone = '(' + phonefieldVal.substring(0, 3) + ') ' + phonefieldVal.substring(3, 6) + '-' + phonefieldVal.substringAfter(phonefieldVal.substring(3, 6));
            }
             system.debug('Phone ::'+ld.Phone);
            ld.OwnerId = us.Id;
            ld.LeadSource = 'Zoom Info';
            ld.Status = 'New';
            ld.Date_List_Produced__c = system.today();
            if(marketMap.containsKey(ld.tempMarket__c)){
                ld.Market__c = marketMap.get(ld.tempMarket__c);
            }
            system.debug('descriptionVal '+descriptionVal);
            if(string.isNotBlank(descriptionVal)){
                ld.Description = ld.Description + ',' +'(' + descriptionVal.substring(1, 4) + ') ' + descriptionVal.substring(4, 7) + '-' + descriptionVal.substringAfter(descriptionVal.substring(4, 7));   
            }
            if(ld.Email != null && !ld.Email.contains('.')){
                ld.Email = '';
            }
            if(ld.Email == 'N/A'){
                ld.Email = '';
            }
            if(ld.LastName == null){
                ld.LastName = 'Missing LastName';
            }
        }
    }
}