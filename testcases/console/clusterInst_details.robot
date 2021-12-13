*** Settings ***
Documentation    View cluster instances details
## Passes with different named clusters
## Fails If clusters with same names exist 
Library		     MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
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
Web UI - user shall be able to view clusterInst details
   [Documentation]
   ...  Show cluster instances
   ...  click a cluster to view the details
   ...  Verify details are correct
   [Tags]  

   @{ws_us}=  Show Cluster Instances  region=US  token=${token}  use_defaults=${False}
   @{ws_eu}=  Show Cluster Instances  region=EU  token=${token}  use_defaults=${False}

   Open Cluster Instances

   FOR  ${row}  IN  @{ws_us}
      log to console  ${row['data']['key']['cluster_key']['name']}
      ${details_us}=  Open Cluster Details  cluster_name=${row['data']['key']['cluster_key']['name']}  region=US
      log to console  ${details_us}
 
      Should Be Equal             ${details_us['Region']}                    US
      Should Be Equal             ${details_us['Cluster']}            ${row['data']['key']['cluster_key']['name']}
      Should Be Equal             ${details_us['Organization']}       ${row['data']['key']['organization']}
      Should Be Equal             ${details_us['Operator']}                ${row['data']['key']['cloudlet_key']['organization']}
      Should Be Equal             ${details_us['Cloudlet']}                ${row['data']['key']['cloudlet_key']['name']}
      Should Be Equal             ${details_us['Flavor']}                  ${row['data']['flavor']['name']}
      Should Be Equal             ${details_us['Deployment']}              ${row['data']['deployment']}

      Close Cluster Details
   END

   FOR  ${row}  IN  @{ws_eu}
      ${details_eu}=  Open Cluster Details  cluster_name=${row['data']['key']['cluster_key']['name']}  region=EU

      Should Be Equal             ${details_eu['Region']}                  EU
      Should Be Equal             ${details_eu['Cluster']}            ${row['data']['key']['cluster_key']['name']}
      Should Be Equal             ${details_eu['Organization']}       ${row['data']['key']['organization']}
      Should Be Equal             ${details_eu['Operator']}                ${row['data']['key']['cloudlet_key']['organization']}
      Should Be Equal             ${details_eu['Cloudlet']}                ${row['data']['key']['cloudlet_key']['name']}
      Should Be Equal             ${details_eu['Flavor']}                  ${row['data']['flavor']['name']}
      Should Be Equal             ${details_eu['Deployment']}              ${row['data']['deployment']}
  
      Close ClusterDetails
   END

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
