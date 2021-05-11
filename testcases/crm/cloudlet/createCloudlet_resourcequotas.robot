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

${operator_name_openstack}  TDG
${physical_name_openstack}  munich

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3351
UpdateCloudlet to add/modify resource quotas and default_resource_alert_threshold should work
   [Documentation]
   ...  - Create Cloudlet with no resource quotas 
   ...  - Update Cloudlet to add resource quotas with alert_thresholds
   ...  - Update Cloudlet to modify resource quotas and default_resource_alert_threshold

   # create cloudlet without resource quotas
   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  token=${tokenop}

   &{resource1}=  Create Dictionary  name=RAM  value=14336  alert_threshold=75
   &{resource2}=  Create Dictionary  name=vCPUs  value=8    alert_threshold=80
   &{resource3}=  Create Dictionary  name=Instances  value=4  alert_threshold=85
   &{resource4}=  Create Dictionary  name=GPUs   value=6  alert_threshold=90
   @{resource_list}=  Create List  ${resource1}  ${resource2}  ${resource3}  ${resource4}

   #update cloudlet to add resource quotas
   ${cloudlet1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${tokenop}

   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['value']}  14336
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['value']}  8
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][2]['value']}  4
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['alert_threshold']}  75
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['alert_threshold']}  80
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][2]['alert_threshold']}  85
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][3]['alert_threshold']}  90

   &{resource1}=  Create Dictionary  name=RAM  value=8192  
   &{resource2}=  Create Dictionary  name=vCPUs  value=4   
   &{resource3}=  Create Dictionary  name=Instances  value=2
   &{resource4}=  Create Dictionary  name=GPUs  value=5
   @{resource_list}=  Create List  ${resource1}  ${resource2}  ${resource3}  ${resource4}

   #update cloudlet to modify resource quotas and default_resource_alert_threshold
   ${cloudlet1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  default_resource_alert_threshold=70  token=${tokenop}
   Should Be Equal As Numbers   ${cloudlet1['data']['default_resource_alert_threshold']}  70
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['value']}  8192
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['value']}  4
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][2]['value']}  2
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][3]['value']}  5
   Dictionary Should Not Contain Key  ${cloudlet1['data']['resource_quotas'][0]}  alert_threshold

# ECQ-3352
CreateCloudlet with resource quotas and UpdateCloudlet to add/modify them
   [Documentation]
   ...  - Create Cloudlet with some resource quotas
   ...  - Update Cloudlet to add remaining resource quotas

   &{resource1}=  Create Dictionary  name=RAM  value=14336  alert_threshold=75
   &{resource2}=  Create Dictionary  name=vCPUs  value=8    alert_threshold=80
   @{resource_list}=  Create List  ${resource1}  ${resource2}

   # create cloudlet with 2 types of resource quotas
   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  resource_list=${resource_list}  token=${tokenop}

   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['value']}  14336
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['value']}  8
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['alert_threshold']}  75
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['alert_threshold']}  80

   &{resource3}=  Create Dictionary  name=Instances  value=4  alert_threshold=85
   &{resource4}=  Create Dictionary  name=GPUs  value=8  alert_threshold=90
   Append To List  ${resource_list}  ${resource3}  ${resource4}

   #update cloudlet to add 2 other resource quotas
   ${cloudlet1}=  Update Cloudlet  region=${region}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name}  resource_list=${resource_list}  token=${tokenop}

   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['value']}  14336
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['value']}  8
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][2]['value']}  4
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][0]['alert_threshold']}  75
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][1]['alert_threshold']}  80
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][2]['alert_threshold']}  85
   Should Be Equal As Numbers   ${cloudlet1['data']['resource_quotas'][3]['alert_threshold']}  90
 
*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${cloudlet_name}=  Get Default Cloudlet Name
   ${org_name}=  Get Default Organization Name

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack}  role=OperatorManager  

   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}

   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${tokenop}


