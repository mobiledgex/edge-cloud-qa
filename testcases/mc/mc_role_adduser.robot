*** Settings ***
Documentation   MasterController Assign Roles

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
# ECQ-3372
MC - Admin user shall be able show role assignments with no assignments
	[Documentation]
	...  - admin user can show role assignments with no assignments
	...  - verify the roles returned

	${showadmin}=   Show Role Assignment   token=${adminToken}

        Should Be True  len(@{showadmin}) > 0

        FOR  ${role}  IN  @{showadmin}	
	    Should Be True  '${role['role']}' == 'AdminManager' or '${role['role']}' == 'OperatorManager' or '${role['role']}' == 'OperatorContributor' or '${role['role']}' == 'OperatorViewer' or '${role['role']}' == 'DeveloperManager' or '${role['role']}' == 'DeveloperContributor' or '${role['role']}' == 'DeveloperViewer' 
        END

#MC - Admin user shall be able to assign a user role to an org
#	[Documentation]
#	...  admin user can assign a user role to an org 
#	...  verify the roles returned
#
#	${orgname}=   Create Org        orgname=${orgname}       token=${adminToken}      
#	${adduser}=   Adduser Role   orgname=${orgname}   username=${dev_manager_user_automation}   role=DeveloperManager    token=${adminToken}     use_defaults=${False}
#	${showadmin}=   Show Role Assignment   token=${adminToken}
#	${showuser}=    Show Role Assignment   token=${userToken}
#
#        ${found}=  Set Variable  ${False} 
#        FOR  ${role}  IN  @{showadmin}
#            ${found}=  Run Keyword If  '${role['role']}' == 'DeveloperManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_manager_user_automation}'  Set Variable  ${True}
#            ...   ELSE  Set Variable  ${found}
#        END
#        Should Be True  ${found}
#	
#	Should Be Equal As Strings     ${showuser[0]['org']}              ${orgname}
#	Should Be Equal As Strings     ${showuser[0]['username']}         ${dev_manager_user_automation}
#	Should Be Equal As Strings     ${showuser[0]['role']}             DeveloperManager
#	
#MC - Admin user shall be able to assign a manager user role to an org
#	[Documentation]
#	...  admin user can assign a user role to an org 
#	...  verify the roles returned
#
#	${orgname}=   Create Org        orgname=${orgname}       token=${adminToken}      
#	${adduser}=   Adduser Role   orgname=${orgname}   username=myuser   role=DeveloperManager    token=${adminToken}     use_defaults=${False}
#	${showadmin}=   Show Role Assignment   token=${adminToken}
#	${showuser}=    Show Role Assignment   token=${userToken}
#
#        ${found_manager}=  Set Variable  ${False}
#        ${found_contributor}=  Set Variable  ${False}
#        ${found_viewer}=  Set Variable  ${False}
#
#        FOR  ${role}  IN  @{showadmin}
#            ${found_manager}=  Run Keyword If  '${role['role']}' == 'DeveloperManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_manager_user_automation}'  Set Variable  ${True}
#            ...   ELSE  Set Variable  ${found_manager}
#        END
#        Should Be True  ${found_manager}
#	
#	Should Be Equal As Strings     ${showuser[0]['org']}              ${orgname}
#	Should Be Equal As Strings     ${showuser[0]['username']}         myuser 
#	Should Be Equal As Strings     ${showuser[0]['role']}             DeveloperManager

