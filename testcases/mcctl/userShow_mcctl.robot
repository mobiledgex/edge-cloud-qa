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
