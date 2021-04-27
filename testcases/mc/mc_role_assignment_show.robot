*** Settings ***
Documentation   MasterController New User Login

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   ${dev_manager_password_automation}
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw


*** Test Cases ***
MC - Admin user shall be able to show role assignments
	[Documentation]
	...  admin user can show role assignments 
	...  verify the roles returned

	${roles}=  Show Role Assignment   token=${adminToken}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers  ${status_code}  200	
	Should Contain              ${body}         "org"
	Should Contain              ${body}         "username"
	Should Contain              ${body}         "role"

MC - User shall be able to show role assignments
	[Documentation]
	...  user can show roles 
	...  verify the roles returned

	${roles}=  Show Role Assignment   token=${userToken}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers  ${status_code}  200	
	Should Contain              ${body}         []

MC - User shall not be able to show role assignments without a token
	[Documentation]
	...  create a new user and show roles without a token
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  Show Role Assignment   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - User shall not be able to show role assignments with an empty token
	[Documentation]
	...  create a new user and show roles with an empty token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  Show Role Assignment    token=${EMPTY}    use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"no token found"}

MC - User shall not be able to show role assignments with a bad token
	[Documentation]
	...  create a new user and show roles with a bad token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  Show Role Assignment   token=thisisabadtoken     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - User shall not be able to show role assignments with an expired token
	[Documentation]
	...  create a new user and show roles with an expired token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  Show Role Assignment   token=${expToken}     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	


	
*** Keywords ***
Setup
	${adminToken}=   Login
	Create User  username=myuser   password=${password}   email_address=xy@xy.com
	${userToken}=  Login  username=myuser  password=${password}
        Set Suite Variable  ${adminToken}
	Set Suite Variable  ${userToken}
