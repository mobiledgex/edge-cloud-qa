*** Settings ***
Documentation   MasterController assign roles with no org 

Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***
${username}=  mextester06
${password}=  mextester06123

*** Test Cases ***
MC - Admin user shall be able assign AdminManger role with no org
   [Documentation]
   ...  assign AdminManager without an org 
   ...  verify assignment is successful 

   ${adduser}=   Adduser Role   username=${user}   role=AdminManager    token=${adminToken}     use_defaults=${False}
   ${showadmin}=   Show Role Assignment   token=${adminToken}

   ${found}=  Set Variable  ${False}
   : FOR  ${role}  IN  @{showadmin}
   \  ${found}=  Run Keyword And Return Status  Should Be True  '${role['username']}'=='${user}' and '${role['role']}'=='AdminManager'
   \  Exit For Loop If  ${found}

   log to console  ${role}
   Should Be Equal       ${role["username"]}  ${user}
   Should Be Equal       ${role["role"]}      AdminManager 
   Should Be Equal       ${role["org"]}       ${EMPTY} 

MC - Admin user shall not be able assign AdminManger role with an org
   [Documentation]
   ...  assign AdminManager role with an org 
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=AdminManager   orgname=myorg   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Admin roles cannot be associated with an org, please specify the empty org \\\\"\\\\""}

MC - Admin user shall not be able assign DeveloperManger role without an org
   [Documentation]
   ...  assign DeveloperManager role without an org
   ...  verify proper error returned
   
   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=DeveloperManager   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - Admin user shall not be able assign DeveloperViewer role without an org
   [Documentation]
   ...  assign DeveloperViewer role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=DeveloperViewer   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - Admin user shall not be able assign DeveloperContributor role without an org
   [Documentation]
   ...  assign DeveloperContributor role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=DeveloperContributor   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - Admin user shall not be able assign OperatorManger role without an org
   [Documentation]
   ...  assign OperatorManager role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=OperatorManager   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - Admin user shall not be able assign OperatorViewer role without an org
   [Documentation]
   ...  assign OperatorViewer role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=OperatorViewer   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - Admin user shall not be able assign OperatorContributor role without an org
   [Documentation]
   ...  assign OperatorContributor role without an org
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=OperatorContributor   token=${adminToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - User shall not be able assign AdminManger role
   [Documentation]
   ...  assign AdminManager role via user token 
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=AdminManager   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Organization not specified or no permissions"}

MC - User shall not be able assign DeveloperManger role without an org
   [Documentation]
   ...  assign DeveloperManager role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=DeveloperManager   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - User shall not be able assign DeveloperContributor role without an org
   [Documentation]
   ...  assign DeveloperContributor role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=DeveloperContributor   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - User shall not be able assign DeveloperViewer role without an org
   [Documentation]
   ...  assign DeveloperViewer role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=DeveloperViewer   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - User shall not be able assign OperatorManger role without an org
   [Documentation]
   ...  assign OperatorManager role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=OperatorManager   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - User shall not be able assign OperatorContributor role without an org
   [Documentation]
   ...  assign OperatorContributor role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=OperatorContributor   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}

MC - User shall not be able assign OperatorViewer role without an org
   [Documentation]
   ...  assign OperatorViewer role without an org via user role
   ...  verify proper error returned

   ${error}=   Run Keyword and Expect Error  *  Adduser Role   username=${user}   role=OperatorViewer   token=${userToken}     use_defaults=${False}

   Should Contain   ${error}  code=400
   Should Contain   ${error}  error={"message":"Org name must be specified for the specified role"}
	
*** Keywords ***
Setup
   ${adminToken}=  Get Supertoken

   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}

   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   Verify Email  email_address=${emailepoch}
   ${userToken}=  Login  username=${user}  password=${password}

   Set Suite Variable  ${adminToken}
   Set Suite Variable  ${userToken}
