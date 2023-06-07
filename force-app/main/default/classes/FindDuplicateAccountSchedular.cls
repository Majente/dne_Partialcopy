/**************************************************
* Class: FindDuplicateAccountSchedular
* Author: Gaurav Rathore and Gracy Agarwal
* Date: 2021-12-17
* Description: Schedular class for  FindDuplicateAccountFuzzyMatchBatchTempTest Class
****************************************************/
global class FindDuplicateAccountSchedular implements System.Schedulable{ 
    /*********************************************************
    @Name 			: execute
    @Parameters 	: SchedulableContext
    @Reutrn type 	: void
    @Description 	: instantiate the FindDuplicateAccountFuzzyMatchBatchTemp class
	********************************************************/
    global void execute (System.SchedulableContext SC){
        FindDuplicateAccountFuzzyMatchBatchTemp m = new FindDuplicateAccountFuzzyMatchBatchTemp();
		Database.executeBatch(m,1);
        
        /*******
        Execute Anonymous Window Statements:
        
		FindDuplicateAccountSchedular schedular = new FindDuplicateAccountSchedular() {
        schedular.execute(null); }
		*******/
    }
}