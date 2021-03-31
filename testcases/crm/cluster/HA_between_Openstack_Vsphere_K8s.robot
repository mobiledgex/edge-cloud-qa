### ECQ-2440 ###
*** Settings ***
Documentation   Create Dedicated k8s Reservable Cluster, Delete Cloudlet from Policy and Verify HA between Openstack and Vsphere

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         MexApp

Test Timeout    ${test_timeout_crm} 

Suite Setup      Setup
Suite Teardown  Cleanup

*** Variables ***
${cloudlet1}  packet-qaregression
${cloudlet2}  DFWVMW2
${operator_name_openstack_packet}  packet
${mobiledgex_domain}  mobiledgex.net
${region}      US
${flavor}  automation_api_flavor
${default_flavor_name}   automation_api_flavor
${cluster_name}  k8sreservable
${docker_image}  docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1
${policy_name}  AutoProvPolicyTest
${app_name}  AutoProvAppK8s
${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***

Create k8s based reservable cluster instnace
   [Documentation]
   ...  create a dedicated reservabe k8s cluster instnace

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  reservable=${True}   cluster_name=${cluster_name}  cloudlet_name=${cloudlet1}  operator_org_name=${operator_name_openstack_packet}  ip_access=IpAccessDedicated  deployment=kubernetes  flavor_name=${flavor}  developer_org_name=MobiledgeX  token=${super_token}
   ${cluster_inst}=  Create Cluster Instance  region=${region}  reservable=${True}   cluster_name=${cluster_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator_name_openstack_packet}  ip_access=IpAccessDedicated  deployment=kubernetes  flavor_name=${flavor}  developer_org_name=MobiledgeX  token=${super_token}

   Log to Console  DONE creating cluster instance

Create Auto Provisioning Policy

   Log to Console  Create Auto Provisioning Policy with 1 min active instances and add two cloudlet to the policy

   &{cloudlet1}=  create dictionary  name=packet-qaregression  organization=packet
   &{cloudlet2}=  create dictionary  name=DFWVMW2  organization=packet
   @{cloudletlist}=  create list  ${cloudlet1}  ${cloudlet2}

   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  min_active_instances=1  max_instances=2  developer_org_name=${orgname}  token=${user_token}  cloudlet_list=${cloudletlist}

   log to console   ${policy_return}

Create App, Add Autoprovisioning Policy and Deploy an App Instance
   
   @{policy_list}=  Create List  ${policy_name}
   log to console  Creating App and App Instance
   create app  region=${region}  app_name=${app_name}  deployment=kubernetes  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policies=@{policy_list}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet1}  operator_org_name=${operator_name_openstack_packet}  token=${user_token}
#   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=${cluster_name}  token=${user_token}

Delete Cloudlet from Auto Provisioning Policy

    ${remove_cloudlet}=  remove auto provisioning policy cloudlet  region=${region}  policy_name=${policy_name}  developer_org_name=${orgname}  cloudlet_name=${cloudlet1}  operator_org_name=${operator_name_openstack_packet}  token=${user_token}
    Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet2}  operator_org_name=${operator_name_openstack_packet}  token=${user_token}
#    sleep  3 minutes
#    app instance should not exist  app_name=${app_name}  region=${region}  app_version=v1  developer_org_name=${orgname}  cloudlet_name=${cloudlet1}

Remove auto provisioning policy from App
    update app  region=${region}  app_name=${app_name}  developer_org_name=${orgname}  auto_prov_policies=@{EMPTY}  app_version=v1  token=${user_token}

    sleep  2 minutes
#    app instance should not exist  app_name=${app_name}  region=${region}  app_version=v1  developer_org_name=${orgname}  cloudlet_name=${cloudlet1}
    app instance should not exist  app_name=${app_name}  region=${region}  app_version=v1  developer_org_name=${orgname}  cloudlet_name=${cloudlet2}
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


