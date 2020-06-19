*** Settings ***
Documentation  CreateAutoProvPolicy 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Test Cases ***
CreateAutoProvPolicy - shall be able to create with min parms 
   [Documentation]
   ...  send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1 
   ...  verify policy is created 

   ${policy_return}=  Create Auto Provisioning Policy  region=US  token=${token}  deploy_client_count=1

   Should Be Equal             ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}  ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['deploy_client_count']}  1

   Dictionary Should Not Contain Key  ${policy_return['data']}  deploy_interval_count
   Dictionary Should Not Contain Key  ${policy_return['data']}  min_active_instances
   Dictionary Should Not Contain Key  ${policy_return['data']}  max_instances

# have to create 9999 cloudlets. not reasonable
#CreateAutoProvPolicy - shall be able to create with max values 
#   [Documentation]
#   ...  send CreateAutoProvPolicy with 9999 for all values
#   ...  verify policy is created
#
#   ${policy_return}=  Create Auto Provisioning Policy  region=US  token=${token}  deploy_client_count=9999  deploy_interval_count=9999  min_active_instances=9999  max_instances=9999
#
#   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name} 
#   Should Be Equal             ${policy_return['data']['key']['developer']}       ${developer_name} 
#   Should Be Equal As Numbers  ${policy_return['data']['min_active_instances']}   9999 
#   Should Be Equal As Numbers  ${policy_return['data']['max_instances']}          9999 
#   Should Be Equal As Numbers  ${policy_return['data']['deploy_client_count']}    9999 
#   Should Be Equal As Numbers  ${policy_return['data']['deploy_interval_count']}  9999 

CreateAutoProvPolicy - shall be able to create with min values
   [Documentation]
   ...  send CreateAutoProvPolicy with min values
   ...  verify proper error is received

   ${policy_return}=  Create Auto Provisioning Policy  region=US  token=${token}  deploy_client_count=1  deploy_interval_count=0  min_active_instances=0  max_instances=0

   Should Be Equal             ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}  ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['deploy_client_count']}  1

   Dictionary Should Not Contain Key  ${policy_return['data']}  deploy_interval_count
   Dictionary Should Not Contain Key  ${policy_return['data']}  min_active_instances
   Dictionary Should Not Contain Key  ${policy_return['data']}  max_instances

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Auto Provisioning Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
