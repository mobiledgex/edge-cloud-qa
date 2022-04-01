### ECQ-2431 ###
*** Settings ***
Documentation   HA Configuration Checks via mcctl
Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         MexApp

Test Setup      Setup
Test Teardown  Cleanup

*** Variables ***
${cloudlet_name_openstack_dedicated}  automationBerlinCloudlet
${operator_name_openstack}  TDG
${mobiledgex_domain}  mobiledgex-qa.net
${region}  EU
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

Create Auto Provisioning Policy with 1 min_active_instances and 1 cloudlet

   Log to Console  Create Auto Provisioning Policy with 1 min_active_instances and 1 cloudlet

   &{cloudlet1}=  create dictionary  name=${cloudlet_name_openstack_ha1}  organization=${operator_name_openstack}
   @{cloudletlist}=  create list  ${cloudlet1}

   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  min_active_instances=1  max_instances=1  developer_org_name=${orgname}  token=${user_token}  cloudlet_list=${cloudletlist}

   log to console   ${policy_return}

Create Auto Provisioning Policy with 2 min_active_instances and 2 cloudlets

  Log to Console  Create Auto Provisioning Policy with 2 min_active_instances and 2 cloudlets
  &{cloudlet1}=  create dictionary  name=${cloudlet_name_openstack_ha1}  organization=${operator_name_openstack}
  &{cloudlet2}=  create dictionary  name=${cloudlet_name_openstack_ha2}  organization=${operator_name_openstack}
  @{cloudletlist}=  create list  ${cloudlet1}  ${cloudlet2}
#  @{cloudletlist}=  create list  ${cloudlet2}

  ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  min_active_instances=2  max_instances=3  developer_org_name=${orgname}  token=${user_token}  cloudlet_list=${cloudletlist}
  log to console   ${policy_return}

Create Auto Provisioning Policy with min_active_instances more than maximum_instances

  Log to Console  Create Auto Provisioning Policy with 1 min_active_instances and 1 cloudlet

   &{cloudlet1}=  create dictionary  name=${cloudlet_name_openstack_ha1}  organization=${operator_name_openstack}
   @{cloudletlist}=  create list  ${cloudlet1}

   ${policy_return}=  Run Keyword And Expect Error  *  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  min_active_instances=2  max_instances=1  developer_org_name=${orgname}  token=${user_token}  cloudlet_list=${cloudletlist}
   should contain  ${policy_return}  Minimum active instances cannot be larger than Maximum Instances
   log to console   ${policy_return}

Create Auto Provisioning Policy with min_active_instances more than number of cloudlets

  Log to Console  Create Auto Provisioning Policy with 1 min_active_instances and 1 cloudlet

  &{cloudlet1}=  create dictionary  name=${cloudlet_name_openstack_ha1}  organization=${operator_name_openstack}
  &{cloudlet2}=  create dictionary  name=${cloudlet_name_openstack_ha2}  organization=${operator_name_openstack}
  @{cloudletlist}=  create list  ${cloudlet1}  ${cloudlet2}

   ${policy_return}=  Run Keyword And Expect Error  *  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  min_active_instances=3  max_instances=4  developer_org_name=${orgname}  token=${user_token}  cloudlet_list=${cloudletlist}
   should contain  ${policy_return}  Minimum Active Instances cannot be larger than the number of Cloudlets

   log to console   ${policy_return}

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
    cleanup provisioning


