*** Settings ***
Documentation   Show apps

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
Web UI - user shall be able show US apps
    [Documentation]
    ...  Show US apps
    ...  Get US apps from WS
    ...  Verify all apps exist
    [Tags]  passing

    @{ws}=  Show Apps  region=US  #sort_field=flavor_name  sort_order=ascending

    Open Apps

    Change Region  US
	
    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{ws}
   \  log to console  ===========================
   \  Log To Console  key=${row['data']['key']['name']}
   \  ${ports}=  Get Variable Value  ${row['data']['access_ports']}  -
   \  ${ports}=  Set Variable  ${ports.upper()}
   \  ${deployment}=  Set Variable If  '${row['data']['deployment']}'=='vm'  ${row['data']['deployment'].upper()}  ${row['data']['deployment'].title()}
   \  Log to Console  deployemnt=${deployment}
   \  Log to console  ports=${ports}
   \  App Should Exist  region=US  app_name=${row['data']['key']['name']}  org_name=${row['data']['key']['developer_key']['name']}  app_version=${row['data']['key']['version']}  deployment_type=${deployment}  default_flavor_name=${row['data']['default_flavor']['name']}  ports=${ports}
	
   ${num_apps_ws}=     Get Length  ${ws}
   ${num_apps_table}=  Get Length  ${rows}

   Should Be Equal  ${num_apps_ws}  ${num_apps_table}
   
Web UI - user shall be able show EU apps
    [Documentation]
    ...  Show EU apps
    ...  Get EU apps from WS
    ...  Verify all apps exist
    [Tags]  passing

    @{ws}=  Show Apps  region=EU

    Open Apps

    Change Region  EU 

    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{ws}
   \  Log To Console  key=${row['data']['key']['name']}
   \  ${ports}=  Get Variable Value  ${row['data']['access_ports']}  -
   \  ${ports}=  Set Variable  ${ports.upper()}
   \  ${deployment}=  Set Variable  ${row['data']['deployment'].title()}
   \  Log to Console  deploy=${deployment}
   \  Log to Console  app_name=${row['data']['key']['name']} org_name=${row['data']['key']['developer_key']['name']} app_version=${row['data']['key']['version']} deployment_type=${deployment} default_flavor=${row['data']['default_flavor']['name']} ports=${ports}
   \  App Should Exist  region=EU  app_name=${row['data']['key']['name']}  org_name=${row['data']['key']['developer_key']['name']}  app_version=${row['data']['key']['version']}  deployment_type=${deployment}  default_flavor_name=${row['data']['default_flavor']['name']}  ports=${ports}

   ${num_apps_ws}=     Get Length  ${ws}
   ${num_apps_table}=  Get Length  ${rows}

   Should Be Equal  ${num_apps_ws}  ${num_apps_table}

Web UI - user shall be able show All Apps
    [Documentation]
    ...  Show All apps
    ...  Get EU and US apps from WS
    ...  Verify all apps exist
    [Tags]  passing

    # need to add some flavor on US and EU region so we can be sure some exist when we run it. can do this in setup

    @{wseu}=  Show Apps  region=EU
    @{wsus}=  Show Apps  region=US

    Open Apps

    @{rows}=  Get Table Data

   : FOR  ${row}  IN  @{wseu}
   \  Log To Console  ${row['data']['key']['name']}
   \  ${ports}=  Get Variable Value  ${row['data']['access_ports']}  -
   \  ${ports}=  Set Variable  ${ports.upper()}
   \  ${deployment}=  Set Variable If  '${row['data']['deployment']}'=='vm'  ${row['data']['deployment'].upper()}  ${row['data']['deployment'].title()}
   \  Log to Console  ${deployment}
   \  App Should Exist  region=EU  app_name=${row['data']['key']['name']}  org_name=${row['data']['key']['developer_key']['name']}  app_version=${row['data']['key']['version']}  deployment_type=${deployment}  default_flavor_name=${row['data']['default_flavor']['name']}  ports=${ports}

   : FOR  ${row}  IN  @{wsus}
   \  Log To Console  ${row['data']['key']['name']}
   \  ${ports}=  Get Variable Value  ${row['data']['access_ports']}  -
   \  ${ports}=  Set Variable  ${ports.upper()}
   \  ${deployment}=  Set Variable If  '${row['data']['deployment']}'=='vm'  ${row['data']['deployment'].upper()}  ${row['data']['deployment'].title()}
   \  Log to Console  ${deployment}
   \  App Should Exist  region=US  app_name=${row['data']['key']['name']}  org_name=${row['data']['key']['developer_key']['name']}  app_version=${row['data']['key']['version']}  deployment_type=${deployment}  default_flavor_name=${row['data']['default_flavor']['name']}  ports=${ports}

   ${num_apps_wsus}=  Get Length  ${wsus}
   ${num_apps_wseu}=  Get Length  ${wseu}
   ${total_apps_ws}=  Evaluate  ${num_apps_wsus}+${num_apps_wseu}

   ${num_apps_table}=  Get Length  ${rows}

   Should Be Equal  ${total_apps_ws}  ${num_apps_table}

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning
