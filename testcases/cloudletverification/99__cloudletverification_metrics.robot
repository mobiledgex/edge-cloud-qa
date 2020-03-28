*** Settings ***
Documentation   Metrics

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  Collections

#Test Setup       Setup
#Test Teardown    Cleanup provisioning

Test Timeout  ${test_timeout}

*** Variables ***
${cloudlet_name_openstack}=   automationBuckhornCloudlet
${operator_name_openstack}=                       GDDT
${developer}=  mobiledgex

${region}=  EU

*** Test Cases ***
Metrics shall collect cloudlet ipusage metric on openstack
   [Documentation]
   ...  request the last cloudlet ipusage metric
   ...  verify info is correct
   [Tags]  cloudlet  metrics

   ${metrics}=         Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  selector=ipusage  last=5

   Cloudlet IPUsage Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cloudlet IPUsage Should Be In Range  ${metrics}

Metrics shall collect cloudlet utilization metric on openstack
   [Documentation]
   ...  request the last cloudlet ipusage metric
   ...  verify info is correct
   [Tags]  cloudlet  metrics

   ${metrics}=         Get Cloudlet Metrics  region=${region}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  selector=utilization  last=5

   Cloudlet Utilization Metrics Headings Should Be Correct  ${metrics}

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cloudlet Utilization Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessDedicated/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockerdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessDedicated/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockerdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessDedicated/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockerdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessDedicated/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockerdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessDedicated/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockerdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessDedicated/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockerdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessShared/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockershared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessShared/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockershared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessShared/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockershared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessShared/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockershared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessShared/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockershared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessShared/docker on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  docker  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_dockershared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessDedicated/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessDedicated/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessDedicated/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessDedicated/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessDedicated/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessDedicated/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  dedicated  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sdedicated_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

Metrics shall collect Cluster CPU metrics for IpAccessShared/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sshared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=cpu  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster CPU Metrics Headings Should Be Correct  ${metrics}

   CPU Should Be In Range  ${metrics}

Metrics shall collect Cluster Disk metrics for IpAccessShared/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sshared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=disk  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Disk Metrics Headings Should Be Correct  ${metrics}

   Disk Should Be In Range  ${metrics}

Metrics shall collect Cluster Memory metrics for IpAccessShared/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sshared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=mem  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Memory Metrics Headings Should Be Correct  ${metrics}

   Memory Should Be In Range  ${metrics}

Metrics shall collect Cluster TCP metrics for IpAccessShared/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sshared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=tcp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster TCP Metrics Headings Should Be Correct  ${metrics}

   TCP Should Be In Range  ${metrics}

Metrics shall collect Cluster UDP metrics for IpAccessShared/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sshared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=udp  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster UDP Metrics Headings Should Be Correct  ${metrics}

   UDP Should Be In Range  ${metrics}

Metrics shall collect Cluster Network metrics for IpAccessShared/k8s on openstack
   [Documentation]
   ...  request cluster CPU metrics with last=5
   ...  verify info is correct
   [Tags]  k8s  shared  metrics

   ${starttime}=  Get Time  epoch
   ${waittime}=  Evaluate  1200 - (${starttime} - ${cluster_name_k8sshared_endtime})
   Log To Console  Waiting for ${waittime} seconds for metrics collection
   Sleep  ${waittime} seconds

   ${metrics}=         Get Cluster Metrics  region=${region}  cluster_name=${cluster_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  developer_org_name=${developer}  selector=network  last=5

   Should Be Equal  ${metrics['data'][0]['Messages']}  ${None}

   Dictionary Should Not Contain Key  ${metrics['data'][0]['Series'][0]}  partial

   ${num_readings}=  Get Length  ${metrics['data'][0]['Series'][0]['values']}
   Should Be Equal As Integers  ${num_readings}  5

   Cluster Network Metrics Headings Should Be Correct  ${metrics}

   Network Should Be In Range  ${metrics}

*** Keywords ***
Setup
   ${limits}=  Get limits
   Set Suite Variable  ${limits}

   ${subnet}=  Get Subnet Details  external-subnet
   Set Suite Variable  ${subnet}

   @{iprange}=  Split String  ${subnet['allocation_pools']}  separator=-
   ${maxips}=  Evaluate  int(ipaddress.IPv4Address('${iprange[1]}')) - int(ipaddress.IPv4Address('${iprange[0]}')) + 1  modules=ipaddress
   Set Suite Variable  ${maxips}

   @{servers}=  Get Server List
   log to console  ${servers}
   ${networkcount}=  Set Variable  0
   : FOR  ${server}  IN  @{servers}
   \  ${contains}=  Evaluate  'external-network-shared' in '${server['Networks']}'
   \  log to console  ${contains}
   \  ${networkcount}=  Run Keyword If  ${contains} == ${True}  Evaluate  ${networkcount} + 1  ELSE  Set Variable  ${networkcount}
   log to console  ${networkcount}
   Set Suite Variable  ${networkcount}

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

Cloudlet IPUsage Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[3]} >= 0
   \  Should Be True               ${reading[4]} > 0
   \  Should Be True               ${reading[5]} > 0
   \  Should Be True               ${reading[6]} > 0

Cloudlet Utilization Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[3]} > 0
   \  Should Be True               ${reading[4]} > 0
   \  Should Be True               ${reading[5]} > 0
   \  Should Be True               ${reading[6]} > 0
   \  Should Be True               ${reading[7]} > 0
   \  Should Be True               ${reading[8]} > 0

CPU Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[5]} >= 0 and ${reading[5]} <= 100

Disk Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[5]} > 0 and ${reading[5]} <= 100

Memory Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[5]} > 0 and ${reading[5]} <= 100

Network Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[5]} > 0 and ${reading[6]} > 0

TCP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[5]} >= 0 and ${reading[6]} >= 0

UDP Should Be In Range
  [Arguments]  ${metrics}

   ${values}=  Set Variable  ${metrics['data'][0]['Series'][0]['values']}

   # verify values
   : FOR  ${reading}  IN  @{values}
   \  Should Be True               ${reading[5]} >= 0 and ${reading[6]} >= 0 and ${reading[7]} >= 0


