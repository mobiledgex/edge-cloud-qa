*** Settings ***
Documentation  CreateTrustPolicyException for user roles

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  DateTime

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${username}=  mextester06
${password}=  ${mextester06_gmail_password}

${region}=  US

*** Test Cases ***
# ECQ-4127
CreateTrustPolicyException - OperatorManager shall be able to show/update but not create/delete a trust policy exception
   [Documentation]
   ...  - login as OperatorManager 
   ...  - do CreateTrustPolicy/ShowTrustPolicy/DeleteTrustPolicy/UpdateTrustPolicy Exception
   ...  - verify show and update work but not create and delete

   [Tags]  TrustPolicyException

   ${user_token2}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${super_token}  
   ${exception_create}=  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${super_token}  region=${region}  rule_list=${rulelist}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  rule_list=${rulelist} 
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   ${show}=  Show Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   ${exception_update}=  Update Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  state=Active

   Length Should Be  ${show}  1

   Should Be Equal  ${show[0]['data']['key']['name']}  ${exception_create['data']['key']['name']}
   Should Be Equal  ${exception_update['data']['key']['name']}  ${exception_create['data']['key']['name']}

# ECQ-4128
CreateTrustPolicyException - OperatorContributor shall be able to show/update but not create/delete a trust policy exception
   [Documentation]
   ...  - login as OperatorContributor
   ...  - do CreateTrustPolicy/ShowTrustPolicy/DeleteTrustPolicy/UpdateTrustPolicy Exception
   ...  - verify show and update work but not create and delete

   [Tags]  TrustPolicyException

   ${user_token2}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${super_token}
   ${exception_create}=  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${super_token}  region=${region}  rule_list=${rulelist}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  rule_list=${rulelist}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   ${show}=  Show Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   ${exception_update}=  Update Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  state=Active

   Length Should Be  ${show}  1

   Should Be Equal  ${show[0]['data']['key']['name']}  ${exception_create['data']['key']['name']}
   Should Be Equal  ${exception_update['data']['key']['name']}  ${exception_create['data']['key']['name']}

# ECQ-4129
CreateTrustPolicyException - OperatorViewer shall be able to show but not create/delete/update a trust policy exception
   [Documentation]
   ...  - login as OperatorViewer
   ...  - do CreateTrustPolicy/ShowTrustPolicy/DeleteTrustPolicy/UpdateTrustPolicy Exception
   ...  - verify show works but not create, delete or update

   [Tags]  TrustPolicyException

   ${user_token2}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${super_token}
   ${exception_create}=  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${super_token}  region=${region}  rule_list=${rulelist}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  rule_list=${rulelist}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  state=Active

   ${show}=  Show Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   Length Should Be  ${show}  1

   Should Be Equal  ${show[0]['data']['key']['name']}  ${exception_create['data']['key']['name']}

# ECQ-4130
CreateTrustPolicyException - DeveloperManager shall be able to create/delete/show/update a trust policy exception
   [Documentation]
   ...  - login as DeveloperManager
   ...  - do CreateTrustPolicy/ShowTrustPolicy/DeleteTrustPolicy/UpdateTrustPolicy Exception
   ...  - verify all work

   [Tags]  TrustPolicyException

   ${user_token2}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${super_token}

   ${policy}=  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  rule_list=${rulelist}
   ${policy_show}=  Show Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  
   ${policy_update}=  Update Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   Should Be Equal  ${policy['data']['key']['name']}  ${policy_name}
   Should Be Equal  ${policy['data']['state']}   ApprovalRequested

   Should Be Equal  ${policy_show[0]['data']['key']['name']}  ${policy['data']['key']['name']}

   Should Be Equal  ${policy_update['data']['key']['name']}  ${policy_name}
   Should Be Equal  ${policy_update['data']['state']}   ApprovalRequested

# ECQ-4131
CreateTrustPolicyException - DeveloperContributor shall be able to create/delete/show/update a trust policy exception
   [Documentation]
   ...  - login as DeveloperContributor
   ...  - do CreateTrustPolicy/ShowTrustPolicy/DeleteTrustPolicy/UpdateTrustPolicy Exception
   ...  - verify all work

   [Tags]  TrustPolicyException

   ${user_token2}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${super_token}

   ${policy}=  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  rule_list=${rulelist}
   ${policy_show}=  Show Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}
   ${policy_update}=  Update Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   Should Be Equal  ${policy['data']['key']['name']}  ${policy_name}
   Should Be Equal  ${policy['data']['state']}   ApprovalRequested

   Should Be Equal  ${policy_show[0]['data']['key']['name']}  ${policy['data']['key']['name']}

   Should Be Equal  ${policy_update['data']['key']['name']}  ${policy_name}
   Should Be Equal  ${policy_update['data']['state']}   ApprovalRequested

# ECQ-4132
CreateTrustPolicyException - DeveloperViewer shall be able to show but not create/delete/update a trust policy exception
   [Documentation]
   ...  - login as DeveloperViewer
   ...  - do CreateTrustPolicy/ShowTrustPolicy/DeleteTrustPolicy/UpdateTrustPolicy Exception
   ...  - verify only show works

   [Tags]  TrustPolicyException

   ${user_token2}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}

   &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/3
   &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=1.1.1.1/1
   &{rule3}=  Create Dictionary  protocol=udp  port_range_minimum=3  port_range_maximum=6   remote_cidr=1.1.1.1/2
   @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  token=${super_token}
   ${policy}=  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${super_token}  region=${region}  rule_list=${rulelist}

   ${show}=  Show Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}  rule_list=${rulelist}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}
   Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Trust Policy Exception  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}  cloudlet_pool_name=${pool['data']['key']['name']}  cloudlet_pool_org_name=${pool['data']['key']['organization']}  token=${user_token2}  region=${region}

   Should Be Equal  ${show[0]['data']['key']['name']}  ${policy['data']['key']['name']}

*** Keywords ***
Setup
   ${super_token}=  Get Super Token

   ${policy_name}=  Get Default Trust Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}

   Set Suite Variable  ${super_token}

Teardown
   Cleanup Provisioning
