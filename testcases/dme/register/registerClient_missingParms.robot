*** Settings ***
Documentation  RegisterClient with missing parameters
...   attempt to register a client with various combinations of missing parameters

Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Variables  shared_variables.py

#Suite Setup	Setup
#Suite Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-2  #has to match crm process startup parms
#${app_name}  someapplication
#${app_name_auth}  someapplicationAuth
#${developer_name}  AcmeAppCo
${app_name}  automation_api_app
${app_name_auth}  automation_api_auth_app
${developer_name}  ${developer_org_name_automation}
${app_version}  1.0
#${app_key}      -----BEGIN PUBLIC KEY-----${\n}MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij${\n}TkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0${\n}VU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC${\n}GJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS${\n}z3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m${\n}QnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C${\n}/QIDAQAB${\n}-----END PUBLIC KEY-----

*** Test Cases ***
RegisterClient - request with app_name only shall return 'DevName cannot be empty'
   [Documentation]
   ...  Send RegisterClient with app_name only
   ...  Verify 'DevName cannot be empty' is returned

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "OrgName cannot be empty"

RegisterClient - request with app_version only shall return 'DevName cannot be empty'
   [Documentation]
   ...  Send RegisterClient with app_version only
   ...  Verify 'DevName cannot be empty' is returned

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_version=${app_version}  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "OrgName cannot be empty"

RegisterClient - request with developer name only shall return 'AppName cannot be empty'
   [Documentation]
   ...  Send RegisterClient with developer name only
   ...  Verify 'AppName cannot be empty' is returned

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	developer_org_name=${developer_name}  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "AppName cannot be empty"

RegisterClient - request without developer name shall return 'DevName cannot be empty'
   [Documentation]
   ...  Send RegisterClient without developer name
   ...  Verify 'DevName cannot be empty' is returned

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  app_version=${app_version}  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "OrgName cannot be empty"

RegisterClient - request without app version shall return 'AppVers cannot be empty'
   [Documentation]
   ...  Send RegisterClient without app version
   ...  Verify 'AppVers cannot be empty' is returned

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name}  developer_org_name=${developer_name}  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "AppVers cannot be empty"

RegisterClient - request without app name shall return 'AppName cannot be empty'
   [Documentation]
   ...  Send RegisterClient without app_name
   ...  Verify 'AppName cannot be empty' is returned

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_version=${app_version}  developer_org_name=${developer_name}  use_defaults=${False}

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "AppName cannot be empty"

RegisterClient - request without authtoken for app with token shall return 'No authtoken received'
   [Documentation]
   ...  Send RegisterClient without authtoken for app that does not have a public key
   ...  Verify 'No authtoken received' is returned

   ${app_version_default}=     Get Default App Version

   ${error_msg}=  Run Keyword And Expect Error  *  Register Client	app_name=${app_name_auth}  app_version=${app_version_default}  developer_org_name=${developer_name}  use_defaults=${False} 

   Should Contain  ${error_msg}   status = StatusCode.INVALID_ARGUMENT
   Should Contain  ${error_msg}   details = "No authtoken received"

*** Keywords ***
Setup
    #Create Operator             operator_name=${operator_name} 
    #Create Developer            
    Create Flavor
    #Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    #Create Cluster
    Create App                 app_name=${app_name} 
    Create App Instance        app_name=${app_name}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster
    Create App                  app_name=${app_name_auth}  auth_public_key=${app_key}
    Create App Instance         app_name=${app_name_auth}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=autocluster


