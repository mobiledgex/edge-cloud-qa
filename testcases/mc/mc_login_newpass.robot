*** Settings ***
Documentation   MasterController New User Login

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=    H31m8@W8maSfg
${newpass}=     aI6A8T*BqfkX1
${adminpass}=   H31m8@W8maSfgnC
${newadminpass}=  kI6h91F!UBH*Xyh	
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw
${mex_password}=  ${mexadmin_password}

*** Test Cases ***
# ECQ-2745	
MC - Admin user shall be able to change the password
	[Documentation]
	...  admin user change their password 
	...  change the password back to the original password after a successful password change

	New Password    password=${newadminpass}     token=${adminuserToken}     use_defaults=${False}
	${adminuserToken}=  Login   username=${adminuser}   password=${newadminpass}
	New Password    password=${adminpass}     token=${adminuserToken}     use_defaults=${False}


# ECQ-2746
MC - Admin user shall be able to login with the new password 
	[Documentation]
	...  admin user change their password and login
	...  change the password back to the original password after a successful password change

	New Password    password=${newadminpass}     token=${adminuserToken}     use_defaults=${False}
	${adminuserToken}=  Login   username=${adminuser}   password=${newadminpass}
	New Password    password=${adminpass}     token=${adminuserToken}     use_defaults=${False}
	
	
# ECQ-2747
MC - Admin user shall not be able to login with the old password 
	[Documentation]
	...  admin user change their password and login
	...  verify the correct error is returned
	...  change the password back to the original password after a successful password change

	${adminuserToken}=  Login   username=${adminuser}   password=${adminpass}
	New Password    password=${newadminpass}     token=${adminuserToken}     use_defaults=${False}
	${error}=  Run Keyword and Expect Error  *  Login   username=${adminuser}   password=${adminpass}
      	
	Should Contain    ${error}   Code = 400	
	Should Contain    ${error}   Body={"message":"Invalid username or password"}

	${adminuserToken}=  Login   username=${adminuser}   password=${newadminpass}
	New Password    password=${adminpass}     token=${adminuserToken}     use_defaults=${False}
	

# ECQ-2748
MC - User shall be able to change their password
	[Documentation]
	...  create a new user and change their password
	...  verify the change is success by logging in
	...  change the password back to the original password after a successful password change

	New Password  password=${newpass}   token=${epochuserToken1} 
	${epochuserToken1}=  Login   username=${epochuser1}  password=${newpass}
	New Password  password=${password}   token=${epochuserToken1}
	${epochuserToken1}=  Login   username=${epochuser1}  password=${password}
	
	
# ECQ-2749
MC - User shall be able to change to the same password as another user
	[Documentation]
	...  create a new user and change their password to the password of another user
	...  verify the change is success by logging in
	...  change the password back to the original password after a successful password change

        New Password  password=${newpass}   token=${epochuserToken1} 
	New Password  password=${newpass}   token=${epochuserToken2}
	${epochuserToken1}=  Login   username=${epochuser1}  password=${newpass}
	${epochuserToken2}=  Login   username=${epochuser2}  password=${newpass}
	New Password  password=${password}   token=${epochuserToken1}
	${epochuserToken1}=  Login   username=${epochuser1}  password=${password}


# ECQ-2750
MC - User shall not be able to login with the old password 
	[Documentation]
	...  create a new user change their password and login
	...  verify the correct error is returned
	...  change the password back to the original password after a successful password change

	New Password    password=${newpass}     token=${epochuserToken1}   use_defaults=${False}

	${error}=  Run Keyword and Expect Error  *  Login   username=${epochuser1}   password=${password}

	Should Contain    ${error}   Code = 400	
	Should Contain    ${error}   Body={"message":"Invalid username or password"}

	${epochuserToken1}=  Login   username=${epochuser1}  password=${newpass}
	New Password  password=${password}   token=${epochuserToken1}
	${epochuserToken1}=  Login   username=${epochuser1}  password=${password}


