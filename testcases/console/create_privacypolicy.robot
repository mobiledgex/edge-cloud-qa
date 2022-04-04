*** Settings ***
Documentation   Create new Trust Policy
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library         Collections
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${operator_name}  GDDT
${wait}  200

*** Test Cases ***
Web UI - User shall be able to create a Trust Policy with protocol TCP
    [Documentation]
    ...  Create a new Trust Policy with protocol TCP
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

Web UI - User shall be able to create a Trust Policy with protocol UDP
    [Documentation]
    ...  Create a new Trust Policy with protocol UDP
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

Web UI - User shall be able to create and update a Trust Policy with protocol ICMP
    [Documentation]
    ...  Create a new Trust Policy with protocol ICMP
    ...  Verify Policy details in backend

    &{rule1}=  Create Dictionary  protocol=ICMP  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    Trustpolicy Should Exist  rules_count=1  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  ICMP
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    ${ui_details}=  Open Trust Policy Details  region=EU  policy_name=${policy_name}
    Log to Console    ${ui_details}
    Should Be Equal   ${ui_details['Trust Policy Name']}   ${policy_name}
    Should Contain    ${ui_details['Outbound Security Rules']}   Protocol
    Should Contain    ${ui_details['Outbound Security Rules']}   Remote CIDR

    ${val}=           Set Variable  ICMP\n10.10.10.0/24
    Should Contain    ${ui_details['Outbound Security Rules']}   ${val}

    Close Details

    &{rule2}=  Create Dictionary    remote_cidr=10.10.10.0/25
    @{rulelist2}=  Create List  ${rule2}
    MexConsole.Update Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist2}  verify_fields=${rulelist}
    ${ui_details}=  Open Trust Policy Details  region=EU  policy_name=${policy_name}

    ${val}=           Set Variable  ICMP\n10.10.10.0/25
    Should Contain    ${ui_details['Outbound Security Rules']}   ${val}

    Close Details

    MexConsole.Delete Trustpolicy

Web UI - User shall be able to create a Trust Policy with full isolation
    [Documentation]
    ...  Create a new Trust Policy with full isolation
    ...  Verify Policy details in UI

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}  full_isolation=On

    Trustpolicy Should Exist  rules_count=Full Isolation  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules']}  ${None}

    MexConsole.Delete Trustpolicy

Web UI - User shall be able to cancel a new Trust Policy
    [Documentation]
    ...  Cancel a new Trust Policy
    ...  Verify Policy is not present on UI

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}  mode=Cancel

    Trustpolicy Should Not Exist  rules_count=1  change_rows_per_page=True

Web UI - User shall be able to create a Trust Policy with multiple security rules
    [Documentation]
    ...  Create a new Trust Policy with 3 security rules
    ...  Verify Policy Details in backend

    &{rule1}=  Create Dictionary  protocol=ICMP  remote_cidr=1.1.1.1/32
    &{rule2}=  Create Dictionary  protocol=TCP  port_range_minimum=1  port_range_maximum=65  remote_cidr=10.10.10.0/24
    &{rule3}=  Create Dictionary  protocol=UDP  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/25

    @{rulelist}=  Create List  ${rule1}  ${rule2}  ${rule3}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist} 

    Trustpolicy Should Exist  rules_count=3  change_rows_per_page=True

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Log To Console  ${policy_details}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  ICMP
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  1.1.1.1/32
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][1]['protocol']}  TCP
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][1]['port_range_min']}   1
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][1]['port_range_max']}  65
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][1]['remote_cidr']}  10.10.10.0/24
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][2]['protocol']}  UDP
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][2]['port_range_min']}   5
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][2]['port_range_max']}  55
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][2]['remote_cidr']}  10.10.10.0/25

    ${ui_details}=  Open Trust Policy Details  region=EU  policy_name=${policy_name}
    Log to Console    ${ui_details}

    Should Be Equal   ${ui_details['Trust Policy Name']}   ${policy_name}
    Should Contain    ${ui_details['Outbound Security Rules']}   Protocol
    Should Contain    ${ui_details['Outbound Security Rules']}   Remote CIDR
    Should Contain    ${ui_details['Outbound Security Rules']}   Port Range Min
    Should Contain    ${ui_details['Outbound Security Rules']}   Port Range Max

    ${val}=           Set Variable  ICMP\n1.1.1.1/32
    Should Contain    ${ui_details['Outbound Security Rules']}   ${val}

    ${val}=           Set Variable  TCP\n1\n65\n10.10.10.0/24
    Should Contain    ${ui_details['Outbound Security Rules']}   ${val}

    ${val}=           Set Variable  UDP\n5\n55\n10.10.10.0/25
    Should Contain    ${ui_details['Outbound Security Rules']}   ${val}

    Close Details

    MexConsole.Delete Trustpolicy

Web UI - User shall be able to delete a rule while creating Trust Policy with multiple security rules
    [Documentation]
    ...  Create a new Trust Policy with 2 security rules
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
    Run Keyword and Ignore Error  MexMasterController.Delete Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=GDDT

