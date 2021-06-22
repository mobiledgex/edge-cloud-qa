*** Settings ***
Documentation   MasterController assign roles with no org 

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup	Setup
Test Teardown	Teardown

*** Variables ***
${username}=   mextester06
${password}=   ${mextester06_gmail_password}	
${userpass}=   H31m8@W8maSfg
${adminpass}=  H31m8@W8maSfgnC		

*** Test Cases ***
# ECQ-1641	
MC - Admin user shall be able assign AdminManger role with no org
   [Documentation]
   ...  assign AdminManager without an org 
   ...  verify assignment is successful 

   ${adduser}=   Adduser Role   username=${epochusername}   role=AdminManager    token=${adminToken}     use_defaults=${False}
   ${showadmin}=   Show Role Assignment   token=${adminToken}

   ${found}=  Set Variable  ${False}
   FOR  ${role}  IN  @{showadmin}
        ${found}=  Run Keyword And Return Status  Should Be True  '${role['username']}'=='${epochusername}' and '${role['role']}'=='AdminManager'
        Exit For Loop If  ${found}
   END
	
   log to console  ${role}
   Should Be Equal       ${role["username"]}  ${epochusername}
   Should Be Equal       ${role["role"]}      AdminManager 
   Should Be Equal       ${role["org"]}       ${EMPTY} 

   Removeuser Role  username=${epochusername}   role=AdminContributor    token=${adminToken}     use_defaults=${False}


# ECQ-1642
MC - Admin user shall not be able assign AdminManger role with an org
   [Documentation]
   ...  assign AdminManager role with an org 
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=AdminManager   orgname=myorg   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Admin roles cannot be associated with an org, please specify the empty org \\\\"\\\\""}

# ECQ-1643
MC - Admin user shall not be able assign DeveloperManger role without an org
   [Documentation]
   ...  assign DeveloperManager role without an org
   ...  verify proper error returned
   
   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=DeveloperManager   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1644
MC - Admin user shall not be able assign DeveloperViewer role without an org
   [Documentation]
   ...  assign DeveloperViewer role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=DeveloperViewer   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1645
MC - Admin user shall not be able assign DeveloperContributor role without an org
   [Documentation]
   ...  assign DeveloperContributor role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=DeveloperContributor   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1646
MC - Admin user shall not be able assign OperatorManger role without an org
   [Documentation]
   ...  assign OperatorManager role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=OperatorManager   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1647
MC - Admin user shall not be able assign OperatorViewer role without an org
   [Documentation]
   ...  assign OperatorViewer role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=OperatorViewer   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1648
MC - Admin user shall not be able assign OperatorContributor role without an org
   [Documentation]
   ...  assign OperatorContributor role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=OperatorContributor   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1649
MC - User shall not be able assign AdminManger role
   [Documentation]
   ...  assign AdminManager role via user token 
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=AdminManager   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Organization not specified or no permissions"}

# ECQ-1650
MC - User shall not be able assign DeveloperManger role without an org
   [Documentation]
   ...  assign DeveloperManager role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=DeveloperManager   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1651
MC - User shall not be able assign DeveloperContributor role without an org
   [Documentation]
   ...  assign DeveloperContributor role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=DeveloperContributor   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1652
MC - User shall not be able assign DeveloperViewer role without an org
   [Documentation]
   ...  assign DeveloperViewer role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=DeveloperViewer   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1653
MC - User shall not be able assign OperatorManger role without an org
   [Documentation]
   ...  assign OperatorManager role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=OperatorManager   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1654
MC - User shall not be able assign OperatorContributor role without an org
   [Documentation]
   ...  assign OperatorContributor role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=OperatorContributor   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

# ECQ-1655
MC - User shall not be able assign OperatorViewer role without an org
   [Documentation]
   ...  assign OperatorViewer role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${epochusername}   role=OperatorViewer   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

   
