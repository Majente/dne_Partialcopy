/**************************************************
* Class: AmendmentOpportunityControllerCopy
* Author: Soljit <VW>
* Date: 2019-06-25
* 
****************************************************/
public class AmendmentOpportunityController {
    
    public Id recordId;
    public String siteIdToDelete{get;set;}
    public String sObjectName{get;set;}
    public boolean showOLIList {get;set;}
    public List<SiteWrapper> wrrapperList{get;set;}
    public List<SiteWrapper> selctedAcc{get;set;}
    Public List<SubsWrapper> selectedSubs{get;set;}
    public  Map<ID,OpportunityLineItem> existedSite {get;set;}
    Public Boolean isSel{get;set;}
    Public List<SubsWrapper> subWrapper{get;set;}
    public Opportunity oppRec{get;set;}
    public String proType;
    public Opportunity opport; 
    public Contract contrct; 
    public string contrctId;
    public integer wrapperIndex {get;set;}
    public Boolean noAmend {get;set;}
    public String ProductId;
    Public String PBEId ;
    List<OpportunityLineItem> oliUpdateList;
    Map<String,Decimal> margins;
    Public Decimal marg{get;set;}    
    public Boolean isSelectedErr {get;set;} 
    public Boolean isSelectedError {get;set;}  
    public Decimal maxMargin {get;set;}
    public Decimal minMargin {get;set;}    
    public Set<Id> existingSiteIds {get;set;}
    public Decimal remainingTerm {get;set;}
    public decimal OpportunityMargin {get;set;}
    public decimal OpportunitySPrice {get;set;}
    public decimal OpportunityMSAFee {get;set;}
    public decimal OpportunityDSAFee {get;set;}
    public String fieldValue {get; set;}
     /*********************************************************
    @Name 			: AmendmentOpportunityController
    @Parameters 	: ApexPages.StandardController
    @Reutrn type 	: void
    @Description 	: Constructor
	********************************************************/
    public AmendmentOpportunityController(ApexPages.StandardController stdController){
        contrct = new Contract();
        remainingTerm = 0;
        existingSiteIds = new Set<Id>();
        isSelectedErr = false;
        marg = 0;
        isSel =false;
        showOLIList = false;
        noAmend =false;
        maxMargin =0;
        oppRec = new Opportunity();
        margins = new Map<String,Decimal>();
        subWrapper = new List<SubsWrapper>();
        existedSite = new Map<ID,OpportunityLineItem>();
        wrrapperList = new List<SiteWrapper>();
        recordId = stdController.getRecord().Id;
        oliUpdateList = new  List<OpportunityLineItem>();
        List<Opportunity_Site__C > oppSiteList = new List<Opportunity_Site__C >();
        for( SBQQ__Quote__c quote : [Select Id,SBQQ__MasterContract__c From SBQQ__Quote__c 
                                     Where SBQQ__Opportunity2__c = :recordId Limit 1 ])
        {
            contrctId =  quote.SBQQ__MasterContract__c;
        }
        for(Contract con : [Select Id,StartDate from Contract where SBQQ__Opportunity__c = :recordId OR ID = :contrctId Limit 1]){
            contrct = con;
            contrctId = con.Id;
        }
        
        system.debug('contrct::'+contrct);
        For(Opportunity_Site__C  oppSite :[Select id, Site__c
                                           From Opportunity_Site__C
                                           Where Opportunity__c =:recordId])
        {
            oppSiteList.add(oppSite);
        }
        if(oppSiteList.size() ==0){
            noAmend = TRUE;            
        }
        System.debug('noAmend ::'+noAmend );
        
        showOLI();
        GoForSearch();        
        //checkMaxMargin();
    }
    /*********************************************************
    @Name 			: GoForSearch
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: Show existing site on account
	********************************************************/
    public void GoForSearch(){
        
        Decimal supplierPrice = 0;
        String monthYear;
        String market;
        opport = [Select Supplier_Price__c,Type,Product_of_Choice__c,Margin__c,Month_Year__c,Commodity_Type__c ,Supplier__c,Subscription_Term__c,
                  AccountId,id,Market__c,Selling_Price__c,Flow_Date__c,Account.Primary_Contact__c,Admin_Fee__c,DNE_Admin_Fee__c,recordtype.Name 
                  From opportunity Where id =:recordId limit 1];
      
        
        if(opport.Flow_Date__c < system.today()){
            system.debug('opp Flow Date:::'+opport.Flow_Date__c);
            decimal monthDiff = opport.Flow_Date__c.monthsBetween(system.today());
            Integer daysEnd = Date.daysInMonth(system.today().year(), system.today().month());
            Decimal day_s = opport.Flow_Date__c.day();
            Decimal day_e = system.today().day();
            Decimal factor = 0;
            if(day_s != day_e){
                factor = (day_e - day_s)/daysEnd;
            }       
            remainingTerm = opport.Subscription_Term__c - ( monthDiff + factor ).setScale(2, RoundingMode.HALF_UP);
            System.debug('remainingTerm :: ' + remainingTerm);
        }
        else{
            remainingTerm = opport.Subscription_Term__c;
        }
        String supplier = opport.Supplier__c ;
        supplierPrice = opport.Supplier_Price__c;
        monthYear = opport.Month_Year__c;
        market = opport.Market__c;
        List<Account> accList = new List<Account>();
        for(Account acc :[Select Id,Name,Market__r.Name 
                          From Account Where parentId =:opport.AccountId  ])
	    {  
	         accList.add(acc);           
	    }
        
        //System.debug('accList::'+accList);
        wrrapperList = new List<SiteWrapper>();
        Decimal margin = 0;
        String proCode = '';
        
        Decimal term;
        term = opport.Subscription_Term__c;
        
        for(OpportunityLineItem oli :[	Select Month_Year__c,ProductCode,Quantity,Id,PricebookEntryId,
        								Supplier_Price__c,UnitPrice, Site__c,product2id 
                                      	From OpportunityLineItem 
                                      	Where OpportunityId =:recordId LIMIT 1])
        { 
            margin = oli.UnitPrice;
            proCode = oli.ProductCode;
            ProductId =oli.Product2Id;
            PBEId = oli.PricebookEntryId;
        }
        
        Decimal listPrice = 0;
        Map<Id,List<Price_List__c>> priceListMap = new  Map<Id,List<Price_List__c>>();
        
        String size = ConstantString.SIZE_LARGE;
        String Name = ConstantString.PRODUCT_GAS;
        if(proCode.contains(ConstantString.SMALL_TYPE)){
            size = ConstantString.SMALL_TYPE;
        }
        if(proCode.contains(ConstantString.PRODUCT_ELECTRICITY)){
            Name = ConstantString.PRODUCT_ELECTRICITY;
        }
        System.debug('market:'+ market);
        System.debug('Name:'+ Name);
        System.debug('size:'+ size);
        System.debug('supplier:'+ supplier); 
        
        //margins = PriceListUtility.getMaxMinMargin(market,Name,size,supplier,'Fixed');
        //System.debug('MarginMap::'+margins);
        priceListMap = PriceListUtility.getTodayPriceList(market,Name,size,supplier);
        System.debug('priceListMap::'+priceListMap);
        
        for(List<Price_list__c> plList :priceListMap.values()){
            for(Price_list__c price :plList){
                if(price.Month_Year__c == monthYear && price.Term__c ==String.valueOf(term) ){
                    listPrice = price.List_Price__c;
                }
            }
        }
        //listPrice = CreateQuoteLineUtility.getLatestPrice(proCode,term,supplier,'Fixed',monthYear);
        System.debug('listPrice::'+ listPrice);
        System.debug('existedSite::'+ existedSite);
        
        for(Site__c site : [Select type__c,id,Name,Volume__c,Market__c,Account__c  
                            From Site__c 
                            Where id NOT IN :existingSiteIds and Account__c IN: accList and Market__c =:opport.Market__c and type__c =:opport.Commodity_Type__c ORDER by Name]){
                wrrapperList.add(new SiteWrapper(site,supplierPrice,margin,listPrice));
        }
        system.debug('wrrapperList::'+wrrapperList);
    }
    
