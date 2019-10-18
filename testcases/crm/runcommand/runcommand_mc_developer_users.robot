*** Settings ***
Documentation  RunCommand for DeveloperManager/DeveloperContributor/DeveloperViewer

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

Test Setup      Setup
Test Teardown   Teardown 

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${test_timeout_crm}  15 min

${operator_name}  dmuus
${cloudlet_name}  tmocloud-1

${username}=   mextester06
${password}=   mextester06123
#${email}=      mextester06@gmail.com
	
*** Test Cases ***
RunCommand - DeveloperManager shall be able to do RunCommand
    [Documentation]
    ...  execute Run Command as DeveloperManager
    ...  verify RunCommand is successful

    Adduser Role  username=${username_epoch}  role=DeveloperManager

    ${token}=  Login

    ${stdout}=  Run Command  region=US  command=whoami

    Should Be Equal  ${stdout}  root\r\n

RunCommand - DeveloperContributor shall be able to do RunCommand
    [Documentation]
    ...  execute Run Command as DeveloperContributor
    ...  verify RunCommand is successful

    Adduser Role  username=${username_epoch}  role=DeveloperContributor

    ${token}=  Login

    ${stdout}=  Run Command  region=US  command=whoami

    Should Be Equal  ${stdout}  root\r\n

RunCommand - DeveloperViewer shall not be able to do RunCommand
    [Documentation]
    ...  execute RunCommand as DeveloperViewer
    ...  verify error is received

    #EDGECLOUD-1446 RunCommand for unauthorized user returns "Forbidden, Forbidden"	

    Adduser Role  username=${username_epoch}  role=DeveloperViewer

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  command=whoami

    log to console  ${error}

    Should Contain  ${error}  runCommand failed with stderr:Error: Forbidden, Forbiddenxxx

*** Keywords ***
Setup
    Create Org  orgtype=developer
    
    Create Flavor  region=US
    Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create App  region=US 
    Create App Instance  region=US  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    ${epoch}=  Get Time  epoch
    ${username_epoch}=  Catenate  SEPARATOR=  ${username}  ${epoch}
    ${email}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com

    Create User  username=${username_epoch}  password=${password}  email_address=${email}
    Unlock User
    Verify Email

    Set Suite Variable  ${username_epoch}

Teardown
    Cleanup Provisioning
    Login  username=mexadmin  password=mexadmin123
