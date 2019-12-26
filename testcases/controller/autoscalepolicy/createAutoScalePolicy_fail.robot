*** Settings ***
Documentation  CreateAutoScalePolicy failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
CreateAutoScalePolicy - create without region shall return error 
   [Documentation]
   ...  send CreateAutoScalePolicy without region 
   ...  verify proper error is received 

   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  token=${token}  use_defaults=False
        
   Should Contain  ${error_msg}   code=400 
   Should Contain  ${error_msg}   {"message":"no region specified"} 

CreateAutoScalePolicy - create without parameters shall return error
   [Documentation] 
   ...  send CreateAutoScalePolicy with region only
   ...  verify proper error is received

   #  EDGECLOUD-1709 - CreateAutoScalePolicy without developer name gives strangely worded error message

   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid developer name, name cannot be empty"}

CreateAutoScalePolicy - create without developer name shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy without developer name 
   ...  verify proper error is received

   #  EDGECLOUD-1709 - CreateAutoScalePolicy without developer name gives strangely worded error message

   # policy name only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid developer name, name cannot be empty"}

   # minnodes only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  min_nodes=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid developer name, name cannot be empty"}

   # maxnodes only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  max_nodes=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid developer name, name cannot be empty"}

   # scaledowncpusthreshold only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  scale_down_cpu_threshold=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid developer name, name cannot be empty"}
                        
   # scaleupcpusthreshold only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  scale_up_cpu_threshold=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid developer name, name cannot be empty"}

   # triggertime only
   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  trigger_time=1  use_defaults=False
   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Invalid developer name, name cannot be empty"}

CreateAutoScalePolicy - create with developer name only shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with developer name only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  developer_name=mypolicy  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}   {"message":"Policy name cannot be empty"}

CreateAutoScalePolicy - create with policy/developer name only shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with policy/developer name only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}  {"message":"Min nodes cannot be less than 1"} 

CreateAutoScalePolicy - create with policy/developer name and minnodes only shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with policy/developer name and minnodes only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}  {"message":"Max nodes must be greater than Min nodes"}

CreateAutoScalePolicy - create with policy/developer name and maxnodes only shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with policy/developer name and maxnodes only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  max_nodes=1  use_defaults=False

   Should Contain  ${error_msg}   code=400
   Should Contain  ${error_msg}  {"message":"Min nodes cannot be less than 1"}
	
CreateAutoScalePolicy - create with policy/developer name and minnodes/maxnodes only shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with policy/developer name and minnodes/maxnodes only
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  use_defaults=False

   Should Contain   ${error}   400
   Should Contain   ${error}  {"message":"Scale down cpu threshold must be less than scale up cpu threshold"}

CreateAutoScalePolicy - create with policy/developer name and minnodes/maxnodes and scaledowncputhreshold only shall return error
   [Documentation] 
   ...  send CreateAutoScalePolicy with policy/developer name and minnodes/maxnodes and scaledowncputhreshold only 
   ...  verify proper error is received 

   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  use_defaults=False

   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Scale down cpu threshold must be less than scale up cpu threshold"}

CreateAutoScalePolicy - create with minnodes <= maxnodes shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with minnodes <= maxnodes
   ...  verify proper error is received
  
   # max < min
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=2  max_nodes=1  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Max nodes must be greater than Min nodes"}

   # max=0
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=2  max_nodes=0  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Max nodes must be greater than Min nodes"}

   # min=max
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=2  max_nodes=2  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Max nodes must be greater than Min nodes"}

CreateAutoScalePolicy - create with minnodes=0 shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with minnodes=0
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=0  max_nodes=1  use_defaults=False

   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Min nodes cannot be less than 1"}

CreateAutoScalePolicy - create with maxnodes too large shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with maxnodes=11
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=11  max_nodes=12  use_defaults=False

   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Max nodes cannot exceed 10"}

CreateAutoScalePolicy - create with scaledowncputhreshold <= scaleupcputhreshold shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with scaledowncputhreshold <= scaleupcputhreshold 
   ...  verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=1  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Scale down cpu threshold must be less than scale up cpu threshold"}

   #scaledowncputhreshold < scaleupcputhreshold
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=2  scale_up_cpu_threshold=1  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Scale down cpu threshold must be less than scale up cpu threshold"}

   #scaledowncputhreshold = scaleupcputhreshold = 0
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=0  scale_up_cpu_threshold=0  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Scale down cpu threshold must be less than scale up cpu threshold"}

CreateAutoScalePolicy - create with scaledowncputhreshold > 100 shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with scaledowncputhreshold > 100
   ...  verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=101  scale_up_cpu_threshold=1  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Scale down CPU threshold must be between 0 and 100"}

CreateAutoScalePolicy - create with scaleupcputhreshold > 100 shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with scaleupcputhreshold > 100
   ...  verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Scale up CPU threshold must be between 0 and 100"}

CreateAutoScalePolicy - create with invalid minnodes shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with invalid minnodes
   ...  verify proper error is received

   #minnodes=-1
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=-1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data"}

   #minnodes=x
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=x  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data"}

CreateAutoScalePolicy - create with invalid maxnodes shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with invalid maxnodes 
   ...  verify proper error is received

   #maxnodes=-1
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=-1  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data"}

   #maxnodes=x
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=2  max_nodes=x  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data"}

CreateAutoScalePolicy - create with invalid scaleupcputhreshold shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with invalid scaleupcputhreshold 
   ...  verify proper error is received

   #maxnodes=-1
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=-10  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data"}

   #maxnodes=x
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=2  max_nodes=x  scale_down_cpu_threshold=xx  scale_up_cpu_threshold=101  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data"}

CreateAutoScalePolicy - create with invalid scaledowncputhreshold shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy with invalid scaledowncputhreshold 
   ...  verify proper error is received

   #scale_up_cpu_threshold=-1
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=-11  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data"}

   #scale_up_cpu_threshold=x
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=2  max_nodes=x  scale_down_cpu_threshold=1  scale_up_cpu_threshold=xx  use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid POST data"}

CreateAutoScalePolicy - create with same name shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy twice for same policy 
   ...  verify proper error is received

   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2  use_defaults=False

   #scale_up_cpu_threshold=-1
   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"key {\\\\"developer\\\\":\\\\"mydev\\\\",\\\\"name\\\\":\\\\"mypolicy\\\\"} already exists"}

CreateAutoScalePolicy - create with invalid developer name shall return error
   [Documentation]
   ...  send CreateAutoScalePolicy twice for same policy
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=+mydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid developer name, name can only contain letters, digits, _ . -"}

   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=m(y)dev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid developer name, name can only contain letters, digits, _ . -"}

   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=m$&^#!@ydev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid developer name, name can only contain letters, digits, _ . -"}

   ${error}=  Run Keyword And Expect Error  *   Create Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  developer_name=<dev  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   Should Contain   ${error}   400
   Should Contain             ${error}  {"message":"Invalid developer name, name can only contain letters, digits, _ . -"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
