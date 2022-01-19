*** Settings ***
Documentation    Update Federator tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${operator}  GDDT
${region}  EU
${countrycode}  DE
${mcc}  49
${mnc1}  101

*** Test Cases ***
# ECQ-4239
Shall be able to update mnc of an existing federator
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a Federator
    ...  Update mnc of the federator
    ...  Validate output of federator show

    @{mnc}=  Create List  ${mnc1}

    ${federator}=  Create Federator  region=${region}  operatorid=${operator}  countrycode=${countrycode}  mcc=${mcc}  mnc=${mnc}  #use_defaults=${False}
    ${federationid}=  Set Variable  ${federator['federationid']}
    ${apikey}=  Set Variable  ${federator['apikey']}

    ${federator_show}=  Show Federator  operatorid=${operator}  federationid=${federationid}
    ${revision}=  Set Variable  ${federator_show[0]['revision']}

    Append to List  ${mnc}  102

    Update Federator  operatorid=${operator}  federationid=${federationid}  mcc=${mcc}  mnc=${mnc}

    ${federator_show}=  Show Federator  operatorid=${operator}  federationid=${federationid}

    Should Be Equal  ${federator_show[0]['countrycode']}  ${countrycode}
    Should Be Equal  ${federator_show[0]['operatorid']}  ${operator}
    Should Be Equal  ${federator_show[0]['mcc']}  ${mcc}
    Length Should Be  ${federator_show[0]['mnc']}  2
    Should Be Equal  ${federator_show[0]['region']}  ${region}
    Should Not Be Equal  ${federator_show[0]['revision']}  ${revision}

    Delete Federator  operatorid=${operator}  federationid=${federationid}


*** Keywords ***
Setup
    ${super_token}=  Get Super Token

    Set Suite Variable  ${super_token}

