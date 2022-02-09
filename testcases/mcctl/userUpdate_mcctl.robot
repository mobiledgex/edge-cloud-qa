*** Settings ***
Documentation  user update  mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime
Library  Collections
Library  String

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***

*** Test Cases ***
# ECQ-4358
UpdateUser - mcctl shall be able to update the current user
	[Documentation]
	...  - send UpdateUser via mcctl with various parms
	...  - verify the user is updated 


        [Template]  Update Current User Via mcctl
  	  email=mexcontester@gmail.com
	  nickname=Phireball
	  familyname=Wizard
	  givenname=Merlin
	  email=${username}@somewhere.net  nickname=Lonely
	  email=${username}@nowhere.net    nickname=The   familyname=Lonely
	  email=${username}@mywhere.net    nickname=Only  familyname=The    givenname=Lonely
	
	
	


*** Keywords ***
Setup	
	${adminToken}=   Get Super Token
	${epoch}=        Get Current Date  result_format=epoch
        ${username}=     Set Variable      newuser${epoch}
        ${password}=     Set Variable      H31m8@W8maSfg
        ${email}=        Set Variable      ${username}@gmail.com

        Create User    username=${username}     password=${password}     email_address=${email} 
        Update Restricted User   username=${username}  email_verified=${True}   locked=${False} 
	Login  username=${username}  password=${password}

	Set Suite Variable   ${username}

Update Current User Via mcctl
	[Arguments]  &{parms}

        &{parms_copy}=  Set Variable  ${parms}

        ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
        Remove From Dictionary  ${parms_copy}  slack-api-url  # this is not allowed since it is secret
        ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

        ${resp}=  Run mcctl  user update ${parmss}
	Should Contain  ${resp}  user updated   ignore_case=True 
        ${show}=  Run mcctl  user current
        Should Be Equal As Strings  ${show['Name']}  ${username}
	Run Keyword If  'email' in ${parms}     Should Be Equal As Strings  ${show['Email']}  ${parms['email']}
	Run Keyword If  'nickname' in ${parms}     Should Be Equal As Strings  ${show['Nickname']}  ${parms['nickname']}
	Run Keyword If  'familyname' in ${parms}     Should Be Equal As Strings  ${show['FamilyName']}  ${parms['familyname']}
	Run Keyword If  'givenname' in ${parms}     Should Be Equal As Strings  ${show['GivenName']}  ${parms['givenname']}

