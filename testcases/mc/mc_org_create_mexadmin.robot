*** Settings ***
Documentation   MasterController Org Create as Admin
	
Library		MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw
${dev_orgname}=    DevOrg
${op_orgname}=     OperOrg

${username}=  mextester06
${password}=  ${mextester06_gmail_password}
${mex_password}=  ${mexadmin_password}
	
*** Test Cases ***
#MC - Show org with admin user no orgs created
#	[Documentation]	
#	...  admin user can show orgs 
#	...  verify the orgs returned
#
#	${org}=  Show Organizations  token=${adminToken}
#	
#	Should Be Empty    ${org}

MC - Admin shall not be able to add an Admin org 
	[Documentation]
	...  admin user can create an Admin org 
	...  verify the correct error message is  returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=admin    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Organization type must be developer, or operator"}

MC - Admin shall be able to add a developer org
	[Documentation]
	...  admin user can create an developer org 
	...  verify the orgs returned
        
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	#Should Be Equal               ${body}         {"message":"Organization created","name":"${dev_orgname}"}
        Should Be Equal               ${body}         {"message":"Organization created"}

	${orgs}=  Show Organizations   token=${adminToken}

        ${found}=  Set Variable  ${False}
        : FOR  ${org}  IN  @{orgs}
        \  ${found}=  Run Keyword And Return Status  Should Be Equal  ${org['Name']}  ${dev_orgname}
        \  Exit For Loop If  ${found}

        Should Be Equal       ${org["Name"]}                   ${dev_orgname}
	Should Be Equal       ${org["Type"]}                   developer
	Should Be Equal       ${org["Address"]}                222 somewhere dr
	Should Be Equal       ${org["Phone"]}                  111-222-3333
	#Should Be Equal       ${org["AdminUsername"]}          mexadmin
	Convert Date          ${org["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - Admin shall be able to add an operator org
	[Documentation]
	...  admin user can create an operator org 
	...  verify the orgs returned
        
	
	Create Org    orgname=${op_orgname}    orgtype=operator    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	#Should Be Equal               ${body}         {"message":"Organization created","name":"${op_orgname}"}
        Should Be Equal               ${body}         {"message":"Organization created"}

	${orgs}=  Show Organizations   token=${adminToken}

        ${found}=  Set Variable  ${False}
        : FOR  ${org}  IN  @{orgs}
        \  ${found}=  Run Keyword And Return Status  Should Be Equal  ${org['Name']}  ${op_orgname}
        \  Exit For Loop If  ${found}

	Should Be Equal       ${org["Name"]}                   ${op_orgname}
	Should Be Equal       ${org["Type"]}                   operator
	Should Be Equal       ${org["Address"]}                222 somewhere dr
	Should Be Equal       ${org["Phone"]}                  111-222-3333
	Convert Date          ${org["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - Admin shall be able to create multiple organizations
	[Documentation]
	...  admin user can create multiple orgs 
	...  verify the orgs returned
        
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created"}
	Create Org    orgname=${op_orgname}    orgtype=operator    address=333 somewhere st    phone=111-222-4444     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body	
	Should Be Equal               ${body}         {"message":"Organization created"}

	${orgs}=  Show Organizations   token=${adminToken}

        ${found}=  Set Variable  ${False}
        : FOR  ${org}  IN  @{orgs}
        \  ${found}=  Run Keyword And Return Status  Should Be Equal  ${org['Name']}  ${dev_orgname}
        \  ${orgfound}=  Set Variable  ${org}
        \  Exit For Loop If  ${found}

        Should Be Equal       ${org["Name"]}                   ${dev_orgname}
	Should Be Equal       ${org["Type"]}                   developer
	Should Be Equal       ${org["Address"]}                222 somewhere dr
	Should Be Equal       ${org["Phone"]}                  111-222-3333
	Convert Date          ${org["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

        ${found}=  Set Variable  ${False}
        : FOR  ${org}  IN  @{orgs}
        \  ${found}=  Run Keyword And Return Status  Should Be Equal  ${org['Name']}  ${op_orgname}
        \  ${orgfound}=  Set Variable  ${org}
        \  Exit For Loop If  ${found}

	Should Be Equal       ${org["Name"]}                   ${op_orgname}
	Should Be Equal       ${org["Type"]}                   operator
	Should Be Equal       ${org["Address"]}                333 somewhere st
	Should Be Equal       ${org["Phone"]}                  111-222-4444
	Convert Date          ${org["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - Admin shall be able to see orgs created by other users
	[Documentation]
	...  admin user can see orgs created by other users 
	...  verify the orgs returned
        
        ${epoch}=  Get Time  epoch
        ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
        ${emailepoch2}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  2  @gmail.com
        ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
        ${epochusername2}=  Catenate  SEPARATOR=  ${username}  ${epoch}  2

        Skip Verify Email
        Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
        Unlock User
        #Verify Email  email_address=${emailepoch}

        Create User  username=${epochusername2}   password=${password}   email_address=${emailepoch2} 
        Unlock User
        #Verify Email  email_address=${emailepoch2}

        ${userToken}=  Login  username=${epochusername}  password=${password}
        ${user2Token}=  Login  username=${epochusername2}  password=${password}
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created"}
	${org}=  Show Organizations   token=${userToken}
        Should Be Equal       ${org[0]["Name"]}                   ${dev_orgname}
	Should Be Equal       ${org[0]["Type"]}                   developer
	Should Be Equal       ${org[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${org[0]["Phone"]}                  111-222-3333
	Convert Date          ${org[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	
	Create Org    orgname=${op_orgname}    orgtype=operator    address=333 somewhere st    phone=111-222-4444     token=${user2Token}     use_defaults=${False}
	${body}=         Response Body	
	Should Be Equal               ${body}         {"message":"Organization created"}
	${org2}=  Show Organizations   token=${user2Token}
        Should Be Equal       ${org2[0]["Name"]}                   ${op_orgname}
	Should Be Equal       ${org2[0]["Type"]}                   operator
	Should Be Equal       ${org2[0]["Address"]}                333 somewhere st
	Should Be Equal       ${org2[0]["Phone"]}                  111-222-4444
	Convert Date          ${org2[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org2[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

	${orgs}=  Show Organizations   token=${adminToken}

        ${found}=  Set Variable  ${False}
        : FOR  ${org}  IN  @{orgs}
        \  ${found}=  Run Keyword And Return Status  Should Be Equal  ${org['Name']}  ${dev_orgname}
        \  ${orgfound}=  Set Variable  ${org}
        \  Exit For Loop If  ${found}

        Should Be Equal       ${org["Name"]}                   ${dev_orgname}
	Should Be Equal       ${org["Type"]}                   developer
	Should Be Equal       ${org["Address"]}                222 somewhere dr
	Should Be Equal       ${org["Phone"]}                  111-222-3333
	Convert Date          ${org["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

        ${found}=  Set Variable  ${False}
        : FOR  ${org}  IN  @{orgs}
        \  ${found}=  Run Keyword And Return Status  Should Be Equal  ${org['Name']}  ${op_orgname}
        \  ${orgfound}=  Set Variable  ${org}
        \  Exit For Loop If  ${found}

	Should Be Equal       ${org["Name"]}                   ${op_orgname}
	Should Be Equal       ${org["Type"]}                   operator
	Should Be Equal       ${org["Address"]}                333 somewhere st
	Should Be Equal       ${org["Phone"]}                  111-222-4444
	Convert Date          ${org["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - Shall not be able to create an org without a token	
	[Documentation]
	...  create an org without a token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	#Should Be Equal              ${body}         {"message":"invalid or expired jwt"}
        Should Be Equal              ${body}  {"message":"no bearer token found"}

MC - Shall not be able to create an org with an empty token	
	[Documentation]
	...  create an org with an empty token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${EMPTY}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"no bearer token found"}

MC - Shall not be able to create an org with a bad token	
	[Documentation]
	...  create an org with a bad token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=thisisabadtoken      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Shall not be able to create an org with an expired token	
	[Documentation]
	...  create an org with an expired token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${expToken}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

*** Keywords ***
Setup
   ${adminToken}=   Login  username=mexadmin  password=${mex_password}
	
   Set Suite Variable  ${adminToken}
