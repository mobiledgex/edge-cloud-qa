*** Settings ***
Documentation   showDevice - request shall return device uniqueid

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

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
${samsung_begin_seconds}  124
${samsung_end_seconds}  1234
${samsung_begin_nanos}  1234
${samsung_end_nanos}  1234
${samsung_notify_id}  1234
${region}  US
${plusone}  1
${count}  1

# add testcase for Developer and Operator user

*** Test Cases ***
#ECQ-1
showDeviceReport - request unique_id with only begin_nanos shall return device information
    [Documentation]
    ...  showDeviceReport returns uuid information
    ...  verify showDeviceReport returns uuid device information with specified parameters

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=abcd
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  ${timestamp}  abcd

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}

      ${device}=  Show Device Report  region=${region}  unique_id=${uid}  #begin_seconds=${secs}  begin_nanos=${nsecs}
    
      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${found['data']['key']['unique_id']}  ${uid}
      #Should Be True    ${found['data']['key']['unique_id']} > ${shit} -2
      #Should Be True    ${found['data']['key']['unique_id']} < ${shit} +2

#ECQ-2
showDeviceReport - request unique_id unique_id_type begin_seconds and begin_nanos shall return specified device information
    [Documentation]
    ...  showDeviceReport returns uuid information using begin_seconds and begin_nanos
    ...  verify showDeviceReport returns uuid device information with specified parameters

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=id427912  unique_id_type=april 
      ${device}=  Show Device  region=${region}
       
      ${found}=  Find Device  ${device}  id427912  april
 
      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']} 
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
 
      ${device}=  Show Device Report  region=${region}  unique_id=id427912  unique_id_type=april  begin_seconds=${secs}  begin_nanos=${nsecs}  

      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}  

     # Length Should Be  ${device}  1


#ECQ-2a
showDeviceReport - request unique_id and unique_id_type with begin_nanos shall return device information
    [Documentation]
    ...  showDeviceReport returns uuid using only unique_id and begin_nanos
    ...  verify showDeviceReport returns uuid device information with specified parameters

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=id427913  unique_id_type=october
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  id427913  october

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}

      ${device}=  Show Device Report  region=${region}  unique_id=id427913  unique_id_type=october  begin_nanos=${nsecs}

      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}

     # Length Should Be  ${device}  1


#ECQ-3 
showDeviceReport - request with only begin_seconds and begin_nanos shall return device information

    [Documentation]
    ...  showDeviceReport returns uuid device information only using begin_seconds and begin_nanos
    ...  verify returned uuid returns uuid using begin_seconds and begin_nanos

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=bothbegins
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  ${timestamp}  bothbegins

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}
      
      ${device}=  Show Device Report  region=${region}  begin_seconds=${secs}  begin_nanos=${nsecs}

      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
      Should Be Equal   ${found['data']['key']['unique_id']}  ${uid} 


#ECQ-4
showDeviceReport - request uuid with only begin_nano shall return device information

    [Documentation]
    ...  showDeviceReport returns uuid device information using only begin_nanos
    ...  verify uuid information is returned using only begin_nanos

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=abcd
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  ${timestamp}  abcd

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}

      ${device}=  Show Device Report  region=${region}  begin_nanos=${nsecs}

      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}

     # Length Should Be  ${device}  1


#ECQ-5
showDeviceReport - request uuid with only begin_seconds shall returns device information 

    [Documentation]
    ...  showDeviceReport returns uuid device information with begin_seconds
    ...  verify returned uuid returns device information

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=abcd
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  ${timestamp}  abcd

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}

      ${device}=  Show Device Report  region=${region}  begin_seconds=${nsecs}

      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}

     # Length Should Be  ${device}  1

#ECQ-6 end_seconds
showDeviceReport - request with only end_seconds and end_nanos shall return device information

    [Documentation]
    ...  showDeviceReport returns uuid device information with begin_seconds and begin_nanos
    ...  verify returned uuid returns device information


      ${timestamp}=  Get Time  epoch
      
      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=testcasesix
      ${device}=  Show Device Report  region=${region}
     

      ${found}=  Find Device  ${device}  ${timestamp}  testcasesix

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}

      ${device}=  Show Device Report  region=${region}  end_seconds=${secs}  end_nanos=${nsecs}


      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${found['data']['key']['unique_id']}  ${uid}
#     Should Be True    ${found['data']['key']['unique_id']} > ${uid} -2
#     Should Be True    ${found['data']['key']['unique_id']} < ${uid} +2

