*** Settings ***
Documentation    View cloudlet details

Library		 MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library          MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}
Library          String

Suite Setup      Setup
Suite Teardown   Teardown

Test Timeout     ${timeout}

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${timeout}           15 min

*** Test Cases ***
WebUI - user shall be able view cloudlet details
   [Documentation]
   ...  Show cloudlets
   ...  click a cloudlet to view the details
   ...  Verify details are correct
   [Tags]  passing

   @{ws_us}=  Show Cloudlets  region=US  cloudlet_name=automationAzureCentralCloudlet  operator_org_name=azure
   @{ws_eu}=  Show Cloudlets  region=EU  cloudlet_name=automationFairviewCloudlet  operator_org_name=GDDT

   Open Cloudlets

   FOR  ${row}  IN  @{ws_us}
       log to console  ${row['data']['location']}
       ${locationus}=  Convert To String  ${row['data']['location']}
       ${locationus}=  Convert JSON  ${locationus}

       ${ipsupportus}=   Set Variable If  ${row['data']['ip_support']} == 1  Static  Dynamic
   #\  sleep  5 seconds

       ${details_us}=  Open Cloudlet Details  cloudlet_name=${row['data']['key']['name']}  region=US
       sleep  3 seconds
   
       log to console  ${details_us}
       log to console  ${details_us['Cloudlet Location']}
       log to console  ${location_us}
       ${locationdetails}=  Convert To String   ${details_us['Cloudlet Location']}

       Should Be Equal             ${details_us['Region']}                  US
       Should Be Equal             ${details_us['Cloudlet Name']}           ${row['data']['key']['name']}
       Should Be Equal             ${details_us['Operator']}                ${row['data']['key']['organization']}
   #\  Should Be Equal             ${details_us['Cloudlet Location']}       ${locationus} 
       Should Contain              ${locationdetails}  "latitude": ${locationus['latitude']}
       Should Contain              ${locationdetails}  "longitude": ${locationus['longitude']}
       Should Be Equal             ${details_us['IP Support']}              ${ip_supportus}
       Should Be Equal As Numbers  ${details_us['Number of Dynamic IPs']}   ${row['data']['num_dynamic_ips']}

       Close Cloudlet Details
       Sleep  3 sec
    END
     
    FOR  ${row}  IN  @{ws_eu}
       ${locationeu}=  Convert To String  ${row['data']['location']}
       ${locationeu}=  Convert JSON  ${locationeu}
       ${ipsupporteu}=   Set Variable If  ${row['data']['ip_support']} == 1  Static  Dynamic

       ${details_eu}=  Open Cloudlet Details  cloudlet_name=${ws_eu[0]['data']['key']['name']}  region=EU

       ${locationdetails}=  Convert To String   ${details_eu['Cloudlet Location']}

       Should Be Equal             ${details_eu['Region']}                  EU
       Should Be Equal             ${details_eu['Cloudlet Name']}           ${row['data']['key']['name']}
       Should Be Equal             ${details_eu['Operator']}                ${row['data']['key']['organization']}
   #\  Should Be Equal             ${details_eu['Cloudlet Location']}       ${locationeu} 
       Should Contain              ${locationdetails}  "latitude": ${locationeu['latitude']}
       Should Contain              ${locationdetails}  "longitude": ${locationeu['longitude']}
       Should Be Equal             ${details_eu['IP Support']}              ${ipsupporteu}
       Should Be Equal As Numbers  ${details_eu['Number of Dynamic IPs']}   ${row['data']['num_dynamic_ips']}

       Close Cloudlet Details
       Sleep  1 sec
    END

*** Keywords ***

Setup
    #create some flavors
    Log to console  login
    Open Browser	
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute

Teardown
    Close Browser
    Cleanup Provisioning

Convert JSON
   [Arguments]  ${location}
   #${location}=  Replace String  ${location}  ,${SPACE}  ${\n}
   #${location}=  Replace String  ${location}  :${SPACE}  :
   #${location}=  Replace String  ${location}  {  {${\n}  count=1
   #${location}=  Replace String Using Regexp  ${location}  }$  ${\n}}
   ${location}=  Replace String  ${location}  '  "
   ${location}=  Evaluate  json.loads('${location}')  json
   [return]  ${location}
