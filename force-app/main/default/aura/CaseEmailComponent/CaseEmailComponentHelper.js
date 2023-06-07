({
    
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
    
    sendHelper: function(component, event,helper) {
        
        var pills = component.get('v.pills');
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
            var emailP = component.find('emailPContainer');
            $A.util.addClass(emailP, 'errorrequired');
            return false;
        }else{
            var emailP = component.find('emailPContainer');
            $A.util.removeClass(emailP, 'errorrequired');
        }
        //var getEmail = component.get("v.email");
        var getEmail = emails
        console.log(getEmail);
        var ccpills = component.get('v.ccpills');
        var ccemails = '' ;
        for (var i = 0; i < ccpills.length; i++) {
            var ccemailVal = ccpills[i].label;
            if(i==0){
                ccemails = ccemailVal ;
            }else{
                ccemails = ccemails+";" +ccemailVal ;
            }        	
        }
        
        //var ccEmail = component.get("v.ccemail");
        var ccEmail = ccemails;
        console.log(ccEmail);
        
        var getSubject = component.get("v.subject");
        
        if(getSubject==''){
			getSubject = component.get("v.subjectoriginal");  
        }
        
        
       // var getbody = component.get("v.body");  
        var getbody = component.get("v.emailBody");    
        if(getbody==''){            
            var emailbody = component.find('emailbody');
            $A.util.addClass(emailbody, 'errorrequired');
            return false;
        }else{
            var emailbody = component.find('emailbody');
            $A.util.removeClass(emailbody, 'errorrequired');
        }
        
        var attachmentName = component.get("v.attachmentName");
        var documentID = component.get("v.documentId");
        var templateId = component.get("v.templateId");
        
        
        // call the server side controller method 	
        var action = component.get("c.sendMailMethod");
        // set the 3 params to sendMailMethod method   
        // 
        var ARID = component.get("v.recordId");
        
        var Email_Sent_Success_message = $A.get("$Label.c.Email_Sent_Success_message");
        
        action.setParams({
            'mMail': getEmail,
            'ccEmail': ccEmail,
            'mSubject': getSubject,
            'mbody': getbody,
            'attachmentName':attachmentName,
            'documentID':documentID,
            'templateId':templateId,
            'recordid':ARID
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                sforce.one.showToast({
                    "mode": 'pester',
                    "type": 'success',
                    "title": "Success",
                    "message": Email_Sent_Success_message
                });
                sforce.one.navigateToSObject(ARID);
            }
 
        });
        $A.enqueueAction(action);
    },
    
   
    
    uploadHelper: function(component, event,helper) {
        // start/show the loading spinner   
        component.set("v.showLoadingSpinner", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("fileId").get("v.files");
        // get the first file using array index[0]  
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
 
        // create a FileReader object 
        var objFileReader = new FileReader();
        // set onload function of FileReader object   
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
 
            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method 
            self.uploadProcess(component, file, fileContents,helper);
        });
 
        objFileReader.readAsDataURL(file);
    },
 
    uploadProcess: function(component, file, fileContents,helper) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '',helper);
    },
 
 
    uploadInChunk: function(component,  file, fileContents, startPosition, endPosition, attachId,helper) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: component.get("v.parentId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion 
                // then call again 'uploadInChunk' method , 
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId,helper);
                } else {
                    component.set("v.attachmentName", attachId);
                    console.log(attachId);
                    //alert('your File is uploaded successfully');
                    component.set("v.showLoadingSpinner", false);
                    
                    helper.sendMailWithAttachment(component, event,helper);
                    
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },
    
    
    sendMailWithAttachment: function(component, event,helper) {
        
        var getEmail = component.get("v.email");
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
            alert('Please Enter valid Email Address');
        } else {
            helper.sendHelper(component, event,helper);
        }
    },
    
    
    addNewPills: function(cmp, helper, values) {
        var pills = cmp.get('v.pills');
        
        for (var i = 0; i < values.length; i++) {
            var trimmedVal = values[i].trim();
            if (trimmedVal !== "") {
                pills.push({                    
                    label: trimmedVal
                    
                });
            }
        }
        console.log(JSON.stringify(pills));
        cmp.set('v.pills', pills);
    },
    
    addNewPillsCc: function(cmp, helper, values) {
        var pills = cmp.get('v.ccpills');
        
        for (var i = 0; i < values.length; i++) {
            var trimmedVal = values[i].trim();
            if (trimmedVal !== "") {
                pills.push({                    
                    label: trimmedVal
                    
                });
            }
        }
        
        cmp.set('v.ccpills', pills);
    },
    
    handleSelectAllChange: function(component, event, helper) {
        var isChecked = false;
        var btnValue = event.getSource().get("v.checked");
        if(btnValue) {
            isChecked = true;
        }
        
        var myCheckboxes = component.find('attachmentDocument'); 
        
        if(myCheckboxes ===undefined){
            
        }else{    
            
            let chk = (myCheckboxes.length == null) ? [myCheckboxes] : myCheckboxes;
            chk.forEach(checkbox => checkbox.set('v.checked', isChecked));
            //component.set("v.documentId","");
            var documentIds = component.get("v.documentId");
            //var myCheckboxes2 = component.find('attachmentDocument'); 
            var id ='' ;
            chk.forEach(function(value2,key2){             
                if(isChecked){
                    var id = value2.get("v.value");
                    var index = documentIds.indexOf(id) ;
                    if(index>-1){
                        documentIds.splice(index,1);
                    }                    
                    console.log(id);
                    documentIds.push(id);               
                }
            });
        }
    },
    
    handleSelectAllChangeSigned: function(component, event, helper) {
        var isChecked = false;
        var btnValue = event.getSource().get("v.checked");
        if(btnValue) {
            isChecked = true;
        }
        
        var myCheckboxes = component.find('attachmentDocumentSigned'); 
        
        if(myCheckboxes ===undefined){
            
        }else{    
            
            let chk = (myCheckboxes.length == null) ? [myCheckboxes] : myCheckboxes;
            chk.forEach(checkbox => checkbox.set('v.checked', isChecked));
            //component.set("v.documentId","");
            var documentIds = component.get("v.documentId");
            //var myCheckboxes2 = component.find('attachmentDocument'); 
            var id ='' ;
            chk.forEach(function(value2,key2){             
                if(isChecked){
                    
                    var id = value2.get("v.value");
                    console.log("ididid"+id);
                    var index = documentIds.indexOf(id) ;
                    if(index>-1){
                        documentIds.splice(index,1);
                    }
                    console.log(value2.get("v.value"));
                    documentIds.push(id);               
                }
            });
        }
    },
   
    setEmailAddress:function(component, event, helper){
    	var action = component.get("c.getEmails");
        var ARID = component.get("v.recordId");
        
        //alert("arid::"+ARID);
        action.setParams({
           'appId':ARID
       });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData=response.getReturnValue();
                 var pills=[];             
                if(responseData.length > 0){
                    for (var i = 0; i < responseData.length; i++) {
                            var EmailAdd = responseData[i]; // .Email;
                            component.set('v.ContactEmail',EmailAdd);
                         //   alert('ContactEmail --->'+component.get('v.ContactEmail'));
                          pills.push({                    
                    label: EmailAdd
                    
                });
                       
                        }
                  
        console.log(pills);
                     component.set('v.pills',pills);
                    if(pills.length>0){
                     component.set("v.emailPills",true);    
                    }
                    
                     //alert(JSON.stringify(responseData));
                }
              }
        });
        $A.enqueueAction(action);
    },
    setAttachments:function(component, event, helper){
        
        var action = component.get("c.getContentDocument");
        var ARID = component.get("v.recordId");
        
        //alert("arid::"+ARID);
        action.setParams({
           'appId':ARID
       });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseData=response.getReturnValue();
                component.set("v.accountList",responseData);
                if(responseData.length >0){
                    component.set("v.accountListCount",true);
                  //  alert(component.get("v.accountListCount"));
                }else{
                    component.set("v.accountListCount",false);
                }                
            }
        });
        $A.enqueueAction(action);
    },
    
  /*  setAttachmentSigned:function(component, event, helper){
        console.log("setAttachmentSigned");
        var action = component.get("c.getContentDocumentAll");
        var ARID = component.get("v.recordId");
        
        //alert("arid::"+ARID);
        action.setParams({
           'appId':ARID
       });
        action.setCallback(this, function(response) {
            var state = response.getState();                        
            if (state === "SUCCESS") {
                var responseData=response.getReturnValue();                 
                component.set("v.accountListSigned",responseData);
                if(responseData.length >0){
                    component.set("v.accountListCountSigned",true);
                }else{
                    component.set("v.accountListCountSigned",false);
                    var checkbox = component.find('allAttachmentDocumentSigned');                    
                    checkbox.set("v.checked",false);
                    
                } 
                var documentIds = component.get("v.documentId");
                responseData.forEach(function(value2,key2){
                    
                    documentIds.push(value2.Id);                     
                })                              
            }
        });
        $A.enqueueAction(action); 
    }*/
})