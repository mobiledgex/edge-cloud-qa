*** Settings ***
Documentation    Federation create/register/deregister failure tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Teardown
Test Timeout  10m

*** Variables ***
${selfoperator}  TDG
${region}  EU
${selfcountrycode}  DE
${mcc}  49
${mnc1}  101
${partneroperator}  packet
${partnercountrycode}  SG
${federationaddr}   https://console-dev.mobiledgex.net:30001/


*** Test Cases ***
# ECQ-4199
Federation create - Controller shall throw error with invalid selfoperatorid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federation with invalid selfoperatorid
    ...  Controller throws error

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"${federationid}\\\\\" does not exist for operator \\\\\"XX\\\\\""}')  Create Federation  selfoperatorid=XX  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}
 
# ECQ-4200
Federation create - Controller shall throw error with invalid selffederationid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federation with invalid selffederationid
    ...  Controller throws error

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Self federator with ID \\\\\"XX\\\\\" does not exist for operator \\\\\"${selfoperator}\\\\\""}')  Create Federation  selfoperatorid=${selfoperator}  selffederationid=XX  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}

# ECQ-4201
Federation create - Controller shall throw error while creating two federations with same selffederationid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create two federations with same selffederationid
    ...  Controller throws error

    ${partnerfederationid1}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey1}=  Generate Random String  32  [LETTERS][NUMBERS]

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Partner federation with same self federation id \\\\\"${federationid}\\\\\" already exists"}')  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=tmus  countrycode=${partnercountrycode}  federationid=${partnerfederationid1}  federationaddr=${federationaddr}  apikey=${partnerapikey1}  federation_name=${federation_name}1

# ECQ-4202
Federation create - Controller shall throw error while creating two federations with same partner federationid/apikey
    [Documentation]
    ...  Login as MexAdmin
    ...  Create two federations with same partner federationid/apikey
    ...  Controller throws error

    # EDGECLOUD-5980
    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}

    ${federator1}=  Create Federator  region=${region}  operatorid=${selfoperator}  countrycode=${selfcountrycode}  mcc=${mcc}  mnc=${mnc}    auto_delete=${False}
    ${federationid1}=  Set Variable  ${federator1['federationid']}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Partner federation with same federation id \\\\\"${partnerfederationid}\\\\\" already exists"}')  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid1}  operatorid=tmus  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  federation_name=${federation_name}1

    Delete Federator  operatorid=${selfoperator}  federationid=${federationid1}

# ECQ-4203
Federation create - Controller shall throw error while creating two federations with same name
    [Documentation]
    ...  Login as MexAdmin
    ...  Create two federations with same name
    ...  Controller throws error

    ${partnerfederationid1}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey1}=  Generate Random String  32  [LETTERS][NUMBERS]

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}

    ${federator1}=  Create Federator  region=${region}  operatorid=${selfoperator}  countrycode=${selfcountrycode}  mcc=${mcc}  mnc=${mnc}    auto_delete=${False}
    ${federationid1}=  Set Variable  ${federator1['federationid']}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Partner federation \\\\\"${federation_name}\\\\\" already exists"}')  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid1}  operatorid=tmus  countrycode=${partnercountrycode}  federationid=${partnerfederationid1}  federationaddr=${federationaddr}  apikey=${partnerapikey1}  federation_name=${federation_name}

    Delete Federator  operatorid=${selfoperator}  federationid=${federationid1}

# ECQ-4204
Federation create - Controller shall throw error with invalid countrycode
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federation with invalid countrycode
    ...  Controller throws error

    # EDGECLOUD-5979
    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Invalid country code \\\\\"XX\\\\\". It must be a valid ISO 3166-1 Alpha-2 code for the country"}')  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=XX  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}

# ECQ-4205
Federation create - Controller shall throw error with invalid federation name
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federation with invalid federation name
    ...  Controller throws error

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    # federation name starting with - 
    ${error_msg}=  Run Keyword and Expect Error  *  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  federation_name=-${federation_name}
    Should Contain  ${error_msg}  Invalid federation name \\\\\"-${federation_name}\\\\\", valid format is ^[a-zA-Z0-9][a-zA-Z0-9_-\]*[a-zA-Z0-9]$

    # federation name starting with _
    ${error_msg}=  Run Keyword and Expect Error  *  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  federation_name=_${federation_name}
    Should Contain  ${error_msg}  Invalid federation name \\\\\"_${federation_name}\\\\\", valid format is ^[a-zA-Z0-9][a-zA-Z0-9_-\]*[a-zA-Z0-9]$

    # federation name ending with -
    ${error_msg}=  Run Keyword and Expect Error  *  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  federation_name=${federation_name}-
    Should Contain  ${error_msg}  Invalid federation name \\\\\"${federation_name}-\\\\\", valid format is ^[a-zA-Z0-9][a-zA-Z0-9_-\]*[a-zA-Z0-9]$

    # federation name ending with _
    ${error_msg}=  Run Keyword and Expect Error  *  Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}  federation_name=${federation_name}_
    Should Contain  ${error_msg}  Invalid federation name \\\\\"${federation_name}_\\\\\", valid format is ^[a-zA-Z0-9][a-zA-Z0-9_-\]*[a-zA-Z0-9]$

# ECQ-4206
Federation Register/Deregister - Controller shall throw error with mismatched selfoperatorid
    [Documentation]
    ...  Login as MexAdmin
    ...  Register/Deregister Federation with incorrect selfoperatorid
    ...  Controller throws error

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Federation with name \\\\\"${federation_name}\\\\\" does not exist for self operator ID \\\\\"packet\\\\\""}')  Register Federation  federation_name=${federation_name}  selfoperatorid=packet
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Federation with name \\\\\"${federation_name}\\\\\" does not exist for self operator ID \\\\\"packet\\\\\""}')  Deregister Federation  federation_name=${federation_name}  selfoperatorid=packet

# ECQ-4207
Federation Register/Deregister - Controller shall throw error with invalid federation name
    [Documentation]
    ...  Login as MexAdmin
    ...  Register/Deregister Federation with invalid federation name
    ...  Controller throws error

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Federation with name \\\\\"XX\\\\\" does not exist for self operator ID \\\\\"${selfoperator}\\\\\""}')  Register Federation  federation_name=XX  selfoperatorid=${selfoperator}
    Run Keyword and Expect Error  ('code=400', 'error={"message":"Federation with name \\\\\"XX\\\\\" does not exist for self operator ID \\\\\"${selfoperator}\\\\\""}')  Deregister Federation  federation_name=XX  selfoperatorid=${selfoperator}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${federation_name}=  Get Default Federation Name
    @{mnc}=  Create List  ${mnc1}

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    ${federator}=  Create Federator  region=${region}  operatorid=${selfoperator}  countrycode=${selfcountrycode}  mcc=${mcc}  mnc=${mnc}    auto_delete=${False}
    ${federationid}=  Set Variable  ${federator['federationid']}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${federation_name}
    Set Suite Variable  ${federationid}
    Set Suite Variable  ${partnerfederationid}
    Set Suite Variable  ${partnerapikey}
    Set Suite Variable  ${mnc}

Teardown
   Cleanup Provisioning
   Delete Federator  operatorid=${selfoperator}  federationid=${federationid}
