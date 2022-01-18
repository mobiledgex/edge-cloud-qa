*** Settings ***
Documentation     Federation Resource Manager

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS_FEDERATION}   root_cert=%{AUTOMATION_MC_CERT}  mc_password=%{AUTOMATION_MC_PASSWORD}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Teardown

*** Variables ***
${operator}=           packet
${countrycode}=        SG

*** Test Cases ***
# ECQ-4253
Partner shall be able to register to shared zones
    [Documentation]
    ...  Login as MexAdmin
    ...  Controller throws error when unsharing federatorzone which is already registered by partner
    ...  Controller throws error when sharing federatorzone with invalid zoneid
    ...  Controller throws error when sharing federatorzone with invalid selfoperatorid
    ...  Controller throws error when sharing the same zone twice with same partner
    ...  Share another federatorzone with partner

    Register Federation  federation_name=${partner_federation_name}  selfoperatorid=${operator}

    Register FederatorZone  zones=${zone_list}  selfoperatorid=${operator}  federation_name=${partner_federation_name}  token=${partner_super_token}

*** Keywords ***
Setup
    @{zone_list}=  Create List  ${selfzone}

    Set Suite Variable  @{zone_list}

Teardown
    Deregister FederatorZone  zones=${zone_list}  selfoperatorid=${operator}  federation_name=${partner_federation_name}  token=${partner_super_token}
    Deregister Federation  federation_name=${partner_federation_name}  selfoperatorid=${operator}
