*** Settings ***
Documentation   Start 2 cluster instances on same cloudlet

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown	Cleanup provisioning

Test Timeout    ${test_timeout_crm}
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet   #has to match crm process startup parms
${operator_name_openstack}  GDDT
${flavor_name}	  x1.medium
${test_timeout_crm}  15 min

${region}=  EU

*** Test Cases ***
# ECQ-1111
CRM shall be able to Create 2 cluster instances on the same cloudlet
    [Documentation]
    ...  - Create 2 clusters and cluster instances on the same cloudlet
    ...  - Verify both are created successfully

    # need to update for anthos once EDGECLOUD-5758 is fixed

    ${epoch_time}=  Get Time  epoch

    ${cluster_name_1}=  Catenate  SEPARATOR=  cl  ${epoch_time}  
    ${cluster_name_2}=  Catenate  SEPARATOR=  ${cluster_name_1}  2

    ${cluster1}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_1}  number_masters=1  number_nodes=${numnodes} 
    ${cluster2}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_2}  number_masters=1  number_nodes=${numnodes} 

    Sleep  20s  # wait for resources to be populated

    ${cluster1}=  Show Cluster Instances  region=${region}  cluster_name=${cluster_name_1}  use_defaults=${False}
    ${cluster2}=  Show Cluster Instances  region=${region}  cluster_name=${cluster_name_2}  use_defaults=${False}

    ${cloudletinfo}=  Show Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name_crm}

    ${rootlb}=  Set Variable  ${cloudletinfo[0]['data']['resources_snapshot']['platform_vms'][1]['ipaddresses'][0]['externalIp']}
    ${node11}=  Set Variable  ${cluster1[0]['data']['resources']['vms'][0]['ipaddresses'][0]['internalIp']}
    ${node12}=  Set Variable  ${cluster1[0]['data']['resources']['vms'][1]['ipaddresses'][0]['internalIp']}
    ${node21}=  Set Variable  ${cluster2[0]['data']['resources']['vms'][0]['ipaddresses'][0]['internalIp']}
    ${node22}=  Set Variable  ${cluster2[0]['data']['resources']['vms'][1]['ipaddresses'][0]['internalIp']}

    #${rootlb}=  Set Variable  80.187.134.197
    #${node11}=  Set Variable  10.101.20.101
    #${node12}=  Set Variable  10.101.20.10 
    #${node21}=  Set Variable  10.101.29.101 
    #${node22}=  Set Variable  10.101.29.10 

    node should ping server  root_loadbalancer=${rootlb}  node=${node11}  server=google.com
    node should ping server  root_loadbalancer=${rootlb}  node=${node12}  server=google.com
    node should ping server  root_loadbalancer=${rootlb}  node=${node21}  server=google.com
    node should ping server  root_loadbalancer=${rootlb}  node=${node22}  server=google.com

    node should not ping server  root_loadbalancer=${rootlb}  node=${node11}  server=${node21}
    node should not ping server  root_loadbalancer=${rootlb}  node=${node11}  server=${node22}
    node should not ping server  root_loadbalancer=${rootlb}  node=${node21}  server=${node11}
    node should not ping server  root_loadbalancer=${rootlb}  node=${node21}  server=${node12}
    node should not ping server  root_loadbalancer=${rootlb}  node=${node12}  server=${node21}
    node should not ping server  root_loadbalancer=${rootlb}  node=${node12}  server=${node22}
    node should not ping server  root_loadbalancer=${rootlb}  node=${node22}  server=${node11}
    node should not ping server  root_loadbalancer=${rootlb}  node=${node22}  server=${node12}


#    sleep  120   #wait for prometheus to finish creating before deleting. bug for this already

# ECQ-3477
CRM shall be able to Create 2 docker cluster instances on the same cloudlet
    [Documentation]
    ...  - Create 2 docker cluster instances on the same cloudlet
    ...  - Verify both are created successfully

    # need to update for anthos once EDGECLOUD-5758 is fixed

    ${epoch_time}=  Get Time  epoch

    ${cluster_name_1}=  Catenate  SEPARATOR=  cl  ${epoch_time}
    ${cluster_name_2}=  Catenate  SEPARATOR=  ${cluster_name_1}  2

    ${cluster1}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_1}  deployment=docker  ip_access=IpAccessShared
    ${cluster2}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_2}  deployment=docker  ip_access=IpAccessShared

    Sleep  20s  # wait for resources to be populated

    ${cluster1}=  Show Cluster Instances  region=${region}  cluster_name=${cluster_name_1}  use_defaults=${False}
    ${cluster2}=  Show Cluster Instances  region=${region}  cluster_name=${cluster_name_2}  use_defaults=${False}

    ${cloudletinfo}=  Show Cloudlet Info  region=${region}  cloudlet_name=${cloudlet_name_crm}

    ${rootlb}=  Set Variable  ${cloudletinfo[0]['data']['resources_snapshot']['platform_vms'][1]['ipaddresses'][0]['externalIp']}
    ${node1}=  Set Variable  ${cluster1[0]['data']['resources']['vms'][0]['ipaddresses'][0]['internalIp']}
    ${node2}=  Set Variable  ${cluster2[0]['data']['resources']['vms'][0]['ipaddresses'][0]['internalIp']}

    #${rootlb}=  Set Variable  80.187.134.197
    #${node1}=  Set Variable  10.101.20.101
    #${node2}=  Set Variable  10.101.29.101

    node should ping server  root_loadbalancer=${rootlb}  node=${node1}  server=google.com
    node should ping server  root_loadbalancer=${rootlb}  node=${node2}  server=google.com

    node should not ping server  root_loadbalancer=${rootlb}  node=${node1}  server=${node2}
    node should not ping server  root_loadbalancer=${rootlb}  node=${node2}  server=${node1}

*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    IF  '${platform_type}' == 'K8SBareMetal'
        ${numnodes}=  Set Variable  0
    ELSE
        ${numnodes}=  Set Variable  1
    END

    Create Flavor  region=${region}

    Set Suite Variable  ${numnodes}
