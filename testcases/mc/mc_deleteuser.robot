*** Settings ***
Documentation   MasterController User Delete

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   mex1234567
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw

*** Test Cases ***
MC - Delete a user without a user name
	[Documentation]
	...  delete a user without a user name
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Delete User    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"User Name not specified"}

MC - Delete a user without a token
	[Documentation]
	...  delete a user without a token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *     Delete User     username=myuser     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Delete a user with an empty token
	[Documentation]
	...  delete a user with an empty token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *     Delete User    username=myuser      token=${EMPTY}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"no token found"}

MC - Delete a user with a bad token
	[Documentation]
	...  delete a user with a bad token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *     Delete User    username=myuser      token=thisisabadtoken      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Delete a user with an expired token
	[Documentation]
	...  delete a user with an expired token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *     Delete User    username=myuser       token=${expToken}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}



	
*** Keywords ***
Setup
	Create User  username=myuser   password=${password}   email=xy@xy.com
	${userToken}=  Login  username=myuser  password=${password}
	Set Suite Variable  ${userToken}
	
