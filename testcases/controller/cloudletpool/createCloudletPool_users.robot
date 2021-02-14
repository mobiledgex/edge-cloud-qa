*** Settings ***
Documentation  Show/Create/DeleteCloudletPool for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-1673
ShowCloudletPool - users shall get empty list 
   [Documentation]
   ...  - send ShowCloudletPool with user token 
   ...  - verify empty list is received 

   ${error}=  Run Keyword and Expect Error  *  Show Cloudlet Pool  region=US  token=${userToken}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   #${pool_return}=  Show Cloudlet Pool  region=US  token=${userToken}

   #Should Be Empty  ${pool_return}

# ECQ-1674
CreateCloudletPool - users shall get error when creating cloudlet pool 
   [Documentation]
   ...  - send CreateCloudletPool with user token
   ...  - verify proper error is received

   #EDGECLOUD-1740 - MC API error message not consistent for 400 and 403 errors

   ${error}=  Run Keyword and Expect Error  *  Create Cloudlet Pool  region=US  token=${userToken}

   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

# ECQ-1675
DeleteCloudletPool - users shall get error when deleting cloudlet pool
   [Documentation]
   ...  - send DeleteCloudletPool with user token
   ...  - verify proper error is received 

   #EDGECLOUD-1740 - MC API error message not consistent for 400 and 403 errors

   ${error}=  Run Keyword and Expect Error  *  Delete Cloudlet Pool  region=US  token=${userToken}

   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

*** Keywords ***
Setup
   ${epoch}=  Get Current Date  result_format=epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   #Verify Email  email_address=${emailepoch}
   Unlock User

   ${userToken}=  Login  username=${epochusername}  password=${password}

   Set Suite Variable  ${userToken}
