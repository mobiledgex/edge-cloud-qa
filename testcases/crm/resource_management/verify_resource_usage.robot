*** Settings ***
Documentation  Resource Management functional tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout    ${test_timeout_crm1}

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${operator_name_openstack_packet}  packet
${physical_name_openstack_packet}  packet

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:9.0
${qcow_centos_image}  https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:8d8f9c268fd419b16084c9ba054b483a
${helm_image}     https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3334
Controller throws proper error and displays correct resource usage/metrics data for docker/k8s/helm/vm based cluster/app instances
   [Documentation]
   ...  - Create Cloudlet with resource quotas
   ...  - Verify default_resource_alert_threshold
   ...  - Verify resource_quotas under ShowCloudlet
   ...  - Verify resources_snapshot under ShowCloudletInfo
   ...  - Verify creation of docker/k8s/helm based cluster instance fails due to quota limits
   ...  - Verify creation of reservable clusters and VM based App Inst fails due to quota limits
   ...  - Update Cloudlet to increase resource quotas
   ...  - Create docker/k8s/helm based cluster instance and verify getresourceusage
   ...  - Create reservable clusters and VM based App Inst and verify getresourceusage
   ...  - Verify getresourceusage after deletion of clusters and app instances
   ...  - Verify cloudletusage metrics after creation/deletion of appinst/clusterinst

   ${settings}=  Show Settings  region=${region}  token=${token}
   Run Keyword If  '${settings['master_node_flavor']}' != 'automation_api_flavor'  Update Settings  region=${region}  master_node_flavor=automation_api_flavor  token=${token}

   &{resource1}=  Create Dictionary  name=RAM  value=8192
   &{resource2}=  Create Dictionary  name=vCPUs  value=4
   &{resource3}=  Create Dictionary  name=Instances  value=2
   @{resource_list}=  Create List  ${resource1}  ${resource2}  ${resource3}


   # create cloudlet with resource quotas
   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  resource_list=${resource_list}  token=${tokenop}

   Should Be Equal As Numbers   ${cloudlet1['data']['default_resource_alert_threshold']}  80
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['value']}  8192
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['value']}  4
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][2]['value']}  2

   Verify Resource Usage  2  8192  4
 
   ${resourceusage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   ${default_instances}=  Set Variable  ${resourceusage[0]['info'][3]['value']}
   ${default_ram}=        Set Variable  ${resourceusage[0]['info'][4]['value']}
   ${default_vcpus}=      Set Variable  ${resourceusage[0]['info'][5]['value']}
   Set Suite Variable  ${default_instances}
   Set Suite Variable  ${default_ram}
   Set Suite Variable  ${default_vcpus}
 
   ${cloudlet_info}=   Show Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  token=${tokenop}

   Dictionary Should Contain Key  ${cloudlet_info[0]['data']}  resources_snapshot
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][0]['name']}  ${cloudlet_name}-packet-pf
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][0]['type']}  platform
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][0]['status']}  ACTIVE
   Dictionary Should Contain Key  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][0]['ipaddresses'][0]}   externalIp
   
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][1]['name']}  ${cloudlet_name}.${operator_name_openstack_packet}.mobiledgex.net
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][1]['type']}  rootlb
   Should Be Equal  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][1]['status']}  ACTIVE
   Dictionary Should Contain Key  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][1]['ipaddresses'][0]}   externalIp

   # create app/appinst for testing resource limits
   Create App  region=${region}  app_name=${app_name1}  developer_org_name=${org_name_dev}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2015  default_flavor_name=${flavor}  token=${tokendev}
   Create App  region=${region}  app_name=${app_name2}  developer_org_name=${org_name_dev}  image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  access_ports=tcp:2015  default_flavor_name=${flavor}  token=${tokendev}
   Create App  region=${region}  app_name=${app_name3}  developer_org_name=${org_name_dev}  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2015  default_flavor_name=${vmflavor}  token=${tokendev}
   Create App  region=${region}  app_name=${app_name4}  developer_org_name=${org_name_dev}  image_type=ImageTypeHelm  deployment=helm  image_path=${helm_image}  access_ports=udp:2015  default_flavor_name=${flavor}  token=${tokendev}

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available:
   Should Contain  ${error}  required vCPUs is 4 but only 0 out of 4 is available
   #Should Contain  ${error}  required Disk is 60GB but only 0GB is available
   Should Contain  ${error}  required Instances is 2 but only 0 out of 2 is available
   Should Contain  ${error}  required RAM is 6144MB but only 0MB out of 8192MB is available

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=docker  flavor_name=${flavor}  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available:
   Should Contain  ${error}  required RAM is 2048MB but only 0MB out of 8192MB is available
   Should Contain  ${error}  required vCPUs is 2 but only 0 out of 4 is available
   #Should Contain  ${error}  required Disk is 20GB but only 0GB is available
   Should Contain  ${error}  required Instances is 1 but only 0 out of 2 is available

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=kubernetes  number_nodes=1  flavor_name=${flavor}  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available:
   #Should Contain  ${error}  required Disk is 80GB but only 0GB is available
   Should Contain  ${error}  required Instances is 3 but only 0 out of 2 is available
   Should Contain  ${error}  required RAM is 8192MB but only 0MB out of 8192MB is available
   Should Contain  ${error}  required vCPUs is 6 but only 0 out of 4 is available

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=kubernetes  number_nodes=1  flavor_name=${flavor}  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available:
   Should Contain  ${error}  required RAM is 4096MB but only 0MB out of 8192MB is available
   Should Contain  ${error}  required vCPUs is 4 but only 0 out of 4 is available
   #Should Contain  ${error}  required Disk is 40GB but only 0GB is available
   Should Contain  ${error}  required Instances is 2 but only 0 out of 2 is available

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=helm  flavor_name=${flavor}  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available:
   Should Contain  ${error}  required vCPUs is 4 but only 0 out of 4 is available
   #Should Contain  ${error}  required Disk is 60GB but only 0GB is available
   Should Contain  ${error}  required Instances is 2 but only 0 out of 2 is available
   Should Contain  ${error}  required RAM is 6144MB but only 0MB out of 8192MB is available

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=helm  flavor_name=${flavor}  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available:
   Should Contain  ${error}  required RAM is 2048MB but only 0MB out of 8192MB is available
   Should Contain  ${error}  required vCPUs is 2 but only 0 out of 4 is available
   #Should Contain  ${error}  required Disk is 20GB but only 0GB is available
   Should Contain  ${error}  required Instances is 1 but only 0 out of 2 is available

   ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_name=${app_name1}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app_name1}  token=${tokendev}
   Should Contain  ${error}  "code":400
   Should Contain  ${error}  'code=200', 'error={"result":{"message":"Not enough resources available:
   Should Contain  ${error}   required vCPUs is 4 but only 0 out of 4 is available 
   #Should Contain  ${error}   required Disk is 60GB but only 0GB is available
   Should Contain  ${error}   required Instances is 2 but only 0 out of 2 is available
   Should Contain  ${error}   required RAM is 6144MB but only 0MB out of 8192MB is available 

   ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_name=${app_name2}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app_name1}  token=${tokendev}
   Should Contain  ${error}  "code":400
   Should Contain  ${error}  'code=200', 'error={"result":{"message":"Not enough resources available:
   Should Contain  ${error}   required vCPUs is 4 but only 0 out of 4 is available
   #Should Contain  ${error}   required Disk is 40GB but only 0GB is available
   Should Contain  ${error}   required Instances is 2 but only 0 out of 2 is available
   Should Contain  ${error}   required RAM is 4096MB but only 0MB out of 8192MB is available

   ${error}=  Run Keyword and Expect Error  *  Create App Instance  region=${region}  app_name=${app_name3}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=dummycluster  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available:
   Should Contain  ${error}  required vCPUs is 6 but only 0 out of 4 is available
   #Should Contain  ${error}  required Disk is 120GB but only 0GB is available
   Should Contain  ${error}  required RAM is 12288MB but only 0MB out of 8192MB is available
   Should Contain  ${error}  required Instances is 2 but only 0 out of 2 is available

   Cloudlet Update  20480  10  4

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}  auto_delete=False  token=${tokendev}
   Verify Resource Usage  4  14336  8

   ${metrics}=  Get CloudletUsage Metrics  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  selector=resourceusage  last=2  token=${tokenop}

   Length Should Be  ${metrics['data'][0]['Series'][0]['values']}   1
   Length Should Be  ${metrics['data'][0]['Series'][0]['columns']}  9
   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][0][6]}    4
   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][0][7]}    14336
   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][0][8]}    8

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cluster_name=${cluster_name}1  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=docker  flavor_name=${flavor}  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available: required Instances is 1 but only 0 out of 4 is available"}

   Delete Cluster Instance  region=${region}  cluster_name=${cluster_name}  developer_org_name=${org_name_dev}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokendev} 
   Verify Resource Usage  ${default_instances}  ${default_ram}  ${default_vcpus}

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=docker  flavor_name=${flavor}  auto_delete=False  token=${tokendev}
   Verify Resource Usage  3  10240  6
   Verify ResourceUsage Metrics  3  10240  6  2
   Delete Cluster Instance  region=${region}  developer_org_name=${org_name_dev}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokendev}
   Verify Resource Usage  ${default_instances}  ${default_ram}  ${default_vcpus}

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=kubernetes  number_nodes=1  flavor_name=${flavor}  auto_delete=False  token=${tokendev}
   Verify Resource Usage  4  12288  8
   Verify ResourceUsage Metrics  4  12288  8  2
   Delete Cluster Instance  region=${region}  developer_org_name=${org_name_dev}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokendev}
   Verify Resource Usage  ${default_instances}  ${default_ram}  ${default_vcpus}

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=kubernetes  number_nodes=1  flavor_name=${flavor}  auto_delete=False  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available: required Instances is 3 but only 2 out of 4 is available"}

   Cloudlet Update  20480  10  5

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=kubernetes  number_nodes=1  flavor_name=${flavor}  auto_delete=False  token=${tokendev}
   Verify Resource Usage  5  16384  10
   Verify ResourceUsage Metrics  5  16384  10  2

   ${error}=  Run Keyword and Expect Error  *  Update Cluster Instance  region=${region}  developer_org_name=${org_name_dev}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  number_nodes=2  token=${tokendev}
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available:
   Should Contain  ${error}  required Instances is 1 but only 0 out of 5 is available 
   Should Contain  ${error}  required vCPUs is 2 but only 0 out of 10 is available 
   Cloudlet Update  20480  12  6
   Update Cluster Instance  region=${region}   developer_org_name=${org_name_dev}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  number_nodes=2  token=${tokendev}
   Verify Resource Usage  6  18432  12
   Delete Cluster Instance  region=${region}  developer_org_name=${org_name_dev}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokendev}
   Verify Resource Usage  ${default_instances}  ${default_ram}  ${default_vcpus}

   Create App Instance  region=${region}  app_name=${app_name3}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=dummycluster  auto_delete=False  token=${tokendev}
   Verify Resource Usage  4  20480  10
   Verify ResourceUsage Metrics  4  20480  10  2
   Delete App Instance  region=${region}  app_name=${app_name3}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=dummycluster  token=${tokendev}
   Verify Resource Usage  ${default_instances}  ${default_ram}  ${default_vcpus}

   Create App Instance  region=${region}  app_name=${app_name1}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app_name1}  auto_delete=${False}  token=${tokendev}
   Verify Resource Usage  4  14336  8
   Verify ResourceUsage Metrics  4  14336  8  2
   Delete App Instance  region=${region}  app_name=${app_name1}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app_name1}  cluster_instance_developer_org_name=MobiledgeX    
   Delete Idle Reservable Cluster Instances  region=${region}  token=${token}
   Verify Resource Usage  ${default_instances}  ${default_ram}  ${default_vcpus}

   Create App Instance  region=${region}  app_name=${app_name2}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app_name2}  auto_delete=${False}  token=${tokendev}
   Verify Resource Usage  4  12288  8
   Verify ResourceUsage Metrics  4  12288  8  2
   Delete App Instance  region=${region}  app_name=${app_name2}  developer_org_name=${org_name_dev}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app_name2}  cluster_instance_developer_org_name=MobiledgeX
   Delete Idle Reservable Cluster Instances  region=${region}  token=${token}
   Verify Resource Usage  ${default_instances}  ${default_ram}  ${default_vcpus}

   #Total number of metrics
   ${metrics}=  Get CloudletUsage Metrics  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  selector=resourceusage  token=${tokenop}
   Length Should Be  ${metrics['data'][0]['Series'][0]['values']}   15

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${developer_name}=  Get Default Developer Name
   ${app_name1}=  Get Default App Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${org_name}=  Get Default Organization Name
   ${flavor}=  Get Default Flavor Name
   ${org_name_dev}=  Set Variable  ${org_name}_dev
   ${cluster_name}=  Get Default Cluster Name

   Create Flavor  region=${region}

   ${time}=  Get Time  epoch
   ${vmflavor}=  Set Variable  flavor${time}1
   Create Flavor  region=${region}  flavor_name=${vmflavor}  disk=80

   ${app_name2}=  Catenate  SEPARATOR=  ${app_name1}  1
   ${app_name3}=  Catenate  SEPARATOR=  ${app_name1}  2
   ${app_name4}=  Catenate  SEPARATOR=  ${app_name1}  3

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com
   ${usernamedev_epoch}=  Catenate  SEPARATOR=  ${username}  dev  ${epoch}
   ${emaildev}=  Catenate  SEPARATOR=  ${username}  dev  +  ${epoch}  @gmail.com

   Create Org  orgname=${org_name_dev}  orgtype=developer
   Create Billing Org  billing_org_name=${org_name_dev}  token=${token}

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Skip Verify Email
   Create User  username=${usernamedev_epoch}  password=${password}  email_address=${emaildev}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack_packet}  role=OperatorManager  
   Adduser Role  username=${usernamedev_epoch}  orgname=${org_name_dev}  role=DeveloperContributor

   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}
   ${tokendev}=  Login  username=${usernamedev_epoch}  password=${password}

   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}

   Set Suite Variable  ${tokenop}
   Set Suite Variable  ${tokendev}

   Set Suite Variable  ${org_name_dev}

   Set Suite Variable  ${app_name1}
   Set Suite Variable  ${app_name2}
   Set Suite Variable  ${app_name3}
   Set Suite Variable  ${app_name4}

   Set Suite Variable  ${flavor}
   Set Suite Variable  ${vmflavor}

