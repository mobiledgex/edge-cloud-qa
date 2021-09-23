*** Settings ***
Documentation   Create 5 Docker Reservable Auto Cluster and Verify Auto-Provisioning

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         MexApp

Test Timeout     15 minutes

Suite Setup      Setup
Suite Teardown  Cleanup

*** Variables ***
${cloudlet_name_openstack_dedicated}  automationSunnydaleCloudlet
${operator_name_openstack}  GDDT
${mobiledgex_domain}  mobiledgex.net
${region}  US
${flavor}  automation_api_flavor
${default_flavor_name}   automation_api_flavor
${cluster_name}  dockerreservable
${docker_image}  docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1
${policy_name}  AutoProvPolicyTest
${app_name_1}  AutoProvAppDocker1
${app_name_2}  AutoProvAppDocker2
${app_name_3}  AutoProvAppDocker3
${app_name_4}  AutoProvAppDocker4
${app_name_5}  AutoProvAppDocker5
${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***

### ECQ-3159 ###

Create Auto Provisioning Policy
   [Tags]  ReservableCluster

   Log to Console  Create Auto Provisioning Policy
   ${policy_return}=  Create Auto Provisioning Policy  region=${region}  policy_name=${policy_name}  deploy_client_count=1  deploy_interval_count=1  developer_org_name=${orgname}  token=${user_token}
   log to console  ${policy_return}

Add Cloudlet to Auto Provisioning Policy

   log to console  Add Cloudlet to Auto Provisioning Policy
   ${add_cloudlet}=  Add Auto Provisioning Policy Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack_dedicated}  policy_name=${policy_name}  developer_org_name=${orgname}  token=${user_token}

Create App, Add Autoprovisioning Policy and Deploy an App Instance
   [Tags]  ReservableCluster

   @{policy}=  Create List  ${policy_name}

   log to console  Creating App and App Instance
   create app  region=${region}  app_name=${app_name_1}  deployment=docker  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policies=${policy}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}
   create app  region=${region}  app_name=${app_name_2}  deployment=docker  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policies=${policy}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}
   create app  region=${region}  app_name=${app_name_3}  deployment=docker  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policies=${policy}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}
   create app  region=${region}  app_name=${app_name_4}  deployment=docker  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policies=${policy}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}
   create app  region=${region}  app_name=${app_name_5}  deployment=docker  developer_org_name=${orgname}  image_path=docker-qa.mobiledgex.net/testmonitor/images/myfirst-app:v1  auto_prov_policies=${policy}  access_ports=tcp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}


   log to console  Registering Client and Finding Cloudlet to App1
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_1}
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   Should Contain  ${error_msg}  FIND_NOTFOUND

   log to console  Registering Client and Finding Cloudlet to App2
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_2}
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   Should Contain  ${error_msg}  FIND_NOTFOUND

   log to console  Registering Client and Finding Cloudlet to App3
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_3}
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   Should Contain  ${error_msg}  FIND_NOTFOUND

   log to console  Registering Client and Finding Cloudlet to App4
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_4}
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   Should Contain  ${error_msg}  FIND_NOTFOUND

   log to console  Registering Client and Finding Cloudlet to App5
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_5}
   ${error_msg}=  Run Keyword And Expect Error  *  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   Should Contain  ${error_msg}  FIND_NOTFOUND

   sleep  3 minutes

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name_1}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name_2}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name_3}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name_4}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}

   Wait For App Instance To Be Ready   region=${region}   developer_org_name=${orgname}  app_version=v1  app_name=${app_name_5}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${user_token}

