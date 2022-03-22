*** Settings ***
Documentation  CreateApp with qos

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  DateTime

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${app_counter}=  ${0}

${region}=  EU

${ram}=  2000
${vcpus}=  5
${disk}=  12

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-4431
CreateApp - apps shall create with qos args
   [Documentation]
   ...  - create app with qos network prioritazation and session duration
   ...  - verify app is created properly

   [Tags]  qos

   [Template]  Create Qos App

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=LowLatency       qos_session_duration=${None}
   image_type=ImageTypeDocker  deployment=docker      image_path=${docker_image}       qos_session_profile=ThroughputDownS  qos_session_duration=${None}
   image_type=ImageTypeHelm    deployment=helm        image_path=${docker_image}       qos_session_profile=ThroughputDownM  qos_session_duration=${None}
   image_type=ImageTypeQcow    deployment=vm          image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownL  qos_session_duration=${None}
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=NoPriority       qos_session_duration=${None}
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=NoPriority       qos_session_duration=0

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=1  qos_session_duration=${None}
   image_type=ImageTypeDocker  deployment=docker      image_path=${docker_image}       qos_session_profile=2  qos_session_duration=${None}
   image_type=ImageTypeHelm    deployment=helm        image_path=${docker_image}       qos_session_profile=3  qos_session_duration=${None}
   image_type=ImageTypeQcow    deployment=vm          image_path=${qcow_centos_image}  qos_session_profile=4  qos_session_duration=${None}
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=0  qos_session_duration=${None}
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=1  qos_session_duration=0
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=0  qos_session_duration=0

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=LowLatency       qos_session_duration=1s
   image_type=ImageTypeDocker  deployment=docker      image_path=${docker_image}       qos_session_profile=ThroughputDownS  qos_session_duration=1m1s
   image_type=ImageTypeHelm    deployment=helm        image_path=${docker_image}       qos_session_profile=ThroughputDownM  qos_session_duration=1h1m1s
   image_type=ImageTypeQcow    deployment=vm          image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownL  qos_session_duration=0s
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=1                qos_session_duration=300ms

# ECQ-4432
CreateApp - Error shall be received for invalid qos session profile parm
   [Documentation]
   ...  - create k8s/docker/helm/vm app with invalid qos session profile value
   ...  - verify error is created

   [Tags]  qos

   [Template]  Fail Create Qos Session Profile App

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=x
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=LowLatenc 
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=5 
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=-1

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=x
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=LowLatenc
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=5 
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=-1

   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=x
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=LowLatenc
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=5
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=-1

   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=x
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=LowLatenc
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=5
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=-1

# ECQ-4433
CreateApp - Error shall be received for invalid qos session duration parm
   [Documentation]
   ...  - create k8s/docker/helm/vm app with invalid qos session duration value
   ...  - verify error is created

   [Tags]  qos

   [Template]  Fail Create Qos Session Duration App

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=LowLatency       qos_session_duration=1
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownS  qos_session_duration=s
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownM  qos_session_duration=-1
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownL  qos_session_duration=999999999999999999999h

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=LowLatency       qos_session_duration=1
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownS  qos_session_duration=s
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownM  qos_session_duration=-1
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownL  qos_session_duration=999999999999999999999s

   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=LowLatency       qos_session_duration=1
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=ThroughputDownS  qos_session_duration=s
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=ThroughputDownM  qos_session_duration=-1
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=ThroughputDownL  qos_session_duration=999999999999999999999m

   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=LowLatency       qos_session_duration=1
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownS  qos_session_duration=s
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownM  qos_session_duration=-1
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownL  qos_session_duration=999999999999999999999ms

