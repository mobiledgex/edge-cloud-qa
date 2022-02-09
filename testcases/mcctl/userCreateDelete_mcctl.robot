*** Settings ***
Documentation  user create delete update mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***


*** Test Cases ***
# ECQ-4355
CreateUser - mcctl shall be able to create/delete users
   [Documentation]
   ...  - send CreateUser/DeleteUser via mcctl with various parms
   ...  - verify the user is created/deleted
	
   [Template]  Success Create/Delete User Via mcctl
      name=${username}  email=${email}  password=${password} 
      name=${username}  email=${email}  password=${password}  nickname=Phireball
      name=${username}  email=${email}  password=${password}  familyname=Wizard
      name=${username}  email=${email}  password=${password}  givenname=Merlin
      name=${username}  email=${email}  password=${password}  enabletotp=${True}
      name=${username}  email=${email}  password=${password}  nickname=Phireball  familyname=Wizard  givenname=Merlin
      name=${username}  email=${email}  password=${password}  nickname=Phireball  familyname=Wizard  givenname=Merlin  enabletotp=${True}

# ECQ-4357
CreateUser - mcctl shall handle create failures
   [Documentation]
   ...  - send CreateUser via mcctl with various error cases
   ...  - verify proper error is received
	
   [Template]  Fail Create User Via mcctl
      # invalid values
      Error: missing required args: 
      Error: missing required args:  name=${username} 
      Error: missing required args:  email=${email}

*** Keywords ***
Setup
   ${adminToken}=   Get Super Token
   ${epoch}=        Get Current Date  result_format=epoch
   ${username}=     Set Variable      newuser${epoch}
   ${password}=     Set Variable      H31m8@W8maSfg
   ${email}=        Set Variable      ${username}@gmail.com

   Set Suite Variable   ${adminToken}
   Set Suite Variable   ${username}
   Set Suite Variable   ${password}
   Set Suite Variable   ${email}


Success Create/Delete User Via mcctl
  [Arguments]  &{parms}

  &{parms_copy}=  Set Variable  ${parms}

  ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
  Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
  ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

  ${show}=  Run mcctl  user create ${parmss}
  ${newparms}=  Set Variable  name=${parms['name']}
  Run mcctl  user delete ${newparms}  
  Should Contain  ${show}  user created   ignore_case=True 

Fail Create User Via mcctl
  [Arguments]  ${error_msg}  &{parms}
   
  ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
  ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  user create ${parmss}  
  Should Contain  ${std_create}  ${error_msg}

