*** Settings ***
Documentation   MasterController RemoveUser Role 

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         Collections

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}
${username}=   mextester06
${password}=   ${mextester06_gmail_password}
${email}=      mextester06@gmail.com
${orgname}=    TheAdminOrg
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw

*** Test Cases ***
# ECQ-1294
MC - Admin remove an AdminManager role from a user 
	[Documentation]
	...  admin remove an adminmanager role from a user  
	...  verify the message returned 

        Adduser Role     username=${epochusername}         role=AdminManager        token=${adminToken}        use_defaults=${False}
	${showadmin}=    Show Role Assignment    token=${adminToken}
	${admin}=        Removeuser Role         token=${adminToken}

        FOR  ${role}  IN  @{showadmin}
           Log to console  ${role['username']}  ${username}
           Run Keyword if  '${role['username']}' == '${username}'  Role Should Be Equal  ${role}  ${username}  ${EMPTY}  AdminManager
        END
	
	#Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	#Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	#Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	#Should Be Empty                ${showadmin[1]['org']}             ${EMPTY}
	#Should Be Equal As Strings     ${showadmin[1]['username']}        myuser 
	#Should Be Equal As Strings     ${showadmin[1]['role']}            AdminManager
	
	Should Be Equal As Strings     ${admin}        {"message":"Role removed from user"}

# ECQ-1295
MC - Admin remove an AdminContributor role from a user 
	[Documentation]
	...  admin remove an admincontributor role from a user  
	...  verify the message returned 

        Adduser Role     username=${epochusername}         role=AdminContributor        token=${adminToken}        use_defaults=${False}
	${showadmin}=    Show Role Assignment    token=${adminToken}
	${admin}=        Removeuser Role         token=${adminToken}

        FOR  ${role}  IN  @{showadmin}
           Log to console  ${role['username']}  ${username}
           Run Keyword if  '${role['username']}' == '${username}'  Role Should Be Equal  ${role}  ${username}  ${EMPTY}  AdminContributor
        END
	
	#Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	#Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	#Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	#Should Be Empty                ${showadmin[1]['org']}             ${EMPTY}
	#Should Be Equal As Strings     ${showadmin[1]['username']}        myuser 
	#Should Be Equal As Strings     ${showadmin[1]['role']}            AdminContributor
	
	Should Be Equal As Strings     ${admin}        {"message":"Role removed from user"}

# ECQ-1296
MC - Admin remove an AdminViewer role from a user 
	[Documentation]
	...  admin remove an adminviewer role from a user  
	...  verify the message returned 

        Adduser Role     username=${epochusername}         role=AdminViewer        token=${adminToken}        use_defaults=${False}
	${showadmin}=    Show Role Assignment    token=${adminToken}
	${admin}=        Removeuser Role         token=${adminToken}

        FOR  ${role}  IN  @{showadmin}
           Log to console  ${role['username']}  ${username}
           Run Keyword if  '${role['username']}' == '${username}'  Role Should Be Equal  ${role}  ${username}  ${EMPTY}  AdminViewer 
        END

	#Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	#Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	#Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	#Should Be Empty                ${showadmin[1]['org']}             ${EMPTY}
	#Should Be Equal As Strings     ${showadmin[1]['username']}        myuser 
	#Should Be Equal As Strings     ${showadmin[1]['role']}            AdminViewer
	
	Should Be Equal As Strings     ${admin}        {"message":"Role removed from user"}

# ECQ-3365
MC - Admin remove an DeveloperManager role from a user 
	[Documentation]
	...  - admin remove an developermanager role from a user  
	...  - verify the message returned 

        Create Org       orgname=${orgname}      
        Adduser Role     orgname=${orgname}      username=${epochusername}         role=DeveloperManager        token=${adminToken}        use_defaults=${False}
	${showadmin}=    Show Role Assignment    token=${adminToken}
	${admin}=        Removeuser Role         token=${adminToken}

        FOR  ${role}  IN  @{showadmin}
           Log to console  ${role['username']}  ${username}
           Run Keyword if  '${role['username']}' == '${username}'  Role Should Be Equal  ${role}  ${username}  ${orgname}  DeveloperManager 
        END
	
	#Should Be Empty                ${showadmin[0]['org']}             ${EMPTY}
	#Should Be Equal As Strings     ${showadmin[0]['username']}        mexadmin 
	#Should Be Equal As Strings     ${showadmin[0]['role']}            AdminManager
	#Should Be Equal As Strings     ${showadmin[1]['org']}             ${orgname}
	#Should Be Equal As Strings     ${showadmin[1]['username']}        myuser 
	#Should Be Equal As Strings     ${showadmin[1]['role']}            DeveloperManager
	
	Should Be Equal As Strings     ${admin}        {"message":"Role removed from user"}

# ECQ-3387
MC - Remove a user role from a user with a bad token
	[Documentation]
	...  - remove a user role from a user with a bad token 
	...  - verify the roles returned 

	${error_msg}=  Run Keyword and Expect Error  *  Adduser Role     username=myuser    role=AdminManager       token=thisisabadtoken    use_defaults=${False}

	${status_code}=  Response Status Code
	${body}=         Response Body

	Should Be Equal As Numbers  ${status_code}  401	
	Should Be Equal             ${body}         {"message":"invalid or expired jwt"}




*** Keywords ***
Setup
        ${epoch}=  Get Time  epoch
        ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
        ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

	${adminToken}=   Login  username=${username_admin}  password=${password_admin}
	Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
        Unlock User
        ${orgname}=  Set Variable  ${orgname}${epoch}
        #Verify Email  email_address=${email}
	#${userToken}=  Login  username=${username}  password=${password}
        Set Suite Variable  ${adminToken}
	#Set Suite Variable  ${userToken}
        Set Suite Variable  ${epochusername} 
        Set Suite Variable  ${orgname}

Role Should Be Equal
   [Arguments]  ${role_data}  ${username}  ${org}  ${role}
   Should Be Equal  ${role_data['username']}  ${username}
   Should Be Equal  ${role_data['org']}       ${org}
   Should Be Equal  ${role_data['role']}      ${role}
 
