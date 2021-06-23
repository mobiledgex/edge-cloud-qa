*** Settings ***
Documentation  usage mcctl

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections
Library  String
Library  DateTime

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  5m

*** Variables ***
${region}=  US
${developer}=  MobiledgeX

${version}=  latest

*** Test Cases ***
# ECQ-3488
Usage - mcctl shall be able to request cluster usage
   [Documentation]
   ...  - send usage cluster via mcctl with various parms
   ...  - verify success

   [Setup]  Cluster Setup

   [Template]  Success Cluster Usage Via mcctl
      cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      cluster=${cluster_name}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      cluster=${cluster_name}  cluster-org=automation_dev_org  starttime=${start_date}  endtime=${end_date}
      cluster=${cluster_name}  cluster-org=automation_dev_org  cloudlet=${cloudlet_name_fake}  starttime=${start_date}  endtime=${end_date}
      cluster=${cluster_name}  cluster-org=automation_dev_org  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}

# ECQ-3489
Usage - mcctl shall be able to request app usage
   [Documentation]
   ...  - send usage app via mcctl with various parms
   ...  - verify success

   [Setup]  App Setup

   [Template]  Success App Usage Via mcctl
      cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      app-org=automation_dev_org  starttime=${start_date}  endtime=${end_date}

      appname=${app_name}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      appname=${app_name}   app-org=automation_dev_org  starttime=${start_date}  endtime=${end_date}
      appname=${app_name}   app-org=automation_dev_org  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      appname=${app_name}   app-org=automation_dev_org  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      app-org=automation_dev_org  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      app-org=automation_dev_org  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}

      cluster=${cluster_name}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      cluster=${cluster_name}  app-org=automation_dev_org  starttime=${start_date}  endtime=${end_date}
      cluster=${cluster_name}  app-org=automation_dev_org  cloudlet=${cloudlet_name_fake}  starttime=${start_date}  endtime=${end_date}
      cluster=${cluster_name}  app-org=automation_dev_org  cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      cloudlet=${cloudlet_name_fake}  cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}

      cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}  vmonly=false
      app-org=automation_dev_org  starttime=${start_date}  endtime=${end_date}  vmonly=false

      cloudlet-org=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}  vmonly=true
      app-org=automation_dev_org  starttime=${start_date}  endtime=${end_date}  vmonly=true

# ECQ-3490
Usage - mcctl shall be able to request cloudletpool usage
   [Documentation]
   ...  - send usage cloudletpool via mcctl with various parms
   ...  - verify success

   [Setup]  Cloudlet Setup

   [Template]  Success Cloudletpool Usage Via mcctl
      cloudletpool=${cloudletpool_name}  cloudletpoolorg=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}
      cloudletpool=${cloudletpool_name}  cloudletpoolorg=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}  showvmappsonly=${False}
      cloudletpool=${cloudletpool_name}  cloudletpoolorg=${operator_name_fake}  starttime=${start_date}  endtime=${end_date}  showvmappsonly=${True}

# ECQ-3491
Usage - mcctl shall handle usage failures
   [Documentation]
   ...  - send usage via mcctl with various error cases
   ...  - verify proper error is received

   [Template]  Fail Usage Via mcctl
      # invalid values
      Error: Please specify a command  ${Empty}
      Error: missing required args:    cluster
      Error: missing required args:    app
      Error: missing required args:    cloudletpool

      Must provide either Cluster organization or Cloudlet organization  cluster  starttime=2021-06-13T20:39:56Z  endtime=2021-06-14T20:49:56Z
      error decoding \\\'EndTime  cluster  starttime=2021-06-13T20:39:56Z  endtime=x
      error decoding \\\'StartTime  cluster  starttime=x  endtime=2021-06-14T20:49:56Z
      Error: 2 error  cluster  starttime=x  endtime=y

      Must provide either App organization or Cloudlet organization  app  starttime=2021-06-13T20:39:56Z  endtime=2021-06-14T20:49:56Z
      error decoding \\\'EndTime  app  starttime=2021-06-13T20:39:56Z  endtime=x
      error decoding \\\'StartTime  app  starttime=x  endtime=2021-06-14T20:49:56Z
      Error: 2 error  app  starttime=x  endtime=y
      Unable to parse "vmonly" value "x" as bool: invalid syntax, valid values are true, false  app  cloudlet-org=tmus  vmonly=x  starttime=2021-06-13T20:39:56Z  endtime=2021-06-14T20:49:56Z

      Error: Bad Request (400), Unable to retrieve CloudletPool info  cloudletpool  cloudletpool=x  cloudletpoolorg=x  starttime=2021-06-13T20:39:56Z  endtime=2021-06-14T20:49:56Z
      Unable to parse "showvmappsonly" value "x" as bool: invalid syntax, valid values are true, false  cloudletpool  cloudletpool=x  cloudletpoolorg=x  showvmappsonly=x  starttime=2021-06-13T20:39:56Z  endtime=2021-06-14T20:49:56Z

