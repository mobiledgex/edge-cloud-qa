*** Settings ***
Documentation   Docker App Connections Metrics
Library  Process
Resource  ../metrics_app_library.robot
Library  Process

Suite Setup       Setup
#Test Teardown    Cleanup provisioning

#Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   packetcloudlet
${operator}=                       packet
${clustername_docker}=   dockermonitoring
${developer_name}=  testmonitor
${app_name}=  app-us

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  testuser
${password}=  testuser
${orgname}=   testmonitor

${port}=  8080

${region}=  US

*** Test Cases ***

Docker Dedicated AppInstMetrics - CONNECTIONS usage metrics on openstack

   start Process  /home/jenkins/docker_active_connections.sh  shell=yes

   sleep  60s

   [Documentation]
   ...  request app Connections metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_1}  ${app_name_influx}  ${clustername_docker_dedicated}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  connections
   log  ${metrics}
   Metrics Headings Should Be Correct  ${metrics}
   Connections Should Be In Range  ${metrics}

Docker Shared AppInstMetrics - CONNECTIONS usage metrics on openstack

   [Documentation]
   ...  request app Connections metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_1}  ${app_name_influx}  ${clustername_docker_shared}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  connections
   log  ${metrics}
   Metrics Headings Should Be Correct  ${metrics}
   Connections Should Be In Range  ${metrics}

K8s Dedicated AppInstMetrics - CONNECTIONS usage metrics on openstack

   [Documentation]
   ...  request app Connections metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_2}  ${app_name_influx}  ${clustername_k8s_dedicated}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  connections
   log  ${metrics}
   Metrics Headings Should Be Correct  ${metrics}
   Connections Should Be In Range  ${metrics}

K8s Shared AppInstMetrics - CONNECTIONS usage metrics on openstack

   [Documentation]
   ...  request app Connections metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name_2}  ${app_name_influx}  ${clustername_k8s_shared}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  connections
   log  ${metrics}
   Metrics Headings Should Be Correct  ${metrics}
   Connections Should Be In Range  ${metrics}


*** Keywords ***
Setup

   ${app_name_1}=  Set Variable  app-us
   ${clustername_docker_dedicated}=   Set Variable  dockermonitoring
   ${clustername_docker_shared}=   Set Variable  dockershared

   ${app_name_2}=  Set Variable  app-us-k8s
   ${clustername_k8s_dedicated}=   Set Variable  k8smonitoring
   ${clustername_k8s_shared}=   Set Variable  k8sshared

   ${developer_name}=  Set Variable  testmonitor

   ${appinst_1}=  Show App Instances  region=${region}  app_name=${app_name_1}  cluster_instance_name=${clustername_docker_dedicated}
   ${appinst_2}=  Show App Instances  region=${region}  app_name=${app_name_1}  cluster_instance_name=${clustername_docker_shared}
   ${appinst_3}=  Show App Instances  region=${region}  app_name=${app_name_2}  cluster_instance_name=${clustername_k8s_dedicated}
   ${appinst_4}=  Show App Instances  region=${region}  app_name=${app_name_2}  cluster_instance_name=${clustername_k8s_shared}
#   ${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}

   Set Suite Variable  ${app_name_1}
   Set Suite Variable  ${app_name_2}
   Set Suite Variable  ${clustername_docker_dedicated}
   Set Suite Variable  ${clustername_docker_shared}
   Set Suite Variable  ${clustername_k8s_dedicated}
   Set Suite Variable  ${clustername_k8s_shared}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${app_name_influx}
   #Set Suite Variable  ${pod}

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  active

Connections Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   FOR  ${reading}  IN  @{values}
      Should Be True               ${reading[9]} >= 50
   END


Metrics Should Match Connected App
   [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   ${found_connection}=  Set Variable  ${False}
   ${found_histogram}=   Set Variable  ${False}

   # verify values
   FOR  ${reading}  IN  @{values}
   #\  @{datesplit}=  Split String  ${reading[0]}  .
      ${found_connection}=  Run Keyword If  '${reading[9]}' == '${port}' and '${reading[10]}' == '1' and '${reading[11]}' == '1' and '${reading[12]}' == '1' and '${reading[13]}' > '0' and '${reading[14]}' > '0'  Set Variable  ${True}
      ...                                 ELSE  Set Variable  ${found_connection}
      ${found_histogram}=  Run Keyword If  '${reading[14]}' > '0' and '${reading[15]}' > '0' and '${reading[16]}' > '0' and '${reading[17]}' > '0' and '${reading[18]}' > '0' and '${reading[19]}' > '0' and '${reading[20]}' > '0' and '${reading[21]}' > '0' and '${reading[22]}' > '0' and '${reading[23]}' > '0'  Set Variable  ${True}
      ...                                 ELSE  Set Variable  ${found_histogram}
   END

   Should Be True  ${found_connection}  Didnot find connected app
   Should Be True  ${found_histogram}   Didnot find histogram app

