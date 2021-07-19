*** Settings ***
Documentation  CreateApp with docker compose file  

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet
${operator_name_openstack}  TDG

${docker_compose_iperf}=  http://35.199.188.102/apps/iperf_compose.yml
${region}=  EU

${test_timeout_crm}  15 min

${username}          mextester06
${password}          ${mextester06_gmail_password}
${email}             mextester06@gmail.com


*** Test Cases ***
# ECQ-3163
User shall be able to deploy docker compose file with public docker image
    [Documentation]
    ...  - deploy a public docker image such as networkstatic/iperf3 in a docker compose file
    ...  - verify deployment is successful

    Create App  region=${region}  token=${token}  access_ports=tcp:5201  deployment_manifest=${docker_compose_iperf}  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${orgname}  app_version=1.0   access_type=loadbalancer
    ${appinst}=  Create App Instance  region=${region}  token=${token}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}  developer_org_name=${orgname}  cluster_instance_developer_org_name=${orgname}

    Should Be Equal As Numbers  ${appinst['data']['state']}  5
    Should Be Equal             ${appinst['data']['runtime_info']['container_ids'][0]}  iperf3

*** Keywords ***
Setup
    ${i}=  Get Time  epoch
    ${orgname}=  Catenate  SEPARATOR=  org  ${i}

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

    ${cluster_name_default}=  Get Default Cluster Name

    Create Flavor  region=${region}

    Skip Verify Email
    Create user  username=${username1}  password=${password}  email_address=${email1}  email_check=${False}   #email_check=True
    Unlock User  username=${username1}

    Create Org  orgname=${orgname}  orgtype=developer
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager

    ${token}=  Login  username=${username1}  password=${password}
    Verify Email Via MC  token=${token}

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker  developer_org_name=${orgname}
    Log To Console  Done Creating Cluster Instance

    Set Suite Variable  ${orgname}
    Set Suite Variable  ${token}
    Set Suite Variable  ${cluster_name_default}
Teardown
    Skip Verify Email   skip_verify_email=True
    Cleanup Provisioning
