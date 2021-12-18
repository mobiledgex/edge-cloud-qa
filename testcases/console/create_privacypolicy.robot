*** Settings ***
Documentation   Create new Privacy Policy
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections
Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${operator_name}  TDG
${wait}  200

*** Test Cases ***
Web UI - User shall be able to create a Privacy Policy with protocol TCP
    [Documentation]
    ...  Create a new Privacy Policy with protocol TCP
    ...  Verify Policy details in backend

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    Trustpolicy Should Exist  rules_count=1  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  tcp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   5
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  55
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy 

Web UI - User shall be able to create a Privacy Policy with protocol UDP
    [Documentation]
    ...  Create a new Privacy Policy with protocol UDP
    ...  Verify Policy details in backend

    &{rule1}=  Create Dictionary  protocol=udp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    Trustpolicy Should Exist  rules_count=1  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  udp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   5
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  55
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy

Web UI - User shall be able to create a Privacy Policy with protocol ICMP
    [Documentation]
    ...  Create a new Privacy Policy with protocol ICMP
    ...  Verify Policy details in backend

    &{rule1}=  Create Dictionary  protocol=icmp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    Trustpolicy Should Exist  rules_count=1  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  icmp
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy

Web UI - User shall be able to create a Privacy Policy with full isolation
    [Documentation]
    ...  Create a new Privacy Policy with full isolation
    ...  Verify Policy details in UI

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}  full_isolation=On

    Trustpolicy Should Exist  rules_count=Full Isolation  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules']}  ${None}

    MexConsole.Delete Trustpolicy

Web UI - User shall be able to cancel a new Privacy Policy 
    [Documentation]
    ...  Cancel a new Privacy Policy 
    ...  Verify Policy is not present on UI

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}  mode=Cancel

    Trustpolicy Should Not Exist  rules_count=1  change_rows_per_page=True

Web UI - User shall be able to create a Privacy Policy with multiple security rules
    [Documentation]
    ...  Create a new Privacy Policy with 2 security rules
    ...  Verify Policy Details in backend

    &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/32
    &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}  ${rule2}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist} 

    Trustpolicy Should Exist  rules_count=2  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  icmp
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  1.1.1.1/32
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][1]['protocol']}  tcp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][1]['port_range_min']}   1
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][1]['port_range_max']}  65
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][1]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy

Web UI - User shall be able to delete a rule while creating Privacy Policy with multiple security rules
    [Documentation]
    ...  Create a new Privacy Policy with 2 security rules
    ...  Delete one rule and verify Policy Details in backend

    &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/32
    &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}  ${rule2}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}   delete_rule=On

    Trustpolicy Should Exist  rules_count=1  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  tcp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   1
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  65
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy

*** Keywords ***
Setup
    ${token}=  Get Supertoken
    ${policy_name}=  Get Default Trust Policy Name
    Open Browser
    Login to Mex Console  browser=${browser}
    Open Compute
    Open Policies
    Open Trustpolicy
    Set Suite Variable  ${token}
    Set Suite Variable  ${policy_name}

Teardown
    Close Browser
