({
    
    sendEmail:function(component, event, helper) {
        helper.sendHelper(component,event,helper);
    },
    backOnRecord:function(component, event, helper) {
        var ARID = component.get("v.recordId"); 
        sforce.one.navigateToSObject(ARID);
    },
    save:function(component, event, helper){
        var getbody = component.get("v.emailBody"); 
        var action = component.get("c.saveEmailTemplate");
        var tempId = component.get("v.templateId");
        action.setParams({
            'mbody': getbody,
            'tempId':tempId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                sforce.one.showToast({
                    "mode": 'pester',
                    "type": 'success',
                    "title": "Success",
                    "message": 'Email template Saved.'
                });
            }
            
        });
        $A.enqueueAction(action);
    },
    doInit : function(component, event, helper) {
        
        helper.setAttachments(component, event, helper);
        helper.setEmailAddress(component, event, helper);
      //  helper.setAttachmentSigned(component, event, helper);
        
        //var action = component.get("c.setViewStat");    
        var ARID =  component.get("v.recordId");        
        var action = component.get("c.getEmailTemplate");
        //alert(action);
        
        //alert("arid::"+ARID);
        action.setParams({
           'appId':ARID
       });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('email model');
            console.log(state);
            if (state === "SUCCESS") {
                var responseData=response.getReturnValue();
                component.set("v.templateList",responseData);
                console.log('responseData = '+JSON.stringify(responseData));  
                
                var body = responseData[0].HtmlValue;
                var datasubject = responseData[0].Subject;
                var btnValue = responseData[0].Id;
                                
                component.set("v.emailBody", body);
                component.set("v.isOpenTemplate", false);
                component.set("v.subject", datasubject);
                component.set("v.subjectoriginal", datasubject);
                component.set("v.templateId",btnValue);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.body", null);
    },
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event,helper);
        } else {
            alert('Please Select a Valid File');
        }
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    handleRemove: function (cmp, event) {
        var name = event.getParam("item").name;
        //alert(name + ' pill was removed!');
        // Remove the pill from view
        var items = cmp.get('v.pills');
        var item = event.getParam("index");
        items.splice(item, 1);
        
        cmp.set('v.pills', items);
        if(items.length==0){
            cmp.set("v.emailPills",false);
        }
        
    },
    changeEmail:function(cmp, event, helper){
        
        var delimiter = ";";
        var inputText = cmp.find('email').getElement();
        var currentInput = inputText.value;
        
        if (currentInput[currentInput.length - 1] === delimiter || event.keyCode === 13) {
            helper.addNewPills(cmp, helper, currentInput.split(delimiter));
            inputText.value = ''; 
            cmp.set("v.emailPills",true);
        }
        
    },
    changeEmailBlur:function(cmp, event, helper){
        
        var delimiter = ";";
        var inputText = cmp.find('email').getElement();
        var currentInput = inputText.value;
        if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(currentInput))
  		{
        
        //if (currentInput[currentInput.length - 1] === delimiter || event.keyCode === 13) {
        helper.addNewPills(cmp, helper, currentInput.split(delimiter));
        inputText.value = ''; 
        cmp.set("v.emailPills",true);
        //}
        
        
        var pills = cmp.get('v.pills');
        var emails = '' ;
        for (var i = 0; i < pills.length; i++) {
            var emailVal = pills[i].label;
            if(i==0){
                emails = emailVal ;
            }else{
                emails = emails+";" +emailVal ;
            }        	
        }
        if(emails==''){            
            var emailP = cmp.find('emailPContainer');
            $A.util.addClass(emailP, 'errorrequired');
            return false;
        }else{
            var emailP = cmp.find('emailPContainer');
            $A.util.removeClass(emailP, 'errorrequired');
        }
        }
        else
        {	
            sforce.one.showToast({ "type": "error","title": "Error!", "message": "Please Enter Vaild Email Address" });
        		inputText.value = '';
        }
        
    },
    handleRemoveCC: function (cmp, event) {
        var name = event.getParam("item").name;
        //alert(name + ' pill was removed!');
        // Remove the pill from view
        var items = cmp.get('v.ccpills');
        var item = event.getParam("index");
        items.splice(item, 1);
        
        cmp.set('v.ccpills', items);
        if(items.length==0){
            cmp.set("v.ccemailPills",false);
        }
        
    },
    changeCcEmail:function(cmp, event, helper){
        
        var delimiter = ";";
        var inputText = cmp.find('ccemail').getElement();
        var currentInput = inputText.value;
        
        if (currentInput[currentInput.length - 1] === delimiter || event.keyCode === 13) {
            helper.addNewPillsCc(cmp, helper, currentInput.split(delimiter));
            inputText.value = ''; 
            cmp.set("v.ccemailPills",true);
        }
        
        
    },
    changeCcEmailBlur:function(cmp, event, helper){
        
        var delimiter = ";";
        var inputText = cmp.find('ccemail').getElement();
        var currentInput = inputText.value;
        
        //if (currentInput[currentInput.length - 1] === delimiter || event.keyCode === 13) {
        helper.addNewPillsCc(cmp, helper, currentInput.split(delimiter));
        inputText.value = ''; 
        cmp.set("v.ccemailPills",true);
        // }
        
        
    },
    
    
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
        
        helper.setAttachments(component, event, helper);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    likenClose: function(component, event, helper) {
        // Display alert message on the click on the "Like and Close" button from Model Footer 
        // and set set the "isOpen" attribute to "False for close the model Box.
        //alert('thanks for like Us :)');
        component.set("v.isOpen", false);
    },
    setDocumenValue:function(component, event, helper) {  
        
        var btnValue = event.getSource().get("v.checked");         
        var id = event.getSource().get("v.value");            
        var documentIds = component.get("v.documentId"); // event.getSource().get("v.documentId");                        
        
        var index = documentIds.indexOf(id) ;
        if(index>-1){
            documentIds.splice(index,1);
        }
        if(btnValue){
            documentIds.push(id);
        }
        
        component.set("v.documentId",documentIds);
        
        const myCheckboxes = component.find('attachmentDocument'); 
        let chk = (myCheckboxes.length == null) ? [myCheckboxes] : myCheckboxes;
        
        var allchk = true;
        chk.forEach(function(value,key){
            if(value.get('v.checked')){
                
            }else{
                allchk = false;
            }
        });
        component.find('allAttachmentDocument').set('v.checked', allchk);
        
    },
    
    setDocumenValueSigned:function(component, event, helper) {  
        
        var btnValue = event.getSource().get("v.checked");         
        var id = event.getSource().get("v.value");            
        var documentIds = component.get("v.documentId"); // event.getSource().get("v.documentId");                        
        
        var index = documentIds.indexOf(id) ;
        if(index>-1){
            documentIds.splice(index,1);
        }
        if(btnValue){
            documentIds.push(id);
        }
        
        component.set("v.documentId",documentIds);
        
        const myCheckboxes = component.find('attachmentDocumentSigned'); 
        let chk = (myCheckboxes.length == null) ? [myCheckboxes] : myCheckboxes;
        
        var allchk = true;
        chk.forEach(function(value,key){
            if(value.get('v.checked')){
                
            }else{
                allchk = false;
            }
        });
        component.find('allAttachmentDocumentSigned').set('v.checked', allchk);
        
    },
    
    
    openModelTemplate: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpenTemplate", true);
        
        var action = component.get("c.getEmailTemplate");
        var ARID = component.get("v.recordId");
        
        //alert("arid::"+ARID);
        action.setParams({
           'appId':ARID
       });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('email model');
            console.log(state);
            if (state === "SUCCESS") {
                var responseData=response.getReturnValue();
                
                component.set("v.templateList",responseData);
                console.log(responseData);                 
            }
        });
        $A.enqueueAction(action);
    },
    closeModelTemplate: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpenTemplate", false);
    },
    setTemplateValue:function(component, event, helper) {        
        var btnValue = event.getSource().get("v.title");  
        var body = event.getSource().get("v.value");
        var datasubject = event.getSource().get("v.name");
        component.set("v.templateId",btnValue);
        
        console.log("datasubject....."+datasubject);  
        
        component.set("v.emailBody", body);
        component.set("v.isOpenTemplate", false);
        component.set("v.subject", datasubject);
        component.set("v.subjectoriginal", datasubject);
        //alert('body' +body);
        
    },
    onSelectAllChange: function(component, event, helper) {
        helper.handleSelectAllChange(component, event, helper);
    },
    onSelectAllChangeSigned: function(component, event, helper) {
        helper.handleSelectAllChangeSigned(component, event, helper);
    }
})