Verify Resource Usage
   [Arguments]   ${instances}  ${ram}  ${vcpu}

   ${resourceusage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   Should Be Equal As Numbers  ${resourceusage[0]['info'][3]['value']}  ${instances}       #Instances
   Should Be Equal As Numbers  ${resourceusage[0]['info'][4]['value']}  ${ram}             #RAM
   Should Be Equal As Numbers  ${resourceusage[0]['info'][5]['value']}  ${vcpu}            #vCPUs

Cloudlet Update
   [Arguments]  ${ram}  ${vcpu}  ${instances}

   &{resource1}=  Create Dictionary  name=RAM  value=${ram}
   &{resource2}=  Create Dictionary  name=vCPUs  value=${vcpu}
   &{resource3}=  Create Dictionary  name=Instances  value=${instances}
   @{resource_list}=  Create List  ${resource1}  ${resource2}  ${resource3}

   ${cloudlet1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${tokenop}
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['value']}  ${ram}
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['value']}  ${vcpu}
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][2]['value']}  ${instances}

Verify ResourceUsage Metrics
   [Arguments]   ${instances}  ${ram}  ${vcpu}  ${length}

   ${metrics}=  Get CloudletUsage Metrics  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  selector=resourceusage  last=2  token=${tokenop}

   Length Should Be  ${metrics['data'][0]['Series'][0]['values']}   ${length}
   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][0][6]}    ${instances}
   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][0][7]}    ${ram}
   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][0][8]}    ${vcpu}

   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][1][6]}    ${default_instances}
   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][1][7]}    ${default_ram}
   Should Be Equal As Numbers  ${metrics['data'][0]['Series'][0]['values'][1][8]}    ${default_vcpus}