*** Keywords ***
Setup
   ${end_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ  increment=10 mins
   ${start_date}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ  increment=-7 days

   Create Flavor  region=${region}

   Set Suite Variable  ${start_date}
   Set Suite Variable  ${end_date}

Cluster Setup
   Setup

   ${cluster}=  Create Cluster Instance  region=${region}  developer_org_name=automation_dev_org  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  deployment=docker  ip_access=IpAccessShared
   ${cluster_name}=  Set Variable  ${cluster['data']['key']['cluster_key']['name']}

   Set Suite Variable  ${cluster_name}

App Setup
   Cluster Setup

   Create App     region=${region}  deployment=docker  access_ports=udp:1
   ${app}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_fake}  operator_org_name=${operator_name_fake}  cluster_instance_name=${cluster_name}
   ${app_name}=  Set Variable  ${app['data']['key']['app_key']['name']}

   Set Suite Variable  ${cluster_name}
   Set Suite Variable  ${app_name}

Cloudlet Setup
   App Setup

   @{cloudlet_list}=  Create List  tmocloud-1
   ${pool}=  Create Cloudlet Pool  region=${region}  operator_org_name=${operator_name_fake}  cloudlet_list=${cloudlet_list}
   ${cloudletpool_name}=  Set Variable  ${pool['data']['key']['name']}

   Set Suite Variable  ${cloudletpool_name}

Success Cluster Usage Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${result}=  Run mcctl  usage cluster region=${region} ${parmss}  version=${version}

   ${num_values}=  Get Length  ${result['data'][0]['Series'][0]['values']}
   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  cluster-usage
   Should Be True  ${num_values} > 0
 
Success App Usage Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${result}=  Run mcctl  usage app region=${region} ${parmss}  version=${version}

   ${num_values}=  Get Length  ${result['data'][0]['Series'][0]['values']}
   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  appinst-usage
   Should Be True  ${num_values} > 0

   IF  'vmonly=true' in '${parmss}'
      FOR  ${u}  IN  @{result['data'][0]['Series'][0]['values']}
         Should Be True  '${u[9]}' == 'vm'
      END
   END

Success Cloudletpool Usage Via mcctl
   [Arguments]  &{parms}

   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())

   ${result}=  Run mcctl  usage cloudletpool region=${region} ${parmss}  version=${version}

   ${num_values_cluster}=  Get Length  ${result['data'][0]['Series'][0]['values']}
   ${num_values_app}=  Get Length  ${result['data'][1]['Series'][0]['values']}

   Should Be Equal  ${result['data'][0]['Series'][0]['name']}  cluster-usage
   Should Be Equal  ${result['data'][1]['Series'][0]['name']}  appinst-usage
   Should Be True  ${num_values_cluster} > 0
   Should Be True  ${num_values_app} > 0

   FOR  ${u}  IN  @{result['data'][0]['Series'][0]['values']}
      Should Be True  '${u[3]}' == '${cloudlet_name_fake}'
   END
   FOR  ${u}  IN  @{result['data'][1]['Series'][0]['values']}
      Should Be True  '${u[6]}' == '${cloudlet_name_fake}'
   END

   IF  'showvmappsonly=${True}' in '${parmss}'
      FOR  ${u}  IN  @{result['data'][1]['Series'][0]['values']}
         Should Be True  '${u[9]}' == 'vm'
      END
   ELSE
      ${found}=  Set Variable  ${False}
      FOR  ${u}  IN  @{result['data'][1]['Series'][0]['values']}
         IF  '${u[9]}' == 'docker' or '${u[9]}' == 'kubernetes'
            ${found}=  Set Variable  ${True}
            Exit For Loop
         END
      END
      Should Be True  ${found}
   END

Fail Usage Via mcctl
   [Arguments]  ${error_msg}  ${type}  &{parms}
   
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items()) 
   ${std_create}=  Run Keyword and Expect Error  *  Run mcctl  usage ${type} region=${region} ${parmss}  version=${version}
   Should Contain  ${std_create}  ${error_msg}
