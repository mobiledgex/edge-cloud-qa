*** Settings ***
Documentation  Clientapiusage Metrics mcctl

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
${cloudlet_dme}=  mexplat-qa-cloudlet
${operator_dme}=  TDG

${version}=  latest

*** Test Cases ***
# ECQ-3570
Clientapiusage - mcctl shall be able to request clientapiusage api metrics
   [Documentation]
   ...  - send clientapiusage api metrics via mcctl with various parms
   ...  - verify success

   [Template]  Success Clientapiusage API Metrics Via mcctl
      selector=api  app-org=${developer_org_name_automation}
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0
#      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation
#      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cluster=autoclusterautomation  cluster-org=${developer}
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cloudlet=${cloudlet_dme}
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cloudlet=${cloudlet_dme}  cloudlet-org=${operator_dme}
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cloudlet=${cloudlet_dme}  cloudlet-org=${operator_dme}  method=FindCloudlet
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cloudlet=${cloudlet_dme}  cloudlet-org=${operator_dme}  method=RegisterClient
      selector=api  cloudlet=${cloudlet_dme}  cloudlet-org=${operator_dme}  method=PlatformFindCloudlet
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cloudlet=${cloudlet_dme}  cloudlet-org=${operator_dme}  method=VerifyLocation
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cloudlet=${cloudlet_dme}  cellid=0
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cloudlet=${cloudlet_dme}  limit=1
      selector=api  appname=${app_name_automation}  app-org=${developer_org_name_automation}  appvers=1.0  cloudlet=${cloudlet_dme}  limit=1  starttime=${start_date}  endtime=${end_date}
      selector=api  app-org=${developer_org_name_automation}  numsamples=1
      selector=api  app-org=${developer_org_name_automation}  numsamples=1  starttime=${start_date}  endtime=${end_date}
      selector=api  app-org=${developer_org_name_automation}  startage=12h
      selector=api  app-org=${developer_org_name_automation}  endage=1s
      selector=api  app-org=${developer_org_name_automation}  startage=12h  endage=1s

# ECQ-3571
Clientapiusage - mcctl shall handle clientapiusage metrics failures
   [Documentation]
   ...  - send clientapiusage metrics via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Clientapiusage Metrics Via mcctl
      # invalid values
      Error: missing required args: 
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=x
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=api
      Error: Bad Request (400), Must provide either App organization or Cloudlet organization                                   selector=api appname=x
      Error: Bad Request (400), Invalid dme selector: x                                                                         selector=x app-org=automation_dev_org
      Error: parsing arg "starttime\=x" failed: unable to parse "x" as time.Time: parsing time "x" into RFC3339 format failed. Example: "2006-01-02T15:04:05Z07:00"   selector=api  app-org=automation_dev_org  starttime=x
      Error: parsing arg "endtime\=x" failed: unable to parse "x" as time.Time: parsing time "x" into RFC3339 format failed. Example: "2006-01-02T15:04:05Z07:00"     selector=api  app-org=automation_dev_org  endtime=x
      Error: parsing arg "startage\=x" failed: unable to parse "x" as time.Duration: time: invalid duration "x"                                                       selector=api  cloudlet-org=automation_dev_org  startage=x
      Error: parsing arg "endage\=x" failed: unable to parse "x" as time.Duration: time: invalid duration "x"                                                         selector=api  cloudlet-org=automation_dev_org  endage=x
      Error: parsing arg "limit\=x" failed: unable to parse "x" as int: invalid syntax                                                                                selector=api  app-org=automation_dev_org  limit=x
      Error: parsing arg "cellid\=x" failed: unable to parse "x" as int: invalid syntax                                                                               selector=api  app-org=automation_dev_org  cellid=x
      Error: parsing arg "numsamples\=x" failed: unable to parse "x" as int: invalid syntax                                                                           selector=api  app-org=automation_dev_org  numsamples=x

*** Keywords ***
Setup
   ${end_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
   ${start_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ  increment=-24 hours

   ${r}=  Register Client  app_name=${app_name_automation}  app_version=1.0  developer_org_name=${developer_org_name_automation}
#   ${fqdn}=  Get App Official FQDN  latitude=37  longitude=-96
   ${cloudlet}=  Find Cloudlet  carrier_name=${operator_name_fake}  latitude=36  longitude=-96
#   Platform Find Cloudlet  carrier_name=${operator_name_fake}  client_token=${fqdn.client_token}  #latitude=36  longitude=-95

   Should Be Equal As Numbers  ${cloudlet.status}  1  #FIND_FOUND
   Should Be True  len('${cloudlet.edge_events_cookie}') > 100

   Set Suite Variable  ${start_date}
   Set Suite Variable  ${end_date}

Success Clientapiusage API Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   #Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics clientapiusage region=${region} ${parmss}  version=${version}

   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  dme-api

Fail Clientapiusage Metrics Via mcctl
   [Arguments]  ${error_msg}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  metrics clientapiusage region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
