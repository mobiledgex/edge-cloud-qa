*** Settings ***
Documentation   showDevice - request shall return device uniqueid

Library  MexDmeRest     dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${platos_app_name}  platosEnablingLayer
${platos_developer_name}  platos
${platos_cloudlet_name}  default
${platos_operator_name}  developer
${platos_uri}  automation.platos.com
${platos_unique_id}  12345
${platos_unique_id_type}  abcde
${platos_first_seen}  1234
${platos_seconds}  1234
${platos_nanos}  1234
${platos_notify_id}  1234
${region}  US

# add testcase for Developer and Operator user

*** Test Cases ***
showDevice - request with id and type shall return device information
    [Documentation]
    ...  registerClient with platos app
    ...  send showDevice display key.uniqueid 
    ...  verify returns 5 result



      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=1234  unique_id_type=abcd 

      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  

      Should Be Equal  ${device['data']['key']['unique_id_type']}  abcd 
      Should Be Equal  ${device['data']['key']['unique_id']}  1234
      Should Be True   ${device['data']['first_seen']['seconds']} > 0
      Should Be True   ${device['data']['first_seen']['nanos']} > 0
      Should Be True   ${device['data']['notify_id']} > 0

      Length Should Be   ${device}  1

showDevice - request with first_seen and seconds shall return device information
    [Documentation]
    ...  registerClient with platos app
    ...  send showDevice display key.time_seen
    ...  verify returns 1 result


      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=1234  unique_id_type=abcd  
      ${device}=  Show Device  region=${region}
       
      ${found}=  Find Device  ${device}  1234  abcd
 
      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']} 
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
 
      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  first_seen_seconds=${secs}  first_seen_nanos=${nsecs}  notify_id=1

      Should Be Equal   ${device['data']['first_seen']['seconds']}  ${secs} 
      Should Be Equal   ${device['data']['first_seen']['nanos']}  ${nsecs}

      Length Should Be   ${device}  1

showDevice - request without first_seen_seconds shall return device information
    [Documentation]
    ...  registerClient with platos app
    ...  send showDevice display key.uniqueid
    ...  verify returns 1 result

      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=1234  unique_id_type=abcd
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  1234  abcd

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
      
      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  #first_seen_seconds=${secs}  first_seen_nanos=${nsecs}  notify_id=1

      Should Be Equal   ${device['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${device['data']['first_seen']['nanos']}  ${nsecs}

      Length Should Be   ${device}  1



showDevice - request with first_seen_nanos shall return device information

    [Documentation]
    ...  registerClient with platos app
    ...  showDevice check display of first_seen
    ...  verify returns 2 result

      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=1234  unique_id_type=abcd
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  1234  abcd

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}

      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  first_seen_seconds=${secs}  first_seen_nanos=${nsecs}  notify_id=1

      Should Be Equal   ${device['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${device['data']['first_seen']['nanos']}  ${nsecs}

      Length Should Be   ${device}  1



showDevice - without first_seen_nanos shall return device information

    [Documentation]
    ...  registerClient with platos app
    ...  showDevice check display of time_seen_nanos
    ...  verify returns 2 result

      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=1234  unique_id_type=abcd
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  1234  abcd

      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}

      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  #first_seen_nanos=${nsecs}  notify_id=1

      Should Be Equal   ${device['data']['first_seen']['seconds']}  ${secs}
      Should Be Equal   ${device['data']['first_seen']['nanos']}  ${nsecs}

      Length Should Be   ${device}  1


showDevice - with notify_id shall return device information

   [Documentation]
    ...  registerClient with platos app
    ...  showDevice check display of first_seen
    ...  verify returns 2 result

      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=1234  unique_id_type=abcd
      ${device}=  Show Device  region=${region}

      ${found}=  Find Device  ${device}  1234  abcd

#      ${secs}=  Set Variable  ${found['data']['first_seen']['seconds']}
#      ${nsecs}=  Set Variable  ${found['data']['first_seen']['nanos']}
      ${ntfy}=  Set Variable  ${found['data']['notify_id']}	
      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  notify_id=${ntfy}

#      Should Be Equal   ${device['data']['first_seen']['seconds']}  ${secs}
#      Should Be Equal   ${device['data']['first_seen']['nanos']}  ${nsecs}
      Should Be Equal   ${device['data']['notify_id']}  ${ntfy}
      
      Length Should Be   ${device}  1


#      Register Client  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  unique_id=1234  unique_id_type=abcd
#      ${device}=  Show Device  notify_id=${notify_id}
#
#      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  notify_id=2
#      Should Be True  ${device['data']['notify_id']} > 0
#      
#      Length Should Be  ${device}  1

showDevice - without notify_id shall return device information
    [Documentation]
    ...  showDevice display notify_id
    ...  verify returns 1 result

      ${device}=  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd
      Should Be True  ${device['data']['notify_id']} > 0

      Length Should Be  ${device}  1
  

showDevice - request with bad token
  [Documentation]
    ...  showDevice verify error for bad token
    ...  verify returns 1 result

      # robot function
      Run Keyword And Expect Error  ('code=400', 'error={"message":"no bearer token found"}')  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}

      ${error}=  Run Keyword And Expect Error  *  Show Device  region=${region}  unique_id=1234  unique_id_type=abcd  use_defaults=${False}
      #Should Be Equal  ${error}  ('code=400', 'error={"message":"no bearer token found"}')
      Should Contain  ${error}  no bearer token found


showDevice - request token error jwt
    [Documentation]
    ...  showDevice verify jwt error
    ...  verify returns 2 result

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
    Create App  region=${region}  developer_org_name=${platos_developer_name}  app_name=${platos_app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/platos/images/server_ping_threaded:6.0

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
