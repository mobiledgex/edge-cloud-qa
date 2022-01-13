*** Settings ***
Documentation     Federation Resource Manager

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS_FEDERATION}   root_cert=%{AUTOMATION_MC_CERT}  mc_password=%{AUTOMATION_MC_PASSWORD}
Library  MexApp
Library  String
Library  Collections

*** Variables ***
${operator}=           packet
${countrycode}=        SG

*** Test Cases ***
Partner shall be able to share zones
    [Documentation]
    ...  Login as MexAdmin
    ...  Controller throws error when unsharing federatorzone which is already registered by partner
    ...  Controller throws error when sharing federatorzone with invalid zoneid
    ...  Controller throws error when sharing federatorzone with invalid selfoperatorid
    ...  Controller throws error when sharing the same zone twice with same partner
    ...  Share another federatorzone with partner

    ${zoneid1}=  Generate Random String  8  [LETTERS][NUMBERS]

    # Unshare zone already registered by partner
    Run Keyword And Expect Error  ('code=400', 'error={"message":"Cannot unshare zone \\\\\"Zone-XYZ\\\\\" as it is registered as part of federation \\\\\"controllerfed\\\\\". Please deregister it first"}')  Unshare FederatorZone  federation_name=${partner_federation_name}  zoneid=Zone-XYZ  selfoperatorid=${operator}  token=${partner_super_token}

    # Invalid zoneid
    Run Keyword And Expect Error  ('code=400', 'error={"message":"Zone ID \\\\\"${zoneid1}\\\\\" not found for operatorID:\\\\\"${operator}\\\\\"\/countrycode:\\\\\"${countrycode}\\\\\""}')   Share FederatorZone  federation_name=${partner_federation_name}  zoneid=${zoneid1}  selfoperatorid=${operator}  token=${partner_super_token}

    # Invalid selfoperatorid
    Run Keyword And Expect Error  ('code=400', 'error={"message":"Federation with name \\\\\"${partner_federation_name}\\\\\" does not exist for self operator ID \\\\\"GDDT\\\\\""}')   Share FederatorZone  federation_name=${partner_federation_name}  zoneid=Zone-ABC  selfoperatorid=GDDT  token=${partner_super_token}

    # Share a zone twice with same partner
    Run Keyword And Expect Error  ('code=400', 'error={"message":"Zone ID \\\\\"Zone-XYZ\\\\\" already exists for partner federator ${partner_fed_id}"}')  Share FederatorZone  federation_name=${partner_federation_name}  zoneid=Zone-XYZ  selfoperatorid=${operator}  token=${partner_super_token}

    Share FederatorZone  federation_name=${partner_federation_name}  zoneid=Zone-ABC  selfoperatorid=${operator}  token=${partner_super_token}

    @{partnerzones}=  ShowFederatedSelfZone FederatorZone  federation_name=${partner_federation_name}  token=${partner_super_token}
    Length Should Be  ${partnerzones}  2
