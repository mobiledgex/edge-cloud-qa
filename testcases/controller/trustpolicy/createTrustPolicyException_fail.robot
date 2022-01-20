*** Settings ***
Documentation  CreateTrustPolicyException failures

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  String
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${operator_name_fake}=  tmus
${cloudlet_name_fake}=  tmocloud-1

*** Test Cases ***
# ECQ-4113
CreateTrustPolicyException - create exception without region shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException without region
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No region specified"}')  Create Trust Policy Exception  token=${token}  use_defaults=${False}

# ECQ-4114
CreateTrustPolicyException - create exception without token shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException without token
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Create Trust Policy Exception  region=${region}  use_defaults=${False}

# ECQ-4115
CreateTrustPolicyException - create exception without key parms shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException with different missing parms 
   ...  - verify error is returned 

   [Tags]  TrustPolicyException

   [Template]  Exception Should Error

   ('code\=400', 'error\={"message":"Invalid AppKey in TrustPolicyExceptionKey, Invalid app name"}')  app_name=${None}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"TrustPolicyException name cannot be empty"}')   app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"Invalid AppKey in TrustPolicyExceptionKey, Invalid app name"}')   policy_name=x  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"Invalid AppKey in TrustPolicyExceptionKey, Invalid app version"}')   policy_name=x  app_name=${app_name_automation_trusted}  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"Invalid AppKey in TrustPolicyExceptionKey, Invalid app organization"}')   policy_name=x  app_name=${app_name_automation_trusted}  app_version=1.0  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"Invalid CloudletPoolKey in TrustPolicyExceptionKey, Invalid cloudlet pool name"}')   policy_name=x  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"Invalid CloudletPoolKey in TrustPolicyExceptionKey, Invalid cloudlet pool organization"}')   policy_name=x  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  rule_list=${rulelist}

# ECQ-4116
CreateTrustPolicyException - create exception with unknown parm values shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException with various unknown parm values
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   [Template]  Exception Should Error
   ('code\=400', 'error\={"message":"App key {\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"yyy\\\\",\\\\"version\\\\":\\\\"1.0\\\\"} not found"}')  policy_name=x  app_name=yyy  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"Org xxxx not found"}')  policy_name=x  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=xxxx  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"App key {\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"x.0\\\\"} not found"}')  policy_name=x  app_name=${app_name_automation_trusted}  app_version=x.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   ('code\=400', 'error\={"message":"CloudletPool key {\\\\"organization\\\\":\\\\"tmus\\\\",\\\\"name\\\\":\\\\"x\\\\"} not found"}')  policy_name=x  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=x  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   ('code\=400', 'error\={"message":"CloudletPool key {\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"} not found"}')  policy_name=x  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=x  rule_list=${rulelist}

CreateTrustPolicyException - create exception with state shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException without protocol
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid field specified: State, this field is only for internal use"}')   Create Trust Policy Exception  region=${region}  state=Active  rule_list=${rulelist}

# ECQ-4117
CreateTrustPolicyException - create exception without protocol shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException without protocol
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Protocol must be one of: (tcp,udp,icmp)"}')   Create Trust Policy Exception  region=${region}  rule_list=${rulelist} 

# ECQ-4118
CreateTrustPolicyException - create exception with invalid CIDR shall return error 
   [Documentation]
   ...  - send CreateTrustPolicyException with invalid CIDR 
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=x 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: x"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=256.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 256.1.1.1/1"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1  remote_cidr=1.1.1.1/33
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: 1.1.1.1/33"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid CIDR address: "}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-4119
CreateTrustPolicyException - create exception with invalid minport shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException with invalid min port 
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=tcp
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port: 0"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist}

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port: 0"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *   Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=string, field=TrustPolicyExcpetion.outbound_security_rules.port_range_min, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"TrustPolicyException.outbound_security_rules.port_range_min\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=number -1, field=TrustPolicyExcpetion.outbound_security_rules.port_range_min, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"TrustPolicyException.outbound_security_rules.port_range_min\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid min port: 65536"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-4120
CreateTrustPolicyException - create exception with invalid maxport shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException with invalid max port
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=x  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=string, field=TrustPolicyExcpetion.outbound_security_rules.port_range_max, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"TrustPolicyException.outbound_security_rules.port_range_max\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=-1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   ${error}=  Run Keyword and Expect Error  *  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 
   #Should Contain  ${error}  ('code=400', 'error={"message":"Invalid data: Unmarshal type error: expected=uint32, got=number -1, field=TrustPolicy.outbound_security_rules.port_range_max, offset
   Should Contain  ${error}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"TrustPolicyException.outbound_security_rules.port_range_max\\\\" at offset

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=1  port_range_maximum=65536  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid max port: 65536"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-4121
CreateTrustPolicyException - create exception with icmp and port range shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException with icmp and port range
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  port_range_maximum=0  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 
   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 
   &{rule}=  Create Dictionary  protocol=icmp  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 
   &{rule}=  Create Dictionary  protocol=icmp  port_range_minimum=0  port_range_maximum=10  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Port range must be empty for icmp"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 

