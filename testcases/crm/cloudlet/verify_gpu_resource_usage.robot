*** Settings ***
Documentation  CloudletResourceUsage Alerts

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout    ${test_timeout_crm}

*** Variables ***
${region}=  EU
${developer}=  mobiledgex

${operator_name_openstack}  GDDT
${physical_name_openstack}  buckhorn

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3389
Controller displays GPU resource usage of cloudlet and triggers alert when threshold is exceeded
   [Documentation]
   ...  - Create Cloudlet with GPU resource quota
   ...  - Create Cluster instance using gpu flavor
   ...  - Verify current GPU resource usage 
   ...  - Verify CloudletResourceUsage alert is triggered
   ...  - Verify alert is removed after UpdateCloudlet to increase quota limit of GPU
   ...  - Controller throws error while creating cluster with gpu flavor when no GPU is available

   &{resource1}=  Create Dictionary  name=GPUs  value=2  alert_threshold=40
   @{resource_list}=  Create List  ${resource1}

   # create cloudlet with resource quotas
   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  resource_list=${resource_list}  env_vars=MEX_EXT_NETWORK=external-network-02  token=${tokenop}  

   Add Cloudlet Resource Mapping   region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack}  mapping=gpu=mygpuresrouce  token=${tokenop}

   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   Dictionary Should Not Contain Key  ${resource_usage[0]['info'][1]}  value
   Should Be Equal As Numbers  ${resource_usage[0]['info'][1]['quota_max_value']}  2

   Create Cluster Instance  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=automation_gpu_flavor  token=${tokendev}

   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   log to console  ${resource_usage}
   Should Be Equal As Numbers  ${resource_usage[0]['info'][1]['value']}  1
   
   Sleep  60s

   #Verify Soft Alert
   ${alert1}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 40% of GPUs is used  token=${tokenop}
   Should Not Be Empty  ${alert1[0]['data']}

   &{resource1}=  Create Dictionary  name=GPUs  value=4  alert_threshold=50
   @{resource_list}=  Create List  ${resource1}

   # update cloudlet with resource quotas
   ${cloudlet1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${tokenop}

   ${resource_usage}=  Get Resource Usage  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   Should Be Equal As Numbers  ${resource_usage[0]['info'][1]['value']}  1
   Should Be Equal As Numbers  ${resource_usage[0]['info'][1]['quota_max_value']}  4

   Sleep  60s
   ${alert1}=  Show Alerts  region=${region}  cloudlet_name=${cloudlet_name}  warning=More than 40% of GPUs is used  token=${tokenop}
   Should Be Empty  ${alert1}

   &{resource1}=  Create Dictionary  name=GPUs  value=1
   @{resource_list}=  Create List  ${resource1}

   ${cloudlet1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${tokenop}

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cluster_name=${cluster_name}1  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=automation_gpu_flavor  token=${tokendev} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Not enough resources available: required GPUs is 1 but only 0 out of 1 is available"}')

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${developer_name}=  Get Default Developer Name
   ${cloudlet_name}=  Get Default Cloudlet Name
   ${org_name}=  Get Default Organization Name
   ${org_name_dev}=  Set Variable  ${org_name}_dev
   ${cluster_name}=  Get Default Cluster Name

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com
   ${usernamedev_epoch}=  Catenate  SEPARATOR=  ${username}  dev  ${epoch}
   ${emaildev}=  Catenate  SEPARATOR=  ${username}  dev  +  ${epoch}  @gmail.com

   Create Org  orgname=${org_name_dev}  orgtype=developer

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Skip Verify Email
   Create User  username=${usernamedev_epoch}  password=${password}  email_address=${emaildev}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack}  role=OperatorManager  
   Adduser Role  username=${usernamedev_epoch}  orgname=${org_name_dev}  role=DeveloperContributor

   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}
   ${tokendev}=  Login  username=${usernamedev_epoch}  password=${password}

   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}

   Set Suite Variable  ${tokenop}
   Set Suite Variable  ${tokendev}

   Set Suite Variable  ${org_name_dev}


