*** Settings ***
Documentation  ShowLogs with OperatorManager/OperatorContributer/OperatorViewer

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${test_timeout_crm}  15 min

${operator_name}  dmuus
${cloudlet_name}  tmocloud-1

${username}=   mextester06
${password}=   ${mextester06_gmail_password}
#${email}=      mextester06@gmail.com

${docker_image}=  image
${docker_image_developer}=  mobiledgex
	
*** Test Cases ***
# ECQ-1893
ShowLogs - OperatorManager shall not be able to do ShowLogs
    [Documentation]
    ...  execute ShowLogs as OperatorManager
    ...  verify error is received

    #EDGECLOUD-1446 ShowLogs for unauthorized user returns "Forbidden, Forbidden"

    Adduser Role  username=${username_epoch}  role=OperatorManager  #orgname=${docker_image_developer}

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  developer_org_name=${docker_image_developer}

    log to console  ${error}

    Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}')

    #Should Contain  ${error}  runCommand failed with stderr:Error: Forbidden, Forbiddenxxx

# ECQ-1894
ShowLogs - OperatorContributor shall not be able to do ShowLogs
    [Documentation]
    ...  execute ShowLogs as OperatorContributor
    ...  verify error is received

    #EDGECLOUD-1446 ShowLogs for unauthorized user returns "Forbidden, Forbidden"

    Adduser Role  username=${username_epoch}  role=OperatorContributor  #orgname=${docker_image_developer}

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  developer_org_name=${docker_image_developer}

    log to console  ${error}

    Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}') 

    #Should Contain  ${error}  runCommand failed with stderr:Error: Forbidden, Forbiddenxxx

# ECQ-1895
ShowLogs - OperatorViewer shall not be able to do ShowLogs
    [Documentation]
    ...  execute ShowLogs as OperatorViewer
    ...  verify error is received

    #EDGECLOUD-1446 ShowLogs for unauthorized user returns "Forbidden, Forbidden"	

    Adduser Role  username=${username_epoch}  role=OperatorViewer  #orgname=${docker_image_developer}

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Show Logs  region=US  developer_org_name=${docker_image_developer}

    log to console  ${error}

    Should Contain  ${error}  ('code=403', 'error={"message":"Forbidden"}') 

    #Should Contain  ${error}  runCommand failed with stderr:Error: Forbidden, Forbiddenxxx

*** Keywords ***
Setup
    Create Org  orgtype=operator
    
    Create Flavor  region=US
    Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${docker_image_developer}
    Create App  region=US  developer_org_name=${docker_image_developer} 
    Create App Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${docker_image_developer}  cluster_instance_developer_org_name=${docker_image_developer}

    ${epoch}=  Get Time  epoch
    ${username_epoch}=  Catenate  SEPARATOR=  ${username}  ${epoch}
    ${email}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com

    Skip Verify Email
    Create User  username=${username_epoch}  password=${password}  email_address=${email}
    Unlock User
    #Verify Email

    Set Suite Variable  ${username_epoch}

Teardown
    Cleanup Provisioning
    Login  username=mexadmin  password=mexadmin123

