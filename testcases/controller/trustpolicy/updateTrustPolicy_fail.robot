*** Settings ***
Documentation  UpdateTrustPolicy fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${operator_name_fake}=  dmuus
${cloudlet_name_fake}=  tmocloud-1
${operator_name_azure}=  azure
${cloudlet_name_azure}=  automationAzureCentralCloudlet 
${operator_name_gcp}=   gcp 
${cloudlet_name_gcp}=  automationGcpCentralCloudlet
${password}=   ${mextester06_gmail_password}
${developer_org}=  automation_dev_org

*** Test Cases ***
# ECQ-3032
UpdateTrustPolicy - update without region shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy without region
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Update Trust Policy  token=${token}  use_defaults=${False}

# ECQ-3033
UpdateTrustPolicy - update without token shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy without token
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Update Trust Policy  region=${region}  use_defaults=${False}

# ECQ-3034
UpdateTrustPolicy - update without parms shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with no parms 
   ...  - verify error is returned 

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {} not found"}')  Update Trust Policy  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3035
UpdateTrustPolicy - update without policy name shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with no policy name 
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"mobiledgex\\\\"} not found"}')  Update Trust Policy  operator_org_name=mobiledgex  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3036
UpdateTrustPolicy - update with unknown org name shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with unknown org name
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"xxxx\\\\"} not found"}')  Update Trust Policy  operator_org_name=xxxx  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3037
UpdateTrustPolicy - update without org name shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with no org name
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"name\\\\":\\\\"x\\\\"} not found"}')  Update Trust Policy  policy_name=x  region=${region}  token=${token}  use_defaults=${False}

# ECQ-3038
UpdateTrustPolicy - update without protocol shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy without protocol
   ...  - verify error is returned

   [Tags]  TrustPolicy

   ${name}=  Get Default Trust Policy Name

   Create Org  orgtype=operator

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}  #${rule2}
   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule_update}=  Create Dictionary  remote_cidr=2.1.1.1/1
   @{rulelist_update}=  Create List  ${rule_update}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   Update Trust Policy  region=${region}  rule_list=${rulelist_update}

   @{rulelist}=  Create List  ${rule1}  ${rule2}
   Create Trust Policy  region=${region}  policy_name=${name}_1  rule_list=${rulelist}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   Update Trust Policy  region=${region}  policy_name=${name}_1  rule_list=${rulelist_update}

# ECQ-3039
UpdateTrustPolicy - update with invalid CIDR shall return error 
   [Documentation]
   ...  - send UpdateTrustPolicy with invalid CIDR 
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Create Org  orgtype=operator

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=x 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: x"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=256.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 256.1.1.1/1"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1/33
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1/33"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: "}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

# ECQ-3040
UpdateTrustPolicy - update with invalid minport shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with invalid min port 
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Create Org  orgtype=operator

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1

   @{rulelist}=  Create List  ${rule}  ${rule2}
   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 0"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=string, field=TrustPolicy.outbound_security_rules.port_range_min, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"TrustPolicy.outbound_security_rules.port_range_min\\\\" at offset
  
   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=number -1, field=TrustPolicy.outbound_security_rules.port_range_min, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"TrustPolicy.outbound_security_rules.port_range_min\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port range: 65536"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-3041
UpdateTrustPolicy - update with invalid maxport shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with invalid max port
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Create Org  orgtype=operator

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=string, field=TrustPolicy.outbound_security_rules.port_range_max, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"TrustPolicy.outbound_security_rules.port_range_max\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=number -1, field=TrustPolicy.outbound_security_rules.port_range_max, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"TrustPolicy.outbound_security_rules.port_range_max\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid max port range: 65536"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-3042
UpdateTrustPolicy - update with icmp and port range shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with icmp and port range
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Create Org  orgtype=operator

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  port_range_maximum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=0  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-3043
UpdateTrustPolicy - update with minport>maxport shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with minport>maxport
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Create Org  orgtype=operator

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

# ECQ-3044
UpdateTrustPolicy - update with policy not found shall return error
   [Documentation]
   ...  - send UpdateTrustPolicy with a policy that does not exist 
   ...  - verify error is returned

   [Tags]  TrustPolicy

   ${name}=  Get Default Trust Policy Name
   ${org}=   Get Default Operator Name

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"${org}\\\\",\\\\"name\\\\":\\\\"${name}\\\\"} not found"}')  Update Trust Policy  region=${region}  token=${token}  rule_list=${rulelist}

