*** Settings ***
Documentation  Clientappusage Metrics mcctl

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
${locationtile}=  -95.993532,35.995297_-96.002515,36.004341_1
${deviceos}=  Android
${devicecarrier}=  tmusz
${devicemodel}=  "Samsung S20"
${datanetworktype}=  5G

${version}=  latest

*** Test Cases ***
# ECQ-3363
Clientappusage - mcctl shall be able to request clientappusage latency metrics
   [Documentation]
   ...  - send clientappusage latency metrics via mcctl with various parms
   ...  - verify success

   [Tags]  DMEPersistentConnection

   [Template]  Success Clientappusage Latency Metrics Via mcctl
      selector=latency  app-org=${developer_org_name_automation}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  locationtile=${locationtile}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  limit=1
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  limit=1  starttime=${start_date}  endtime=${end_date}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  datanetworktype=${datanetworktype}
      selector=latency  app-org=${developer_org_name_automation}  numsamples=1
      selector=latency  app-org=${developer_org_name_automation}  numsamples=1  starttime=${start_date}  endtime=${end_date}
      selector=latency  app-org=${developer_org_name_automation}  startage=12h
      selector=latency  app-org=${developer_org_name_automation}  endage=1s
      selector=latency  app-org=${developer_org_name_automation}  startage=12h  endage=1s

# ECQ-3405
Clientappusage - mcctl shall be able to request clientappusage deviceinfo metrics
   [Documentation]
   ...  - send clientappusage deviceinfo metrics via mcctl with various parms
   ...  - verify success

   [Tags]  DMEPersistentConnection

   [Template]  Success Clientappusage DeviceInfo Metrics Via mcctl
      selector=deviceinfo  app-org=${developer_org_name_automation}
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  limit=1
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  limit=1  starttime=${start_date}  endtime=${end_date}
      selector=deviceinfo  app-org=${developer_org_name_automation}  deviceos=${deviceos}
      selector=deviceinfo  app-org=${developer_org_name_automation}  devicemodel=${devicemodel}
      selector=deviceinfo  app-org=${developer_org_name_automation}  datanetworktype=${datanetworktype}
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  deviceos=${deviceos}
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  devicemodel=${devicemodel}
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  datanetworktype=${datanetworktype}
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  limit=1  starttime=${start_date}  endtime=${end_date}  deviceos=${deviceos}  devicemodel=${devicemodel}  datanetworktype=${datanetworktype}
      selector=deviceinfo  app-org=${developer_org_name_automation}  numsamples=1
      selector=deviceinfo  app-org=${developer_org_name_automation}  numsamples=1  starttime=${start_date}  endtime=${end_date}
      selector=deviceinfo  app-org=${developer_org_name_automation}  startage=12h
      selector=deviceinfo  app-org=${developer_org_name_automation}  endage=1s
      selector=deviceinfo  app-org=${developer_org_name_automation}  startage=12h  endage=1s

# ECQ-3364
Clientappusage - mcctl shall handle clientappusage metrics failures
   [Documentation]
   ...  - send clientappusage metrics via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  DMEPersistentConnection

   [Template]  Fail Clientappusage Metrics Via mcctl
      # invalid values
      Error: missing required args: 
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=x
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=latency
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=latency appname=x
      Error: Bad Request (400), Custom stat not implemented yet                                                                 selector=custom app-org=automation_dev_org
      Error: Bad Request (400), Provided selector "x" is not valid. Must provide only one of "latency", "deviceinfo", "custom"  selector=x app-org=automation_dev_org
      Error: Bad Request (400), DeviceOS not allowed for appinst latency metric                                                 selector=latency  app-org=automation_dev_org  deviceos=x
      Error: Bad Request (400), DeviceModel not allowed for appinst latency metric                                              selector=latency  app-org=automation_dev_org  devicemodel=x
      error decoding \\\'MetricsCommon.TimeRange.StartTime\\\'                                                                  selector=latency  app-org=automation_dev_org  starttime=x
      error decoding \\\'MetricsCommon.TimeRange.EndTime\\\'                                                                    selector=latency  app-org=automation_dev_org  endtime=x
      error decoding \\\'MetricsCommon.TimeRange.StartAge\\\': time: invalid duration "x"                                       selector=latency  cloudlet-org=automation_dev_org  startage=x
      error decoding \\\'MetricsCommon.TimeRange.EndAge\\\': time: invalid duration "x"                                         selector=latency  cloudlet-org=automation_dev_org  endage=x
      Unable to parse "limit" value "x" as int: invalid syntax                                                                  selector=latency  app-org=automation_dev_org  limit=x
      Error: Bad Request (400), LocationTile not allowed for appinst deviceinfo metric                                          selector=deviceinfo  app-org=automation_dev_org  locationtile=x
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=deviceinfo
      Unable to parse "numsamples" value "x" as int: invalid syntax                                                             selector=latency  app-org=automation_dev_org  numsamples=x

*** Keywords ***
Setup
   ${end_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
   ${start_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ  increment=-24 hours

   Update Settings  region=${region}  edge_events_metrics_collection_interval=5s
   Sleep  10s

   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
   ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96

   Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloudlet.edge_events_cookie}') > 100

   @{samples}=  Create List  ${10.4}  ${4.20}  ${30}  ${440}  ${0.50}  ${6.00}  ${170.45}

   ${devicemodel_modify}=  Replace String  ${devicemodel}  "  ${Empty}
   Create DME Persistent Connection  edge_events_cookie=${cloudlet.edge_events_cookie}  device_model=${devicemodel_modify}  device_os=${deviceos}  carrier_name=${devicecarrier}  latitude=36  longitude=-96

   ${latency}=  Send Latency Edge Event  edge_events_cookie=${cloudlet.edge_events_cookie}  carrier_name=${devicecarrier}  latitude=36  longitude=-96  samples=${samples}

   Set Suite Variable  ${start_date}
   Set Suite Variable  ${end_date}

Success Clientappusage Latency Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   #Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientappusage region=${region} ${parmss}  version=${version}

   IF  'numsamples' not in '${parmss}'
      Should Be Equal  ${result['data'][0]['Series'][0]['name']}  latency-metric
   ELSE
      Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
   END

#   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
#   Run Keyword If  'rawdata' not in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
#   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  latency-metric

Success Clientappusage DeviceInfo Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientappusage region=${region} ${parmss}  version=${version}

   IF  'numsamples' not in '${parmss}'
      Should Be Equal  ${result['data'][0]['Series'][0]['name']}  device-metric
   ELSE
      Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
   END

#   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
#   Run Keyword If  'rawdata' not in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
#   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  device-metric

Fail Clientappusage Metrics Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  metrics clientappusage region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
