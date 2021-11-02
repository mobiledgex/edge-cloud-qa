*** Settings ***
Documentation  CreateApp with zipped docker compose file  

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexApp
Library  MexArtifactory
Library  String

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet
${operator_name_openstack}  TDG

${developer_org_name}=  MobiledgeX

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0

${docker_compose_zip_url}=  http://35.199.188.102/apps/postgres_redis_compose.zip
${docker_image_path}=   docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_compose_zip}=  postgres_redis_compose.zip
${docker_compose_zip_path}=  crm/app

${region}=  EU

${test_timeout_crm}  15 min

${username}          mextester06
${password}          ${mextester06_gmail_password}
${email}             mextester06@gmail.com

${artifactory_server}            artifactory-qa.mobiledgex.net

*** Test Cases ***
# ECQ-2162
User shall be able to deploy docker compose zip filed from artifactory
    [Documentation]
    ...  create user/org and upload compose zip file to artifactory 
    ...  deploy the app to openstack
    ...  verify containers are running 

    ${docker_compose_zip_full}=  Find File  ${docker_compose_zip}
    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${super_token}=  Get Supertoken

    #Skip Verify Email   skip_verify_email=False
    Skip Verify Email
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_check=${False}   #email_check=True
    Unlock User  username=${username1}
    #Verify Email

    Create Org  orgname=${orgname}  orgtype=developer

    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager

    ${user_token}=  Login  username=${username1}  password=${password}
    Verify Email Via MC  token=${user_token}

    Curl Image To Artifactory  username=${username1}  password=${password}  server=${artifactory_server}  org_name=${orgname}  image_name=${docker_compose_zip_full}

    ${compose_artifactory}=  Set Variable  https://${artifactory_server}/artifactory/repo-${orgname}/${docker_compose_zip}

    Create App  region=${region}  token=${super_token}  access_ports=tcp:8008,tcp:8011  image_path=${docker_image}  deployment_manifest=${compose_artifactory}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0   access_type=loadbalancer
    Create App Instance  region=${region}  token=${super_token}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  developer_org_name=${developer_org_name}  cluster_instance_developer_org_name=${developer_org_name}

    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=redis:latest  node=${server_info_node[0]['Networks']}
    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=postgres:latest  node=${server_info_node[0]['Networks']}

# ECQ-2163
User shall be able to deploy docker compose zip filed from url
    [Documentation]
    ...  create user/org 
    ...  deploy the app with zipped docker compose file to openstack
    ...  verify containers are running

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  access_ports=tcp:8008,tcp:8011  image_path=${docker_image}  deployment_manifest=${docker_compose_zip_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0   access_type=loadbalancer
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  developer_org_name=${developer_org_name}  cluster_instance_developer_org_name=${developer_org_name}

    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=redis:latest  node=${server_info_node[0]['Networks']}
    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=postgres:latest  node=${server_info_node[0]['Networks']}

# ECQ-2270
User shall be able to deploy docker compose zip filed from url with no image_path
    [Documentation]
    ...  create user/org
    ...  deploy the app to openstack with no image_path
    ...  verify containers are running

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  region=${region}  access_ports=tcp:8008,tcp:8011  image_path=no_default  deployment_manifest=${docker_compose_zip_url}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_org_name}  app_version=1.0   access_type=loadbalancer
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  developer_org_name=${developer_org_name}  cluster_instance_developer_org_name=${developer_org_name}

    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=redis:latest  node=${server_info_node[0]['Networks']}
    Wait for docker container to be running  root_loadbalancer=${rootlb}  docker_image=postgres:latest  node=${server_info_node[0]['Networks']}

*** Keywords ***
Setup
    ${i}=  Get Time  epoch
    ${orgname}=  Catenate  SEPARATOR=  org  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    Create Flavor  region=${region}

#    #Skip Verify Email   skip_verify_email=False
#    Skip Verify Email   
#    Create user  username=${username1}  password=${password}  email_address=${email1}  email_check=${False}   #email_check=True  
#    Unlock User  username=${username1}
#    #Verify Email
#    
#    Create Org  orgname=${orgname}  orgtype=developer
#
#    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager
#
#    ${user_token}=  Login  username=${username1}  password=${password}
#    Verify Email Via MC  token=${user_token}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  ip_access=IpAccessDedicated  number_masters=0  number_nodes=0  deployment=docker  developer_org_name=${developer_org_name}
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cluster_name}=  Get Default Cluster Name
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
   
    ${cloudlet_lowercase}=  Convert To Lowercase  ${cloudlet_name_crm}
    ${openstack_node_name}=    Catenate  SEPARATOR=-  docker  vm  ${cloudlet_lowercase}  ${cluster_name}
    ${server_info_node}=    Get Server List  name=${openstack_node_name}
 
    Set Suite Variable  ${rootlb}
    Set Suite Variable  ${orgname}
    Set Suite Variable  ${username1}
    Set Suite Variable  ${email1}
    Set Suite Variable  ${server_info_node}

Teardown
    Skip Verify Email   skip_verify_email=True
    Cleanup Provisioning