#   wait for cluster instance to be ready  region=${region}  cluster_name=reservable0  cloudlet_name=${cloudlet_name_openstack_dedicated}  token=${user_token}

   log to console  Send RegisterClient and FindCloudlet to verify AutoProvisioning is Successful
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_1}
   ${cloudlet}=  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   log to console  Deployed Autoprovision App Successfully!

   Should Be Equal As Numbers  ${cloudlet.status}  1

   log to console  Send RegisterClient and FindCloudlet to verify AutoProvisioning is Successful
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_2}
   ${cloudlet}=  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   log to console  Deployed Autoprovision App Successfully!

   Should Be Equal As Numbers  ${cloudlet.status}  1

   log to console  Send RegisterClient and FindCloudlet to verify AutoProvisioning is Successful
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_3}
   ${cloudlet}=  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   log to console  Deployed Autoprovision App Successfully!

   Should Be Equal As Numbers  ${cloudlet.status}  1

   log to console  Send RegisterClient and FindCloudlet to verify AutoProvisioning is Successful
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_4}
   ${cloudlet}=  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   log to console  Deployed Autoprovision App Successfully!

   Should Be Equal As Numbers  ${cloudlet.status}  1

   log to console  Send RegisterClient and FindCloudlet to verify AutoProvisioning is Successful
   Register Client  developer_org_name=${orgname}  app_version=v1  app_name=${app_name_5}
   ${cloudlet}=  Find Cloudlet  latitude=12  longitude=50  carrier_name=${operator_name_openstack}
   log to console  Deployed Autoprovision App Successfully!

   Should Be Equal As Numbers  ${cloudlet.status}  1

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
    ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
    ${cluster_name}=  Catenate  SEPARATOR=  ${cluster_name}  ${epoch}
    ${policy_name}=  Catenate  SEPARATOR=  ${policy_name}  ${epoch}
    ${app_name_1}=  Catenate  SEPARATOR=  ${app_name_1}  ${epoch}
    ${app_name_2}=  Catenate  SEPARATOR=  ${app_name_2}  ${epoch}
    ${app_name_3}=  Catenate  SEPARATOR=  ${app_name_3}  ${epoch}
    ${app_name_4}=  Catenate  SEPARATOR=  ${app_name_4}  ${epoch}
    ${app_name_5}=  Catenate  SEPARATOR=  ${app_name_5}  ${epoch}
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
    Set Suite Variable  ${app_name_1}
    Set Suite Variable  ${app_name_2}
    Set Suite Variable  ${app_name_3}
    Set Suite Variable  ${app_name_4}
    Set Suite Variable  ${app_name_5}

Cleanup

    sleep  1 minute
    ${appInst1}=  Show App Instances  region=${region}  app_name=${app_name_1}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    ${appInst2}=  Show App Instances  region=${region}  app_name=${app_name_2}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    ${appInst3}=  Show App Instances  region=${region}  app_name=${app_name_3}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    ${appInst4}=  Show App Instances  region=${region}  app_name=${app_name_4}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    ${appInst5}=  Show App Instances  region=${region}  app_name=${app_name_5}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    ${reservable1_cluster_name}=  Set Variable  ${appInst1[0]['data']['real_cluster_name']}
    ${reservable2_cluster_name}=  Set Variable  ${appInst2[0]['data']['real_cluster_name']}
    ${reservable3_cluster_name}=  Set Variable  ${appInst3[0]['data']['real_cluster_name']}
    ${reservable4_cluster_name}=  Set Variable  ${appInst4[0]['data']['real_cluster_name']}
    ${reservable5_cluster_name}=  Set Variable  ${appInst5[0]['data']['real_cluster_name']}

    delete app instance  region=${region}  app_name=${app_name_1}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    delete app instance  region=${region}  app_name=${app_name_2}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    delete app instance  region=${region}  app_name=${app_name_3}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    delete app instance  region=${region}  app_name=${app_name_4}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1
    delete app instance  region=${region}  app_name=${app_name_5}  cluster_instance_name=autocluster-autoprov  cluster_instance_developer_org_name=MobiledgeX  developer_org_name=${orgname}  app_version=v1

    delete cluster instance  region=${region}  cluster_name=${reservable1_cluster_name}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${super_token}
    delete cluster instance  region=${region}  cluster_name=${reservable2_cluster_name}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${super_token}
    delete cluster instance  region=${region}  cluster_name=${reservable3_cluster_name}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${super_token}
    delete cluster instance  region=${region}  cluster_name=${reservable4_cluster_name}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${super_token}
    delete cluster instance  region=${region}  cluster_name=${reservable5_cluster_name}  developer_org_name=MobiledgeX  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  token=${super_token}

    cleanup provisioning


