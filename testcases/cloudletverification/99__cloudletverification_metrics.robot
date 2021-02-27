*** Settings ***
Documentation   Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}  auto_login=${False}
Library  Collections
Library  String

Test Setup       Setup
#Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout}

*** Variables ***
${cloudlet_name}=   automationBuckhornCloudlet
${operator_name}=                       GDDT
${developer_organization_name}=  mobiledgex

${region}=  EU

*** Test Cases ***
#Metrics shall collect cloudlet ipusage metric 
#   [Documentation]
#   ...  request the last cloudlet ipusage metric
#   ...  verify info is correct
#   [Tags]  cloudlet  metrics
#
#   [Setup]  Setup Cloudlet Metrics
#
#   ${metrics}=         Get Cloudlet Metrics  region=${region}  token=${operator_token}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  selector=ipusage  last=5
#
#   Cloudlet IPUsage Metrics Headings Should Be Correct  ${metrics}
#
#   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
#
#   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
#
#   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
#   Should Be Equal As Integers  ${num_readings}  5
#
#   Cloudlet IPUsage Should Be In Range  ${metrics}
#
#Metrics shall collect cloudlet utilization metric 
#   [Documentation]
#   ...  request the last cloudlet ipusage metric
#   ...  verify info is correct
#   [Tags]  cloudlet  metrics
#
#   [Setup]  Setup Cloudlet Metrics
#
#   ${metrics}=         Get Cloudlet Metrics  region=${region}  token=${operator_token}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  selector=utilization  last=5
#
#   Cloudlet Utilization Metrics Headings Should Be Correct  ${metrics}
#
#   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
#
#   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
#
#   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
#   Should Be Equal As Integers  ${num_readings}  5
#
#   Cloudlet Utilization Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessDedicated/Direct/docker 
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  direct  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessDedicated/Direct/docker 
   [Documentation]
   ...  request cluster Disk metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  direct  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessDedicated/Direct/docker 
   [Documentation]
   ...  request cluster Memory metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  direct  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessDedicated/Direct/docker 
   [Documentation]
   ...  request cluster TCP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  direct  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessDedicated/Direct/docker 
   [Documentation]
   ...  request cluster UDP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  direct  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessDedicated/Direct/docker 
   [Documentation]
   ...  request cluster Network metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  direct  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request cluster Disk metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request cluster Memory metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  loadbalance  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request cluster TCP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request cluster UDP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request cluster Network metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request cluster Disk metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request cluster Memory metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request cluster TCP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request cluster UDP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request cluster Network  metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request cluster Disk metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request cluster Memory metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request cluster TCP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  dedicated  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request cluster UDP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request cluster Network metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request cluster Disk metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request cluster Memory metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request cluster TCP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request cluster UDP metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request cluster Network metrics with last=5
   ...  verify info is correct
   [Tags]  cluster  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

# not supported for direct access
#Metrics shall collect App Connections metrics for IpAccessDedicated/Direct/docker 
#   [Documentation]
#   ...  request App Connections metrics with last=5
#   ...  verify info is correct
#   [Tags]  app  docker  dedicated  direct  metrics
#
#   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
#   Log To Console  Waiting for ${waittime} seconds for metrics collection
#   Sleep  ${waittime} seconds
#
#   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicateddirect}  cluster_instance_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=connections  last=5
#
#   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
#
#   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
#
#   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
#   Should Be Equal As Integers  ${num_readings}  5
#
#   App Connections Metrics Headings Should Be Correct  ${metrics}
#
#   App Connections Should Be In Range  ${metrics}

