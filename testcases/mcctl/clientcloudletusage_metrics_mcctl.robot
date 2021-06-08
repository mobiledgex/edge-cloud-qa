*** Settings ***
Documentation  Clientcloudletusage Metrics mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
${locationtile}=  -95.993532,35.995297_-96.011498,36.013385_2
${deviceos}=  Android
${devicecarrier}=  dmuus
${devicemodel}=  "platos S20"
${datanetworktype}=  5G

${version}=  latest

*** Test Cases ***
# ECQ-3451
Clientcloudletusage - mcctl shall be able to request clientcloudletusage latency metrics
   [Documentation]
   ...  - send clientcloudletusage latency metrics via mcctl with various parms
   ...  - verify success

   [Tags]  DMEPersistentConnection

   [Template]  Success Clientcloudletusage Latency Metrics Via mcctl
      selector=latency  cloudlet-org=${operator_name_fake}
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  locationtile=${locationtile}
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  devicecarrier=${devicecarrier} 
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  datanetworktype=${datanetworktype}
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  devicecarrier=${devicecarrier}  datanetworktype=${datanetworktype}
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=false
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=true
      selector=latency  cloudlet-org=${operator_name_fake}  last=1
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}  rawdata=true

# ECQ-3452
Clientcloudletusage - mcctl shall be able to request clientcloudletusage deviceinfo metrics
   [Documentation]
   ...  - send clientcloudletusage deviceinfo metrics via mcctl with various parms
   ...  - verify success

   [Tags]  DMEPersistentConnection

   [Template]  Success Clientcloudletusage DeviceInfo Metrics Via mcctl
      selector=deviceinfo  cloudlet-org=${operator_name_fake}
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  locationtile=${locationtile}
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  deviceos=${deviceos}
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  devicemodel=${devicemodel}
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  devicecarrier=${devicecarrier} 
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=false
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=true
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  last=1
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}  rawdata=true

# ECQ-3453
Clientcloudletusage - mcctl shall handle clientcloudletusage metrics failures
   [Documentation]
   ...  - send clientcloudletusage metrics via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  DMEPersistentConnection

   [Template]  Fail Clientcloudletusage Metrics Via mcctl
      # invalid values
      Error: missing required args: 
      Error: missing required args:                                                               selector=
      Error: missing required args:                                                               selector=x
      Error: missing required args:                                                               selector=latency
      Error: missing required args:                                                               selector=latency cloudlet=x
      Error: Bad Request (400), Invalid clientcloudletusage selector: custom                      selector=custom cloudlet-org=dmuus
      Error: Bad Request (400), Invalid clientcloudletusage selector: x                           selector=x cloudlet-org=dmuus
      Error: Bad Request (400), DeviceOS not allowed for cloudlet latency metric                  selector=latency  cloudlet-org=automation_dev_org  deviceos=x
      Error: Bad Request (400), DeviceModel not allowed for cloudlet latency metric               selector=latency  cloudlet-org=automation_dev_org  devicemodel=x
      Unable to parse "rawdata" value "x" as bool: invalid syntax, valid values are true, false   selector=latency  cloudlet-org=automation_dev_org  rawdata=x
      error decoding \\\'StartTime\\\'                                                            selector=latency  cloudlet-org=automation_dev_org  starttime=x
      error decoding \\\'EndTime\\\'                                                              selector=latency  cloudlet-org=automation_dev_org  endtime=x
      Unable to parse "last" value "x" as int: invalid syntax                                     selector=latency  cloudlet-org=automation_dev_org  last=x
      Error: Bad Request (400), DataNetworkType not allowed for cloudlet deviceinfo metric        selector=deviceinfo  cloudlet-org=dmuus  datanetworktype=x
      Error: missing required args:                                                               selector=deviceinfo
      Error: Bad Request (400), DataNetworkType not allowed for cloudlet deviceinfo metric        selector=deviceinfo  cloudlet-org=automation_dev_org  datanetworktype=x

*** Keywords ***
Setup
   ${end_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
   ${start_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ  increment=-24 hours

   Set Suite Variable  ${start_date}
   Set Suite Variable  ${end_date}

Success Clientcloudletusage Latency Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   #Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientcloudletusage region=${region} ${parmss}  version=${version}

   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
   Run Keyword If  'rawdata' not in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  latency-metric

Success Clientcloudletusage DeviceInfo Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientcloudletusage region=${region} ${parmss}  version=${version}

   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
   Run Keyword If  'rawdata' not in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  device-metric

Fail Clientcloudletusage Metrics Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  metrics clientcloudletusage region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
