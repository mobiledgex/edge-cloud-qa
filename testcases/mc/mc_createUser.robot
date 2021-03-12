*** Settings ***
Documentation   MasterController user/current superuser

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  OperatingSystem
Library  String
Library  Collections
	
Suite Setup	 Setup
Test Teardown    Cleanup provisioning

*** Variables ***
${password}=   mexadminfastedgecloudinfra
${tld_file}=  tlds_list.txt
	
*** Test Cases ***
# ECQ-2715
MC - User shall be able to create a new user
	[Documentation]
	...  create a new user with various name
	...  get user/current info
	...  verify info is correct
	...  delete the user
	...  ECQ-2715
	
	@{usernames}=  Create List  1  a  _username  123lkjsdfh12jsd12  MYNAME  a-----   dlfjoiwefmsifqwleko23kjsdlijalskdfjqoiwjlkadsjfoiajlrejqwoiejalksdjfoiqwjflkajsdoifjqwiojfaoifjaiosjfiwjefoiajsdflkajlfkjaskldfjaoijfalksdjfoiajsdflkjasoifjasdlkjfalisjdfklajsdflkajsflkajsflkj  my_username
	
	: FOR  ${name}  IN  @{usernames}
	\  ${email}=  Catenate  SEPARATOR=  ${name}  @auto.com
	\  ${username}=   Set Variable   ${name}
	\  Create User  username=${name}  password=${password}  email_address=${email}
	\  Unlock User  username=${name}
	\  Login   username=${name}  password=${password}
	
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

# ECQ-2716
MC - User shall not be able to create a new user with no username
	[Documentation]
	...  create a new user without username
	...  verify proper error is received
	...  ECQ-2716
	
	Run Keyword and Expect Error  ('code=400', 'error={"message":"Name not specified"}')  Create User   password=${password}   email_address=x@x.com   use_defaults=${False}
	
# ECQ-2717
MC - User shall not be able to create a new user with empty username
	[Documentation]
	...  create a new user with empty username
	...  verify proper error is received
	...  ECQ-2717
	
	Run Keyword and Expect Error  ('code=400', 'error={"message":"Name not specified"}')  Create User  username=${EMPTY}  password=${password}  email_address=x@x.com  use_defaults=${False}
	
# ECQ-2718
MC - User shall not be able to create a new user with no password
	[Documentation]
	...  create a new user without password
	...  verify proper is received
	...  ECQ-2718
	
	Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid password, password must be at least 8 characters"}')  Create User  username=xxxxx  email_address=x@x.com  use_defaults=${False}

# ECQ-2719
MC - User shall not be able to create a new user with empty password
	[Documentation]
	...  create a new user with empty password
	...  verify proper error is received
	...  ECQ-2719
	
	Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid password, password must be at least 8 characters"}')  Create User  username=xxxxx  password=${EMPTY}  email_address=x@x.com  use_defaults=${False}

# ECQ-2720
MC - User shall not be able to create a new user without an email
	[Documentation]
	...  create a new user without an email
	...  verify the proper error is received
	...  ECQ-2720

	Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid email address"}')  Create User   username=myusername   password=${password}   use_defaults=${False}

# ECQ-2721
MC - User shall not be able to create a new user with an empty email
	[Documentation]
	...  create a new user with an empty email
	...  verify the proper error is received
	...  ECQ-2721

	Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid email address"}')  Create User   username=myusername    password=${password}   email_address=${EMPTY}   use_defaults=${False}

# ECQ-2722
MC - User shall not be able to create a new user with :: in the username
	[Documentation]
	...  create a new user with :: in the username
	...  verify the proper error is received
	...  ECQ-2722

	Run Keyword and Expect Error  ('code=400', 'error={"message":"name can only contain letters, digits, _ . -"}')  Create User  username=my::name  password=${password}  email_address=x@x.com  use_defaults=${False}

# ECQ-2723
MC - User shall not be able to create a new user with an invalid email
	[Documentation]
	...  create a new user with an empty email
	...  verify the proper error is received
	...  ECQ-2723

	Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid email address"}')  Create User   username=myusername    password=${password}   email_address=x.com   use_defaults=${False}

