*** Settings ***
Documentation   Show cloudlets

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
Web UI - user shall be able show US cloudlets
   [Documentation]
   ...  Show US cloudlets
   ...  Get US cloudlets from WS
   ...  Verify all cloudlets exist

   @{ws}=  Show Cloudlets  region=US  #sort_field=flavor_name  sort_order=ascending
   ${num_cloudlets_ws}=     Get Length  ${ws}
   Log to console  ${ws}	

   Open Cloudlets
	
   Change Region  US
	
   @{rows}=  Get Table Data
   Log to console  ${rows}
#   ${num_cloudlets_table}=  Get Length  ${rows}
#	
#   : FOR  ${row}  IN  @{ws}
#   \  Log To Console  ${row}
#   \  Cloudlet Should Exist  region=US  cloudlet_name=${row['data']['key']['name']}  operator=${row['data']['key']['operator_key']['name']}  latitude=${row['data']['location']['latitude']}  longitude=${row['data']['location']['longitude']}
#
#   Cloudlets Should Show On Map  ${num_cloudlets_ws}
	
#   Should Be Equal  ${num_cloudlets_ws}  ${num_cloudlets_table}
   
Web UI - user shall be able show EU cloudlets
   [Documentation]
   ...  Show EU cloudlets
   ...  Get EU cloudlets from WS
   ...  Verify all cloudlets exist

   # need to add some flavor on US region so we can be sure some exist when we run it. can do this in setup

   @{ws}=  Show Cloudlets  region=EU
   Log to console  ${ws[0]['data']['key']['name']}
   ${num_cloudlets_ws}=     Get Length  ${ws}
 
   Open Cloudlets

   Change Region  EU 

   @{rows}=  Get Table Data
   ${num_cloudlets_table}=  Get Length  ${rows}
	
   : FOR  ${row}  IN  @{ws}
   \  Log To Console  ${row['data']['key']['name']}
   \  Cloudlet Should Exist  region=EU  cloudlet_name=${row['data']['key']['name']}  operator=${row['data']['key']['operator_key']['name']}  latitude=${row['data']['location']['latitude']}  longitude=${row['data']['location']['longitude']}

   Cloudlets Should Show On Map  ${num_cloudlets_ws}

   Should Be Equal  ${num_cloudlets_ws}  ${num_cloudlets_table}

Web UI - user shall be able show All cloudlets
   [Documentation]
   ...  Show All cloudlets
   ...  Get EU and US cloudlets from WS
   ...  Verify all flavors exist

   # need to add some flavor on US and EU region so we can be sure some exist when we run it. can do this in setup

   @{wseu}=  Show Cloudlets  region=EU
   @{wsus}=  Show Cloudlets  region=US
   ${num_cloudlets_wsus}=     Get Length  ${wsus}
   ${num_cloudlets_wseu}=     Get Length  ${wseu}
   ${total_cloudlets_ws}=  Evaluate  ${num_cloudlets_wsus}+${num_cloudlets_wseu}
	 		
   Open Cloudlets

   @{rows}=  Get Table Data
   ${num_cloudlets_table}=  Get Length  ${rows}
	
   : FOR  ${row}  IN  @{wseu}
   \  Log To Console  ${row['data']['key']['name']}
   \  Cloudlet Should Exist  region=EU  cloudlet_name=${row['data']['key']['name']}  operator=${row['data']['key']['operator_key']['name']}  latitude=${row['data']['location']['latitude']}  longitude=${row['data']['location']['longitude']}

   : FOR  ${row}  IN  @{wsus}
   \  Log To Console  ${row['data']['key']['name']}
   \  Cloudlet Should Exist  region=US  cloudlet_name=${row['data']['key']['name']}  operator=${row['data']['key']['operator_key']['name']}  latitude=${row['data']['location']['latitude']}  longitude=${row['data']['location']['longitude']}


  
   Cloudlets Should Show On Map  ${total_cloudlets_ws}

   Should Be Equal  ${total_cloudlets_ws}  ${num_cloudlets_table}

*** Keywords ***
Setup
    #create some flavors
    Log to console  login

    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning