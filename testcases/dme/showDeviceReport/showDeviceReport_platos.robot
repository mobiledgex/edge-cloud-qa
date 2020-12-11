*** Settings ***
Documentation   showDevice - request shall return device uniqueid

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${platos_app_name}  platosEnablingLayer
${platos_developer_name}  platos
${platos_cloudlet_name}  default
${platos_operator_name}  developer
${platos_uri}  automation.platos.com
${platos_unique_id}  12345
${platos_unique_id_type}  platos
${platos_begin_seconds}  124
${platos_end_seconds}  1234
${platos_begin_nanos}  1234
${platos_end_nanos}  1234
${platos_notify_id}  1234
${region}  US
${plusone}  1
${count}  1

# add testcase for Developer and Operator user

*** Test Cases ***
#ECQ-2128 not supported
#showDeviceReport - request unique_id with only begin_nanos shall return device information
#    [Documentation]
#    ...  showDeviceReport returns uuid information
#    ...  verify showDeviceReport returns uuid device information with only begin_nanos specified parameters
#
#      ${timestamp}=  Get Time  epoch
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${platos_unique_id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${platos_unique_id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}
#
#      ${device}=  Show Device Report  region=${region}  unique_id=${uid}  #begin_seconds=${secs}  begin_nanos=${nsecs}
#    
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${found['data']['key']['unique_id']}  ${uid}
#      #Should Be True    ${found['data']['key']['unique_id']} > ${shit} -2
#      #Should Be True    ${found['data']['key']['unique_id']} < ${shit} +2

# ECQ-2949
showDeviceReport - request with platos platform app and non-platos unique_id_type shall not return device information
    [Documentation]
    ...  - send showDeviceReport with platos platform app and non-platos unique_id_type
    ...  - verify showDeviceReport returns no info

    ${timestamp}=  Get Time  epoch

    Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=myid
    ${device}=  Show Device  region=${region}

    ${device}=  Show Device Report  region=${region}  unique_id=${timestamp}  #begin_seconds=${secs}  begin_nanos=${nsecs}
    Length Should Be   ${device}  0

# ECQ-2950
showDeviceReport - request with platos platform app and platos unique_id_type shall not return device information
    [Documentation]
    ...  - send showDeviceReport with platos platform app and platos unique_id_type
    ...  - verify showDeviceReport returns no info

    ${timestamp}=  Get Time  epoch

    Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=platos
    ${device}=  Show Device  region=${region}

    ${device}=  Show Device Report  region=${region}  unique_id=${timestamp}  #begin_seconds=${secs}  begin_nanos=${nsecs}
    Length Should Be   ${device}  0

# ECQ-2951
showDeviceReport - request with platos platform app and lower platos unique_id_type shall not return device information
    [Documentation]
    ...  - send showDeviceReport with lowercase platos platform app and platos unique_id_type
    ...  - verify showDeviceReport returns no info

    ${timestamp}=  Get Time  epoch

    Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=platos
    ${device}=  Show Device  region=${region}

    ${device}=  Show Device Report  region=${region}  unique_id=${timestamp}  #begin_seconds=${secs}  begin_nanos=${nsecs}
    Length Should Be   ${device}  0

#ECQ-2129 not supported
#showDeviceReport - request unique_id unique_id_type begin_seconds and begin_nanos shall return specified device information
#    [Documentation]
#    ...  showDeviceReport returns uuid information using begin_seconds and begin_nanos
#    ...  verify showDeviceReport returns uuid device information with unique_id unique_id_type begin_seconds and begin_nanos
#
#      ${id_type}=  Set Variable  platosapril
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=id427912  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#       
#      ${found}=  Find Device  ${device}  id427912  ${id_type} 
# 
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']} 
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
# 
#      ${device}=  Show Device Report  region=${region}  unique_id=id427912  unique_id_type=${id_type}  begin_seconds=${secs}  begin_nanos=${nsecs}  
#
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}  
#
#     # Length Should Be  ${device}  1
#
#
##ECQ-2130 not supported
#showDeviceReport - request unique_id and unique_id_type with begin_nanos shall return device information
#    [Documentation]
#    ...  showDeviceReport returns uuid using only with unique_id and unique_id_type with begin_nanos
#    ...  verify showDeviceReport returns uuid device information with unique_id and unique_id_type with begin_nanos
#
#      ${id_type}=  Set Variable  octoberplatos
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=id427913  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  id427913  ${id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#
#      ${device}=  Show Device Report  region=${region}  unique_id=id427913  unique_id_type=${id_type}  begin_nanos=${nsecs}
#
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#
#     # Length Should Be  ${device}  1
#
#
##ECQ-2131  not supported
#showDeviceReport - request with only begin_seconds and begin_nanos shall return device information
#
#    [Documentation]
#    ...  showDeviceReport returns uuid device information only using begin_seconds and begin_nanos
#    ...  verify showDeviceReport returns uuid device information only using begin_seconds and begin_nanos
#
##      ${id_type}=  Set Variable  noveplatosmber
#
#      ${timestamp}=  Get Time  epoch
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}
#      
#      ${device}=  Show Device Report  region=${region}  begin_seconds=${secs}  begin_nanos=${nsecs}
#
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#      Should Be Equal   ${found['data']['key']['unique_id']}  ${uid} 
#
#
##ECQ-2132 not supported
#showDeviceReport - request uuid with only begin_nano shall return device information
#
#    [Documentation]
#    ...  showDeviceReport returns uuid device information using only begin_nanos
#    ...  verify uuid information is returned using only begin_nanos
#
#      ${id_type}=  Set Variable  abcdplatos
#
#      ${timestamp}=  Get Time  epoch
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#
#      ${device}=  Show Device Report  region=${region}  begin_nanos=${nsecs}
#
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#
#     # Length Should Be  ${device}  1
#
#
##ECQ-2133 not supported
#showDeviceReport - request uuid with only begin_seconds shall returns device information 
#
#    [Documentation]
#    ...  showDeviceReport returns uuid device information with begin_seconds
#    ...  verify returned uuid returns device information
#
#      ${id_type}=  Set Variable  platosabcd
#
#      ${timestamp}=  Get Time  epoch
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#
#      ${device}=  Show Device Report  region=${region}  begin_seconds=${nsecs}
#
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#
#     # Length Should Be  ${device}  1
#
##ECQ-2134 not supported
#showDeviceReport - request with only end_seconds and end_nanos shall return device information
#
#    [Documentation]
#    ...  showDeviceReport returns uuid device information with begin_seconds and begin_nanos
#    ...  verify returned uuid returns device information with begin_seconds and begin_nanos
#
#      ${id_type}=  Set Variable  testcaplatossesix
#
#      ${timestamp}=  Get Time  epoch
#      
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${id_type}
#      ${device}=  Show Device Report  region=${region}
#     
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}
#
#      ${device}=  Show Device Report  region=${region}  end_seconds=${secs}  end_nanos=${nsecs}
#
#
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${found['data']['key']['unique_id']}  ${uid}
##     Should Be True    ${found['data']['key']['unique_id']} > ${uid} -2
##     Should Be True    ${found['data']['key']['unique_id']} < ${uid} +2
#
##      Should Be Equal  ${device['data']['key']['unique_id_type']}  abcd
##      Should Be Equal  ${device['data']['key']['unique_id']}  1234
##      Should Be True   ${device['data']['first_seen']['seconds']} > 0
##      Should Be True   ${device['data']['first_seen']['nanos']} > 0
##      Should Be True   ${device['data']['notify_id']} > 0
#
#
##ECQ-2135 not supported
#showDeviceReport - request with added time to end_seconds shall return device data
#    [Documentation]
#    ...  showDeviceReport returns uuid device information with unique_id end_seconds and end_nanos
#    ...  verify returned uuid returns device information with unique_id end_seconds and end _nanos
#
#      ${id_type}=  Set Variable  apriplatosl
#
#      ${timestamp}=  Get Time  epoch
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}
#
#      ${countsec}=  Evaluate  ${secs} + 1
#      ${countnano}=  Evaluate  ${nsecs} + 1
#
#      ${device}=  Show Device Report  region=${region}  unique_id=${uid} end_seconds=${countsec}  end_nanos=${nsecs}
#
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#      Should Be Equal   ${found['data']['key']['unique_id']}  ${uid}
#
#
#     # Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#     # Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#     # Should Be Equal   ${found['data']['key']['unique_id']}  ${uid}   
#     # Length Should Be  ${device}  1
#
##ECQ-2136 not supported
#showDeviceReport - request with added time to end_nanos shall return device data
#
#    [Documentation]
#    ...  showDeviceReport returns uuid device information with end_seconds and end_nanos
#    ...  verify returned uuid returns device information with end_seconds and end _nanos
#
#      ${id_type}=  Set Variable  platosendnanos2
#
#      ${timestamp}=  Get Time  epoch
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${id_type} 
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#     
#     ${countsec}=  Evaluate  ${secs} + 1
#     ${countnano}=  Evaluate  ${nsecs} + 1
#
#
#     ${device}=  Show Device Report  region=${region}  end_seconds=${secs}  end_nanos=${countnano}
#
#
#      Should Be True    ${found['data']['key']['unique_id']}  ${timestamp}
#      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#      Should Be True   ${found['data']['first_seen']['nanos']} < ${countnano}
#
#     #Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#     #Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}    
#     # Should Not Be Equal   ${found['data']['first_seen']['nanos']}  ${count}
#     # Should Be True    ${found['data']['key']['unique_id']} < ${count1}
#     # Length Should Be   ${device}  1
#
##ECQ-2137 not supported
#showDeviceReport - request with unique_id_type with end_seconds and end_nanos shall return device information
#
#    [Documentation]
#    ...  showDeviceReport display uuid using a specified unique_id_type end_seconds and end_nanos
#    ...  verify returned uuid returns device information using a specified unique_id_type end_seconds and end_nanos
#
#      ${id_type}=  Set Variable  platostesteight
#
#      ${timestamp}=  Get Time  epoch
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#
#     ${countsec}=  Evaluate  ${secs} + 1
#     ${countnano}=  Evaluate  ${nsecs} + 1
#
#
#     ${device}=  Show Device Report  region=${region}  unique_id_type=${id_type}  end_seconds=${countsec}  end_nanos=${nsecs}
#
#
#      Should Be True    ${found['data']['key']['unique_id']}  ${timestamp}
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be True   ${found['data']['first_seen']['seconds']} < ${countsec}
#
#     #Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#     #Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#     
#
#
##ECQ-2138 not supported
#showDeviceReport - request with unique_id unique_id_type begin_seconds and begin_nanos shall return specified device information
#    [Documentation]
#    ...  showDeviceReport display uuid using a specified unique_id unique_id_type end_seconds and end_nanos
#    ...  verify returned uuid returns device information using a specified unique_id unique_id_type end_seconds and end_nanos
#
#      ${id_type}=  Set Variable  tesplatostcasesix
#
#      ${timestamp}=  Get Time  epoch
#
#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=${timestamp}  unique_id_type=${id_type}
#      ${device}=  Show Device  region=${region}
#
#      ${found}=  Find Device  ${device}  ${timestamp}  ${id_type}
#
#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
#      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}
#
#      ${countsec}=  Evaluate  ${secs} + 1
#      ${countnano}=  Evaluate  ${nsecs} + 1
#
#
#     ${device}=  Show Device Report  region=${region}  unique_id=${uid}  unique_id_type=${id_type}  end_seconds=${countsec}  end_nanos=${nsecs}
#
#
#      Should Be True    ${found['data']['key']['unique_id']}  ${timestamp}
#      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#      Should Be True   ${found['data']['first_seen']['seconds']} < ${countsec}
#
#     #Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
#     #Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
#
##
#
#
#  
#ECQ-2139
showDeviceReport - request with bad token
  [Documentation]
    ...  showDevice verify error for bad token
    ...  verify no bearer token found

      # robot function
   #   Run Keyword And Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Show Device Report  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}

      ${error}=  Run Keyword And Expect Error  *  Show Device Report  region=${region}  unique_id=1234  unique_id_type=abcdplatos  use_defaults=${False}
      #Should Be Equal  ${error}  ('code=400', 'error={"message":"no bearer token found"}')
      Should Contain  ${error}  no bearer token found