# ECQ-3373	
MC - Admin user shall be able to assign Developer user roles to a developer org
	[Documentation]
	...  - admin user can assign developer user roles to a developer org
	...  - verify the roles returned

	#${userC}    ${passwordC}    ${emailC}=    Create User    
	#${userV}    ${passwordV}    ${emailV}=    Create User 
	${orgname}=     Create Org  orgname=${orgname}  orgtype=developer  token=${adminToken}      
        ${adduser}=     Adduser Role   orgname=${orgname}   username=${dev_viewer_user_automation}       role=DeveloperViewer         token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role   orgname=${orgname}   username=${dev_manager_user_automation}      role=DeveloperManager        token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role   orgname=${orgname}   username=${dev_contributor_user_automation}  role=DeveloperContributor    token=${adminToken}     use_defaults=${False}
	${showadmin}=   Show Role Assignment   token=${adminToken}
        ${showuser_manager}=    Show Role Assignment   token=${userToken_devmanager}
        ${showuser_contributor}=    Show Role Assignment   token=${userToken_devcontributor}
        ${showuser_viewer}=    Show Role Assignment   token=${userToken_devviewer}

        ${found_manager}=  Set Variable  ${False}
        ${found_contributor}=  Set Variable  ${False}
        ${found_viewer}=  Set Variable  ${False}

        FOR  ${role}  IN  @{showadmin}
            ${found_manager}=  Run Keyword If  '${role['role']}' == 'DeveloperManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_manager_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_manager}
            ${found_contributor}=  Run Keyword If  '${role['role']}' == 'DeveloperContributor' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_contributor_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_contributor}
            ${found_viewer}=  Run Keyword If  '${role['role']}' == 'DeveloperViewer' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_viewer_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_viewer}
        END
        Should Be True  ${found_manager}
        Should Be True  ${found_contributor}
        Should Be True  ${found_viewer}

        ${found_user_manager}=  Set Variable  ${False}
        ${found_user_contributor}=  Set Variable  ${False}
        ${found_user_viewer}=  Set Variable  ${False}
        FOR  ${role}  IN  @{showuser_manager}	
            ${found_user_manager}=  Run Keyword If  '${role['role']}' == 'DeveloperManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_manager_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_manager}
        END
        FOR  ${role}  IN  @{showuser_contributor}
            ${found_user_contributor}=  Run Keyword If  '${role['role']}' == 'DeveloperContributor' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_contributor_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_contributor}
        END
        FOR  ${role}  IN  @{showuser_viewer}
            ${found_user_viewer}=  Run Keyword If  '${role['role']}' == 'DeveloperViewer' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_viewer_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_viewer}
        END
        Should Be True  ${found_user_manager}
        Should Be True  ${found_user_contributor}
        Should Be True  ${found_user_viewer}

# ECQ-3374	
MC - Admin user shall be able to assign Operator user roles to a operator org
	[Documentation]
	...  - admin user can assign operator user roles to an operator org
	...  - verify the roles returned

#	${userC}    ${passwordC}    ${emailC}=    Create User    
#	${userV}    ${passwordV}    ${emailV}=    Create User 
	${orgname}=     Create Org     orgname=${orgname}   orgtype=operator    token=${adminToken}      
	${adduser}=     Adduser Role   orgname=${orgname}   username=${op_manager_user_automation}     role=OperatorManager        token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role   orgname=${orgname}   username=${op_contributor_user_automation}   role=OperatorContributor    token=${adminToken}     use_defaults=${False}
	${adduser}=     Adduser Role   orgname=${orgname}   username=${op_viewer_user_automation}   role=OperatorViewer         token=${adminToken}     use_defaults=${False}	
	${showadmin}=   Show Role Assignment   token=${adminToken}
        ${showadmin}=   Show Role Assignment   token=${adminToken}
        ${showuser_manager}=    Show Role Assignment   token=${userToken_opmanager}
        ${showuser_contributor}=    Show Role Assignment   token=${userToken_opcontributor}
        ${showuser_viewer}=    Show Role Assignment   token=${userToken_opviewer}
	
        ${found_manager}=  Set Variable  ${False}
        ${found_contributor}=  Set Variable  ${False}
        ${found_viewer}=  Set Variable  ${False}

        FOR  ${role}  IN  @{showadmin}
            ${found_manager}=  Run Keyword If  '${role['role']}' == 'OperatorManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_manager_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_manager}
            ${found_contributor}=  Run Keyword If  '${role['role']}' == 'OperatorContributor' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_contributor_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_contributor}
            ${found_viewer}=  Run Keyword If  '${role['role']}' == 'OperatorViewer' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_viewer_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_viewer}
        END
        Should Be True  ${found_manager}
        Should Be True  ${found_contributor}
        Should Be True  ${found_viewer}

        ${found_user_manager}=  Set Variable  ${False}
        ${found_user_contributor}=  Set Variable  ${False}
        ${found_user_viewer}=  Set Variable  ${False}
        FOR  ${role}  IN  @{showuser_manager}
            ${found_user_manager}=  Run Keyword If  '${role['role']}' == 'OperatorManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_manager_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_manager}
        END
        FOR  ${role}  IN  @{showuser_contributor}
            ${found_user_contributor}=  Run Keyword If  '${role['role']}' == 'OperatorContributor' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_contributor_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_contributor}
        END
        FOR  ${role}  IN  @{showuser_viewer}
            ${found_user_viewer}=  Run Keyword If  '${role['role']}' == 'OperatorViewer' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_viewer_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_viewer}
        END
        Should Be True  ${found_user_manager}
        Should Be True  ${found_user_contributor}
        Should Be True  ${found_user_viewer}
	
