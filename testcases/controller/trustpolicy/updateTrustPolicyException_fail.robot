*** Settings ***
Documentation  UpdateTrustPolicyException fail

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US

*** Test Cases ***
# ECQ-4165
UpdateTrustPolicyException - update without region shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException without region
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Update Trust Policy Exception  token=${token}  use_defaults=${False}

# ECQ-4166
UpdateTrustPolicyException - update without token shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException without token
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Update Trust Policy Exception  region=${region}  use_defaults=${False}

# ECQ-4167
UpdateTrustPolicyException - update without key parms shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException with different missing parms
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   [Template]  Exception Should Error

   # no key
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{},\\\\"cloudlet_pool_key\\\\":{}} not found"}')  app_name=${None}

   # no policy name
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"}} not found"}')   app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # no app name
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # no app version
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # no app aorg
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # no cloudlet pool name
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # no cloudlet pool org name
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}

# ECQ-4168
UpdateTrustPolicyException - update with unknown parm values shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException with various unknown parm values
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   [Template]  Exception Should Error

   # unknown policy name
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"x\\\\"} not found"}')   policy_name=x  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # unknown app name
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"x\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_name=x  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # unknown app version
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"x\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  developer_org_name=${developer_org_name_automation}  app_version=x  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # unknown app aorg
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_name=${app_name_automation_trusted}  developer_org_name=x  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # unknown cloudlet pool name
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"x\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=x  cloudlet_pool_org_name=${pool['data']['key']['organization']}

   # unknown cloudlet pool org name
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=x

   # unknown cloudlet pool org name with rules
   ('code\=400', 'error\={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')   policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=x  rule_list=${rulelist}

# ECQ-4169
UpdateTrustPolicyException - update without protocol shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException without protocol
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   ${name}=  Get Default Trust Policy Name

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}  #${rule2}

   &{rule_update}=  Create Dictionary  remote_cidr=2.1.1.1/1
   @{rulelist_update}=  Create List  ${rule_update}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   Update Trust Policy Exception  region=${region}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist_update}  token=${token}

   @{rulelist}=  Create List  ${rule1}  ${rule2}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   Update Trust Policy Exception  region=${region}  policy_name=${name}_1  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist_update}  token=${token}

# ECQ-4170
UpdateTrustPolicyException - update with invalid CIDR shall return error 
   [Documentation]
   ...  - send UpdateTrustPolicyException with invalid CIDR 
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=x 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: x"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=256.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 256.1.1.1/1"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1/33
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1/33"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: "}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

# ECQ-4171
UpdateTrustPolicyException - update with invalid minport shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException with invalid min port 
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1

   @{rulelist}=  Create List  ${rule}  ${rule2}

   &{rule}=  Create Dictionary  protocol=tcp
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port: 0"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port: 0"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=string, field=TrustPolicyException.outbound_security_rules.port_range_min, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"TrustPolicyException.outbound_security_rules.port_range_min\\\\" at offset
  
   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=number -1, field=TrustPolicy.outbound_security_rules.port_range_min, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"TrustPolicyException.outbound_security_rules.port_range_min\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port: 65536"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

# ECQ-4172
UpdateTrustPolicyException - update with invalid maxport shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException with invalid max port
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
#   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"TrustPolicyException.outbound_security_rules.port_range_max\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=number -1, field=TrustPolicy.outbound_security_rules.port_range_max, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"TrustPolicyException.outbound_security_rules.port_range_max\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid max port: 65536"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

# ECQ-4173
UpdateTrustPolicyException - update with icmp and port range shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException with icmp and port range
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
#   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  port_range_maximum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=0  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist} 

# ECQ-4174
UpdateTrustPolicyException - update with minport>maxport shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException with minport>maxport
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
#   Create Trust Policy  region=${region}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   rule_list=${rulelist}  

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Update Trust Policy Exception  region=${region}  token=${token}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

# ECQ-4175
UpdateTrustPolicyException - operator update of rules shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException as operator with rules
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   ${optoken}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   # rules only
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Operator can update only state field"}')  Update Trust Policy Exception  region=${region}  token=${optoken}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   rule_list=${rulelist}

   # rules and state
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Operator can update only state field"}')  Update Trust Policy Exception  region=${region}  token=${optoken}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   rule_list=${rulelist}  state=Active

# ECQ-4176
UpdateTrustPolicyException - operator update of state=unknown shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException as operator with state=unknown
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   ${optoken}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"New state must be either Active or Rejected"}')  Update Trust Policy Exception  region=${region}  token=${optoken}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   state=Unknown

# ECQ-4177
UpdateTrustPolicyException - developer update of state shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException as developer with state
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   ${devtoken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   # state and rules
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Developer not allowed to update state field"}')  Update Trust Policy Exception  region=${region}  token=${devtoken}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   rule_list=${rulelist}  state=Active

   # state only
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Developer not allowed to update state field"}')  Update Trust Policy Exception  region=${region}  token=${devtoken}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   state=Active

# ECQ-4252
UpdateTrustPolicyException - developer update of rules after Active shall return error
   [Documentation]
   ...  - send UpdateTrustPolicyException as developer with connections after it is Active
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   ${devtoken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${optoken}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   Update Trust Policy Exception  region=${region}  token=${optoken}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   state=Active

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Can update security rules only when trust policy exception is still in approval requested state"}')  Update Trust Policy Exception  region=${region}  token=${devtoken}  policy_name=${policy_name}  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}   rule_list=${rulelist}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}
   Set Suite Variable  ${pool}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}

   Create Trust Policy Exception  region=${region}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${token}  rule_list=${rulelist}
 
   ${policy_name}=  Get Default Trust Policy Name
   Set Suite Variable  ${policy_name}

   ${cloudlet_name}=  Get Default Cloudlet Name
   Set Suite Variable  ${cloudlet_name}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/1
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=2  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule1}  ${rule2}
   Set Suite Variable  @{rulelist}

Exception Should Error
   [Arguments]  ${error_msg}  &{parms}
   Run Keyword and Expect Error  ${error_msg}  Update Trust Policy Exception  region=${region}  token=${token}  &{parms}  use_defaults=${False}

