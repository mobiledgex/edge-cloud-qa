*** Settings ***
Documentation  UpdateAutoScalePolicy failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
UpdateAutoScalePolicy - update without region shall return error 
   [Documentation]
   ...  send UpdateAutoScalePolicy without region 
   ...  verify proper error is received 

   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  token=${token}  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
        
   Should Be Equal As Numbers  ${code}   400 
   Should Be Equal             ${response}  {"message":"no region specified"} 

UpdateAutoScalePolicy - update without parameters shall return error
   [Documentation] 
   ...  send UpdateAutoScalePolicy with region only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  use_defaults=False
   #${error_msg}=  Run Keyword And Expect Error  *   Create App Instance  region=US  token=${token}  use_defaults=False

   ${response}=  Response Body
   ${code}=  Response Status Code

   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {} not found"}

UpdateAutoScalePolicy - update without developer name shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy without developer name 
   ...  verify proper error is received

   # policy name only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {\\"name\\":\\"${policy_name}\\"} not found"}

   # minnodes only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  min_nodes=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {} not found"}

   # maxnodes only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  max_nodes=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {} not found"}

   # scaledowncpusthreshold only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  scale_down_cpu_threshold=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {} not found"}
                        
   # scaleupcpusthreshold only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  scale_up_cpu_threshold=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {} not found"}

   # triggertime only
   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  trigger_time=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {} not found"}
 
UpdateAutoScalePolicy - update with developer name only shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with developer name only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  developer_name=${developer_name}  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code

   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {\\"developer\\":\\"${developer_name}\\"} not found"}

UpdateAutoScalePolicy - update with minnodes <= maxnodes shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with minnodes <= maxnodes
   ...  verify proper error is received
  
   # max < min
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=2  max_nodes=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Max nodes must be greater than Min nodes"}

   # max=0
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=2  max_nodes=0  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Max nodes must be greater than Min nodes"}

   # min=max
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=2  max_nodes=2  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Max nodes must be greater than Min nodes"}

UpdateAutoScalePolicy - update with minnodes=0 shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with minnodes=0
   ...  verify proper error is received

   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=0  max_nodes=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code

   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Min nodes cannot be less than 1"}

UpdateAutoScalePolicy - update with maxnodes too large shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with maxnodes=11
   ...  verify proper error is received

   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=11  max_nodes=12  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code

   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Max nodes cannot exceed 10"}

UpdateAutoScalePolicy - update with scaledowncputhreshold <= scaleupcputhreshold shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with scaledowncputhreshold <= scaleupcputhreshold 
   ...  verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Scale down cpu threshold must be less than scale up cpu threshold"}

   #scaledowncputhreshold < scaleupcputhreshold
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=2  scale_up_cpu_threshold=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Scale down cpu threshold must be less than scale up cpu threshold"}

   #scaledowncputhreshold = scaleupcputhreshold = 0
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=0  scale_up_cpu_threshold=0  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Scale down cpu threshold must be less than scale up cpu threshold"}

UpdateAutoScalePolicy - update with scaledowncputhreshold > 100 shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with scaledowncputhreshold > 100
   ...  verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=101  scale_up_cpu_threshold=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Scale down CPU threshold must be between 0 and 100"}

UpdateAutoScalePolicy - update with scaleupcputhreshold > 100 shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with scaleupcputhreshold > 100
   ...  verify proper error is received

   #scaledowncputhreshold = scaleupcputhreshold
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Scale up CPU threshold must be between 0 and 100"}

UpdateAutoScalePolicy - update with invalid minnodes shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with invalid minnodes
   ...  verify proper error is received

   #minnodes=-1
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=-1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid POST data"}

   #minnodes=x
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=x  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid POST data"}

UpdateAutoScalePolicy - update with invalid maxnodes shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with invalid maxnodes 
   ...  verify proper error is received

   #maxnodes=-1
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=1  max_nodes=-1  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid POST data"}

   #maxnodes=x
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=2  max_nodes=x  scale_down_cpu_threshold=10  scale_up_cpu_threshold=101  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid POST data"}

UpdateAutoScalePolicy - update with invalid scaleupcputhreshold shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with invalid scaleupcputhreshold 
   ...  verify proper error is received

   #maxnodes=-1
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=-10  scale_up_cpu_threshold=101  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid POST data"}

   #maxnodes=x
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=2  max_nodes=x  scale_down_cpu_threshold=xx  scale_up_cpu_threshold=101  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid POST data"}

UpdateAutoScalePolicy - update with invalid scaledowncputhreshold shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy with invalid scaledowncputhreshold 
   ...  verify proper error is received

   #scale_up_cpu_threshold=-1
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=10  scale_up_cpu_threshold=-11  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid POST data"}

   #scale_up_cpu_threshold=x
   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_name=${developer_name}  min_nodes=2  max_nodes=x  scale_down_cpu_threshold=1  scale_up_cpu_threshold=xx  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid POST data"}

UpdateAutoScalePolicy - update with policy not found shall return error
   [Documentation]
   ...  send UpdateAutoScalePolicy for a policy that doesnt exist
   ...  verify proper error is received

   Run Keyword And Expect Error  *   Update Autoscale Policy  region=US  token=${token}  policy_name=policy_name  developer_name=developer_name  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Policy key {\\"developer\\":\\"developer_name\\",\\"name\\":\\"policy_name\\"} not found"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   Create Autoscale Policy  region=US

   ${policy_name}=  Get Default Autoscale Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}

