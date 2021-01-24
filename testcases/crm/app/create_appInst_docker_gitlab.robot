*** Settings ***
Documentation  CreateApp with docker image 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String
Library  MexDocker

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet
${operator_name_openstack}  TDG

${region}=  EU

${test_timeout_crm}  15 min

${username}          mextester06
${password}          ${mextester06_gmail_password}
${email}             mextester06@gmail.com

${app_name}          server_ping_threaded
${app_version_old}       5.0
${app_version_new}       9.0

*** Test Cases ***
# ECQ-3139
User shall be able to redeploy docker image with same name
    [Documentation]
    ...  - upload a docker image 
    ...  - deploy the app/appinst
    ...  - delete the app/appinst
    ...  - reupload a different verion of the image with the same name
    ...  - deploy the app/appinst again
    ...  - verify the new image is running

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Push Image To Docker  username=${username1}  password=${password}  server=${gitlab_server}  org_name=${orgname}  app_name=${app_name}  app_version=${app_version_old}  gitlab_app_name=${app_name}:99
 
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    ${gitlab_image}=  Set Variable  ${gitlab_server}/${orgname}/images/${app_name}:99

    Create App  region=${region}  access_ports=tcp:2015  image_path=${gitlab_image}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${orgname}  app_version=1.0  auto_delete=${False}
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=${orgname}  cluster_instance_developer_org_name=${orgname}  auto_delete=${False}

    ${version_old}=  Get App Version   ${appinst['data']['uri']}  2015
    Should Be Equal  ${version_old}  pong

    Delete App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=${orgname}  cluster_instance_developer_org_name=${orgname}
    Delete App  region=${region}  developer_org_name=${orgname}

    Push Image To Docker  username=${username1}  password=${password}  server=${gitlab_server}  org_name=${orgname}  app_name=${app_name}  app_version=${app_version_new}  gitlab_app_name=${app_name}:99

    Create App  region=${region}  access_ports=tcp:2015  image_path=${gitlab_image}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${orgname}  app_version=1.0
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=${orgname}  cluster_instance_developer_org_name=${orgname}

    ${version_old}=  Get App Version   ${appinst['data']['uri']}  2015
    Should Be Equal  ${version_old.strip()}  ${app_version_new}

*** Keywords ***
Setup
    ${i}=  Get Time  epoch
    ${orgname}=  Catenate  SEPARATOR=  org  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Pull Image From Docker  username=${gitlab_username}  password=${gitlab_password}  server=${gitlab_server}  org_name=mobiledgex  app_name=${app_name}  app_version=${app_version_old}
    Tag Image               username=${gitlab_username}  password=${gitlab_password}  server=${gitlab_server}  app_name=${app_name}  source_name=${gitlab_server}/mobiledgex/images/${app_name}:${app_version_old}  target_name=${app_name}:${app_version_old}

    Pull Image From Docker  username=${gitlab_username}  password=${gitlab_password}  server=${gitlab_server}  org_name=mobiledgex  app_name=${app_name}  app_version=${app_version_new}
    Tag Image               username=${gitlab_username}  password=${gitlab_password}  server=${gitlab_server}  app_name=${app_name}  source_name=${gitlab_server}/mobiledgex/images/${app_name}:${app_version_new}  target_name=${app_name}:${app_version_new}

    Create Flavor  region=${region}

    Skip Verify Email   
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_check=${False}   #email_check=True  
    Unlock User  username=${username1}
 
    Create Org  orgname=${orgname}  orgtype=developer

    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager

    ${user_token}=  Login  username=${username1}  password=${password}
    Verify Email Via MC  token=${user_token}

    ${cluster_name}=  Get Default Cluster Name
    
    Set Suite Variable  ${orgname}
    Set Suite Variable  ${username1}
    Set Suite Variable  ${email1}

Teardown
    Cleanup Provisioning
