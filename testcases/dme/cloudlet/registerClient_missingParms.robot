*** Settings ***
Documentation  RegisterClient with missing parameters
...   attempt to register a client with various combinations of missing parameters

Library  MexDme  dme_address=${dme_api_address}

*** Variables ***
${dme_api_address}  127.0.0.1:50051
${app_name}  someapplication
${app_name_auth}  someapplicationAuth
${developer_name}  AcmeAppCo
${app_version}  1.0

*** Test Cases ***
RegisterClient - request should return 'DevName cannot be empty' with app_name only
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "DevName cannot be empty"

RegisterClient - request should return 'DevName cannot be empty' with app_version only
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_version=${app_version}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "DevName cannot be empty"

RegisterClient - request should return 'AppName cannot be empty' with developer name only
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	developer_name=${developer_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "AppName cannot be empty"

RegisterClient - request should return 'DevName cannot be empty' with app_name and app_version only
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  app_version=${app_version}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "DevName cannot be empty"

RegisterClient - request should return 'AppVers cannot be empty' with app_name and developer_name only
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  developer_name=${developer_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "AppVers cannot be empty"

RegisterClient - request should return 'AppName cannot be empty' with app_version and developer_name only
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_version=${app_version}  developer_name=${developer_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "AppName cannot be empty"

RegisterClient - request should return 'No authtoken received' with no authtoken
   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version}  developer_name=${developer_name}

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   details = "No authtoken received"
