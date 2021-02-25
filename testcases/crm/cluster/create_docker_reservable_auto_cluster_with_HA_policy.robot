### ECQ-3181 ###
*** Settings ***
Documentation   Create Dedicated Docker Reservable Cluster and Verify HA works with 1 min active instances

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         MexApp

Test Timeout    ${test_timeout_crm}

Suite Setup      Setup
Suite Teardown  Cleanup

*** Variables ***
${cloudlet_name_openstack_dedicated}  automationDusseldorfCloudlet
${operator_name_openstack}  TDG
${mobiledgex_domain}  mobiledgex.net
${region}      EU
${flavor}  automation_api_flavor
${default_flavor_name}   automation_api_flavor
${cluster_name}  dockerreservable
${docker_image}  docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1
${policy_name}  AutoProvPolicyTest
${app_name}  AutoProvAppDocker
${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***

Create Auto Provisioning Policy
   [Tags]  ReservableCluster

   Log to Console  Create Auto Provisioning Policy

   &{cloudlet1}=  create dictionary  name=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}
   @{cloudletlist}=  create list  ${cloudlet1}

   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  developer_org_name=${orgname}  token=${user_token}  cloudlet_list=${cloudletlist}

   log to console   ${policy_return}

Create App, Add Autoprovisioning Policy and Deploy an App Instance
   [Tags]  ReservableCluster

   @{policy_list}=  Create List  ${policy_name}
   log to console  Creating App and App Instance
   create app  region=${region}  app_name=${app_name}  deployment=docker  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policies=@{policy_list}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}
   sleep  1 minutes
   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}  #cluster_instance_name=${cluster_name}

Delete app instance and verify auto deployment works again
   [Tags]  ReservableCluster

    delete app instance  region=${region}  app_name=${app_name}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    sleep  1 minutes
    Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}  #cluster_instance_name=${cluster_name}

Remove auto provisioning policy from App
   [Tags]  ReservableCluster
    update app  region=${region}  app_name=${app_name}  developer_org_name=${orgname}  auto_prov_policies=@{EMPTY}  app_version=v1  token=${user_token}
    sleep  2 minutes
    app instance should not exist  app_name=${app_name}  region=${region}  app_version=v1  developer_org_name=${orgname}

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
    ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
    ${cluster_name}=  Catenate  SEPARATOR=  ${cluster_name}  ${epoch}
    ${policy_name}=  Catenate  SEPARATOR=  ${policy_name}  ${epoch}
    ${app_name}=  Catenate  SEPARATOR=  ${app_name}  ${epoch}
    ${super_token}=  Get Super Token

    Skip Verify Email  token=${super_token}
    Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
    #Verify Email  email_address=${emailepoch}
    Unlock User
    ${user_token}=  Login  username=${epochusername}  password=${password}

    ${orgname}=  Create Org  token=${user_token}  orgtype=developer
    Set Suite Variable  ${super_token}
    Set Suite Variable  ${user_token}
    Set Suite Variable  ${policy_name}
    Set Suite Variable  ${orgname}
    Set Suite Variable  ${cluster_name}
    Set Suite Variable  ${app_name}


Cleanup
    delete cluster instance  region=${region}  cluster_name=reservable0  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${super_token}

    cleanup provisioning