    /*********************************************************
    @Name 			: checkMaxMargin
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: Check maximum margin
	********************************************************/
   /* public void checkMaxMargin(){
        System.debug('**** checkMaxMargin : marg '+ marg);
        //Decimal marg = Decimal.valueOf(ApexPages.currentPage().getParameters().get('marg'));
        String pageMessage = ''; 
        if(  margins.get(ConstantString.MARGIN_MAX) == null || margins.get(ConstantString.MARGIN_MIN) == null){
        	return;
        }
        maxMargin = margins.get(ConstantString.MARGIN_MAX);//margins.get(ConstantString.MARGIN_MAX) != null ? margins.get(ConstantString.MARGIN_MAX) : 3;
        minMargin = margins.get(ConstantString.MARGIN_MIN);//margins.get(ConstantString.MARGIN_MIN) != null ? margins.get(ConstantString.MARGIN_MIN) : 1;

        System.debug('maxmargin:'+margins.get(ConstantString.MARGIN_MAX));
        System.debug('minmargin:'+margins.get(ConstantString.MARGIN_MIN));
        for( SiteWrapper wp :wrrapperList){
            
            if(wp.margin > maxmargin || wp.margin <minMargin) 
            {
                isSelectedErr = true;
                wp.isError = true;
                System.debug('inside if marginChosen : '+ wp.margin);
                pageMessage = Label.Margin_must_be_between +minMargin+' and ' + maxmargin;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                return;
            }
            // wrrapperList.add(wp.margin);
        }
        isSelectedErr = false;
        if(marg > 0){
            for( SiteWrapper wp :wrrapperList){
                wp.margin = marg;
                wp.isError = false;    
            }
        }        
        //return;
    }*/
    
    
    /*********************************************************
    @Name 			: Cancel
    @Parameters 	: Void
    @Reutrn type 	: void
    @Description 	: Cancel
	********************************************************/
    public pageReference Cancel(){
        return new pageReference('/'+recordId);
    }
    
