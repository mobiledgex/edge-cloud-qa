*** Settings ***
Documentation  RunConsole with OperatorManager/OperatorContributer/OperatorViewer

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

#Test Setup      Setup
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
${mex_password}=  ${mexadmin_password}
	
*** Test Cases ***
# ECQ-2071
RunConsole - OperatorManager shall not be able to do RunConsole
    [Documentation]
    ...  execute RunConsole as OperatorManager
    ...  verify error is received

    #EDGECLOUD-1446 RunConsole for unauthorized user returns "Forbidden, Forbidden"

    #Adduser Role  username=${username_epoch}  role=OperatorManager  #orgname=${docker_image_developer}

    ${token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=${app_name_automation}  developer_org_name=${developer_org_name_automation}

    log to console  ${error}

    Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}') 

    #Should Contain  ${error}  runCommand failed with stderr:Error: Forbidden, Forbiddenxxx

# ECQ-2072
RunConsole - OperatorContributor shall not be able to do RunConsole
    [Documentation]
    ...  execute RunConsole as OperatorContributor
    ...  verify error is received

    #EDGECLOUD-1446 RunConsole for unauthorized user returns "Forbidden, Forbidden"

    #Adduser Role  username=${username_epoch}  role=OperatorContributor  #orgname=${docker_image_developer}

    ${token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=${app_name_automation}  developer_org_name=${developer_org_name_automation}

    log to console  ${error}

    Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

    #Should Contain  ${error}  Error: Forbidden (403), code=403, message=Forbidden

    #Should Contain  ${error}  runCommand failed with stderr:Error: Forbidden, Forbiddenxxx

# ECQ-2073
RunConsole - OperatorViewer shall not be able to do RunConsole
    [Documentation]
    ...  execute RunConsole as OperatorViewer
    ...  verify error is received

    #EDGECLOUD-1446 RunConsole for unauthorized user returns "Forbidden, Forbidden"	

    #Adduser Role  username=${username_epoch}  role=OperatorViewer  #orgname=${docker_image_developer}

    ${token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

    ${error}=  Run Keyword And Expect Error  *  Run Console  region=US  app_name=${app_name_automation}  developer_org_name=${developer_org_name_automation} 

    log to console  ${error}

    Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

    #Should Contain  ${error}  Error: Forbidden (403), code=403, message=Forbidden

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

#    Skip Verify Email
#    Create User  username=${username_epoch}  password=${password}  email_address=${email}
#    Unlock User
#    #Verify Email

#    Set Suite Variable  ${username_epoch}

Teardown
    Cleanup Provisioning
    Login  username=mexadmin  password=${mex_password}

