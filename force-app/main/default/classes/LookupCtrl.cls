/**************************************************
* Class: LookupCtrl
* Author: Soljit <VW>
* Date: 2019-06-25
* 
****************************************************/
public class LookupCtrl {

    /**
     * Returns JSON of list of ResultWrapper to Lex Components
     * @objectName - Name of SObject
     * @fld_API_Text - API name of field to display to user while searching
     * @fld_API_Val - API name of field to be returned by Lookup COmponent
     * @lim   - Total number of record to be returned
     * @fld_API_Search - API name of field to be searched
     * @searchText - text to be searched
     * */
     /*********************************************************
    @Name 			: searchDB
    @Parameters 	: String objectName, String fld_API_Text, String fld_API_Val,Integer lim,
					  String fld_API_Search,String searchText, String extraWhereClause
    @Reutrn type 	: String
    @Description 	: 
	********************************************************/
    @AuraEnabled
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val,
            Integer lim,String fld_API_Search,String searchText, String extraWhereClause ){

        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';


        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val;
        query += ' FROM '+objectName;
        query += ' WHERE '+fld_API_Search+' LIKE '+searchText;
        if(String.isNotEmpty(extraWhereClause))
        {
            query += extraWhereClause;
        }
        System.debug('JTM - query = ' + query);

        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();

        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.text = String.valueOf(s.get(fld_API_Text)) ;
            obj.val = String.valueOf(s.get(fld_API_Val))  ;
            lstRet.add(obj);
        }
        return JSON.serialize(lstRet) ;
    }

     /*********************************************************
    @Name 			: ResultWrapper
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: wrapper class for Result
	********************************************************/
    public class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String val{get;set;}
    }
}