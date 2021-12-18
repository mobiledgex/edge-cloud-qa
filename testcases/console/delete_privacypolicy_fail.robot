*** Settings ***
Documentation   Update an existing Privacy Policy
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    10 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${operator_name}  packet
${wait}  200

*** Test Cases ***
Web UI - User shall not be able to delete a trust policy when it is in use by a cloudlet
    [Documentation]
    ...  Create a new Trust Policy with protocol TCP
    ...  Create a cloudlet which is mapped to this policy
    ...  Deleting trust policy should fail

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=US  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}
    Trustpolicy Should Exist  rules_count=1  change_rows_per_page=True
    MexMasterController.Create Cloudlet  region=US  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  trust_policy=${policy_name}

    MexConsole.Delete Trustpolicy  cloudlet_name=${cloudlet_name}  result=fail

    MexMasterController.Delete Cloudlet  region=US  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}
    MexConsole.Delete Trustpolicy

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${policy_name}=  Get Default Trust Policy Name
    ${cloudlet_name}=  Get Default Cloudlet Name
    Open Browser
    Login to Mex Console  browser=${browser}
    Open Compute
    Open Policies
    Open Trustpolicy
    Set Suite Variable  ${token}
    Set Suite Variable  ${policy_name}
    Set Suite Variable  ${cloudlet_name}

Teardown
    Close Browser