# ECQ-2751	
MC - User shall not be able to change their password without a token
	[Documentation]
	...  create a new user change their password without a token
	...  verify the correct error is returned

	${error}=  Run Keyword and Expect Error  *  New Password    password=${newpass}     use_defaults=${False}

	Should Contain    ${error}   Code = 400	
	Should Contain    ${error}   Body={"message":"No bearer token found"}
	

# ECQ-2752
MC - User shall not be able to change their password with an empty token
	[Documentation]
	...  create a new user change their password with an empty token 
	...  verify the correct error is returned

	${error}=  Run Keyword and Expect Error  *  New Password    password=${newpass}     token=${EMPTY}    use_defaults=${False}

	Should Contain    ${error}   Code = 400	
	Should Contain    ${error}   Body={"message":"No bearer token found"}
	

# ECQ-2753
MC - User shall not be able to change their password with a bad token
	[Documentation]
	...  create a new user change their password with a bad token 
	...  verify the correct error is returned

	${error}=  Run Keyword and Expect Error  *  New Password    password=${newpass}     token=thisisabadtoken     use_defaults=${False}

	Should Contain    ${error}   Code = 401	
	Should Contain    ${error}   Body={"message":"Invalid or expired jwt"}
	
	
# ECQ-2754
MC - User shall not be able to change their password with an expired token
	[Documentation]
	...  create a new user change their password with an expired token 
	...  verify the correct error is returned

	${error}=  Run Keyword and Expect Error  *  New Password    password=${newpass}     token=${expToken}     use_defaults=${False}

	Should Contain    ${error}   Code = 401	
	Should Contain    ${error}   Body={"message":"Invalid or expired jwt"}
	

# ECQ-2755
MC - Admin user shall not be able to change to a weak password 
	[Documentation]
	...  admin user can not change their password to a weak password  
	...  verify the correct error is returned

	${error}=  Run Keyword and Expect Error  *  New Password    password=aweakone     token=${adminuserToken}     use_defaults=${False}

	Should Contain    ${error}   Code = 400	
	Should Contain    ${error}   Body={"message":"Password too weak, requires crack time 2.0 years but is 12.0 seconds. Please increase length or complexity"}


# ECQ-2756	
MC - User shall not be able to change to a weak password 
	[Documentation]
	...  admin user can not change their password to a weak password  
	...  verify the correct error is returned

	${error}=  Run Keyword and Expect Error  *  New Password    password=aweakone     token=${epochuserToken1}     use_defaults=${False}

	Should Contain    ${error}   Code = 400	
	Should Contain    ${error}   Body={"message":"Password too weak, requires crack time 31.0 days but is 12.0 seconds. Please increase length or complexity"}

*** Keywords ***
Setup
	Skip Verify Email   skip_verify_email=True
	${username}=   Set Variable   myuser
	${epoch}=  Get Time  epoch
	${emailepoch1}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
	${epochuser1}=  Catenate  SEPARATOR=  ${username}  ${epoch}
	${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  1  @gmail.com
	${epochuser2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  1
	${adminuseremail}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
	${adminuser}=   Catenate  SEPARATOR=  ${username}  ${epoch}  2	
	Create User  username=${epochuser1}   password=${password}   email_address=${emailepoch1}    email_check=False
	Unlock User
	Create User  username=${epochuser2}   password=L63l0K%0LSo3@   email_address=${emailepoch2}    email_check=False
	Unlock User
	Create User  username=${adminuser}   password=${adminpass}   email_address=${adminuseremail}    email_check=False
	Unlock User
	${adminToken}=   Login  username=qaadmin  password=mexadminfastedgecloudinfra
	${adduser}=   Adduser Role   username=${adminuser}   role=AdminManager    token=${adminToken}     use_defaults=${False}
	${adminuserToken}=   Login  username=${adminuser}   password=${adminpass}
	${epochuserToken1}=  Login  username=${epochuser1}  password=${password}
	${epochuserToken2}=  Login  username=${epochuser2}   password=L63l0K%0LSo3@
	Set Suite Variable  ${adminuser}
        Set Suite Variable  ${adminuserToken}
	Set Suite Variable  ${epochuser1}
	Set Suite Variable  ${epochuserToken1}
	Set Suite Variable  ${epochuser2}
	Set Suite Variable  ${epochuserToken2}