# ECQ-4122
CreateTrustPolicyException - create exception with minport>maxport shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException with minport>maxport
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1 
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist} 

   &{rule}=  Create Dictionary  protocol=tcp  port_range_minimum=10  port_range_maximum=1  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}
   Run Keyword and Expect Error  ('code=400', 'error={"message":"Min port range: 10 cannot be higher than max: 1"}')  Create Trust Policy Exception  region=${region}  token=${token}  rule_list=${rulelist}

# ECQ-4123
CreateTrustPolicyException - create with duplicate exception shall return error
   [Documentation]
   ...  - send same CreateTrustPolicyException twice 
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=11  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   Create Trust Policy Exception  region=${region}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   ${policyname}=  Get Default Trust Policy Name
   ${org}=  Get Default Operator Name

   ${error}=  Run Keyword and Expect Error  *  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}

   Should Be Equal  ${error}  ('code=400', 'error={"message":"TrustPolicyException key {\\\\"app_key\\\\":{\\\\"organization\\\\":\\\\"${developer_org_name_automation}\\\\",\\\\"name\\\\":\\\\"${app_name_automation_trusted}\\\\",\\\\"version\\\\":\\\\"1.0\\\\"},\\\\"cloudlet_pool_key\\\\":{\\\\"organization\\\\":\\\\"${pool['data']['key']['organization']}\\\\",\\\\"name\\\\":\\\\"${pool['data']['key']['name']}\\\\"},\\\\"name\\\\":\\\\"${policy_name}\\\\"} already exists"}')

# ECQ-4269
CreateTrustPolicyException - create on non-trusted app shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException on app that is not trusted
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   ${policyname}=  Get Default Trust Policy Name

   &{rule}=  Create Dictionary  protocol=udp  port_range_minimum=10  port_range_maximum=11  remote_cidr=1.1.1.1/1
   @{rulelist}=  Create List  ${rule}

   ${error}=  Run Keyword and Expect Error  *  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  rule_list=${rulelist}
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Non trusted app: organization:\\\\"${developer_org_name_automation}\\\\" name:\\\\"${app_name_automation}\\\\" version:\\\\"1.0\\\\" not compatible with trust policy: app_key:\\\\u003corganization:\\\\"${developer_org_name_automation}\\\\" name:\\\\"${app_name_automation}\\\\" version:\\\\"1.0\\\\" \\\\u003e cloudlet_pool_key:\\\\u003corganization:\\\\"${pool['data']['key']['organization']}\\\\" name:\\\\"${pool['data']['key']['name']}\\\\" \\\\u003e name:\\\\"${policyname}\\\\" "}') 

# ECQ-4270
CreateTrustPolicyException - create without security rules shall return error
   [Documentation]
   ...  - send CreateTrustPolicyException without security rules
   ...  - verify error is returned

   [Tags]  TrustPolicyException

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Security rules must be specified"}')  Create Trust Policy Exception  region=${region}  token=${token}  app_name=${app_name_automation_trusted}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']} 

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${token}
   Set Suite Variable  ${pool}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   @{rulelist}=  Create List  ${rule1}
   Set Suite Variable  @{rulelist}

Exception Should Error
   [Arguments]  ${error_msg}  &{parms}
   Run Keyword and Expect Error  ${error_msg}  Create Trust Policy Exception  region=${region}  token=${token}  &{parms}  use_defaults=${False}

