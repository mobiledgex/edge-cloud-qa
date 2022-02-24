*** Settings ***
Documentation  user api key
	
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  Collections
Library  String
Library  MexApp
	
Test Setup	Setup
Test Teardown   Cleanup Provisioning

*** Variables ***
${errmsg}=     API key ID not found
${key}=        ApiKey
${keyid}=      Id
${appname}=    automation_api_app
${devorg}=     automation_dev_org
${oporg}=      tmus
${cldlet}=     ApiKey_Cloudlet
	
*** Test Cases ***
# ECQ-4376
MC - Create Show Delete an api key
   [Documentation]
   ...   - create an api key with the current user
   ...   - show an api key for the current user
   ...   - delete an api key for the current user
   ...   - verify all actions

   ${desc}=        Set Variable   Test development api key
   ${perm0act}=    Set Variable   manage       #action
   ${perm0res}=    Set Variable   appinsts     #resource
   ${perm1act}=    Set Variable   view         #action
   ${perm1res}=    Set Variable   cloudlets    #resource
   ${permlist}=    Create List    ${perm0act}  ${perm0res}   ${perm1act}  ${perm1res}  

   ${devtoken}=     Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${resp}=  Create User Api Key  organization=automation_dev_org   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   ${key}
   Should Contain  ${resp}   ${keyid}

   ${apikeyid}=     Set Variable      ${resp['Id']}
   ${apikey}=       Set Variable      ${resp['ApiKey']}

   ${show}=  Show User Api Key   token=${devtoken}   apikey_id=${apikeyid}   use_defaults=${False}
   Should Be Equal As Strings   ${show[0]['Id']}   ${apikeyid}

   Delete User Api Key  apikey_id=${apikeyid}   token=${devtoken}   use_defaults=${False}
   ${resp}=  Run Keyword and Expect Error  *  Show User Api Key   token=${devtoken}   apikey_id=${apikeyid}   use_defaults=${False}
   Should Contain   ${resp}   ${errmsg}

# ECQ-4377
MC - Login with an api key
   [Documentation]
   ...  - create an api key with the current user
   ...  - login with the api key
   ...  - verify the login was successful

   ${desc}=        Set Variable   Test dev api key
   ${perm0act}=    Set Variable   manage
   ${perm0res}=    Set Variable   appinsts
   ${perm1act}=    Set Variable   view
   ${perm1res}=    Set Variable   cloudlets
   ${permlist}=    Create List    ${perm0act}  ${perm0res}   ${perm1act}  ${perm1res}  

   ${devtoken}=     Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${resp}=  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   ${key}
   Should Contain  ${resp}   ${keyid}
   ${apitoken}=  Login   apikey_id=${resp['Id']}   apikey=${resp['ApiKey']}
   Should Not Be Empty   ${apitoken}
	
   Delete User Api Key  apikey_id=${resp['Id']}   token=${devtoken}   use_defaults=${False}
   ${resp}=  Run Keyword and Expect Error  *  Show User Api Key   token=${devtoken}   apikey_id=${resp['Id']}   use_defaults=${False}
   Should Contain   ${resp}   ${errmsg}

