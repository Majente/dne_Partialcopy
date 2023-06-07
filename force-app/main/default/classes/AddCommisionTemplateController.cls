/**************************************************
* Class: AddCommisionTemplateController
* Author: Soljit <VW> 
* Date: 2019-06-10
* Description : controller for add commission templates
****************************************************/
public class AddCommisionTemplateController 
{
    private ApexPages.StandardController stdController;
    public final DNE_Commission_Hierarchy__c newTemplate;
    
   /*********************************************************
    @Name           : AddCommisionTemplateController
    @Parameters     : ApexPages.StandardController
    @Reutrn type    : 
    @Description    : Constructor
    ********************************************************/
    public AddCommisionTemplateController(ApexPages.StandardController stdC) 
    {
        this.stdController = stdC;
        newTemplate = new DNE_Commission_Hierarchy__c();
    }

    /*********************************************************
    @Name           : getPicklistsOptions
    @Parameters     : 
    @Reutrn type    : String
    @Description    : get picklist options
    ********************************************************/
    @AuraEnabled
    public static String getPicklistsOptions()
    {        
        String optionMapJSON = '';
        try
        {
            Map<String, List<LightningSelectOption>> mapToSerialize = new Map<String, List<LightningSelectOption>>();

            List<LightningSelectOption> typeOptions = new List<LightningSelectOption>();

            List<String> pkListValues = new List<String>();
            Schema.SObjectType obj = Schema.getGlobalDescribe().get('DNE_Commission_Hierarchy__c');
            Schema.DescribeSObjectResult res = obj.getDescribe();
            Schema.DescribeFieldResult result = res.fields.getMap().get('Type__c').getDescribe();
            List<Schema.PicklistEntry> pkle = result.getPicklistValues();
            for(Schema.PicklistEntry pklVal : pkle)
            {
                //pkListValues.add(pklVal.getLabel());
                typeOptions.add(new LightningSelectOption(pklVal.getLabel(), pklVal.getLabel()));
            }

            mapToSerialize.put('typeOptions', typeOptions);

            optionMapJSON = JSON.serialize(mapToSerialize);

        }
        catch(Exception e)
        {
            System.debug('JTM - AddCommisionTemplateController.getCommissionHierarchyTypes() - ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        System.debug('JTM - AddCommisionTemplateController.getCommissionHierarchyTypes() - optionMapJSON = ' + optionMapJSON);
        return optionMapJSON;
    }
    /*********************************************************
    @Name           : saveCommissionHierarchy
    @Parameters     : DNE_Commission_Hierarchy__c:ch
    @Reutrn type    : String
    @Description    : save commission hierarchy
    ********************************************************/

    @AuraEnabled
    public static String saveCommissionHierarchy(DNE_Commission_Hierarchy__c ch, 
                                                 Id openerId,
                                                 Id level1Id,
                                                 Id level2Id,
                                                 Id level3Id,
                                                 Id level4Id,
                                                 Id level5Id,
                                                 Id level6Id,
                                                 Id level7Id,
                                                 Id level8Id,
                                                 Id level9Id,
                                                 Id level10Id,
                                                 Id level11Id,
                                                 Id level12Id,
                                                 Id level13Id,
                                                 Id level14Id,
                                                 Id level15Id,
                                                 Id level16Id
    )
    {
        System.debug('JTM - ch = ' + ch);
        
        if(openerId == null)
        {
            System.debug('JTM - OPENER required');
            return System.Label.Opener_is_required_label;
        }

        if(ch.Effective_From__c == null)
        {
            System.debug('JTM - EFFECTIVE FROM required');
            return System.Label.Effective_from_field_is_required_label;
        }

        if(level1Id == null)
        {
            System.debug('JTM - LEVEL 1 required');
            return System.Label.Commission_hierarchy_required_label;
        }

        ch.Opener__c = openerId;
        ch.Level_1__c = level1Id;
        ch.Level_2__c = level2Id;
        ch.Level_3__c = level3Id;
        ch.Level_4__c = level4Id;
        ch.Level_5__c = level5Id;
        ch.Level_6__c = level6Id;
        ch.Level_7__c = level7Id;
        ch.Level_8__c = level8Id;
        ch.Level_9__c = level9Id;
        ch.Level_10__c = level10Id;
        ch.Level_11__c = level11Id;
        ch.Level_12__c = level12Id;
        ch.Level_13__c = level13Id;
        ch.Level_14__c = level14Id;
        ch.Level_15__c = level15Id;
        ch.Level_16__c = level16Id;

        try
        {
            insert ch;
            System.debug('JTM - ch.Id = ' + ch.Id);
        }
        catch(Exception e)
        {
            return 'ERROR: ' + e.getMessage();
        }

        String successMessage = Label.SUCCESS_Commission_Hierarchy_created;
        return successMessage;
    }
  
    /*********************************************************
    @Name           : saveCommissionHierarchyList
    @Parameters     : List<DNE_Commission_Hierarchy__c>:chList
    @Reutrn type    : String
    @Description    : save commission hierarchy List
    ********************************************************/
    /*
    @AuraEnabled
    public static String saveCommissionHierarchyList(List<DNE_Commission_Hierarchy__c> chList)
    {
        System.debug('JTM - chList = ' + chList);

        if(chList.isEmpty())
        {
            return 'ERROR: There are no Commission Hierarchies in the list. Please add at least one.';
        }
        
        for(DNE_Commission_Hierarchy__c ch : chList)
        {
            if(ch.Opener__c == null)
            {
                System.debug('JTM - OPENER required');
                return 'ERROR: The Opener is required';
            }

            if(ch.Effective_From__c == null)
            {
                System.debug('JTM - EFFECTIVE FROM required');
                return 'ERROR: The Effective From field is required';
            }

            if(ch.Level_1__c == null)
            {
                System.debug('JTM - LEVEL 1 required');
                return 'ERROR: At least on Level is required for a Commission Hierarchy';
            }
        }

        try
        {
            
            System.debug('JTM - TRYING');
            insert chList;
        }
        catch(Exception e)
        {
            System.debug('JTM - CATCHING');
            return 'ERROR: ' + e.getMessage();
        }
        
        String oneOrMany;
        if(chList.size()==1)
        {
            oneOrMany = ' Commission Hierarchy ';
        }
        else
        {
            oneOrMany = ' Commission Hierarchies ';
        }

        String successMessage = 'SUCCESS: ' + chList.size() + oneOrMany + ' created.';
        return successMessage;
    }
*/
}