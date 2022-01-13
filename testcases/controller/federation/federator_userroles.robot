*** Settings ***
Documentation    Federator userroles tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${operator}  packet
${region}  EU
${countrycode}  DE
${mcc}  49
${mnc1}  101

*** Test Cases ***
# ECQ-4216
OperatorManager of org A shall not be able to do create/view/update/generateapikey/delete federator of Operator Org B
    [Documentation]
    ...  Login as OperatorManager of org A
    ...  Create/View/Update/GenerateApiKey/Delete federator of Operator Org B
    ...  Controller throws 403 forbidden

    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=dmuus  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    ${federator_show}=  Show Federator  operatorid=${operator}  federationid=${federationid}  token=${op1_token}
    Should Be Empty  ${federator_show}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  token=${op1_token}

    Append to List  ${mnc}  102
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Federator  operatorid=${operator}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  token=${op1_token}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  GenerateSelfApiKey Federator  operatorid=${operator}  federationid=${federationid}  token=${op1_token}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Federator  operatorid=${operator}  federationid=${federationid}  token=${op1_token}

# ECQ-4217
OperatorContributor shall be able to create/update/generateapikey/delete/view federator
    [Documentation]
    ...  Login as OperatorContributor
    ...  Create/View/Update/GenerateApiKey/Delete federator

    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]

    Run Keyword And Ignore Error  Adduser Role  username=${op_contributor_user_automation}  orgname=dmuus  role=OperatorContributor  token=${super_token}
    ${op1_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

    Create Federator  region=${region}  operatorid=dmuus  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  token=${op1_token}    auto_delete=${False}

    Append to List  ${mnc}  102
    Update Federator  operatorid=dmuus  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  token=${op1_token}  

    GenerateSelfApiKey Federator  operatorid=dmuus  federationid=${federationid}  token=${op1_token}

    ${show}=  Show Federator  operatorid=dmuus  federationid=${federationid}  token=${op1_token}
    Should Not Be Empty  ${show}

    Delete Federator  operatorid=dmuus  federationid=${federationid}  token=${op1_token}

# ECQ-4218
OperatorViewer shall not be able to create/update/generateapikey/delete federator
    [Documentation]
    ...  Login as OperatorViewer
    ...  Create/View/Update/GenerateApiKey/Delete federator
    ...  OperatorViewer is only able to view federator

    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]

    ${federator}=  Create Federator  region=${region}  operatorid=dmuus  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}   

    Run Keyword And Ignore Error  Adduser Role  username=${op_viewer_user_automation}  orgname=dmuus  role=OperatorViewer  token=${super_token}
    ${op1_token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Federator  region=${region}  operatorid=dmuus  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  token=${op1_token}  

    Append to List  ${mnc}  102
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Federator  operatorid=dmuus  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  token=${op1_token}  

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  GenerateSelfApiKey Federator  operatorid=dmuus  federationid=${federationid}  token=${op1_token}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Federator  operatorid=dmuus  federationid=${federationid}  token=${op1_token}

    ${show}=  Show Federator  operatorid=dmuus  federationid=${federationid}  token=${op1_token}
    Should Not Be Empty  ${show}

# ECQ-4219
DeveloperManager shall not be able to create/update/generateapikey/delete/view federator
    [Documentation]
    ...  Login as DeveloperManager
    ...  Create/View/Update/GenerateApiKey/Delete federator
    ...  Controller throws 403 forbidden

    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}   

    Run Keyword And Ignore Error  Adduser Role  username=${dev_manager_user_automation}  orgname=${developer_org_name_automation}  role=DeveloperManager  token=${super_token}
    ${dev1_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  token=${dev1_token}  

    Append to List  ${mnc}  102
    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Update Federator  operatorid=${operator}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  token=${dev1_token}  

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  GenerateSelfApiKey Federator  operatorid=${operator}  federationid=${federationid}  token=${dev1_token}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Federator  operatorid=${operator}  federationid=${federationid}  token=${dev1_token}

    ${show}=  Show Federator  operatorid=${operator}  federationid=${federationid}  token=${dev1_token}
    Should Be Empty  ${show}
 
*** Keywords ***
Setup
    ${super_token}=  Get Super Token

    Set Suite Variable  ${super_token}