# ECQ-4378
MC - Verify user apikey create limit 
   [Documentation]
   ...  - change the config userapikeycreatelimit to 3 (default 10)
   ...  - try and create 4 api keys
   ...  - verify the correct error is given 

   ${desc}=        Set Variable        Test api key limit
   ${perm0act}=    Set Variable        manage       #action
   ${perm0res}=    Set Variable        appinsts     #resource
   ${perm1act}=    Set Variable        view         #action
   ${perm1res}=    Set Variable        cloudlets    #resource
   ${permlist}=    Create List         ${perm0act}  ${perm0res}   ${perm1act}  ${perm1res}  
   ${three}=       Convert To Integer  3
   ${ten}=         Convert To Integer  10
   ${createerr}=   Set Variable        User cannot create more than 3 API keys, please delete existing keys to create new one
  
   ${adminToken}=   Get Super Token
   Set Apikey Limit Config    apikey_limit=${three}
   ${config}=   Show Config    token=${adminToken}
   Should Be Equal As Numbers   ${config['UserApiKeyCreateLimit']}   ${three}
   ${devtoken}=     Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${resp1}=  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp1}   ${key}
   Should Contain  ${resp1}   ${keyid}
   ${resp2}=  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp2}   ${key}
   Should Contain  ${resp2}   ${keyid}
   ${resp3}=  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp3}   ${key}
   Should Contain  ${resp3}   ${keyid}
   ${failed}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain   ${failed}   ${createerr}

   Delete User Api Key  apikey_id=${resp1['Id']}   token=${devtoken}   use_defaults=${False}
   ${clear}=  Run Keyword and Expect Error  *  Show User Api Key   token=${devtoken}   apikey_id=${resp1['Id']}   use_defaults=${False}
   Should Contain   ${clear}   code=400
   Should Contain   ${clear}   ${errmsg}
   Delete User Api Key  apikey_id=${resp2['Id']}   token=${devtoken}   use_defaults=${False}
   ${clear}=  Run Keyword and Expect Error  *  Show User Api Key   token=${devtoken}   apikey_id=${resp2['Id']}   use_defaults=${False}
   Should Contain   ${clear}   code=400
   Should Contain   ${clear}   ${errmsg}
   Delete User Api Key  apikey_id=${resp3['Id']}   token=${devtoken}   use_defaults=${False}
   ${clear}=  Run Keyword and Expect Error  *  Show User Api Key   token=${devtoken}   apikey_id=${resp3['Id']}   use_defaults=${False}
   Should Contain   ${clear}   code=400
   Should Contain   ${clear}   ${errmsg}

   Set Apikey Limit Config    apikey_limit=${ten}   token=${adminToken}
   ${config}=   Show Config    token=${adminToken}
   Should Be Equal As Numbers   ${config['UserApiKeyCreateLimit']}   ${ten}

