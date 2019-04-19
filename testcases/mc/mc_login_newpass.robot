*** Settings ***
Documentation   MasterController New User Login

Library		MexMasterController  root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   mex1234567
${newpass}=   new1234567
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw


*** Test Cases ***
MC - Admin user shall be able to change the password
	[Documentation]
	...  admin user change their password 
	...  change the password back to the original password after a successful password change

	New Password    password=${newpass}     token=${adminToken}     use_defaults=${False}
	New Password    password=mexadmin123    token=${adminToken}     use_defaults=${False}

	
MC - Admin user shall be able to login with the new password 
	[Documentation]
	...  admin user change their password and login
	...  delete users after test completes

	New Password    password=${newpass}     token=${adminToken}   use_defaults=${False}
	Login   username=mexadmin   password=${newpass}
	New Password    password=mexadmin123    token=${adminToken}     use_defaults=${False}

MC - Admin user shall not be able to login with the old password 
	[Documentation]
	...  admin user change their password and login
	...  verify the correct error is returned
	...  delete users after test completes

	New Password    password=${newpass}     token=${adminToken}   use_defaults=${False}

	${error_msg}=  Run Keyword and Expect Error  *  Login   username=mexadmin   password=mexadmin123
      	
	${status_code}=  Response Status Code
	${body}=         Response Body

	New Password    password=mexadmin123    token=${adminToken}     use_defaults=${False}

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - User shall be able to change their password
	[Documentation]
	...  create a new user and change their password
	...  delete user after successfull password change

	New Password  password=${newpass}   token=${userToken} 

MC - User shall be able to change to the same password as another user
	[Documentation]
	...  create a new user and change their password to the password of another user
	...  delete users after successfull password change

        New Password  password=${newpass}   token=${userToken} 
	New Password  password=${newpass}   token=${newUserToken}

MC - User shall not be able to login with the old password 
	[Documentation]
	...  create a new user change their password and login
	...  verify the correct error is returned
	...  delete users after test completes

	New Password    password=${newpass}     token=${userToken}   use_defaults=${False}

	${error_msg}=  Run Keyword and Expect Error  *  Login   username=myuser   password=${password}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid username or password"}

MC - User shall not be able to change their password without a token
	[Documentation]
	...  create a new user change their password without a token
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  New Password    password=${newpass}     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - User shall not be able to change their password with an empty token
	[Documentation]
	...  create a new user change their password with an empty token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  New Password    password=${newpass}     token=${EMPTY}    use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - User shall not be able to change their password with a bad token
	[Documentation]
	...  create a new user change their password with a bad token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  New Password    password=${newpass}     token=thisisabadtoken     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - User shall not be able to change their password with an expired token
	[Documentation]
	...  create a new user change their password with an expired token 
	...  verify the correct error is returned
	...  delete users after test completes

	${error_msg}=  Run Keyword and Expect Error  *  New Password    password=${newpass}     token=${expToken}     use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}



*** Keywords ***
Setup
	${adminToken}=   Login
	Create User  username=myuser   password=${password}   email=xy@xy.com
	${userToken}=  Login  username=myuser  password=${password}
	Create User  username=youruser   password=somepassword   email=xyz@xyz.com
	${newUserToken}=  Login  username=youruser   password=somepassword
        Set Suite Variable  ${adminToken}
	Set Suite Variable  ${userToken}
	Set Suite Variable  ${newUserToken}