#Metrics shall collect App CPU metrics for IpAccessDedicated/Direct/docker 
#   [Documentation]
#   ...  request App CPU metrics with last=5
#   ...  verify info is correct
#   [Tags]  app  docker  dedicated  direct  metrics
#
#   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
#   Log To Console  Waiting for ${waittime} seconds for metrics collection
#   Sleep  ${waittime} seconds
#
#   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicateddirect}  cluster_instance_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5
#
#   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
#
#   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
#
#   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
#   Should Be Equal As Integers  ${num_readings}  5
#
#   App CPU Metrics Headings Should Be Correct  ${metrics}
#
#   App CPU Should Be In Range  ${metrics}
#
#Metrics shall collect App Disk metrics for IpAccessDedicated/Direct/docker 
#   [Documentation]
#   ...  request App Disk metrics with last=5
#   ...  verify info is correct
#   [Tags]  app  docker  dedicated  direct  metrics
#
#   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
#   Log To Console  Waiting for ${waittime} seconds for metrics collection
#   Sleep  ${waittime} seconds
#
#   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicateddirect}  cluster_instance_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5
#
#   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
#
#   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
#
#   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
#   Should Be Equal As Integers  ${num_readings}  5
#
#   App Disk Metrics Headings Should Be Correct  ${metrics}
#
#   App Disk Should Be In Range  ${metrics}
#
#Metrics shall collect App Memory metrics for IpAccessDedicated/Direct/docker 
#   [Documentation]
#   ...  request App Memory metrics with last=5
#   ...  verify info is correct
#   [Tags]  app  docker  dedicated  direct  metrics
#
#   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
#   Log To Console  Waiting for ${waittime} seconds for metrics collection
#   Sleep  ${waittime} seconds
#
#   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicateddirect}  cluster_instance_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5
#
#   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
#
#   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
#
#   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
#   Should Be Equal As Integers  ${num_readings}  5
#
#   App Memory Metrics Headings Should Be Correct  ${metrics}
#
#   App Memory Should Be In Range  ${metrics}
#
#Metrics shall collect App Network metrics for IpAccessDedicated/Direct/docker 
#   [Documentation]
#   ...  request App Network metrics with last=5
#   ...  verify info is correct
#   [Tags]  app  docker  dedicated  direct  metrics
#
#   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicateddirect_endtime}  ${metrics_wait_docker}
#   Log To Console  Waiting for ${waittime} seconds for metrics collection
#   Sleep  ${waittime} seconds
#
#   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicateddirect}  cluster_instance_name=${cluster_name_dockerdedicateddirect}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5
#
#   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}
#
#   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial
#
#   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
#   Should Be Equal As Integers  ${num_readings}  5
#
#   App Network Metrics Headings Should Be Correct  ${metrics}
#
#   App Network Should Be In Range  ${metrics}

Metrics shall collect App Connections metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request App Connections metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicatedlb}  cluster_instance_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=connections  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Connections Metrics Headings Should Be Correct  ${metrics}

   App Connections Should Be In Range  ${metrics}

Metrics shall collect App CPU metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request App CPU metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicatedlb}  cluster_instance_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App CPU Metrics Headings Should Be Correct  ${metrics}

   App CPU Should Be In Range  ${metrics}

Metrics shall collect App Disk metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request App Disk metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicatedlb}  cluster_instance_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Disk Metrics Headings Should Be Correct  ${metrics}

   App Disk Should Be In Range  ${metrics}

Metrics shall collect App Memory metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request App Memory metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicatedlb}  cluster_instance_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Memory Metrics Headings Should Be Correct  ${metrics}

   App Memory Should Be In Range  ${metrics}

Metrics shall collect App Network metrics for IpAccessDedicated/LB/docker 
   [Documentation]
   ...  request App Network metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockerdedicatedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockerdedicatedlb}  cluster_instance_name=${cluster_name_dockerdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Network Metrics Headings Should Be Correct  ${metrics}

   App Network Should Be In Range  ${metrics}

Metrics shall collect App Connections metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request App Connections metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockersharedlb}  cluster_instance_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=connections  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Connections Metrics Headings Should Be Correct  ${metrics}

   App Connections Should Be In Range  ${metrics}

Metrics shall collect App CPU metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request App CPU metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockersharedlb}  cluster_instance_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App CPU Metrics Headings Should Be Correct  ${metrics}

   App CPU Should Be In Range  ${metrics}

Metrics shall collect App Disk metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request App Disk metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockersharedlb}  cluster_instance_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Disk Metrics Headings Should Be Correct  ${metrics}

   App Disk Should Be In Range  ${metrics}

Metrics shall collect App Memory metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request App Memory metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockersharedlb}  cluster_instance_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Memory Metrics Headings Should Be Correct  ${metrics}

   App Memory Should Be In Range  ${metrics}

Metrics shall collect App Network metrics for IpAccessShared/LB/docker 
   [Documentation]
   ...  request App Network metrics with last=5
   ...  verify info is correct
   [Tags]  app  docker  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_dockersharedlb_endtime}  ${metrics_wait_docker}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_dockersharedlb}  cluster_instance_name=${cluster_name_dockersharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Network Metrics Headings Should Be Correct  ${metrics}

   App Network Should Be In Range  ${metrics}

Metrics shall collect App Connections metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request App Connections metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8ssharedlb}  cluster_instance_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=connections  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Connections Metrics Headings Should Be Correct  ${metrics}

   App Connections Should Be In Range  ${metrics}

