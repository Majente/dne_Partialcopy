public class InvoiceEntryProcessBatch implements Database.Batchable<sObject>{
    
    public String Query;
    public string recordId ;
    public InvoiceEntryProcessBatch(){
        Query= 'SELECT id,LDC_Account_Number__c,Reason__c,MatchedContract__c,Formula_for_match_with_Contract_c__c,Contract_ID__c,Calculation_Type__c,Customer_Name__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Term_Months__c,Commodity__c FROM CSV_INVOICE_DATA_TEMP__c WHERE Matching_Contract__c != null';
    }
    public InvoiceEntryProcessBatch(string recId){
        recordId = recId;
        Query= 'SELECT id,LDC_Account_Number__c,Reason__c,MatchedContract__c,Formula_for_match_with_Contract_c__c,Contract_ID__c,Calculation_Type__c,Customer_Name__c,Contract_Start_Date__c,Contract_End_Date__c,Contract_Term_Months__c,Commodity__c FROM CSV_INVOICE_DATA_TEMP__c WHERE id =: recordId';
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<CSV_INVOICE_DATA_TEMP__c> EntryList){
        set<string> SiteIdSet = new set<string>();
        For(CSV_INVOICE_DATA_TEMP__c invoice: EntryList){
            SiteIdSet.add(invoice.LDC_Account_Number__c);
        }
        system.debug('SiteIdSet ::'+SiteIdSet);
        List<Site__c> SiteList = [select id,Name,Account__c,Account__r.ParentId,Account__r.Parent.Name from Site__c where Name IN: SiteIdSet];
        set<id> ParentAccIdSet = new set<id>();
        For(Site__c site: SiteList){
            ParentAccIdSet.add(site.Account__r.ParentId);
        }
        system.debug('ParentAccIdSet ::'+ParentAccIdSet);
        string AccName;
        //List<string> oppList = new List<string>();
        For(Opportunity opp: [select id,Name,AccountId,Account.Name from Opportunity 
                              where AccountId IN: ParentAccIdSet]){
                                  AccName = opp.Account.Name;
                                  //        oppList.add(opp.id);
                              }
        //system.debug('oppList ::'+oppList);
        system.debug('AccName ::'+AccName);
        Map<id,string> SiteMap = new Map<id,string>();
        List<string> oppIds = new List<string>();
        For(Opportunity_Site__c oppSite: [SELECT Id, Name, Site__c,Site__r.Name, Opportunity__c,Opportunity__r.Main_Opportunity__c FROM Opportunity_Site__c WHERE Site__r.Name IN: SiteIdSet]){
            if(oppSite.Opportunity__r.Main_Opportunity__c == null){
                SiteMap.put(oppSite.Opportunity__c,oppSite.Site__r.Name);
            }else{
                SiteMap.put(oppSite.Opportunity__r.Main_Opportunity__c,oppSite.Site__r.Name);
            }
        }
        system.debug('SiteMap ::'+SiteMap);
        for(id oppid: SiteMap.keyset()){
            oppIds.add(oppid);
        }
        system.debug('oppIds ::'+oppIds);
        //  Map<string,List<Contract>> ContractMap = new Map<string,List<Contract>>();
        List<Contract> contrList = new List<Contract>();
        For(Contract Contr: [SELECT Id,EndDate,StartDate,ContractTerm,Account.Name,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Commodity_Type__c,AccountId FROM Contract 
                             WHERE SBQQ__Opportunity__c IN: oppIds]){
                                 //        if(!ContractMap.containsKey(Contr.Account.Name)){
                                 //           ContractMap.put(Contr.Account.Name, new List<Contract>());
                                 //       }
                                 //       ContractMap.get(Contr.Account.Name).add(Contr);
                                 contrList.add(Contr);
                             }
        system.debug('contrList ::'+contrList);
        Map<string,string> commodityMap = new Map<string,string>();
        commodityMap.put('Power','Electricity');
        commodityMap.put('Gas','Gas');
        string ReasonForNotMatch = '';
        List<CSV_INVOICE_DATA_TEMP__c> InvoiceList = new List<CSV_INVOICE_DATA_TEMP__c>();
        /*For(CSV_INVOICE_DATA_TEMP__c invoice: EntryList){
if(AccName.containsAny(invoice.Customer_Name__c)){
system.debug('yes');
if(ContractMap.containsKey(AccName)){
For(Contract contr: ContractMap.get(AccName)){
if(SiteMap.containsKey(contr.SBQQ__Opportunity__c)){
if(contr.SBQQ__Opportunity__r.Commodity_Type__c == commodityMap.get(invoice.Commodity__c)){
if(contr.EndDate == invoice.Contract_End_Date__c){
if(contr.StartDate != invoice.Contract_Start_Date__c){
ReasonForNotMatch += 'StartDateError ,';
}
if(contr.ContractTerm != invoice.Contract_Term_Months__c){
ReasonForNotMatch += 'TermError ,';
} 
if(contr.StartDate == invoice.Contract_Start_Date__c && contr.EndDate == invoice.Contract_End_Date__c &&
contr.ContractTerm == invoice.Contract_Term_Months__c && contr.SBQQ__Opportunity__r.Commodity_Type__c == commodityMap.get(invoice.Commodity__c)){
ReasonForNotMatch += 'RightRecord';
}
invoice.Matching_Contract__c = contr.id;
}   
}

}
}
}
}
ReasonForNotMatch = ReasonForNotMatch.removeEnd(',');
system.debug('ReasonForNotMatch ::'+ReasonForNotMatch);
invoice.Reason__c = ReasonForNotMatch;
InvoiceList.add(invoice);
}*/
        For(CSV_INVOICE_DATA_TEMP__c invoice: EntryList){
            if(AccName.containsAny(invoice.Customer_Name__c)){
                //if(ContractMap.containsKey(AccName)){
                For(Contract contr: contrList){
                    if(SiteMap.containsKey(contr.SBQQ__Opportunity__c)){
                        if(contr.SBQQ__Opportunity__r.Commodity_Type__c == commodityMap.get(invoice.Commodity__c)){
                            if(contr.EndDate == invoice.Contract_End_Date__c){
                                system.debug('contains-5');
                                if(contr.StartDate != invoice.Contract_Start_Date__c){
                                    ReasonForNotMatch += 'StartDateError ,';
                                }
                                if(contr.ContractTerm != invoice.Contract_Term_Months__c){
                                    ReasonForNotMatch += 'TermError ,';
                                } 
                                if(contr.StartDate == invoice.Contract_Start_Date__c && contr.EndDate == invoice.Contract_End_Date__c &&
                                   contr.ContractTerm == invoice.Contract_Term_Months__c && contr.SBQQ__Opportunity__r.Commodity_Type__c == commodityMap.get(invoice.Commodity__c)){
                                       ReasonForNotMatch += 'RightRecord';
                                   }
                                invoice.MatchedContract__c = contr.id;
                            }   
                        }
                        
                        // }
                    }
                }
            }
            ReasonForNotMatch = ReasonForNotMatch.removeEnd(',');
            system.debug('ReasonForNotMatch ::'+ReasonForNotMatch);
            invoice.Reason__c = ReasonForNotMatch;
            InvoiceList.add(invoice);
        }
        system.debug('InvoiceList ::'+InvoiceList);
        if(InvoiceList.size()>0){
            update InvoiceList;
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}