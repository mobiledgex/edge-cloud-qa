*** Settings ***
Documentation   Update an existing Privacy Policy
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
Web UI - User shall be able to update Protocol in an existing Privacy Policy
    [Documentation]
    ...  Create a new Privacy Policy with protocol TCP
    ...  Update Privacy Policy with protocol UDP

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    &{rule2}=  Create Dictionary  protocol=udp
    @{rulelist1}=  Create List  ${rule2}

    MexConsole.Update Trustpolicy  rule_list=${rulelist1}

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  udp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   5
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  55
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy  change_rows_per_page=True

Web UI - User shall be able to update port_range_min in an existing Privacy Policy
    [Documentation]
    ...  Create a new Privacy Policy 
    ...  Update port_range_min

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    &{rule2}=  Create Dictionary  port_range_minimum=20
    @{rulelist1}=  Create List  ${rule2}

    MexConsole.Update Trustpolicy  rule_list=${rulelist1}

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  tcp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   20
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  55
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy  change_rows_per_page=True

Web UI - User shall be able to update port_range_max in an existing Privacy Policy
    [Documentation]
    ...  Create a new Privacy Policy 
    ...  Update port_range_max

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    &{rule2}=  Create Dictionary  port_range_maximum=60
    @{rulelist1}=  Create List  ${rule2}

    MexConsole.Update Trustpolicy  rule_list=${rulelist1}

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  tcp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   5
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  60
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy  change_rows_per_page=True

Web UI - User shall be able to update remote_cidr in an existing Privacy Policy
    [Documentation]
    ...  Create a new Privacy Policy 
    ...  Update remote_cidr

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    &{rule2}=  Create Dictionary  remote_cidr=20.20.20.0/24
    @{rulelist1}=  Create List  ${rule2}

    MexConsole.Update Trustpolicy  rule_list=${rulelist1}

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  tcp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   5
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  55
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  20.20.20.0/24

    MexConsole.Delete Trustpolicy  change_rows_per_page=True

Web UI - User shall be able to update a Privacy Policy to enable full isolation
    [Documentation]
    ...  Create a new Privacy Policy with protocol TCP
    ...  Update Privacy Policy to enable full isolation

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    &{rule2}=  Create Dictionary  full_isolation=On
    @{rulelist1}=  Create List  ${rule2}

    MexConsole.Update Trustpolicy  rule_list=${rulelist1}

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules']}  ${None}

    MexConsole.Delete Trustpolicy  change_rows_per_page=True

Web UI - User shall be able to update all fields in an existing Privacy Policy
    [Documentation]
    ...  Create a new Privacy Policy 
    ...  Update Privacy Policy to change all fields

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    &{rule2}=  Create Dictionary  protocol=udp  port_range_minimum=2000  port_range_maximum=6000  remote_cidr=20.20.20.0/24
    @{rulelist1}=  Create List  ${rule2}

    MexConsole.Update Trustpolicy  rule_list=${rulelist1}

    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  udp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   2000
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  6000
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  20.20.20.0/24

    MexConsole.Delete Trustpolicy  change_rows_per_page=True

Web UI - User shall be able to delete a rule while updating Privacy Policy with multiple security rules
    [Documentation]
    ...  Create a new Privacy Policy with 2 security rules
    ...  Update Privacy Policy to delete one rule 

    &{rule1}=  Create Dictionary  protocol=icmp  remote_cidr=1.1.1.1/32
    &{rule2}=  Create Dictionary  protocol=tcp  port_range_minimum=1  port_range_maximum=65  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}  ${rule2}

    Add New Trustpolicy  region=EU  developer_org_name=${operator_name}  policy_name=${policy_name}  rule_list=${rulelist}

    MexConsole.Update Trustpolicy  delete_rule=On
    ${policy_details}=    Show Trust Policy  region=EU  policy_name=${policy_name}  operator_org_name=${operator_name}
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  tcp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   1
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  65
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexConsole.Delete Trustpolicy  change_rows_per_page=True

Web UI - User shall be able to update an existing Trust Policy which is mapped to a cloudlet
    [Documentation]
    ...  Create a new Privacy Policy with protocol TCP
    ...  Create a cloudlet and assign the policy to it 
    ...  Update Privacy Policy with protocol UDP

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}

    Add New Trustpolicy  region=US  developer_org_name=packet  policy_name=${policy_name}  rule_list=${rulelist}
    MexMasterController.Create Cloudlet  region=US  operator_org_name=packet  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  trust_policy=${policy_name}

    &{rule2}=  Create Dictionary  protocol=udp
    @{rulelist1}=  Create List  ${rule2}
    @{cloudletlist}=  Create List  ${cloudlet_name}

    MexConsole.Update Trustpolicy  rule_list=${rulelist1}  cloudlets=@{cloudletlist}

    ${policy_details}=    Show Trust Policy  region=US  policy_name=${policy_name}  operator_org_name=packet
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  udp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   5
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  55
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexMasterController.Delete Cloudlet  region=US  operator_org_name=packet  cloudlet_name=${cloudlet_name}
    MexConsole.Delete Trustpolicy  change_rows_per_page=True

Web UI - User shall be able to update an existing Trust Policy which is mapped to 2 cloudlets
    [Documentation]
    ...  Create a new Privacy Policy with protocol TCP
    ...  Create a cloudlet and assign the policy to it
    ...  Update Privacy Policy with protocol UDP

    &{rule1}=  Create Dictionary  protocol=tcp  port_range_minimum=5  port_range_maximum=55  remote_cidr=10.10.10.0/24
    @{rulelist}=  Create List  ${rule1}
    ${cloudlet_name1}=  Catenate  SEPARATOR=  ${cloudlet_name}  2
    @{cloudletlist}=  Create List  ${cloudlet_name}  ${cloudlet_name1}

    Add New Trustpolicy  region=US  developer_org_name=packet  policy_name=${policy_name}  rule_list=${rulelist}
    MexMasterController.Create Cloudlet  region=US  operator_org_name=packet  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=31  longitude=-91  trust_policy=${policy_name}
    MexMasterController.Create Cloudlet  region=US  operator_org_name=packet  cloudlet_name=${cloudlet_name1}  platform_type=PlatformTypeFake  number_dynamic_ips=254  latitude=32  longitude=-92  trust_policy=${policy_name}

    &{rule2}=  Create Dictionary  protocol=udp
    @{rulelist1}=  Create List  ${rule2}

    MexConsole.Update Trustpolicy  rule_list=${rulelist1}  cloudlets=@{cloudletlist}

    ${policy_details}=    Show Trust Policy  region=US  policy_name=${policy_name}  operator_org_name=packet
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['protocol']}  udp
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_min']}   5
    Should Be Equal As Integers  ${policy_details[0]['data']['outbound_security_rules'][0]['port_range_max']}  55
    Should Be Equal  ${policy_details[0]['data']['outbound_security_rules'][0]['remote_cidr']}  10.10.10.0/24

    MexMasterController.Delete Cloudlet  region=US  operator_org_name=packet  cloudlet_name=${cloudlet_name}
    MexMasterController.Delete Cloudlet  region=US  operator_org_name=packet  cloudlet_name=${cloudlet_name1}
    MexConsole.Delete Trustpolicy  change_rows_per_page=True

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
