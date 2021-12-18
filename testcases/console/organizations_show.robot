*** Settings ***
Documentation   Show organizations

Library		MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
	
Suite Setup      Setup
Suite Teardown   Teardown

Test Timeout    ${timeout}
	
*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}     25 min

*** Test Cases ***
WebUI - user shall be able show organizations
   [Documentation]
   ...  Show organizations
   ...  Verify all organizations exist

   [Tags]  passing

   @{ws}=  Show Organizations  #sort_field=flavor_name  sort_order=ascending
   ${num_orgs_ws}=     Get Length  ${ws}

   Open Organizations  change_rows_per_page=True
	
   @{rows}=  Get Table Data
   ${num_orgs_table}=  Get Length  ${rows}
	
   FOR  ${row}  IN  @{ws}
       Run Keyword If  'Phone' in ${row}    Organization Should Exist  organization=${row['Name']}  type=${row['Type']}  phone=${row['Phone']}  address=${row['Address']}
       ...   ELSE   Organization Should Exist  organization=${row['Name']}  type=${row['Type']}
   END
   Should Be Equal  ${num_orgs_ws}  ${num_orgs_table}
   
*** Keywords ***
Setup
    Open Browser	
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning
