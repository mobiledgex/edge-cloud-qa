*** Settings ***
Documentation   MasterController Org Create
	
Library		MexMasterController  root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${password}=   mex1234567
${expToken}=   eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTQ4NDkwMjcsImlhdCI6MTU1NDc2MjYyNywidXNlcm5hbWUiOiJtZXhhZG1pbiIsImtpZCI6Mn0.7hM7102kjgrAAbWWvpdJwg3PcNWd7td6D6QSxcvB6gswJUOMeoD5EvpzYnHjdHnbm4uJ7BlnHEOVr4yltZb1Rw
${dev_orgname}=    DevOrg
${op_orgname}=     OperOrg
	
*** Test Cases ***
MC - Show org with admin user no orgs created
	[Documentation]	
	...  admin user can show orgs 
	...  verify the orgs returned

	${org}=  Show Org   token=${adminToken}
	
	Should Be Empty    ${org}

MC - Add an Admin org with the admin user
	[Documentation]
	...  admin user can create an Admin org 
	...  verify the correct error message is  returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=admin    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Organization type must be developer, or operator"}

MC - Add a developer org with the admin user
	[Documentation]
	...  admin user can create an developer org 
	...  verify the orgs returned
        
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created","name":"${dev_orgname}"}

	${org}=  Show Org   token=${adminToken}
        Should Be Equal       ${org[0]["Name"]}                   ${dev_orgname}
	Should Be Equal       ${org[0]["Type"]}                   developer
	Should Be Equal       ${org[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${org[0]["Phone"]}                  111-222-3333
	Should Be Equal       ${org[0]["AdminUsername"]}          mexadmin
	Convert Date          ${org[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - Add a operator org with the admin user
	[Documentation]
	...  admin user can create an operator org 
	...  verify the orgs returned
        
	
	Create Org    orgname=${op_orgname}    orgtype=operator    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created","name":"${op_orgname}"}

	${org}=  Show Org   token=${adminToken}
	Should Be Equal       ${org[0]["Name"]}                   ${op_orgname}
	Should Be Equal       ${org[0]["Type"]}                   operator
	Should Be Equal       ${org[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${org[0]["Phone"]}                  111-222-3333
	Should Be Equal       ${org[0]["AdminUsername"]}          mexadmin
	Convert Date          ${org[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - Admin user can create multiple organizations
	[Documentation]
	...  admin user can create multiple orgs 
	...  verify the orgs returned
        
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created","name":"${dev_orgname}"}
	Create Org    orgname=${op_orgname}    orgtype=operator    address=333 somewhere st    phone=111-222-4444     token=${adminToken}     use_defaults=${False}
	${body}=         Response Body	
	Should Be Equal               ${body}         {"message":"Organization created","name":"${op_orgname}"}

	${orgs}=  Show Org   token=${adminToken}
        Should Be Equal       ${orgs[0]["Name"]}                   ${dev_orgname}
	Should Be Equal       ${orgs[0]["Type"]}                   developer
	Should Be Equal       ${orgs[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${orgs[0]["Phone"]}                  111-222-3333
	Should Be Equal       ${orgs[0]["AdminUsername"]}          mexadmin
	Convert Date          ${orgs[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${orgs[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Should Be Equal       ${orgs[1]["Name"]}                   ${op_orgname}
	Should Be Equal       ${orgs[1]["Type"]}                   operator
	Should Be Equal       ${orgs[1]["Address"]}                333 somewhere st
	Should Be Equal       ${orgs[1]["Phone"]}                  111-222-4444
	Should Be Equal       ${orgs[1]["AdminUsername"]}          mexadmin
	Convert Date          ${orgs[1]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${orgs[1]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - New user can create a developer org
	[Documentation]
	...  new user can create a developer org 
	...  verify the org returned
        
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created","name":"${dev_orgname}"}
	
	${org}=  Show Org   token=${userToken}
        Should Be Equal       ${org[0]["Name"]}                   ${dev_orgname}
	Should Be Equal       ${org[0]["Type"]}                   developer
	Should Be Equal       ${org[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${org[0]["Phone"]}                  111-222-3333
	Should Be Equal       ${org[0]["AdminUsername"]}          myuser
	Convert Date          ${org[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - New user can create a operator org
	[Documentation]
	...  new user can create a operator org 
	...  verify the org returned
        
	
	Create Org    orgname=${op_orgname}    orgtype=operator    address=222 somewhere dr    phone=111-222-3333     token=${userToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created","name":"${op_orgname}"}
	
	${org}=  Show Org   token=${userToken}
        Should Be Equal       ${org[0]["Name"]}                   ${op_orgname}
	Should Be Equal       ${org[0]["Type"]}                   operator
	Should Be Equal       ${org[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${org[0]["Phone"]}                  111-222-3333
	Should Be Equal       ${org[0]["AdminUsername"]}          myuser
	Convert Date          ${org[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - New user can create multiple organizations
	[Documentation]
	...  new user can create multiple orgs 
	...  verify the orgs returned
        
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created","name":"${dev_orgname}"}
	Create Org    orgname=${op_orgname}    orgtype=operator    address=333 somewhere st    phone=111-222-4444     token=${userToken}     use_defaults=${False}
	${body}=         Response Body	
	Should Be Equal               ${body}         {"message":"Organization created","name":"${op_orgname}"}

	${orgs}=  Show Org   token=${userToken}
        Should Be Equal       ${orgs[0]["Name"]}                   ${dev_orgname}
	Should Be Equal       ${orgs[0]["Type"]}                   developer
	Should Be Equal       ${orgs[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${orgs[0]["Phone"]}                  111-222-3333
	Should Be Equal       ${orgs[0]["AdminUsername"]}          myuser
	Convert Date          ${orgs[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${orgs[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Should Be Equal       ${orgs[1]["Name"]}                   ${op_orgname}
	Should Be Equal       ${orgs[1]["Type"]}                   operator
	Should Be Equal       ${orgs[1]["Address"]}                333 somewhere st
	Should Be Equal       ${orgs[1]["Phone"]}                  111-222-4444
	Should Be Equal       ${orgs[1]["AdminUsername"]}          myuser
	Convert Date          ${orgs[1]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${orgs[1]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - Admin user can see orgs created by other users
	[Documentation]
	...  admin user can see orgs created by other users 
	...  verify the orgs returned
        
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created","name":"${dev_orgname}"}
	${org}=  Show Org   token=${userToken}
        Should Be Equal       ${org[0]["Name"]}                   ${dev_orgname}
	Should Be Equal       ${org[0]["Type"]}                   developer
	Should Be Equal       ${org[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${org[0]["Phone"]}                  111-222-3333
	Should Be Equal       ${org[0]["AdminUsername"]}          myuser
	Convert Date          ${org[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	
	Create Org    orgname=${op_orgname}    orgtype=operator    address=333 somewhere st    phone=111-222-4444     token=${user2Token}     use_defaults=${False}
	${body}=         Response Body	
	Should Be Equal               ${body}         {"message":"Organization created","name":"${op_orgname}"}
	${org2}=  Show Org   token=${user2Token}
        Should Be Equal       ${org2[0]["Name"]}                   ${op_orgname}
	Should Be Equal       ${org2[0]["Type"]}                   operator
	Should Be Equal       ${org2[0]["Address"]}                333 somewhere st
	Should Be Equal       ${org2[0]["Phone"]}                  111-222-4444
	Should Be Equal       ${org2[0]["AdminUsername"]}          youruser
	Convert Date          ${org2[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org2[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

	${orgs}=  Show Org   token=${adminToken}
        Should Be Equal       ${orgs[0]["Name"]}                   ${dev_orgname}
	Should Be Equal       ${orgs[0]["Type"]}                   developer
	Should Be Equal       ${orgs[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${orgs[0]["Phone"]}                  111-222-3333
	Should Be Equal       ${orgs[0]["AdminUsername"]}          myuser
	Convert Date          ${orgs[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${orgs[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Should Be Equal       ${orgs[1]["Name"]}                   ${op_orgname}
	Should Be Equal       ${orgs[1]["Type"]}                   operator
	Should Be Equal       ${orgs[1]["Address"]}                333 somewhere st
	Should Be Equal       ${orgs[1]["Phone"]}                  111-222-4444
	Should Be Equal       ${orgs[1]["AdminUsername"]}          youruser
	Convert Date          ${orgs[1]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${orgs[1]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - Create an org without an org name	
	[Documentation]
	...  create an org without an org name
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgtype=developer    address=222 somewhere dr    phone=111-222-3333    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Name not specified"}

MC - Create an org without an org type	
	[Documentation]
	...  create an org without an org type
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    address=222 somewhere dr    phone=111-222-3333    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Organization type must be developer, or operator"}

MC - Create an org without an org address	
	[Documentation]
	...  create an org without an org address
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    orgtype=developer   phone=111-222-3333    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Address not specified"}

MC - Create an org without an org phone	
	[Documentation]
	...  create an org without an org phone
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    orgtype=developer   address=222 somewhere dr    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Phone number not specified"}

MC - Create an org without a token	
	[Documentation]
	...  create an org without a token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Create an org with an empty token	
	[Documentation]
	...  create an org with an empty token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${EMPTY}      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Create an org with a bad token	
	[Documentation]
	...  create an org with a bad token
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org    orgname=adminOrg    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=thisisabadtoken      use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  401	
	Should Be Equal              ${body}         {"message":"invalid or expired jwt"}

MC - Create an org with an expired token	
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
	${adminToken}=   Login
	Create User   username=myuser   password=${password}   email=xy@xy.com
	${userToken}=  Login  username=myuser  password=${password}   
	Create User   username=youruser   password=${password}    email=xyz@xyz.com
	${user2Token}=  Login  username=youruser  password=${password} 
        Set Suite Variable  ${adminToken}
	Set Suite Variable  ${userToken}
	Set Suite Variable  ${user2Token}