Metrics shall collect App CPU metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request App CPU metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8ssharedlb}  cluster_instance_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App CPU Metrics Headings Should Be Correct  ${metrics}

   App CPU Should Be In Range  ${metrics}

Metrics shall collect App Disk metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request App Disk metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8ssharedlb}  cluster_instance_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Disk Metrics Headings Should Be Correct  ${metrics}

   App Disk Should Be In Range  ${metrics}

Metrics shall collect App Memory metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request App Memory metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8ssharedlb}  cluster_instance_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Memory Metrics Headings Should Be Correct  ${metrics}

   App Memory Should Be In Range  ${metrics}

Metrics shall collect App Network metrics for IpAccessShared/LB/k8s 
   [Documentation]
   ...  request App Network metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8ssharedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8ssharedlb}  cluster_instance_name=${cluster_name_k8ssharedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Network Metrics Headings Should Be Correct  ${metrics}

   App Network Should Be In Range  ${metrics}

Metrics shall collect App Connections metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request App Connections metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8sdedicatedlb}  cluster_instance_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=connections  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Connections Metrics Headings Should Be Correct  ${metrics}

   App Connections Should Be In Range  ${metrics}

Metrics shall collect App CPU metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request App CPU metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8sdedicatedlb}  cluster_instance_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App CPU Metrics Headings Should Be Correct  ${metrics}

   App CPU Should Be In Range  ${metrics}

Metrics shall collect App Disk metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request App Disk metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8sdedicatedlb}  cluster_instance_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Disk Metrics Headings Should Be Correct  ${metrics}

   App Disk Should Be In Range  ${metrics}

Metrics shall collect App Memory metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request App Memory metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  shared  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8sdedicatedlb}  cluster_instance_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Memory Metrics Headings Should Be Correct  ${metrics}

   App Memory Should Be In Range  ${metrics}

Metrics shall collect App Network metrics for IpAccessDedicated/LB/k8s 
   [Documentation]
   ...  request App Network metrics with last=5
   ...  verify info is correct
   [Tags]  app  k8s  dedicated  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${cluster_name_k8sdedicatedlb_endtime}  ${metrics_wait_k8s}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_k8sdedicatedlb}  cluster_instance_name=${cluster_name_k8sdedicatedlb}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   App Network Metrics Headings Should Be Correct  ${metrics}

   App Network Should Be In Range  ${metrics}

Metrics shall collect App CPU metrics for VM direct 
   [Documentation]
   ...  request App CPU metrics with last=5
   ...  verify info is correct
   [Tags]  app  vm  direct  metrics

   ${waittime}=  Calculate Wait Time  ${vmdirect_endtime}  ${metrics_wait_vm}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_vmdirect}  cluster_instance_name=${cluster_name_vm}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings} >= 1

   App CPU Metrics Headings Should Be Correct  ${metrics}

   App CPU Should Be In Range  ${metrics}

Metrics shall collect App Disk metrics for VM direct 
   [Documentation]
   ...  request App Disk metrics with last=5
   ...  verify info is correct
   [Tags]  app  vm  direct  metrics

   # EDGECLOUD-2596 Can not get disk metrics for VM based App Instance using mcctl

   ${waittime}=  Calculate Wait Time  ${vmdirect_endtime}  ${metrics_wait_vm}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_vmdirect}  cluster_instance_name=${cluster_name_vm}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings} >= 1

   App Disk Metrics Headings Should Be Correct  ${metrics}

   App Disk Should Be In Range  ${metrics}

Metrics shall collect App Memory metrics for VM direct 
   [Documentation]
   ...  request App Memory metrics with last=5
   ...  verify info is correct
   [Tags]  app  vm  direct  metrics

   ${waittime}=  Calculate Wait Time  ${vmdirect_endtime}  ${metrics_wait_vm}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_vmdirect}  cluster_instance_name=${cluster_name_vm}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings} >= 1

   App Memory Metrics Headings Should Be Correct  ${metrics}

   App Memory Should Be In Range  ${metrics}