#MC - Admin user shall be able to assign all user roles to users
#	[Documentation]
#	...  admin user can assign all user roles to users
#	...  verify the roles returned
#
#	${userAM}    ${passwordAM}    ${emailAM}=    Create User
#	${userAC}    ${passwordAC}    ${emailAC}=    Create User    
#	${userAV}    ${passwordAV}    ${emailAV}=    Create User 
#	${userDM}    ${passwordDM}    ${emailDM}=    Create User
#	${userDC}    ${passwordDC}    ${emailDC}=    Create User    
#	${userDV}    ${passwordDV}    ${emailDV}=    Create User 
#	${userOM}    ${passwordOM}    ${emailOM}=    Create User
#	${userOC}    ${passwordOC}    ${emailOC}=    Create User    
#	${userOV}    ${passwordOV}    ${emailOV}=    Create User 
#	${adduser}=     Adduser Role     username=${userAM}    role=AdminManager            token=${adminToken}     use_defaults=${False}
#	${adduser}=     Adduser Role     username=${userAC}    role=AdminContributor        token=${adminToken}     use_defaults=${False}
#	${adduser}=     Adduser Role     username=${userAV}    role=AdminViewer             token=${adminToken}     use_defaults=${False}	
#	${adduser}=     Adduser Role     username=${userDM}    role=DeveloperManager        token=${adminToken}     use_defaults=${False}
#	${adduser}=     Adduser Role     username=${userDC}    role=DeveloperContributor    token=${adminToken}     use_defaults=${False}
#	${adduser}=     Adduser Role     username=${userDV}    role=DeveloperViewer         token=${adminToken}     use_defaults=${False}	
#	${adduser}=     Adduser Role     username=${userOM}    role=OperatorManager         token=${adminToken}     use_defaults=${False}
#	${adduser}=     Adduser Role     username=${userOC}    role=OperatorContributor     token=${adminToken}     use_defaults=${False}
#	${adduser}=     Adduser Role     username=${userOV}    role=OperatorViewer          token=${adminToken}     use_defaults=${False}	
#	${showadmin}=   Show Role Assignment   token=${adminToken}
#	
#	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
#	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
#	Should Be Empty                ${showadmin[1]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[1]['username']}        ${userAM}
#	Should Be Equal As Strings     ${showadmin[1]['role']}            AdminManager
#	Should Be Empty                ${showadmin[2]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[2]['username']}        ${userAC}
#	Should Be Equal As Strings     ${showadmin[2]['role']}            AdminContributor
#	Should Be Empty                ${showadmin[3]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[3]['username']}        ${userAV}
#	Should Be Equal As Strings     ${showadmin[3]['role']}            AdminViewer
#	Should Be Empty                ${showadmin[4]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[4]['username']}        ${userDM}
#	Should Be Equal As Strings     ${showadmin[4]['role']}            DeveloperManager
#	Should Be Empty                ${showadmin[5]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[5]['username']}        ${userDC}
#	Should Be Equal As Strings     ${showadmin[5]['role']}            DeveloperContributor
#	Should Be Empty                ${showadmin[6]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[6]['username']}        ${userDV}
#	Should Be Equal As Strings     ${showadmin[6]['role']}            DeveloperViewer
#	Should Be Empty                ${showadmin[7]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[7]['username']}        ${userOM}
#	Should Be Equal As Strings     ${showadmin[7]['role']}            OperatorManager
#	Should Be Empty                ${showadmin[8]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[8]['username']}        ${userOC}
#	Should Be Equal As Strings     ${showadmin[8]['role']}            OperatorContributor
#	Should Be Empty                ${showadmin[9]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[9]['username']}        ${userOV}
#	Should Be Equal As Strings     ${showadmin[9]['role']}            OperatorViewer
	
