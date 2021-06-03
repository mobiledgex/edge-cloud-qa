*** Settings ***
Documentation  CreateCloudletPoolMemberMember Fail

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator}=  dmuus

*** Test Cases ***
# ECQ-1660
CreateCloudletPoolMember - create without region shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember without region
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"No region specified"}

# ECQ-1661
CreateCloudletPoolMember - create without parameters shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember with region only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {} not found"}

# ECQ-2303
CreateCloudletPoolMember - create without org shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember with name only
   ...  - verify proper error is received

   ${error}=  Run Keyword And Expect Error  *  Add Cloudlet Pool Member  region=US  cloudlet_pool_name=xxx  token=${token}  use_defaults=False

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"CloudletPool key {\\\\"name\\\\":\\\\"xxx\\\\"} not found"}

# ECQ-1662
# removed since it checks the pool name exists before adding member
#CreateCloudletPoolMember - create with invalid pool name shall return error 
#   [Documentation]
#   ...  send CreateCloudletPoolMember with invalid name
#   ...  verify proper error is received 
#
#   Create Cloudlet Pool  region=US  token=${token}
#
#   # start with a dash
#   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=-pool
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}
#
#   # $ in name 
#   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=p$ool
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}
#
#   # () in name
#   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=p(o)ol
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}
#
#   # +={}<> in name
#   ${error}=  Run Keyword and Expect Error  *  Add Cloudlet Pool Member  region=US  token=${token}  cloudlet_pool_name=+={}<>
#   Should Contain   ${error}  code=400
#   Should Contain   ${error}  error={"message":"Invalid Cloudlet Pool name"}

# ECQ-1663
CreateCloudletPoolMember - create with same name shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember twice for same name 
   ...  - verify proper error is received

   #EDGECLOUD-1716 CreateCloudletPoolMember for duplicate create should return the member name in the error

   Create Cloudlet Pool  region=US  token=${token}  operator_org_name=${operator}
   Add Cloudlet Pool Member  region=US  token=${token}  operator_org_name=dmuus  cloudlet_name=tmocloud-1  

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  region=US  token=${token}  operator_org_name=dmuus  cloudlet_name=tmocloud-1
   
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cloudlet already part of pool"}

# ECQ-1664
CreateCloudletPoolMember - create operator not found shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember operator not found 
   ...  - verify proper error is received

   #EDGECLOUD-1717 - CreateCloudletPoolMember - create with unknown operator/cloudlet should give info in error message

   #Create Cloudlet Pool  region=US  token=${token}  operator_org_name=${operator}

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  region=US  token=${token}  operator_org_name=dmuusxxx  cloudlet_name=tmocloud-1
  
   ${pool_name}=  Get Default Cloudlet Pool Name
 
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"CloudletPool key {\\\\"organization\\\\":\\\\"dmuusxxx\\\\",\\\\"name\\\\":\\\\"${pool_name}\\\\"} not found"}

# ECQ-1665
CreateCloudletPoolMember - create cloudlet not found shall return error
   [Documentation]
   ...  - send CreateCloudletPoolMember cloudlet not found
   ...  - verify proper error is received

   #EDGECLOUD-1717 - CreateCloudletPoolMember - create with unknown operator/cloudlet should give info in error message

   Create Cloudlet Pool  region=US  token=${token}  operator_org_name=${operator}

   ${error}=  Run Keyword And Expect Error  *   Add Cloudlet Pool Member  region=US  token=${token}  operator_org_name=dmuus  cloudlet_name=tmocloud-1xx
   
   Should Contain  ${error}   400
   Should Contain  ${error}   {"message":"Cloudlet key {\\\\"organization\\\\":\\\\"dmuus\\\\",\\\\"name\\\\":\\\\"tmocloud-1xx\\\\"} not found"}

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${pool_name}=  Get Default Cloudlet Pool Name

   Set Suite Variable  ${pool_name}
