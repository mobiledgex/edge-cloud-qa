*** Settings ***
Documentation   MasterController Superuser Login

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

#Test Setup	Setup
#Test Teardown	Cleanup Provisioning

*** Variables ***
${mex_password}=  ${mexadmin_password}

*** Test Cases ***
# ECQ-3280
MC - Superuser shall be able to successfully login
   [Documentation]
   ...  - login to the mc as superuser
   ...  - verify token is correct

   Login  username=mexadmin  password=${mex_password}
   ${token}=  Decoded Token

   ${expire_time}=  Evaluate  (${token['exp']} - ${token['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   Should Be Equal  ${token['username']}  mexadmin	

# ECQ-3281
MC - Superuser with wrong password shall not be able to login
   [Documentation]
   ...  - login to the mc with superuser username and invalid password
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  password=xx

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

# ECQ-3282
MC - Superuser with wrong username shall not be able to login
   [Documentation]
   ...  - login to the mc with invalid username and superuser password
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=xx

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

# ECQ-3283
MC - Superuser with no username shall not be able to login
   [Documentation]
   ...  - login to the mc with no username and superuser password
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${None}  password=${mex_password}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

# ECQ-3284
MC - Superuser with no password shall not be able to login
   [Documentation]
   ...  - login to the mc with superuser username and no password
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=mexadmin  password=${None}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Please specify password"}

# ECQ-3285
MC - Superuser with empty username shall not be able to login
   [Documentation]
   ...  - login to the mc with empty username and superuser password
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${EMPTY}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

# ECQ-3286
MC - Superuser with empty password shall not be able to login
   [Documentation]
   ...  - login to the mc with superuser username and empty password
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  password=${EMPTY}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Please specify password"}

# ECQ-3287
MC - User with empty username/password shall not be able to login
   [Documentation]
   ...  - login to the mc with empty username/password
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${EMPTY}  password=${EMPTY}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

# ECQ-3288
MC - User with no username/password shall not be able to login
   [Documentation]
   ...  - login to the mc with empty username/password
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${None}  password=${None}   use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

# ECQ-3289
MC - User with invalid json shall not be able to login
   [Documentation]
   ...  - login to the mc with invalid username/password json
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  json_data={"username":"mexadmin","password":"${mex_password}"

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid JSON data: Syntax error at offset 62, unexpected end of JSON input"}

# ECQ-3290
MC - User with wrong parm name shall not be able to login
   [Documentation]
   ...  - login to the mc with wrong username/password json
   ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  json_data={"username":"mexadmin","passwor":"${mex_password}"}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Please specify password"}
