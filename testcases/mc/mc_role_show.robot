*** Settings ***
Documentation   MasterController show roles

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   mex1234567
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw


*** Test Cases ***
# ECQ-3366
MC - Admin user shall be able to show roles
	[Documentation]
	...  - admin user can show roles 
	...  - verify the roles returned

	${roles}=   Show Role   token=${adminToken}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers  ${status_code}  200	
	Should Contain             ${body}         "AdminContributor","AdminManager","AdminViewer","BillingManager","DeveloperContributor","DeveloperManager","DeveloperViewer","OperatorContributor","OperatorManager","OperatorViewer"

# ECQ-3367
MC - User shall be able to show roles
	[Documentation]
	...  - user can show roles 
	...  - verify the roles returned

        [Setup]  Setup User

	${roles}=  Show Role   token=${userToken}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers  ${status_code}  200	
	Should Be Equal             ${body}         ["AdminContributor","AdminManager","AdminViewer","DeveloperContributor","DeveloperManager","DeveloperViewer","OperatorContributor","OperatorManager","OperatorViewer"]

# ECQ-3368
MC - User shall not be able to show roles without a token
	[Documentation]
	...  - create a new user and show roles without a token
	...  - verify the correct error is returned
	...  - delete users after test completes

        [Setup]  Setup User

	${error_msg}=  Run Keyword and Expect Error  *  Show Role   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"no bearer token found"}

# ECQ-3369
MC - User shall not be able to show roles with an empty token
	[Documentation]
	...  - create a new user and show roles with an empty token 
	...  - verify the correct error is returned
	...  - delete users after test completes

        [Setup]  Setup User

	${error_msg}=  Run Keyword and Expect Error  *  Show Role    token=${EMPTY}    use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"no bearer token found"}

# ECQ-3370
MC - User shall not be able to show roles with a bad token
	[Documentation]
	...  - create a new user and show roles with a bad token 
	...  - verify the correct error is returned
	...  - delete users after test completes

        [Setup]  Setup User

	${error_msg}=  Run Keyword and Expect Error  *  Show Role   token=thisisabadtoken     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

# ECQ-3371
MC - User shall not be able to show roles with an expired token
	[Documentation]
	...  - create a new user and show roles with an expired token 
	...  - verify the correct error is returned
	...  - delete users after test completes

        [Setup]  Setup User

	${error_msg}=  Run Keyword and Expect Error  *  Show Role   token=${expToken}     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
        Should Be Equal             ${body}         {"message":"invalid or expired jwt"}
	
*** Keywords ***
Setup 
        ${adminToken}=   Login
        Set Suite Variable  ${adminToken}

Setup User
	#Create User  username=myuser   password=${password}   email_address=xy@xy.com
	#${userToken}=  Login  username=myuser  password=${password}
        ${userToken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
	Set Suite Variable  ${userToken}
