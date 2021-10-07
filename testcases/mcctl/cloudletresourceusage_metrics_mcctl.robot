*** Settings ***
Documentation  Clientcloudletusage Metrics mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${version}=  latest

*** Test Cases ***
# ECQ-4065
Cloudletusage - mcctl shall be able to request resourceusage metrics
   [Documentation]
   ...  - send cloudletusage metrics with selector=resourceusage via mcctl with various parms
   ...  - verify success

   [Template]  Success Cloudletresourceusage Metrics Via mcctl
        cloudlet-org=${operator_name_fake}
        cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  
        cloudlet-org=${operator_name_fake}  limit=1
        cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  limit=100  starttime=${start_date}  endtime=${end_date}
        cloudlet-org=${operator_name_fake}  numsamples=1
        cloudlet-org=${operator_name_fake}  numsamples=100  starttime=${start_date}  endtime=${end_date}
        cloudlet-org=${operator_name_fake}  startage=12h
        cloudlet-org=${operator_name_fake}  endage=1s
        cloudlet-org=${operator_name_fake}  startage=12h  endage=1s

# ECQ-4066
Cloudletusage - mcctl shall be able to request flavorusage metrics
   [Documentation]
   ...  - send cloudletusage metrics with selector=flavorusage via mcctl with various parms
   ...  - verify success

   [Template]  Success Cloudletflavorusage Metrics Via mcctl
        cloudlet-org=${operator_name_fake}
        cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}
        cloudlet-org=${operator_name_fake}  limit=1
        cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  limit=100  starttime=${start_date}  endtime=${end_date}
        cloudlet-org=${operator_name_fake}  numsamples=1
        cloudlet-org=${operator_name_fake}  numsamples=100  starttime=${start_date}  endtime=${end_date}
        cloudlet-org=${operator_name_fake}  startage=12h
        cloudlet-org=${operator_name_fake}  endage=1s
        cloudlet-org=${operator_name_fake}  startage=12h  endage=1s

*** Keywords ***
Setup
   ${epochnow}=  Get Current Date  result_format=epoch
   ${epochstart}=  Evaluate  ${epochnow} - 86400
   ${start_date}=  Evaluate  time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(${epochstart}))
   ${end_date}=  Evaluate  time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(${epochnow}))

   Set Suite Variable  ${start_date}
   Set Suite Variable  ${end_date}

 Success Cloudletresourceusage Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics cloudletusage region=${region} selector=resourceusage ${parmss}  version=${version}

   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  fake-resource-usage

 Success Cloudletflavorusage Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics cloudletusage region=${region} selector=flavorusage ${parmss}  version=${version}

   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  cloudlet-flavor-usage

