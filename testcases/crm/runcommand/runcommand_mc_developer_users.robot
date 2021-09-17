*** Settings ***
Documentation  RunCommand for DeveloperManager/DeveloperContributor/DeveloperViewer

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

Test Setup      Setup
Test Teardown   Teardown 

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${test_timeout_crm}  15 min

${operator_name}  tmus
${cloudlet_name}  tmocloud-1

${username}=   mextester06
${password}=   ${mextester06_gmail_password}
#${email}=      mextester06@gmail.com

${docker_image}=  image
#${docker_image_developer}=  ${automation_dev_org}
${mex_password}=  ${mexadmin_password}
	
*** Test Cases ***
# ECQ-1567
RunCommand - DeveloperManager shall be able to do RunCommand
    [Documentation]
    ...  execute Run Command as DeveloperManager
    ...  verify RunCommand is successful

#    Adduser Role  username=${username_epoch}  role=DeveloperManager  orgname=${docker_image_developer}

#    ${token}=  Login
     ${token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

#    ${stdout}=  Run Command  region=US  app_name=app1587252144-180521  app_version=1.0  developer_org_name=MobiledgeX  cluster_instance_name=cluster1587252144-180521  operator_org_name=tmus  cloudlet_name=tmocloud-1  command=whoami

    ${stdout}=  Run Command  region=US  command=whoami  developer_org_name=${developer_org_name_automation}

    Should Be Equal  ${stdout}  root\r\n

# ECQ-1568
RunCommand - DeveloperContributor shall be able to do RunCommand
    [Documentation]
    ...  execute Run Command as DeveloperContributor
    ...  verify RunCommand is successful

#    Adduser Role  username=${username_epoch}  role=DeveloperContributor  orgname=${docker_image_developer}

#    ${token}=  Login
     ${token}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

    ${stdout}=  Run Command  region=US  command=whoami  developer_org_name=${developer_org_name_automation}

    Should Be Equal  ${stdout}  root\r\n

# ECQ-1569
RunCommand - DeveloperViewer shall not be able to do RunCommand
    [Documentation]
    ...  execute RunCommand as DeveloperViewer
    ...  verify error is received

    #EDGECLOUD-1446 RunCommand for unauthorized user returns "Forbidden, Forbidden"	

#    Adduser Role  username=${username_epoch}  role=DeveloperViewer  orgname=${docker_image_developer}

#    ${token}=  Login
     ${token}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

    ${error}=  Run Keyword And Expect Error  *  Run Command  region=US  command=whoami  developer_org_name=${developer_org_name_automation}

    Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

*** Keywords ***
Setup
    #Create Org  orgtype=developer
    
    Create Flavor  region=US
    Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_org_name_automation}
    Create App  region=US   image_path=${docker_image}  developer_org_name=${developer_org_name_automation}
    Create App Instance  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_org_name_automation}  cluster_instance_developer_org_name=${developer_org_name_automation}

#    ${epoch}=  Get Time  epoch
#    ${username_epoch}=  Catenate  SEPARATOR=  ${username}  ${epoch}
#    ${email}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
#
#    Skip Verify Email
#    Create User  username=${username_epoch}  password=${password}  email_address=${email}
#    Unlock User
#    #Verify Email
#
#    Set Suite Variable  ${username_epoch}

Teardown
    Cleanup Provisioning
    Login  username=mexadmin  password=${mex_password}
