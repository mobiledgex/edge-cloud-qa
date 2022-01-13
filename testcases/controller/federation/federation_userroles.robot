*** Settings ***
Documentation    Federation userroles tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Teardown
Test Timeout  10m

*** Variables ***
${selfoperator}  packet
${region}  EU
${countrycode}  DE
${mcc}  49
${mnc1}  101
${partneroperator}  WWT
${partnercountrycode}  SG
${federationaddr}   https://console-dev.mobiledgex.net:30001/

*** Test Cases ***
# ECQ-4220
OperatorManager of org A shall not be able to create/view/delete federation of Operator Org B
    [Documentation]
    ...  Login as OperatorManager of Org A
    ...  Create/View/Delete federation of Operator Org B
    ...  Controller throws 403 forbidden

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    Run Keyword And Ignore Error  Adduser Role  username=${op_manager_user_automation}  orgname=tmus  role=OperatorManager  token=${super_token}
    ${op1_token}=  Login  username=${op_manager_user_automation}  password=${op_manager_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  token=${op1_token}

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}

    ${federation_show}=  Show Federation  selfoperatorid=${selfoperator}  token=${op1_token}
    Should Be Empty  ${federation_show}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Federation  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${op1_token}

# ECQ-4221
OperatorContributor shall be able to create/view/delete federation
    [Documentation]
    ...  Login as OperatorContributor
    ...  Create/View/Delete federation

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    Run Keyword And Ignore Error  Adduser Role  username=${op_contributor_user_automation}  orgname=${selfoperator}  role=OperatorContributor  token=${super_token}
    ${op1_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  token=${op1_token}  auto_delete=${False}

    ${federation_show}=  Show Federation  selfoperatorid=${selfoperator}  token=${op1_token}
    Should Not Be Empty  ${federation_show}

    Delete Federation  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${op1_token}

# ECQ-4222
OperatorViewer shall not be able to create/delete federation
    [Documentation]
    ...  Login as OperatorViewer
    ...  Create/View/Delete federation
    ...  Controller throws 403 forbidden for create/delete federation
    ...  OperatorViewer is only able to view federation

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    Run Keyword And Ignore Error  Adduser Role  username=${op_viewer_user_automation}  orgname=${selfoperator}  role=OperatorViewer  token=${super_token}
    ${op1_token}=  Login  username=${op_viewer_user_automation}  password=${op_viewer_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  token=${op1_token}

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}

    ${federation_show}=  Show Federation  selfoperatorid=${selfoperator}  token=${op1_token}
    Should Not Be Empty  ${federation_show}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Federation  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${op1_token}

# ECQ-4223
DeveloperManager shall not be able to create/view/delete federation
    [Documentation]
    ...  Login as DeveloperManager
    ...  Create/View/Delete federation
    ...  Controller throws 403 forbidden

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    Run Keyword And Ignore Error  Adduser Role  username=${dev_manager_user_automation}  orgname=${developer_org_name_automation}  role=DeveloperManager  token=${super_token}
    ${dev1_token}=  Login  username=${dev_manager_user_automation}  password=${dev_manager_password_automation}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  token=${dev1_token}

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}

    ${federation_show}=  Show Federation  selfoperatorid=${selfoperator}  token=${dev1_token}
    Should Be Empty  ${federation_show}

    Run Keyword and Expect Error  ('code=403', 'error={"message":"Forbidden"}')  Delete Federation  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${dev1_token}


*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${federation_name}=  Get Default Federation Name
    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]

    ${federator}=  Create Federator  region=${region}  operatorid=${selfoperator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${federationid}
    Set Suite Variable  ${federation_name}

Teardown
    Run Keyword And Ignore Error  Removeuser Role  username=${op_contributor_user_automation}  orgname=${selfoperator}  role=OperatorContributor  token=${super_token}
    Cleanup Provisioning