# ECQ-4379
MC - Verify manager user role premissions check on api key creation
   [Documentation] 
   ...  - this test will verify the premmisions of the api key are a subset of the current users permissions
   ...  - try and give permissions for a manager resource to a contributor/viewer developer/operator apikeys
   ...  - verify error messages in all cases 

   ${desc}=        Set Variable   Test manager api key
   ${perm0act}=    Set Variable   manage       #action
   ${perm0res}=    Set Variable   users        #resource
   ${permlist}=    Create List    ${perm0act}  ${perm0res}    

   ${devtoken}=     Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

   ${devtoken}=     Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

   ${optoken}=     Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${oporg}   description=${desc}   token=${optoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

   ${optoken}=     Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${oporg}   description=${desc}   token=${optoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

# ECQ-4380
MC - Verify contributor user role premissions check on api key creation
   [Documentation] 
   ...  - this test will verify the premmisions of the api key are a subset of the current users permissions
   ...  - try and give permissions for a contributor resource to a viewer developer/operator apikeys
   ...  - verify error messages in all cases 

   ${desc}=        Set Variable   Test contributor api key
   ${perm0act}=    Set Variable   manage       #action
   ${perm0res}=    Set Variable   apps         #resource
   ${permlist}=    Create List    ${perm0act}  ${perm0res}    

   ${devtoken}=     Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

   ${perm0act}=    Set Variable   manage       #action
   ${perm0res}=    Set Variable   cloudlets    #resource
   ${permlist}=    Create List    ${perm0act}  ${perm0res}    

   ${optoken}=     Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${oporg}   description=${desc}   token=${optoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

# ECQ-4381
MC - Verify user type checked on api key creation
   [Documentation]
   ...  - this test will verify dev resources can not be given to an operator apikey and visa versa
   ...  - verify error messages are correct 

   ${desc}=        Set Variable   Test oper user api key
   ${perm0act}=    Set Variable   manage       #action
   ${perm0res}=    Set Variable   appinsts     #resource
   ${permlist}=    Create List    ${perm0act}  ${perm0res}    

   ${optoken}=     Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${oporg}   description=${desc}   token=${optoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

   ${perm0act}=    Set Variable   view         #action
   ${perm0res}=    Set Variable   apps         #resource
   ${permlist}=    Create List    ${perm0act}  ${perm0res}    

   ${optoken}=     Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${oporg}   description=${desc}   token=${optoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

   ${desc}=        Set Variable   Test dev user api key
   ${perm0act}=    Set Variable   manage       #action
   ${perm0res}=    Set Variable   cloudlets    #resource
   ${permlist}=    Create List    ${perm0act}  ${perm0res}    

   ${devtoken}=     Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

   ${perm0act}=    Set Variable   view             #action
   ${perm0res}=    Set Variable   cloudletpools    #resource
   ${permlist}=    Create List    ${perm0act}  ${perm0res}    

   ${devtoken}=     Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   code=400
   Should Contain  ${resp}   Invalid permission specified:

# ECQ-4382
MC - Verify view apikey permissions
   [Documentation]
   ...  - this test will verify the view  permissions for an apikey
   ...  - verify view permissions only work for the given resourse 
   ...  - verify error messages are correct 

   ${desc}=        Set Variable    Test view api key permissions
   ${perm0act}=    Set Variable    view      #action
   ${perm0res}=    Set Variable    users     #resource
   ${permlist}=    Create List     ${perm0act}  ${perm0res} 
   ${role1}=       Set Variable    DeveloperViewer
   ${role2}=       Set Variable    OperatorViewer
   
	
   ${devtoken}=     Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}
   ${resp}=  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   ${key}
   Should Contain  ${resp}   ${keyid}

   ${apikeytoken}=  Login   apikey_id=${resp['Id']}   apikey=${resp['ApiKey']}
   Should Not Be Empty   ${apikeytoken}

   ${userlist}=  Show Role Assignment   token=${apikeytoken}
   Should Contain   ${userlist[0]['role']}      ${resp['Id']}-role

   ${applist}=  Run Keyword and Expect Error  *   Show Apps   region=US   app_name=${appname}   token=${apikeytoken}
   Should Contain   ${applist}   code=403
   Should Contain   ${applist}   Forbidden

   ${cloudlets}=   Run Keyword and Expect Error  *   Show Cloudlets   region=US   token=${apikeytoken}
   Should Contain   ${cloudlets}   code=403
   Should Contain   ${cloudlets}   Forbidden

   Delete User Api Key  apikey_id=${resp['Id']}   token=${devtoken}   use_defaults=${False}

   ${apikeytoken}=     Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}
   ${resp1}=  Create User Api Key  organization=${oporg}   description=${desc}   token=${apikeytoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp1}   ${key}
   Should Contain  ${resp1}   ${keyid}

   ${apikeytoken}=  Login   apikey_id=${resp1['Id']}   apikey=${resp1['ApiKey']}
   Should Not Be Empty   ${apikeytoken}

   ${userlist1}=  Show Role Assignment     token=${apikeytoken}
   Should Contain   ${userlist1[0]['role']}    ${resp1['Id']}-role

   ${cloudlets1}=   Run Keyword and Expect Error  *   Show Cloudlets   region=US   token=${apikeytoken}
   Should Contain   ${cloudlets1}   code=403
   Should Contain   ${cloudlets1}   Forbidden

   ${poollist}=     Run Keyword and Expect Error  *   Show Cloudlet Pool   region=US  
   Should Contain   ${poollist}   code=403
   Should Contain   ${poollist}   Forbidden

   Delete User Api Key  apikey_id=${resp1['Id']}   token=${devtoken}   use_defaults=${False}

# ECQ-4383
MC - Verify manage apikey permissions
   [Documentation]
   ...  - this test will verify manage permissions for an apikey
   ...  - manage permissions are create, delete, and show
   ...  - verify the manage permissions only work for the given resource 
   ...  - allow manage apps 
   ...  - verify error messages are correct 

   ${desc}=          Set Variable    Test manage api key permissions
   ${perm0act}=      Set Variable    manage    #action
   ${perm0res}=      Set Variable    apps      #resource
   ${permlist}=      Create List     ${perm0act}  ${perm0res}
   ${newapp}=        Set Variable    apikey_app 
   ${gitlab_image}   Set Variable    docker-qa.mobiledgex.net/automation_dev_org/images/server_ping_threaded:11.0

   ${devtoken}=     Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${resp}=  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp}   ${key}
   Should Contain  ${resp}   ${keyid}

   ${apikeytoken}=  Login   apikey_id=${resp['Id']}   apikey=${resp['ApiKey']}   use_defaults=${False}
   Should Not Be Empty   ${apikeytoken}

   ${applist}=  Create App  region=US  app_name=${newapp}  app_version=1.0  access_ports=tcp:2015  image_type=ImageTypeDocker   image_path=${gitlab_image}  deployment=docker  developer_org_name=${devorg}  default_flavor_name=automation_api_flavor  token=${apikeytoken}   auto_delete=${False}
   Should Not Be Empty   ${applist}   

   ${applist}=  Show Apps   region=US   app_name=${newapp}   token=${apikeytoken}
   Should Contain  ${applist[0]['data']['key']['name']}    ${newapp}

   ${delapp}=  Delete App  region=US  app_name=${newapp}  token=${apikeytoken} 
   Should Be Empty  ${delapp}  

   ${cloudlets}=   Run Keyword and Expect Error  *   Show Cloudlets   region=US   token=${apikeytoken}
   Should Contain   ${cloudlets}   code=403
   Should Contain   ${cloudlets}   Forbidden

   Delete User Api Key  apikey_id=${resp['Id']}   token=${devtoken}   use_defaults=${False}


   ${perm0act}=       Set Variable    manage        #action
   ${perm0res}=       Set Variable    cloudlets     #resource
   ${permlist}=       Create List     ${perm0act}  ${perm0res} 

   ${apikeytoken}=     Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
   ${resp1}=  Create User Api Key  organization=tmus   description=${desc}   token=${apikeytoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain  ${resp1}   ${key}
   Should Contain  ${resp1}   ${keyid}

   ${apikeytoken}=  Login   apikey_id=${resp1['Id']}   apikey=${resp1['ApiKey']}
   Should Not Be Empty   ${apikeytoken}

   ${cloudlet}=  Create Cloudlet   region=US  operator_org_name=${oporg}   cloudlet_name=${cldlet}   number_dynamic_ips=256     latitude=35     longitude=-96  ip_support=IpSupportDynamic    static_ips=30.30.30.1   auto_delete=${False}
   Should Contain   ${cloudlet['data']['created_at']}   ${current_date}
   Should Be True  'updated_at' in ${cloudlet['data']}

   ${cloudlets}=  Show Cloudlets   region=US   operator_org_name=${oporg}   cloudlet_name=${cldlet} 
   Should Contain    ${cloudlets[0]['data']['key']['name']}    ${cldlet}     
   Should Contain    ${cloudlets[0]['data']['key']['organization']}    ${oporg}    
	

   Delete Cloudlet     region=US    operator_org_name=${oporg}       cloudlet_name=${cldlet}
   ${cloudlets}=  Show Cloudlets   region=US   operator_org_name=${oporg}   cloudlet_name=${cldlet} 
   Should Be Empty    ${cloudlets}     

   ${poollist}=   Run Keyword and Expect Error  *  Show Cloudlet Pool   region=US  
   Should Contain   ${poollist}   code=403
   Should Contain   ${poollist}   Forbidden

   Delete User Api Key  apikey_id=${resp1['Id']}   token=${devtoken}   use_defaults=${False}

# ECQ-4384
MC - Verify valid viewer permissions are returned
   [Documentation]
   ...  - this test will verify viewer permissions are returned on a permissions failure
   ...  - valid viewer permissions should not contain any manage resources 

   ${desc}=          Set Variable    Test valid viewer api key permissions
   ${perm0act}=      Set Variable    view            #action
   ${perm0res}=      Set Variable    cloudletpools   #resource
   ${permlist}=      Create List     ${perm0act}  ${perm0res}

   ${devtoken}=     Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain      ${resp}   code=400
   Should Contain      ${resp}   Invalid permission specified:
   Should Not Contain  ${resp}   manage   
   
   ${desc}=          Set Variable    Test valid viewer api key permissions
   ${perm0act}=      Set Variable    view    #action
   ${perm0res}=      Set Variable    apps    #resource
   ${permlist}=      Create List     ${perm0act}  ${perm0res}

   ${optoken}=     Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${oporg}   description=${desc}   token=${optoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain      ${resp}   code=400
   Should Contain      ${resp}   Invalid permission specified:
   Should Not Contain  ${resp}   manage   

# ECQ-4385
MC - Verify valid contributor permissions are returned 
   [Documentation]
   ...  - this test will verify contributor permissions are returned on a permissions failure
   ...  - valid viewer permissions should not contain any manager resources 

   ${desc}=          Set Variable    Test valid contributor api key permissions
   ${perm0act}=      Set Variable    view            #action
   ${perm0res}=      Set Variable    cloudletpools   #resource
   ${permlist}=      Create List     ${perm0act}  ${perm0res}

   ${devtoken}=     Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain      ${resp}   code=400
   Should Contain      ${resp}   Invalid permission specified:
   Should Not Contain  ${resp}   users:manage   

   ${desc}=          Set Variable    Test valid contributor api key permissions
   ${perm0act}=      Set Variable    view    #action
   ${perm0res}=      Set Variable    apps    #resource
   ${permlist}=      Create List     ${perm0act}  ${perm0res}

   ${optoken}=     Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${oporg}   description=${desc}   token=${optoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain      ${resp}   code=400
   Should Contain      ${resp}   Invalid permission specified:
   Should Not Contain  ${resp}   users:manage  

# ECQ-4386
MC - Verify valid manager permissions are returned
   [Documentation]
   ...  - this test will verify manager permissions are returned on a permissions failure
   ...  - valid viewer permissions should not contain any manager resources 

   ${desc}=          Set Variable    Test valid manager api key permissions
   ${perm0act}=      Set Variable    view            #action
   ${perm0res}=      Set Variable    cloudletpools   #resource
   ${permlist}=      Create List     ${perm0act}  ${perm0res}

   ${devtoken}=     Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${devorg}   description=${desc}   token=${devtoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain   ${resp}   code=400
   Should Contain   ${resp}   Invalid permission specified:
   Should Contain   ${resp}   users:manage   

   ${desc}=          Set Variable    Test valid manager api key permissions
   ${perm0act}=      Set Variable    view    #action
   ${perm0res}=      Set Variable    apps    #resource
   ${permlist}=      Create List     ${perm0act}  ${perm0res}

   ${optoken}=     Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
   ${resp}=  Run Keyword and Expect Error  *  Create User Api Key  organization=${oporg}   description=${desc}   token=${optoken}  permission_list=${permlist}  use_defaults=${False}
   Should Contain   ${resp}   code=400
   Should Contain   ${resp}   Invalid permission specified:
   Should Contain   ${resp}   users:manage  


*** Keywords ***
Setup
   ${admintoken}=     Get Super Token 
   ${current_date}=   Fetch Current Date
   
   Set Suite Variable   ${admintoken}
   Set Suite Variable   ${current_date}
