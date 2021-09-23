### ECQ-2431 ###
*** Settings ***
Documentation   Create K8S Reservable Cluster and Verify Verify HA works with 1 min active instances

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         MexApp

Test Timeout     ${test_timeout_crm}

Suite Setup      Setup
Suite Teardown  Cleanup

*** Variables ***
${cloudlet_name_openstack_dedicated}  automationFrankfurtCloudlet
${operator_name_openstack}  TDG
${mobiledgex_domain}  mobiledgex.net
${region}  US
${flavor}  automation_api_flavor
${default_flavor_name}   automation_api_flavor
${cluster_name}  k8sreservable
${docker_image}  docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1
${policy_name}  AutoProvPolicyTest
${app_name}  AutoProvAppK8S
${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***

Create one k8s and one docker based reservable cluster instnace
   [Documentation]
   ...  create a dedicated reservabe cluster instnace for docer and kubernetes
   ...  verify it creates 1 lb and 2 nodes and 1 master

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  reservable=${True}   cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=kubernetes  flavor_name=${flavor}  developer_org_name=MobiledgeX  token=${super_token}
   Log to Console  DONE creating cluster instance

Create Auto Provisioning Policy

   Log to Console  Create Auto Provisioning Policy
   &{cloudlet1}=  create dictionary  name=${cloudlet_name_openstack_dedicated}  organization=${operator_name_openstack}
   @{cloudletlist}=  create list  ${cloudlet1}
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}   min_active_instances=1  max_instances=1  developer_org_name=${orgname}  token=${user_token}  cloudlet_list=${cloudletlist}
   log to console  ${policy_return}

#Add Cloudlet to Auto Provisioning Policy
#
#   log to console  Add Cloudlet to Auto Provisioning Policy
#   ${add_cloudlet}=  Add Auto Provisioning Policy Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack_dedicated}  policy_name=${policy_name}  developer_org_name=${orgname}  token=${user_token}

Create App, Add Autoprovisioning Polivy and Deploy an App Instance

   @{policy_list}=  Create List  ${policy_name}
   log to console  Creating App and App Instance
   create app  region=${region}  app_name=${app_name}  deployment=kubernetes  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policies=@{policy_list}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}

#   log to console  Registering Client and Finding Cloudlet
#   Register Client  developer_org_name=${orgname}  app_version=v1
#   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
#   Should Contain  ${error_msg}  FIND_NOTFOUND

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}  #cluster_instance_name=${cluster_name}

#   log to console  Send RegisterClient and FindCloudlet to verify AutoProvisioning is Successful
#   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name}
#   ${cloudlet}=  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
#   log to console  Deployed Autoprovision App Successfully!
#
#   Should Be Equal As Numbers  ${cloudlet.status}  1

Delete app instance and verify auto deployment works again

    delete app instance  region=${region}  app_name=${app_name}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1

    Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}  #cluster_instance_name=${cluster_name}

Remove auto provisioning policy from App
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
#    delete app instance  region=${region}  app_name=${app_name}  cluster_instance_name=${cluster_name}  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    cleanup provisioning

