*** Settings ***
Documentation   MasterController New User Login

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         Collections
Library         DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   ${mextester06_gmail_password}
${orgname}=    TheAdminOrg
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw


*** Test Cases ***
MC - Admin user shall be able show role assignments with no assignments
	[Documentation]
	...  admin user can show role assignments with no assignments
	...  verify the roles returned

	${showadmin}=   Show Role Assignment   token=${adminToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager


MC - Admin user shall be able to assign a user role to an org
	[Documentation]
	...  admin user can assign a user role to an org 
	...  verify the roles returned

	${orgname}=   Create Org        orgname=${orgname}       token=${adminToken}      
	${adduser}=   Adduser Role   orgname=${orgname}   username=${dev_manager_user_automation}   role=DeveloperManager    token=${adminToken}     use_defaults=${False}
	${showadmin}=   Show Role Assignment   token=${adminToken}
	${showuser}=    Show Role Assignment   token=${userToken}
	
#	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
#	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
#	Should Be Equal As Strings     ${showadmin[1]['org']}             ${orgname}
#	Should Be Equal As Strings     ${showadmin[1]['username']}        mexadmin
#	Should Be Equal As Strings     ${showadmin[1]['role']}            DeveloperManager

	Should Be Equal As Strings     ${showuser[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser[0]['username']}         ${dev_manager_user_automation}
	Should Be Equal As Strings     ${showuser[0]['role']}             DeveloperManager
	
MC - Admin user shall be able to assign a manager user role to an org
	[Documentation]
	...  admin user can assign a user role to an org 
	...  verify the roles returned

	${orgname}=   Create Org        orgname=${orgname}       token=${adminToken}      
	${adduser}=   Adduser Role   orgname=${orgname}   username=myuser   role=DeveloperManager    token=${adminToken}     use_defaults=${False}
	${showadmin}=   Show Role Assignment   token=${adminToken}
	${showuser}=    Show Role Assignment   token=${userToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Equal As Strings     ${showadmin[1]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[1]['username']}        mexadmin
	Should Be Equal As Strings     ${showadmin[1]['role']}            DeveloperManager

	Should Be Equal As Strings     ${showuser[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser[0]['username']}         myuser 
	Should Be Equal As Strings     ${showuser[0]['role']}             DeveloperManager
	
MC - Admin user shall be able to assign Developer user roles to a developer org
	[Documentation]
	...  admin user can assign developer user roles to a developer org
	...  verify the roles returned

	${userC}    ${passwordC}    ${emailC}=    Create User    
	${userV}    ${passwordV}    ${emailV}=    Create User 
	${orgname}=     Create Org        orgname=${orgname}       token=${adminToken}      
	${adduser}=     Adduser Role   orgname=${orgname}   username=myuser     role=DeveloperManager        token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role   orgname=${orgname}   username=${userC}   role=DeveloperContributor    token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role   orgname=${orgname}   username=${userV}   role=DeveloperViewer         token=${adminToken}     use_defaults=${False}	
	${showadmin}=   Show Role Assignment   token=${adminToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Equal As Strings     ${showadmin[1]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[1]['username']}        mexadmin
	Should Be Equal As Strings     ${showadmin[1]['role']}            DeveloperManager
	Should Be Equal As Strings     ${showadmin[2]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[2]['username']}        myuser
	Should Be Equal As Strings     ${showadmin[2]['role']}            DeveloperManager
	Should Be Equal As Strings     ${showadmin[3]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[3]['username']}        ${userC}
	Should Be Equal As Strings     ${showadmin[3]['role']}            DeveloperContributor
	Should Be Equal As Strings     ${showadmin[4]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[4]['username']}        ${userV}
	Should Be Equal As Strings     ${showadmin[4]['role']}            DeveloperViewer
	
MC - Admin user shall be able to assign Operator user roles to a operator org
	[Documentation]
	...  admin user can assign operator user roles to an operator org
	...  verify the roles returned

	${userC}    ${passwordC}    ${emailC}=    Create User    
	${userV}    ${passwordV}    ${emailV}=    Create User 
	${orgname}=     Create Org     orgname=${orgname}   orgtype=operator    token=${adminToken}      
	${adduser}=     Adduser Role   orgname=${orgname}   username=myuser     role=OperatorManager        token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role   orgname=${orgname}   username=${userC}   role=OperatorContributor    token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role   orgname=${orgname}   username=${userV}   role=OperatorViewer         token=${adminToken}     use_defaults=${False}	
	${showadmin}=   Show Role Assignment   token=${adminToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Equal As Strings     ${showadmin[1]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[1]['username']}        mexadmin
	Should Be Equal As Strings     ${showadmin[1]['role']}            OperatorManager
	Should Be Equal As Strings     ${showadmin[2]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[2]['username']}        myuser
	Should Be Equal As Strings     ${showadmin[2]['role']}            OperatorManager
	Should Be Equal As Strings     ${showadmin[3]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[3]['username']}        ${userC}
	Should Be Equal As Strings     ${showadmin[3]['role']}            OperatorContributor
	Should Be Equal As Strings     ${showadmin[4]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[4]['username']}        ${userV}
	Should Be Equal As Strings     ${showadmin[4]['role']}            OperatorViewer
	
MC - Admin user shall be able to assign all user roles to users
	[Documentation]
	...  admin user can assign all user roles to users
	...  verify the roles returned

	${userAM}    ${passwordAM}    ${emailAM}=    Create User
	${userAC}    ${passwordAC}    ${emailAC}=    Create User    
	${userAV}    ${passwordAV}    ${emailAV}=    Create User 
	${userDM}    ${passwordDM}    ${emailDM}=    Create User
	${userDC}    ${passwordDC}    ${emailDC}=    Create User    
	${userDV}    ${passwordDV}    ${emailDV}=    Create User 
	${userOM}    ${passwordOM}    ${emailOM}=    Create User
	${userOC}    ${passwordOC}    ${emailOC}=    Create User    
	${userOV}    ${passwordOV}    ${emailOV}=    Create User 
	${adduser}=     Adduser Role     username=${userAM}    role=AdminManager            token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role     username=${userAC}    role=AdminContributor        token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role     username=${userAV}    role=AdminViewer             token=${adminToken}     use_defaults=${False}	
	${adduser}=     Adduser Role     username=${userDM}    role=DeveloperManager        token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role     username=${userDC}    role=DeveloperContributor    token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role     username=${userDV}    role=DeveloperViewer         token=${adminToken}     use_defaults=${False}	
	${adduser}=     Adduser Role     username=${userOM}    role=OperatorManager         token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role     username=${userOC}    role=OperatorContributor     token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role     username=${userOV}    role=OperatorViewer          token=${adminToken}     use_defaults=${False}	
	${showadmin}=   Show Role Assignment   token=${adminToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Empty                ${showadmin[1]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[1]['username']}        ${userAM}
	Should Be Equal As Strings     ${showadmin[1]['role']}            AdminManager
	Should Be Empty                ${showadmin[2]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[2]['username']}        ${userAC}
	Should Be Equal As Strings     ${showadmin[2]['role']}            AdminContributor
	Should Be Empty                ${showadmin[3]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[3]['username']}        ${userAV}
	Should Be Equal As Strings     ${showadmin[3]['role']}            AdminViewer
	Should Be Empty                ${showadmin[4]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[4]['username']}        ${userDM}
	Should Be Equal As Strings     ${showadmin[4]['role']}            DeveloperManager
	Should Be Empty                ${showadmin[5]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[5]['username']}        ${userDC}
	Should Be Equal As Strings     ${showadmin[5]['role']}            DeveloperContributor
	Should Be Empty                ${showadmin[6]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[6]['username']}        ${userDV}
	Should Be Equal As Strings     ${showadmin[6]['role']}            DeveloperViewer
	Should Be Empty                ${showadmin[7]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[7]['username']}        ${userOM}
	Should Be Equal As Strings     ${showadmin[7]['role']}            OperatorManager
	Should Be Empty                ${showadmin[8]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[8]['username']}        ${userOC}
	Should Be Equal As Strings     ${showadmin[8]['role']}            OperatorContributor
	Should Be Empty                ${showadmin[9]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[9]['username']}        ${userOV}
	Should Be Equal As Strings     ${showadmin[9]['role']}            OperatorViewer
	
MC - A user shall be able to assign a user role to an org they created
	[Documentation]
	...  a user can assign a user role to an org 
	...  verify the roles returned

	${orgname}=   Create Org        orgname=${orgname}       token=${userToken}      
	${adduser}=   Adduser Role   orgname=${orgname}   username=myuser   role=DeveloperManager    token=${userToken}     use_defaults=${False}
	${showadmin}=   Show Role Assignment   token=${adminToken}
	${showuser}=    Show Role Assignment   token=${userToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Equal As Strings     ${showadmin[1]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[1]['username']}        myuser
	Should Be Equal As Strings     ${showadmin[1]['role']}            DeveloperManager

	Should Be Equal As Strings     ${showuser[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser[0]['username']}         myuser 
	Should Be Equal As Strings     ${showuser[0]['role']}             DeveloperManager
	
MC - DeveloperManager shall be able to assign all Developer roles to users
	[Documentation]
	...  developer manager  user can assign all user roles to users
	...  verify the roles returned

	${userDM}    ${passwordDM}    ${emailDM}=    Create User
	${userDC}    ${passwordDC}    ${emailDC}=    Create User    
	${userDV}    ${passwordDV}    ${emailDV}=    Create User 
	${user1Token}=   Login   ${userDM}    ${passwordDM}
	${user2Token}=   Login   ${userDC}    ${passwordDC}
	${user3Token}=   Login   ${userDV}    ${passwordDV}
	${orgname}=      Create Org        orgname=${orgname}       token=${userToken}      
	${adduser}=      Adduser Role     orgname=${orgname}    username=${userDM}    role=DeveloperManager        token=${userToken}     use_defaults=${False}
	${adduser}=      Adduser Role     orgname=${orgname}    username=${userDC}    role=DeveloperContributor    token=${userToken}     use_defaults=${False}
	${adduser}=      Adduser Role     orgname=${orgname}    username=${userDV}    role=DeveloperViewer         token=${userToken}     use_defaults=${False}	
	${showuser}=     Show Role Assignment   token=${userToken}
	${showuser1}=    Show Role Assignment   token=${user1Token}
	${showuser2}=    Show Role Assignment   token=${user2Token}
	${showuser3}=    Show Role Assignment   token=${user3Token}

	Should Be Equal As Strings     ${showuser[0]['org']}               ${orgname}
	Should Be Equal As Strings     ${showuser[0]['username']}          myuser 
	Should Be Equal As Strings     ${showuser[0]['role']}              DeveloperManager
	Should Be Equal As Strings     ${showuser1[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser1[0]['username']}         ${userDM} 
	Should Be Equal As Strings     ${showuser1[0]['role']}             DeveloperManager
	Should Be Equal As Strings     ${showuser2[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser2[0]['username']}         ${userDC}
	Should Be Equal As Strings     ${showuser2[0]['role']}             DeveloperContributor
	Should Be Equal As Strings     ${showuser3[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser3[0]['username']}         ${userDV} 
	Should Be Equal As Strings     ${showuser3[0]['role']}             DeveloperViewer
	
MC - OperatorManager shall be able to assign all Operator roles to users	
	[Documentation]
	...  operator manager user can assign all operator roles to users
	...  verify the roles returned

	${userOM}    ${passwordOM}    ${emailOM}=    Create User
	${userOC}    ${passwordOC}    ${emailOC}=    Create User    
	${userOV}    ${passwordOV}    ${emailOV}=    Create User 
	${user1Token}=   Login   ${userOM}    ${passwordOM}
	${user2Token}=   Login   ${userOC}    ${passwordOC}
	${user3Token}=   Login   ${userOV}    ${passwordOV}
	${orgname}=      Create Org       orgname=${orgname}    orgtype=operator      token=${userToken}      
	${adduser}=      Adduser Role     orgname=${orgname}    username=${userOM}    role=OperatorManager        token=${userToken}     use_defaults=${False}
	${adduser}=      Adduser Role     orgname=${orgname}    username=${userOC}    role=OperatorContributor    token=${userToken}     use_defaults=${False}
	${adduser}=      Adduser Role     orgname=${orgname}    username=${userOV}    role=OperatorViewer         token=${userToken}     use_defaults=${False}	
	${showuser}=     Show Role Assignment   token=${userToken}
	${showuser1}=    Show Role Assignment   token=${user1Token}
	${showuser2}=    Show Role Assignment   token=${user2Token}
	${showuser3}=    Show Role Assignment   token=${user3Token}

	Should Be Equal As Strings     ${showuser[0]['org']}               ${orgname}
	Should Be Equal As Strings     ${showuser[0]['username']}          myuser 
	Should Be Equal As Strings     ${showuser[0]['role']}              OperatorManager
	Should Be Equal As Strings     ${showuser1[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser1[0]['username']}         ${userOM} 
	Should Be Equal As Strings     ${showuser1[0]['role']}             OperatorManager
	Should Be Equal As Strings     ${showuser2[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser2[0]['username']}         ${userOC}
	Should Be Equal As Strings     ${showuser2[0]['role']}             OperatorContributor
	Should Be Equal As Strings     ${showuser3[0]['org']}              ${orgname}
	Should Be Equal As Strings     ${showuser3[0]['username']}         ${userOV} 
	Should Be Equal As Strings     ${showuser3[0]['role']}             OperatorViewer
	
MC - Assign a user role to a user without a token
	[Documentation]
	...  assign a user role to a user without a token 
	...  verify the roles returned

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - Assign a user role to a user with an empty token
	[Documentation]
	...  assign a user role to a user with an empty token 
	...  verify the roles returned

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       token=${EMPTY}      use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"no token found"}

MC - Assign a user role to a user with a bad token
	[Documentation]
	...  assign a user role to a user with a bad token 
	...  verify the roles returned

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       token=thisisabadtoken    use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

MC - Assign a user role to a user with an expired token
	[Documentation]
	...  assign a user role to a user with an expired token 
	...  verify the roles returned

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       token=${expToken}       use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}

*** Keywords ***
Setup
        ${epoch}=  Get Current Date  result_format=epoch
	${adminToken}=   Login Mexadmin
        ${orgname}=  Set Variable  ${orgname}${epoch}
	#Create User  username=myuser   password=${password}   email_address=xy@xy.com
        #Unlock User
	#${userToken}=  Login  username=myuser  password=${password}
        ${userToken}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
        Set Suite Variable  ${adminToken}
	Set Suite Variable  ${userToken}
        Set Suite Variable  ${orgname}