# ECQ-4434
UpdateApp - apps shall update with qos args
   [Documentation]
   ...  - create app
   ...  - update app with qos network prioritazation and session duration
   ...  - verify app is updated properly

   [Tags]  qos

   [Template]  Update Qos App

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=LowLatency       qos_session_duration=${None}  qos_session_profile_2=LowLatency       qos_session_duration_2=${None}
   image_type=ImageTypeDocker  deployment=docker      image_path=${docker_image}       qos_session_profile=ThroughputDownS  qos_session_duration=${None}  qos_session_profile_2=ThroughputDownS  qos_session_duration_2=1s
   image_type=ImageTypeHelm    deployment=helm        image_path=${docker_image}       qos_session_profile=ThroughputDownM  qos_session_duration=${None}  qos_session_profile_2=ThroughputDownL  qos_session_duration_2=1m1s 
   image_type=ImageTypeQcow    deployment=vm          image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownL  qos_session_duration=${None}  qos_session_profile_2=ThroughputDownM  qos_session_duration_2=${None}
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=NoPriority       qos_session_duration=${None}  qos_session_profile_2=ThroughputDownL  qos_session_duration_2=1h1m1s
   image_type=ImageTypeQcow    deployment=vm          image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownL  qos_session_duration=${None}  qos_session_profile_2=ThroughputDownM  qos_session_duration_2=0

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=1  qos_session_duration=${None}  qos_session_profile_2=ThroughputDownL  qos_session_duration_2=1m1s
   image_type=ImageTypeDocker  deployment=docker      image_path=${docker_image}       qos_session_profile=2  qos_session_duration=${None}  qos_session_profile_2=1                qos_session_duration_2=1s
   image_type=ImageTypeHelm    deployment=helm        image_path=${docker_image}       qos_session_profile=3  qos_session_duration=${None}  qos_session_profile_2=4                qos_session_duration_2=4m1s
   image_type=ImageTypeQcow    deployment=vm          image_path=${qcow_centos_image}  qos_session_profile=4  qos_session_duration=${None}  qos_session_profile_2=3                qos_session_duration_2=4ms
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=0  qos_session_duration=${None}  qos_session_profile_2=1                qos_session_duration_2=1h0m0s

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=LowLatency       qos_session_duration=1s      qos_session_profile_2=LowLatency       qos_session_duration_2=2s
   image_type=ImageTypeDocker  deployment=docker      image_path=${docker_image}       qos_session_profile=ThroughputDownS  qos_session_duration=1m1s    qos_session_profile_2=ThroughputDownL  qos_session_duration_2=1m1s
   image_type=ImageTypeHelm    deployment=helm        image_path=${docker_image}       qos_session_profile=ThroughputDownM  qos_session_duration=1h1m1s  qos_session_profile_2=ThroughputDownS  qos_session_duration_2=1s
   image_type=ImageTypeQcow    deployment=vm          image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownL  qos_session_duration=0s      qos_session_profile_2=ThroughputDownL  qos_session_duration_2=1h1m1s
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}       qos_session_profile=1                qos_session_duration=300ms   qos_session_profile_2=ThroughputDownL  qos_session_duration_2=300ms

# ECQ-4435
UpdateApp - Error shall be received for invalid qos session profile parm
   [Documentation]
   ...  - update k8s/docker/helm/vm app with invalid qos session profile value
   ...  - verify error is received

   [Tags]  qos

   [Template]  Fail Update Qos Session Profile App

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=x
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=LowLatenc
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=5
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=-1

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=x
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=LowLatenc
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=5
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=-1

   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=x
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=LowLatenc
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=5
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=-1

   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=x
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=LowLatenc
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=5
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=-1

# ECQ-4436
UpdateApp - Error shall be received for invalid qos session duration parm
   [Documentation]
   ...  - update k8s/docker/helm/vm app with invalid qos session duration value
   ...  - verify error is received

   [Tags]  qos

   [Template]  Fail Update Qos Session Duration App

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=LowLatency       qos_session_duration=1
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownS  qos_session_duration=s
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownM  qos_session_duration=-1
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownL  qos_session_duration=999999999999999999999h

   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=LowLatency       qos_session_duration=1
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownS  qos_session_duration=s
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownM  qos_session_duration=-1
   image_type=ImageTypeDocker  deployment=kubernetes  image_path=${docker_image}  qos_session_profile=ThroughputDownL  qos_session_duration=999999999999999999999s

   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=LowLatency       qos_session_duration=1
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=ThroughputDownS  qos_session_duration=s
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=ThroughputDownM  qos_session_duration=-1
   image_type=ImageTypeHelm  deployment=helm  image_path=${docker_image}  qos_session_profile=ThroughputDownL  qos_session_duration=999999999999999999999m

   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=LowLatency       qos_session_duration=1
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownS  qos_session_duration=s
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownM  qos_session_duration=-1
   image_type=ImageTypeQcow  deployment=vm  image_path=${qcow_centos_image}  qos_session_profile=ThroughputDownL  qos_session_duration=999999999999999999999ms

*** Keywords ***
Setup
    Create Flavor  region=${region}  ram=${ram}  disk=${disk}  vcpus=${vcpus}

   ${time}=  Get Current Date  result_format=epoch

   ${appname}=  Set Variable  app${time}
   Set Suite Variable  ${appname}

Setup Update
   ${app}=  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=loadbalancer  image_path=${parms['image_path']}  access_ports=tcp:2016  

Create Qos App
   [Arguments]  &{parms}

   ${app}=  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=loadbalancer  image_path=${parms['image_path']}  access_ports=tcp:2016  qos_session_profile=${parms['qos_session_profile']}  qos_session_duration=${parms['qos_session_duration']}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}

   Verify Qos  ${app}  ${parms['qos_session_profile']}  ${parms['qos_session_duration']}

