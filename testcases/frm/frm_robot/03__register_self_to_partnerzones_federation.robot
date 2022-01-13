*** Settings ***
Documentation     Federation Resource Manager

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
${partneroperator}  packet


*** Test Cases ***
# ECQ-3755
Shall be able to register/deregister to multiple partner zones and view zones as cloudlets
    [Documentation]
    ...  Login as OperatorContributor
    ...  Register to partner zone
    ...  Validate output of federatorzone showfederatedpartnerzone
    ...  Deregister/Register multiple partner federatorzones
    ...  Validate output of cloudlet show

    Register FederatorZone  zones=${zone_list}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${op1_token}

    @{partnerzones}=  ShowFederatedPartnerZone FederatorZone  federation_name=${federation_name}  token=${op1_token}
    Should Be True  ${partnerzones[0]['Registered']}
    Should Be True  ${partnerzones[1]['Registered']}

    Append to List  ${zone_list}  Zone-XYZ

    # Deregister multiple partner zones
    Deregister FederatorZone  zones=${zone_list}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${op1_token}

    @{partnerzones}=  ShowFederatedPartnerZone FederatorZone  federation_name=${federation_name}  token=${op1_token}
    Should Not Be True  ${partnerzones[0]['Registered']}
    Should Not Be True  ${partnerzones[1]['Registered']}

    # Register multiple partner zones
    Register FederatorZone  zones=${zone_list}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${op1_token}

    @{partnerzones}=  ShowFederatedPartnerZone FederatorZone  federation_name=${federation_name}  registered=${True}  token=${op1_token}
    Length Should Be  ${partnerzones}  2

    ${cloudlet1}=  Show Cloudlets  region=${region}  cloudlet_name=Zone-XYZ  token=${op1_token}
    Should Be Equal  ${cloudlet1[0]['data']['platform_type']}  Federation
    Should Be Equal  ${cloudlet1[0]['data']['physical_name']}   Zone-XYZ
    Should Be Equal  ${cloudlet1[0]['data']['key']['federated_organization']}  ${partneroperator}
    Should Be Equal  ${cloudlet1[0]['data']['state']}  Ready

*** Keywords ***
Setup
   @{zone_list}=  Create List  Zone-ABC

   Run Keyword And Ignore Error  Adduser Role  username=${op_contributor_user_automation}  orgname=${selfoperator}  role=OperatorContributor  token=${super_token}
   ${op1_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

   Set Suite Variable  @{zone_list}
   Set Suite Variable  ${op1_token}

Teardown
   Deregister FederatorZone  zones=${zone_list}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${op1_token}
