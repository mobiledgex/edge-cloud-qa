*** Settings ***
Documentation   Calculate CPU, MEM and DISK metrics usage for App and Cluster Insatnce under High Simulated Load

#Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library		MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library     MexApp
Library     String
Variables   shared_variables.py
Resource  ../metrics_app_library.robot

Test Timeout     30 minutes

Suite Setup      Setup
Suite Teardown  Cleanup

*** Variables ***

${cloudlet_name_openstack_dedicated}  automationSunnydaleCloudlet
${operator_name_openstack_gddt}  GDDT
${mobiledgex_domain}  mobiledgex.net
${region}  EU
${flavor}  automation_api_flavor
${default_flavor_name}   automation_api_flavor
${cluster_name_1}  docker-stress
${cluster_name_2}  shared-docker-stress
${cluster_name_3}  k8s-stress
#${developer_name}  developer1574731678-0317152
${docker_image_1}      docker-qa.mobiledgex.net/testmonitor/images/docker-stress:v1
${kubernetes_image_1}  docker-qa.mobiledgex.net/testmonitor/images/docker-stress:v1
#${policy_name}  AutoProvPolicyTest
${app_name_1}  docker-stress-dedicated
${app_name_2}  docker-stress-shared
${app_name_3}  k8s-stress-dedicated
${token_server_url}  http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc
${username_admin}=  mexadmin
${password_admin}=  ${mexadmin_password}
${username}=  mextester06
${password}=  ${mextester06_gmail_password}
#${orgname}=   metricsorg

*** Test Cases ***

Create Cluster and App Instnce
  [Documentation]
  ...  Create 3 different types of Cluster/App Instance k8s Dedicated & Docker Dedicated/Shared
  ...  Verify they are created successfully
  log to console  Creating Cluster Instances
  ${handle1}=  create cluster instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  cluster_name=${cluster_name_1}  operator_org_name=${operator_name_openstack_gddt}  flavor_name=${default_flavor_name}  ip_access=IpAccessDedicated  deployment=docker  token=${user_token}  use_thread=${True}
  ${handle2}=  create cluster instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  cluster_name=${cluster_name_2}  operator_org_name=${operator_name_openstack_gddt}  flavor_name=${default_flavor_name}  ip_access=IpAccessShared  deployment=docker  token=${user_token}  use_thread=${True}
  ${handle3}=  create cluster instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  cluster_name=${cluster_name_3}  operator_org_name=${operator_name_openstack_gddt}  flavor_name=${default_flavor_name}  ip_access=IpAccessDedicated  deployment=kubernetes  token=${user_token}  use_thread=${True}

  Log To Console  Waiting for ClusterIntance Thread
  Wait For Replies  ${handle1}  ${handle2}  ${handle3}

  log to console  Creating App and App Instance

  create app  region=${region}  app_name=${app_name_1}  deployment=docker  developer_org_name=${orgname}  image_path=${docker_image_1}  access_ports=udp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}
  create app  region=${region}  app_name=${app_name_2}  deployment=docker  developer_org_name=${orgname}  image_path=${docker_image_1}  access_ports=udp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}
  create app  region=${region}  app_name=${app_name_3}  deployment=kubernetes  developer_org_name=${orgname}  image_path=${kubernetes_image_1}  access_ports=udp:8080  app_version=v1  default_flavor_name=${default_flavor_name}  token=${user_token}

  ${handle1}=  create app instance  region=${region}  app_name=${app_name_1}  app_version=v1  cloudlet_name=${cloudlet_name_openstack_dedicated}  cluster_instance_name=${cluster_name_1}   developer_org_name=${orgname}  operator_org_name=${operator_name_openstack_gddt}  token=${user_token}  use_thread=${True}
  ${handle2}=  create app instance  region=${region}  app_name=${app_name_2}  app_version=v1  cloudlet_name=${cloudlet_name_openstack_dedicated}  cluster_instance_name=${cluster_name_2}   developer_org_name=${orgname}  operator_org_name=${operator_name_openstack_gddt}  token=${user_token}  use_thread=${True}
  ${handle3}=  create app instance  region=${region}  app_name=${app_name_3}  app_version=v1  cloudlet_name=${cloudlet_name_openstack_dedicated}  cluster_instance_name=${cluster_name_3}   developer_org_name=${orgname}  operator_org_name=${operator_name_openstack_gddt}  token=${user_token}  use_thread=${True}

  Log To Console  Waiting for AppInst threads
  Wait For Replies  ${handle1}  ${handle2}  ${handle3}

  sleep  180s