# ECQ-2740
MC - Admin user shall not be able assign AdminManger with a weak password
   [Documentation]
   ...  assign AdminManager with a weak password 
   ...  verify assignment is not successful 

   Run Keyword and Expect Error  *  Adduser Role   username=${adminuser}   role=AdminManager    token=${adminToken}     use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Password too weak, requires crack time 2.0 years but is 5.0 months. Please increase length or complexity"}

   Login   username=${adminuser}   password=${userpass}
   ${userinformatioin}=   Get Current User   	
   New Password   password=${adminpass}   token=${adminuserToken}   use_defaults=${False}
   ${adduser}=   Adduser Role   username=${adminuser}   role=AdminManager    token=${adminToken}     use_defaults=${False}
   ${showadmin}=   Show Role Assignment   token=${adminToken}

   ${found}=  Set Variable  ${False}
   FOR  ${role}  IN  @{showadmin}
        ${found}=  Run Keyword And Return Status  Should Be True  '${role['username']}'=='${adminuser}' and '${role['role']}'=='AdminManager'
        Exit For Loop If  ${found}
   END 
	
   log to console  ${role}
   Should Be Equal       ${role["username"]}  ${adminuser}
   Should Be Equal       ${role["role"]}      AdminManager 
   Should Be Equal       ${role["org"]}       ${EMPTY} 

   Removeuser Role  username=${adminuser}   role=AdminManager    token=${adminToken}     use_defaults=${False}
   ${tempToken}=   Login  username=${adminuser}  password=${adminpass}
   New Password   password=${userpass}   token=${tempToken}   use_defaults=${False}


# ECQ-2741
MC - Admin user shall be able assign AdminContributor role with no org
   [Documentation]
   ...  assign AdminContributor without an org 
   ...  verify assignment is successful 

   ${adduser}=   Adduser Role   username=${epochusername}   role=AdminContributor    token=${adminToken}     use_defaults=${False}
   ${showadmin}=   Show Role Assignment   token=${adminToken}

   ${found}=  Set Variable  ${False}
   FOR  ${role}  IN  @{showadmin}
        ${found}=  Run Keyword And Return Status  Should Be True  '${role['username']}'=='${epochusername}' and '${role['role']}'=='AdminContributor'
        Exit For Loop If  ${found}
   END 
	
   log to console  ${role}
   Should Be Equal       ${role["username"]}  ${epochusername}
   Should Be Equal       ${role["role"]}      AdminContributor 
   Should Be Equal       ${role["org"]}       ${EMPTY} 

   Removeuser Role  username=${epochusername}   role=AdminContributor    token=${adminToken}     use_defaults=${False}
 

# ECQ-2742
MC - Admin user shall not be able assign AdminContributor with a weak password
   [Documentation]
   ...  assign AdminContributor with a weak password 
   ...  verify assignment is not successful 

   Run Keyword and Expect Error  *  Adduser Role   username=${adminuser}   role=AdminContributor    token=${adminToken}     use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Password too weak, requires crack time 2.0 years but is 5.0 months. Please increase length or complexity"}

   Login   username=${adminuser}   password=${userpass}
   ${userinformatioin}=   Get Current User   	
   New Password   password=${adminpass}   token=${adminuserToken}   use_defaults=${False}
   ${adduser}=   Adduser Role   username=${adminuser}   role=AdminContributor    token=${adminToken}     use_defaults=${False}
   ${showadmin}=   Show Role Assignment   token=${adminToken}

   ${found}=  Set Variable  ${False}
   FOR  ${role}  IN  @{showadmin}
        ${found}=  Run Keyword And Return Status  Should Be True  '${role['username']}'=='${adminuser}' and '${role['role']}'=='AdminContributor'
         Exit For Loop If  ${found}
   END
	
   log to console  ${role}
   Should Be Equal       ${role["username"]}  ${adminuser}
   Should Be Equal       ${role["role"]}      AdminContributor 
   Should Be Equal       ${role["org"]}       ${EMPTY} 

   Removeuser Role  username=${adminuser}   role=AdminContributor    token=${adminToken}     use_defaults=${False}
   ${tempToken}=   Login  username=${adminuser}  password=${adminpass}
   New Password   password=${userpass}   token=${tempToken}   use_defaults=${False}


