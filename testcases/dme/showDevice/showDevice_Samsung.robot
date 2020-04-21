*** Settings ***
Documentation   showDevice - request shall return device uniqueid

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${samsung_app_name}  SamsungEnablingLayer
${samsung_developer_name}  Samsung
${samsung_cloudlet_name}  default
${samsung_operator_name}  developer
${samsung_uri}  automation.samsung.com
${samsung_unique_id}  12345
${samsung_unique_id_type}  abcde
${samsung_first_seen}  1234
${samsung_seconds}  1234
${samsung_nanos}  1234
${samsung_notify_id}  1234
${region}  US

# add testcase for Developer and Operator user

*** Test Cases ***
showDevice - request with id and type shall return device information
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display key.uniqueid 
    ...  verify returns 5 result



      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcd 

      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  

      Should Be Equal  ${device['data']['key']['unique_id_type']}  abcd 
      Should Be Equal  ${device['data']['key']['unique_id']}  1234
      Should Be True   ${device['data']['first_seen']['seconds']} > 0
      Should Be True   ${device['data']['first_seen']['nanos']} > 0
      Should Be True   ${device['data']['notify_id']} > 0

      Length Should Be   ${device}  1

showDevice - request without id and type shall return device information
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display key.uniqueid
    ...  verify returns 5 result


      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=  unique_id_type=  first_seen=  seconds=  nanos=  notify_id=
      ${device}=  Show Device  region=${region}

      Should Not Be Equal  ${device[-1]['data']['key']['unique_id_type']}  unique_id
      Should Not Be Equal  ${device[-1]['data']['key']['unique_id']}  None
      Should Be True   ${device[-1]['data']['first_seen']['seconds']} > 0
      Should Not Be True   ${device[-1]['data']['first_seen']['nanos']} < 0
      Should Be True   ${device[-1]['data']['notify_id']} > 0

      ${len}=  Get Length  ${device}
      Should Be True   ${len} > 1

showDevice - request with first_seen and seconds shall return device information
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display key.time_seen
    ...  verify returns 1 result


      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcd  
      ${device}=  Show Device  region=${region}
       
      ${found}=  Find Device  ${device}  1234  abcd
 
      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']} 
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
 
      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  first_seen_seconds=${secs}  first_seen_nanos=${nsecs}  notify_id=1

      Should Be Equal   ${device['data']['first_seen']['seconds']}  ${secs} 
      Should Be Equal   ${device['data']['first_seen']['nanos']}  ${nsecs}

      Length Should Be   ${device}  1

showDevice - request without first_seen and seconds shall return device information
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display key.uniqueid
    ...  verify returns 5 result

      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=  unique_id_type=  first_seen=  seconds=  nanos=  notify_id=
      ${device}=  Show Device  region=${region}

      Should Not Be Equal  ${device[-1]['data']['key']['unique_id_type']}  unique_id
      Should Not Be Equal  ${device[-1]['data']['key']['unique_id']}  None
      Should Be True   ${device[-1]['data']['first_seen']['seconds']} > 0
      Should Not Be True   ${device[-1]['data']['first_seen']['nanos']} < 0
      Should Be True   ${device[-1]['data']['notify_id']} > 0

      ${len}=  Get Length  ${device}
      Should Be True   ${len} > 1

showDevice - request with first_seen and nanos shall return device information
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display time_seen seconds
    ...  verify returns 1 result

      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcde  first_seen=1234  seconds=1234  nanos=1234  notify_id=1
      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  first_seen=1234  seconds=1234  nanos=1234  notify_id=1

      Should Be True   ${device['data']['first_seen']['nanos']} > 0

      Length Should Be   ${device}  1

showDevice - request without first_seen and nanos shall return device information
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display time_seen nanos
    ...  verify returns 1 result

      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=wofirsts  unique_id_type=wofirstsid  first_seen=  seconds=  nanos=  notify_id=
      ${device}=  Show Device  region=${region}

      Should Be True   ${device[-1]['data']['first_seen']['nanos']} > 0

      ${len}=  Get Length  ${device}
      Should Be True   ${len} > 1

showDevice - request with notify_id shall return device information
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display notify_id
    ...  verify returns 1 result


      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=9876  unique_id_type=april  first_seen=1234  seconds=1234  nanos=1234  notify_id=1
      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  first_seen=1234  seconds=1234  nanos=1234  notify_id=1

      Should Be True   ${device['data']['notify_id']} > 0
      
      Length Should Be   ${device}  1

