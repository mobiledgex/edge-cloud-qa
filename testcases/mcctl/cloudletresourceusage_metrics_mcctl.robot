*** Settings ***
Documentation  Clientcloudletusage Metrics mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String
Library  DateTime

Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  10m

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
        cloudletorg=${operator_name_fake}
        cloudlet=${cloudlet_name_fake}  cloudletorg=${operator_name_fake}  
        cloudletorg=${operator_name_fake}  limit=1
        cloudlet=${cloudlet_name_fake}  cloudletorg=${operator_name_fake}  limit=100  starttime=${start_date}  endtime=${end_date}
        cloudletorg=${operator_name_fake}  numsamples=1
        cloudletorg=${operator_name_fake}  numsamples=100  starttime=${start_date}  endtime=${end_date}
        cloudletorg=${operator_name_fake}  startage=12h
        cloudletorg=${operator_name_fake}  endage=1s
        cloudletorg=${operator_name_fake}  startage=12h  endage=1s

        cloudlets:0.cloudletorg=${operator_name_fake}
        cloudlets:0.cloudlet=${cloudlet_name_fake}  cloudlets:0.cloudletorg=${operator_name_fake}
        cloudlets:0.cloudletorg=${operator_name_fake}  cloudlets:1.cloudletorg=${operator_name_openstack}
        cloudlets:0.cloudlet=${cloudlet_name_fake}  cloudlets:0.cloudletorg=${operator_name_fake}  cloudlets:1.cloudlet=${cloudlet_name_openstack}  cloudlets:1.cloudletorg=${operator_name_openstack}
        cloudlets:0.cloudletorg=${operator_name_fake}  limit=100  starttime=${start_date}  endtime=${end_date}
        cloudlets:0.cloudletorg=${operator_name_fake}  startage=12h  endage=1s
        cloudlets:0.cloudletorg=${operator_name_fake}  numsamples=100  starttime=${start_date}  endtime=${end_date}

# ECQ-4066
Cloudletusage - mcctl shall be able to request flavorusage metrics
   [Documentation]
   ...  - send cloudletusage metrics with selector=flavorusage via mcctl with various parms
   ...  - verify success

   [Template]  Success Cloudletflavorusage Metrics Via mcctl
        cloudletorg=${operator_name_fake}
        cloudlet=${cloudlet_name_fake}  cloudletorg=${operator_name_fake}
        cloudletorg=${operator_name_fake}  limit=1
        cloudlet=${cloudlet_name_fake}  cloudletorg=${operator_name_fake}  limit=100  starttime=${start_date}  endtime=${end_date}
        cloudletorg=${operator_name_fake}  numsamples=1
        cloudletorg=${operator_name_fake}  numsamples=100  starttime=${start_date}  endtime=${end_date}
        cloudletorg=${operator_name_fake}  startage=12h
        cloudletorg=${operator_name_fake}  endage=1s
        cloudletorg=${operator_name_fake}  startage=12h  endage=1s

        cloudlets:0.cloudletorg=${operator_name_fake}
        cloudlets:0.cloudlet=${cloudlet_name_fake}  cloudlets:0.cloudletorg=${operator_name_fake}
        cloudlets:0.cloudletorg=${operator_name_fake}  cloudlets:1.cloudletorg=${operator_name_openstack}
        cloudlets:0.cloudlet=${cloudlet_name_fake}  cloudlets:0.cloudletorg=${operator_name_fake}  cloudlets:1.cloudlet=${cloudlet_name_openstack}  cloudlets:1.cloudletorg=${operator_name_openstack}
        cloudlets:0.cloudletorg=${operator_name_fake}  limit=100  starttime=${start_date}  endtime=${end_date}
        cloudlets:0.cloudletorg=${operator_name_fake}  startage=12h  endage=1s
        cloudlets:0.cloudletorg=${operator_name_fake}  numsamples=100  starttime=${start_date}  endtime=${end_date}

# ECQ-4275
Cloudletusage - mcctl help shall show
   [Documentation]
   ...  - send cloudletusage metrics via mcctl with help for each command
   ...  - verify help is returned

   [Template]  Show Help
   ${Empty}

