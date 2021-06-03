*** Settings ***
Documentation   MasterController Org Create by User
	
Library		MexMasterController   mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library         DateTime
Library         String 

Test Setup	Setup
Test Teardown	Teardown
#Test Teardown  Cleanup Provisioning

*** Variables ***
${dev_orgname}=    DevOrg
${op_orgname}=     OperOrg

${username}=  mextester06
${password}=  ${mextester06_gmail_password} 
	
*** Test Cases ***
# ECQ-1622
MC - User shall be able to query empty orgs
       [Documentation]
       ...  user can show orgs when no orgs exist
       ...  verify the empty list is returned

       ${org}=  Show Organizations  token=${userToken}

       Should Be Empty    ${org}

# ECQ-1623
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

# ECQ-1624
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

# ECQ-1625
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
        ${numorgs}=  Get Length  ${orgs}

        Should Be Equal As Numbers  ${numorgs}  2

        ${devfound}=  Set Variable  ${FALSE}
        ${opfound}=  Set Variable  ${FALSE}
        log to console  xx ${devfound} ${opfound}

        FOR  ${org}  IN  @{orgs}
           ${devfound}=  Run Keyword If  "${org["Name"]}"=="${dev_orgname}"  Verify Dev Org  ${org}
           ...           ELSE  Set Variable  ${devfound}
           ${opfound}=   Run Keyword If  "${org["Name"]}"=="${op_orgname}"   Verify Op Org   ${org}
           ...           ELSE  Set Variable  ${opfound}
        END
        log to console  yy ${devfound} ${opfound}
        Should Be True  ${devfound}
        Should Be True  ${opfound}

#        Should Be Equal       ${orgs[0]["Name"]}                   ${dev_orgname}
#	Should Be Equal       ${orgs[0]["Type"]}                   developer
#	Should Be Equal       ${orgs[0]["Address"]}                222 somewhere dr
#	Should Be Equal       ${orgs[0]["Phone"]}                  111-222-3333
#	Convert Date          ${orgs[0]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
#	Convert Date          ${orgs[0]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
#	Should Be Equal       ${orgs[1]["Name"]}                   ${op_orgname}
#	Should Be Equal       ${orgs[1]["Type"]}                   operator
#	Should Be Equal       ${orgs[1]["Address"]}                333 somewhere st
#	Should Be Equal       ${orgs[1]["Phone"]}                  111-222-4444
#	Convert Date          ${orgs[1]["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
#	Convert Date          ${orgs[1]["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z

# ECQ-1626
MC - User shall not be able to create an org without an org name	
	[Documentation]
	...  create an org without an org name
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgtype=developer    address=222 somewhere dr    phone=111-222-3333    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Name not specified"}

# ECQ-1627
MC - User shall not be able to create an org without an org type	
	[Documentation]
	...  create an org without an org type
	...  verify the correct error message is returned

	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    address=222 somewhere dr    phone=111-222-3333    token=${userToken}     use_defaults=${False}
	${status_code}=  Response Status Code
	${body}=         Response Body
	
	Should Be Equal As Numbers   ${status_code}  400	
	Should Be Equal              ${body}         {"message":"Organization type must be developer, or operator"}

# no longer supported
# ECQ-1628
#MC - User shall not be able to create an org without an address	
#	[Documentation]
#	...  create an org without an org address
#	...  verify the correct error message is returned
#
#	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    orgtype=developer   phone=111-222-3333    token=${userToken}     use_defaults=${False}
#	${status_code}=  Response Status Code
#	${body}=         Response Body
#	
#	Should Be Equal As Numbers   ${status_code}  400	
#	Should Be Equal              ${body}         {"message":"Address not specified"}
#  ECQ-1629
#MC - User shall not be able to create an org without a phone	
#	[Documentation]
#	...  create an org without an org phone
#	...  verify the correct error message is returned
#
#	${org}=   Run Keyword and Expect Error  *   Create Org     orgname=${dev_orgname}    orgtype=developer   address=222 somewhere dr    token=${userToken}     use_defaults=${False}
#	${status_code}=  Response Status Code
#	${body}=         Response Body
#	
#	Should Be Equal As Numbers   ${status_code}  400	
#	Should Be Equal              ${body}         {"message":"Phone number not specified"}

#  ECQ-1630
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

# ECQ-3428
MC - User shall not be able to create an org that is too long
        [Documentation]
        ...  - create an org with a name that is too long as a user
        ...  - verify the correct error message is returned

        ${rand_org}=  Generate Random String  91
        ${org}=   Run Keyword and Expect Error  *   Create Org    orgname=${rand_org}    orgtype=developer    address=222 somewhere dr    phone=111-222-3333     token=${userToken}      use_defaults=${False}
        ${status_code}=  Response Status Code
        ${body}=         Response Body

        Should Be Equal As Numbers   ${status_code}  400
        Should Be Equal              ${body}         {"message":"Name too long"}

*** Keywords ***
Setup
   #${epoch}=  Get Time  epoch
   ${epoch}=  Get Current Date  result_format=epoch
   
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Skip Verify Email   #skip_verify_email=False
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}   email_check=True
   Unlock User
   #Verify Email  email_address=${emailepoch}

   ${userToken}=  Login  username=${epochusername}  password=${password}

#   Verify Email Via MC  token=${userToken}
	
   Set Suite Variable  ${userToken}

Teardown
   #Skip Verify Email   skip_verify_email=True
   Cleanup Provisioning

Verify Dev Org
        [Arguments]  ${org}
        Should Be Equal       ${org["Name"]}                   ${dev_orgname}
        Should Be Equal       ${org["Type"]}                   developer
        Should Be Equal       ${org["Address"]}                222 somewhere dr
        Should Be Equal       ${org["Phone"]}                  111-222-3333
        Convert Date          ${org["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
        Convert Date          ${org["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
        [Return]  ${TRUE}

Verify Op Org
        [Arguments]  ${org}
        Should Be Equal       ${org["Name"]}                   ${op_orgname}
        Should Be Equal       ${org["Type"]}                   operator
        Should Be Equal       ${org["Address"]}                333 somewhere st
        Should Be Equal       ${org["Phone"]}                  111-222-4444
        Convert Date          ${org["CreatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
        Convert Date          ${org["UpdatedAt"]}              date_format=%Y-%m-%dT%H:%M:%S.%f%z
        [Return]  ${TRUE}

