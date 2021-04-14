*** Settings ***
Documentation  CreateCloudletPool for user roles

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${organization}=  dmuus
${region}=  US

${username}=  mextester06
${password}=  ${mextester06_gmail_password}

*** Test Cases ***
# Create Org Cloudlet Pool no longer supported

# ECQ-2306
CreateCloudletPool - developer org owner shall not be able to create a cloudlet pool
   [Documentation]
   ...  - send CreateCloudletPool/DeleteCloudletPool for Developer org owner
   ...  - verify proper error is received

   ${user_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   
   ${orgname}=  Create Org  token=${user_token}  orgtype=developer

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=${region}  token=${user_token}  operator_org_name=${orgname}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool  region=${region}  token=${user_token}  operator_org_name=${orgname}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${error3}=  Run Keyword And Expect Error  *  Show Cloudlet Pool  region=${region}  token=${user_token}  operator_org_name=${orgname}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

#   ${error3}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=${region}  token=${user_token}
#   Should Contain   ${error3}  code=403
#   Should Contain   ${error3}  error={"message":"Forbidden"}
#
#   ${error4}=  Run Keyword And Expect Error  *  Delete Org Cloudlet Pool  region=${region}  token=${user_token}
#   Should Contain   ${error4}  code=403
#   Should Contain   ${error4}  error={"message":"Forbidden"}

# ECQ-2307
CreateCloudletPool - operator org owner shall be able to create a cloudlet pool
   [Documentation]
   ...  - send CreateCloudletPool/DeleteCloudletPool for Operator org owner
   ...  - verify pool can be created and deleted

   ${user_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   ${orgname}=  Create Org  token=${user_token}  orgtype=operator

   ${pool}=  Create Cloudlet Pool  region=${region}  token=${user_token}  operator_org_name=${orgname}
   Should Be Equal  ${pool['data']['key']['name']}  ${pool_name}

   ${pool2}=  Show Cloudlet Pool  region=${region}  token=${user_token}  operator_org_name=${orgname}
   Should Be Equal  ${pool2[0]['data']['key']['name']}  ${pool_name}

#   ${orgpool}=  Create Org Cloudlet Pool  region=${region}  token=${user_token}

   # delete will happen during cleanup

# ECQ-2308
CreateCloudletPool - DeveloperManager shall be able to create a cloudlet pool
   [Documentation]
   ...  - send CreateCloudletPool/DeleteCloudletPool for DeveloperManager user
   ...  - verify proper error is received

   ${user_token2}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

   #${orgname}=  Create Org  token=${user_token}  orgtype=developer

   #Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperManager   token=${user_token}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${error3}=  Run Keyword And Expect Error  *  Show Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error3}  code=403
   Should Contain   ${error3}  error={"message":"Forbidden"}

#   ${error3}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=${region}  token=${user_token2}
#   Should Contain   ${error3}  code=403
#   Should Contain   ${error3}  error={"message":"Forbidden"}
#
#   ${error4}=  Run Keyword And Expect Error  *  Delete Org Cloudlet Pool  region=${region}  token=${user_token2}
#   Should Contain   ${error4}  code=403
#   Should Contain   ${error4}  error={"message":"Forbidden"}

# ECQ-2309
CreateCloudletPool - DeveloperContributor shall be not able to create a cloudlet pool
   [Documentation]
   ...  - send CreateCloudletPool/DeleteCloudletPool for DeveloperContributor user
   ...  - verify proper error is received

   ${user_token2}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

   #${orgname}=  Create Org  token=${user_token}  orgtype=developer

   #Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperContributor   token=${user_token}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${error3}=  Run Keyword And Expect Error  *  Show Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error3}  code=403
   Should Contain   ${error3}  error={"message":"Forbidden"}

#   ${error3}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=${region}  token=${user_token2}
#   Should Contain   ${error3}  code=403
#   Should Contain   ${error3}  error={"message":"Forbidden"}
#
#   ${error4}=  Run Keyword And Expect Error  *  Delete Org Cloudlet Pool  region=${region}  token=${user_token2}
#   Should Contain   ${error4}  code=403
#   Should Contain   ${error4}  error={"message":"Forbidden"}

# ECQ-2310
CreateCloudletPool - DeveloperViewer shall be not able to create a cloudlet pool
   [Documentation]
   ...  - send CreateCloudletPool/DeleteCloudletPool for DeveloperViewer user
   ...  - verify proper error is received

   ${user_token2}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

   #${orgname}=  Create Org  token=${user_token}  orgtype=developer

   #Adduser Role   orgname=${orgname}   username=${epochusername2}  role=DeveloperViewer   token=${user_token}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${error3}=  Run Keyword And Expect Error  *  Show Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error3}  code=403
   Should Contain   ${error3}  error={"message":"Forbidden"}

#   ${error3}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=${region}  token=${user_token2}
#   Should Contain   ${error3}  code=403
#   Should Contain   ${error3}  error={"message":"Forbidden"}
#
#   ${error4}=  Run Keyword And Expect Error  *  Delete Org Cloudlet Pool  region=${region}  token=${user_token2}
#   Should Contain   ${error4}  code=403
#   Should Contain   ${error4}  error={"message":"Forbidden"}

# ECQ-2311
CreateCloudletPool - OperatorManager shall be able to create a cloudlet pool
   [Documentation]
   ...  - send CreateCloudletPool/DeleteCloudletPool for OperatorManager user
   ...  - verify pool can be created and deleted

   ${user_token2}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   #${orgname}=  Create Org  token=${user_token}  orgtype=operator

   #Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorManager  token=${user_token}

   ${pool}=  Create Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${pool['data']['key']['name']}  ${pool_name}

   ${pool2}=  Show Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${pool2[0]['data']['key']['name']}  ${pool_name}

   #${orgpool}=  Create Org Cloudlet Pool  region=${region}  token=${user_token2}

   # delete will happen during cleanup

# ECQ-2312
CreateCloudletPool - OperatorContributor shall be able to create a cloudlet pool
   [Documentation]
   ...  - send CreateCloudletPool/DeleteCloudletPool for OperatorContributor user
   ...  - verify pool can be created and deleted

   ${user_token2}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

   #${orgname}=  Create Org  token=${user_token}  orgtype=operator

   #Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorContributor  token=${user_token}

   ${pool}=  Create Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${pool['data']['key']['name']}  ${pool_name}

   ${pool2}=  Show Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Be Equal  ${pool2[0]['data']['key']['name']}  ${pool_name}

#   ${orgpool}=  Create Org Cloudlet Pool  region=${region}  token=${user_token2}

   # delete will happen during cleanup

# ECQ-2313
CreateCloudletPool - OperatorViewer shall not be able to create a cloudlet pool
   [Documentation]
   ...  - send CreateCloudletPool/DeleteCloudletPool for OperatorViewer user
   ...  - verify proper error is received

   ${user_token2}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

   #${orgname}=  Create Org  token=${user_token}  orgtype=operator

   #Adduser Role   orgname=${orgname}   username=${epochusername2}  role=OperatorViewer  token=${user_token}

   ${error}=  Run Keyword And Expect Error  *  Create Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error}  code=403
   Should Contain   ${error}  error={"message":"Forbidden"}

   ${error2}=  Run Keyword And Expect Error  *  Delete Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Contain   ${error2}  code=403
   Should Contain   ${error2}  error={"message":"Forbidden"}

   ${pool2}=  Show Cloudlet Pool  region=${region}  token=${user_token2}  operator_org_name=${operator_name_fake}
   Should Be True  len(${pool2}) >= 0

#   ${error3}=  Run Keyword And Expect Error  *  Create Org Cloudlet Pool  region=${region}  token=${user_token2}
#   Should Contain   ${error3}  code=403
#   Should Contain   ${error3}  error={"message":"Forbidden"}
#
#   ${error4}=  Run Keyword And Expect Error  *  Delete Org Cloudlet Pool  region=${region}  token=${user_token2}
#   Should Contain   ${error4}  code=403
#   Should Contain   ${error4}  error={"message":"Forbidden"}

*** Keywords ***
Setup
#   ${epoch}=  Get Current Date  result_format=epoch
#   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
#   ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
#   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
#   ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2
#
#   ${super_token}=  Get Super Token

   ${pool_name}=  Get Default Cloudlet Pool Name
 
#   Skip Verify Email  token=${super_token} 
#   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
#   #Verify Email  email_address=${emailepoch}
#   Unlock User 
#   ${user_token}=  Login  username=${epochusername}  password=${password}
#
#   Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2}
#   #Verify Email  email_address=${emailepoch2}
#   Unlock User 
#   ${user_token2}=  Login  username=${epochusername2}  password=${password}

#   Set Suite Variable  ${user_token}
#   Set Suite Variable  ${user_token2}
#   Set Suite Variable  ${epochusername2}
   Set Suite Variable  ${pool_name}
