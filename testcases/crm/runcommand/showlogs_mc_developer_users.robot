*** Settings ***
Documentation  ShowLogs for DeveloperManager/DeveloperContributor/DeveloperViewer

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

Test Setup      Setup
Test Teardown   Teardown 

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${test_timeout_crm}  15 min

${operator_name}  tmus
${cloudlet_name}  tmocloud-1

${username}=   mextester06
${password}=   mextester06123
#${email}=      mextester06@gmail.com

${docker_image}=  image
${docker_image_developer}=  mobiledgex
	
*** Test Cases ***
ShowLogs - DeveloperManager shall be able to do ShowLogs
    [Documentation]
    ...  execute Show Logs as DeveloperManager
    ...  verify ShowLogs is successful

    Adduser Role  username=${username_epoch}  role=DeveloperManager  orgname=${docker_image_developer}

    ${token}=  Login

    ${stdout}=  Show Logs  region=US  developer_org_name=${docker_image_developer}

    Should Be Equal  ${stdout[0]}  here's some logs\r\n 

ShowLogs - DeveloperContributor shall be able to do ShowLogs
    [Documentation]
    ...  execute Show Logs as DeveloperContributor
    ...  verify ShowLogs is successful

    Adduser Role  username=${username_epoch}  role=DeveloperContributor  orgname=${docker_image_developer}

    ${token}=  Login

    ${stdout}=  Show Logs  region=US  developer_org_name=${docker_image_developer}

    Should Be Equal  ${stdout[0]}  here's some logs\r\n 

ShowLogs - DeveloperViewer shall be able to do ShowLogs
    [Documentation]
    ...  execute ShowLogs as DeveloperViewer
    ...  verify ShowLogs is successful

    #EDGECLOUD-1446 ShowLogs for unauthorized user returns "Forbidden, Forbidden"	

    Adduser Role  username=${username_epoch}  role=DeveloperViewer  orgname=${docker_image_developer}

    ${token}=  Login

    ${stdout}=  Show Logs  region=US  developer_org_name=${docker_image_developer}

    Should Be Equal  ${stdout[0]}  here's some logs\r\n

*** Keywords ***
Setup
    #Create Org  orgtype=developer
    
    Create Flavor  region=US
    Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${docker_image_developer}
    Create App  region=US   image_path=${docker_image}  developer_org_name=${docker_image_developer}
    Create App Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${docker_image_developer}  cluster_instance_developer_org_name=${docker_image_developer}

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
