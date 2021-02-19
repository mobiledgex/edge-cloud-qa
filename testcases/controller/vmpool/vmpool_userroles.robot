*** Settings ***
Documentation  VMPools for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-2349
VMPool - developer org owner shall not be able to manipulate vm pools
   [Documentation]
   ...  - send CreateVMPool/DeleteVMPool/ShowVMPool/AddVMPoolMember/RemoveVMPoolMember for org owner\n
   ...  - verify error is returned\n

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Delete VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   #${pool}=  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   #Length Should Be  ${pool}  0

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Remove VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-2350
VMPool - operator org owner shall not be able to manipulate vm pools
   [Documentation]
   ...  - send CreateVMPool/DeleteVMPool/ShowVMPool/AddVMPoolMember/RemoveVMPoolMember for org owner\n
   ...  - verify error is returned\n

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Delete VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   #${pool}=  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   #Length Should Be  ${pool}  0

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Remove VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-2351
VMPool - DeveloperManager shall not be able to manipulate vm pools
   [Documentation]
   ...  - send CreateVMPool/DeleteVMPool/ShowVMPool/AddVMPoolMember/RemoveVMPoolMember for DeveloperManager user\n
   ...  - verify error is returned\n

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager   token=${user_token}

   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Delete VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Remove VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-2352
VMPool - DeveloperContributor shall not be able to manipulate vm pools
   [Documentation]
   ...  - send CreateVMPool/DeleteVMPool/ShowVMPool/AddVMPoolMember/RemoveVMPoolMember for DeveloperContributor user\n
   ...  - verify error is returned\n


   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperContributor   token=${user_token}

   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Delete VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Remove VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-2353
VMPool - DeveloperViewer shall not be able to manipulate vm pools
   [Documentation]
   ...  - send CreateVMPool/DeleteVMPool/ShowVMPool/AddVMPoolMember/RemoveVMPoolMember for DeveloperViewer user\n
   ...  - verify error is returned\n

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperViewer   token=${user_token}

   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Delete VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Remove VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-2354
VMPool - OperatorManager shall not be able to manipulate vm pools
   [Documentation]
   ...  - send CreateVMPool/DeleteVMPool/ShowVMPool/AddVMPoolMember/RemoveVMPoolMember for OperatorManager user\n
   ...  - verify error is returned\n

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${user_token}

   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Delete VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${pool}=  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Length Should Be  ${pool}  0

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Remove VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-2355
VMPool - OperatorContributor shall not be able to manipulate vm pools
   [Documentation]
   ...  - send CreateVMPool/DeleteVMPool/ShowVMPool/AddVMPoolMember/RemoveVMPoolMember for OperatorContributor user\n
   ...  - verify error is returned\n

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorContributor  token=${user_token}

   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Delete VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${pool}=  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Length Should Be  ${pool}  0

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Remove VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-2356
VMPool - OperatorViewer shall not be able to manipulate vm pools
   [Documentation]
   ...  - send CreateVMPool/DeleteVMPool/ShowVMPool/AddVMPoolMember/RemoveVMPoolMember for OperatorViewer user\n
   ...  - verify error is returned\n

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorViewer  token=${user_token}

   ${error}=  Run Keyword and Expect Error  *  Create VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Delete VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Update VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${pool}=  Show VM Pool  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Length Should Be  ${pool}  0

   ${error}=  Run Keyword and Expect Error  *  Add VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

   ${error}=  Run Keyword and Expect Error  *  Remove VM Pool Member  region=US  token=${user_token2}  vm_pool_name=name  org_name=MobiledgeX  use_defaults=False
   Should Be Equal  ${error}  ('code=403', 'error={"message":"Forbidden"}')

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

   ${super_token}=  Get Super Token
 
   Skip Verify Email  token=${super_token} 
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   #Verify Email  email_address=${emailepoch}
   Unlock User 
   ${user_token}=  Login  username=${epochusername}  password=${password}

   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
   #Verify Email  email_address=${emailepoch2}
   Unlock User 
   ${user_token2}=  Login  username=${epochusername2}  password=${password}

   Set Suite Variable  ${user_token}
   Set Suite Variable  ${user_token2}
   Set Suite Variable  ${epochusername2}
