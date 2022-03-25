*** Settings ***
Documentation  user show mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${version}=  latest

*** Test Cases ***
# ECQ-3406
ShowUser - mcctl shall be able to show users
   [Documentation]
   ...  - send user show via mcctl with various parms
   ...  - verify success

   [Template]  Success ShowUser Via mcctl
       name_to_check=mexadmin  
       name_to_check=qaadmin                    email=mxdmnqa@gmail.com
       name_to_check=mexadmin                   familyname=mexadmin
       name_to_check=mexadmin                   givenname=mexadmin
       name_to_check=mexadmin                   nickname=mexadmin
       name_to_check=op_contributor_automation  name=op_contributor_automation

# ECQ-4437
User - mcctl shall be able to show the current user
   [Documentation]
   ...  - send user current via mcctl
   ...  - verify success

   ${token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

   ${result}=  Run mcctl  user current  token=${token}  version=${version}

   Should Be Equal  ${result['Name']}  ${dev_manager_user_automation}
   Should Contain  ${result['Email']}  gmail.com

   Should Be True   ${result['EmailVerified']}
   Should Not Be True  ${result['Locked']}  

   Should Be True  len('${result['CreatedAt']}') > 0
   Should Be True  len('${result['UpdatedAt']}') > 0
   Should Be True  len('${result['LastLogin']}') > 0
   Should Be True  len('${result['PassCrackTimeSec']}') > 0

   ${error}=  Run Keyword and Expect Error  *  Run mcctl  user current --data "{}"  token=${token}  version=${version}
   Should Contain  ${error}  command does not accept input

# ECQ-4298
User - mcctl help shall show
   [Documentation]
   ...  - send User via mcctl with help for each command
   ...  - verify help is returned

   [Template]  Show Help
   ${Empty}
   create
   delete
   update
   show
   current
   newpass
   resendverify
   verifyemail
   passwordresetrequest
   passwordreset
   createuserapikey
   deleteuserapikey
   showuserapikey

*** Keywords ***
#Setup
#   ${end_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
#   ${start_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ  increment=-24 hours
#
#   Set Suite Variable  ${start_date}
#   Set Suite Variable  ${end_date}

Success ShowUser Via mcctl
   [Arguments]  &{parms}

   ${name_to_check}=  Set Variable  ${parms['name_to_check']}
   Remove From Dictionary  ${parms}  name_to_check  # dont send this as an arg
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   @{result}=  Run mcctl  user show ${parmss_modify}  version=${version}

   ${found}=  Set Variable  ${False}
   FOR  ${key}  IN  @{result}
      IF  '${key['Name']}' == '${name_to_check}'
          ${found}=  Set Variable  ${True}
          Exit For Loop
      END
   END

   Should Be True  ${found}

Show Help
   [Arguments]  ${parms}

   ${error}=  Run Keyword and Expect Error  *  Run mcctl  user ${parms} -h  version=${version}

   ${cmd}=  Run Keyword If  '${parms}' == '${Empty}'  Set Variable  ${Empty}  ELSE  Set Variable  ${parms}
   Should Contain  ${error}  Usage: mcctl user ${cmd}
