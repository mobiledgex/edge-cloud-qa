*** Settings ***
Documentation   MasterController New User Login

Library		MexMasterController  root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
#Test Teardown	Cleanup Provisioning

*** Variables ***

*** Test Cases ***
MC - New User shall be able to successfully login
    [Documentation]
    ...  login to the mc as a new user
    ...  verify token is correct

   Login  username=${username}  password=${password}
	
   ${token}=     Decoded Token
	
   ${expire_time}=             Evaluate  (${token['exp']} - ${token['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   Should Be Equal             ${token['username']}  ${username}	

MC - New User with wrong password shall not be able to login
    [Documentation]
    ...  login to the mc as new user with invalid password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${username}  password=xx

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - New User with wrong username shall not be able to login
    [Documentation]
    ...  login to the mc as new user with invalid username
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=xx  password=${password}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - New User with no username shall not be able to login
    [Documentation]
    ...  login to the mc as new user with no username
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${None}  password=${password}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

MC - New User with no password shall not be able to login
    [Documentation]
    ...  login to the mc with as new user and no password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${username}  password=${None}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - New User with empty username shall not be able to login
    [Documentation]
    ...  login to the mc with empty username and new user password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${EMPTY}  password=${password}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

MC - New User with empty password shall not be able to login
    [Documentation]
    ...  login to the mc with as new user and empty password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${username}  password=${EMPTY}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

*** Keywords ***
Setup
    ${username}  ${password}  ${email}=  Create User   	

    Set Suite Variable  ${username}
    Set Suite Variable  ${password} 