# ECQ-4341
Cloudletusage - mcctl shall handle usage failures
   [Documentation]
   ...  - send Metrics CloudletUsage via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Usage Via mcctl
      # missing values
      Error: missing required args: selector  #not sending any args with mcctl

      Error: Bad Request (400), Cloudlet details must be present  selector=
      Error: Bad Request (400), Cloudlet details must be present  selector=x
      Error: Bad Request (400), Cloudlet details must be present  selector=resourceusage
      Error: Bad Request (400), Cloudlet details must be present  selector=flavorusage

      Error: parsing arg "starttime\=x" failed: unable to parse "x" as time: invalid format, valid values are RFC3339 format, i.e. "2006-01-02T15:04:05Z", or "2006-01-02T15:04:05+07:00"   selector=resourceusage  starttime=x
      Error: parsing arg "endtime\=x" failed: unable to parse "x" as time: invalid format, valid values are RFC3339 format, i.e. "2006-01-02T15:04:05Z", or "2006-01-02T15:04:05+07:00"     selector=resourceusage  endtime=x
      Error: parsing arg "startage\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc                     selector=resourceusage  startage=x
      Error: parsing arg "endage\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc                       selector=resourceusage  endage=x
      Error: parsing arg "limit\=x" failed: unable to parse "x" as int: invalid syntax                                                                           selector=resourceusage  limit=x
      Error: parsing arg "numsamples\=x" failed: unable to parse "x" as int: invalid syntax                                                                      selector=resourceusage  numsamples=x

      Error: Bad Request (400), Cloudlet details must be present  selector=resourceusage  cloudlet=x
      Error: Bad Request (400), Cloudlet does not exist           selector=resourceusage  cloudletorg=x
      Error: Bad Request (400), Cloudlet does not exist           selector=resourceusage  cloudlet=x  cloudletorg=x

      Error: Bad Request (400), Cloudlet org must be present      selector=resourceusage  cloudlets:0.cloudlet=x
      Error: Bad Request (400), Cloudlet does not exist           selector=resourceusage  cloudlets:0.cloudletorg=x
      Error: Bad Request (400), Cloudlet does not exist           selector=resourceusage  cloudlets:0.cloudlet=x  cloudlets:0.cloudletorg=x

      Error: parsing arg "starttime\=x" failed: unable to parse "x" as time: invalid format, valid values are RFC3339 format, i.e. "2006-01-02T15:04:05Z", or "2006-01-02T15:04:05+07:00"   selector=flavorusage  starttime=x
      Error: parsing arg "endtime\=x" failed: unable to parse "x" as time: invalid format, valid values are RFC3339 format, i.e. "2006-01-02T15:04:05Z", or "2006-01-02T15:04:05+07:00"     selector=flavorusage  endtime=x
      Error: parsing arg "startage\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc                     selector=flavorusage  startage=x
      Error: parsing arg "endage\=x" failed: unable to parse "x" as duration: invalid format, valid values are 300ms, 1s, 1.5h, 2h45m, etc                       selector=flavorusage  endage=x
      Error: parsing arg "limit\=x" failed: unable to parse "x" as int: invalid syntax                                                                           selector=flavorusage  limit=x
      Error: parsing arg "numsamples\=x" failed: unable to parse "x" as int: invalid syntax                                                                      selector=flavorusage  numsamples=x

      Error: Bad Request (400), Cloudlet details must be present  selector=flavorusage  cloudlet=x
      Error: Bad Request (400), Cloudlet does not exist           selector=flavorusage  cloudletorg=x
      Error: Bad Request (400), Cloudlet does not exist           selector=flavorusage  cloudlet=x  cloudletorg=x

      Error: Bad Request (400), Cloudlet org must be present      selector=flavorusage  cloudlets:0.cloudlet=x
      Error: Bad Request (400), Cloudlet does not exist           selector=flavorusage  cloudlets:0.cloudletorg=x
      Error: Bad Request (400), Cloudlet does not exist           selector=flavorusage  cloudlets:0.cloudlet=x  cloudlets:0.cloudletorg=x

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

   #Should Be Equal  ${result['data'][0]['Series'][0]['name']}  fake-resource-usage
   Should Contain  ${result['data'][0]['Series'][0]['name']}  -resource-usage

 Success Cloudletflavorusage Metrics Via mcctl
   [Arguments]  &{parms}

   &{parms_copy}=  Set Variable  ${parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())
   ${parmss_modify}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms_copy}.items())

   ${result}=  Run mcctl  metrics cloudletusage region=${region} selector=flavorusage ${parmss}  version=${version}

   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  cloudlet-flavor-usage

Show Help
   [Arguments]  ${parms}

   ${error}=  Run Keyword and Expect Error  *  Run mcctl  metrics cloudletusage ${parms} -h  version=${version}

   ${cmd}=  Run Keyword If  '${parms}' == '${Empty}'  Set Variable  ${Empty}  ELSE  Set Variable  ${parms}
   Should Contain  ${error}  Usage: mcctl metrics cloudletusage ${cmd}

Fail Usage Via mcctl
   [Arguments]  ${error_msg}  ${error_msg2}=noerrormsg  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  metrics cloudletusage region=${region} ${parmss}    version=${version}
   Should Contain Any  ${std_create}  ${error_msg}  ${error_msg2}

