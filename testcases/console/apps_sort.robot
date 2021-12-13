*** Settings ***
Documentation   Sort Apps

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
	
Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${timeout}
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           15 min
	
*** Test Cases ***
WebUI - User shall be able to sort Apps by AppName
   [Documentation]
   ...  Show all apps
   ...  Sort by app name
   ...  Get all apps from WS
   ...  Verify all apps are sorted properly

   #
   # Sort Ascending With Both Regions
   #
   
   #@{rowsEU}=  Show Apps  region=EU  sort_field=app_name  sort_order=ascending
   #@{rowsUS}=  Show Apps  region=US  sort_field=app_name  sort_order=ascending
   @{ws_asc}=  Show All Apps  sort_field=app_name  sort_order=ascending

   #${num_appsEU}=     Get Length  ${rowsEU}
   #${num_appsUS}=     Get Length  ${rowsUS}
   ${num_apps_ws_asc}=     Get Length  ${ws_asc}


   Sort Apps By App Name
	
   @{table_rows_asc}=  Get Table Data
   ${num_apps_table_asc}=  Get Length  ${table_rows_asc}

   ${counter}=  Set Variable  0
   : FOR  ${row}  IN  @{ws_asc}
   \  Log To Console  ${row}
   \  Log To Console  ${table_rows_asc[${counter}]}
   \  ${ports}=  Get Variable Value  ${row['data']['access_ports']}  -
   \  ${ports}=  Set Variable  ${ports.upper()}
   \  ${deployment}=  Set Variable If  '${row['data']['deployment']}'=='vm'  ${row['data']['deployment'].upper()}  ${row['data']['deployment'].title()}

   \  Should Be Equal  ${table_rows_asc[${counter}][0]}  ${row['data']['region']} 
   \  Should Be Equal  ${table_rows_asc[${counter}][1]}  ${row['data']['key']['developer_key']['name']}
   \  Should Be Equal  ${table_rows_asc[${counter}][2]}  ${row['data']['key']['name']}
   \  Should Be Equal  ${table_rows_asc[${counter}][3]}  ${row['data']['key']['version']}
   \  Should Be Equal  ${table_rows_asc[${counter}][4]}  ${deployment}
   \  Should Be Equal  ${table_rows_asc[${counter}][5]}  ${row['data']['default_flavor']['name']}
   \  Should Be Equal  ${table_rows_asc[${counter}][6]}  ${ports}

   \  ${counter}=  Evaluate  ${counter} + 1
	
   Should Be Equal  ${num_apps_ws_asc}  ${num_apps_table_asc}


   #
   # sort descending
   #
   @{ws_desc}=  Show All Apps  sort_field=app_name  sort_order=descending
   ${num_apps_ws_desc}=     Get Length  ${ws_desc}

   Sort Apps By App Name
	
   @{table_rows_desc}=  Get Table Data
   ${num_apps_table_desc}=  Get Length  ${table_rows_desc}

   ${counter}=  Set Variable  0
   : FOR  ${row}  IN  @{ws_desc}
   \  Log To Console  ${row}
   \  Log To Console  ${table_rows_desc[${counter}]}
   \  ${ports}=  Get Variable Value  ${row['data']['access_ports']}  -
   \  ${ports}=  Set Variable  ${ports.upper()}
   \  ${deployment}=  Set Variable If  '${row['data']['deployment']}'=='vm'  ${row['data']['deployment'].upper()}  ${row['data']['deployment'].title()}

   \  Should Be Equal  ${table_rows_desc[${counter}][0]}  ${row['data']['region']}
   \  Should Be Equal  ${table_rows_desc[${counter}][1]}  ${row['data']['key']['developer_key']['name']}
   \  Should Be Equal  ${table_rows_desc[${counter}][2]}  ${row['data']['key']['name']}
   \  Should Be Equal  ${table_rows_desc[${counter}][3]}  ${row['data']['key']['version']}
   \  Should Be Equal  ${table_rows_desc[${counter}][4]}  ${deployment}
   \  Should Be Equal  ${table_rows_desc[${counter}][5]}  ${row['data']['default_flavor']['name']}
   \  Should Be Equal  ${table_rows_desc[${counter}][6]}  ${ports}

   \  ${counter}=  Evaluate  ${counter} + 1
	
   Should Be Equal  ${num_apps_ws_desc}  ${num_apps_table_desc}

WebUI - User shall be able to sort Apps by Region 
   [Documentation]
   ...  Show all apps
   ...  Sort by region
   ...  Get all apps from WS
   ...  Verify all apps are sorted properly

   #
   # sort ascending
   #
   @{ws_asc}=  Show All Apps  sort_field=region  sort_order=ascending
   ${num_apps_ws_asc}=     Get Length  ${ws_asc}
   
   Sort Apps By Region
	
   @{table_rows_asc}=  Get Table Data
   ${num_apps_table_asc}=  Get Length  ${table_rows_asc}

   ${counter}=  Set Variable  0
   : FOR  ${row}  IN  @{ws_asc}
   \  Log To Console  ${row}
   \  Log To Console  ${table_rows_asc[${counter}]}
   \  ${ports}=  Get Variable Value  ${row['data']['access_ports']}  -
   \  ${ports}=  Set Variable  ${ports.upper()}
   \  ${deployment}=  Set Variable If  '${row['data']['deployment']}'=='vm'  ${row['data']['deployment'].upper()}  ${row['data']['deployment'].title()}

   \  Should Be Equal  ${table_rows_asc[${counter}][0]}  ${row['data']['region']}
   \  Should Be Equal  ${table_rows_asc[${counter}][1]}  ${row['data']['key']['developer_key']['name']}
   \  Should Be Equal  ${table_rows_asc[${counter}][2]}  ${row['data']['key']['name']}
   \  Should Be Equal  ${table_rows_asc[${counter}][3]}  ${row['data']['key']['version']}
   \  Should Be Equal  ${table_rows_asc[${counter}][4]}  ${deployment}
   \  Should Be Equal  ${table_rows_asc[${counter}][5]}  ${row['data']['default_flavor']['name']}
   \  Should Be Equal  ${table_rows_asc[${counter}][6]}  ${ports}

   \  ${counter}=  Evaluate  ${counter} + 1
	
   Should Be Equal  ${num_apps_ws_asc}  ${num_apps_table_asc}


   #
   # sort descending
   #
   @{ws_desc}=  Show All Clusters  sort_field=region  sort_order=descending
   ${num_clusters_ws_desc}=     Get Length  ${ws_desc}

   Sort Clusters By Region
	
   @{table_rows_desc}=  Get Table Data
   ${num_clusters_table_desc}=  Get Length  ${table_rows_desc}

   ${counter}=  Set Variable  0
   : FOR  ${row}  IN  @{ws_desc}
   \  Log To Console  ${row}
   \  Log To Console  ${table_rows_desc[${counter}]}
   \  Should Be Equal  ${row['data']['region']}  ${table_rows_desc[${counter}][0]}
   \  Should Be Equal  ${row['data']['key']['cluster_key']['name']}  ${table_rows_desc[${counter}][1]}
   \  Should Be Equal  ${row['data']['key']['developer']}  ${table_rows_desc[${counter}][2]}
   \  Should Be Equal  ${row['data']['key']['cloudlet_key']['operator_key']['name']}  ${table_rows_desc[${counter}][3]}
   \  ${counter}=  Evaluate  ${counter} + 1
	
   Should Be Equal  ${num_clusters_ws_desc}  ${num_clusters_table_desc}



*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Apps

Teardown
    Close Browser
    Cleanup Provisioning
