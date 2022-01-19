*** Settings ***
Documentation   Federation Resource Manager

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS_FEDERATION}   root_cert=%{AUTOMATION_MC_CERT}  mc_password=%{AUTOMATION_MC_PASSWORD}
Library  MexApp
Library  String

Suite Setup  Setup
Suite Teardown  Teardown 

Test Timeout    ${test_timeout_crm}

*** Variables ***
${operator}=           packet

*** Keywords ***
Setup
   ${partner_super_token}=  Get Super Token
   ${zone1}=  Get Default Federator Zone
   ${zone2}=  Generate Random String  8  [LETTERS][NUMBERS]

   ${output}=  Show Federation  federation_name=${partner_federation_name}  token=${partner_super_token}
   ${federation_id}=  Set Variable  ${output[0]['selffederationid']}

   ${generate_api}=  GenerateSelfApiKey Federator  operatorid=${operator}  federationid=${federationid}
   ${new_apikey}=  Set Variable  ${generate_api['apikey']}

   @{self_zones}=  ShowFederatedSelfZone FederatorZone  federation_name=${partner_federation_name}  token=${partner_super_token}
   ${length}=  Get Length  ${self_zones}

   Set Global Variable  ${partner_fed_id}  ${federation_id}
   Set Global Variable  ${partner_api_key}  ${new_apikey}
   Set Global Variable  ${number_of_federatedzones}  ${length}
   Set Global Variable  ${partner_super_token}

Teardown
   Unshare FederatorZone  federation_name=${partner_federation_name}  zoneid=Zone-ABC  selfoperatorid=${operator}  token=${partner_super_token}
   Cleanup Provisioning