    /*********************************************************
    @Name 			: checkSelectedMaxMargin
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: Check selected maximum margin
	********************************************************/
   /* public void checkSelectedMaxMargin(){
        System.debug('**** checkMaxMargin : marg '+ marg);
        //Decimal marg = Decimal.valueOf(ApexPages.currentPage().getParameters().get('marg'));
        String pageMessage = ''; 
        if(  margins.get(ConstantString.MARGIN_MAX) == null || margins.get(ConstantString.MARGIN_MAX) == null){
        	isSelectedError = false;
	        if(marg > 0){
	            for( SiteWrapper wp :wrrapperList){
	                wp.margin = marg;
	                wp.isError = false;    
	            }
	        } 
        	return;
        }
        maxmargin = margins.get(ConstantString.MARGIN_MAX);//margins.get(ConstantString.MARGIN_MAX) != null ? margins.get(ConstantString.MARGIN_MAX) : 3;
        minMargin = margins.get(ConstantString.MARGIN_MIN);//margins.get(ConstantString.MARGIN_MIN) != null ? margins.get(ConstantString.MARGIN_MIN) : 1;
        System.debug('maxmargin:'+ margins.get(ConstantString.MARGIN_MAX));
        System.debug('minmargin:'+ margins.get(ConstantString.MARGIN_MIN));
        for( SiteWrapper wp :selctedAcc){
            
            if(wp.margin > maxmargin || wp.margin <minMargin) 
            {
                isSelectedError = true;
                wp.isError = true;
                System.debug('inside if marginChosen : '+ wp.margin);
                pageMessage = Label.Margin_must_be_between +minMargin+' and ' + maxmargin;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, pageMessage));
                return;
            }
            // wrrapperList.add(wp.margin);
        }
        isSelectedError = false;
        if(marg > 0){
            for( SiteWrapper wp :wrrapperList){
                wp.margin = marg;
                wp.isError = false;    
            }
        }        
        //return;
    }*/
    
