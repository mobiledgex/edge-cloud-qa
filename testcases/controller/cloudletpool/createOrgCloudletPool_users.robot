*** Settings ***
Documentation  CreateOrgCloudletPool for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  mextester06123

*** Test Cases ***
ShowOrgCloudletPool - users shall get empty list 
   [Documentation]
   ...  send ShowOrgCloudletPoolMember with user token 
   ...  verify empty list is received 

   ${pool_return}=  Show Org Cloudlet Pool  region=US  token=${userToken}
   log to console  xxx ${pool_return}

   Should Be Empty  ${pool_return}

CreateOrgCloudletPool - users shall get error when creating org cloudlet pool 
   [Documentation]
   ...  send CreateOrgCloudletPool with user token
   ...  verify proper error is received

   EDGECLOUD-1740 - MC API error message not consistent for 400 and 403 errors

   ${error}=  Run Keyword and Expect Error  *  Create Org Cloudlet Pool  region=US  token=${userToken}

   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

DeleteOrgCloudletPool - users shall get error when deleting org cloudlet pool
   [Documentation]
   ...  send DeleteOrgCloudletPool with user token
   ...  verify proper error is received 

   EDGECLOUD-1740 - MC API error message not consistent for 400 and 403 errors

   ${error}=  Run Keyword and Expect Error  *  Delete Org Cloudlet Pool  region=US  token=${userToken}

   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Verify Email  email_address=${emailepoch}
   Unlock User

   ${userToken}=  Login  username=${epochusername}  password=${password}

   Set Suite Variable  ${userToken}
