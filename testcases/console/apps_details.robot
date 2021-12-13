*** Settings ***
Documentation    View apps details

Library		     MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library          MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library          String
Library          Collections

Suite Setup      Setup
Suite Teardown   Teardown

Test Timeout     ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           15 min

*** Test Cases ***
Web UI - user shall be able to view app details
   [Documentation]
   ...  Show apps
   ...  click a app to view the details
   ...  Verify details are correct
   #[Tags]  

   @{wsUSEU}=  Show All Apps
   ${cnt}=  Get Length  ${wsUSEU}
   ${numbers}=    Evaluate    random.sample(range(0, ${cnt}), 20)    random
   @{L1}=  Create List
   FOR  ${index}  IN  @{numbers}
       Append To List   ${L1}  ${wsUSEU}[${index}]
   END

   Open Apps

   : FOR  ${row}  IN  @{L1}
   \  log to console  ${row}
   \  ${details_us}=  Open App Details  app_name=${row['data']['key']['name']}  region=${row['data']['region']}  app_version=${row['data']['key']['version']}  app_org=${row['data']['key']['organization']}
   \  log to console  ${details_us}
 
   \  Should Be Equal             ${details_us['Region']}             ${row['data']['region']}
   \  Should Be Equal             ${details_us['App']}                ${row['data']['key']['name']}
   \  Should Be Equal             ${details_us['Organization']}       ${row['data']['key']['organization']}
   \  Run Keyword If  'Default Flavor' in ${details_us}  Should Be Equal          ${details_us['Default Flavor']}               ${row['data']['default_flavor']['name']}
   \  Should Be Equal             ${details_us['Deployment']}              ${row['data']['deployment']}
   \  Run Keyword If  'Ports' in ${details_us}   Should Be Equal             ${details_us['Ports']}              ${row['data']['access_ports']}
   \  Run Keyword If  'revision' in ${row['data']}  Should Be Equal          ${details_us['Revision']}               ${row['data']['revision']}
   \  Run Keyword If  'seconds' in ${row['data']['created_at']}  Dictionary Should Contain Key  ${details_us}  Created
   \  Run Keyword If  'seconds' in ${row['data']['updated_at']}  Dictionary Should Contain Key  ${details_us}  Updated
   \  Close Apps Details

*** Keywords ***

Setup
    Open Browser	
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning
