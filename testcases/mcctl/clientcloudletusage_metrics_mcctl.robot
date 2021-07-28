*** Settings ***
Documentation  Clientcloudletusage Metrics mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  Collections
Library  String
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX
#${locationtile}=  -95.993532,35.995297_-96.011498,36.013385_2
#${locationtile}=  -95.993532,35.995297_-96.002515,36.004341_1
${locationtile}=  -90.998922,30.993940_-91.007905,31.002985_1
${deviceos}=  Android
${devicecarrier}=  tmusz
${devicemodel}=  "Samsung S20"
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
      selector=latency  cloudlet-org=${operator_name_fake}  limit=1
      selector=latency  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  limit=100  starttime=${start_date}  endtime=${end_date}
      selector=latency  cloudlet-org=${operator_name_fake}  numsamples=1
      selector=latency  cloudlet-org=${operator_name_fake}  numsamples=100  starttime=${start_date}  endtime=${end_date}
      selector=latency  cloudlet-org=${operator_name_fake}  startage=12h
      selector=latency  cloudlet-org=${operator_name_fake}  endage=1s
      selector=latency  cloudlet-org=${operator_name_fake}  startage=12h  endage=1s

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
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  limit=1
      selector=deviceinfo  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  limit=1  starttime=${start_date}  endtime=${end_date}
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  numsamples=1
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  numsamples=100  starttime=${start_date}  endtime=${end_date}
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  startage=12h
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  endage=1s
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  startage=12h  endage=1s

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
      Error: Bad Request (400), Invalid clientcloudletusage selector: custom                      selector=custom cloudlet-org=tmus
      Error: Bad Request (400), Invalid clientcloudletusage selector: x                           selector=x cloudlet-org=tmus
      Error: Bad Request (400), DeviceOS not allowed for cloudlet latency metric                  selector=latency  cloudlet-org=automation_dev_org  deviceos=x
      Error: Bad Request (400), DeviceModel not allowed for cloudlet latency metric               selector=latency  cloudlet-org=automation_dev_org  devicemodel=x
      Error: parsing arg "starttime\=x" failed: unable to parse "x" as time: invalid format, valid values are RFC3339 format, i.e. "2006-01-02T15:04:05Z07:00"               selector=latency  cloudlet-org=automation_dev_org  starttime=x
      Error: parsing arg "endtime\=x" failed: unable to parse "x" as time: invalid format, valid values are RFC3339 format, i.e. "2006-01-02T15:04:05Z07:00"                 selector=latency  cloudlet-org=automation_dev_org  endtime=x
      Error: parsing arg "startage\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc         selector=latency  cloudlet-org=automation_dev_org  startage=x
      Error: parsing arg "endage\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc           selector=latency  cloudlet-org=automation_dev_org  endage=x
      Error: parsing arg "limit\=x" failed: unable to parse "x" as int: invalid syntax                                    selector=latency  cloudlet-org=automation_dev_org  limit=x
      Error: Bad Request (400), DataNetworkType not allowed for cloudlet deviceinfo metric        selector=deviceinfo  cloudlet-org=tmus  datanetworktype=x
      Error: missing required args:                                                               selector=deviceinfo
      Error: Bad Request (400), DataNetworkType not allowed for cloudlet deviceinfo metric        selector=deviceinfo  cloudlet-org=automation_dev_org  datanetworktype=x
      Error: parsing arg "numsamples\=x" failed: unable to parse "x" as int: invalid syntax             selector=latency  cloudlet-org=automation_dev_org  numsamples=x

*** Keywords ***
Setup
   ${epochnow}=  Get Current Date  result_format=epoch
   #${epochnow}=  Evaluate  calendar.timegm(time.strptime('${now}', '%Y-%m-%dT%H:%M:%S'))  modules=calendar
   ${epochstart}=  Evaluate  ${epochnow} - 86400
   ${start_date}=  Evaluate  time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(${epochstart}))
   ${end_date}=  Evaluate  time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(${epochnow}))

   #${end_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
   #${start_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ  increment=-24 hours
   
   Update Settings  region=${region}  edge_events_metrics_collection_interval=5s  location_tile_side_length_km=1
   Sleep  10s

   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
   ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=31  longitude=-91

   Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloudlet.edge_events_cookie}') > 100

   @{samples}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${170.45}

   ${devicemodel_modify}=  Replace String  ${devicemodel}  "  ${Empty}
   Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  device_model=${devicemodel_modify}  device_os=${deviceos}  carrier_name=${devicecarrier}  data_network_type=${datanetworktype}  latitude=31  longitude=-91

   ${latency}=  Send Latency Edge Event  edge_events_cookie=${cloudlet.edge_events_cookie}  carrier_name=${devicecarrier}  data_network_type=${datanetworktype}  latitude=31  longitude=-91  samples=${samples}

   Sleep  10s

   Set Suite Variable  ${start_date}
   Set Suite Variable  ${end_date}

Success Clientcloudletusage Latency Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   #Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientcloudletusage region=${region} ${parmss}  version=${version}

   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  latency-metric

#   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
#   Run Keyword If  'numsamples' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
#   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  latency-metric

Success Clientcloudletusage DeviceInfo Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientcloudletusage region=${region} ${parmss}  version=${version}

   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  device-metric

#   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
#   Run Keyword If  'rawdata' not in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
#   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  device-metric

Fail Clientcloudletusage Metrics Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  metrics clientcloudletusage region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
