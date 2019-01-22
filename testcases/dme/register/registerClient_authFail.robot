*** Settings ***
Documentation  RegisterClient - various auth fail erors


Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
#${dme_api_address}  127.0.0.1:50051
#${controller_api_address}  127.0.0.1:55001
${app_name}  someapplication
${app_name_auth}  someapplicationAuth
${developer_name}  AcmeAppCo
${app_version}  1.0
${app_key}      -----BEGIN PUBLIC KEY-----${\n}MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij${\n}TkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0${\n}VU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC${\n}GJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS${\n}z3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m${\n}QnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C${\n}/QIDAQAB${\n}-----END PUBLIC KEY-----

${expired_token}  eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDIzODc5NDksImlhdCI6MTU0MjM4Nzg4OSwiZGV2bmFtZSI6IkFjbWVBcHBDbyIsImFwcG5hbWUiOiJzb21lYXBwbGljYXRpb25BdXRoIiwiYXBwdmVycyI6IjEuMCJ9.bJwA5_AKQvzEFOX5x5xeXEKLobNHXbyVx7FP_nGKOHLCuLl4_F3pnU3slnMfnWRmPS-4ewhp2u6w_aYK2_xwuvLN4kIz1zz9olQ02J03mrDW0He2EDu_6EpA9qHHnf2gSA_BU_tnbltTcqKbWj8XsN6rAPSJ7InW78KEiC5AKYI6j3ZVUhuzMgLcK-oessPs6L7FOpuTfOrHV6zrSYMXAsoq3qdACuB6m3QjgnS9Na8nGUzZV75lCrvcuFIz6NqWi3QPnk9XaDNezAzWAgUMrqp3DHUr6R-nBAg4TefSJcD0FCePeGfih34hbHqwiehXfVJ2Ux07lUvq-lu0s-vO3g

${operator_name}  dmuus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

*** Test Cases ***
RegisterClient - request for app without authpublickey shall return 'No authkey found to validate token'
   [Documentation]
   ...  send RegisterClient with for app with no authpublickey
   ...  verify 'No authkey found to validate token' is received

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}  auth_token=1234

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "No authkey found to validate token"

RegisterClient - request with invalid version in token shall return 'failed to verify token - token appvers mismatch'
   [Documentation]
   ...  send RegisterClient with wrong app version
   ...  verify 'failed to verify token - token appvers mismatch' is received

   ${token}=  Generate Auth Token  app_name=${app_name_auth}  app_version=2.0  developer_name=${developer_name}

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - token appvers mismatch"

RegisterClient - request with invalid appname in token shall return 'failed to verify token - token appname mismatch'
   [Documentation]
   ...  send RegisterClient with wrong app name
   ...  verify 'failed to verify token - token appname mismatch' is received

   ${token}=  Generate Auth Token  app_name=myapp  app_version=${app_version}  developer_name=${developer_name}

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - token appname mismatch"

RegisterClient - request with invalid devname in token shall return 'failed to verify token - token developer mismatch'
   [Documentation]
   ...  send RegisterClient with wrong developer name
   ...  verify 'failed to verify token - token developer mismatch'

   ${token}=  Generate Auth Token  app_name=${app_name}  app_version=${app_version}  developer_name=mydev

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - token developer mismatch"

RegisterClient - request with invalid token shall return 'failed to verify token - token contains an invalid number of segments'
   [Documentation]
   ...  send RegisterClient with wrong auth token
   ...  verify 'failed to verify token - token contains an invalid number of segments' is received

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=x

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - token contains an invalid number of segments"

RegisterClient - request with expired token shall return 'failed to verify token - token is expired'
   [Documentation]
   ...  generate at token
   ...  send RegisterClient with the token which should pass
   ...  wait 70secs and send RegisterClient again with the same token
   ...  verify 'failed to verify token - token is expired' is received
 
   # should pass register since valid token
   ${token}=  Generate Auth Token  app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}
   Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Sleep  1 minute 10 seconds
	
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - token is expired

*** Keywords ***
Setup
    #Create Operator             operator_name=${operator_name} 
    Create Developer            developer_name=${developer_name}
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create Cluster Flavor
    Create Cluster
    Create App                  app_name=${app_name}
    Create App                  app_name=${app_name_auth}  auth_public_key=${app_key}
    Create App Instance         app_name=${app_name}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create App Instance         app_name=${app_name_auth}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

