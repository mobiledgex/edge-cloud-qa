*** Settings ***
Documentation   Artifactory curl with different roles

Library	    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library     MexArtifactory
	
#Test Setup	 Setup
Test Teardown    Teardown

*** Variables ***
${username}          mextester99
${password}          ${mextester06_gmail_password}
${email}             mextester99@gmail.com
${mextester99_gmail_password}  rfbixqomqidobmcb
${server}            artifactory-qa.mobiledgex.net
${artifactory_dummy_image_name}        mc_user_uploads_artifactory.robot 
${OPorgname}         oporgtester01
${DEVorgname}        jdevorg
${i}                 1
	
*** Test Cases ***

MC - User shall be able to curl artifactory image as Developer Manager
    [Documentation] 
    ...  create a new user 
    ...  verify artifactory curl doesnt work if locked and unverified
    ...  create a new developer org
    ...  add user to org as Developer Manager
    ...  curl artifactory image 
    ...  delete the user

    [Tags]  Upload

    ${i}=  Get Time  epoch
    ${DEVorgname}=  Catenate  SEPARATOR=  ${DEVorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden 

    Unlock User  username=${username1}

    # curl should fail since user is NOT verified
    ${pusherror2}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror2}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden 

    Verify Email
	
    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperManager

    Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}  

MC - User shall be able to curl artifactory image as Developer Contributor
    [Documentation] 
    ...  create a new user 
    ...  verify artifactory curl doesnt work if locked and unverified
    ...  create a new developer org
    ...  add user to org as Developer Contributor
    ...  curl artifactory image 
    ...  delete the user

    [Tags]  Upload

    ${i}=  Get Time  epoch
    ${DEVorgname}=  Catenate  SEPARATOR=  ${DEVorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name} 
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Unlock User  username=${username1}

    # curl should fail since user is NOT verified
    ${pusherror2}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Verify Email
	
    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperContributor

    Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name} 

MC - User shall not be able to curl artifactory image as Developer Viewer
    [Documentation] 
    ...  create a new user 
    ...  create a new developer org
    ...  add user to org as Developer Viewer
    ...  verify cant curl artifactory image 
    ...  delete the user

    [Tags]  Upload

    ${i}=  Get Time  epoch
    ${DEVorgname}=  Catenate  SEPARATOR=  ${DEVorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Unlock User  username=${username1}

    # docker push/pull should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Verify Email
	
    Create Org  orgname=${DEVorgname}  orgtype=developer
    
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperViewer

    ${error}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

MC - User shall not be able to curl artifactory image as Operator Manager
    [Documentation] 
    ...  create a new user 
    ...  create a new operator org
    ...  add user to org as Operator Manager
    ...  verify cant curl artifactory image 
    ...  delete the user

    [Tags]  Upload

    ${i}=  Get Time  epoch
    ${OPorgname}=  Catenate  SEPARATOR=  ${OPorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Unlock User  username=${username1}

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Verify Email
	
    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorManager

    ${error}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

MC - User shall not be able to curl artifactory image as Operator Contributor
    [Documentation] 
    ...  create a new user 
    ...  create a new Operator org
    ...  add user to org as Operator Contributor
    ...  verify cant curl artifactory image
    ...  delete the user

    [Tags]  Upload

    ${i}=  Get Time  epoch
    ${OPorgname}=  Catenate  SEPARATOR=  ${OPorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Unlock User  username=${username1}

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Verify Email

    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorContributor

    ${error}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

MC - User shall not be able to curl artifactory image as Operator Viewer
    [Documentation] 
    ...  create a new user 
    ...  create a new Operator org
    ...  add user to org as Operator Viewer
    ...  verify cant curl artifactory image
    ...  delete the user

    [Tags]  Upload

    ${i}=  Get Time  epoch
    ${OPorgname}=  Catenate  SEPARATOR=  ${OPorgname}  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Skip Verify Email   skip_verify_email=False	
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}  email_check=True

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

    Unlock User  username=${username1}

    # curl should fail since user is locked
    ${pusherror1}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden
    
    Verify Email
	
    Create Org  orgname=${OPorgname}  orgtype=operator
    
    Adduser Role  orgname=${OPorgname}  username=${username1}  role=OperatorViewer

    ${error}=   Run Keyword and Expect Error  *  Curl Image To Artifactory  username=${username1}  password=${password}  server=${server}  org_name=${OPorgname}  image_name=${artifactory_dummy_image_name}
    Should Contain Any  ${pusherror1}  The requested URL returned error: 401  The requested URL returned error: 403 Forbidden

*** Keywords ***
Setup

Teardown
    Skip Verify Email   skip_verify_email=True
    Cleanup Provisioning
 
