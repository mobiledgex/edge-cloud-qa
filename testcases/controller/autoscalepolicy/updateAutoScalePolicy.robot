*** Settings ***
Documentation  UpdateAutoScalePolicy 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Test Cases ***
# ECQ-3543
UpdateAutoScalePolicy - shall be able to update with max values 
   [Documentation]
   ...  - send UpdateAutoScalePolicy with min_nodes=9  max_nodes=10  scale_up_cpu_threshold=100  scale_down_cpu_threshold=99  trigger_time=100000000
   ...  - verify policy is updated

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=9  max_nodes=10  scale_up_cpu_threshold=100  scale_down_cpu_threshold=99  trigger_time=100000000  use_defaults=False
   log to console  ${policy_return}

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name} 
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name} 
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              9
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              10 
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    100
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  99 
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}           100000000

# ECQ-3544
UpdateAutoScalePolicy - shall be able to update with min values
   [Documentation]
   ...  - send UpdateAutoScalePolicy with min_nodes=1  max_nodes=2  scale_up_cpu_threshold=2  scale_down_cpu_threshold=1  trigger_time=1 
   ...  - verify policy is updated

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=1  max_nodes=2  scale_up_cpu_threshold=2  scale_down_cpu_threshold=1  trigger_time=1  use_defaults=False
   log to console  ${policy_return}

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name} 
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name} 
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              1
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              2 
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    2
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  1 
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       1

# ECQ-3545
UpdateAutoScalePolicy - shall be able to update minnodes 
   [Documentation]
   ...  - send UpdateAutoScalePolicy with min_nodes=4
   ...  - verify policy is updated

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=4 

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              4
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              8
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    20
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  10
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       10

# ECQ-3546
UpdateAutoScalePolicy - shall be able to update maxnodes
   [Documentation]
   ...  - send UpdateAutoScalePolicy with max_nodes=7
   ...  - verify policy is updated

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  max_nodes=7

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              5
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              7
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    20
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  10
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       10

# ECQ-3547
UpdateAutoScalePolicy - shall be able to update minnodes and maxnodes
   [Documentation]
   ...  - send UpdateAutoScalePolicy with min_nodes=2 max_nodes=7
   ...  - verify policy is updated 

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=2  max_nodes=7

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              2
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              7
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    20
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  10
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       10

# ECQ-3548
UpdateAutoScalePolicy - shall be able to update with scaleup and scaledown 
   [Documentation]
   ...  - send UpdateAutoScalePolicy with scale_up_cpu_threshold=2  scale_down_cpu_threshold=1 
   ...  - verify policy is updated

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  scale_up_cpu_threshold=2  scale_down_cpu_threshold=1  use_defaults=False
   log to console  ${policy_return}

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              5
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              8
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    2
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  1
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       10 

# ECQ-3549
UpdateAutoScalePolicy - shall be able to update trigger_time
   [Documentation]
   ...  - send UpdateAutoScalePolicy with trigger_time=100
   ...  - verify policy is updated

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  trigger_time=100 
   log to console  ${policy_return}

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              5
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              8
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    20
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  10
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       100

# ECQ-3550
UpdateAutoScalePolicy - shall be able to update with all values
   [Documentation]
   ...  - send UpdateAutoScalePolicy with min_nodes=6  max_nodes=9  scale_up_cpu_threshold=21  scale_down_cpu_threshold=11  trigger_time=11
   ...  - verify policy is updated

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=6  max_nodes=9  scale_up_cpu_threshold=21  scale_down_cpu_threshold=11  trigger_time=11 

   Should Be Equal             ${policy_return['data']['key']['name']}            ${policy_name}
   Should Be Equal             ${policy_return['data']['key']['organization']}       ${developer_name}
   Should Be Equal As Numbers  ${policy_return['data']['min_nodes']}              6
   Should Be Equal As Numbers  ${policy_return['data']['max_nodes']}              9
   Should Be Equal As Numbers  ${policy_return['data']['scale_up_cpu_thresh']}    21
   Should Be Equal As Numbers  ${policy_return['data']['scale_down_cpu_thresh']}  11
   Should Be Equal As Numbers  ${policy_return['data']['trigger_time_sec']}       11

# ECQ-3551
UpdateAutoScalePolicy - shall be able to update with same values
   [Documentation]
   ...  - send UpdateAutoScalePolicy with same values as created
   ...  - verify policy is updated

   ${policy_return}=  Update Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=5  max_nodes=8  scale_up_cpu_threshold=20  scale_down_cpu_threshold=10  trigger_time=10 

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
   ${developer_name}=  Set Variable  ${developer_org_name_automation}

   Create Autoscale Policy  region=US  token=${token}  policy_name=${policy_name}  developer_org_name=${developer_name}  min_nodes=5  max_nodes=8  scale_up_cpu_threshold=20  scale_down_cpu_threshold=10  trigger_time=10

   Set Suite Variable  ${policy_name}
   Set Suite Variable  ${developer_name}
