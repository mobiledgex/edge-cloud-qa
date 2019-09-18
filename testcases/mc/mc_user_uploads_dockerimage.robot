*** Settings ***
Documentation   MasterController user/current superuser

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
	
#Test Setup	 Setup
Test Teardown    Teardown

*** Variables ***
${username}          mextester99
${password}          mextester99123
${email}             mextester99@gmail.com
${orgname}           MobiledgeX
${i}                 1
	
*** Test Cases ***

MC - User shall be able to create a and upload docker image in different user roles
	[Documentation] 
	...  create a new user 
	...  add user to an org as different roles
	...  upload docker image in each role
	...  delete the user

    ${email1}=  Catenate  SEPARATOR=  ${username}  +  ${i}  @gmail.com
    ${username1}=  Catenate  SEPARATOR=  ${username}  ${i}
	
    Create user  username=${username1}  password=${password}  email=${email1}

    Unlock User  username=${username1}
    
    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperManager

    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperContributor

    Adduser Role  orgname=${orgname}  username=${username1}  role=DeveloperViewer



*** Keywords ***

Teardown
    Cleanup Provisioning
 
