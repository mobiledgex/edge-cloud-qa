*** Settings ***
Documentation   Show cluster

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
Web UI - user shall be able show US clusters
   [Documentation]
   ...  Show US clusters
   ...  Get US clusters from WS
   ...  Verify all clusters exist
   [Tags]  passing

   @{ws}=  Show Cluster Instances  region=US  token=${token}  use_defaults=${False}  #sort_field=flavor_name  sort_order=ascending
   ${num_clusters_ws}=     Get Length  ${ws}
   ${num_ws_online}=  Set Variable  0

   Open Cluster Instances
	
   Change Region  US
	
   @{rows}=  Get Table Data
   ${num_clusters_table}=  Get Length  ${rows}
	
   FOR  ${row}  IN  @{ws}
      Cluster Should Exist  region=US  cluster_name=${row['data']['key']['cluster_key']['name']}  developer_name=${row['data']['key']['organization']}  operator_name=${row['data']['key']['cloudlet_key']['organization']}  cloudlet_name=${row['data']['key']['cloudlet_key']['name']}  flavor_name=${row['data']['flavor']['name']}  ip_access=${row['data']['ip_access']}
      ${num_ws_online}=  Run Keyword If  '${row['data']['state']}' == '5'  Evaluate  ${num_ws_online} + 1
      ...  ELSE  Set Variable  ${num_ws_online}
   END

   Cluster Should Show On Map  ${num_ws_online}

   Should Be Equal  ${num_clusters_ws}  ${num_clusters_table}
   
Web UI - user shall be able show EU clusters
   [Documentation]
   ...  Show EU clusters
   ...  Get EU clusters from WS
   ...  Verify all clusters exist
   [Tags]  passing

   @{ws}=  Show Cluster Instances  region=EU  token=${token}  use_defaults=${False}
   ${num_clusters_ws}=     Get Length  ${ws}
   ${num_ws_online}=  Set Variable  0
 
   Open Cluster Instances

   Change Region  EU 

   @{rows}=  Get Table Data
   ${num_clusters_table}=  Get Length  ${rows}
	
   FOR  ${row}  IN  @{ws}
      Cluster Should Exist  region=EU  cluster_name=${row['data']['key']['cluster_key']['name']}  developer_name=${row['data']['key']['organization']}  operator_name=${row['data']['key']['cloudlet_key']['organization']}  cloudlet_name=${row['data']['key']['cloudlet_key']['name']}  flavor_name=${row['data']['flavor']['name']}  ip_access=${row['data']['ip_access']}
      ${num_ws_online}=  Run Keyword If  '${row['data']['state']}' == '5'  Evaluate  ${num_ws_online} + 1
      ...  ELSE  Set Variable  ${num_ws_online}
   END

   Cluster Should Show On Map  ${num_ws_online}

   Should Be Equal  ${num_clusters_ws}  ${num_clusters_table}

Web UI - user shall be able show All clusters
   [Documentation]
   ...  Show All clusters
   ...  Get EU and US clusters from WS
   ...  Verify all clusters exist
   [Tags]  passing

   @{wseu}=  Show Cluster Instances  region=EU  token=${token}  use_defaults=${False}
   @{wsus}=  Show Cluster Instances  region=US  token=${token}  use_defaults=${False}
   ${num_clusters_wsus}=     Get Length  ${wsus}
   ${num_clusters_wseu}=     Get Length  ${wseu}
   ${total_clusters_ws}=  Evaluate  ${num_clusters_wsus}+${num_clusters_wseu}
   ${num_ws_online}=  Set Variable  0
	 		
   Open Cluster Instances

   @{rows}=  Get Table Data
   ${num_clusters_table}=  Get Length  ${rows}
	
   FOR  ${row}  IN  @{wseu}
      Log To Console  ${row['data']['key']['cluster_key']['name']}
      Cluster Should Exist  region=EU  cluster_name=${row['data']['key']['cluster_key']['name']}  developer_name=${row['data']['key']['organization']}  operator_name=${row['data']['key']['cloudlet_key']['organization']}  cloudlet_name=${row['data']['key']['cloudlet_key']['name']}  flavor_name=${row['data']['flavor']['name']}  ip_access=${row['data']['ip_access']}
      ${num_ws_online}=  Run Keyword If  '${row['data']['state']}' == '5'  Evaluate  ${num_ws_online} + 1
      ...  ELSE  Set Variable  ${num_ws_online}
   END

   FOR  ${row}  IN  @{wsus}
      Log To Console  ${row['data']['key']['cluster_key']['name']}
      Cluster Should Exist  region=US  cluster_name=${row['data']['key']['cluster_key']['name']}  developer_name=${row['data']['key']['organization']}  operator_name=${row['data']['key']['cloudlet_key']['organization']}  cloudlet_name=${row['data']['key']['cloudlet_key']['name']}  flavor_name=${row['data']['flavor']['name']}  ip_access=${row['data']['ip_access']}
      ${num_ws_online}=  Run Keyword If  '${row['data']['state']}' == '5'  Evaluate  ${num_ws_online} + 1
      ...  ELSE  Set Variable  ${num_ws_online}
   END

   Cluster Should Show On Map  ${num_ws_online}

   Should Be Equal  ${total_clusters_ws}  ${num_clusters_table}

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    ${token}=  Get Super Token

    Set Suite Variable  ${token}

Teardown
    Close Browser
    Cleanup Provisioning
