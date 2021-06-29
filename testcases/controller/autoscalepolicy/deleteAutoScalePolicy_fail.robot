*** Settings ***
Documentation  DeleteAutoScalePolicy failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-3538
DeleteAutoScalePolicy - delete without region shall return error 
   [Documentation]
   ...  - send DeleteAutoScalePolicy without region 
   ...  - verify proper error is received 

   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  token=${token}  use_defaults=False
        
   Should Be Equal  ${error}  ('code=400', 'error={"message":"No region specified"}')

# ECQ-3539
DeleteAutoScalePolicy - delete without parameters shall return error
   [Documentation] 
   ...  - send DeleteAutoScalePolicy with region only
   ...  - verify proper error is received

   #  EDGECLOUD-1709 - CreateAutoScalePolicy without developer name gives strangely worded error message

   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  use_defaults=False

   Should Be Equal  ${error}  ('code=400', 'error={"message":"Policy key {} not found"}')

# ECQ-3540
DeleteAutoScalePolicy - delete without organization shall return error
   [Documentation]
   ...  - send DeleteAutoScalePolicy without organization
   ...  - verify proper error is received

   #  EDGECLOUD-1709 - CreateAutoScalePolicy without developer name gives strangely worded error message

   # policy name only
   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  use_defaults=False
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Policy key {\\\\"name\\\\":\\\\"mypolicy\\\\"} not found"}')

   # minnodes only
   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  min_nodes=1  use_defaults=False
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Policy key {} not found"}')

   # maxnodes only
   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  max_nodes=1  use_defaults=False
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Policy key {} not found"}')

   # scaledowncpusthreshold only
   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  scale_down_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Policy key {} not found"}')
                        
   # scaleupcpusthreshold only
   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  scale_up_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Policy key {} not found"}')

   # triggertime only
   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  trigger_time=1  use_defaults=False
   Should Be Equal  ${error}  ('code=400', 'error={"message":"Policy key {} not found"}')

# ECQ-3541 
DeleteAutoScalePolicy - delete with organization only shall return error
   [Documentation]
   ...  - send DeleteAutoScalePolicy with organization only
   ...  - verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  developer_org_name=${developer_org_name_automation}  use_defaults=False
   Should Be Equal  ${error_msg}   ('code=400', 'error={"message":"Policy key {\\\\"organization\\\\":\\\\"automation_dev_org\\\\"} not found"}')

# ECQ-3542
DeleteAutoScalePolicy - delete with organization not found shall return error
   [Documentation]
   ...  - send DeleteAutoScalePolicy with organization that doesnt exist
   ...  - verify proper error is received

   #EDGECLOUD-1712 - DeleteAutoScalePolicy for non-existent policy does not return an error 

   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  policy_name=x  developer_org_name=x  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   
   Should Contain  ${error}  code=400 
   Should Contain  ${error}  {"message":"Policy key {\\\\"organization\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"x\\\\"} not found"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