Metrics shall collect App Network metrics for VM direct 
   [Documentation]
   ...  request App Network metrics with last=5
   ...  verify info is correct
   [Tags]  app  vm  direct  metrics

   ${waittime}=  Calculate Wait Time  ${vmdirect_endtime}  ${metrics_wait_vm}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_vmdirect}  cluster_instance_name=${cluster_name_vm}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings} >= 1

   App Network Metrics Headings Should Be Correct  ${metrics}

   App Network Should Be In Range  ${metrics}

Metrics shall collect App CPU metrics for VM lb 
   [Documentation]
   ...  request App CPU metrics with last=5
   ...  verify info is correct
   [Tags]  app  vm  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${vmlb_endtime}  ${metrics_wait_vm}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_vmlb}  cluster_instance_name=${cluster_name_vm}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings} >= 1

   App CPU Metrics Headings Should Be Correct  ${metrics}

   App CPU Should Be In Range  ${metrics}

Metrics shall collect App Disk metrics for VM lb 
   [Documentation]
   ...  request App Disk metrics with last=5
   ...  verify info is correct
   [Tags]  app  vm  loadbalancer  metrics

   # EDGECLOUD-2596 Can not get disk metrics for VM based App Instance using mcctl

   ${waittime}=  Calculate Wait Time  ${vmlb_endtime}  ${metrics_wait_vm}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_vmlb}  cluster_instance_name=${cluster_name_vm}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings} >= 1

   App Disk Metrics Headings Should Be Correct  ${metrics}

   App Disk Should Be In Range  ${metrics}

Metrics shall collect App Memory metrics for VM lb 
   [Documentation]
   ...  request App Memory metrics with last=5
   ...  verify info is correct
   [Tags]  app  vm  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${vmlb_endtime}  ${metrics_wait_vm}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_vmlb}  cluster_instance_name=${cluster_name_vm}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings} >= 1

   App Memory Metrics Headings Should Be Correct  ${metrics}

   App Memory Should Be In Range  ${metrics}

Metrics shall collect App Network metrics for VM lb 
   [Documentation]
   ...  request App Network metrics with last=5
   ...  verify info is correct
   [Tags]  app  vm  loadbalancer  metrics

   ${waittime}=  Calculate Wait Time  ${vmlb_endtime}  ${metrics_wait_vm}
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=  Get App Metrics  region=${region}  app_name=${app_name_vmlb}  cluster_instance_name=${cluster_name_vm}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  developer_org_name=${developer_organization_name}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be True  ${num_readings} >= 1

   App Network Metrics Headings Should Be Correct  ${metrics}

   App Network Should Be In Range  ${metrics}

*** Keywords ***

Setup Cloudlet Metrics
   Login  username=${username_mexadmin}  password=${password_mexadmin}

   ${run_debug_out}=    Run Debug  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  node_type=crm  command=oscmd  args=openstack limits show -f json --absolute
   ${limits}=    evaluate    json.loads('''${run_debug_out['data']['output']}''')    json
   #${limits}=  Get limits
   Set Suite Variable  ${limits}

   ${run_debug_out}=    Run Debug  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  node_type=crm  command=oscmd  args=openstack subnet show ${cloudlet_external_subnet} -f json
   ${subnet}=    evaluate    json.loads('''${run_debug_out['data']['output']}''')    json
   #${subnet}=  Get Subnet Details  external-subnet
   Set Suite Variable  ${subnet}

   @{iprange}=  Split String  ${subnet['allocation_pools']}  separator=-
   ${maxips}=  Evaluate  int(ipaddress.IPv4Address('${iprange[1]}')) - int(ipaddress.IPv4Address('${iprange[0]}')) + 1  modules=ipaddress
   Set Suite Variable  ${maxips}

   ${run_debug_out}=    Run Debug  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  node_type=crm  command=oscmd  args=openstack server list -f json
   @{servers}=    evaluate    json.loads('''${run_debug_out['data']['output']}''')    json
   #@{servers}=  Get Server List
   ${networkcount}=  Set Variable  0
   FOR  ${server}  IN  @{servers}
          ${contains}=  Evaluate  'external-network-shared' in '${server['Networks']}'
   #\  log to console  ${contains}
          ${networkcount}=  Run Keyword If  ${contains} == ${True}  Evaluate  ${networkcount} + 1  ELSE  Set Variable  ${networkcount}
   END
   #log to console  ${networkcount}
   Set Suite Variable  ${networkcount}

   Setup  # also run the normal setup

