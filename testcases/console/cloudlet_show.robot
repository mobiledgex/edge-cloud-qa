*** Settings ***
Documentation   Show cloudlets

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
WebUI - user shall be able show US cloudlets
   [Documentation]
   ...  Show US cloudlets
   ...  Get US cloudlets from WS
   ...  Verify all cloudlets exist
   [Tags]  passing

   @{ws}=  Show Cloudlets  region=US  token=${token}  use_defaults=${False}  #sort_field=flavor_name  sort_order=ascending
   ${num_cloudlets_ws_online}=  Set Variable  0 
   ${num_cloudlets_ws}=  Get Length  ${ws} 

   Open Cloudlets
	
   Change Region  US

   @{rows}=  Get Table Data
   ${num_cloudlets_table}=  Get Length  ${rows}
	
   FOR  ${row}  IN  @{ws}
      Cloudlet Should Exist  region=US  cloudlet_name=${row['data']['key']['name']}  operator_name=${row['data']['key']['organization']}  state=${row['data']['state']} 
      ${num_cloudlets_ws_online}=  Run Keyword If  '${row['data']['state']}' == '5'  Evaluate  ${num_cloudlets_ws_online} + 1
      ...  ELSE  Set Variable  ${num_cloudlets_ws_online}
   END

   Cloudlets Should Show On Map  ${num_cloudlets_ws_online}

   Should Be Equal  ${num_cloudlets_ws}  ${num_cloudlets_table}
   
WebUI - user shall be able show EU cloudlets
   [Documentation]
   ...  Show EU cloudlets
   ...  Get EU cloudlets from WS
   ...  Verify all cloudlets exist

   @{ws}=  Show Cloudlets  region=EU  token=${token}  use_defaults=${False}
   ${num_cloudlets_ws}=     Get Length  ${ws}
   ${num_cloudlets_ws_online}=  Set Variable  0
 
   Open Cloudlets

   Change Region  EU 

   @{rows}=  Get Table Data
   ${num_cloudlets_table}=  Get Length  ${rows}
	
   FOR  ${row}  IN  @{ws}
      Cloudlet Should Exist  region=EU  cloudlet_name=${row['data']['key']['name']}  operator_name=${row['data']['key']['organization']}  state=${row['data']['state']} 
      ${num_cloudlets_ws_online}=  Run Keyword If  '${row['data']['state']}' == '5'  Evaluate  ${num_cloudlets_ws_online} + 1
      ...  ELSE  Set Variable  ${num_cloudlets_ws_online}
   END

   Cloudlets Should Show On Map  ${num_cloudlets_ws_online}

   Should Be Equal  ${num_cloudlets_ws}  ${num_cloudlets_table}

WebUI - user shall be able show All cloudlets
   [Documentation]
   ...  Show All cloudlets
   ...  Get EU and US cloudlets from WS
   ...  Verify all flavors exist
   [Tags]  passing

   @{wseu}=  Show Cloudlets  region=EU  token=${token}  use_defaults=${False}
   @{wsus}=  Show Cloudlets  region=US  token=${token}  use_defaults=${False}
   ${num_cloudlets_wsus}=     Get Length  ${wsus}
   ${num_cloudlets_wseu}=     Get Length  ${wseu}
   ${total_cloudlets_ws}=  Evaluate  ${num_cloudlets_wsus}+${num_cloudlets_wseu}
   ${num_cloudlets_ws_online}=  Set Variable  0
	
   Open Cloudlets

   @{rows}=  Get Table Data
   ${num_cloudlets_table}=  Get Length  ${rows}
	
   FOR  ${row}  IN  @{wseu}
      Log To Console  ${row['data']['key']['name']}
      Cloudlet Should Exist  region=EU  cloudlet_name=${row['data']['key']['name']}  operator_name=${row['data']['key']['organization']}
      ${num_cloudlets_ws_online}=  Run Keyword If  '${row['data']['state']}' == '5'  Evaluate  ${num_cloudlets_ws_online} + 1
      ...  ELSE  Set Variable  ${num_cloudlets_ws_online}
   END

   FOR  ${row}  IN  @{wsus}
      Log To Console  ${row['data']['key']['name']}
      Cloudlet Should Exist  region=US  cloudlet_name=${row['data']['key']['name']}  operator_name=${row['data']['key']['organization']}
      ${num_cloudlets_ws_online}=  Run Keyword If  '${row['data']['state']}' == '5'  Evaluate  ${num_cloudlets_ws_online} + 1
      ...  ELSE  Set Variable  ${num_cloudlets_ws_online}
   END

   Cloudlets Should Show On Map  ${num_cloudlets_ws_online}

   Should Be Equal  ${total_cloudlets_ws}  ${num_cloudlets_table}

*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    ${token}=  Get Supertoken
    Set Suite Variable  ${token}

Teardown
    Close Browser
    Cleanup Provisioning
