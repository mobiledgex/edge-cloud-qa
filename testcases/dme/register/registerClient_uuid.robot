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

${app_version}  1.0
${app_key}      -----BEGIN PUBLIC KEY-----${\n}MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij${\n}TkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0${\n}VU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC${\n}GJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS${\n}z3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m${\n}QnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C${\n}/QIDAQAB${\n}-----END PUBLIC KEY-----
${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc

*** Test Cases ***
# ECQ-2110
RegisterClient - request without id and type shall return device information
    [Documentation]
    ...  registerClient with samsung app without unique_id and type
    ...  verify returns id and type 

      Run Keyword and Ignore Error   Create App  region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0

      ${regresp}=  Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=  unique_id_type=
      Should Be Equal  ${regresp['unique_id_type']}  ${samsung_developer_name}:${samsung_app_name}

      ${len}=  Get Length  ${regresp['unique_id']}
      Should Be Equal As Integers  ${len}  27

# ECQ-2177
RegisterClient - request with id and type shall return empty unique_id and type
    [Documentation]
    ...  registerClient with samsung app with unique_id and type
    ...  verify returns empty id and type

    Run Keyword and Ignore Error   Create App  region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0

    ${regresp}=  Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=1234  unique_id_type=samsungtype
    Length Should Be   ${regresp['unique_id_type']}  0 

    Length Should Be   ${regresp['unique_id']}  0

# ECQ-2178
RegisterClient - request with id and type and auth shall return device information
   [Documentation]
   ...  registerClient with samsung app with unique_id and type and auth
   ...  verify returns id and type

   #Run Keyword and Ignore Error  Create App   region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}    auth_public_key=${app_key}  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0
   Create App   region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}2    auth_public_key=${app_key}  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0

   ${token}=  Generate Auth Token  app_name=${samsung_app_name}2  app_version=${app_version}  developer_name=${samsung_developer_name}

   Register Client      app_name=${samsung_app_name}2  app_version=${app_version}  developer_org_name=${samsung_developer_name}  auth_token=${token}
   ${decoded_cookie}=  decoded session cookie
   ${token_server}=    token server uri

   Should Be Equal  ${token_server}  ${token_server_url}

   ${uuid_length}=  Get Length  ${decoded_cookie['key']['uniqueid']}

   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   #Should Be Equal  ${decoded_cookie['key']['peerip']}   ${peer_ip}
   Should Match Regexp         ${decoded_cookie['key']['peerip']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
   Should Be Equal             ${decoded_cookie['key']['orgname']}  ${samsung_developer_name}
   Should Be Equal             ${decoded_cookie['key']['appname']}  ${samsung_app_name}2
   Should Be Equal             ${decoded_cookie['key']['appvers']}  ${app_version}
   Should Be Equal As Numbers  ${uuid_length}  27
   #Should Be Equal             ${decoded_cookie['key']['uniqueidtype']}  ${samsung_developer_name}:${samsung_app_name} 
   Should Be Equal             ${decoded_cookie['key']['uniqueidtype']}  dme-ksuid

# ECQ-2111
RegisterClient - request without id shall return error 
    [Documentation]
    ...  registerClient with samsung app without id
    ...  verify returns error 


    Run Keyword and Ignore Error   Create App  region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0
 
    ${error}=  Run Keyword And Expect error  *  Register Client  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  unique_id=  unique_id_type=abcd
    #Should Be Equal  ${error}  '('post failed:', Exception('ws did not return a 200 response. responseCode = 400. ResponseBody={\n "code": 3,\n "message": "Both, or none of UniqueId and UniqueIdType should be set",\n "details": [\n ]\n}'))')
    Should Contain  ${error}  "Both, or none of UniqueId and UniqueIdType should be set" 

*** Keywords ***
Setup
    Create Flavor  region=${region} 
   # Create App  region=${region}  developer_org_name=${samsung_developer_name}  app_name=${samsung_app_name}  access_ports=tcp:1  image_path=docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:6.0

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
