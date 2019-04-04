*** Settings ***
Documentation   MasterController Login

Library		MexMasterController  root_cert=../../certs/mex-ca.crt

#Test Setup	Setup
#Test Teardown	Cleanup Provisioning

*** Variables ***

*** Test Cases ***
MC - User shall be able to successfully login
    [Documentation]
    ...  login to the mc
    ...  verify token is correct

   Login
   ${token}=  Decoded Token

   ${expire_time}=  Evaluate  (${token['exp']} - ${token['iat']}) / 60 / 60
   Should Be Equal As Numbers  ${expire_time}  24   #expires in 24hrs
   Should Be Equal  ${token['username']}  mexadmin	

MC - User with wrong password shall not be able to login
    [Documentation]
    ...  login to the mc with invalid password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  password=xx

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - User with wrong username shall not be able to login
    [Documentation]
    ...  login to the mc with invalid username
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=xx

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - User with no username shall not be able to login
    [Documentation]
    ...  login to the mc with no username
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${None}  password=mex123  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

MC - User with no password shall not be able to login
    [Documentation]
    ...  login to the mc with no password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=mexadmin  password=${None}  use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - User with empty username shall not be able to login
    [Documentation]
    ...  login to the mc with empty username
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${EMPTY}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

MC - User with empty password shall not be able to login
    [Documentation]
    ...  login to the mc with empty password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  password=${EMPTY}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - User with empty username/password shall not be able to login
    [Documentation]
    ...  login to the mc with empty username/password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${EMPTY}  password=${EMPTY}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

MC - User with no username/password shall not be able to login
    [Documentation]
    ...  login to the mc with empty username/password
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  username=${None}  password=${None}   use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Username not specified"}

MC - User with invalid json shall not be able to login
    [Documentation]
    ...  login to the mc with invalid username/password json
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  json_data={"username":"mexadmin","password":"mexadmin123"

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid POST data"}

MC - User with wrong parm name shall not be able to login
    [Documentation]
    ...  login to the mc with wrong username/password json
    ...  verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  *  Login  json_data={"username":"mexadmin","passwor":"mexadmin123"}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Invalid username or password"}
