*** Settings ***
Documentation  RegisterClient - various auth fail erors


Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

*** Variables ***
${app_version}     1.0
${app_name}        automation_api_app
${app_name_auth}   automation_api_auth_app
${developer_name}  ${developer_org_name_automation} 

*** Test Cases ***
# ECQ-891
RegisterClient - request for app without authpublickey shall return 'No authkey found to validate token'
   [Documentation]
   ...  send RegisterClient with for app with no authpublickey
   ...  verify 'No authkey found to validate token' is received

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  app_version=${app_version}  developer_org_name=${developer_name}  auth_token=1234

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "No authkey found to validate token"

# ECQ-892
RegisterClient - request with invalid version in token shall return 'failed to verify token - token appvers mismatch'
   [Documentation]
   ...  send RegisterClient with wrong app version
   ...  verify 'failed to verify token - token appvers mismatch' is received

   ${token}=  Generate Auth Token  app_name=${app_name_auth}  app_version=2.0  developer_name=${developer_name}

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_org_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "failed to verify token - token appvers mismatch"

# ECQ-893
RegisterClient - request with invalid appname in token shall return 'failed to verify token - token appname mismatch'
   [Documentation]
   ...  send RegisterClient with wrong app name
   ...  verify 'failed to verify token - token appname mismatch' is received

   ${token}=  Generate Auth Token  app_name=myapp  app_version=${app_version}  developer_name=${developer_name}

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_org_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "failed to verify token - token appname mismatch"

# ECQ-894
RegisterClient - request with invalid devname in token shall return 'failed to verify token - token developer mismatch'
   [Documentation]
   ...  send RegisterClient with wrong developer name
   ...  verify 'failed to verify token - token developer mismatch'

   ${token}=  Generate Auth Token  app_name=${app_name}  app_version=${app_version}  developer_name=mydev

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_org_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "failed to verify token - token organization mismatch"

# ECQ-895
RegisterClient - request with invalid token shall return 'failed to verify token - token contains an invalid number of segments'
   [Documentation]
   ...  send RegisterClient with wrong auth token
   ...  verify 'failed to verify token - token contains an invalid number of segments' is received

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_org_name=${developer_name}  auth_token=x

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "failed to verify token - token contains an invalid number of segments"

# ECQ-896
RegisterClient - request with expired token shall return 'failed to verify token - token is expired'
   [Documentation]
   ...  generate at token
   ...  send RegisterClient with the token which should pass
   ...  wait 70secs and send RegisterClient again with the same token
   ...  verify 'failed to verify token - token is expired' is received
 
   # should pass register since valid token
   ${token}=  Generate Auth Token  app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}
   Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_org_name=${developer_name}  auth_token=${token}

   Sleep  1 minute 10 seconds
	
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_org_name=${developer_name}  auth_token=${token}

   Should Contain  ${error_msg}   status = StatusCode.UNAUTHENTICATED
   Should Contain  ${error_msg}   details = "failed to verify token - token is expired