Docker Dedicated App Instance CPU Usage
  [Documentation]
   ...  request app CPU metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_1}  ${app_name_influx_1}  ${cluster_name_1}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  cpu
   log  ${metrics}
   Docker Dedicated App CPU Headings Should Be Correct  ${metrics}
   Docker Dedicated App CPU Should Be In Range  ${metrics}

Docker Dedicated App Instance MEM Usage
   [Documentation]
   ...  request app MEM metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_1}  ${app_name_influx_1}  ${cluster_name_1}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  mem
   log  ${metrics}
   Docker Dedicated App MEM Headings Should Be Correct  ${metrics}
   Docker Dedicated App MEM Should Be In Range  ${metrics}

Docker Dedicated App Instance DISK Usage
   [Documentation]
   ...  request app CPU metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_1}  ${app_name_influx_1}  ${cluster_name_1}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  disk
   log  ${metrics}
   Docker Dedicated App DISK Headings Should Be Correct  ${metrics}
   Docker Dedicated App DISK Should Be In Range  ${metrics}

Docker Shared App Instance CPU Usage
    [Documentation]
   ...  request app CPU metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_2}  ${app_name_influx_2}  ${cluster_name_2}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  cpu
   log  ${metrics}
   Docker Shared App CPU Headings Should Be Correct  ${metrics}
   Docker Shared App CPU Should Be In Range  ${metrics}

Docker Shared App Instance MEM Usage
   [Documentation]
   ...  request app MEM metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_2}  ${app_name_influx_2}  ${cluster_name_2}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  mem
   log  ${metrics}
   Docker Shared App MEM Headings Should Be Correct  ${metrics}
   Docker Shared App MEM Should Be In Range  ${metrics}

Docker Shared App Instance DISK Usage

  [Documentation]
   ...  request app DISK metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_2}  ${app_name_influx_2}  ${cluster_name_2}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  disk
   log  ${metrics}
   Docker Shared App DISK Headings Should Be Correct  ${metrics}
   Docker Shared App DISK Should Be In Range  ${metrics}

k8s Dedicated App Instance CPU Usage
   [Documentation]
   ...  request app CPU metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_3}  ${app_name_influx_3}  ${cluster_name_3}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  cpu
   log  ${metrics}
   k8s Dedicated App Instance CPU Headings Should Be Correct  ${metrics}
   k8s Dedicated App Instance CPU Should Be In Range  ${metrics}

k8s Dedicated App Instance MEM Usage

  [Documentation]
   ...  request app MEM metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_3}  ${app_name_influx_3}  ${cluster_name_3}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  mem
   log  ${metrics}
   k8s Dedicated App Instance MEM Headings Should Be Correct  ${metrics}
   k8s Dedicated App Instance MEM Headings Should Be In Range  ${metrics}

k8s Dedicated App Instance DISK Usage

  [Documentation]
   ...  request app DISK metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_3}  ${app_name_influx_3}  ${cluster_name_3}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack_gddt}  ${orgname}  disk
   log  ${metrics}
   k8s Dedicated App Instance DISK Headings Should Be Correct  ${metrics}
   k8s Dedicated App Instance DISK Should Be In Range  ${metrics}


*** Keywords ***
Setup

