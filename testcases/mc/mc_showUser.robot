*** Settings ***
Documentation   MasterController show user

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
Library         Collections

#Test Setup     Setup
#Test Teardown   Cleanup Provisioning

*** Variables ***
${username}          mextester99
${password}          ${mextester06_gmail_password}
${email}             mextester99@gmail.com

*** Test Cases ***
# ECQ-3151
MC - shall be able to show user by username/email/familyname/givenname/nickname
    [Documentation]
    ...  - create 2 users
    ...  - send user show with username/email/familyname/givenname/nickname
    ...  - verify returned info is correct

   [Setup]  Setup
   [Teardown]  Cleanup Provisioning
   [Template]  Show User with filter

   username_to_check=${username1}  username=${username1}  
   username_to_check=${username1}  email=${username1}@xy.com
   username_to_check=${username1}  family_name=${username1}_familyname 
   username_to_check=${username1}  given_name=${username1}_givenname 
   username_to_check=${username1}  nickname=${username1}_nickname 
   username_to_check=${username1}  username=${username1}  email=${username1}@xy.com
   username_to_check=${username1}  username=${username1}  family_name=${username1}_familyname
   username_to_check=${username1}  given_name=${username1}_givenname  nickname=${username1}_nickname
   username_to_check=${username1}  username=${username1}  email=${username1}@xy.com  family_name=${username1}_familyname  given_name=${username1}_givenname  nickname=${username1}_nickname


   username_to_check=${username2}  username=${username2}
   username_to_check=${username2}  email=${username2}@xy.com
   username_to_check=${username2}  family_name=${username2}_familyname
   username_to_check=${username2}  given_name=${username2}_givenname
   username_to_check=${username2}  nickname=${username2}_nickname
   username_to_check=${username2}  username=${username2}  email=${username2}@xy.com
   username_to_check=${username2}  username=${username2}  family_name=${username2}_familyname
   username_to_check=${username2}  given_name=${username2}_givenname  nickname=${username2}_nickname
   username_to_check=${username2}  username=${username2}  email=${username2}@xy.com  family_name=${username2}_familyname  given_name=${username2}_givenname  nickname=${username2}_nickname

# ECQ-3152
MC - shall be able to show user by role
    [Documentation]
    ...  - send user show with all role type
    ...  - verify returned info is correct

   [Template]  Show User by Role Should Return Correct Users

   OperatorManager
   OperatorContributor
   OperatorViewer
   DeveloperManager
   DeveloperContributor
   DeveloperViewer
   AdminManager
   AdminContributor
   AdminViewer

# ECQ-3153
MC - shall be able to show user by org
    [Documentation]
    ...  - send user show with org
    ...  - verify returned info is correct

   [Template]  Show User by Org Should Return Correct Users

   dmuus
   GDDT
 
# ECQ-3154 
MC - shall be able to show user by locked
    [Documentation]
    ...  - send user show with locked
    ...  - verify returned info is correct

    add test

# ECQ-3155
MC - shall be able to show user by enabletotp
    [Documentation]
    ...  - send user show with enabletotp
    ...  - verify returned info is correct

    add test

# ECQ-3156
MC - shall be able to show user by emailverified
    [Documentation]
    ...  - send user show with emailverified
    ...  - verify returned info is correct

    add test
 
*** Keywords ***
Show User by Role Should Return Correct Users
   [Arguments]  ${role}

   ${super_token}=  Get Super Token

   ${roles}=  Show User Role  role=${role}  token=${super_token}
   ${info}=  Show User  role=${role}  token=${super_token}  use_defaults=${False}

   ${num_roles}=  Get Length  ${roles}
   ${num_users}=  Get Length  ${info}

   FOR  ${u}  IN  @{info}
      ${found}=  User Should Be In Roles  ${u['Name']}  ${roles}
      Should Be True  ${found}
   END

