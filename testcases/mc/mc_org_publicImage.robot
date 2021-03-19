*** Settings ***
Documentation   Docker push/pull with different roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library     MexDocker
Library  DateTime

Test Setup       Setup
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
# ECQ-3291
MC - User shall not be able to pull docker image from another org
    [Documentation]
    ...  - create user1/org1 and user2/org2
    ...  - user1 pushes docker image
    ...  - user2 pulls the image but gets denied
    ...  - add user2 to org1
    ...  - user2 can pull the image

    ${epoch}=  Get Current Date  result_format=epoch

    ${username1}=  Set Variable  user${epoch}_1
    ${username2}=  Set Variable  user${epoch}_2
    ${orgname}=  Set Variable  org${epoch}
    ${email1}=  Catenate  SEPARATOR=  ${username1}  @gmail.com
    ${email2}=  Catenate  SEPARATOR=  ${username2}  @gmail.com

    # create user1
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}
    Skip Verify Email
    Unlock User  username=${username1}
    ${token}=  Login  username=${username1}  password=${password}
    Verify Email Via MC  token=${token}
    Login Mexadmin
    Create Org  orgname=${orgname}  orgtype=developer
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager
    Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${orgname}  app_name=${app_name}  app_version=${app_version}

    # create user2
    Create user  username=${username2}  password=${password}  email_address=${email2}  email_password=${mextester99_gmail_password}
    Unlock User  username=${username2}
    Skip Verify Email
    ${token}=  Login  username=${username2}  password=${password}
    Verify Email Via MC  token=${token}
    ${org2}=  Catenate  SEPARATOR=  ${orgname}  2 
    Login Mexadmin
    Create Org  orgname=${org2}  orgtype=developer
    Adduser Role  orgname=${org2}  username=${username2}  role=DeveloperManager

    ${pullerror}=  Run Keyword and Expect Error  *  Pull Image From Docker  username=${username2}  password=${password}  server=${server}  org_name=${orgname}  app_name=${app_name}  app_version=${app_version}
    Should Contain  ${pullerror}  denied: requested access to the resource is denied

    Adduser Role  orgname=${orgname}  username=${username2}  role=DeveloperManager
    Pull Image From Docker  username=${username2}  password=${password}  server=${server}  org_name=${orgname}  app_name=${app_name}  app_version=${app_version} 

# ECQ-3292
MC - User shall be able to pull docker image from another org with publicimages 
    [Documentation]
    ...  - create user1/org1 with publicimages=true and user2/org2
    ...  - user1 pushes docker image
    ...  - user2 can pull the image since it is public

    ${epoch}=  Get Current Date  result_format=epoch

    ${username1}=  Set Variable  user${epoch}_1
    ${username2}=  Set Variable  user${epoch}_2
    ${orgname}=  Set Variable  org${epoch}
    ${email1}=  Catenate  SEPARATOR=  ${username1}  @gmail.com
    ${email2}=  Catenate  SEPARATOR=  ${username2}  @gmail.com
    ${orgname}=  Set Variable  org${epoch}

    # create user1
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_password=${mextester99_gmail_password}
    Unlock User  username=${username1}
    ${token}=  Login  username=${username1}  password=${password}
    Verify Email Via MC  token=${token}
    Login Mexadmin
    Create Org  orgname=${orgname}  orgtype=developer  public_images=${True}
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager
    Push Image To Docker  username=${username1}  password=${password}  server=${server}  org_name=${orgname}  app_name=${app_name}  app_version=${app_version}

    # create user2
    Create user  username=${username2}  password=${password}  email_address=${email2}  email_password=${mextester99_gmail_password}
    Unlock User  username=${username2}
    ${token}=  Login  username=${username2}  password=${password}
    Verify Email Via MC  token=${token}
    Login Mexadmin

    ${org2}=  Catenate  SEPARATOR=  ${orgname}  2
    Create Org  orgname=${org2}  orgtype=developer
    Adduser Role  orgname=${org2}  username=${username2}  role=DeveloperManager

    Pull Image From Docker  username=${username2}  password=${password}  server=${server}  org_name=${orgname}  app_name=${app_name}  app_version=${app_version}

*** Keywords ***
Setup
    Pull Image From Docker  username=root  password=sandhill  server=${server}  org_name=mobiledgex  app_name=${app_name}  app_version=${app_version}
    Tag Image               username=root  password=sandhill  server=${server}  app_name=${app_name}  source_name=docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

Teardown
    Cleanup Provisioning

