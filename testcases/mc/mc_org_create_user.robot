*** Settings ***
Documentation   MasterController Org Create by User
	
Library		MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime

Suite Setup	Setup
Suite Teardown	Cleanup Provisioning
Test Teardown  Cleanup Provisioning

*** Variables ***
${dev_orgname}=    DevOrg
${op_orgname}=     OperOrg

${username}=  mextester06
${password}=  mextester06123
	
*** Test Cases ***
MC - User shall be able to query empty orgs
       [Documentation]
       ...  user can show orgs when no orgs exist
       ...  verify the empty list is returned

       ${org}=  Show Organizations  token=${userToken}

       Should Be Empty    ${org}

MC - User shall be able to create a developer org
	[Documentation]
	...  new user can create a developer org 
	...  verify the org returned
        
	
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

MC - User shall be able to create an operator org
	[Documentation]
	...  new user can create a operator org 
	...  verify the org returned
        
	
	Create Org    orgname=${op_orgname}    orgtype=operator    address=222 somewhere dr    phone=111-222-3333     token=${userToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created"}
	
	${org}=  Show Organizations   token=${userToken}
        Should Be Equal       ${org[0]["Name"]}                   ${op_orgname}
	Should Be Equal       ${org[0]["Type"]}                   operator
	Should Be Equal       ${org[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${org[0]["Phone"]}                  111-222-3333
	Convert Date          ${org[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${org[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - User shall be able to create multiple organizations
	[Documentation]
	...  new user can create multiple orgs 
	...  verify the orgs returned
        
	
	Create Org    orgname=${dev_orgname}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}     use_defaults=${False}
	${body}=         Response Body
	Should Be Equal               ${body}         {"message":"Organization created"}
	Create Org    orgname=${op_orgname}    orgtype=operator    address=333 somewhere st    phone=111-222-4444     token=${userToken}     use_defaults=${False}
	${body}=         Response Body	
	Should Be Equal               ${body}         {"message":"Organization created"}

	${orgs}=  Show Organizations   token=${userToken}
        Should Be Equal       ${orgs[0]["Name"]}                   ${dev_orgname}
	Should Be Equal       ${orgs[0]["Type"]}                   developer
	Should Be Equal       ${orgs[0]["Address"]}                222 somewhere dr
	Should Be Equal       ${orgs[0]["Phone"]}                  111-222-3333
	Convert Date          ${orgs[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${orgs[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Should Be Equal       ${orgs[1]["Name"]}                   ${op_orgname}
	Should Be Equal       ${orgs[1]["Type"]}                   operator
	Should Be Equal       ${orgs[1]["Address"]}                333 somewhere st
	Should Be Equal       ${orgs[1]["Phone"]}                  111-222-4444
	Convert Date          ${orgs[1]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
	Convert Date          ${orgs[1]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

MC - User shall not be able to create an org without an org name	
	[Documentation]
	...  create an org without an org name
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgtype=developer    address=222 somewhere dr    phone=111-222-3333    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Name not specified"}

MC - User shall not be able to create an org without an org type	
	[Documentation]
	...  create an org without an org type
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    address=222 somewhere dr    phone=111-222-3333    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Organization type must be developer, or operator"}

MC - User shall not be able to create an org without an address	
	[Documentation]
	...  create an org without an org address
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    orgtype=developer   phone=111-222-3333    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Address not specified"}

MC - User shall not be able to create an org without a phone	
	[Documentation]
	...  create an org without an org phone
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    orgtype=developer   address=222 somewhere dr    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Phone number not specified"}

MC - User shall not be able to create an org named mobiledgex 
        [Documentation]
        ...  create an org without an org phone
        ...  verify the correct error message is returned

        ${org}=   Run Keyword and Expect Error  *   Create Org     orgname=mobiledgex    orgtype=developer   address=222 somewhere dr    phone=111-222-3333  token=${userToken}     use_defaults=${False}
        ${status_code}=  Response Status Code
        ${body}=         Response Body

        Should Be Equal As Numbers   ${status_code}  400
        Should Be Equal              ${body}         {"message":"Not authorized to create reserved org mobiledgex"}

        ${org}=   Run Keyword and Expect Error  *   Create Org     orgname=MobiledgeX    orgtype=operator   address=222 somewhere dr    phone=111-222-3333  token=${userToken}     use_defaults=${False}
        ${status_code}=  Response Status Code
        ${body}=         Response Body

        Should Be Equal As Numbers   ${status_code}  400
        Should Be Equal              ${body}         {"message":"Not authorized to create reserved org MobiledgeX"}

*** Keywords ***
Setup
   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   Verify Email  email_address=${emailepoch}

   ${userToken}=  Login  username=${epochusername}  password=${password}
	
   Set Suite Variable  ${userToken}
