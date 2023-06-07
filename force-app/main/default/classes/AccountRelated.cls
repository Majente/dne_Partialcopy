public class AccountRelated {
    
   public static void myMethod()
    {
        for ( ChildRelationship r: Account.SObjectType.getDescribe().getChildRelationships() ) 
        {
            system.debug('Account related Object : ' +string.valueOf( r.getChildSObject() ) );  
        }
    }
}