# ECQ-2743
MC - Admin user shall be able assign AdminViewer role with no org
   [Documentation]
   ...  assign AdminViewer without an org 
   ...  verify assignment is successful 

   ${adduser}=   Adduser Role   username=${epochusername}   role=AdminViewer    token=${adminToken}     use_defaults=${False}
   ${showadmin}=   Show Role Assignment   token=${adminToken}

   ${found}=  Set Variable  ${False}
   FOR  ${role}  IN  @{showadmin}
	${found}=  Run Keyword And Return Status  Should Be True  '${role['username']}'=='${epochusername}' and '${role['role']}'=='AdminViewer'
        Exit For Loop If  ${found}
   END
	
   log to console  ${role}
   Should Be Equal       ${role["username"]}  ${epochusername}
   Should Be Equal       ${role["role"]}      AdminViewer 
   Should Be Equal       ${role["org"]}       ${EMPTY} 

   Removeuser Role  username=${epochusername}   role=AdminViewer    token=${adminToken}     use_defaults=${False}


# ECQ-2744
MC - Admin user shall not be able assign AdminViewer with a weak password
   [Documentation]
   ...  assign AdminViewer with a weak password 
   ...  verify assignment is not successful 

   Run Keyword and Expect Error  *  Adduser Role   username=${adminuser}   role=AdminViewer    token=${adminToken}     use_defaults=${False}

   ${status_code}=  Response Status Code
   ${body}=         Response Body

   Should Be Equal As Numbers  ${status_code}  400	
   Should Be Equal             ${body}         {"message":"Password too weak, requires crack time 2.0 years but is 5.0 months. Please increase length or complexity"}

   Login   username=${adminuser}   password=${userpass}
   ${userinformatioin}=   Get Current User   	
   New Password   password=${adminpass}   token=${adminuserToken}   use_defaults=${False}
   ${adduser}=   Adduser Role   username=${adminuser}   role=AdminViewer    token=${adminToken}     use_defaults=${False}
   ${showadmin}=   Show Role Assignment   token=${adminToken}

   ${found}=  Set Variable  ${False}
   FOR  ${role}  IN  @{showadmin}
	${found}=  Run Keyword And Return Status  Should Be True  '${role['username']}'=='${adminuser}' and '${role['role']}'=='AdminViewer'
        Exit For Loop If  ${found}
   END

   log to console  ${role}
   Should Be Equal       ${role["username"]}  ${adminuser}
   Should Be Equal       ${role["role"]}      AdminViewer 
   Should Be Equal       ${role["org"]}       ${EMPTY} 

   Removeuser Role  username=${adminuser}   role=AdminViewer    token=${adminToken}     use_defaults=${False}
   ${tempToken}=   Login  username=${adminuser}  password=${adminpass}
   New Password   password=${userpass}   token=${tempToken}   use_defaults=${False}



*** Keywords ***
Setup
   ${adminToken}=  Get Supertoken

   ${epoch}=  Get Current Date  result_format=epoch

   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${adminuser}=   Catenate  SEPARATOR=  ${username}  ${epoch}  01	
   ${adminuseremail}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  01  @gmail.com

   #Skip Verify Email   skip_verify_email=False
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}    email_check=True
   Unlock User
   #Verify Email  email_address=${emailepoch}
   ${userToken}=  Login  username=${epochusername}  password=${password}
   Verify Email Via MC  token=${userToken}

   #Skip Verify Email
   Create User  username=${adminuser}   password=${userpass}   email_address=${adminuseremail}    email_check=False
   Unlock User
#   Verify Email  email_address=${adminuseremail}
   ${adminuserToken}=  Login  username=${adminuser}  password=${userpass}

   Set Suite Variable  ${adminToken}
   Set Suite Variable  ${userToken}
   Set Suite Variable  ${epochusername}
   Set Suite Variable  ${adminuser}
   Set Suite Variable  ${userpass}
   Set Suite Variable  ${adminpass}
   Set Suite Variable  ${adminuserToken}		

Teardown
   Skip Verify Email   skip_verify_email=True
   Cleanup Provisioning 