Show User by Org Should Return Correct Users
   [Arguments]  ${org}

   ${roles}=  Show User Role  organization=${org}  token=${super_token}
   ${info}=  Show User  organization=${org}  token=${super_token}  use_defaults=${False}

   ${num_roles}=  Get Length  ${roles}
   ${num_users}=  Get Length  ${info}

   Should Be True  ${num_roles} > 0
   Should Be True  ${num_users} > 0

   FOR  ${u}  IN  @{info}
      ${found}=  User Should Be In Roles  ${u['Name']}  ${roles}
      Should Be True  ${found}
   END

User Should Be In Roles
   [Arguments]  ${user}  ${roles}

   ${found}=  Set Variable  ${False}
   FOR  ${r}  IN  @{roles}
      ${found}=  Run Keyword If  '${r['username']}' == '${user}'  Set Variable  ${True}
      ...  ELSE  Set Variable  ${found} 
   END

   [Return]  ${found}

Setup
   ${super_token}=  Get Super Token
   ${time}=  Get Time  epoch
   
   ${username1}=  Set Variable  user1_${time}
   ${username2}=  Set Variable  user2_${time}

   Create User  username=${username1}   password=${mextester06_gmail_password}   email_address=${username1}@xy.com  family_name=${username1}_familyname  given_name=${username1}_givenname  nickname=${username1}_nickname  
   Create User  username=${username2}   password=${mextester06_gmail_password}   email_address=${username2}@xy.com  family_name=${username2}_familyname  given_name=${username2}_givenname  nickname=${username2}_nickname  enable_totp=${True}

   Unlock User  username=${username1}

   ${user_token}=  Login  username=${username1}   password=${mextester06_gmail_password}
   Verify Email Via MC    token=${user_token} 

   Set Suite Variable  ${super_token}
   Set Suite Variable  ${username1}
   Set Suite Variable  ${username2}

Show User with filter
   [Arguments]  ${username_to_check}  ${username}=${None}  ${email}=${None}  ${family_name}=${None}  ${given_name}=${None}  ${nickname}=${None} 

   ${info}=  Show User  username=${username}  email_address=${email}  family_name=${family_name}  given_name=${given_name}  nickname=${nickname}  token=${super_token}  use_defaults=${False}

   Convert Date  ${info[0]['CreatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z
   Convert Date  ${info[0]['UpdatedAt']}  date_format=%Y-%m-%dT%H:%M:%S.%f%z

   Should Be Equal             ${info[0]['Email']}          ${username_to_check}@xy.com
   Run Keyword If  '${username_to_check}' == '${username1}'  Should Be Equal  ${info[0]['EmailVerified']}  ${True}
   ...  ELSE  Should Be Equal  ${info[0]['EmailVerified']}  ${False}
   Run Keyword If  '${username_to_check}' == '${username1}'  Should Be Equal  ${info[0]['EnableTOTP']}  ${False}
   ...  ELSE  Should Be Equal  ${info[0]['EnableTOTP']}  ${True}
   Run Keyword If  '${username_to_check}' == '${username1}'  Should Be Equal  ${info[0]['Locked']}  ${False}
   ...  ELSE  Should Be Equal  ${info[0]['Locked']}  ${True}

   Should Be Equal             ${info[0]['FamilyName']}     ${username_to_check}_familyname 
   Should Be Equal             ${info[0]['GivenName']}      ${username_to_check}_givenname 
   #Should Be Equal  ${info[0]['ID']}  1
   Should Be Equal As Numbers  ${info[0]['Iter']}           0
   Should Be Equal             ${info[0]['Name']}           ${username_to_check}
   Should Be Equal             ${info[0]['Nickname']}       ${username_to_check}_nickname 
   Should Be Equal             ${info[0]['Passhash']}       ${EMPTY}
   Should Be Equal             ${info[0]['Picture']}        ${EMPTY}
   Should Be Equal             ${info[0]['Salt']}           ${EMPTY}