# ECQ-2724
MC - User shall not be able to create a new user with an invalid username characters  
	[Documentation]
	...  create a new user with an invalid username
	...  verify the proper error is received
	...  ECQ-2724

	Run Keyword and Expect Error  ('code=400', 'error={"message":"name can only contain letters, digits, _ . -"}')  Create User   username=~^`    password=${password}   email_address=x@x.com   use_defaults=${False}

# ECQ-2725
MC - User shall not be able to create a new user with spaces before the username   
	[Documentation]
	...  create a new user with spaces before the username
	...  verify the proper error is received
	...  ECQ-2725

	Run Keyword and Expect Error  ('code=400', 'error={"message":"name can only contain letters, digits, _ . -"}')  Create User   username=${SPACE}name${SPACE}    password=${password}   email_address=x@x.com   use_defaults=${False}

# ECQ-2726
MC - User shall not be able to create a new user with an invalid password
	[Documentation]
	...  create a new user with an invalid password
	...  verify the proper error is received
	...  ECQ-2726

	Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid password, password must be at least 8 characters"}')  Create User   username=xxxxxx    password=mypass   email_address=x@x.com   use_defaults=${False}

# ECQ-2727
MC - User shall not be able to create the same new user twice same info
	[Documentation]
	...  create the same user twice same info
	...  verify the proper error is received
	...  delete the user
	...  ECQ-2727

        Create User   username=myusername   password=${password}   email_address=xy@xy.com    use_defaults=${False}
	Run Keyword and Expect Error  ('code=400', 'error={"message":"Username with name myusername (case-insensitive) already exists"}')  Create User   username=myusername    password=${password}   email_address=xy@xy.com   use_defaults=${False}

# ECQ-2728	
MC - User shall not be able to create the same new user twice different password
	[Documentation]
	...  create the same user twice different password
	...  verify the proper error is received
	...  delete the user
	...  ECQ-2728

        Create User   username=myusername   password=${password}   email_address=xy@xy.com    use_defaults=${False}
	Run Keyword and Expect Error  ('code=400', 'error={"message":"Username with name myusername (case-insensitive) already exists"}')  Create User   username=myusername    password=user45newvigaveveateat1726354   email_address=xy@xy.com   use_defaults=${False}

# ECQ-2732
MC - User shall not be able to create the same new user twice different email
	[Documentation]
	...  create the same user twice different email
	...  verify the proper error is received
	...  delete the user
	...  ECQ-2732

        Create User   username=myusername   password=${password}   email_address=xy@xy.com    use_defaults=${False}
	Run Keyword and Expect Error  ('code=400', 'error={"message":"Username with name myusername (case-insensitive) already exists"}')  Create User   username=myusername    password=${password}   email_address=xyz@xyz.com   use_defaults=${False}

# ECQ-2733
MC - User shall not be able to create the superuser twice same info
	[Documentation]
	...  create the superuser again with the same info
	...  verify the proper error is received
	...  ECQ-2733

	Run Keyword and Expect Error  ('code=400', 'error={"message":"Username with name mexadmin (case-insensitive) already exists"}')  Create User   username=mexadmin    password=${password}    email_address=mexadmin@mobiledgex.net   use_defaults=${False}

# ECQ-2734
MC - User shall not be able to create the superuser twice different password
	[Documentation]
	...  create the superuser again with a different password
	...  verify the proper error is received
	...  ECQ-2734

	Run Keyword and Expect Error  ('code=400', 'error={"message":"Username with name mexadmin (case-insensitive) already exists"}')  Create User   username=mexadmin    password=${password}   email_address=mexadmin@mobiledgex.net   use_defaults=${False}

# ECQ-2735
MC - User shall not be able to create the superuser twice different email
	[Documentation]
	...  create the superuser again with a different password
	...  verify the proper error is received
	...  ECQ-2735

	Run Keyword and Expect Error  ('code=400', 'error={"message":"Username with name mexadmin (case-insensitive) already exists"}')  Create User   username=mexadmin    password=${password}    email_address=xy@xy.com   use_defaults=${False}

# ECQ-2736
MC - User shall not be able to create the user with a weak password
	[Documentation]
	...  create a user with a weak password
	...  verify the proper error is received
	...  ECQ-2736
	

	Run Keyword and Expect Error  ('code=400', 'error={"message":"Password too weak, requires crack time 31.0 days but is less than a second. Please increase length or complexity"}')  Create User   username=myusername    password=password123    email_address=xy@xy.com   use_defaults=${False}

# ECQ-2981
MC - User shall be able to create a new user with all TLDs
        [Documentation]
        ...  - create a new user using all TLDs
        ...  - unlock user
        ...  - login user
        ...  - delete the user

        Login Mexadmin  # login again as mexadmin since running the suite logs in as anothe user once it gets here

        ${tldsf}=  Find File  ${tld_file}
        ${tlds}=  Get File  ${tldsf} 
        @{tlds_split}=  Split String  ${tlds}

        ${x}=  Set Variable  0
        ${step}=  Set Variable  20
        ${num_tlds}=  Get Length  ${tlds_split}

        [Teardown]  Teardown TLDs  ${tlds_split}  ${step}
 
        FOR  ${x}  IN RANGE  0  ${num_tlds}  ${step}
            Log to console  ${x}
            Run Keyword If  ${x} < ${num_tlds}  Create Users In Background  ${x}  ${step}  ${tlds_split}
            ...  ELSE  Exit For Loop

            Login Users In Background  ${x}  ${step}  ${tlds_split}
        END

*** Keywords ***
Setup
	Login
        Skip Verify Email

Create Users In Background
   [Arguments]  ${start}  ${step}  ${tlds_split}
  
   @{handle_list1}=  Create List
   @{handle_list2}=  Create List
   ${end}=  Evaluate  ${step} + ${start}
   ${num_tlds}=  Get Length  ${tlds_split}
 
   FOR  ${c}  IN RANGE  ${start}  ${end}
      Run Keyword If  ${c} < ${num_tlds}  log to console  ${tlds_split[${c}]}
      ${handle}=  Run Keyword If  ${c} < ${num_tlds}  Create User  username=tld${tlds_split[${c}]}  password=${password}  email_address=tld${tlds_split[${c}]}@tld.${tlds_split[${c}]}  use_thread=${True}  auto_delete=${False}
      ...  ELSE  Exit For Loop
      Append To List   ${handle_list1}   ${handle}
   END
   Wait For Replies    @{handle_list1}

   FOR  ${c}  IN RANGE  ${start}  ${end}
      ${handle}=  Run Keyword If  ${c} < ${num_tlds}  Unlock User  username=tld${tlds_split[${c}]}  use_thread=${True}
      ...  ELSE  Exit For Loop
      Append To List   ${handle_list2}   ${handle}
   END
   Wait For Replies    @{handle_list2}

Login Users In Background
   [Arguments]  ${start}  ${step}  ${tlds_split}

   @{handle_list}=  Create List
   ${end}=  Evaluate  ${step} + ${start}
   ${num_tlds}=  Get Length  ${tlds_split}

   FOR  ${c}  IN RANGE  ${start}  ${end}
      ${handle}=  Run Keyword If  ${c} < ${num_tlds}  Login  username=tld${tlds_split[${c}]}  password=${password}  use_thread=${True}
      ...  ELSE  Exit For Loop
      Append To List   ${handle_list}   ${handle}
   END

   Wait For Replies    @{handle_list}

Teardown TLDs
   [Arguments]  ${tlds_split}  ${step}

   ${num_tlds}=  Get Length  ${tlds_split}

   FOR  ${x}  IN RANGE  0  ${num_tlds}  ${step}
      Delete Users In Background  ${x}  ${step}  ${tlds_split}
   END

Delete Users In Background
   [Arguments]  ${start}  ${step}  ${tlds_split}

   @{handle_list}=  Create List
   ${end}=  Evaluate  ${step} + ${start}
   ${num_tlds}=  Get Length  ${tlds_split}

   FOR  ${c}  IN RANGE  ${start}  ${end}
      ${handle}=  Run Keyword If  ${c} < ${num_tlds}  Delete User  username=tld${tlds_split[${c}]}  use_thread=${True}
      ...  ELSE  Exit For Loop

      Append To List   ${handle_list}   ${handle}
   END

   Wait For Replies    @{handle_list}

