*** Settings ***
Documentation  CreateOrgCloudletPool for users

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Suite Setup  Setup
Suite Teardown  Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-1685
ShowOrgCloudletPool - users shall get empty list 
   [Documentation]
   ...  - send ShowOrgCloudletPool with user token 
   ...  - verify empty list is received 

   ${error}=  Run Keyword and Expect Error  *  Show Org Cloudlet Pool  region=US  token=${userToken}

   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

# ECQ-1686
CreateOrgCloudletPool - users shall get error when creating org cloudlet pool 
   [Documentation]
   ...  - send CreateOrgCloudletPool with user token
   ...  - verify proper error is received

   #EDGECLOUD-1740 - MC API error message not consistent for 400 and 403 errors

   ${error}=  Run Keyword and Expect Error  *  Create Org Cloudlet Pool  region=US  token=${userToken}

   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

# ECQ-1687
DeleteOrgCloudletPool - users shall get error when deleting org cloudlet pool
   [Documentation]
   ...  - send DeleteOrgCloudletPool with user token
   ...  - verify proper error is received 

   #EDGECLOUD-1740 - MC API error message not consistent for 400 and 403 errors

   ${error}=  Run Keyword and Expect Error  *  Delete Org Cloudlet Pool  region=US  token=${userToken}

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
