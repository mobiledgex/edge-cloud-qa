*** Settings ***
Documentation   K8s Dedicated App Disk Metrics

Resource  ../metrics_app_library.robot

Suite Setup       Setup
#Test Teardown    Cleanup provisioning

#Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   packetcloudlet
${operator}=                       packet
${clustername_k8sdedicated}=   k8sshared
${developer_name}=  testmonitor
${app_name}=  app-us-k8s

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  testuser
${password}=  testuser
${orgname}=   testmonitor

${port}=  8080

${region}=  US


*** Test Cases ***
k8s Shared AppInstMetrics - DISK usage metric on openstack
   [Documentation]
   ...  request app Disk metrics with last=1
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last app metric on openstack   ${app_name}  ${app_name_influx}  ${clustername_k8sdedicated}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   log  ${metrics}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}


k8s Shared AppInstMetrics - last 5 DISK usage metrics on openstack
   [Documentation]
   ...  request app Disk metrics with last=5
   ...  verify info is correct

   ${metrics}  ${metrics_influx}=  Get the last 5 app metrics on openstack     ${app_name}  ${app_name_influx}  ${clustername_k8sdedicated}  ${cloudlet_name_openstack_metrics}  ${operator}  ${developer_name}  disk

   Metrics Should Match Influxdb  metrics=${metrics}  metrics_influx=${metrics_influx}

   log  ${metrics}

   Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

*** Keywords ***
Setup

   ${app_name}=  Set Variable  app-us-k8s
   ${clustername_k8sdedicated}=   Set Variable  k8sshared
   ${developer_name}=  Set Variable  testmonitor
#   ${t}=  Get Default Time Stamp
#   ${developer_name}=  Get Default Developer Name
#   ${app_name}=  Get Default App Name
#   ${clustername_k8sdedicated}=  Get Default Cluster Name

   #${clustername_k8sdedicated}=  Catenate  SEPARATOR=-  cluster  ${t}  k8sdedicated
   #${app_name}=     Catenate  SEPARATOR=  ${app_name}  k8s

   #${app_name}=  Set Variable  app1582226010-873146k8s
   #${clustername_k8sdedicated}=   Set Variable  cluster-1582226010-873146-k8sdedicated
   #${developer_name}=  Set Variable  mobiledgex

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name}
   ${pod}=  Set Variable  ${appinst[0]['data']['runtime_info']['container_ids'][0]}
   ${app_name_influx}=  Convert To Lowercase  ${app_name}

   log to console  ${appinst} ${pod}

   Set Suite Variable  ${app_name}
   Set Suite Variable  ${app_name_influx}
   Set Suite Variable  ${clustername_k8sdedicated}
   Set Suite Variable  ${developer_name}
   Set Suite Variable  ${pod}

Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        appinst-disk
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  pod
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  disk

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
    FOR  ${reading}  IN  @{values}
     Should Be Equal  ${reading[1]}  ${app_name_influx}
     Should Be Equal  ${reading[2]}  v1
     Should Be Equal  ${reading[3]}  ${clustername_k8sdedicated}
     Should Be Equal  ${reading[4]}  ${developer_name}
     Should Be Equal  ${reading[5]}  ${cloudlet_name_openstack_metrics}
     Should Be Equal  ${reading[6]}  ${operator}
     Should Be Equal  ${reading[7]}  ${developer_name}

     Should Be True               ${reading[9]} > 0 and ${reading[9]} <= 100000000
    END

Metrics Should Match Influxdb
   [Arguments]  ${metrics}  ${metrics_influx}

   ${metrics_influx_t}=  Set Variable  ${metrics_influx}
   ${index}=  Set Variable  0
   FOR  ${reading}  IN  @{metrics_influx}
      @{datesplit1}=  Split String  ${metrics['data'][0]['Series'][0]['values'][0][${index}]}  .
      ${metricsepoch}=  Convert Date  ${datesplit1[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      @{datesplit2}=  Split String  ${reading['time']}  .
      ${influxepoch}=  Convert Date  ${datesplit2[0]}  result_format=epoch  date_format=%Y-%m-%dT%H:%M:%S
      Run Keyword If  '${metricsepoch}' < '${influxepoch}'  Remove From List  ${metrics_influx_t}  ${index}
      ...  ELSE  Exit For Loop
   END
    #Run Keyword If  '${metrics['data'][0]['Series'][0]['values'][0][0]}' != '${metrics_influx[0]['time']}'  Remove From List  ${metrics_influx}  0  #remove 1st item if newer than ws
   #...  ELSE  Remove From List  ${metrics_influx}  -1  #remove last item
   log to console  ${metrics_influx_t}

   ${index}=  Set Variable  0
    FOR  ${reading}  IN  @{metrics['data'][0]['Series'][0]['values']}
      Should Be Equal  ${metrics_influx_t[${index}]['time']}  ${reading[0]}
      Should Be Equal  ${metrics_influx_t[${index}]['disk']}  ${reading[9]}
      ${index}=  Evaluate  ${index}+1
    END
