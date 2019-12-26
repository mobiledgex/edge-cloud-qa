*** Settings ***
Documentation  DeleteAutoScalePolicy failures 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Test Cases ***
DeleteAutoScalePolicy - delete without region shall return error 
   [Documentation]
   ...  send DeleteAutoScalePolicy without region 
   ...  verify proper error is received 

   Run Keyword And Expect Error  *   Delete Autoscale Policy  token=${token}  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
        
   Should Be Equal As Numbers  ${code}   400 
   Should Be Equal             ${response}  {"message":"no region specified"} 

DeleteAutoScalePolicy - delete without parameters shall return error
   [Documentation] 
   ...  send DeleteAutoScalePolicy with region only
   ...  verify proper error is received

   #  EDGECLOUD-1709 - CreateAutoScalePolicy without developer name gives strangely worded error message

   Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  use_defaults=False

   ${response}=  Response Body
   ${code}=  Response Status Code

   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"no region specified"}

DeleteAutoScalePolicy - delete without developer name shall return error
   [Documentation]
   ...  send DeleteAutoScalePolicy without developer name 
   ...  verify proper error is received

   #  EDGECLOUD-1709 - CreateAutoScalePolicy without developer name gives strangely worded error message

   # policy name only
   ${error_msg}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  policy_name=mypolicy  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"no region specified"}

   # minnodes only
   ${error_msg}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  min_nodes=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"no region specified"}

   # maxnodes only
   ${error_msg}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  max_nodes=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"no region specified"}

   # scaledowncpusthreshold only
   ${error_msg}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  scale_down_cpu_threshold=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"no region specified"}
                        
   # scaleupcpusthreshold only
   ${error_msg}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  scale_up_cpu_threshold=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"no region specified"}

   # triggertime only
   ${error_msg}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  trigger_time=1  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code
   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"no region specified"}
 
DeleteAutoScalePolicy - delete with developer name only shall return error
   [Documentation]
   ...  send DeleteAutoScalePolicy with developer name only
   ...  verify proper error is received

   ${error_msg}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  developer_name=mypolicy  use_defaults=False
   ${response}=  Response Body
   ${code}=  Response Status Code

   Should Be Equal As Numbers  ${code}   400
   Should Be Equal             ${response}  {"message":"Invalid policy name"}

DeleteAutoScalePolicy - delete with name not found shall return error
   [Documentation]
   ...  send DeleteAutoScalePolicy for policy not found
   ...  verify proper error is received

   #EDGECLOUD-1712 - DeleteAutoScalePolicy for non-existent policy does not return an error 

   ${error}=  Run Keyword And Expect Error  *   Delete Autoscale Policy  region=US  token=${token}  policy_name=x  developer_name=x  min_nodes=1  max_nodes=2  scale_down_cpu_threshold=1  scale_up_cpu_threshold=2   use_defaults=False
   
   Should Contain  ${error}  code=400 
   Should Contain  ${error}  {"message":"Policy key {\\\\"developer\\\\":\\\\"x\\\\",\\\\"name\\\\":\\\\"x\\\\"} not found"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}
