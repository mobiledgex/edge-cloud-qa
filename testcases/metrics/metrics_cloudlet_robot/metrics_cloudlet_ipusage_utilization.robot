*** Settings ***
Documentation   Cloudlet Ipusage/Utilization Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexInfluxDB  influxdb_address=%{AUTOMATION_INFLUXDB_ADDRESS}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_METRICS_ENV}
Library  DateTime
Library  String
Library  Collections

Test Setup       Setup
Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout_crm}

*** Variables ***
${cloudlet_name_openstack_metrics}=   automationBuckhornCloudlet
${operator}=                       GDDT

${username_admin}=  mexadmin
${password_admin}=  mexadmin123

${username}=  mextester06
${password}=  mextester06123
${orgname}=   metricsorg

${region}=  EU

*** Test Cases ***
CloudletMetrics - Shall be able to get the last 5 cloudlet Ipusage/Utilization metrics on openstack
   [Documentation]
   ...  request cloudlet metrics with all selectors
   ...  verify info is correct

   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=network,utilization,ipusage  last=5

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

CloudletMetrics - Shall be able to get the last 5 cloudlet wildcard metrics on openstack
   [Documentation]
   ...  request cloudlet metrics with wildcard selector 
   ...  verify info is correct

   ${metrics}=         MexMasterController.Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack_metrics}  operator_name=${operator}  selector=*  last=5

   Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

*** Keywords ***
Setup
   #${limits}=  Get Openstack limits
   #Set Suite Variable  ${limits}
   
   ${timestamp}=  Get Default Time Stamp
   ${developer_name}=  Get Default Developer Name
   ${clustername_k8shared}=  Get Default Cluster Name
   #${clustername_k8dedicated}=  Catenate  SEPARATOR=  cluster  ${timestamp}  -k8sdedicated

   #${clustername_k8dedicated}=   Set Variable  cluster1582840989-090443-k8sdedicated 
   #${developer_name}=  Set Variable  mobiledgex 

   Set Suite Variable  ${clustername_k8shared}
   Set Suite Variable  ${developer_name}
 
Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization 
   Should Be Equal  ${metrics['data'][0]['Series'][1]['name']}        cloudlet-ipusage 

   FOR  ${i}  IN RANGE  0  2
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  operator
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  netSend
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  netRecv
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  vCpuUsed
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  vCpuMax
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  memUsed
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  memMax
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  diskUsed
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  diskMax
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][11]}  floatingIpsUsed
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][12]}  floatingIpsMax
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][13]}  ipv4Used
      Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][14]}  ipv4Max
   END 

CPU Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[5]} > 0 and ${reading[5]} <= 100

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[5]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[5]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[5]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[5]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[5]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[14]} > 0 and ${reading[14]} <= 100

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[14]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[14]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[14]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[14]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[14]}  ${None}

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[13]} > 0 and ${reading[13]} <= 100

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[13]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[13]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[13]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[13]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[13]}  ${None}

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[6]} > 0 and ${reading[7]} > 0

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[6]}  ${None}
   \  Should Be Equal               ${reading[7]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[6]}  ${None}
   \  Should Be Equal               ${reading[7]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[6]}  ${None}
   \  Should Be Equal               ${reading[7]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[6]}  ${None}
   \  Should Be Equal               ${reading[7]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[7]}  ${None}
   \  Should Be Equal               ${reading[6]}  ${None}

TCP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[8]} >= 0 and ${reading[9]} >= 0

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}
   \  Should Be Equal               ${reading[9]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}
   \  Should Be Equal               ${reading[9]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}
   \  Should Be Equal               ${reading[9]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}
   \  Should Be Equal               ${reading[9]}  ${None}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be Equal               ${reading[8]}  ${None}
   \  Should Be Equal               ${reading[9]}  ${None}

UDP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}
   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[10]} >= 0 and ${reading[11]} >= 0 and ${reading[12]} >= 0

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][1]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][2]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][3]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][4]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][5]['values']}
   FOR  ${reading}  IN  @{values}
      Should Be Equal               ${reading[10]}  ${None}
      Should Be Equal               ${reading[11]}  ${None}
      Should Be Equal               ${reading[12]}  ${None}
   END


