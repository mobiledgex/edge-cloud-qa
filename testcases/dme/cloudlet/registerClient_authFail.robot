*** Settings ***
Documentation  RegisterClient - various auth fail erors


Library  MexDme  dme_address=${dme_api_address}
#Library		MexController  controller_address=${controller_api_address}

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${controller_api_address}  127.0.0.1:55001
${app_name}  someapplication
${app_name_auth}  someapplicationAuth
${developer_name}  AcmeAppCo
${app_version}  1.0
${expired_token}  eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDIzODc5NDksImlhdCI6MTU0MjM4Nzg4OSwiZGV2bmFtZSI6IkFjbWVBcHBDbyIsImFwcG5hbWUiOiJzb21lYXBwbGljYXRpb25BdXRoIiwiYXBwdmVycyI6IjEuMCJ9.bJwA5_AKQvzEFOX5x5xeXEKLobNHXbyVx7FP_nGKOHLCuLl4_F3pnU3slnMfnWRmPS-4ewhp2u6w_aYK2_xwuvLN4kIz1zz9olQ02J03mrDW0He2EDu_6EpA9qHHnf2gSA_BU_tnbltTcqKbWj8XsN6rAPSJ7InW78KEiC5AKYI6j3ZVUhuzMgLcK-oessPs6L7FOpuTfOrHV6zrSYMXAsoq3qdACuB6m3QjgnS9Na8nGUzZV75lCrvcuFIz6NqWi3QPnk9XaDNezAzWAgUMrqp3DHUr6R-nBAg4TefSJcD0FCePeGfih34hbHqwiehXfVJ2Ux07lUvq-lu0s-vO3g

${operator_name}  tmus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

*** Test Cases ***
RegisterClient - request should return 'No authkey found to validate token' with app without token
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  app_version=${app_version}  developer_name=${developer_name}  auth_token=1234

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "No authkey found to validate token"

RegisterClient - request should return 'failed to verify token - token appvers mismatch' with invalid version in token
   ${token}=  Generate Auth Token  app_name=${app_name_auth}  app_version=2.0  developer_name=${developer_name}

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - token appvers mismatch"

RegisterClient - request should return 'failed to verify token - token appname mismatch' with invalid appname in token
   ${token}=  Generate Auth Token  app_name=myapp  app_version=${app_version}  developer_name=${developer_name}

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - token appname mismatch"

RegisterClient - request should return 'failed to verify token - token developer mismatch' with invalid appname in token
   ${token}=  Generate Auth Token  app_name=${app_name}  app_version=${app_version}  developer_name=mydev

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - token developer mismatch"

RegisterClient - request should return 'failed to verify token - unable to verify token against key' with invalid appname in token
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=x

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - unable to verify token against key"

RegisterClient - request should return failed with expired token
   # should pass register since valid token
   ${token}=  Generate Auth Token  app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}
   Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Sleep  1 minute 10 seconds
	
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "failed to verify token - unable to verify tokey"
