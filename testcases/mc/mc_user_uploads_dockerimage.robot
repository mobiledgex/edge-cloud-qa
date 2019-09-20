*** Settings ***
Documentation   MasterController user/current superuser

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library     MexDocker
	
#Test Setup	 Setup
Test Teardown    Teardown

*** Variables ***
${username}          mextester99
${password}          mextester99123
${email}             mextester99@gmail.com
${server}            docker-qa.mobiledgex.net
${app_name}          server_ping_threaded
${app_version}       5.0
${OPorgname}         oporgtester01
${DEVorgname}        jdevorg
${i}                 1
	
*** Test Cases ***

MC - User shall be able to create a and upload docker image in different user roles as Developer Manager
	[Documentation] 
	...  create a new user 
	...  create a new developer org
    ...  add user to org as Developer Manager
	...  upload docker image 
	...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
	
    Create user  username=${username1}  password=${password}  email_address=${email1}

    Unlock User  username=${username1}

    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperManager

    Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

MC - User shall be able to create a and upload docker image in different user roles as Developer Contributor
	[Documentation] 
	...  create a new user 
	...  create a new developer org
    ...  add user to org as Developer Contributor
	...  upload docker image 
	...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
	
    Create user  username=${username1}  password=${password}  email_address=${email1}

    Unlock User  username=${username1}

    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperContributor

    Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

MC - User shall be able to create a and upload docker image in different user roles as Developer Viewer
	[Documentation] 
	...  create a new user 
	...  create a new developer org
    ...  add user to org as Developer Viewer
	...  upload docker image 
	...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
	
    Create user  username=${username1}  password=${password}  email_address=${email1}

    Unlock User  username=${username1}

    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperViewer

    ${error}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${error}  denied: requested access to the resource is denied

    ${pullerror}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${pullerror}  not found: manifest unknown: manifest unknown

MC - User shall be able to create a and upload docker image in different user roles as Operator Manager
	[Documentation] 
	...  create a new user 
	...  create a new operator org
    ...  add user to org as Operator Manager
	...  upload docker image 
	...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
	
    Create user  username=${username1}  password=${password}  email_address=${email1}

    Unlock User  username=${username1}

    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorManager

    ${error}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${error}  denied: requested access to the resource is denied

    ${pullerror}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${pullerror}  denied: requested access to the resource is denied

MC - User shall be able to create a and upload docker image in different user roles as Operator Contributor
	[Documentation] 
	...  create a new user 
	...  create a new Operator org
    ...  add user to org as Operator Contributor
	...  upload docker image 
	...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
	
    Create user  username=${username1}  password=${password}  email_address=${email1}

    Unlock User  username=${username1}

    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorContributor

    ${error}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${error}  denied: requested access to the resource is denied

    ${pullerror}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${pullerror}  denied: requested access to the resource is denied

MC - User shall be able to create a and upload docker image in different user roles as Operator Viewer
	[Documentation] 
	...  create a new user 
	...  create a new Operator org
    ...  add user to org as Operator Viewer
	...  upload docker image 
	...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
	
    Create user  username=${username1}  password=${password}  email_address=${email1}

    Unlock User  username=${username1}

    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorViewer

    ${error}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${OPorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${error}  denied: requested access to the resource is denied

    ${pullerror}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${pullerror}  denied: requested access to the resource is denied

*** Keywords ***

Teardown
    Cleanup Provisioning
 