#MC - A user shall be able to assign a user role to an org they created
#	[Documentation]
#	...  a user can assign a user role to an org 
#	...  verify the roles returned
#
#	${orgname}=   Create Org        orgname=${orgname}       token=${userToken}      
#	${adduser}=   Adduser Role   orgname=${orgname}   username=myuser   role=DeveloperManager    token=${userToken}     use_defaults=${False}
#	${showadmin}=   Show Role Assignment   token=${adminToken}
#	${showuser}=    Show Role Assignment   token=${userToken}
#	
#	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
#	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
#	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
#	Should Be Equal As Strings     ${showadmin[1]['org']}             ${orgname}
#	Should Be Equal As Strings     ${showadmin[1]['username']}        myuser
#	Should Be Equal As Strings     ${showadmin[1]['role']}            DeveloperManager
#
#	Should Be Equal As Strings     ${showuser[0]['org']}              ${orgname}
#	Should Be Equal As Strings     ${showuser[0]['username']}         myuser 
#	Should Be Equal As Strings     ${showuser[0]['role']}             DeveloperManager

# ECQ-3375	
MC - DeveloperManager shall be able to assign all Developer roles to users
	[Documentation]
	...  - developer manager user can assign all user roles to users
	...  - verify the roles returned

#	${userDM}    ${passwordDM}    ${emailDM}=    Create User
#	${userDC}    ${passwordDC}    ${emailDC}=    Create User    
#	${userDV}    ${passwordDV}    ${emailDV}=    Create User 
#	${user1Token}=   Login   ${userDM}    ${passwordDM}
#	${user2Token}=   Login   ${userDC}    ${passwordDC}
#	${user3Token}=   Login   ${userDV}    ${passwordDV}
	${orgname}=      Create Org        orgname=${orgname}       token=${userToken_devmanager}      
	${adduser}=      Adduser Role     orgname=${orgname}    username=${op_manager_user_automation}    role=DeveloperManager        token=${userToken_devmanager}     use_defaults=${False}
	${adduser}=      Adduser Role     orgname=${orgname}    username=${dev_contributor_user_automation}    role=DeveloperContributor    token=${userToken_devmanager}     use_defaults=${False}
	${adduser}=      Adduser Role     orgname=${orgname}    username=${dev_viewer_user_automation}    role=DeveloperViewer         token=${userToken_devmanager}     use_defaults=${False}	
	${showadmin}=     Show Role Assignment   token=${userToken_devmanager}
	${showuser_manager}=    Show Role Assignment   token=${userToken_opmanager}
	${showuser_contributor}=    Show Role Assignment   token=${userToken_devcontributor}
	${showuser_viewer}=    Show Role Assignment   token=${userToken_devviewer}

        ${found_manager}=  Set Variable  ${False}
        #${found_contributor}=  Set Variable  ${False}
        #${found_viewer}=  Set Variable  ${False}

        FOR  ${role}  IN  @{showadmin}
            ${found_manager}=  Run Keyword If  '${role['role']}' == 'DeveloperManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_manager_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_manager}
        END
        Should Be True  ${found_manager}
        #Should Be True  ${found_contributor}
        #Should Be True  ${found_viewer}

        ${found_user_manager}=  Set Variable  ${False}
        ${found_user_contributor}=  Set Variable  ${False}
        ${found_user_viewer}=  Set Variable  ${False}
        FOR  ${role}  IN  @{showuser_manager}
            ${found_user_manager}=  Run Keyword If  '${role['role']}' == 'DeveloperManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_manager_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_manager}
        END
        FOR  ${role}  IN  @{showuser_contributor}
            ${found_user_contributor}=  Run Keyword If  '${role['role']}' == 'DeveloperContributor' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_contributor_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_contributor}
        END
        FOR  ${role}  IN  @{showuser_viewer}
            ${found_user_viewer}=  Run Keyword If  '${role['role']}' == 'DeveloperViewer' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_viewer_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_viewer}
        END
        Should Be True  ${found_user_manager}
        Should Be True  ${found_user_contributor}
        Should Be True  ${found_user_viewer}

# ECQ-3376
MC - OperatorManager shall be able to assign all Operator roles to users	
	[Documentation]
	...  - operator manager user can assign all operator roles to users
	...  - verify the roles returned

