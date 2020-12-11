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
${samsung_last_seen}  1234
${samsung_seconds}  1234
${samsung_nanos}  1234
${samsung_notify_id}  1234
${region}  US

# add testcase for Developer and Operator user

*** Test Cases ***
##ECQ-2116 not supported
#showDevice - request with id and type shall return device information
#    [Documentation]
#    ...  registerClient with samsung app with unique_id and type
#    ...  verify showDevice returns all information supported
#    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id
#
#      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcd 
#
#      ${device}=  Show Device  region=${region}  unique_id=${epoch}  unique_id_type=abcd  
#
#      Should Be Equal  ${device[0]['data']['key']['unique_id_type']}  1234
#      Should Be Equal  ${device[0]['data']['key']['unique_id']}  1234
#      Should Be True   ${device[0]['data']['first_seen']['seconds']} > 0
#      Should Be True   ${device[0]['data']['first_seen']['nanos']} > 0
#      Should Be True   ${device[0]['data']['notify_id']} > 0
#
#      Length Should Be   ${device}  1
#
##ECQ-2117
#showDevice - request with first_seen and seconds shall return device information
#    [Documentation]
#    ...  showDevice displays requested firstseen data
#    ...  verify returns time of first_seen seconds requested
#    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id
#
#      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcd  
#      ${device}=  Show Device  region=${region}
#       
#      ${found}=  Find Device  ${device}  1234  abcd
# 
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']} 
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
# 
#      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  first_seen_seconds=${secs}  first_seen_nanos=${nsecs}  notify_id=1
#
#      Should Be Equal   ${device[0]['data']['first_seen']['seconds']}  ${secs} 
#      Should Be Equal   ${device[0]['data']['first_seen']['nanos']}  ${nsecs}
#
#      Length Should Be   ${device}  1
#
##ECQ-2118
#showDevice - request without first_seen_seconds shall return device information
#    [Documentation]
#    ...  showDevice displays firstseen data without requesting
#    ...  verify showDevice returns first_seen device information
#    ...  firstseen.seconds firstseen.nanos
#
#
#      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcd
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  1234  abcd
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#      
#      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  #first_seen_seconds=${secs}  first_seen_nanos=${nsecs}  notify_id=1
#
#      Should Be Equal   ${device[0]['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${device[0]['data']['first_seen']['nanos']}  ${nsecs}
#
#      Length Should Be   ${device}  1
#
##ECQ-2119
#showDevice - request with first_seen_nanos shall return device information
#
#    [Documentation]
#    ...  showDevice check display of first_seen_nanos
#    ...  verify returns time of first_seen_nanos requested
#
#      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcd
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  1234  abcd
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#
#      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  first_seen_seconds=${secs}  first_seen_nanos=${nsecs}  notify_id=1
#
#      Should Be Equal   ${device[0]['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${device[0]['data']['first_seen']['nanos']}  ${nsecs}
#
#      Length Should Be   ${device}  1
#
#
##ECQ-2120
#showDevice - without first_seen_nanos shall return device information
#
#    [Documentation]
#    ...  showDevice check display of time_seen_nanos without specifying time
#    ...  verify time_seen_nanos is displayed without being requested
#
#      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcd
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  1234  abcd
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#
#      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  #first_seen_nanos=${nsecs}  notify_id=1
#
#      Should Be Equal   ${device[0]['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${device[0]['data']['first_seen']['nanos']}  ${nsecs}
#
#      Length Should Be   ${device}  1
#
##ECQ-2121
#showDevice - with notify_id shall return device information
#
#   [Documentation]
#    ...  showDevice check display of notify_id 
#    ...  verify notify_id is displayed as requested
#
#      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=abcd
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  1234  abcd
#
##      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
##      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#      ${ntfy}=  Set Variable  ${found['data']['notify_id']}	
#      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  notify_id=${ntfy}
#
##      Should Be Equal   ${device['data']['first_seen']['seconds']}  ${secs}
##      Should Be Equal   ${device['data']['first_seen']['nanos']}  ${nsecs}
#      Should Be Equal   ${device[0]['data']['notify_id']}  ${ntfy}
#      
#      Length Should Be   ${device}  1
#

# ECQ-2957
showDevice - request with Samsung platform app and non-samsung unique_id_type shall not return device information
    [Documentation]
    ...  - send showDevice with Samsung platform app and non-samsung unique_id_type
    ...  - verify showDevice returns no info

    ${timestamp}=  Get Time  epoch

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=myid

    ${device}=  Show Device  region=${region}  unique_id=${timestamp}  #begin_seconds=${secs}  begin_nanos=${nsecs}
    Length Should Be   ${device}  0

# ECQ-2958
showDevice - request with Samsung platform app and Samsung unique_id_type shall not return device information
    [Documentation]
    ...  - send showDevice with Samsung platform app and Samsung unique_id_type
    ...  - verify showDevice returns no info

    ${timestamp}=  Get Time  epoch

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=Samsung

    ${device}=  Show Device  region=${region}  unique_id=${timestamp}  #begin_seconds=${secs}  begin_nanos=${nsecs}
    Length Should Be   ${device}  0

# ECQ-2959
showDevice - request with Samsung platform app and lower samsung unique_id_type shall not return device information
    [Documentation]
    ...  - send showDevice with lowercase samsung platform app and Samsung unique_id_type
    ...  - verify showDevice returns no info

    ${timestamp}=  Get Time  epoch

    Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=samsung

    ${device}=  Show Device  region=${region}  unique_id=${timestamp}  #begin_seconds=${secs}  begin_nanos=${nsecs}
    Length Should Be   ${device}  0

#ECQ-2122
showDevice - without notify_id shall return device information
    [Documentation]
    ...  showDevice check display of notify_id
    ...  verify notify_id is displayed without being requested

      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd
      Should Be True  ${device[0]['data']['notify_id']} > 0

      Length Should Be  ${device}  1
  
#ECQ-2123
showDevice - request with bad token
  [Documentation]
    ...  showDevice verify error for bad token
    ...  verify no bearer token found

      # robot function
      Run Keyword And Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}

      ${error}=  Run Keyword And Expect Error  *  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}
      #Should Be Equal  ${error}  ('code=400', 'error={"message":"no bearer token found"}')
      Should Contain  ${error}  no bearer token found

#ECQ-2124
showDevice - request token error jwt
    [Documentation]
    ...  showDevice verify jwt error
    ...  verify invalid or expired jwt 

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
    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0

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