#ECQ-2140
showDeviceReport - request token error jwt
    [Documentation]
    ...  showDevice verify jwt error
    ...  verify invalid or expired jwt 

      # robot function


      ${error}=  Run Keyword And Expect Error  *  Show Device Report  region=${region}  unique_id=1234  unique_id_type=abcd  token=xx  use_defaults=${False}
      #Should Be Equal  ${error}  ('code=401', 'error={"message":"invalid or expired jwt"}')
      Should Contain  ${error}  ('code=401', 'error={"message":"invalid or expired jwt"}')

*** Keywords ***


Setup
    Create Flavor  region=${region} 
   # ShowDevice  uniqueid=${uniqueid}  
#ShowDevice  uniqueid=${uniqueid}    
    #ShowDevice  uniqueidtype=${uniqueidtype}
    # ignore error since sometimes the platos app already exists
    Run Keyword and Ignore Error  Create App  region=${region}  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/platos/images/server_ping_threaded:6.0


{count}  Evaluate  ${count}+1


   #Set Suite Variable  ${app} 

Find Device
   [Arguments]  ${device}  ${id}  ${type}

   ${fd}=  Set Variable  ${None} 
   FOR  ${d}  IN  @{device}
   #   log to console  ${d['data']['key']['unique_id']} ${id}
      ${fd}=  Run Keyword If  '${d['data']['key']['unique_id']}' == '${id}' and '${d['data']['key']['unique_id_type']}' == '${type}'  Set Variable  ${d}     
      ...  ELSE  Set Variable  ${fd}
   #   Run Keyword If  '${d['data']['key']['unique_id']}' == '${id}' and '${d['data']['key']['unique_id_type']}' == '${type}'    [Return]  ${d}
   #   log to console  ${fd}
   END
 
   [Return]  ${fd}