Fail Create Qos Session Profile App
   [Arguments]  &{parms}

   ${std_create}=  Run Keyword and Expect Error  *  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=loadbalancer  image_path=${parms['image_path']}  access_ports=tcp:2016  qos_session_profile=${parms['qos_session_profile']} 

   Should Be Equal  ${std_create}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected QosSessionProfile, but got string ${parms['qos_session_profile']} for field \\\\"App.qos_session_profile\\\\", valid values are one of NoPriority, LowLatency, ThroughputDownS, ThroughputDownM, ThroughputDownL, or 0, 1, 2, 3, 4"}')

Fail Create Qos Session Duration App
   [Arguments]  &{parms}

   ${std_create}=  Run Keyword and Expect Error  *  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  access_type=loadbalancer  image_path=${parms['image_path']}  access_ports=tcp:2016  qos_session_profile=${parms['qos_session_profile']}  qos_session_duration=${parms['qos_session_duration']}

   Should Be Equal  ${std_create}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected duration, but got string ${parms['qos_session_duration']} for field \\\\"App.qos_session_duration\\\\", valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

Fail Update Qos Session Profile App
   [Arguments]  &{parms}

   ${std_create}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}_${app_counter}  qos_session_profile=${parms['qos_session_profile']}

   Should Be Equal  ${std_create}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected QosSessionProfile, but got string ${parms['qos_session_profile']} for field \\\\"App.qos_session_profile\\\\", valid values are one of NoPriority, LowLatency, ThroughputDownS, ThroughputDownM, ThroughputDownL, or 0, 1, 2, 3, 4"}')

Fail Update Qos Session Duration App
   [Arguments]  &{parms}

   ${std_create}=  Run Keyword and Expect Error  *  Update App  region=${region}  app_name=${appname}_${app_counter}  qos_session_profile=${parms['qos_session_profile']}  qos_session_duration=${parms['qos_session_duration']}

   Should Be Equal  ${std_create}  ('code=400', 'error={"message":"Invalid JSON data: Unmarshal error: expected duration, but got string ${parms['qos_session_duration']} for field \\\\"App.qos_session_duration\\\\", valid values are 300ms, 1s, 1.5h, 2h45m, etc"}')

Update Qos App
   [Arguments]  &{parms}

   ${app}=  Create App  region=${region}  app_name=${appname}_${app_counter}  image_type=${parms['image_type']}  deployment=${parms['deployment']}  image_path=${parms['image_path']}  access_ports=tcp:2016

   Should Be Equal  ${app['data']['deployment']}  ${parms['deployment']}

   ${app1}=  Update App  region=${region}  app_name=${appname}_${app_counter}  qos_session_profile=${parms['qos_session_profile']}  qos_session_duration=${parms['qos_session_duration']}

   ${app2}=  Update App  region=${region}  app_name=${appname}_${app_counter}  qos_session_profile=${parms['qos_session_profile_2']}  qos_session_duration=${parms['qos_session_duration_2']}

   ${app_counter}=  Evaluate  ${app_counter} + 1
   Set Suite Variable  ${app_counter}

   Verify Qos  ${app1}  ${parms['qos_session_profile']}  ${parms['qos_session_duration']}

   Verify Qos  ${app2}  ${parms['qos_session_profile_2']}  ${parms['qos_session_duration_2']}

Verify Qos
   [Arguments]  ${app}  ${profile}  ${duration} 

   IF  '${profile}' == 'NoPriority' or '${profile}' == '0'
      Should Not Contain  ${app['data']}  qos_session_profile
   ELSE
      IF  '${profile}' == 'LowLatency' or '${profile}' == '1'
         Should Be Equal  ${app['data']['qos_session_profile']}  LowLatency
      ELSE IF  '${profile}' == 'ThroughputDownS' or '${profile}' == '2'
         Should Be Equal  ${app['data']['qos_session_profile']}  ThroughputDownS
      ELSE IF  '${profile}' == 'ThroughputDownM' or '${profile}' == '3'
         Should Be Equal  ${app['data']['qos_session_profile']}  ThroughputDownM
      ELSE IF  '${profile}' == 'ThroughputDownL' or '${profile}' == '4'
         Should Be Equal  ${app['data']['qos_session_profile']}  ThroughputDownL
      END
   END

   IF  '${duration}' != '${None}' and '${duration}' != '0s' and '${duration}' != '0'
      Should Be Equal  ${app['data']['qos_session_duration']}  ${duration}
   ELSE
      Should Not Contain  ${app['data']}  qos_session_duration
   END

