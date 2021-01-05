*** Settings ***
Documentation  CreateTrustPolicy failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${operator_name_fake}=  dmuus
${cloudlet_name_fake}=  tmocloud-1
${operator_name_azure}=  azure
${cloudlet_name_azure}=  automationAzureCentralCloudlet 
${operator_name_gcp}=   gcp 
${cloudlet_name_gcp}=  automationGcpCentralCloudlet


*** Test Cases ***
# ECQ-3018
CreateTrustPolicy - create without region shall return error
   [Documentation]
   ...  - send CreateTrustPolicy without region
   ...  - verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no region specified"}')  Create Trust Policy  token=${token}  use_defaults=${False}

# ECQ-3019
CreateTrustPolicy - create without token shall return error
   [Documentation]
   ...  - send CreateTrustPolicy without token
   ...  - verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Create Trust Policy  region=${region}  use_defaults=${False}

# ECQ-3020
CreateTrustPolicy - create without parms shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with no parms 
   ...  - verify error is returned 

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid organization, name cannot be empty"}')  Create Trust Policy  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3021
CreateTrustPolicy - create without policy name shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with no policy name 
   ...  - verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy name cannot be empty"}')  Create Trust Policy  operator_org_name=${developer}  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3022
CreateTrustPolicy - create with unknown org name shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with unknown org name
   ...  - verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"org xxxx not found"}')  Create Trust Policy  operator_org_name=xxxx  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3023
CreateTrustPolicy - create without org name shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with no org name
   ...  - verify error is returned

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid organization, name cannot be empty"}')  Create Trust Policy  policy_name=x  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3024
CreateTrustPolicy - create without protocol shall return error
   [Documentation]
   ...  - send CreateTrustPolicy without protocol
   ...  - verify error is returned

   &{rule}=  Create Dictionary  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   Create Trust Policy  region=${region}  rule_list=${rulelist} 

# ECQ-3025
CreateTrustPolicy - create with invalid CIDR shall return error 
   [Documentation]
   ...  - send CreateTrustPolicy with invalid CIDR 
   ...  - verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=x 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: x"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=256.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 256.1.1.1/1"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1/33
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1/33"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: "}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-3026
CreateTrustPolicy - create with invalid minport shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with invalid min port 
   ...  - verify error is returned

   &{rule}=  Create Dictionary  protocol=tcp
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: code=400, message=Unmarshal type error: expected=uint32, got=string, field=TrustPolicy.outbound_security_rules.port_range_min, offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: code=400, message=Unmarshal type error: expected=uint32, got=number -1, field=TrustPolicy.outbound_security_rules.port_range_min, offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 65536"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-3027
CreateTrustPolicy - create with invalid maxport shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with invalid max port
   ...  - verify error is returned

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: code=400, message=Unmarshal type error: expected=uint32, got=string, field=TrustPolicy.outbound_security_rules.port_range_max, offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: code=400, message=Unmarshal type error: expected=uint32, got=number -1, field=TrustPolicy.outbound_security_rules.port_range_max, offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid max port range: 65536"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-3028
CreateTrustPolicy - create with icmp and port range shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with icmp and port range
   ...  - verify error is returned

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  port_range_maximum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=0  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-3029
CreateTrustPolicy - create with minport>maxport shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with minport>maxport
   ...  - verify error is returned

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

# ECQ-3030
CreateTrustPolicy - create with duplicate policy shall return error
   [Documentation]
   ...  - send same CreateTrustPolicy twice 
   ...  - verify error is returned

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=11  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   Create Trust Policy  region=${region}  rule_list=${rulelist}

   ${policyname}=  Get Default Trust Policy Name
   ${org}=  Get Default Operator Name

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Key {\\\\"organization\\\\":\\\\"${org}\\\\",\\\\"name\\\\":\\\\"${policyname}\\\\"} already exists"}')  Create Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

# ECQ-3031
#EDGECLOUD-4191 CreateCloudlet for non-openstack with trust policy error says "Privacy Policy"
CreateTrustPolicy - CreateCloudlet with non-openstack shall return error
   [Documentation]
   ...  - send CreateTrustPolicy with non-openstack platforms
   ...  - verify error is returned

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}
   Create Flavor  region=US

   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Trust Policy not supported on PLATFORM_TYPE_AZURE","code":400}}')    Create Cloudlet  region=US  platform_type=PlatformTypeAzure  operator_org_name=${developer}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Trust Policy not supported on PLATFORM_TYPE_GCP","code":400}}')      Create Cloudlet  region=US  platform_type=PlatformTypeGCP  operator_org_name=${developer}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Trust Policy not supported on PLATFORM_TYPE_EDGEBOX","code":400}}')  Create Cloudlet  region=US  platform_type=PlatformTypeEdgebox  operator_org_name=${developer}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Trust Policy not supported on PLATFORM_TYPE_VSPHERE","code":400}}')  Create Cloudlet  region=US  platform_type=PlatformTypeVsphere  operator_org_name=${developer}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Trust Policy not supported on PLATFORM_TYPE_AWS_EKS","code":400}}')  Create Cloudlet  region=US  platform_type=PlatformTypeAwsEks  operator_org_name=${developer}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Trust Policy not supported on PLATFORM_TYPE_AWS_EC2","code":400}}')  Create Cloudlet  region=US  platform_type=PlatformTypeAwsEc2  operator_org_name=${developer}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}

   Create VM Pool  region=${region}  vm_pool_name=${policy_return['data']['key']['name']}_pool  org_name=${developer}  #use_defaults=False
   Run Keyword and Expect Error  ('code=200', 'error={"result":{"message":"Trust Policy not supported on PLATFORM_TYPE_VM_POOL","code":400}}')  Create Cloudlet  region=US  platform_type=PlatformTypeVmPool  operator_org_name=${developer}  latitude=1  longitude=1  number_dynamic_ips=1  trust_policy=${policy_return['data']['key']['name']}  vm_pool=${policy_return['data']['key']['name']}_pool

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   Create Org
