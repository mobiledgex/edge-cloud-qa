*** Settings ***
Documentation   MasterController New User Login

Library		MexMasterController  root_cert=../../certs/mex-ca.crt

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   mex1234567
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw


*** Test Cases ***
MC - Super user shall be able to show roles
	[Documentation]
	...  superuser can show roles 
	...  verify the roles returned

	${roles}=  Show Role   token=${superToken}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers  ${status_code}  200	
	Should Be Equal             ${body}         ["AdminContributor","AdminManager","AdminViewer","DeveloperContributor","DeveloperManager","DeveloperViewer","OperatorContributor","OperatorManager","OperatorViewer"]

MC - User shall be able to show roles
	[Documentation]
	...  user can show roles 
	...  verify the roles returned

	${roles}=  Show Role   token=${userToken}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers  ${status_code}  200	
	Should Be Equal             ${body}         ["AdminContributor","AdminManager","AdminViewer","DeveloperContributor","DeveloperManager","DeveloperViewer","OperatorContributor","OperatorManager","OperatorViewer"]

MC - User shall not be able to show roles without a token
	[Documentation]
	...  create a new user and show roles without a token
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  Show Role   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - User shall not be able to show roles with an empty token
	[Documentation]
	...  create a new user and show roles with an empty token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  Show Role    token=${EMPTY}    use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - User shall not be able to show roles with a bad token
	[Documentation]
	...  create a new user and show roles with a bad token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  Show Role   token=thisisabadtoken     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - User shall not be able to show roles with an expired token
	[Documentation]
	...  create a new user and show roles with an expired token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  Show Role   token=${expToken}     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	


	
*** Keywords ***
Setup
	${superToken}=   Login
	Create User  username=myuser   password=${password}   email=xy@xy.com
	${userToken}=  Login  username=myuser  password=${password}
        Set Suite Variable  ${superToken}
	Set Suite Variable  ${userToken}
