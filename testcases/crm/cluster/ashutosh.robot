*** Settings ***
Documentation   Create Dedicated Docker Reservable Cluster and Verify Auto-Provisioning

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
#Library         MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         MexApp
#Library         String
#Library         SSHLibrary  10 Seconds
#Library         OperatingSystem

Test Timeout     15 minutes

#Test Setup      Setup
Suite Teardown  Cleanup

*** Variables ***
${cloudlet_name_openstack_dedicated}  automationDusseldorfCloudlet
${operator_name_openstack}  TDG
${mobiledgex_domain}  mobiledgex.net
${region}  EU
${flavor}  automation_api_flavor
${default_flavor_name}   automation_api_flavor
${cluster_name}  dockerreservable
${docker_image}  docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1
${policy_name}  AutoProvPolicyTest
${app_name}  AutoProvAppDocker
${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc

*** Test Cases ***

Create docker based reservable cluster instnace
   [Documentation]
   ...  create a dedicated reservabe docker cluster instnace

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  reservable=${True}   cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker  flavor_name=${flavor}
   Log to Console  DONE creating cluster instance

Create Auto Provisioning Policy

   Log to Console  Create Auto Provisioning Policy
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  deploy_client_count=1  deploy_interval_count=1  developer_org_name=testmonitor
   log to console  ${policy_return}

Add Cloudlet to Auto Provisioning Policy

   log to console  Add Cloudlet to Auto Provisioning Policy
   ${add_cloudlet}=  Add Auto Provisioning Policy Cloudlet  region=EU  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack_dedicated}  policy_name=${policy_name}  developer_org_name=testmonitor

Create App, Add Autoprovisioning Policy and Deploy an App Instance

   log to console  Creating App and App Instance
   create app  region=EU  app_name=${app_name}  deployment=docker  developer_org_name=testmonitor  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policy=${policy_name}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}

   log to console  Registering Client and Finding Cloudlet
   Register Client  developer_org_name=testmonitor  app_version=v1
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=12  longitude=50  carrier_name=TDG
#   Should Be Equal As Numbers  ${cloudlet.status}  FIND_NOTFOUND
   Should Contain  ${error_msg}  FIND_NOTFOUND

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=testmonitor  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}

#   sleep  45s

   log to console  Send RegisterClient and FindCloudlet to verify AutoProvisioning is Successful
   Register Client  developer_org_name=testmonitor  app_version=v1  app_name=AutoProvAppDocker
   ${cloudlet}=  Find Cloudlet  latitude=12  longitude=50  carrier_name=TDG
   log to console  Deployed Autoprovision App Successfully!

   Should Be Equal As Numbers  ${cloudlet.status}  1

#   sleep  15s

#   log to console  show app instances status
#   show app instances  region=${region}  developer_org_name=testmonitor  app_version=v1  app_name=${app_name}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}}
#   log to console  App Instnace is running successfully!

#   sleep  20s

   log to console  delete app instance
   delete app instance  region=${region}  app_name=AutoProvAppDocker  cluster_instance_name=dockerreservable  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=testmonitor  app_version=v1
   log to console  App Instnace Deleted!

   sleep  15s

   log to console  Registering Client and Finding Cloudlet
   Register Client  developer_org_name=testmonitor  app_version=v1
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=12  longitude=50  carrier_name=TDG
#   Should Be Equal As Numbers  ${cloudlet.status}  FIND_NOTFOUND
   Should Contain  ${error_msg}  FIND_NOTFOUND

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=testmonitor  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}

#   sleep  15s

   log to console  Send RegisterClient and FindCloudlet to verify AutoProvisioning is Successful
   Register Client  developer_org_name=testmonitor  app_version=v1  app_name=AutoProvAppDocker
   ${cloudlet}=  Find Cloudlet  latitude=12  longitude=50  carrier_name=TDG
   log to console  Re-Deployed Autoprovision App Successfully!

#   sleep  15s

#   log to console  show app instances status
#   show app instances  region=${region}  developer_org_name=testmonitor  app_version=v1  app_name=AutoProvAppDocker  operator_org_name=${operator_name_openstack}  cluster_instance_name=k8sreservable
#   log to console  App Instnace is running successfully!

*** Keywords ***
Setup
   #Wait For App Instance To Be Ready   region=${region}  developer_org_name=testmonitor  app_version=v1  app_name=AutoProvAppDocker  operator_org_name=${operator_name_openstack}  cluster_instance_name=k8sreservable
   show app instances  region=${region}  developer_org_name=testmonitor  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}
   Wait For App Instance To Be Ready   region=${region}   developer_org_name=testmonitor  app_version=v1  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name}
#
#    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
#    ${rootlb}=  Convert To Lowercase   ${rootlb}
#    Set Suite Variable  ${rootlb}

Cleanup
    cleanup provisioning


