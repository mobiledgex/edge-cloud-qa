*** Settings ***
Documentation    Create Federator tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${operator}  TDG
${region}  EU
${countrycode}  DE
${mcc}  49
${mnc1}  101

*** Test Cases ***
# ECQ-4236
Shall be able to create a federator without providing federationid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator without providing federationid 
    ...  Validate output of federator show

    @{mnc}=  Create List  ${mnc1}

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  
    ${federationid}=  Set Variable  ${federator['federationid']}
    ${apikey}=  Set Variable  ${federator['apikey']}

    ${federator_show}=  Show Federator  operatorid=${operator}  federationid=${federationid}
    Log To Console  ${federator_show}

    Should Be Equal  ${federator_show[0]['countrycode']}  ${countrycode}
    Should Be Equal  ${federator_show[0]['operatorid']}  ${operator}
    Should Be Equal  ${federator_show[0]['mcc']}  ${mcc}
    Should Be Equal  ${federator_show[0]['mnc'][0]}  ${mnc1}
    Should Be Equal  ${federator_show[0]['region']}  ${region}

    Delete Federator  operatorid=${operator}  federationid=${federationid}

# ECQ-4237
Shall be able to create a federator with operator specific federationid
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator by providing federationid
    ...  Validate output of federator show

    @{mnc}=  Create List  ${mnc1}
    ${federationid}=  Generate Random String  8  [LETTERS][NUMBERS]

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  federationid=${federationid}  

    ${federator_show}=  Show Federator  operatorid=${operator}  federationid=${federationid}
    Log To Console  ${federator_show}
    Should Be Equal  ${federator_show[0]['federationid']}  ${federationid}

# ECQ-4238
Shall be able to generate self api key of an existing federator
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federator without providing federationid
    ...  Generate api key for the federator
    ...  Validate that new key is not the same as old key

    @{mnc}=  Create List  ${mnc1}

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  
    ${federationid}=  Set Variable  ${federator['federationid']}
    ${apikey}=  Set Variable  ${federator['apikey']}

    ${generate_api}=  GenerateSelfApiKey Federator  operatorid=${operator}  federationid=${federationid}
    ${new_apikey}=  Set Variable  ${generate_api['apikey']}

    Should Not Be Equal  ${apikey}  ${new_apikey}

    Delete Federator  operatorid=${operator}  federationid=${federationid}


*** Keywords ***
Setup
    ${super_token}=  Get Super Token

    Set Suite Variable  ${super_token}

