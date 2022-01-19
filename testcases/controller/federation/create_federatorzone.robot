*** Settings ***
Documentation    Create FederatorZone test

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup  Setup
Test Teardown  Cleanup Provisioning
Test Timeout  10m

*** Variables ***
${selfoperator}  GDDT
${region}  EU
${selfcountrycode}  DE
${city}   Sunnydale
${state}  Bavaria
${locality}  Urban

*** Test Cases ***
# ECQ-4241
Shall be able to create federatorzone with all optional arguments
    [Documentation]
    ...  Login as MexAdmin
    ...  Create/View/Delete a federatorzone

    @{cloudlets}=  Create List  ${cloudlet_name}

    Create Cloudlet  region=${region}  operator_org_name=${selfoperator}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  env_vars=FAKE_RAM_MAX=4096000,FAKE_VCPUS_MAX=1000,FAKE_DISK_MAX=100000

    Create FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  cloudlets=${cloudlets}  geolocation=50,50  region=${region}  zoneid=${federator_zone}  city=${city}  state=${state}  locality=${locality}  use_defaults=${False}  auto_delete=${False}

    ${show_federatorzone}=  Show FederatorZone  zoneid=${federator_zone}  region=${region}  token=${super_token}
    Should Be Equal  ${show_federatorzone[0]['cloudlets'][0]}  ${cloudlet_name}
    Should Be Equal  ${show_federatorzone[0]['zoneid']}  ${federator_zone}
    Should Be Equal  ${show_federatorzone[0]['city']}  ${city}
    Should Be Equal  ${show_federatorzone[0]['state']}  ${state}
    Should Be Equal  ${show_federatorzone[0]['locality']}  ${locality}

    Delete FederatorZone  operatorid=${selfoperator}  countrycode=${selfcountrycode}  zoneid=${federator_zone}  token=${super_token}

*** Keywords ***
Setup
    ${super_token}=  Get Super Token
    ${federator_zone}=  Get Default Federator Zone
    ${cloudlet_name}=  Get Default Cloudlet Name

    Set Suite Variable  ${super_token}
    Set Suite Variable  ${federator_zone}
    Set Suite Variable  ${cloudlet_name}
