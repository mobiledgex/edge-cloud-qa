*** Settings ***
Documentation   Docker push/pull with different roles

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library     MexDocker
	
Test Setup	 Setup
Test Teardown    Teardown

*** Variables ***
${username}          mextester99
${password}          ${mextester06_gmail_password}
${email}             mextester99@gmail.com
${mextester99_gmail_password}  rfbixqomqidobmcb
${server}            docker-qa.mobiledgex.net
${app_name}          server_ping_threaded
${app_version}       5.0
${OPorgname}         oporgtester01
${DEVorgname}        jdevorg
${i}                 1
	
*** Test Cases ***

MC - User shall be able to upload docker image as Developer Manager
    [Documentation] 
    ...  create a new user 
    ...  verify docker push/pull doesnt work if locked and unverified
    ...  create a new developer org
    ...  add user to org as Developer Manager
    ...  upload docker image 
    ...  delete the user

    ${i}=  Get Time  epoch
    ${DEVorgname}=  Catenate  SEPARATOR=  ${DEVorgname}  ${i}
 
    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Unlock User  username=${username1}

    # docker push/pull should fail since user is NOT verified
    ${pusherror2}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror2}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror2}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror2}  unauthorized: HTTP Basic: Access denied

    Verify Email
	
    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperManager

    Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

MC - User shall be able to upload docker image as Developer Contributor
    [Documentation] 
    ...  create a new user 
    ...  verify docker push/pull doesnt work if locked and unverified
    ...  create a new developer org
    ...  add user to org as Developer Contributor
    ...  upload docker image 
    ...  delete the user

    ${i}=  Get Time  epoch
    ${DEVorgname}=  Catenate  SEPARATOR=  ${DEVorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Unlock User  username=${username1}

    # docker push/pull should fail since user is NOT verified
    ${pusherror2}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror2}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror2}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror2}  unauthorized: HTTP Basic: Access denied

    Verify Email
	
    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperContributor

    Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

MC - User shall not be able to upload docker image as Developer Viewer
    [Documentation] 
    ...  create a new user 
    ...  create a new developer org
    ...  add user to org as Developer Viewer
    ...  verify cant upload docker image 
    ...  delete the user

    ${i}=  Get Time  epoch
    ${DEVorgname}=  Catenate  SEPARATOR=  ${DEVorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Unlock User  username=${username1}

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Verify Email
	
    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperViewer

    ${error}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${error}  denied: requested access to the resource is denied

    ${pullerror}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version} 

    Should Contain  ${pullerror}  not found

MC - User shall not be able to upload docker image as Operator Manager
    [Documentation] 
    ...  create a new user 
    ...  create a new operator org
    ...  add user to org as Operator Manager
    ...  verify cant upload docker image 
    ...  delete the user

    ${i}=  Get Time  epoch
    ${OPorgname}=  Catenate  SEPARATOR=  ${OPorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}   email_check=True

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Unlock User  username=${username1}

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Verify Email
	
    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorManager

    ${error}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${error}  denied: requested access to the resource is denied

    ${pullerror}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version} 

    Should Contain  ${pullerror}  pull access denied

MC - User shall not be able to upload docker image as Operator Contributor
    [Documentation] 
    ...  create a new user 
    ...  create a new Operator org
    ...  add user to org as Operator Contributor
    ...  verify cant upload docker image
    ...  delete the user

    ${i}=  Get Time  epoch
    ${OPorgname}=  Catenate  SEPARATOR=  ${OPorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Unlock User  username=${username1}

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Verify Email

    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorContributor

    ${error}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version} 

    Should Contain  ${error}  denied: requested access to the resource is denied

    ${pullerror}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${pullerror}  pull access denied

MC - User shall not be able to upload docker image as Operator Viewer
    [Documentation] 
    ...  create a new user 
    ...  create a new Operator org
    ...  add user to org as Operator Viewer
    ...  verify cant upload docker image
    ...  delete the user

    ${i}=  Get Time  epoch
    ${OPorgname}=  Catenate  SEPARATOR=  ${OPorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Unlock User  username=${username1}

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    ${pullerror1}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pusherror1}  unauthorized: HTTP Basic: Access denied
    Should Contain  ${pullerror1}  unauthorized: HTTP Basic: Access denied

    Verify Email
	
    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorViewer

    ${error}=   Run Keyword and Expect Error  *  Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${OPorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${error}  denied: requested access to the resource is denied

    ${pullerror}=   Run Keyword and Expect Error  *  Pull Image From Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    Should Contain  ${pullerror}  pull access denied

*** Keywords ***
Setup
    Pull Image From Docker  username=root  password=sandhill  server=${server}  org_name=mobiledgex  app_name=${app_name}  app_version=${app_version}
    Tag Image               username=root  password=sandhill  server=${server}  app_name=${app_name}  source_name=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0  target_name=server_ping_threaded:5.0

Teardown
    Skip Verify Email   skip_verify_email=True
    Cleanup Provisioning
 
