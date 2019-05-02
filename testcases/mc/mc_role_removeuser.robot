*** Settings ***
Documentation   MasterController New User Login

Library		MexMasterController  root_cert=%{AUTOMATION_MC_CERT}
Library         Collections

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   mex1234567
${orgname}=    TheAdminOrg
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw

*** Test Cases ***
MC - Admin remove an AdminManager role from a user 
	[Documentation]
	...  admin remove an adminmanager role from a user  
	...  verify the message returned 

        Adduser Role     username=myuser         role=AdminManager        token=${adminToken}        use_defaults=${False}
	${showadmin}=    Show Role Assignment    token=${adminToken}
	${admin}=        Removeuser Role         token=${adminToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Empty                ${showadmin[1]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[1]['username']}        myuser 
	Should Be Equal As Strings     ${showadmin[1]['role']}            AdminManager
	
	Should Be Equal As Strings     ${admin}        {"message":"Role removed from user"}

MC - Admin remove an AdminCondtributor role from a user 
	[Documentation]
	...  admin remove an admincontributor role from a user  
	...  verify the message returned 

        Adduser Role     username=myuser         role=AdminContributor        token=${adminToken}        use_defaults=${False}
	${showadmin}=    Show Role Assignment    token=${adminToken}
	${admin}=        Removeuser Role         token=${adminToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Empty                ${showadmin[1]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[1]['username']}        myuser 
	Should Be Equal As Strings     ${showadmin[1]['role']}            AdminContributor
	
	Should Be Equal As Strings     ${admin}        {"message":"Role removed from user"}

MC - Admin remove an AdminViewer role from a user 
	[Documentation]
	...  admin remove an adminviewer role from a user  
	...  verify the message returned 

        Adduser Role     username=myuser         role=AdminViewer        token=${adminToken}        use_defaults=${False}
	${showadmin}=    Show Role Assignment    token=${adminToken}
	${admin}=        Removeuser Role         token=${adminToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Empty                ${showadmin[1]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[1]['username']}        myuser 
	Should Be Equal As Strings     ${showadmin[1]['role']}            AdminViewer
	
	Should Be Equal As Strings     ${admin}        {"message":"Role removed from user"}

MC - Admin remove an DeveloperManager role from a user 
	[Documentation]
	...  admin remove an developermanager role from a user  
	...  verify the message returned 

        Create Org       orgname=${orgname}      
        Adduser Role     orgname=${orgname}      username=myuser         role=DeveloperManager        token=${adminToken}        use_defaults=${False}
	${showadmin}=    Show Role Assignment    token=${adminToken}
	${admin}=        Removeuser Role         token=${adminToken}
	
	Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	Should Be Equal As Strings     ${showadmin[1]['org']}             ${orgname}
	Should Be Equal As Strings     ${showadmin[1]['username']}        myuser 
	Should Be Equal As Strings     ${showadmin[1]['role']}            DeveloperManager
	
	Should Be Equal As Strings     ${admin}        {"message":"Role removed from user"}

MC - Remove a user role from a user with a bad token
	[Documentation]
	...  remove a user role from a user with a bad token 
	...  verify the roles returned 

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       token=thisisabadtoken    use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}




*** Keywords ***
Setup
	${adminToken}=   Login
	Create User  username=myuser   password=${password}   email=xy@xy.com
	${userToken}=  Login  username=myuser  password=${password}
        Set Suite Variable  ${adminToken}
	Set Suite Variable  ${userToken}
