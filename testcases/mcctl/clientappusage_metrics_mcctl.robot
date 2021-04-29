*** Settings ***
Documentation  Clientappusage Metrics mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${version}=  latest

*** Test Cases ***
# ECQ-3363
Clientappusage - mcctl shall be able to request clientappusage metrics
   [Documentation]
   ...  - send clientappusage metrics via mcctl with various parms
   ...  - verify success

   [Tags]  DMEPersistentConnection

   [Template]  Success Clientappusage Metrics Via mcctl
      selector=latency  app-org=${developer_org_name_automation}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  locationtile=0-0,0-2
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=false
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  rawdata=true
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1  starttime=2021-04-27T08:22:40Z endtime=2021-04-28T08:22:40Z
      selector=latency  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}  cloudlet=${cloudlet_name_fake}  last=1  starttime=2021-04-27T08:22:40Z endtime=2021-04-28T08:22:40Z  rawdata=true

# ECQ-3364
Clientappusage - mcctl shall handle clientappusage metrics failures
   [Documentation]
   ...  - send clientappusage metrics via mcctl with various error cases
   ...  - verify proper error is received

   [Tags]  DMEPersistentConnection

   [Template]  Fail Clientappusage Metrics Via mcctl
      # invalid values
      Error: missing required args: 
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization  selector=
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization  selector=x
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization  selector=latency
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization  selector=latency appname=x
      Error: Bad Request (400), Custom stat not implemented yet                                selector=custom app-org=automation_dev_org
      Error: Bad Request (400), Provided selector "x" is not valid. Must provide only one of "latency", "deviceinfo", "custom"                                selector=x app-org=automation_dev_org
      Error: Bad Request (400), DeviceOS not allowed for appinst latency metric  selector=latency  app-org=automation_dev_org  deviceos=x
      Error: Bad Request (400), DeviceModel not allowed for appinst latency metric  selector=latency  app-org=automation_dev_org  devicemodel=x
      Error: Bad Request (400), DataNetworkType not allowed for appinst latency metric  selector=latency  app-org=automation_dev_org  datanetworktype=x
      Unable to parse "rawdata" value "x" as bool: invalid syntax, valid values are true, false  selector=latency  app-org=automation_dev_org  rawdata=x
      error decoding \\\'StartTime\\\'  selector=latency  app-org=automation_dev_org  starttime=x
      error decoding \\\'EndTime\\\'  selector=latency  app-org=automation_dev_org  endtime=x
      Unable to parse "last" value "x" as int: invalid syntax  selector=latency  app-org=automation_dev_org  last=x

*** Keywords ***
Setup
   ${flavor_name}=  Get Default Flavor Name
   Set Suite Variable  ${flavor_name}

Success Clientappusage Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientappusage region=${region} ${parmss}  version=${version}

   Run Keyword If  'rawdata=false' in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
   Run Keyword If  'rawdata' not in '${parmss}'  Should Contain  ${result['data'][0]['Series'][0]['name']}  latency-metric-
   Run Keyword If  'rawdata=true' in '${parmss}'  Should Be Equal  ${result['data'][0]['Series'][0]['name']}  latency-metric

Fail Clientappusage Metrics Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  metrics clientappusage region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
