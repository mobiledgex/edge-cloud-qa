*** Settings ***
Documentation   MasterController user/current superuser

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
Library         Collections
	
#Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${username}          mextester99
${password}          ${mextester06_gmail_password}
${email}             mextester99@gmail.com

*** Test Cases ***
# ECQ-2929
MC - User shall be able to get the current status of superuser
    [Documentation]
    ...  - login to mc as superuser
    ...  - get user/current info
    ...  - verify info is correct

   Login  username=${admin_manager_username}  password=${admin_manager_password}
   ${info}=  Get Current User
   log to console  ${info}

   Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info['Email']}          ${admin_manager_email} 
   Should Be Equal             ${info['EmailVerified']}  ${True}
   Should Be Empty             ${info['FamilyName']}     #mexadmin
   Should Be Empty             ${info['GivenName']}      #mexadmin
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info['Iter']}           0
   Should Be Equal             ${info['Name']}           qaadmin
   Should Be Empty             ${info['Nickname']}       #mexadmin
   Should Be Equal             ${info['Passhash']}       ${EMPTY}
   Should Be Equal             ${info['Picture']}        ${EMPTY}
   Should Be Equal             ${info['Salt']}           ${EMPTY}
   Convert Date  ${info['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

# ECQ-2930
MC - User shall be able to get the current status of new user
    [Documentation]
    ...  - create a new user
    ...  - login to mc as new
    ...  - get user/current info
    ...  - verify info is correct

   ${i}=  Get Time  epoch
   ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
   ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

   Skip Verify Email
   Create User  ${username1}  ${password}  ${email1}  	
   Unlock User  #username=${username}
   Login
	
   ${info}=  Get Current User

   Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info['Email']}          ${email1}
   Should Be Equal             ${info['EmailVerified']}  ${False}
   Should Be Equal             ${info['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info['Iter']}           0
   Should Be Equal             ${info['Name']}           ${username1}
   Should Be Equal             ${info['Nickname']}       ${EMPTY}
   Should Be Equal             ${info['Passhash']}       ${EMPTY}
   Should Be Equal             ${info['Picture']}        ${EMPTY}
   Should Be Equal             ${info['Salt']}           ${EMPTY}
   Convert Date  ${info['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

# ECQ-2931
MC - User with no token shall not be able to get current status
    [Documentation]
    ...  - request user/current without token
    ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Get Current User  use_defaults=${False}

# ECQ-2932
MC - User with an empty token shall not be able to get current status
    [Documentation]
    ...  - request user/current with an empty token
    ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  ('code=400', 'error={"message":"No bearer token found"}')  Get Current User   token=${EMPTY}    use_defaults=${False}

# ECQ-2933
MC - User with bad token1 shall not be able to get current status
    [Documentation]
    ...  - request user/current with token=<some other token>
    ...  - verify correct error msg is received

   #this token came from verifyLocation testscases
   ${error_msg}=  Run Keyword and Expect Error  ('code=401', 'error={"message":"Invalid or expired jwt"}')  Get Current User  token=eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQzMjUxMzIsImlhdCI6MTU1NDIzODczMiwia2V5Ijp7InBlZXJpcCI6IjEwLjEzOC4wLjkiLCJkZXZuYW1lIjoiZGV2ZWxvcGVyMTU1NDIzODczMC04ODU0MDkiLCJhcHBuYW1lIjoiYXBwMTU1NDIzODczMC04ODU0MDkiLCJhcHB2ZXJzIjoiMS4wIiwia2lkIjo2fX0.oehfMCQiukTxbYtq0xa4C-XSji_BJhTp7zLDjZk_WlWPSM0uyyt1Ul0UhkCR-7e8XWLJvqaFjzmuPRxjiN0ruw

# ECQ-2934
MC - User with bad token2 shall not be able to get current status
    [Documentation]
    ...  - request user/current with token=xx
    ...  - verify correct error msg is received

   ${error_msg}=  Run Keyword and Expect Error  ('code=401', 'error={"message":"Invalid or expired jwt"}')  Get Current User  token=xx

# ECQ-2935
MC - User with expired token shall not be able to get current status of superuser
    [Documentation]
    ...  - request user/current with expired token of superuser
    ...  - verify correct error msg is received

   # gen 10am 4/4 {"token":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ0NzY2OTcsImlhdCI6MTU1NDM5MDI5NywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.PsVVex66xzIL3ebqSy9gQnN2rBykCETuwihnAAxsPk_9vwp6fpW0mD2vdvgTALY08Eq--N_ZNoguPNHXc8h5AQ"}

   ${token}=  Set Variable  eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ0NzY2OTcsImlhdCI6MTU1NDM5MDI5NywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.PsVVex66xzIL3ebqSy9gQnN2rBykCETuwihnAAxsPk_9vwp6fpW0mD2vdvgTALY08Eq--N_ZNoguPNHXc8h5AQ	
   ${error_msg}=  Run Keyword and Expect Error  ('code=401', 'error={"message":"Invalid or expired jwt"}')  Get Current User  token=${token}

# ECQ-2936
MC - User with expired token shall not be able to get current status of newuser
    [Documentation]
    ...  - request user/current with expired token of newuser
    ...  - verify correct error msg is received

    # created 10am4/4 {"token":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ0NzY0MTEsImlhdCI6MTU1NDM5MDAxMSwidXNlcm5hbWUiOiJuYW1lMTU1NDM5MDAxMS4yMDMyOTI4Iiwia2lkIjoyfQ.zs0z3rKlFzYbm7TfmuU5PpsnnF7LpotwfZh9Rb_Ym_LTpXciaBckPstBk_z64yHDV0hvh2mjLtbUp-4OVlOrNg"}
   ${token}=  Set Variable  eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ0NzY0MTEsImlhdCI6MTU1NDM5MDAxMSwidXNlcm5hbWUiOiJuYW1lMTU1NDM5MDAxMS4yMDMyOTI4Iiwia2lkIjoyfQ.zs0z3rKlFzYbm7TfmuU5PpsnnF7LpotwfZh9Rb_Ym_LTpXciaBckPstBk_z64yHDV0hvh2mjLtbUp-4OVlOrNg	
   ${error_msg}=  Run Keyword and Expect Error  ('code=401', 'error={"message":"Invalid or expired jwt"}')  Get Current User  token=${token}

# ECQ-2928
MC - User shall be able to update current metadata
    [Documentation]
    ...  - create a new user and login
    ...  - set the metadata 
    ...  - get the user data and verify metadata is set 

   ${i}=  Get Time  epoch
   ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
   ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

   Skip Verify Email
   Create User  ${username1}  ${password}  ${email1}
   Unlock User  #username=${username}
   ${token}=  Login

   ${username}=  Get Default Username
   ${email}=  Get Default Email

   ${info}=  Get Current User

   Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info['Email']}          ${email1}
   Should Be Equal             ${info['EmailVerified']}  ${False}
   Should Be Equal             ${info['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info['Iter']}           0
   Should Be Equal             ${info['Name']}           ${username1}
   Should Be Equal             ${info['Nickname']}       ${EMPTY}
   Should Be Equal             ${info['Passhash']}       ${EMPTY}
   Should Be Equal             ${info['Picture']}        ${EMPTY}
   Should Be Equal             ${info['Salt']}           ${EMPTY}
   Should Be Equal            ${info['Metadata']}        ${EMPTY}
   Convert Date  ${info['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   Update Current User  metadata=xxxx  use_defaults=False  token=${token}  

   ${info2}=  Get Current User

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info2['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info2['Iter']}           0
   Should Be Equal             ${info2['Name']}           ${username1}
   Should Be Equal             ${info2['Nickname']}       ${EMPTY}
   Should Be Equal             ${info2['Passhash']}       ${EMPTY}
   Should Be Equal             ${info2['Picture']}        ${EMPTY}
   Should Be Equal             ${info2['Salt']}           ${EMPTY}
   Should Be Equal            ${info2['Metadata']}        xxxx
   Convert Date  ${info2['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

# ECQ-3623
MC - User shall not be able to update username
    [Documentation]
    ...  - create a new user and login
    ...  - set the username
    ...  - verify error is received

   ${i}=  Get Time  epoch
   ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
   ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

   Skip Verify Email
   Create User  ${username1}  ${password}  ${email1}
   Unlock User  #username=${username}
   ${token}=  Login

   Run Keyword and Expect Error  ('code=400', 'error={"message":"Cannot change username"}')  Update Current User  username=xx  use_defaults=False  token=${token}

# ECQ-3622
MC - User shall be able to update current nick/family/given name
    [Documentation]
    ...  - create a new user and login
    ...  - set the nick/family/given name
    ...  - get the user data and verify nick/family/given name is set

   ${i}=  Get Time  epoch
   ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
   ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

   Skip Verify Email
   Create User  ${username1}  ${password}  ${email1}
   Unlock User  #username=${username}
   ${token}=  Login

   ${username}=  Get Default Username
   ${email}=  Get Default Email

   ${info}=  Get Current User

   Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info['Email']}          ${email1}
   Should Be Equal             ${info['EmailVerified']}  ${False}
   Should Be Equal             ${info['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info['Iter']}           0
   Should Be Equal             ${info['Name']}           ${username1}
   Should Be Equal             ${info['Nickname']}       ${EMPTY}
   Should Be Equal             ${info['Passhash']}       ${EMPTY}
   Should Be Equal             ${info['Picture']}        ${EMPTY}
   Should Be Equal             ${info['Salt']}           ${EMPTY}
   Should Be Equal            ${info['Metadata']}        ${EMPTY}
   Convert Date  ${info['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   Update Current User  family_name=newfamilyname  given_name=newgivenname  nickname=newnickname  use_defaults=False  token=${token}

   ${info2}=  Get Current User

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['FamilyName']}     newfamilyname
   Should Be Equal             ${info2['GivenName']}      newgivenname
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info2['Iter']}           0
   Should Be Equal             ${info2['Name']}           ${username1}
   Should Be Equal             ${info2['Nickname']}       newnickname
   Should Be Equal             ${info2['Passhash']}       ${EMPTY}
   Should Be Equal             ${info2['Picture']}        ${EMPTY}
   Should Be Equal             ${info2['Salt']}           ${EMPTY}
   Should Be Equal            ${info2['Metadata']}        ${EMPTY}
   Convert Date  ${info2['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

# ECQ-3624
MC - User shall be able to update current email address
    [Documentation]
    ...  - create a new user and login
    ...  - set the emailaddress
    ...  - get the user data and verify emailaddress is set

   ${i}=  Get Time  epoch
   ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
   ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

   Skip Verify Email
   Create User  ${username1}  ${password}  ${email1}
   Unlock User  #username=${username}
   ${token}=  Login

   ${username}=  Get Default Username
   ${email}=  Get Default Email

   ${info}=  Get Current User

   Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info['Email']}          ${email1}
   Should Be Equal             ${info['EmailVerified']}  ${False}
   Should Be Equal             ${info['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info['Iter']}           0
   Should Be Equal             ${info['Name']}           ${username1}
   Should Be Equal             ${info['Nickname']}       ${EMPTY}
   Should Be Equal             ${info['Passhash']}       ${EMPTY}
   Should Be Equal             ${info['Picture']}        ${EMPTY}
   Should Be Equal             ${info['Salt']}           ${EMPTY}
   Should Be Equal            ${info['Metadata']}        ${EMPTY}
   Convert Date  ${info['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   Update Current User  email_address=newemail@email.com  use_defaults=False  token=${token}

   ${info2}=  Get Current User

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          newemail@email.com
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info2['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info2['Iter']}           0
   Should Be Equal             ${info2['Name']}           ${username1}
   Should Be Equal             ${info2['Nickname']}       ${EMPTY} 
   Should Be Equal             ${info2['Passhash']}       ${EMPTY}
   Should Be Equal             ${info2['Picture']}        ${EMPTY}
   Should Be Equal             ${info2['Salt']}           ${EMPTY}
   Should Be Equal            ${info2['Metadata']}        ${EMPTY}
   Convert Date  ${info2['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

# ECQ-3625
MC - User shall be able to update current enable totp
    [Documentation]
    ...  - create a new user and login
    ...  - enable totp
    ...  - get the user data and verify enable totp is set

   ${i}=  Get Time  epoch
   ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
   ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

   Skip Verify Email
   Create User  ${username1}  ${password}  ${email1}
   Unlock User  #username=${username}
   ${token}=  Login

   ${username}=  Get Default Username
   ${email}=  Get Default Email

   ${info}=  Get Current User

   Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info['Email']}          ${email1}
   Should Be Equal             ${info['EmailVerified']}  ${False}
   Should Be Equal             ${info['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info['Iter']}           0
   Should Be Equal             ${info['Name']}           ${username1}
   Should Be Equal             ${info['Nickname']}       ${EMPTY}
   Should Be Equal             ${info['Passhash']}       ${EMPTY}
   Should Be Equal             ${info['Picture']}        ${EMPTY}
   Should Be Equal             ${info['Salt']}           ${EMPTY}
   Should Be Equal            ${info['Metadata']}        ${EMPTY}
   Should Not Be True         ${info['EnableTOTP']}
   Should Be Equal             ${info['TOTPSharedKey']}  ${EMPTY}
   Convert Date  ${info['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   ${msg}=  Update Current User  enable_totp=${True}  use_defaults=False  token=${token}
   Should Contain  ${msg['Message']}  User updated${\n}Enabled two factor authentication. Please use the following text code with the two factor authentication app on your phone to set it up
   Should Be True  len('${msg['TOTPSharedKey']}') > 0
   Should Be True  len('${msg['TOTPQRImage']}') > 0

   ${info2}=  Get Current User

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info2['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info2['Iter']}           0
   Should Be Equal             ${info2['Name']}           ${username1}
   Should Be Equal             ${info2['Nickname']}       ${EMPTY}
   Should Be Equal             ${info2['Passhash']}       ${EMPTY}
   Should Be Equal             ${info2['Picture']}        ${EMPTY}
   Should Be Equal             ${info2['Salt']}           ${EMPTY}
   Should Be Equal            ${info2['Metadata']}        ${EMPTY}
   Should Be True              ${info2['EnableTOTP']}
   Should Be Equal             ${info2['TOTPSharedKey']}  ${EMPTY}
   Convert Date  ${info2['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   ${msg}=  Update Current User  enable_totp=${False}  use_defaults=False  token=${token}

   ${info2}=  Get Current User

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['FamilyName']}     ${EMPTY}
   Should Be Equal             ${info2['GivenName']}      ${EMPTY}
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info2['Iter']}           0
   Should Be Equal             ${info2['Name']}           ${username1}
   Should Be Equal             ${info2['Nickname']}       ${EMPTY}
   Should Be Equal             ${info2['Passhash']}       ${EMPTY}
   Should Be Equal             ${info2['Picture']}        ${EMPTY}
   Should Be Equal             ${info2['Salt']}           ${EMPTY}
   Should Be Equal            ${info2['Metadata']}        ${EMPTY}
   Should Not Be True         ${info2['EnableTOTP']}
   Should Be Equal             ${info2['TOTPSharedKey']}  ${EMPTY}
   Convert Date  ${info2['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

# ECQ-4273
MC - User shall not be able to update with duplicate email address
    [Documentation]
    ...  - Login as a user
    ...  - attempt to update with an email already used
    ...  - verify error is returned

    Login  username=${op_manager_user_automation}   password=${op_manager_password_automation}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Email ${admin_manager_email} already in use"}')  Update Current User  email_address=${admin_manager_email}  use_defaults=${False}

