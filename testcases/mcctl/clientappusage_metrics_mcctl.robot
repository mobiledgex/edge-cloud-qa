*** Settings ***
Documentation  Clientappusage Metrics mcctl

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
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=false
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=true
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}  rawdata=true

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
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=false
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=true
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}  rawdata=true
      selector=deviceinfo  app-org=${developer_org_name_automation}  deviceos=Android
      selector=deviceinfo  app-org=${developer_org_name_automation}  devicemodel="Google Pixel"
      selector=deviceinfo  app-org=${developer_org_name_automation}  datanetworktype=5G
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  deviceos=Android
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  devicemodel="Google Pixel"
      selector=deviceinfo  cloudlet-org=${operator_name_fake}  datanetworktype=5G
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}  deviceos=Android  devicemodel="Google Pixel"  datanetworktype=5G
      selector=deviceinfo  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1  starttime=${start_date}  endtime=${end_date}  deviceos=Android  devicemodel="Google Pixel"  datanetworktype=5G  rawdata=true

# ECQ-3364
Clientappusage - mcctl shall handle clientappusage metrics failures
   [Documentation]
   ...  - send clientappusage metrics via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  DMEPersistentConnection

   [Template]  Fail Clientappusage Metrics Via mcctl
      # invalid values
      Error: missing required args: 
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                                                 selector=
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                                                 selector=x
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                                                 selector=latency
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                                                 selector=latency appname=x
      Error: Bad Request (400), Custom stat not implemented yet                                                                                               selector=custom app-org=automation_dev_org
      Error: Bad Request (400), Provided selector "x" is not valid. Must provide only one of "latency", "deviceinfo", "custom"                                selector=x app-org=automation_dev_org
      Error: Bad Request (400), DeviceOS not allowed for appinst latency metric                                                                               selector=latency  app-org=automation_dev_org  deviceos=x
      Error: Bad Request (400), DeviceModel not allowed for appinst latency metric                                                                            selector=latency  app-org=automation_dev_org  devicemodel=x
      Error: Bad Request (400), DataNetworkType not allowed for appinst latency metric                                                                        selector=latency  app-org=automation_dev_org  datanetworktype=x
      Unable to parse "rawdata" value "x" as bool: invalid syntax, valid values are true, false                                                               selector=latency  app-org=automation_dev_org  rawdata=x
      error decoding \\\'StartTime\\\'                                                                                                                        selector=latency  app-org=automation_dev_org  starttime=x
      error decoding \\\'EndTime\\\'                                                                                                                          selector=latency  app-org=automation_dev_org  endtime=x
      Unable to parse "last" value "x" as int: invalid syntax                                                                                                 selector=latency  app-org=automation_dev_org  last=x
      Error: Bad Request (400), LocationTile not allowed for appinst deviceinfo metric                                                                        selector=deviceinfo  app-org=automation_dev_org  locationtile=x
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                                                 selector=deviceinfo

*** Keywords ***
Setup
   ${end_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
   ${start_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ  increment=-24 hours

   Set Suite Variable  ${start_date}
   Set Suite Variable  ${end_date}

Success Clientappusage Latency Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   #Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientappusage region=${region} ${parmss}  version=${version}

   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
   Run Keyword If  'rawdata' not in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  latency-metric

Success Clientappusage DeviceInfo Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientappusage region=${region} ${parmss}  version=${version}

   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
   Run Keyword If  'rawdata' not in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  device-metric-
   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  device-metric

Fail Clientappusage Metrics Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  metrics clientappusage region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
