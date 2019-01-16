*** Settings ***
Documentation  RegisterClient with auth token

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${app_name_auth}  someapplicationAuth   #has to match crm process startup parms
${developer_name}  AcmeAppCo
${app_version}  1.0
${app_key}      -----BEGIN PUBLIC KEY-----${\n}MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij${\n}TkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0${\n}VU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC${\n}GJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS${\n}z3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m${\n}QnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C${\n}/QIDAQAB${\n}-----END PUBLIC KEY-----

${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
${peer_ip}           10.138.0.8

*** Test Cases ***
RegisterClient - request with auth shall return proper JWT
   [Documentation]
   ...  Send RegisterClient with auth token to register a client for an app that contains an authpublickey
   ...  Verify returned JWT is correct

   ${token}=  Generate Auth Token  app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}
   
   Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}
   ${decoded_cookie}=  decoded session cookie
   ${token_server}=    token server uri

   Should Be Equal  ${token_server}  ${token_server_url}
	
   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   #Should Be Equal  ${decoded_cookie['key']['peerip']}   ${peer_ip} 	
   Should Match Regexp  ${decoded_cookie['key']['peerip']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
   Should Be Equal  ${decoded_cookie['key']['devname']}  ${developer_name}	
   Should Be Equal  ${decoded_cookie['key']['appname']}  ${app_name_auth}	
   Should Be Equal  ${decoded_cookie['key']['appvers']}  ${app_version}	

*** Keywords ***
Setup
    #Create Operator             operator_name=${operator_name} 
    Create Developer            developer_name=${developer_name}
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create Cluster Flavor
    Create Cluster
    Create App                  app_name=${app_name_auth}  auth_public_key=${app_key} 
    Create App Instance         app_name=${app_name_auth}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

