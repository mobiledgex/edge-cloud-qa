*** Settings ***
Documentation     Federation Resource Manager

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Timeout  10m

*** Variables ***
${selfoperator}  GDDT
${region}  EU
${selfcountrycode}  DE


*** Test Cases ***
# ECQ-3755
Shall be able to create new federatorzones and share them 
    [Documentation]
    ...  Login as OperatorContributor
    ...  Create a new federatorzone
    ...  Share the zone with partner

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000  token=${op1_token}

    Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  use_defaults=${False}  token=${op1_token}

    Share FederatorZone  zoneid=${federator_zone}  selfoperatorid=${selfoperator}  federation_name=${federation_name}  token=${op1_token}

    @{selfzones}=  ShowFederatedSelfZone FederatorZone  federation_name=${federation_name}  token=${op1_token}
    Length Should Be  ${selfzones}  1

*** Keywords ***
Setup
   ${federator_zone}=  Get Default Federator Zone
   ${cloudlet_name}=  Get Default Cloudlet Name

   @{zone_list}=  Create List  ${cloudlet_name}

   Run Keyword And Ignore Error  Adduser Role  username=${op_contributor_user_automation}  orgname=${selfoperator}  role=OperatorContributor  token=${super_token}
   ${op1_token}=  Login  username=${op_contributor_user_automation}  password=${op_contributor_password_automation}

   Set Suite Variable  @{zone_list}
   Set Suite Variable  ${op1_token}
   Set Suite Variable  ${federator_zone}
   Set Suite Variable  ${cloudlet_name}
   Set Global Variable  ${selfzone}  ${federator_zone}
