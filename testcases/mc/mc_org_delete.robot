*** Settings ***
Documentation   MasterController Org Delete

Library		MexMasterController  root_cert=../../certs/mex-ca.crt

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   mex1234567
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw

*** Test Cases ***
MC - Delete an org without an org name	
	[Documentation]
	...  delete an org without an org name
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Delete Org   token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Organization name not specified"}

MC - Delete an org without a token	
	[Documentation]
	...  delete an org without a token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *    Delete Org     orgname=myOrg      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Delete an org with an empty token	
	[Documentation]
	...  delete an org with an empty token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *    Delete Org     orgname=myOrg     token=${EMPTY}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Delete an org with a bad token	
	[Documentation]
	...  delete an org with a bad token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *    Delete Org    orgname=myOrg    token=thisisabadtoken      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Delete an org with an expired token	
	[Documentation]
	...  delete an org with an expired token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Delete Org    orgname=myOrg    token=${expToken}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Delete an org with a user assigned admin token	
	[Documentation]
	...  delete an org with a user assigned with the admin token
	...  verify the correct error message is returned

        ${user_role}=  Get Role
	Create User      username=contributor     password=${password}     email=xyz@xyz.com
        Role Adduser     orgname=myOrg       username=contributor     role=${user_role}      token=${userToken}      use_defaults=${False}
	Delete Org    orgname=myOrg    token=${adminToken}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal              ${body}         {"message":"Organization deleted"}

MC - Delete an org with a user assigned user token	
	[Documentation]
	...  delete an org with a user assigned with the user token
	...  verify the correct error message is returned

        ${user_role}=  Get Role
	Create User      username=contributor     password=${password}     email=xyz@xyz.com
        Role Adduser     orgname=myOrg       username=contributor     role=${user_role}      token=${userToken}      use_defaults=${False}
	Delete Org    orgname=myOrg    token=${userToken}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	#Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"Organization deleted"}

	
*** Keywords ***
Setup
	${adminToken}=   Login
	Create User  username=myuser   password=${password}   email=xy@xy.com
	${userToken}=  Login  username=myuser  password=${password}
	Create Org    orgname=myOrg    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}    use_defaults=${False}
	Set Suite Variable  ${adminToken}
	Set Suite Variable  ${userToken}
	
