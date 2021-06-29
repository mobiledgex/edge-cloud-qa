*** Settings ***
Documentation  CreateAutoScalePolicy 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-3506
CreateAutoScalePolicy - shall be able to create with min parms 
   [Documentation]
   ...  - send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1 
   ...  - verify policy is created

   ${policy_return}=  Create Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=1  use_defaults=False
   log to console  ${policy_return} 

   Should Be Equal             ${policy_return['data']['key']['name']}          ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}     ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}            1 
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}            2
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}  1

   Dictionary Should Not Contain Key  ${policy_return['data']}  scale_down_cpu_thresh
   Dictionary Should Not Contain Key  ${policy_return['data']}  trigger_time_sec

# ECQ-3507
CreateAutoScalePolicy - shall be able to create with max values 
   [Documentation]
   ...  - send CreateAutoScalePolicy with min_nodes=9  max_nodes=10  scale_up_cpu_threshold=100  scale_down_cpu_threshold=99  trigger_time=100000000
   ...  - verify policy is created

   ${policy_return}=  Create Autoscale Policy  region=US  token=${token}  policy_name=aasdfadfasdfasdfasfdadfasdfadsfadsfasdfasdffasdfdasafdsewrqwerqwerwerqerqerqw  developer_org_name=${developer_name}  min_nodes=9  max_nodes=10  scale_up_cpu_threshold=100  scale_down_cpu_threshold=99  trigger_time=100000000  use_defaults=False
   log to console  ${policy_return}

   Should Be Equal             ${policy_return['data']['key']['name']}            aasdfadfasdfasdfasfdadfasdfadsfadsfasdfasdffasdfdasafdsewrqwerqwerwerqerqerqw 
   Should Be Equal             ${policy_return['data']['key']['organization']}    ${developer_name} 
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              9
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              10 
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    100
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  99 
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}           100000000

# ECQ-3508
CreateAutoScalePolicy - shall be able to create with min values
   [Documentation]
   ...  - send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=2  scale_down_cpu_threshold=1  trigger_time=1 
   ...  - verify policy is created

   ${policy_return}=  Create Autoscale Policy  region=US  token=${token}  policy_name=a  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=2  scale_down_cpu_threshold=1  trigger_time=1  use_defaults=False
   log to console  ${policy_return}

   Should Be Equal             ${policy_return['data']['key']['name']}            a 
   Should Be Equal             ${policy_return['data']['key']['organization']}    ${developer_name} 
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              1
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              2 
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    2
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  1 
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       1

# ECQ-3509
CreateAutoScalePolicy - shall be able to create with scaleup and scaledown 
   [Documentation]
   ...  - send CreateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=2  scale_down_cpu_threshold=1 
   ...  - verify policy is created

   ${policy_return}=  Create Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=2  scale_down_cpu_threshold=1  use_defaults=False
   log to console  ${policy_return}

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              1
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              2
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    2
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  1

   Dictionary Should Not Contain Key  ${policy_return['data']}  trigger_time_sec       

# ECQ-3510
CreateAutoScalePolicy - shall be able to create with all values
   [Documentation]
   ...  - send CreateAutoScalePolicy with min_nodes=5  max_nodes=8  scale_up_cpu_threshold=20  scale_down_cpu_threshold=10  trigger_time=10
   ...  - verify policy is created

   ${policy_return}=  Create Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=5  max_nodes=8  scale_up_cpu_threshold=20  scale_down_cpu_threshold=10  trigger_time=10  use_defaults=False
   log to console  ${policy_return}

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              5
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              8
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    20
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  10
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       10

*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${policy_name}=  Get Default Auto Scale Policy Name
   ${developer_name}=  Get Default Developer Name

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
