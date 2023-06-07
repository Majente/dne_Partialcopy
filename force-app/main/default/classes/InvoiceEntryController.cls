public class InvoiceEntryController {
    
    @AuraEnabled
    public static List<sObject> getData(string objName){
        system.debug('objName ::'+objName);
        string query = 'SELECT id,MatchedContract__c,Formula_for_match_with_Contract_c__c,Contract_ID__c,Calculation_Type__c,Reason__c FROM '+objName+' WHERE Matching_Contract__c != null';
        List<sObject> DataList = database.query(query);
        system.debug('DataList ::'+DataList);
        return DataList;
    }
    @AuraEnabled
    public static string ProcessEntry(List<string> SelectedRec){
        system.debug('SelectedRec ::'+SelectedRec);
        string message;
        if(SelectedRec ==  null || SelectedRec.size() == 0){
            message = 'Please select atleast one record!';
            return message;
        }
        set<id> ContractId = new set<id>();
        Map<id,CSV_INVOICE_DATA_TEMP__c> InvoiceMap = new  Map<id,CSV_INVOICE_DATA_TEMP__c>();
        Map<string,string> paymentTypeMap = new Map<string,string>();
        paymentTypeMap.put('50/50 On Flow', '50% Upfront on flow and 50% Residual - Monthly');
        paymentTypeMap.put('50/50 Upfront', '50% Upfront on flow and 50% Residual - Monthly');
        paymentTypeMap.put('On Flow', '100% Residual - Monthly');
        
        List<CSV_INVOICE_DATA_TEMP__c> InvoiceList = [SELECT id,MatchedContract__c,Formula_for_match_with_Contract_c__c,Contract_ID__c,Calculation_Type__c,Reason__c FROM CSV_INVOICE_DATA_TEMP__c WHERE id IN: SelectedRec];
        For(CSV_INVOICE_DATA_TEMP__c Invoice: InvoiceList){
            ContractId.add(Invoice.MatchedContract__c);
            InvoiceMap.put(Invoice.MatchedContract__c, Invoice);
        }
        system.debug('ContractId ::'+ContractId);
        system.debug('InvoiceMap ::'+InvoiceMap);
        List<Contract> contrList = new List<Contract>();
        For(Contract contr: [select id,name,supplier_s_contract_ID__c,Payment_Terms__c from Contract where id IN: ContractId]){
            if(InvoiceMap.containsKey(contr.Id)){
                CSV_INVOICE_DATA_TEMP__c invEntry =  InvoiceMap.get(contr.Id);  
                if(contr.supplier_s_contract_ID__c == null || contr.supplier_s_contract_ID__c == ''){
                    contr.supplier_s_contract_ID__c = invEntry.Contract_ID__c;
                }
                if(contr.Payment_Terms__c == null || contr.Payment_Terms__c == ''){
                    contr.Payment_Terms__c = paymentTypeMap.get(invEntry.Calculation_Type__c);
                }
                contrList.add(contr);
            }
        }
        system.debug('contrList ::'+contrList);
        List<CSV_INVOICE_DATA_TEMP__c> CsvINvoiceList = new List<CSV_INVOICE_DATA_TEMP__c>();
        if(contrList.size()>0){
            try{
                update contrList;
                message = 'Record Processed successfully!';
                
                for(Contract cont: contrList){
                    if(InvoiceMap.containsKey(cont.Id)){
                        CSV_INVOICE_DATA_TEMP__c invEntry =  InvoiceMap.get(cont.Id);
                        invEntry.Matching_Contract__c = null;
                        CsvINvoiceList.add(invEntry);
                    }
                }
            }catch(Exception ex){
                message = ex.getMessage();
            }
            if(CsvINvoiceList.size()>0){
                try{
                    update CsvINvoiceList;
                }catch(Exception ex){
                    message = ex.getMessage();
                }
            }
        }
        return message;
    }
}