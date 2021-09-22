*** Settings ***
Documentation  UpdateAutoScalePolicy failures 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-3552
UpdateAutoScalePolicy - update without region shall return error 
   [Documentation]
   ...  - send UpdateAutoScalePolicy without region 
   ...  - verify proper error is received 

   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  token=${token}  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"No region specified"}')

# ECQ-3553
UpdateAutoScalePolicy - update without parameters shall return error
   [Documentation] 
   ...  - send UpdateAutoScalePolicy with region only
   ...  - verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {} not found"}')

# ECQ-3554
UpdateAutoScalePolicy - update without organization shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy without organization
   ...  - verify proper error is received

   # policy name only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {\\\\"name\\\\":\\\\"${policy_name}\\\\"} not found"}')

   # minnodes only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  min_nodes=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {} not found"}')

   # maxnodes only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  max_nodes=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {} not found"}')

   # scaledowncpusthreshold only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  scale_down_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {} not found"}')
                        
   # scaleupcpusthreshold only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  scale_up_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {} not found"}')

   # triggertime only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  trigger_time=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {} not found"}')

# ECQ-3555 
UpdateAutoScalePolicy - update with organization only shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with organization only
   ...  - verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  developer_org_name=${developer_name}  use_defaults=False
   Should Be Equal   ${error_msg}  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"${developer_name}\\\\"} not found"}')

# ECQ-3556
UpdateAutoScalePolicy - update with minnodes <= maxnodes shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with minnodes <= maxnodes
   ...  - verify proper error is received
  
   # max < min
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=2  max_nodes=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Max nodes must be greater than Min nodes"}')

   # max=0
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=2  max_nodes=0  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Max nodes must be greater than Min nodes"}')

   # min=max
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=2  max_nodes=2  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Max nodes must be greater than Min nodes"}')

# now supported
# ECQ-3557
#UpdateAutoScalePolicy - update with minnodes=0 shall return error
#   [Documentation]
#   ...  - send UpdateAutoScalePolicy with minnodes=0
#   ...  - verify proper error is received
#
#   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=0  max_nodes=1  use_defaults=False
#   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Min nodes cannot be less than 1"}')
  
# ECQ-3558 
UpdateAutoScalePolicy - update with maxnodes too large shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with maxnodes=11
   ...  - verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=11  max_nodes=12  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Max nodes cannot exceed 10"}')

# ECQ-3559
UpdateAutoScalePolicy - update with scaledowncputhreshold <= scaleupcputhreshold shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with scaledowncputhreshold <= scaleupcputhreshold 
   ...  - verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Scale down cpu threshold must be less than scale up cpu threshold"}')

   #scaledowncputhreshold < scaleupcputhreshold
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=2  scale_up_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Scale down cpu threshold must be less than scale up cpu threshold"}')

   #scaledowncputhreshold = scaleupcputhreshold = 0
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=0  scale_up_cpu_threshold=0  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"One of target cpu or target mem or target active connections must be specified"}')

# ECQ-3560
UpdateAutoScalePolicy - update with scaledowncputhreshold > 100 shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with scaledowncputhreshold > 100
   ...  - verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=101  scale_up_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Scale down CPU threshold must be between 0 and 100"}')

# ECQ-3561
UpdateAutoScalePolicy - update with scaleupcputhreshold > 100 shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with scaleupcputhreshold > 100
   ...  - verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Scale up CPU threshold must be between 0 and 100"}')

# ECQ-3562
UpdateAutoScalePolicy - update with invalid minnodes shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with invalid minnodes
   ...  - verify proper error is received

   #minnodes=-1
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=-1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"AutoScalePolicy.min_nodes\\\\" at offset

   #minnodes=x
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=x  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"AutoScalePolicy.min_nodes\\\\" at offset

# ECQ-3563
UpdateAutoScalePolicy - update with invalid maxnodes shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with invalid maxnodes 
   ...  - verify proper error is received

   #maxnodes=-1
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=-1  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -1 for field \\\\"AutoScalePolicy.max_nodes\\\\" at offset

   #maxnodes=x
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=2  max_nodes=x  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"AutoScalePolicy.max_nodes\\\\" at offset

# ECQ-3564
UpdateAutoScalePolicy - update with invalid scaleupcputhreshold shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with invalid scaleupcputhreshold 
   ...  - verify proper error is received

   #scaleupcputhreshold=-10
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=-10  use_defaults=False
   Should Contain  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -10 for field \\\\"AutoScalePolicy.scale_up_cpu_thresh\\\\" at offset

   #scaleupcputhreshold=xx
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=2  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=xx  use_defaults=False
   Should Contain  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"AutoScalePolicy.scale_up_cpu_thresh\\\\" at offset

# ECQ-3565
UpdateAutoScalePolicy - update with invalid scaledowncputhreshold shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy with invalid scaledowncputhreshold 
   ...  - verify proper error is received

   #scaledowncputhreshold=-10
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=-10  scale_up_cpu_threshold=11  use_defaults=False
   Should Contain  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got number -10 for field \\\\"AutoScalePolicy.scale_down_cpu_thresh\\\\" at offset

   #scaledowncputhreshold=xx
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=2  max_nodes=3  scale_down_cpu_threshold=xx  scale_up_cpu_threshold=1  use_defaults=False
   Should Contain  ${error_msg}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected uint32, but got string for field \\\\"AutoScalePolicy.scale_down_cpu_thresh\\\\" at offset

# ECQ-3566
UpdateAutoScalePolicy - update with organization not found shall return error
   [Documentation]
   ...  - send UpdateAutoScalePolicy for an organization that doesnt exist
   ...  - verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=policy_name  developer_org_name=developer_name  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   Should Be Equal  ${error_msg}  ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"developer_name\\\\",\\\\"name\\\\":\\\\"policy_name\\\\"} not found"}')

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   Create Autoscale Policy  region=US  token=${token}

   ${policy_name}=  Get Default Autoscale Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}

