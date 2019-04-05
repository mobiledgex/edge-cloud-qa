*** Settings ***
Documentation   MasterController user/current superuser

Library		MexMasterController  root_cert=../../certs/mex-ca.crt
Library         DateTime
	
#Test Setup	Setup
#Test Teardown	Cleanup Provisioning

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
	
   FOR  ${name}  IN  @{usernames}
   \  ${email}=  Catenate  SEPARATOR=  ${name}  @auto.com
   \  ${username}  ${password}  ${email}=  Create User  username=${name}  password=${password}  email=${email}
   \  Login
	
   \  ${info}=  Get Current User

   \  Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
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
   \  Convert Date  ${info['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   \  Login  username=${name}  password=${password}
   \  Delete User


MC - User shall not be able to create a new user with no username
    [Documentation]
    ...  create a new user without username
    ...  verify proper is received
	
   Run Keyword and Expect Error  *  Create User  password=${password}  email=x@x.com  use_defaults=${False}

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