#      Should Be Equal  ${device['data']['key']['unique_id_type']}  abcd
#      Should Be Equal  ${device['data']['key']['unique_id']}  1234
#      Should Be True   ${device['data']['first_seen']['seconds']} > 0
#      Should Be True   ${device['data']['first_seen']['nanos']} > 0
#      Should Be True   ${device['data']['notify_id']} > 0


#ECQ-7  end_nanos
showDeviceReport - request with unique_id end_seconds and end_nanos shall return device information
    [Documentation]
    ...  showDevice displays requested firstseen data
    ...  verify returns time of first_seen seconds requested
    ...  key.uniqueidtype key.uniqueid firstseen.seconds firstseen.nanos lastseen.seconds lastseen.nanos and notify_id

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=april
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  ${timestamp}  april

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}

      ${countsec}=  Evaluate  ${secs} + 1
      ${countnano}=  Evaluate  ${nsecs} + 1

      ${device}=  Show Device Report  region=${region}  unique_id=${uid} end_seconds=${countsec}  end_nanos=${nsecs}

      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
      Should Be Equal   ${found['data']['key']['unique_id']}  ${uid}


     # Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
     # Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
     # Should Be Equal   ${found['data']['key']['unique_id']}  ${uid}   
     # Length Should Be  ${device}  1

#ECQ-8- working count for end
showDeviceReport - request with end_seconds and end_nanos shall return device data

    [Documentation]
    ...  showDeviceReport returns uuid informtion with only end_seconds and end_nanos
    ...  verify time_seen_nanos is displayed without being requested

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=endnanos2
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  ${timestamp}  endnanos2

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
     
     ${countsec}=  Evaluate  ${secs} + 1
     ${countnano}=  Evaluate  ${nsecs} + 1


     ${device}=  Show Device Report  region=${region}  end_seconds=${secs}  end_nanos=${countnano}


      Should Be True    ${found['data']['key']['unique_id']}  ${timestamp}
      Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
      Should Be True   ${found['data']['first_seen']['nanos']} < ${countnano}

     #Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
     #Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}    
     # Should Not Be Equal   ${found['data']['first_seen']['nanos']}  ${count}
     # Should Be True    ${found['data']['key']['unique_id']} < ${count1}
     # Length Should Be   ${device}  1

#ECQ-9
showDeviceReport - returns uuid information with unique_id with end_seconds and end_nanos shall return device information

    [Documentation]
    ...  showDeviceReport display uuid using unique_id with end_seconds and end_nanos
    ...  verify returned information 

      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=testeight
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  ${timestamp}  testeight

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}

     ${countsec}=  Evaluate  ${secs} + 1
     ${countnano}=  Evaluate  ${nsecs} + 1


     ${device}=  Show Device Report  region=${region}  unique_id_type=testeight  end_seconds=${countsec}  end_nanos=${nsecs}


      Should Be True    ${found['data']['key']['unique_id']}  ${timestamp}
      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be True   ${found['data']['first_seen']['seconds']} < ${countsec}

     #Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
     #Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}
     


#ECQ- 10 Return one specific record with begin_seconds
showDeviceReport - equest unique_id unique_id_type begin_seconds and begin_nanos shall return specified device information
    [Documentation]
    ...  showDeviceReport returns uuid information using end_seconds and end_nanos
    ...  verify showDeviceReport returns uuid device information with specified parameters 


      ${timestamp}=  Get Time  epoch

      Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=${timestamp}  unique_id_type=testeight
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  ${timestamp}  testeight

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
      ${uid}=  Set Variable  ${found['data']['key']['unique_id']}

      ${countsec}=  Evaluate  ${secs} + 1
      ${countnano}=  Evaluate  ${nsecs} + 1


     ${device}=  Show Device Report  region=${region}  unique_id=${uid}  unique_id_type=testeight  end_seconds=${countsec}  end_nanos=${nsecs}


      Should Be True    ${found['data']['key']['unique_id']}  ${timestamp}
      Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
      Should Be True   ${found['data']['first_seen']['seconds']} < ${countsec}

     #Should Be Equal   ${found['data']['first_seen']['seconds']}  ${secs}
     #Should Be Equal   ${found['data']['first_seen']['nanos']}  ${nsecs}




  
#ECQ-11
showDeviceReport - request with bad token
  [Documentation]
    ...  showDevice verify error for bad token
    ...  verify no bearer token found

      # robot function
   #   Run Keyword And Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Show Device Report  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}

      ${error}=  Run Keyword And Expect Error  *  Show Device Report  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}
      #Should Be Equal  ${error}  ('code=400', 'error={"message":"no bearer token found"}')
      Should Contain  ${error}  no bearer token found

#ECQ-12
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
    Create App  region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0


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
