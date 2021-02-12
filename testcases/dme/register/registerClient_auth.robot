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
#${developer_name}  AcmeAppCo
${app_version}  1.0
${app_key}      -----BEGIN PUBLIC KEY-----${\n}MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij${\n}TkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0${\n}VU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC${\n}GJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS${\n}z3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m${\n}QnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C${\n}/QIDAQAB${\n}-----END PUBLIC KEY-----

${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
#${token_server_local_url}  http://127.0.0.1:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc

${peer_ip}           10.138.0.8

*** Test Cases ***
RegisterClient - request with auth shall return proper JWT for deployment=docker
   [Documentation]
   ...  Send RegisterClient with auth token to register a client for an app that contains an authpublickey
   ...  Verify returned JWT is correct

   Create App                  auth_public_key=${app_key}  deployment=docker
   Create App Instance         cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

   ${developer_name_default}=  Get Default Developer Name
   ${app_name_default}=  Get Default App Name
   ${token}=  Generate Auth Token  app_name=${app_name_default}  app_version=${app_version}  developer_name=${developer_name_default}
   
   Register Client	app_name=${app_name_default}  app_version=${app_version}  developer_org_name=${developer_name_default}  auth_token=${token}
   ${decoded_cookie}=  decoded session cookie
   ${token_server}=    token server uri

#   ${status}  ${value}=  Run Keyword And Ignore Error  Should Contain  %{AUTOMATION_DME_ADDRESS}  127.0.0.1
#   Run Keyword If   '${status}' == 'PASS'   Should Be Equal  ${token_server}  ${token_server_local_url}
#   ...  ELSE  Should Be Equal  ${token_server}  ${token_server_url}

   Should Be Equal  ${token_server}  ${token_server_url}

   ${uuid_length}=  Get Length  ${decoded_cookie['key']['uniqueid']}
	
   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   #Should Be Equal  ${decoded_cookie['key']['peerip']}   ${peer_ip} 	
   Should Match Regexp         ${decoded_cookie['key']['peerip']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
   Should Be Equal             ${decoded_cookie['key']['orgname']}  ${developer_name_default}	
   Should Be Equal             ${decoded_cookie['key']['appname']}  ${app_name_default}	
   Should Be Equal             ${decoded_cookie['key']['appvers']}  ${app_version}	
   Should Be Equal As Numbers  ${uuid_length}  27
   Should Be Equal             ${decoded_cookie['key']['uniqueidtype']}  dme-ksuid

RegisterClient - request with auth shall return proper JWT for deployment=kubernetes
   [Documentation]
   ...  Send RegisterClient with auth token to register a client for an app that contains an authpublickey
   ...  Verify returned JWT is correct

   Create App                  auth_public_key=${app_key}  deployment=kubernetes
   Create App Instance         cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster

   ${developer_name_default}=  Get Default Developer Name
   ${app_name_default}=  Get Default App Name
   ${token}=  Generate Auth Token  app_name=${app_name_default}  app_version=${app_version}  developer_name=${developer_name_default}

   Register Client      app_name=${app_name_default}  app_version=${app_version}  developer_org_name=${developer_name_default}  auth_token=${token}
   ${decoded_cookie}=  decoded session cookie
   ${token_server}=    token server uri

   ${uuid_length}=  Get Length  ${decoded_cookie['key']['uniqueid']}

   Should Be Equal  ${token_server}  ${token_server_url}

   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   #Should Be Equal  ${decoded_cookie['key']['peerip']}   ${peer_ip}
   Should Match Regexp         ${decoded_cookie['key']['peerip']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
   Should Be Equal             ${decoded_cookie['key']['orgname']}  ${developer_name_default}
   Should Be Equal             ${decoded_cookie['key']['appname']}  ${app_name_default}
   Should Be Equal             ${decoded_cookie['key']['appvers']}  ${app_version}
   Should Be Equal As Numbers  ${uuid_length}  27
   Should Be Equal             ${decoded_cookie['key']['uniqueidtype']}  dme-ksuid

RegisterClient - request with auth shall return proper JWT for deployment=vm
   [Documentation]
   ...  Send RegisterClient with auth token to register a client for an app that contains an authpublickey
   ...  Verify returned JWT is correct

   Create App                  auth_public_key=${app_key}  deployment=vm  image_type=ImageTypeQCOW
   Create App Instance         cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  

   ${developer_name_default}=  Get Default Developer Name
   ${app_name_default}=  Get Default App Name
   ${token}=  Generate Auth Token  app_name=${app_name_default}  app_version=${app_version}  developer_name=${developer_name_default}

   Register Client      app_name=${app_name_default}  app_version=${app_version}  developer_org_name=${developer_name_default}  auth_token=${token}
   ${decoded_cookie}=  decoded session cookie
   ${token_server}=    token server uri

   ${uuid_length}=  Get Length  ${decoded_cookie['key']['uniqueid']}

   Should Be Equal  ${token_server}  ${token_server_url}

   ${expire_time}=  Evaluate  (${decoded_cookie['exp']} - ${decoded_cookie['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   #Should Be Equal  ${decoded_cookie['key']['peerip']}   ${peer_ip}
   Should Match Regexp         ${decoded_cookie['key']['peerip']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b
   Should Be Equal             ${decoded_cookie['key']['orgname']}  ${developer_name_default}
   Should Be Equal             ${decoded_cookie['key']['appname']}  ${app_name_default}
   Should Be Equal             ${decoded_cookie['key']['appvers']}  ${app_version}
   Should Be Equal As Numbers  ${uuid_length}  27
   Should Be Equal             ${decoded_cookie['key']['uniqueidtype']}  dme-ksuid

*** Keywords ***
Setup
    #Create Operator             operator_name=${operator_name} 
    #Create Developer            #developer_name=${developer_name}
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    #Create Cluster
    #Create App                  auth_public_key=${app_key}  deployment=docker 
    #Create App Instance         cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=autocluster

