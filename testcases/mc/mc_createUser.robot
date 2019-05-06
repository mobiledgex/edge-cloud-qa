*** Settings ***
Documentation   MasterController user/current superuser

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
	
Test Setup	 Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${password}=   mex1234567
	
*** Test Cases ***

MC - User shall be able to create a new user
	[Documentation]
	...  create a new user with various name
	...  get user/current info
	...  verify info is correct
	...  delete the user
	
	@{usernames}=  Create List  1  a  -username  _username  123lkjsdfh12jsd12  MYNAME  -----   &and&  .auto  .,&  ,!auto  dlfjoiwefmsifqwleko23kjsdlijalskdfjqoiwjlkadsjfoiajlrejqwoiejalksdjfoiqwjflkajsdoifjqwiojfaoifjaiosjfiwjefoiajsdflkajlfkjaskldfjaoijfalksdjfoiajsdflkjasoifjasdlkjfalisjdfklajsdflkajsflkajsflkj  my username
	
	: FOR  ${name}  IN  @{usernames}
	\  ${email}=  Catenate  SEPARATOR=  ${name}  @auto.com
	\  ${username}  ${password}  ${email}=  Create User  username=${name}  password=${password}  email=${email}
	\  Login
	
	\  ${info}=   Get Current User

	\  Should Be Equal             ${info['Email']}          ${email}
	\  Should Be Equal             ${info['EmailVerified']}  ${False}
	\  Should Be Equal             ${info['FamilyName']}     ${EMPTY}
	\  Should Be Equal             ${info['GivenName']}      ${EMPTY}
	\  Should Be Equal As Numbers  ${info['Iter']}           0
	\  Should Be Equal             ${info['Name']}           ${username}
	\  Should Be Equal             ${info['Nickname']}       ${EMPTY}
	\  Should Be Equal             ${info['Passhash']}       ${EMPTY}
	\  Should Be Equal             ${info['Picture']}        ${EMPTY}
	\  Should Be Equal             ${info['Salt']}           ${EMPTY}
	\  Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
	\  Convert Date  ${info['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
	
	\  Login  username=${name}  password=${password}


MC - User shall not be able to create a new user with no username
	[Documentation]
	...  create a new user without username
	...  verify proper error is received
	
	Run Keyword and Expect Error  *  Create User   password=${password}   email=x@x.com   use_defaults=${False}
	
	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Name not specified"}

MC - User shall not be able to create a new user with empty username
	[Documentation]
	...  create a new user with empty username
	...  verify proper error is received
	
	Run Keyword and Expect Error  *  Create User  username=${EMPTY}  password=${password}  email=x@x.com  use_defaults=${False}
	
	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Name not specified"}

MC - User shall not be able to create a new user with no password
	[Documentation]
	...  create a new user without password
	...  verify proper is received
	
	Run Keyword and Expect Error  *  Create User  username=xxxxx  email=x@x.com  use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid password, password must be at least 8 characters"}

MC - User shall not be able to create a new user with empty password
	[Documentation]
	...  create a new user with empty password
	...  verify proper error is received
	
	Run Keyword and Expect Error  *  Create User  username=xxxxx  password=${EMPTY}  email=x@x.com  use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid password, password must be at least 8 characters"}

MC - User shall not be able to create a new user without an email
	[Documentation]
	...  create a new user without an email
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=myusername   password=${password}   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid email address"}

MC - User shall not be able to create a new user with an empty email
	[Documentation]
	...  create a new user with an empty email
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=myusername    password=${password}   email=${EMPTY}   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid email address"}


MC - User shall not be able to create a new user with :: in the username
	[Documentation]
	...  create a new user with :: in the username
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User  username=my::name  password=${password}  email=x@x.com  use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Name cannot contain ::"}

MC - User shall not be able to create a new user with an invalid email
	[Documentation]
	...  create a new user with an empty email
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=myusername    password=${password}   email=x.com   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid email address"}

MC - User shall not be able to create a new user with an invalid username characters  
	[Documentation]
	...  create a new user with an invalid username
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=~^`    password=${password}   email=x@x.com   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid characters in user name"}
	

MC - User shall not be able to create a new user with spaces before the username   
	[Documentation]
	...  create a new user with spaces before the username
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=${SPACE}name${SPACE}    password=${password}   email=x@x.com   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid characters in user name"}

MC - User shall not be able to create a new user with an invalid password
	[Documentation]
	...  create a new user with an invalid password
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=xxxxxx    password=mypass   email=x@x.com   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Invalid password, password must be at least 8 characters"}

MC - User shall not be able to create the same new user twice same info
	[Documentation]
	...  create the same user twice same info
	...  verify the proper error is received
	...  delete the user

        Create User   username=myusername   password=${password}   email=xy@xy.com    use_defaults=${False}
	Run Keyword and Expect Error  *  Create User   username=myusername    password=${password}   email=xy@xy.com   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Username already exists"}
	
MC - User shall not be able to create the same new user twice different password
	[Documentation]
	...  create the same user twice different password
	...  verify the proper error is received
	...  delete the user

        Create User   username=myusername   password=${password}   email=xy@xy.com    use_defaults=${False}
	Run Keyword and Expect Error  *  Create User   username=myusername    password=mypass12345   email=xy@xy.com   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Username already exists"}

MC - User shall not be able to create the same new user twice different email
	[Documentation]
	...  create the same user twice different email
	...  verify the proper error is received
	...  delete the user

        Create User   username=myusername   password=${password}   email=xy@xy.com    use_defaults=${False}
	Run Keyword and Expect Error  *  Create User   username=myusername    password=${password}   email=xyz@xyz.com   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Username already exists"}

MC - User shall not be able to create the superuser twice same info
	[Documentation]
	...  create the superuser again with the same info
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=mexadmin    password=mexadmin123   email=mexadmin@mobiledgex.net   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Username already exists"}

MC - User shall not be able to create the superuser twice different password
	[Documentation]
	...  create the superuser again with a different password
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=mexadmin    password=${password}   email=mexadmin@mobiledgex.net   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Username already exists"}

MC - User shall not be able to create the superuser twice different email
	[Documentation]
	...  create the superuser again with a different password
	...  verify the proper error is received

	Run Keyword and Expect Error  *  Create User   username=mexadmin    password=mexadmin123   email=xy@xy.com   use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"Username already exists"}

        
*** Keywords ***
Setup
	Login