Find 1587055811
   [Arguments]  ${device}  ${id}  ${type}

   ${fd}=  Set Variable  ${None}
   FOR  ${d}  IN  @{device}
  #    log to console  ${d['data']['key']['unique_id']} ${id}
      ${fd}=  Run Keyword If  '${d['data']['first_seen']['seconds']}' == '1587060066'  Set Variable  ${d}
      ...  ELSE  Set Variable  ${fd}
   #   Run Keyword If  '${d['data']['key']['unique_id']}' == '${id}' and '${d['data']['key']['unique_id_type']}' == '${type}'    [Return]  ${d}
  #    log to console  ${fd}
   END


   [Return]  ${fd}

Current Time
#    [Arguments]  $CurrentDate}  ${newdatetime}
#    ${CurrentDate}=  Get Current Date  result_format=%Y-%m-%d %H:%M:%S.%f
    ${CurrentDate}=  Get Time  epoch
    ${CurrentDate}=  Get Current Date time_zone=UTC  result_format=epoch


    #${newdatetime} =  Add Time To Date  ${CurrentDate}  0 days
    #Log  ${newdatetime}
    #${newdatetime} =  Add Time To Date  ${CurrentDate}  0 hours
    #Log  ${newdatetime}
    #${newdatetime} =  Add Time To Date  ${CurrentDate}  0 minutes
    #Log  ${newdatetime}
    ${newdatetime} =  Add Time To Date  ${CurrentDate}  1 seconds
    Log  ${newdatetime}