#	${userOM}    ${passwordOM}    ${emailOM}=    Create User
#	${userOC}    ${passwordOC}    ${emailOC}=    Create User    
#	${userOV}    ${passwordOV}    ${emailOV}=    Create User 
#	${user1Token}=   Login   ${userOM}    ${passwordOM}
#	${user2Token}=   Login   ${userOC}    ${passwordOC}
#	${user3Token}=   Login   ${userOV}    ${passwordOV}
	${orgname}=      Create Org       orgname=${orgname}    orgtype=operator      token=${userToken_opmanager}      
	${adduser}=      Adduser Role     orgname=${orgname}    username=${dev_manager_user_automation}    role=OperatorManager        token=${userToken_opmanager}     use_defaults=${False}
	${adduser}=      Adduser Role     orgname=${orgname}    username=${op_contributor_user_automation}    role=OperatorContributor    token=${userToken_opmanager}     use_defaults=${False}
	${adduser}=      Adduser Role     orgname=${orgname}    username=${op_viewer_user_automation}    role=OperatorViewer         token=${userToken_opmanager}     use_defaults=${False}	
	${showadmin}=     Show Role Assignment   token=${userToken_opmanager}
	${showuser_manager}=    Show Role Assignment   token=${userToken_devmanager}
	${showuser_contributor}=    Show Role Assignment   token=${userToken_opcontributor}
	${showuser_viewer}=    Show Role Assignment   token=${userToken_opviewer}

        ${found_manager}=  Set Variable  ${False}

        FOR  ${role}  IN  @{showadmin}
            ${found_manager}=  Run Keyword If  '${role['role']}' == 'OperatorManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_manager_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_manager}
        END
        Should Be True  ${found_manager}

        ${found_user_manager}=  Set Variable  ${False}
        ${found_user_contributor}=  Set Variable  ${False}
        ${found_user_viewer}=  Set Variable  ${False}
        FOR  ${role}  IN  @{showuser_manager}
            ${found_user_manager}=  Run Keyword If  '${role['role']}' == 'OperatorManager' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${dev_manager_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_manager}
        END
        FOR  ${role}  IN  @{showuser_contributor}
            ${found_user_contributor}=  Run Keyword If  '${role['role']}' == 'OperatorContributor' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_contributor_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_contributor}
        END
        FOR  ${role}  IN  @{showuser_viewer}
            ${found_user_viewer}=  Run Keyword If  '${role['role']}' == 'OperatorViewer' and '${role['org']}' == '${orgname}' and '${role['username']}' == '${op_viewer_user_automation}'  Set Variable  ${True}
            ...   ELSE  Set Variable  ${found_user_viewer}
        END
        Should Be True  ${found_user_manager}
        Should Be True  ${found_user_contributor}
        Should Be True  ${found_user_viewer}

# ECQ-3377	
MC - Assign a user role to a user without a token
	[Documentation]
	...  - assign a user role to a user without a token 
	...  - verify error is returned

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"No bearer token found"}

# ECQ-3378
MC - Assign a user role to a user with an empty token
	[Documentation]
	...  - assign a user role to a user with an empty token 
	...  - verify error is returned

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       token=${EMPTY}      use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  400	
	Should Be Equal             ${body}         {"message":"No bearer token found"}

# ECQ-3379
MC - Assign a user role to a user with a bad token
	[Documentation]
	...  - assign a user role to a user with a bad token 
	...  - verify error is returned

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       token=thisisabadtoken    use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"Invalid or expired jwt"}

# ECQ-3380
MC - Assign a user role to a user with an expired token
	[Documentation]
	...  - assign a user role to a user with an expired token 
	...  - verify error is returned

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       token=${expToken}       use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"Invalid or expired jwt"}

*** Keywords ***
Setup
        ${epoch}=  Get Current Date  result_format=epoch
	${adminToken}=   Login Mexadmin
        ${orgname}=  Set Variable  myorg${epoch}
	#Create User  username=myuser   password=${password}   email_address=xy@xy.com
        #Unlock User
	#${userToken}=  Login  username=myuser  password=${password}
        ${userToken_devmanager}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}
        ${userToken_devviewer}=  Login  username=${dev_viewer_user_automation}  password=${dev_viewer_password_automation}
        ${userToken_devcontributor}=  Login  username=${dev_contributor_user_automation}  password=${dev_contributor_password_automation}
        ${userToken_opmanager}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}
        ${userToken_opviewer}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}
        ${userToken_opcontributor}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

        Set Suite Variable  ${adminToken}
	Set Suite Variable  ${userToken_devmanager}
        Set Suite Variable  ${userToken_devviewer}
        Set Suite Variable  ${userToken_devcontributor}
        Set Suite Variable  ${userToken_opmanager}
        Set Suite Variable  ${userToken_opviewer}
        Set Suite Variable  ${userToken_opcontributor}

        Set Suite Variable  ${orgname}
