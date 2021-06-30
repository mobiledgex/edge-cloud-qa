*** Settings ***
Documentation  CreateAutoScalePolicy for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
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
# ECQ-3532
CreateAutoScalePolicy - DeveloperManager shall be able to create a policy
   [Documentation]
   ...  - send CreateAutoScalePolicy/ShowAutoScalePolicy/UpdateAutoScalePolicy for DeveloperManager user
   ...  - verify success

   ${user_token2}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

   ${policy_return}=  Create Autoscale Policy  region=US  token=${user_token2}  #policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${policy_return['data']['key']['name']}  ${policy_name}

   ${policy_return2}=  Update Autoscale Policy  region=US  token=${user_token2}  policy_name=${policy_name}  developer_org_name=${developer_org_name_automation}  max_nodes=3
   Should Be Equal  ${policy_return2['data']['key']['name']}  ${policy_name}

# ECQ-3533
CreateAutoScalePolicy - DeveloperContributor shall be able to create a policy
   [Documentation]
   ...  - send CreateAutoScalePolicy/ShowAutoScalePolicy/UpdateAutoScalePolicy for DeveloperContributor user
   ...  - verify success

   ${user_token2}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

   ${policy_return}=  Create Autoscale Policy  region=US  token=${user_token2}  #policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1  use_defaults=False
   Should Be Equal  ${policy_return['data']['key']['name']}  ${policy_name}

   ${policy_return2}=  Update Autoscale Policy  region=US  token=${user_token2}  policy_name=${policy_name}  developer_org_name=${developer_org_name_automation}  max_nodes=3
   Should Be Equal  ${policy_return2['data']['key']['name']}  ${policy_name}

# ECQ-3534
CreateAutoScalePolicy - DeveloperViewer shall not be able to create a policy
   [Documentation]
   ...  - send CreateAutoScalePolicy/UpdateAutoScalePolicy for DeveloperContributor user
   ...  - verify proper error is received
   ...  - send ShowAutoScalePolicy for DeveloperContributor user
   ...  - verify success

   ${user_token}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

   ${error1}=  Run Keyword and Expect Error  *  Create Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error1}  ('code=403', 'error={"message":"Forbidden"}')

   ${error2}=  Run Keyword and Expect Error  *  Update Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error2}  ('code=403', 'error={"message":"Forbidden"}')

   ${policy_return}=  Show Autoscale Policy  region=US  token=${user_token}
   Length Should Be  ${policy_return}  0

   ${error4}=  Run Keyword and Expect Error  *  Delete Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error4}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-3535
CreateAutoScalePolicy - OperatorManager shall not be able to create a policy
   [Documentation]
   ...  - send CreateAutoScalePolicy/ShowAutoScalePolicy/UpdateAutoScalePolicy for OperatorManager user
   ...  - verify error

   ${user_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   ${error1}=  Run Keyword and Expect Error  *  Create Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error1}  ('code=403', 'error={"message":"Forbidden"}')

   ${error2}=  Run Keyword and Expect Error  *  Update Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error2}  ('code=403', 'error={"message":"Forbidden"}')

   ${error3}=  Run Keyword and Expect Error  *  Show Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error3}  ('code=403', 'error={"message":"Forbidden"}')

   ${error4}=  Run Keyword and Expect Error  *  Delete Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error4}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-3536
CreateAutoScalePolicy - OperatorContributor shall not be able to create a policy
   [Documentation]
   ...  - send CreateAutoScalePolicy/ShowAutoScalePolicy/UpdateAutoScalePolicy for OperatorContributor user
   ...  - verify error

   ${user_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

   ${error1}=  Run Keyword and Expect Error  *  Create Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error1}  ('code=403', 'error={"message":"Forbidden"}')

   ${error2}=  Run Keyword and Expect Error  *  Update Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error2}  ('code=403', 'error={"message":"Forbidden"}')

   ${error3}=  Run Keyword and Expect Error  *  Show Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error3}  ('code=403', 'error={"message":"Forbidden"}')

   ${error4}=  Run Keyword and Expect Error  *  Delete Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error4}  ('code=403', 'error={"message":"Forbidden"}')

# ECQ-3537
CreateAutoScalePolicy - OperatorViewer shall not be able to create a policy
   [Documentation]
   ...  - send CreateAutoScalePolicy/ShowAutoScalePolicy/UpdateAutoScalePolicy for OperatorViewer user
   ...  - verify error

   ${user_token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

   ${error1}=  Run Keyword and Expect Error  *  Create Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error1}  ('code=403', 'error={"message":"Forbidden"}')

   ${error2}=  Run Keyword and Expect Error  *  Update Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error2}  ('code=403', 'error={"message":"Forbidden"}')

   ${error3}=  Run Keyword and Expect Error  *  Show Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error3}  ('code=403', 'error={"message":"Forbidden"}')

   ${error4}=  Run Keyword and Expect Error  *  Delete Autoscale Policy  region=US  token=${user_token}
   Should Be Equal  ${error4}  ('code=403', 'error={"message":"Forbidden"}')

*** Keywords ***
Setup
   ${policy_name}=  Get Default Autoscale Policy Name
 
   Set Suite Variable  ${policy_name}
