*** Settings ***
Documentation   RegisterClient with uuid 

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
# ECQ-2110
RegisterClient - request without id and type shall return device information
    [Documentation]
    ...  registerClient with samsung app without unique_id and typ
    ...  verify returns id and type 


#     Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=  unique_id_type=  

      ${regresp}=  Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=  unique_id_type=
      Should Be Equal  ${regresp['unique_id_type']}  ${samsung_developer_name}:${samsung_app_name}

      ${len}=  Get Length  ${regresp['unique_id']}
      Should Be Equal As Integers  ${len}  27

      #Should Contain  ${debug}  ${resp['unique_id']}

      #${device}=  Register Client  ${resp['unique_id']}

      #Should Be Equal  ${resp['unique_id']  ${samsung_unique_id}

#     Should Not Be Equal  ${device[-1]['data']['key']['unique_id_type']}  unique_id_type
#      Should Be Equal  ${device[-1]['data']['key']['unique_id_type']} ${samsung_unique_id_type} 
#      Should Be Equal  ${device[-1]['data']['key']['unique_id']} ${samsung_unique_id}
#      Should Be True   ${device[-1]['data']['first_seen']['seconds']} > 0
#      Should Not Be True   ${device[-1]['data']['first_seen']['nanos']} < 0
#      Should Be True   ${device[-1]['data']['notify_id']} > 0

#     ${device}=  Show Device  region=${region}  unique_id_type=${Samsung:SamsungEnablingLayer}  unique_id=${unique_id}

# ECQ-2111
RegisterClient - request without id shall return error 
    [Documentation]
    ...  registerClient with samsung app without id
    ...  verify returns error 


      #Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=  unique_id_type=abcd
      
      ${error}=  Run Keyword And Expect error  *  Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=  unique_id_type=abcd
      #Should Be Equal  ${error}  '('post failed:', Exception('ws did not return a 200 response. responseCode = 400. ResponseBody={\n "code": 3,\n "message": "Both, or none of UniqueId and UniqueIdType should be set",\n "details": [\n ]\n}'))')
      Should Contain  ${error}  "Both, or none of UniqueId and UniqueIdType should be set" 

      ${device}=  Show Device  region=${region}

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
