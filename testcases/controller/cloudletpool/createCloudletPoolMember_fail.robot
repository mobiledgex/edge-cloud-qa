*** Settings ***
Documentation  CreateCloudletPoolMemberMember Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Test Cases ***
CreateCloudletPoolMember - create without region shall return error
   [Documentation]
   ...  send CreateCloudletPoolMember without region
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool Member  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"no region specified"}

CreateCloudletPoolMember - create without parameters shall return error
   [Documentation]
   ...  send CreateCloudletPoolMember with region only
   ...  verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool Member  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid operator name"}

CreateCloudletPoolMember - create with invalid pool name shall return error 
   [Documentation]
   ...  send CreateCloudletPoolMember with invalid name
   ...  verify proper error is received 

   # start with a dash
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=-pool
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # $ in name 
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=p$ool
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # () in name
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=p(o)ol
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

   # +={}<> in name
   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=+={}<>
   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

CreateCloudletPoolMember - create with same name shall return error
   [Documentation]
   ...  send CreateCloudletPoolMember twice for same name 
   ...  verify proper error is received

   #EDGECLOUD-1716 CreateCloudletPoolMember for duplicate create should return the member name in the error

   Create Cloudlet Pool  region=US  token=${token} 
   Create Cloudlet Pool Member  region=US  token=${token}  operator_name=tmus  cloudlet_name=tmocloud-1  

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool Member  region=US  token=${token}  operator_name=tmus  cloudlet_name=tmocloud-1
   
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"CloudletPoolMember key {\\\\"pool_key\\\\":{\\\\"name\\\\":\\\\"${pool_name}\\\\"},\\\\"cloudlet_key\\\\":{\\\\"operator_key\\\\":{\\\\"name\\\\":\\\\"tmus\\\\"},\\\\"name\\\\":\\\\"tmocloud-1\\\\"}} already exists"}

CreateCloudletPoolMember - create operator not found shall return error
   [Documentation]
   ...  send CreateCloudletPoolMember operator not found 
   ...  verify proper error is received

   #EDGECLOUD-1717 - CreateCloudletPoolMember - create with unknown operator/cloudlet should give info in error message

   Create Cloudlet Pool  region=US  token=${token}

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool Member  region=US  token=${token}  operator_name=tmusxxx  cloudlet_name=tmocloud-1
   
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cloudlet key {\\\\"operator_key\\\\":{\\\\"name\\\\":\\\\"tmusxxx\\\\"},\\\\"name\\\\":\\\\"tmocloud-1\\\\"} not found"}

CreateCloudletPoolMember - create cloudlet not found shall return error
   [Documentation]
   ...  send CreateCloudletPoolMember cloudlet not found
   ...  verify proper error is received

   #EDGECLOUD-1717 - CreateCloudletPoolMember - create with unknown operator/cloudlet should give info in error message

   Create Cloudlet Pool  region=US  token=${token}

   ${error}=  Run Keyword And Expect Error  *   Create Cloudlet Pool Member  region=US  token=${token}  operator_name=tmus  cloudlet_name=tmocloud-1xx
   
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cloudlet key {\\\\"operator_key\\\\":{\\\\"name\\\\":\\\\"tmus\\\\"},\\\\"name\\\\":\\\\"tmocloud-1xx\\\\"} not found"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
