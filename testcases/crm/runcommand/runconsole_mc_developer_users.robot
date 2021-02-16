*** Settings ***
Documentation  RunConsole for DeveloperManager/DeveloperContributor/DeveloperViewer

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
${developer}=   automation_dev_org
${mex_password}=  ${mexadmin_password}
	
*** Test Cases ***
# ECQ-2068
RunConsole - DeveloperManager shall be able to do RunConsole
    [Documentation]
    ...  execute Run Console as DeveloperManager
    ...  verify RunConsole is successful

    Adduser Role  username=${username_epoch}  role=DeveloperManager  orgname=${developer}

    ${token}=  Login

#    ${stdout}=  Run Console  region=US  app_name=app1587252144-180521  app_version=1.0  developer_org_name=MobiledgeX  cluster_instance_name=cluster1587252144-180521  operator_org_name=dmuus  cloudlet_name=tmocloud-1  command=whoami

    ${stdout}=  Run Console  region=US  developer_org_name=${developer}  operator_org_name=dmuus  cloudlet_name=tmocloud-1
    Should Contain  ${stdout['console']['url']}  https://127.0.0.1
    Should Contain  ${stdout['console']['url']}  token=xyz 

# ECQ-2069
RunConsole - DeveloperContributor shall be able to do RunConsole
    [Documentation]
    ...  execute Run Console as DeveloperContributor
    ...  verify RunConsole is successful

    Adduser Role  username=${username_epoch}  role=DeveloperContributor  orgname=${developer}

    ${token}=  Login

    ${stdout}=  Run Console  region=US  developer_org_name=${developer}  operator_org_name=dmuus  cloudlet_name=tmocloud-1

    #Should Be Equal  ${stdout['console']['url']}  https://127.0.0.1:39791?token=xyz
    Should Contain  ${stdout['console']['url']}  https://127.0.0.1
    Should Contain  ${stdout['console']['url']}  token=xyz

# ECQ-2070
RunConsole - DeveloperViewer shall not be able to do RunConsole
    [Documentation]
    ...  execute RunConsole as DeveloperViewer
    ...  verify error is received

    #EDGECLOUD-1446 RunConsole for unauthorized user returns "Forbidden, Forbidden"	

    Adduser Role  username=${username_epoch}  role=DeveloperViewer  orgname=${developer}

    ${token}=  Login

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  command=whoami  developer_org_name=${developer}

    Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

*** Keywords ***
Setup
    #Create Org  orgtype=developer
   
    Create Flavor  region=US
    Create App  region=US  image_path=${qcow_centos_image}  access_ports=tcp:2015  deployment=vm  image_type=ImageTypeQCOW  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    Create App Instance  region=US  operator_org_name=dmuus  cloudlet_name=tmocloud-1  #app_name=${app_name_default}  developer_org_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  use_defaults=${False}
 
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
    Login  username=mexadmin  password=${mex_password}
