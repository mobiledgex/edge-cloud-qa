*** Settings ***
Documentation   MasterController Token Expire
	
Library		MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Config Cleanup

*** Variables ***
	
*** Test Cases ***
# ECQ-4416
MC - Login token shall expire based on UserLoginTokenValidDuration config value
    [Documentation]
    ...  - config UserLoginTokenValidDuration config value
    ...  - verify login token expires after configured value

    Set Token Duration Config   user_login_token_valid_duration=3m1s  token=${supertoken}

    ${devtoken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
    ${optoken}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Show App Instances  region=US  token=${devtoken}
    Show App Instances  region=US  token=${optoken}
    Sleep  1m
    Show App Instances  region=US  token=${devtoken}
    Show App Instances  region=US  token=${optoken}
    Sleep  1m
    Show App Instances  region=US  token=${devtoken}
    Show App Instances  region=US  token=${optoken}
    Sleep  1m10s
    ${deverror}=  Run Keyword and Expect Error  *  Show App Instances  region=US  token=${devtoken}
    ${operror}=  Run Keyword and Expect Error  *  Show App Instances  region=US  token=${optoken}

    Should Contain  ${deverror}  ('code=400', 'error={"message":"Token is expired by 1
    Should Contain  ${operror}  ('code=400', 'error={"message":"Token is expired by 1

# ECQ-4417
MC - Api Key token shall expire based on ApiKeyLoginTokenValidDuration config value
    [Documentation]
    ...  - config ApiKeyLoginTokenValidDuration config value
    ...  - verify login token expires after configured value
 
    ${perm0act}=    Set Variable   manage
    ${perm0res}=    Set Variable   appinsts
    ${perm1act}=    Set Variable   view
    ${perm1res}=    Set Variable   cloudlets
    ${permlist}=    Create List    ${perm0act}  ${perm0res}   ${perm1act}  ${perm1res}

    Set Token Duration Config   api_key_login_token_valid_duration=1m  token=${supertoken}

    ${devtoken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
 
    ${resp}=  Create User Api Key  organization=automation_dev_org   description=desc   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
    
    ${apitoken}=  Login   apikey_id=${resp['Id']}   apikey=${resp['ApiKey']}

    Show App Instances  region=US  token=${apitoken}
    Sleep  1m10s
    ${deverror}=  Run Keyword and Expect Error  *  Show App Instances  region=US  token=${apitoken}

    Should Contain  ${deverror}  ('code=400', 'error={"message":"Token is expired by 1

# ECQ-4418
MC - Websocket token shall expire based on WebsocketTokenValidDuration config value
    [Documentation]
    ...  - config WebsocketTokenValidDuration config value
    ...  - verify websocket token expires after configured value

    Set Token Duration Config   websocket_token_valid_duration=2m1s  token=${supertoken}

    ${devtoken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

    ${dev_wstoken}=  Create Websocket Token  token=${devtoken}

    Create App Instance  region=US  token=${devtoken}  websocket_token=${dev_wstoken}  app_name=${app_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autoclusterws1  
    Sleep  1m
    Create App Instance  region=US  token=${devtoken}  websocket_token=${dev_wstoken}  app_name=${app_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autoclusterws2
    Sleep  1m10s
    ${deverror}=  Run Keyword and Expect Error  *  Create App Instance  region=US  token=${devtoken}  websocket_token=${dev_wstoken}  app_name=${app_name_automation}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=autoclusterws

    Should Contain  ${deverror}  ('code=400', 'error={"message":"Token is expired by 1
 
*** Keywords ***
Setup
    ${supertoken}=  Get Super Token
    Set Suite Variable   ${supertoken}

Config Cleanup
    Set Token Duration Config   user_login_token_valid_duration=24h0m0s
    Set Token Duration Config   api_key_login_token_valid_duration=4h0m0s
    Set Token Duration Config   websocket_token_valid_duration=2m0s

    Cleanup Provisioning
