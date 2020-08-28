*** Settings ***
Documentation   Docker push/pull with different roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library     MexDocker

Test Setup       Setup
#Test Teardown    Teardown

*** Variables ***
${username}          mextester99
${password}          mextester99123
${email}             mextester99@gmail.com
${mextester99_gmail_password}  rfbixqomqidobmcb
${server}            docker-qa.mobiledgex.net
${app_name}          server_ping_threaded
${app_version}       5.0
${OPorgname}         oporgtester01
${DEVorgname}        jdevorg
${i}                 1

*** Test Cases ***

MC - User shall not be able to pull docker image from another org
    [Documentation]
    ...  create a new user
    ...  verify docker push/pull doesnt work if locked and unverified
    ...  create a new developer org
    ...  add user to org as Developer Manager
    ...  upload docker image
    ...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
    ${email2}=  Catenate  SEPARATOR=  ${username}  +  2  @gmail.com
    ${username2}=  Catenate  SEPARATOR=  ${username}  2 

    # create user1
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}
    Unlock User  username=${username1}
    Verify Email
    Create Org  orgname=${DEVorgname}  orgtype=developer
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperManager
    Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    # create user2
    Create user  username=${username2}  password=${password}  email_address=${email2}  email_password=${mextester99_gmail_password}
    Unlock User  username=${username2}
    Verify Email
    ${org2}=  Catenate  SEPARATOR=  ${DEVorgname}  2 
    Create Org  orgname=${org2}  orgtype=developer
    Adduser Role  orgname=${org2}  username=${username2}  role=DeveloperManager

    ${pullerror}=  Run Keyword and Expect Error  *  Pull Image From Docker  username=${username2}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pullerror}  denied: requested access to the resource is denied

    Adduser Role  orgname=${DEVorgname}  username=${username2}  role=DeveloperManager
    Pull Image From Docker  username=${username2}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version} 

MC - User shall be able to pull docker image from another org with publicimages 
    [Documentation]
    ...  create a new user
    ...  verify docker push/pull doesnt work if locked and unverified
    ...  create a new developer org
    ...  add user to org as Developer Manager
    ...  upload docker image
    ...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
    ${email2}=  Catenate  SEPARATOR=  ${username}  +  2  @gmail.com
    ${username2}=  Catenate  SEPARATOR=  ${username}  2

    # create user1
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}
    Unlock User  username=${username1}
    Verify Email
    Create Org  orgname=${DEVorgname}  orgtype=developer  public_images=${True}
    Adduser Role  orgname=${DEVorgname}  username=${username1}  role=DeveloperManager
    Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

    # create user2
    Create user  username=${username2}  password=${password}  email_address=${email2}  email_password=${mextester99_gmail_password}
    Unlock User  username=${username2}
    Verify Email
    ${org2}=  Catenate  SEPARATOR=  ${DEVorgname}  2
    Create Org  orgname=${org2}  orgtype=developer
    Adduser Role  orgname=${org2}  username=${username2}  role=DeveloperManager

    Pull Image From Docker  username=${username2}  password=${password}  server=${server}  org_name=${DEVorgname}  app_name=${app_name}  app_version=${app_version}

*** Keywords ***
Setup
    Pull Image From Docker  username=root  password=sandhill  server=${server}  org_name=mobiledgex  app_name=${app_name}  app_version=${app_version}
    Tag Image               username=root  password=sandhill  server=${server}  app_name=${app_name}  source_name=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

Teardown
    Cleanup Provisioning

