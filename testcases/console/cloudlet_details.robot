*** Settings ***
Documentation   View cloudlet details

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
	
Suite Setup      Setup
Suite Teardown   Teardown

Test Timeout    ${timeout}
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadmin123
${timeout}     15 min

*** Test Cases ***
Web UI - user shall be able cloudlet details
   [Documentation]
   ...  Show cloudlets
   ...  click a cloudlet to view the details
   ...  Verify details are correct

   @{ws_us}=  Show Cloudlets  region=US
   @{ws_eu}=  Show Cloudlets  region=EU

   Open Cloudlets

   ${details_us}=  Open Cloudlet Details  cloudlet_name=${ws_us[0]['data']['key']['name']}
   log to console  ${details_us}

   Should Be Equal             ${details_us['Region']}            US
   Should Be Equal             ${details_us['CloudletName']}      ${ws_us[0]['data']['key']['name']}
   Should Be Equal             ${details_us['Operator']}          ${ws_us[0]['data']['key']['operator_key']['name']}
   Should Be Equal             ${details_us['CloudletLocation']}  bug is opened for this
   Should Be Equal             ${details_us['Ip_support']}        ${ws_us[0]['data']['ip_support']}
   Should Be Equal As Numbers  ${details_us['Num_dynamic_ips']}   ${ws_us[0]['data']['num_dynamic_ips']}

   Close Cloudlet Details

   ${details_eu}=  Open Cloudlet Details  cloudlet_name=${ws_eu[0]['data']['key']['name']}
   log to console  ${details_eu}

   Should Be Equal             ${details_eu['Region']}            EU
   Should Be Equal             ${details_eu['CloudletName']}      ${ws_eu[0]['data']['key']['name']}
   Should Be Equal             ${details_eu['Operator']}          ${ws_eu[0]['data']['key']['operator_key']['name']}
   Should Be Equal             ${details_eu['CloudletLocation']}  bug is opened for this
   Should Be Equal             ${details_eu['Ip_support']}        ${ws_eu[0]['data']['ip_support']}
   Should Be Equal As Numbers  ${details_eu['Num_dynamic_ips']}   ${ws_eu[0]['data']['num_dynamic_ips']}

*** Keywords ***
	
Setup
    #create some flavors
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning