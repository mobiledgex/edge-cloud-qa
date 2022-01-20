*** Settings ***
Documentation    Create Federation tests

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Teardown
Test Timeout  10m

*** Variables ***
${selfoperator}  GDDT
${region}  EU
${selfcountrycode}  DE
${mcc}  49
${mnc1}  101
${partneroperator}  packet
${partnercountrycode}  SG
${federationaddr}   https://console-dev.mobiledgex.net:30001/


*** Test Cases ***
# ECQ-4240
Shall be able to create a federation
    [Documentation]
    ...  Login as MexAdmin
    ...  Create a federation
    ...  Validate output of federation show

    ${partnerfederationid}=  Generate Random String  32  [LETTERS][NUMBERS]
    ${partnerapikey}=  Generate Random String  32  [LETTERS][NUMBERS]

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${federationid}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partnerfederationid}  federationaddr=${federationaddr}  apikey=${partnerapikey}
 
    ${federation_show}=  Show Federation  selfoperatorid=${selfoperator}
    Should Not Be True  ${federation_show[0]['PartnerRoleAccessToSelfZones']}
    Should Not Be True  ${federation_show[0]['PartnerRoleShareZonesWithSelf']}
    Should Be Equal  ${federation_show[0]['operatorid']}  ${partneroperator}
    Should Be Equal  ${federation_show[0]['selfoperatorid']}  ${selfoperator}
    Should Be Equal  ${federation_show[0]['selffederationid']}  ${federationid}
    Should Be Equal  ${federation_show[0]['federationid']}  ${partnerfederationid}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${federation_name}=  Get Default Federation Name
    @{mnc}=  Create List  ${mnc1}

    ${federator}=  Create Federator  region=${region}  operatorid=${selfoperator}  countrycode=${selfcountrycode}  mcc=${mcc}  mnc=${mnc}
    ${federationid}=  Set Variable  ${federator['federationid']}

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${federation_name}
    Set Suite Variable  ${federationid}

Teardown
   Cleanup Provisioning
   Delete Federator  operatorid=${selfoperator}  federationid=${federationid} 