# ECQ-3118
UpdateTrustPolicy - update with trust policy and maintenance mode shall return error
   [Documentation]
   ...  - send CreateTrustPolicy
   ...  - send CreateCloudlet with the policy and maintenance mode
   ...  - verify error is returned

   [Tags]  TrustPolicy

   Create Flavor  region=${region}

   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${operator_name_fake}

   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/1
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001

   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   ${cloudlet}=  Create Cloudlet  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_fake}  trust_policy=${policy_return['data']['key']['name']}
   Should Be Equal             ${cloudlet['data']['trust_policy']}  ${policy_return['data']['key']['name']}
   Should Be Equal As Numbers  ${cloudlet['data']['trust_policy_state']}  5

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cannot change both maintenance state and trust policy at the same time"}')  Update Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}  trust_policy=${cloudlet['data']['trust_policy']}  maintenance_state=MaintenanceStart  use_defaults=False

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cannot change both maintenance state and trust policy at the same time"}')  Update Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  cloudlet_name=${cloudlet_name}  trust_policy=${cloudlet['data']['trust_policy']}  maintenance_state=MaintenanceStartNoFailover  use_defaults=False

# ECQ-3124
UpdateTrustPolicy - shall not be able to update trust policy on cloudlet with mismatched appinst rules
   [Documentation]
   ...  - create a trust policy
   ...  - send CreateCloudlet with policy
   ...  - create app/appinst with required_outbound_connections
   ...  - send UpdateTrustPolicy with mismatched appinst rules
   ...  - verify error is received

   [Tags]  TrustPolicy

   Create Flavor  region=${region}

   Create Org  orgtype=operator

   ${policy_name}=  Get Default Trust Policy Name
   ${app_name}=  Get Default App Name
   ${org_name}=  Get Default Organization Name
   ${cloudlet_name}=  Get Default Cloudlet Name

   # create a trust policy
   &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.1.1.1/24
   @{rulelist1}=  Create List  ${rule1}

   &{rule11}=  Create Dictionary  protocol=udp  port_range_minimum=2001  port_range_maximum=3001  remote_cidr=3.1.1.1/24
   @{rulelist11}=  Create List  ${rule11}

   &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=1001  port_range_maximum=2001  remote_cidr=3.2.1.1/24
   @{rulelist2}=  Create List  ${rule2}

   ${policy_return}=  Create Trust Policy  region=${region}  rule_list=${rulelist1}  operator_org_name=${operator_name_fake}

   Should Be Equal  ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal  ${policy_return['data']['key']['organization']}  ${operator_name_fake}
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['protocol']}        udp
   Should Be Equal             ${policy_return['data']['outbound_security_rules'][0]['remote_cidr']}     3.1.1.1/24
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_min']}  1001
   Should Be Equal As Numbers  ${policy_return['data']['outbound_security_rules'][0]['port_range_max']}  2001
   ${numrules}=  Get Length  ${policy_return['data']['outbound_security_rules']}
   Should Be Equal As Numbers  ${numrules}  1

   # create cloudlet with trust policy
   ${cloudlet}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_fake}  trust_policy=${policy_name}
   Should Be Equal             ${cloudlet['data']['trust_policy']}  ${policy_name}
   Should Be Equal As Numbers  ${cloudlet['data']['trust_policy_state']}  5

   # add appinst on the cloudlet
   &{rule1}=  Create Dictionary  protocol=udp  port=1001  remote_ip=3.1.1.1
   @{tcp1_rulelist}=  Create List  ${rule1}
   Login  username=dev_manager_automation  password=${password}
   ${app}=  Create App  region=${region}  developer_org_name=${developer_org}  image_type=ImageTypeDocker  deployment=docker  image_path=${docker_image}  access_ports=tcp:2016  trusted=${True}  required_outbound_connections_list=${tcp1_rulelist}
   ${appinst}=  Create App Instance  region=${region}  operator_org_name=${operator_name_fake}  cluster_instance_name=autocluster${app_name}  developer_org_name=${developer_org}

   # update cloudlet with new trust policy with mismatch port list
   ${error}=  Run Keyword and Expect Error  *  Update Trust Policy  region=${region}  rule_list=${rulelist11}  operator_org_name=${operator_name_fake}  token=${token}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"AppInst on cloudlet organization:\\\\"${operator_name_fake}\\\\" name:\\\\"${cloudlet_name}\\\\" not compatible with trust policy - No outbound rule in policy to match required connection udp:3.1.1.1:1001 for App {\\\\"organization\\\\":\\\\"${developer_org}\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"}"}') 

   ${error}=  Run Keyword and Expect Error  *  Update Trust Policy  region=${region}  rule_list=${rulelist2}  operator_org_name=${operator_name_fake}  token=${token}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"AppInst on cloudlet organization:\\\\"${operator_name_fake}\\\\" name:\\\\"${cloudlet_name}\\\\" not compatible with trust policy - No outbound rule in policy to match required connection udp:3.1.1.1:1001 for App {\\\\"organization\\\\":\\\\"${developer_org}\\\\",\\\\"name\\\\":\\\\"${app_name}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"}"}')

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
 
   ${policy_name}=  Get Default Trust Policy Name
   Set Suite Variable  ${policy_name}

   ${cloudlet_name}=  Get Default Cloudlet Name
   Set Suite Variable  ${cloudlet_name}

