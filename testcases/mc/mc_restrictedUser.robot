*** Settings ***
Documentation   MasterController restricted user

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
Library         Collections
	
Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${username}          mextester99
${password}          ${mextester06_gmail_password}
${email}             mextester99@gmail.com

*** Test Cases ***
# ECQ-3626
MC - Admin shall be able to update other user nick/family/given name
    [Documentation]
    ...  - create a new user and login
    ...  - set the nick/family/given name
    ...  - get the user data and verify nick/family/given name is set

   ${info}=  Get Current User  token=${usertoken}

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

   Update Restricted User  username=${username1}  family_name=newfamilyname  given_name=newgivenname  nickname=newnickname  use_defaults=False  token=${supertoken}

   ${info2}=  Get Current User  token=${usertoken}

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

   Update Restricted User  email_address=${email1}  family_name=newfamilyname2  given_name=newgivenname2  nickname=newnickname2  use_defaults=False  token=${supertoken}

   ${info2}=  Get Current User  token=${usertoken}

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['FamilyName']}     newfamilyname2
   Should Be Equal             ${info2['GivenName']}      newgivenname2
   #Should Be Equal  ${info['ID']}  1
   Should Be Equal As Numbers  ${info2['Iter']}           0
   Should Be Equal             ${info2['Name']}           ${username1}
   Should Be Equal             ${info2['Nickname']}       newnickname2
   Should Be Equal             ${info2['Passhash']}       ${EMPTY}
   Should Be Equal             ${info2['Picture']}        ${EMPTY}
   Should Be Equal             ${info2['Salt']}           ${EMPTY}
   Should Be Equal            ${info2['Metadata']}        ${EMPTY}
   Convert Date  ${info2['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

# ECQ-3627
MC - Admin shall be able to update other user email verified
    [Documentation]
    ...  - create a new user and login
    ...  - set the email verified
    ...  - get the user data and verify email verified is set

   ${info}=  Get Current User  token=${usertoken}

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

   Update Restricted User  username=${username1}  email_verified=${True}  use_defaults=False  token=${supertoken}

   ${info2}=  Get Current User  token=${usertoken}

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${True}
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

   Update Restricted User  username=${username1}  email_verified=${False}  use_defaults=False  token=${supertoken}

   ${info2}=  Get Current User  token=${usertoken}

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
   Convert Date  ${info2['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   Update Restricted User  email_address=${email1}   email_verified=${True}  use_defaults=False  token=${supertoken}

   ${info2}=  Get Current User  token=${usertoken}

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${True}
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

# ECQ-3628
MC - Admin shall be able to update other user locked
    [Documentation]
    ...  - create a new user and login
    ...  - set the locked arg
    ...  - get the user data and verify locked is set

   ${info}=  Get Current User  token=${usertoken}

   Convert Date  ${info['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info['Email']}          ${email1}
   Should Be Equal             ${info['EmailVerified']}  ${False}
   Should Be Equal             ${info['Locked']}         ${False}
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

   Update Restricted User  username=${username1}  locked=${True}  use_defaults=False  token=${supertoken}

   ${info2}=  Get Current User  token=${usertoken}

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['Locked']}          ${True}
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

   Update Restricted User  username=${username1}  locked=${False}  use_defaults=False  token=${supertoken}

   ${info2}=  Get Current User  token=${usertoken}

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['Locked']}         ${False}
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

   Update Restricted User  email_address=${email1}  locked=${True}  use_defaults=False  token=${supertoken}

   ${info2}=  Get Current User  token=${usertoken}

   Convert Date  ${info2['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Should Be Equal             ${info2['Email']}          ${email1}
   Should Be Equal             ${info2['EmailVerified']}  ${False}
   Should Be Equal             ${info2['Locked']}          ${True}
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

*** Keywords ***
Setup
   ${supertoken}=  Get Super Token

   ${i}=  Get Time  epoch

   ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
   ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}

   Skip Verify Email
   Create User  ${username1}  ${password}  ${email1}
   Unlock User  #username=${username}
   ${usertoken}=  Login

   Set Suite Variable  ${username1}
   Set Suite Variable  ${supertoken}
   Set Suite Variable  ${usertoken}
   Set Suite Variable  ${email1}
