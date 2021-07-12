*** Settings ***
Documentation   GetQosPositionKpi Testcases 

Library         MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         Collections

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com

*** Test Cases ***
# ECQ-2179
GetQosPositionKpi - request shall return 0 position
   [Documentation]
   ...  registerClient with samsung app
   ...  send GetQosPositionKpi with no position 
   ...  verify returns empty result

   Register Client      developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
   ${qos}=  Get Qos Position KPI  

   Should Be Equal As Integers   ${qos['result']['ver']}     0
   Should Be Equal               ${qos['result']['status']}  RsSuccess

   Length Should Be              ${qos['result']['tags']}  0
   Length Should Be              ${qos['result']['position_results']}  0

# ECQ-2180
GetQosPositionKpi - request shall return 1 position 
   [Documentation]
   ...  registerClient with samsung app
   ...  send GetQosPositionKpi with 1 position
   ...  verify returns 1 result

   &{position1}=  Create Dictionary  position_id=1  latitude=1  longitude=1 
   @{positionlist}=  Create List  ${position1}

   Register Client	developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
   ${qos}=  Get Qos Position KPI  position_list=${positionlist} 

   Should Be Equal As Integers   ${qos['result']['ver']}     0 
   Should Be Equal               ${qos['result']['status']}  RsSuccess 

   Should Be Equal               ${qos['result']['position_results'][0]['positionid']}                           1 
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['latitude']}             1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['longitude']}            1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['horizontal_accuracy']}  0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['vertical_accuracy']}    0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['altitude']}             0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['course']}               0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['speed']}                0
   Should Be Equal               ${qos['result']['position_results'][0]['gps_location']['timestamp']}            ${None} 

   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_max']} > 0

   Length Should Be              ${qos['result']['tags']}  0
   Length Should Be              ${qos['result']['position_results']}  1

# ECQ-2181
GetQosPositionKpi - request shall return multiple positions
   [Documentation]
   ...  registerClient with samsung app
   ...  send GetQosPositionKpi with multiple positions
   ...  verify returns all results

   ${num_positions}=  Set Variable  ${100}
   @{positionlist}=  Create List  

   FOR  ${index}  IN RANGE  1  ${num_positions} 
      &{position}=  Create Dictionary  position_id=${index}  latitude=${index}  longitude=${index}
      Append To List  ${positionlist}  ${position}
   END

   Register Client      developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
   ${qos}=  Get Qos Position KPI  position_list=${positionlist}

   Should Be Equal As Integers   ${qos['result']['ver']}     0
   Should Be Equal               ${qos['result']['status']}  RsSuccess

   FOR  ${index}  IN RANGE  1  ${num_positions} 
      Should Be Equal As Strings    ${qos['result']['position_results'][${index}-1]['positionid']}                           ${index} 
      Should Be Equal As Integers   ${qos['result']['position_results'][${index}-1]['gps_location']['latitude']}             ${index} 
      Should Be Equal As Integers   ${qos['result']['position_results'][${index}-1]['gps_location']['longitude']}            ${index} 
      Should Be Equal As Integers   ${qos['result']['position_results'][${index}-1]['gps_location']['horizontal_accuracy']}  0
      Should Be Equal As Integers   ${qos['result']['position_results'][${index}-1]['gps_location']['vertical_accuracy']}    0
      Should Be Equal As Integers   ${qos['result']['position_results'][${index}-1]['gps_location']['altitude']}             0
      Should Be Equal As Integers   ${qos['result']['position_results'][${index}-1]['gps_location']['course']}               0
      Should Be Equal As Integers   ${qos['result']['position_results'][${index}-1]['gps_location']['speed']}                0
      Should Be Equal               ${qos['result']['position_results'][${index}-1]['gps_location']['timestamp']}            ${None}

      Should Be True  ${qos['result']['position_results'][${index}-1]['dluserthroughput_min']} > 0
      Should Be True  ${qos['result']['position_results'][${index}-1]['dluserthroughput_avg']} > 0
      Should Be True  ${qos['result']['position_results'][${index}-1]['dluserthroughput_max']} > 0
      Should Be True  ${qos['result']['position_results'][${index}-1]['uluserthroughput_min']} > 0
      Should Be True  ${qos['result']['position_results'][${index}-1]['uluserthroughput_avg']} > 0
      Should Be True  ${qos['result']['position_results'][${index}-1]['uluserthroughput_max']} > 0
      Should Be True  ${qos['result']['position_results'][${index}-1]['latency_min']} > 0
      Should Be True  ${qos['result']['position_results'][${index}-1]['latency_avg']} > 0
      Should Be True  ${qos['result']['position_results'][${index}-1]['latency_max']} > 0
   END

   Length Should Be              ${qos['result']['tags']}  0
   Length Should Be              ${qos['result']['position_results']}  ${num_positions-1} 

