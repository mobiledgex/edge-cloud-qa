*** Settings ***
Documentation  RunConsole for DeveloperContributor with novnc and spice env_vars

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm}

*** Variables ***
${test_timeout_crm}  15 min

${operator_name}  ${operator_name_openstack}
${cloudlet_name}  ${cloudlet_name_openstack}

${username}=   mextester06
${password}=   ${mextester06_gmail_password}
#${email}=      mextester06@gmail.com

${docker_image}=  image
${docker_image_developer}=  mobiledgex
${mex_password}=  ${mexadmin_password}

${region}=  EU

*** Test Cases ***
# ECQ-3123

RunConsole - DeveloperContributor shall be able to do RunConsole with envvar=novnc
    [Documentation]
    ...  execute Run Console as DeveloperContributor
    ...  verify RunConsole is successful


    #Adduser Role  username=${username_epoch}  role=DeveloperContributor  orgname=${developer_org_name_automation}  #orgname=${docker_image_developer}

    ${usertoken}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

    ${stdout}=  update cloudlet  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  env_vars=MEX_CONSOLE_TYPE=novnc  token=${token}
    #${stdout}=  Run Console  region=EU  developer_org_name=${docker_image_developer}  operator_org_name=${operator_name}  cloudlet_name=automationSunnydaleCloudlet
    ${stdout}=  Run Console  region=${region}  developer_org_name=${developer_org_name_automation}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}

    log to console  ${stdout}
    Should Contain  ${stdout['edge_turn_addr']}  edgeturn-qa-eu.mobiledgex.net:6080


#ECQ-3126
RunConsole - DeveloperContributor shall not be able to do RunConsole with envvar=spice
    [Documentation]
    ...  execute Run Console as DeveloperContributor
    ...  verify RunConsole is successful

    #Adduser Role  username=${username_epoch}  role=DeveloperContributor  orgname=${developer_org_name_automation}  #orgname=${docker_image_developer}

    ${usertoken}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

    update cloudlet  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  env_vars=MEX_CONSOLE_TYPE=spice  token=${token}
    ${error}=  Run Keyword And Expect Error  *  Run Console  region=${region}  developer_org_name=${developer_org_name_automation}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}
    log to console  ${error}

    update cloudlet  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  env_vars=MEX_CONSOLE_TYPE=spice  token=${token}
    log to console  Console Back to novnc



*** Keywords ***
Setup
    #Create Org  orgtype=developer

    Create Flavor  region=${region}  ram=4096  vcpus=2  disk=40
    Create App  region=${region}  image_path=https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/cirros-0.5.1-x86_64-disk.img#md5:33622b3106fdb13bfd1de6df4403eec2  access_ports=tcp:8080  deployment=vm  image_type=ImageTypeQCOW  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    Create App Instance  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  #app_name=${app_name_default}  developer_org_name=${developer_name_default}  app_version=${app_version_default}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  use_defaults=${False}

    ${epoch}=  Get Time  epoch
    ${username_epoch}=  Catenate  SEPARATOR=  ${username}  ${epoch}
    ${email}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com

    #Skip Verify Email
    #Create User  username=${username_epoch}  password=${password}  email_address=${email}
    #Unlock User
    #Verify Email
    ${token}=  Get Super Token
    Set Suite Variable  ${token}
    #Set Suite Variable  ${username_epoch}


Teardown
    update cloudlet  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  env_vars=MEX_CONSOLE_TYPE=novnc  token=${token}
    Cleanup Provisioning
    Login  username=mexadmin  password=${mex_password}