Setup
   ${operator_token}=  Login  username=${username_operator}  password=${password_operator}
   Set Suite Variable  ${operator_token}

Calculate Wait Time
  [Arguments]  ${endtime}  ${metrics_waittime} 
  ${starttime}=  Get Time  epoch
  ${waittime}=  Run Keyword If  (${starttime} - ${endtime}) < ${metrics_waittime}  Evaluate  ${metrics_waittime} - (${starttime} - ${endtime})  ELSE  Set Variable  0
  [return]  ${waittime}

Cloudlet IPUsage Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-ipusage
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  floatingIpsUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  floatingIpsMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  ipv4Used
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  ipv4Max

Cloudlet Utilization Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cloudlet-utilization
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  vCpuUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  vCpuMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  memUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  memMax
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  diskUsed
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  diskMax

Cluster CPU Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-cpu
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cpu

Cluster Disk Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-disk
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  disk 

Cluster Memory Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-mem
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  mem

Cluster Network Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-network
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  sendBytes
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  recvBytes

Cluster TCP Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-tcp
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  tcpConns
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  tcpRetrans

Cluster UDP Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        cluster-udp
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  udpSent
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  udpRecv
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  udpRecvErr

App Connections Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        appinst-connections
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  port
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  active
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  handled
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][11]}  accepts
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][12]}  bytesSent
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][13]}  bytesRecvd
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][14]}  P0
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][15]}  P25
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][16]}  P50
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][17]}  P75
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][18]}  P90
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][19]}  P95
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][20]}  P99
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][21]}  P99.5
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][22]}  P99.9
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][23]}  P100

App CPU Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        appinst-cpu
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  pod
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  cpu

App Disk Metrics Headings Should Be Correct
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

App Memory Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        appinst-mem
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  pod
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  mem

App Network Metrics Headings Should Be Correct
  [Arguments]  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Series'][0]['name']}        appinst-network
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][0]}  time
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][1]}  app
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][2]}  ver
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][3]}  cluster
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][4]}  clusterorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][5]}  cloudlet
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][6]}  cloudletorg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][7]}  apporg
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][8]}  pod
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][9]}  sendBytes
   Should Be Equal  ${metrics['data'][0]['Series'][0]['columns'][10]}  recvBytes

Cloudlet IPUsage Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[3]} >= 0
            Should Be True               ${reading[4]} > 0
            Should Be True               ${reading[5]} > 0
            Should Be True               ${reading[6]} > 0
     END

Cloudlet Utilization Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[3]} >= 0
            Should Be True               ${reading[4]} >= -1 
            Should Be True               ${reading[5]} >= 0
            Should Be True               ${reading[6]} >= -1
            Should Be True               ${reading[7]} >= 0
            Should Be True               ${reading[8]} >= -1 
     END

CPU Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[5]} >= 0 and ${reading[5]} <= 100
     END

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[5]} > 0 and ${reading[5]} <= 100
     END

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[5]} > 0 and ${reading[5]} <= 100
     END

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[5]} > 0 and ${reading[6]} > 0
     END

TCP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[5]} >= 0 and ${reading[6]} >= 0
     END

UDP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR    ${reading}  IN  @{values}
               Should Be True    ${reading[5]} >= 0 and ${reading[6]} >= 0 and ${reading[7]} >= 0
     END

App Connections Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
             Should Be True               ${reading[9]} >= 0
             Should Be True               ${reading[10]} >= 0
             Should Be True               ${reading[11]} >= 0
             Should Be True               ${reading[12]} >= 0
             Should Be True               ${reading[13]} >= 0
             Should Be True               ${reading[14]} >= 0
             Should Be True               ${reading[15]} >= 0
             Should Be True               ${reading[16]} >= 0
             Should Be True               ${reading[17]} >= 0
             Should Be True               ${reading[18]} >= 0
             Should Be True               ${reading[19]} >= 0
             Should Be True               ${reading[20]} >= 0
             Should Be True               ${reading[21]} >= 0
             Should Be True               ${reading[22]} >= 0
             Should Be True               ${reading[23]} >= 0
     END

App CPU Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[9]} >= 0 and ${reading[9]} <= 100
     END

App Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[9]} >= 0 and ${reading[9]} <= 1000000000
     END

App Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[9]} >= 0 and ${reading[9]} <= 400000000
     END

App Network Should Be In Range
   [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
     FOR  ${reading}  IN  @{values}
            Should Be True               ${reading[9]} >= 0 and ${reading[10]} >= 0
     END