# ECQ-2182
GetQosPositionKpi - request with lte shall return 1 position
   [Documentation]
   ...  registerClient with samsung app
   ...  send GetQosPositionKpi with 1 position and lte_category
   ...  verify returns 1 result

   &{position1}=  Create Dictionary  position_id=1  latitude=1  longitude=1
   @{positionlist}=  Create List  ${position1}

   Register Client      developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
   ${qos}=  Get Qos Position KPI  position_list=${positionlist}  lte_category=3

   Should Be Equal As Integers   ${qos['result']['ver']}     0
   Should Be Equal               ${qos['result']['status']}  RsSuccess

   Should Be Equal               ${qos['result']['position_results'][0]['positionid']}                           1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['latitude']}             1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['longitude']}            1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['horizontal_accuracy']}  0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['vertical_accuracy']}    0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['altitude']}             0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['course']}               0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['speed']}                0
   Should Be Equal               ${qos['result']['position_results'][0]['gps_location']['timestamp']}            ${None}

   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_max']} > 0

   Length Should Be              ${qos['result']['tags']}  0
   Length Should Be              ${qos['result']['position_results']}  1

# ECQ-2183
GetQosPositionKpi - request with latitude only shall return 1 position
   [Documentation]
   ...  registerClient with samsung app and latitude only
   ...  send GetQosPositionKpi with 1 position
   ...  verify returns 1 result

   &{position1}=  Create Dictionary  position_id=1  latitude=1
   @{positionlist}=  Create List  ${position1}

   Register Client      developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
   ${qos}=  Get Qos Position KPI  position_list=${positionlist}

   Should Be Equal As Integers   ${qos['result']['ver']}     0
   Should Be Equal               ${qos['result']['status']}  RsSuccess

   Should Be Equal               ${qos['result']['position_results'][0]['positionid']}                           1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['latitude']}             1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['longitude']}            0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['horizontal_accuracy']}  0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['vertical_accuracy']}    0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['altitude']}             0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['course']}               0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['speed']}                0
   Should Be Equal               ${qos['result']['position_results'][0]['gps_location']['timestamp']}            ${None}

   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_max']} > 0

   Length Should Be              ${qos['result']['tags']}  0
   Length Should Be              ${qos['result']['position_results']}  1

# ECQ-2184
GetQosPositionKpi - request with longitude only shall return 1 position
   [Documentation]
   ...  registerClient with samsung app and longitude only
   ...  send GetQosPositionKpi with 1 position
   ...  verify returns 1 result

   &{position1}=  Create Dictionary  longitude=1
   @{positionlist}=  Create List  ${position1}

   Register Client      developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
   ${qos}=  Get Qos Position KPI  position_list=${positionlist}

   Should Be Equal As Integers   ${qos['result']['ver']}     0
   Should Be Equal               ${qos['result']['status']}  RsSuccess

   Should Be Equal               ${qos['result']['position_results'][0]['positionid']}                           0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['latitude']}             0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['longitude']}            1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['horizontal_accuracy']}  0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['vertical_accuracy']}    0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['altitude']}             0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['course']}               0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['speed']}                0
   Should Be Equal               ${qos['result']['position_results'][0]['gps_location']['timestamp']}            ${None}

   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_max']} > 0

   Length Should Be              ${qos['result']['tags']}  0
   Length Should Be              ${qos['result']['position_results']}  1

# ECQ-2185
GetQosPositionKpi - request with position_id only shall return 1 position
   [Documentation]
   ...  registerClient with samsung app and position_id only
   ...  send GetQosPositionKpi with 1 position
   ...  verify returns 1 result

   &{position1}=  Create Dictionary  position_id=1
   @{positionlist}=  Create List  ${position1}

   Register Client      developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}
   ${qos}=  Get Qos Position KPI  position_list=${positionlist}

   Should Be Equal As Integers   ${qos['result']['ver']}     0
   Should Be Equal               ${qos['result']['status']}  RsSuccess

   Should Be Equal               ${qos['result']['position_results'][0]['positionid']}                           1
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['latitude']}             0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['longitude']}            0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['horizontal_accuracy']}  0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['vertical_accuracy']}    0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['altitude']}             0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['course']}               0
   Should Be Equal As Integers   ${qos['result']['position_results'][0]['gps_location']['speed']}                0
   Should Be Equal               ${qos['result']['position_results'][0]['gps_location']['timestamp']}            ${None}

   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['dluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['uluserthroughput_max']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_min']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_avg']} > 0
   Should Be True  ${qos['result']['position_results'][0]['latency_max']} > 0

   Length Should Be              ${qos['result']['tags']}  0
   Length Should Be              ${qos['result']['position_results']}  1

*** Keywords ***
Setup
    Create Flavor
    Run Keyword and Ignore Error  Create App  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  official_fqdn=${samsung_uri} 

