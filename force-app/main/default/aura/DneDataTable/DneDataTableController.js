({
   
    init: function ( cmp, event, helper ) {
       
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'View', name: 'view' } ];


        cmp.set( 'v.mycolumns', [
            { label: 'Opportunity Owner:Full Name', fieldName: 'Owner', type: 'text' },
            { label: 'Account Name', fieldName: 'AccountName', type: 'text' },
            { label: 'Opportunity Name', fieldName: 'Name', type: 'text' },
            {  label: 'PGR', fieldName: '', type: 'text' }
              ]);

        var action = cmp.get( "c.fetchOpportunity" );
        /*action.setParams({
        });*/
        action.setCallback(this, function( response ) {
           
            var state = response.getState();
           
            if ( state === "SUCCESS" ) {
               
                var rows = response.getReturnValue();
               
                for ( var i = 0; i < rows.length; i++ ) {
                   
                    var row = rows[i];
                   
                    if ( row.Account ) {
                        row.AccountName = row.Account.Name;
                    }
                   
                    if ( row.Owner ) {
                        row.Owner = row.Owner.Name;
                    }
                   
                }
               
                cmp.set( "v.oppList", rows );
                console.log( 'opp are ' + cmp.get( "v.oppList" ) );
               
            }
           
        });
        $A.enqueueAction( action );
       
    },

    handleRowAction: function ( cmp, event, helper ) {
       
        var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        var recId = row.Id;

        switch ( action.name ) {
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": recId
                });
                editRecordEvent.fire();
                break;
            case 'view':
                var viewRecordEvent = $A.get("e.force:navigateToURL");
                viewRecordEvent.setParams({
                    "url": "/" + recId
                });
                viewRecordEvent.fire();
                break;
        }
    }
   
})