#   ${t}=  Get Default Time Stamp
#   ${developer_name}=  Get Default Developer Name
#   ${app_name_1}=  Get Default App Name
#   ${app_name_2}=  Get Default App Name
#   ${app_name_3}=  Get Default App Name
#   ${cluster_name_1}=  Get Default Cluster Name
#   ${cluster_name_2}=  Get Default Cluster Name
#   ${cluster_name_3}=  Get Default Cluster Name

   ${epoch}=  Get Time  epoch
   ${emailepoch}=  Catenate  SEPARATOR=  ${username}  +  ${epoch}  @gmail.com
   ${epochusername}=  Catenate  SEPARATOR=  ${username}  ${epoch}
   ${super_token}=  Get Super Token
#
   Skip Verify Email  token=${super_token}
   Create User  username=${epochusername}   password=${password}   email_address=${emailepoch}
   Unlock User
   ${user_token}=  Login  username=${epochusername}  password=${password}

   ${orgname}=  Create Org  token=${user_token}  orgtype=developer
   ${app_name_influx_1}=  Convert To Lowercase  ${app_name_1}
   ${app_name_influx_2}=  Convert To Lowercase  ${app_name_2}
   ${app_name_influx_3}=  Convert To Lowercase  ${app_name_3}


   Set Suite Variable  ${super_token}
   Set Suite Variable  ${user_token}
   Set Suite Variable  ${orgname}
   Set Suite Variable  ${cluster_name_1}
   Set Suite Variable  ${cluster_name_2}
   Set Suite Variable  ${cluster_name_3}
   Set Suite Variable  ${app_name_1}
   Set Suite Variable  ${app_name_2}
   Set Suite Variable  ${app_name_3}
   Set Suite Variable  ${app_name_influx_1}
   Set Suite Variable  ${app_name_influx_2}
   Set Suite Variable  ${app_name_influx_3}

#   ${docker_image}=  set variable  docker-qa.mobiledgex.net/testmonitor/images/docker-stress:v1
#   ${kubernetes_image}=  set variable  docker-qa.mobiledgex.net/testmonitor/images/docker-stress:v1



Docker Dedicated App CPU Headings Should Be Correct
  [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  cpu
Docker Dedicated App CPU Should Be In Range
  [Arguments]  ${metrics}
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} > 100 and ${reading[9]} <= 200
   END


Docker shared App CPU Headings Should Be Correct
  [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  cpu
Docker Shared App CPU Should Be In Range
  [Arguments]  ${metrics}
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} > 100 and ${reading[9]} <= 200
   END


k8s Dedicated App Instance CPU Headings Should Be Correct
  [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  cpu
k8s Dedicated App Instance CPU Should Be In Range
  [Arguments]  ${metrics}
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 0.1 and ${reading[9]} <= 3.0
   END

Docker Dedicated App MEM Headings Should Be Correct
  [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  mem
Docker Dedicated App MEM Should Be In Range
  [Arguments]  ${metrics}
  ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
  FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 10000000 and ${reading[9]} <= 300000000
  END

Docker Shared App MEM Headings Should Be Correct
  [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  mem

Docker Shared App MEM Should Be In Range
   [Arguments]  ${metrics}
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 10000000 and ${reading[9]} <= 300000000
   END

k8s Dedicated App Instance MEM Headings Should Be Correct
  [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  mem
k8s Dedicated App Instance MEM Headings Should Be In Range
   [Arguments]  ${metrics}
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 1000000 and ${reading[9]} <= 300000000
   END

Docker Dedicated App DISK Headings Should Be Correct
   [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  disk

Docker Dedicated App DISK Should Be In Range

   [Arguments]  ${metrics}
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} > 100000000 and ${reading[9]} <= 4028653056
   END

Docker Shared App DISK Headings Should Be Correct
   [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  disk

Docker Shared App DISK Should Be In Range

  [Arguments]  ${metrics}
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} > 100000000 and ${reading[9]} <= 4028653056
   END

k8s Dedicated App Instance DISK Headings Should Be Correct
   [Arguments]  ${metrics}
  Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  disk

k8s Dedicated App Instance DISK Should Be In Range
   [Arguments]  ${metrics}
   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} > 1000 and ${reading[9]} <= 100000
   END

Cleanup

  cleanup provisioning