    /*********************************************************
    @Name 			: showOLI
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: Show existing OLI on page
	********************************************************/
    public void showOLI(){
        For(SBQQ__Subscription__c sub : [Select Id,Supplier__c,Site__c,SBQQ__Contract__c,SBQQ__Contract__r.Status,site__r.Type__c,
                                         site__r.Market__c,Site__r.name,
                                         IsAmended__c,IsNew__c, SBQQ__Discount__c, SBQQ__ListPrice__c,Annual_Volume__c,
                                         SBQQ__Quantity__c, SBQQ__QuoteLine__c, SBQQ__StartDate__c, SBQQ__QuoteLine__r.SBQQ__Product__c,
                                         SBQQ__SubscriptionEndDate__c, SBQQ__SubscriptionStartDate__c,SBQQ__QuoteLine__r.Supplier_Price__c, 
                                         Adder_Margin__c, DNE_Admin_Fee__c,SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c
                                         From SBQQ__Subscription__c where SBQQ__Contract__c =: contrct.Id AND Site__c != null ORDER by Site__r.name] )
        {    
            System.debug('sub::'+sub);
            system.debug('Annual_Volume__c'+sub.Annual_Volume__c);
            if(sub.SBQQ__QuoteLine__c != null){
                subWrapper.add(new subsWrapper(sub)); 
                existingSiteIds.add(sub.Site__c);
                
            }
        }
        
    /*    Map<Id,OpportunityLineItem > oliSiteMap = new Map<Id,OpportunityLineItem>();
        for(OpportunityLineItem oli :[Select site__r.Id, site__r.Type__c,site__r.Market__c,site__r.Volume__c,
                                      site__r.Unit_of_Measure__c,Opportunity.Subscription_Term__c,
                                      PricebookEntryId,Product2Id,Id,Supplier_Price__c,UnitPrice, Site__c, 
                                      Site__r.name,Quantity,Opportunity.Name,Opportunity.Flow_Date__c 
                                      From OpportunityLineItem 
                                      Where OpportunityId =:recordId 
                                      OR (Opportunity.Main_Opportunity__c =: recordId 
                                          AND Opportunity.RecordType.Name = 'Amendment' AND Opportunity.StageName = 'Activate Change')])
        {
            
            if(!oliSiteMap.containskey(oli.Site__c)){
                oliSiteMap.put(oli.Site__c, oli); 
                showOLIList = true;
            }
            else{
               oliSiteMap.get(oli.Site__c).Quantity += oli.Quantity ; 
            }
            
        }*/
      /*  for(OpportunityLineItem oli : oliSiteMap.values()){
            oli.Quantity /= (oli.Opportunity.Subscription_Term__c/12);
            subWrapper.add(new subsWrapper(oli));
        }*/
        
        System.debug('subWrapper::'+subWrapper);
    }
    /*********************************************************
    @Name 			: AddSelectedOLI
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: Selected OLI on Page
	********************************************************/
    public void AddSelectedOLI(){
        selectedSubs = new List<subsWrapper>();
        for(subsWrapper wr : subWrapper){
             System.debug('wr::'+wr);
             system.debug('isSelected'+wr.isSelected);
             system.debug('annualVolume'+wr.annualVolume);
             system.debug('subOldQuantity'+wr.subOldQuantity);
            if(wr.subOldQuantity == null){
                wr.subOldQuantity = 0;
            }
            system.debug('wr.annualVolume'+wr.annualVolume);
            system.debug('subOldQuantity'+wr.subOldQuantity);
            if(wr.isSelected == true &&  wr.annualVolume != null && wr.subOldQuantity != null ) {
            system.debug('wr.annualVolume##'+wr.annualVolume);
            system.debug('subOldQuantity###'+wr.subOldQuantity);
                selectedSubs.add(wr);
                showOLIList = true;
            }
        }
        System.debug('selectedSubs::'+selectedSubs);
    }
    /*********************************************************
    @Name 			: getStandardPB
    @Parameters 	: 
    @Reutrn type 	: string
    @Description 	: Get pricebook
	********************************************************/
     public static string getStandardPB(){
        For(Pricebook2 pb :[Select id, name 
                            From Pricebook2 Where isStandard = true]){
            if(pb!=null){
                return pb.id;
            }
        }
        return null;
    }
    /*********************************************************
    @Name 			: saveOLI
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: Save edit OLI
	********************************************************/
    public PageReference saveOLI(){
        
        AddSelected();
        AddSelectedOLI();
        system.debug('selctedAccSize'+selctedAcc.size());
        system.debug('selectedSubsSize'+selectedSubs.size());
        if(selctedAcc.size() == 0 && selectedSubs.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.NoSiteSelected));
            return null;            
        }
        fieldValue = oppRec.Commodity_Type__c;
        system.debug('fieldValue'+fieldValue);
        if(fieldValue == null){
            fieldValue = opport.Commodity_Type__c;
        }
        decimal OppSPRice = OpportunitySPrice;
        system.debug('BeforePrice :::'+OppSPRice);
        if(OppSPRice == null || OppSPRice == 0){
            system.debug('opport.Supplier_Price__c'+opport.Supplier_Price__c);
            OppSPRice = opport.Supplier_Price__c;
        }
        decimal OppMPRice = OpportunityMargin;
        system.debug('BeforePrice :::'+OppMPRice);
        if(OppMPRice == null || OppMPRice == 0){
            system.debug('opport.Margin__c'+opport.Margin__c);
            OppMPRice = opport.Margin__c;
        }
        system.debug('OppSPRice'+OppSPRice);
        system.debug('OppMPRice'+OppMPRice);
        system.debug('OpportunityMSAFee'+OpportunityMSAFee);
        system.debug('OpportunityDSAFee'+OpportunityDSAFee);
        
        
        Opportunity opp = new Opportunity();
        system.debug('opport.AccountId ::'+opport.AccountId);
        Account acc = [Select name 
                       From account Where id =: opport.AccountId];
        String stdPB = getStandardPB();
        List<SBQQ__QuoteLine__c> oliList = new  List<SBQQ__QuoteLine__c>();
        Id RecordTypeIdAmendmentOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();

        opp.name = (acc.Name != null?'Amendment Opportunity'+' '+ acc.Name + '-' + String.valueOf(System.today()):'Amendment Opportunity'+ '-' + String.valueOf(System.today())).Left(120);        
        opp.CloseDate = System.today();
        opp.RecordTypeId = RecordTypeIdAmendmentOpp;
        opp.StageName = 'Proposal';
        opp.DNE_Admin_Fee__c = opport.DNE_Admin_Fee__c;
        opp.Main_Opportunity__c = recordId;
        opp.AccountId =opport.AccountId;
        opp.Market__c = opport.Market__c;
        opp.Pricebook2Id =stdPB;
        opp.Supplier__c = opport.Supplier__c;
        SYSTEM.debug('opport.Supplier__c'+opport.Supplier__c);
        opp.Commodity_Type__c = fieldValue;
        opp.Supplier_Price__c = OppSPRice;
        opp.Selling_Price__c = opport.Selling_Price__c;
        //opp.Subscription_Term__c = opport.Subscription_Term__c;
        opp.Subscription_Term__c  = remainingTerm;
        opp.Month_Year__c = opport.Month_Year__c;
        opp.Margin__c = OppMPRice;
        opp.Admin_Fee__c = opport.Admin_Fee__c;
        opp.Product_of_Choice__c = opport.Product_of_Choice__c;
        opp.Monthly_Site_Admin_Fee__c = OpportunityMSAFee;
        opp.Daily_Site_Admin_Fee__c = OpportunityDSAFee;
        opp.Type = opport.Type;
        /*if(opport.Flow_Date__c != null){
            opp.Flow_Date__c = opport.Flow_Date__c;
        }*/
        try{
        	insert opp;
        }catch(Exception e){
            if(e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            System.debug('exception is -->' + e.getMessage());
            return null;
        }
       
        SBQQ__Quote__c insertedQuote = [select id,SBQQ__Opportunity2__c,SBQQ__MasterContract__c from SBQQ__Quote__c where SBQQ__Opportunity2__c=:opp.Main_Opportunity__c];
        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c = opp.id;
        newQuote.SBQQ__Primary__c = true;
        /*if(opport.Flow_Date__c != null){
             newQuote.SBQQ__StartDate__c  = opport.Flow_Date__c;
        }*/
        newQuote.SBQQ__PricebookId__c = stdPB;
        //newQuote.SBQQ__SubscriptionTerm__c = opport.Subscription_Term__c;
        newQuote.margin__c = OppMPRice;
        newQuote.Administration_Fee__c = opp.Admin_Fee__c;
        newQuote.Primary_Contact__c = opp.AccountId != null ? opp.account.Primary_Contact__c : null;
        newQuote.Billing_Contact__c = opp.AccountId != null ? opp.account.Primary_Contact__c : null;
        newQuote.Supplier_Price__c = OppSPRice;
        newQuote.Supplier__c = opp.Supplier__c;
        newQuote.Selling_Price__c = opp.Selling_Price__c; 
        system.debug('contrct::'+contrct);
        system.debug('ContrId^^^'+contrctId);
        if(contrctId != null){
            newQuote.SBQQ__MasterContract__c = contrctId;
            system.debug('Contract###'+newQuote.SBQQ__MasterContract__c);
        }else{
            system.debug('Contract::'+insertedQuote.SBQQ__MasterContract__c);
            newQuote.SBQQ__MasterContract__c = insertedQuote.SBQQ__MasterContract__c;
        }
        try{
        	insert newQuote;
        	system.debug('newQuote'+newQuote);
        }catch(Exception e){
            if(e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            System.debug('exception is -->' + e.getMessage());
            return null;
        }
        
        //SBQQ__QuoteLine__c quoteLine;
        SBQQ__QuoteLine__c quoteLine1;

        Opportunity_Site__c oppSite;
        List<Opportunity_Site__c> oppSiteList = new List<Opportunity_Site__c>();
        System.debug('oliUpdateList.size() ::: ' + oliUpdateList.size());
        System.debug('oliUpdateList ::: ' + oliUpdateList);
        Decimal subTerm = 0;        
        if(remainingTerm != null){
            subTerm = remainingTerm/12;
        }
        Decimal amendedQuantity = 0;
        Decimal ExistingQLISupplierPrice = OpportunitySPrice;
        Decimal ExistingQLIMarginPrice = OpportunityMargin;
        if(selectedSubs != null){
            for(SubsWrapper wrap :selectedSubs){
                if(ExistingQLISupplierPrice == null || ExistingQLISupplierPrice == 0){
                    ExistingQLISupplierPrice = wrap.supplier_Price;
                }
                if(ExistingQLIMarginPrice == null || ExistingQLIMarginPrice == 0){
                    ExistingQLIMarginPrice = wrap.adderMargin;
                }
                quoteLine1 = new SBQQ__QuoteLine__c();
                quoteLine1.Supplier__c = opp.Supplier__c;
                quoteLine1.Market__c = opp.Market__c;
                quoteLine1.Type__c = opp.recordtype.Name;

                quoteLine1.SBQQ__Quote__c = newQuote.id;
                quoteLine1.Site__c = wrap.site.Id;
                quoteLine1.SBQQ__Product__c = wrap.productId;
                //quoteLine1.SBQQ__PricebookEntryId__c = wrap.oli.PricebookEntryId;
                quoteLine1.SBQQ__ListPrice__c = ExistingQLIMarginPrice;
                quoteLine1.Supplier_Price__c = ExistingQLISupplierPrice;
                quoteLine1.SBQQ__Existing__c = true;
                quoteLine1.AnnualVolumeForSite__c = wrap.annualVolume;
                system.debug('AnnualVolumeForSite__c'+quoteLine1.AnnualVolumeForSite__c);
               // quoteLine1.SBQQ__PriorQuantity__c = wrap.oliOldQuantity * (opport.Subscription_Term__c / 12);
                if(wrap.annualVolume - wrap.subOldQuantity == 0){
                    amendedQuantity = wrap.annualVolume;
                }else{
                    amendedQuantity = wrap.annualVolume - wrap.subOldQuantity;
                }
                system.debug('amendedQuantity'+amendedQuantity);
                system.debug('wrap.subRemainingTerm'+wrap.subRemainingTerm);
                if(wrap.subRemainingTerm == null){
                    wrap.subRemainingTerm = 0;
                }
                if(wrap.subRemainingTerm != null){
                    quoteLine1.SBQQ__Quantity__c = amendedQuantity * (wrap.subRemainingTerm/12);
                }
                
                 System.debug('quoteLine1.SBQQ__PriorQuantity__c ::: ' + quoteLine1.SBQQ__PriorQuantity__c);
                 System.debug('amendedQuantity ::: ' + amendedQuantity);
                 System.debug('quoteLine1.SBQQ__Quantity__c ::: ' + quoteLine1.SBQQ__Quantity__c);
                //quoteLine1.SBQQ__Quantity__c = wrap.oli.site__r.Volume__c * subTerm;
			    quoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
				quoteLine1.SBQQ__DefaultSubscriptionTerm__c = opp.Subscription_Term__c;
                quoteLine1.Selling_Price__c = ( ( quoteLine1.Supplier_Price__c != null ? quoteLine1.Supplier_Price__c : 0 ) + ( quoteLine1.SBQQ__ListPrice__c != null ? quoteLine1.SBQQ__ListPrice__c : 0 ) ) * quoteLine1.SBQQ__Quantity__c ;                
                System.debug('amendedQuantity ::: ' + amendedQuantity);
                System.debug('quoteLine1 ::: ' + quoteLine1);  
                system.debug('NewQLIPrice :::$'+quoteLine1.Supplier_Price__c);
            	system.debug('NewQLIMArgin :::$'+quoteLine1.SBQQ__ListPrice__c);
                oliList.add(quoteLine1);

	            oppSite = new Opportunity_Site__c();
	            oppsite.Market__c = opp.Market__c;
	            oppsite.Site__c = wrap.site.Id;
	            oppsite.Opportunity__c = opp.id;
	            // By passing QLI insertion on trigger
	            oppsite.Flag__c = true;
	            oppSiteList.add(oppSite);
            }
        }
        Decimal NewQLISupplierPrice = OpportunitySPrice;
        Decimal NewQLIMarginPrice = OpportunityMargin;
        decimal Monthly_Site_Admin_Fee = opp.Monthly_Site_Admin_Fee__c  * opp.Subscription_Term__c;
        if(opp.Monthly_Site_Admin_Fee__c == null){
            opp.Monthly_Site_Admin_Fee__c = 0;
        }
        if(opp.Daily_Site_Admin_Fee__c == null){
            opp.Daily_Site_Admin_Fee__c = 0;
        }
        if(opp.Subscription_Term__c == null){
            opp.Subscription_Term__c = 0;
        }
        decimal Daily_Site_Admin_Fee = opp.Daily_Site_Admin_Fee__c  * (opp.Subscription_Term__c/12) * 365;
        decimal FinalValue = Monthly_Site_Admin_Fee + Daily_Site_Admin_Fee.setScale(2, RoundingMode.HALF_UP);
        system.debug('FinalValue ::'+FinalValue);
        
        For(SiteWrapper wp :selctedAcc){
            if(NewQLISupplierPrice == null || NewQLISupplierPrice == 0){
                    NewQLISupplierPrice = wp.supplierPrice;
                }
                if(NewQLIMarginPrice == null || NewQLIMarginPrice == 0){
                    NewQLIMarginPrice = wp.margin;
                }
            quoteLine1 = new SBQQ__QuoteLine__c();
            quoteLine1.Supplier__c = opp.Supplier__c;
            quoteLine1.Market__c = opp.Market__c;
            quoteLine1.Type__c = opp.recordtype.Name;
            quoteLine1.SBQQ__Quote__c = newQuote.id;
            quoteLine1.Add_On_Fee__c = FinalValue;
            quoteLine1.Site__c = wp.site.Id;
            quoteLine1.SBQQ__Existing__c = false;
            quoteLine1.SBQQ__Product__c = ProductId;
            quoteLine1.SBQQ__PricebookEntryId__c = PBEId;
            quoteLine1.SBQQ__ListPrice__c = NewQLIMarginPrice;
            quoteLine1.Supplier_Price__c = NewQLISupplierPrice;
            quoteLine1.AnnualVolumeForSite__c = wp.site.Volume__c;
            quoteLine1.SBQQ__Quantity__c = wp.site.Volume__c * subTerm;
            system.debug('SBQQ__Quantity__c'+quoteLine1.SBQQ__Quantity__c);
            quoteLine1.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            quoteLine1.SBQQ__DefaultSubscriptionTerm__c = opp.Subscription_Term__c;
            quoteLine1.Selling_Price__c = ( ( quoteLine1.Supplier_Price__c != null ? quoteLine1.Supplier_Price__c : 0 ) + ( quoteLine1.SBQQ__ListPrice__c != null ? quoteLine1.SBQQ__ListPrice__c : 0 ) ) * quoteLine1.SBQQ__Quantity__c ;                            
            oliList.add(quoteLine1);
            system.debug('NewquoteLine1 :::'+quoteLine1);  
            system.debug('NewQLIPrice :::$'+quoteLine1.Supplier_Price__c);
            system.debug('NewQLIMArgin :::$'+quoteLine1.SBQQ__ListPrice__c);
            oppSite = new Opportunity_Site__c();
            oppsite.Market__c = opp.Market__c;
            oppsite.Site__c = wp.site.id;
            oppsite.Opportunity__c = opp.id;
            oppsite.Flag__c = true;
            oppSiteList.add(oppsite);
        }

        try{
	        if(oliList.size() >0 ){
	            insert oliList;
                system.debug('oliList'+oliList);
	        }
	        if(oppSiteList.size() > 0){
	            insert oppSiteList;
                system.debug('oppSiteList'+oppSiteList);
	        }            
        }catch(Exception e){
            if(e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            System.debug('exception is -->' + e.getMessage());
            return null;
        }        
        PageReference pr;
        pr = new PageReference('/'+opp.id); 
        pr.setRedirect(true);
        return pr;
    }
    /*********************************************************
    @Name 			: ReturntoOpportunity
    @Parameters 	: 
    @Reutrn type 	: PageReference
    @Description 	: Take back to Opportunity record detail page
	********************************************************/
   /* public PageReference ReturntoOpportunity() {
         PageReference pageRef = new PageReference('/'+recordId);
		 pageRef.setRedirect(true);
        return pageRef;
    }*/

    
    /*********************************************************
    @Name 			: removeOLI
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: Mark quantity is -1 for OLI
	********************************************************/
    /*public void removeOLI(){
        Decimal quan;
        //oliUpdateList = new  List<OpportunityLineItem>();
        System.debug('**** remove wrapperIndex '+wrapperIndex);
        //System.debug('**** index : '+ApexPages.currentPage().getParameters().get('PARAM1'));
        OpportunityLI opplinIt = oppWrapper.get(wrapperIndex);
        quan =opplinIt.oli.Quantity;
        opplinIt.oli.Amend_Quantity__c = -quan;
        oliUpdateList.add(opplinIt.oli);
        Update oliUpdateList;
        oppWrapper.remove(wrapperIndex);
        System.debug('remove oliUpdateList::'+oliUpdateList);
    }*/
    
    /*********************************************************
    @Name 			: saveSites
    @Parameters 	: 
    @Reutrn type 	: PageReference
    @Description 	: Create new amendment opportunity
	********************************************************/
    
   /* public PageReference saveSites(){
       Opportunity opp = new Opportunity();
        try{
        AddSelected();
        checkSelectedMaxMargin();
        System.debug('In SaveSite method isSelectedError::'+isSelectedError);
        
        if(isSelectedError){
            return null;
        }
        Account acc = [Select name 
                       From account Where id =: opport.AccountId];
        String stdPB = getStandardPB();
        List<SBQQ__QuoteLine__c> oliList = new  List<SBQQ__QuoteLine__c>();
        Double maxMargin = 0;
        // Get Highest Margin
        For(SiteWrapper wp :selctedAcc){
            if(wp.margin > maxMargin )
                maxMargin = wp.margin;
        }
        System.debug('In SaveSite method maxMargin::'+maxMargin);
        
        opp.name = acc.Name != null?'Amendment Opportunity'+' '+ acc.Name + '-' + String.valueOf(System.today()):'Amendment Opportunity'+ '-' + String.valueOf(System.today());        
        opp.CloseDate = System.today();
        opp.StageName = 'Qualification';
        opp.Main_Opportunity__c = recordId;
        opp.AccountId =opport.AccountId;
        opp.Market__c = opport.Market__c;
        opp.Pricebook2Id =stdPB;
        opp.Supplier__c = opport.Supplier__c;
        opp.Commodity_Type__c = opport.Commodity_Type__c;
        opp.Supplier_Price__c = opport.Supplier_Price__c;
        opp.Subscription_Term__c = opport.Subscription_Term__c;
        opp.Month_Year__c = opport.Month_Year__c;
        opp.Margin__c = maxMargin;
        if(opport.Flow_Date__c != null){
            opp.Flow_Date__c = opport.Flow_Date__c;
        }            
        insert opp;
        
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Opportunity2__c = opp.id;
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__StartDate__c = System.today();
        newQuote.SBQQ__PricebookId__c = stdPB;
        newQuote.SBQQ__SubscriptionTerm__c = opport.Subscription_Term__c;
        INSERT newQuote;
        
        System.debug('existedSite::'+existedSite);
        
        List<Opportunity_Site__c > siteList = new List<Opportunity_Site__c >();
        Opportunity_Site__c oppSite;
        For(SiteWrapper wp :selctedAcc){
            oppSite = new Opportunity_Site__c();
            oppsite.Market__c = opp.Market__c;
            oppsite.Site__c = wp.site.id;
            oppsite.Opportunity__c = opp.id;
            siteList.add(oppsite);
        }
        if(siteList.size()>0){
            try{ 
                INSERT siteList;
            }catch(Exception ex){
                System.debug(ex.getMessage());
                // return ex.getMessage();
            }
        }
            }
        catch(Exception e){
              if(e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.MailException'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getdmlMessage(0)));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            System.debug('exception is -->' + e.getMessage());
            return null;
        }
        
        
        SBQQ__QuoteLine__c quoteLine;
        For(SiteWrapper wp :selctedAcc){
            quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.SBQQ__Quote__c = newQuote.id;
            quoteLine.Site__c = wp.site.id;
            quoteLine.SBQQ__Product__c = ProductId;
            quoteLine.SBQQ__PricebookEntryId__c = PBEId;
            quoteLine.SBQQ__ListPrice__c = maxMargin;
            if(wp.listPrice>0){
                quoteLine.Supplier_Price__c = wp.listPrice + wp.margin;
            }
            quoteLine.Supplier_Price__c = opport.Supplier_Price__c + wp.margin ;
            quoteLine.Selling_Price__c = (quoteLine.Supplier_Price__c * wp.site.Volume__c * opport.Subscription_Term__c)/12;
            quoteLine.SBQQ__Quantity__c = wp.site.Volume__c;
            oliList.add(quoteLine);
        }
        
        System.debug('oliList::'+oliList);
        if(oliList.size()>0){
            INSERT oliList;
        } 
        PageReference pr;
        pr = new PageReference('/'+opp.id); 
        pr.setRedirect(true);
        return pr; 
    }*/
    
    /*********************************************************
    @Name 			: AddSelected
    @Parameters 	: 
    @Reutrn type 	: void
    @Description 	: Selected records in pop-up
	********************************************************/
    public void AddSelected(){
        isSel=false;
        selctedAcc = new List<SiteWrapper>();
        for(SiteWrapper wr : wrrapperList){
            if(wr.isSelected == true){
                selctedAcc.add(wr);
                proType = wr.site.Type__c;
                isSel = true;
            }
        }
        //checkSelectedMaxMargin();
        System.debug('isSel:'+isSel);
    }
    
    /*********************************************************
    @Name 			: deleteSiteMethod
    @Parameters 	: Void
    @Reutrn type 	: void
    @Description 	: Delete Sites
    ********************************************************/
   /* public void deleteSiteMethod(){
        String indexParam = Apexpages.currentPage().getParameters().get('indexParam');
        System.debug('siteIdToDelete = '+siteIdToDelete+'  recordId = '+ recordId+'  indexParam = '+indexParam);
        try{
            Delete [Select id from Opportunity_Site__c where Site__c =: siteIdToDelete AND Opportunity__c =: recordId limit 1];  
        }catch(Exception ex){
            System.debug('Exception: '+ ex.getMessage());
        }
    }*/
    
    /*********************************************************
    @Name 			: SiteWrapper
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: Wrapper class for Sites
	********************************************************/
    //Wrapper class for Sites
    public class SiteWrapper {
        public Site__c site{get;set;}
        public Boolean isSelected{get;set;}
        //public Boolean isExist{get;set;}
        public Decimal supplierPrice{get;set;}
        public Decimal margin {get;set;}
        public Decimal listPrice {get;set;}
        public OpportunityLineItem oli{get;set;}
        public Decimal maxMarg {get;set;}
        public Boolean isError {get;set;}
        public SiteWrapper(Site__c si,Decimal sp,Decimal marg,Decimal lstprice) {            
            margin = marg;
            supplierPrice = sp;
            site = si;
            listPrice = lstprice;
            isSelected = false;
            isError = false;
           // this.isExist = isExist;
        }  
    }
    /*********************************************************
    @Name 			: OpportunityLI
    @Parameters 	: 
    @Reutrn type 	: 
    @Description 	: wrapper class for OLI
	********************************************************/
    //
    public class SubsWrapper{
        public SBQQ__Subscription__c sub{get;set;}
        public Site__c site{get;set;}
        public Decimal subOldQuantity{get;set;}
        public Boolean isSelected{get;set;}
        public Decimal subRemainingTerm{get;set;}
       
       
		public Decimal adderMargin{get;set;}
        public Decimal supplier_Price{get;set;}
        public Decimal annualVolume{get;set;}
        public String productId{get;set;}
        
        public SubsWrapper(SBQQ__Subscription__c sub){
            this.sub = sub;
            site = new  Site__c(Id=sub.Site__c);
            site.name = sub.Site__r.name;
            site.Market__c = sub.site__r.Market__c;
            site.Type__c = sub.site__r.Type__c;
            productId = sub.SBQQ__QuoteLine__r.SBQQ__Product__c;
            adderMargin = sub.Adder_Margin__c;
            supplier_Price = sub.SBQQ__QuoteLine__r.Supplier_Price__c;
            annualVolume = sub.Annual_Volume__c;
            //oliOldQuantity = oppLine.site__r.Volume__c;
            subOldQuantity = sub.Annual_Volume__c;
            isSelected = false;
            if(sub.SBQQ__StartDate__c < system.today()){
                
                decimal monthDiff = sub.SBQQ__StartDate__c.monthsBetween(system.today());
                Integer daysEnd = Date.daysInMonth(system.today().year(), system.today().month());
                Decimal day_s = sub.SBQQ__StartDate__c.day();
                Decimal day_e = system.today().day();
                Decimal factor = 0;
                System.debug('sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c ** ' + sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c);
                if(day_s != day_e){
                    factor = (day_e - day_s)/daysEnd;
                }       
                subRemainingTerm = sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c - ( monthDiff + factor ).setScale(2, RoundingMode.HALF_UP);
            }
            else{
                subRemainingTerm = sub.SBQQ__QuoteLine__r.SBQQ__DefaultSubscriptionTerm__c;
            }            
            System.debug('subRemainingTerm ** ' + subRemainingTerm);
        }
        
    }
    
    public Decimal calculateRemainingTerm(Date flowDate, Decimal subscriptionTerm){
        Decimal termRemaining = 0;
        if(flowDate < system.today()){
            system.debug('opp Flow Date:::'+flowDate);
            decimal monthDiff = flowDate.monthsBetween(system.today());
            Integer daysEnd = Date.daysInMonth(system.today().year(), system.today().month());
            Decimal day_s = flowDate.day();
            Decimal day_e = system.today().day();
            Decimal factor = 0;
            if(day_s != day_e){
                factor = (day_e - day_s)/daysEnd;
            }       
            termRemaining = subscriptionTerm - ( monthDiff + factor ).setScale(2, RoundingMode.HALF_UP);
            System.debug('termRemaining :: ' + termRemaining);
        }
        else{
            termRemaining = subscriptionTerm;
        }
        return termRemaining;
    }
    
}