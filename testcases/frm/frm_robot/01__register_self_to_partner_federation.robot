*** Settings ***
Documentation    Federation Resource Manager

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
#Test Teardown  Teardown
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
${partner_fed_id}


*** Test Cases ***
# ECQ-3755
Shall be able to register/deregister with partner federation 
    [Documentation]
    ...  Login as MexAdmin
    ...  Register to Partner Federation, mcc and mnc of partner are visible in output of federation show
    ...  Federation delete fails when federation is registered
    ...  Controller throws error when zone list has invalid zoneid
    ...  Controller throws error when federation name is null
    ...  Controller throws error when zone list is empty
    ...  Register to Partner zone and validate output of federatorzone showfederatedpartnerzone
    ...  Federation deregister fails when partnerzone is already registered

    Log To Console   ${partner_fed_id}
 
    Run Keyword and Expect Error  ('code=400', 'error={"message":"No federation exists with partner federator"}')  Deregister Federation  federation_name=${federation_name}  selfoperatorid=${selfoperator}
    Register Federation  federation_name=${federation_name}  selfoperatorid=${selfoperator}

    ${show}=  Show Federation 
    Should Be Equal  ${show[0]['mcc']}  200
    Should Be Equal  ${show[0]['mnc'][0]}  201
    Should Not Be True  ${show[0]['PartnerRoleAccessToSelfZones']}
    Should Be True  ${show[0]['PartnerRoleShareZonesWithSelf']}

    Run Keyword and Expect Error  ('code=400', 'error={"message":"Federation \\\\\"${federation_name}\\\\\" is already registered"}')  Register Federation  federation_name=${federation_name}  selfoperatorid=${selfoperator}
    Run Keyword And Expect Error  ('code=400', 'error={"message":"Cannot delete federation \\\\\"${federation_name}\\\\\" as it is registered"}')  Delete Federation  selfoperatorid=${selfoperator}

    @{partnerzones}=  ShowFederatedPartnerZone FederatorZone  federation_name=${federation_name}  token=${super_token}
    Length Should Be  ${partnerzones}  ${number_of_federatedzones}
    Should Not Be True  ${partnerzones[0]['Registered']}
    ${zone_name}=  Set Variable  ${partnerzones[0]['zoneid']}

    @{zone_list}=  Create List  ${zone_name}
    @{invalid_list}=  Create List  XX
    @{empty_list}=  Create List

    Run Keyword And Expect Error  ('code=400', 'error={"message":"Zone ID \\\\\"XX\\\\\" not found"}')  Register FederatorZone  zones=${invalid_list}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${super_token}
    Run Keyword And Expect Error  ('code=400', 'error={"message":"Missing federation name \\\\\"\\\\\""}')  Register FederatorZone  zones=${zone_list}  selfoperatorid=${selfoperator}  federation_name=${Empty}  token=${super_token} 

    Run Keyword And Expect Error  ('code=400', 'error={"message":"Must specify the zones to be registered"}')  Register FederatorZone  zones=${empty_list}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${super_token}

    Register FederatorZone  zones=${zone_list}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${super_token}

    Run Keyword And Expect Error  ('code=400', 'error={"message":"Cannot deregister federation \\\\\"${federation_name}\\\\\" as partner zone \\\\\"${zone_name}\\\\\" is registered locally. Please deregister it before deregistering federation"}')  Deregister Federation  federation_name=${federation_name}  selfoperatorid=${selfoperator}

    @{partnerzones}=  ShowFederatedPartnerZone FederatorZone  federation_name=${federation_name}  token=${super_token}
    Should Be True  ${partnerzones[0]['Registered']}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${federation_name}=  Get Default Federation Name

    @{federation}=  Show Federation  federationid=${partner_fed_id}  use_defaults=${False}  token=${super_token}
    @{registered_zones}=  ShowFederatedPartnerZone FederatorZone  federation_name=${federation[0]['name']}  token=${super_token}

    IF  len(@{registered_zones}) > 0
        @{list1}=  Create List  ${registered_zones[0]['zoneid']}
    END

    IF  len(@{federation}) > 0
        SetPartnerApiKey Federation  federation_name=${federation[0]['name']}  selfoperatorid=${selfoperator}  apikey=${partner_api_key}
        IF  '${federation[0]['PartnerRoleShareZonesWithSelf']}' is 'True'
            IF  '${registered_zones[0]['Registered']}' is 'True'
                Deregister FederatorZone  zones=${list1}  selfoperatorid=${selfoperator}  federation_name=${federation[0]['name']}  token=${super_token}
            END
            Deregister Federation  federation_name=${federation[0]['name']}  selfoperatorid=${selfoperator}
        END
        Delete Federation   federation_name=${federation[0]['name']}  selfoperatorid=${selfoperator}
    END 

    Create Federation  selfoperatorid=${selfoperator}  selffederationid=${self_federation_id}  operatorid=${partneroperator}  countrycode=${partnercountrycode}  federationid=${partner_fed_id}  federationaddr=${federationaddr}  apikey=${partner_api_key}

    Set Global Variable  ${super_token}
    Set Global Variable  ${federation_name}

Teardown
   Cleanup Provisioning