showDevice - request without notify_id shall return device information
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display notify_id
    ...  verify returns 1 result


      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcde  first_seen=1234  seconds=1234  nanos=1234  notify_id=
      ${device}=  Show Device  region=${region}
      ${device}=  Show Device  region=${region}

      Should Be True   ${device[-1]['data']['notify_id']} > 1

      ${len}=  Get Length  ${device}
      Should Be True   ${len} > 1

showDevice - fail invalid format firstseen seconds
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display time_seen
    ...  verify returns 1 result
      
      ${error}=  Run Keyword And Expect Error  *  Show Device  region=${region}  first_seen_seconds=-90xf
      Should Be Equal  ${error}  ('code=400', 'error={"message":"Invalid data: code=400, message=Unmarshal type error: expected=int64, got=string, field=seconds, offset=45"}')

showDevice - fail invalid format firstseen nanos
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display time_seen
    ...  verify returns 1 result


      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=ifirstn  unique_id_type=ifirstnid  first_seen=21:12  seconds=  nanos=  notify_id=0
      ${device}=  Show Device  region=${region}
      ${device}=  Show Device  region=${region}

      Should Be True   ${device[-1]['data']['first_seen']['nanos']} > 1

      ${len}=  Get Length  ${device}
      Should Be True   ${len} > 1

showDevice - fail invalid format seconds
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display time_seen nanos
    ...  verify returns 1 result


      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=iseconds  unique_id_type=isecondsid  first_seen=  seconds=x-221  nanos=  notify_id=0
      ${device}=  Show Device  region=${region}
      ${device}=  Show Device  region=${region}

      Should Be True   ${device[-1]['data']['first_seen']['seconds']} > 1

      ${len}=  Get Length  ${device}
      Should Be True   ${len} > 1

showDevice - fail invalid format nanos
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display time_seen seconds
    ...  verify returns 1 result


      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=inanos  unique_id_type=inanosid  #first_seen=  seconds=  nanos=xxxxx  notify_id=
      ${device}=  Show Device  region=${region}  nanos=xxxxx

      Should Be True   ${device[-1]['data']['first_seen']['nanos']} > 1

      ${len}=  Get Length  ${device}
      Should Be True   ${len} > 1

showDevice - fail invalid format notifyid
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display time_seen nanos
    ...  verify returns 1 result


      Register Client   developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=inotidyid  unique_id_type=inotifyidt  #first_seen=  seconds=  nanos=  notify_id=zzzzzzz
      ${device}=  Show Device  region=${region}  first_seen=  seconds=  nanos=  notify_id=zzzzzzz 
      ${device}=  Show Device  region=${region}

      Should Be True   ${device[-1]['data']['notify_id']} > 1

      ${len}=  Get Length  ${device}
      Should Be True   ${len} > 1 

showDevice - fail test for bad token
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display notify_id
    ...  verify returns 1 result

      # robot function
      Run Keyword And Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}

      ${error}=  Run Keyword And Expect Error  *  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}
      #Should Be Equal  ${error}  ('code=400', 'error={"message":"no bearer token found"}')
      Should Contain  ${error}  no bearer token found


showDevice - request token error jwt
    [Documentation]
    ...  registerClient with samsung app
    ...  send showDevice display token
    ...  verify returns 1 result

      # robot function


      ${error}=  Run Keyword And Expect Error  *  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  token=xx  use_defaults=${False}
      #Should Be Equal  ${error}  ('code=401', 'error={"message":"invalid or expired jwt"}')
      Should Contain  ${error}  ('code=401', 'error={"message":"invalid or expired jwt"}')

*** Keywords ***
Setup
    Create Flavor  region=${region} 
   # ShowDevice  uniqueid=${uniqueid}  
#ShowDevice  uniqueid=${uniqueid}    
    #ShowDevice  uniqueidtype=${uniqueidtype}
    Create App  region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0

   #Set Suite Variable  ${app} 

Find Device
   [Arguments]  ${device}  ${id}  ${type}

   ${fd}=  Set Variable  ${None} 
   FOR  ${d}  IN  @{device}
      log to console  ${d['data']['key']['unique_id']} ${id}
      ${fd}=  Run Keyword If  '${d['data']['key']['unique_id']}' == '${id}' and '${d['data']['key']['unique_id_type']}' == '${type}'  Set Variable  ${d}     
      ...  ELSE  Set Variable  ${fd}
   #   Run Keyword If  '${d['data']['key']['unique_id']}' == '${id}' and '${d['data']['key']['unique_id_type']}' == '${type}'    [Return]  ${d}
      log to console  ${fd}
   END
 
   [Return]  ${fd}
