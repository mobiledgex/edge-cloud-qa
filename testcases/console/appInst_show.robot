*** Settings ***
Documentation   Show appinsts

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
	
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}     15 min

*** Test Cases ***
Web UI - user shall be able show US app instances
    [Documentation]
    ...  Show US app instances
    ...  Get US instances from WS
    ...  Verify all instances exist
    [Tags]  passing

    # need to add some flavor on US region so we can be sure some exist when we run it. can do this in setup

    @{ws}=  Show App Instances  region=US  #sort_field=flavor_name  sort_order=ascending
    ${num_appinstances_ws}=  Get Length  ${ws}

    Log to console  ${ws[0]['data']['key']['app_key']['name']}	

    Open App Instances

    Change Region  US
	
    @{rows}=  Get Table Data
    ${num_appinstances_table}=  Get Length  ${rows}
	
   : FOR  ${row}  IN  @{ws}
   \  Log To Console  ${row['data']['key']['app_key']['name']}
   \  ${state}=  Get Variable Value  ${row['data']['state']} 
   \  ${state_string}=  Set Variable If  ${state} == 5  Ready  Error
   \  App Instance Should Exist  region=US  app_name=${row['data']['key']['app_key']['name']}  org_name=${row['data']['key']['app_key']['developer_key']['name']}  app_version=${row['data']['key']['app_key']['version']}  operator_name=${row['data']['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name']}  cloudlet_name=${row['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  cluster_instance=${row['data']['key']['cluster_inst_key']['cluster_key']['name']}  latitude=${row['data']['cloudlet_loc']['latitude']}  longitude=${row['data']['cloudlet_loc']['longitude']}  state=${state} 
	
   Should Be Equal  ${num_appinstances_ws}  ${num_appinstances_table}
   
Web UI - user shall be able show EU flavors
    [Documentation]
    ...  Show EU flavors
    ...  Get EU flavors from WS
    ...  Verify all flavors exist

    # need to add some flavor on US region so we can be sure some exist when we run it. can do this in setup

    @{ws}=  Show Flavors  region=EU
    Log to console  ${ws[0]['data']['key']['name']}
    Open Flavors

    Change Region  EU 

    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{ws}
   \  Log To Console  ${row['data']['key']['name']}
   \  Flavor Should Exist  region=US  flavor_name=${row['data']['key']['name']}  ram=${row['data']['ram']}  vcpus=${row['data']['vcpus']}  disk=${row['data']['disk']}

   ${num_flavors_ws}=     Get Length  ${ws}
   ${num_flavors_table}=  Get Length  ${rows}

   Should Be Equal  ${num_flavors_ws}  ${num_flavors_table}

Web UI - user shall be able show All app instances
    [Documentation]
    ...  Show All app instances 
    ...  Get EU and US app instances from WS
    ...  Verify all app instances exist
    [Tags]  passing

    # need to add some flavor on US and EU region so we can be sure some exist when we run it. can do this in setup

    @{wseu}=  Show App Instances  region=EU
    @{wsus}=  Show App Instances  region=US
    ${num_appinstances_wsus}=  Get Length  ${wsus}
    ${num_appinstances_wseu}=  Get Length  ${wseu}
    ${total_appinstances_ws}=  Evaluate  ${num_appinstances_wsus}+${num_appinstances_wseu}

    Open App Instances 

    @{rows}=  Get Table Data
    ${num_appinstances_table}=  Get Length  ${rows}

   : FOR  ${row}  IN  @{wseu}
   \  Log To Console  ${row['data']['key']['app_key']['name']}
   \  ${state}=  Get Variable Value  ${row['data']['state']}
   \  ${state_string}=  Set Variable If  ${state} == 5  Ready  Error
   \  App Instance Should Exist  region=US  app_name=${row['data']['key']['app_key']['name']}  org_name=${row['data']['key']['app_key']['developer_key']['name']}  app_version=${row['data']['key']['app_key']['version']}  operator_name=${row['data']['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name']}  cloudlet_name=${row['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  cluster_instance=${row['data']['key']['cluster_inst_key']['cluster_key']['name']}  latitude=${row['data']['cloudlet_loc']['latitude']}  longitude=${row['data']['cloudlet_loc']['longitude']}  state=${state_string}

   : FOR  ${row}  IN  @{wsus}
   \  Log To Console  ${row['data']['key']['app_key']['name']}
   \  ${state}=  Get Variable Value  ${row['data']['state']}
   \  ${state_string}=  Set Variable If  ${state} == 5  Ready  Error
   \  App Instance Should Exist  region=US  app_name=${row['data']['key']['app_key']['name']}  org_name=${row['data']['key']['app_key']['developer_key']['name']}  app_version=${row['data']['key']['app_key']['version']}  operator_name=${row['data']['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name']}  cloudlet_name=${row['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  cluster_instance=${row['data']['key']['cluster_inst_key']['cluster_key']['name']}  latitude=${row['data']['cloudlet_loc']['latitude']}  longitude=${row['data']['cloudlet_loc']['longitude']}  state=${state_string}

   Should Be Equal  ${total_appinstances_ws}  ${num_appinstances_table}

*** Keywords ***
Setup
    #create some flavors
    Open Browser
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning
