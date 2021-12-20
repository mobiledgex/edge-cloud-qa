*** Settings ***
Documentation   Create new cloudlet

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         DateTime
Library         Collections

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    20 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra

*** Test Cases ***
WebUI - Update Cloudlet to map an existing cloudlet to a different trust policy
    [Documentation]
    ...  Create a new cloudlet and map it to trust policy , say policy A
    ...  Update Cloudlet to map the cloudlet to trust policy B
    [Tags]  passing

    Open Cloudlets

    Search Cloudlet  cloudlet_name=${cloudlet_name}
    MexConsole.Update Cloudlet  region=US  cloudlet_name=${cloudlet_name}  operator=packet  trust_policy=${policy_name}

    ${cloudlet_details}=    Show Cloudlets  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=packet
    Should Be Equal  ${cloudlet_details[0]['data']['trust_policy']}   ${policy_name}

    ${time}=  Set Variable  ${cloudlet_details[0]['data']['updated_at']['seconds']}
    Log to Console  ${time}
    ${timestamp}=  Convert Date  ${time}  exclude_millis=yes
    Log to Console  ${timestamp}

    ${details}=  Open Cloudlet Details  region=US  cloudlet_name=${cloudlet_name}
    Log to Console  ${details}
    Should Be Equal   ${details['Updated']}   ${timestamp}
    Should Be Equal   ${details['Trust Policy']}  ${policy_name}
    Close Cloudlet Details

    Search Cloudlet  cloudlet_name=${cloudlet_name}
    MexConsole.Delete Cloudlet  cloudlet_name=${cloudlet_name}  region=US  operator=packet
    Cloudlet Should Not Exist  cloudlet_name=${cloudlet_name}  region=US  operator_name=packet

WebUI - Update Cloudlet to remove a trust policy from an existing cloudlet
    [Documentation]
    ...  Create a new cloudlet and map it to trust policy , say policy A
    ...  Update Cloudlet to remove the trust policy from the cloudlet
    [Tags]  passing

    Open Cloudlets

    Search Cloudlet  cloudlet_name=${cloudlet_name}
    MexConsole.Update Cloudlet  region=US  cloudlet_name=${cloudlet_name}  operator=packet  trust_policy=RemovePolicy

    ${cloudlet_details}=    Show Cloudlets  region=US  cloudlet_name=${cloudlet_name}  operator_org_name=packet
    Dictionary Should Not Contain Key  ${cloudlet_details[0]['data']}   trust_policy

    ${time}=  Set Variable  ${cloudlet_details[0]['data']['updated_at']['seconds']}
    Log to Console  ${time}
    ${timestamp}=  Convert Date  ${time}  exclude_millis=yes
    Log to Console  ${timestamp}

    ${details}=  Open Cloudlet Details  region=US  cloudlet_name=${cloudlet_name}
    Log to Console  ${details}
    Should Be Equal   ${details['Updated']}   ${timestamp}
    Dictionary Should Not Contain Key  ${details}  Trust Policy
    Close Cloudlet Details

    Search Cloudlet  cloudlet_name=${cloudlet_name}
    MexConsole.Delete Cloudlet  cloudlet_name=${cloudlet_name}  region=US  operator=packet
    Cloudlet Should Not Exist  cloudlet_name=${cloudlet_name}  region=US  operator_name=packet

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${cloudlet_name}=  Get Default Cloudlet Name
    ${policy_name}=  Get Default Trust Policy Name
    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}
    Open Browser
    Login to Mex Console  browser=${browser}
    MexMasterController.Create Cloudlet  region=US  operator_org_name=packet  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  trust_policy=automation_trust_policy
    MexMasterController.Create Trust Policy  region=US  policy_name=${policy_name}  operator_org_name=packet  rule_list=@{rulelist}
    Open Compute
    Set Suite Variable  ${token}
    Set Suite Variable  ${cloudlet_name}
    Set Suite Variable  ${policy_name}

Teardown
    MexMasterController.Delete Trust Policy  region=US  policy_name=${policy_name}  operator_org_name=packet
    Close Browser 
