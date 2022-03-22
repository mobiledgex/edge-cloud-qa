# -*- coding: robot -*-
*** Settings ***
Documentation  Cloudletinfo show resources snapshot platformvms info  
	
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections

Test Setup	Setup
Test Teardown	Cleanup Provisioning

*** Variables ***

${openstack_cloudlet}=  automationBuckhornCloudlet
${openstack_org}=  GDDT
${vcd_cloudlet}=  automationDallasCloudlet
${vcd_org}=  packet
${region}=  US
${mobiledgex_domain}=  mobiledgex.net
${type_unknown}=  unknown
${ip_none}=       None
${type_drlb}=  dedicatedrootlb
${type_srlb}=  sharedrootlb
${platform_vm}=  platformvm
${k8s_cluster}=  porttestcluster
${k8s_master}=  k8s-cluster-master
${k8s_node}=    k8s-cluster-node
${docker_node}=      docker-cluster-node
${status_active}=  ACTIVE
${status_off}=     SHUTOFF
${status_error}=   ERROR
${status_p_on}=    POWERED_ON
${status_p_off}=   POWERED_OFF
#name changes used checking old load
${type_rlb_old}=  rootlb
${platform_old}=  platform
${master_old}=  cluster-master
${node_k8s_old}=  cluster-k8s-node
${docker_node_old}=  cluster-docker-node
#Changes to naming old --> new
#cluster-master --> k8s-cluster-master
#cluster-k8s-node --> k8s-cluster-node
#cluster-docker-node --> docker-cluster-node

*** Test Cases ***
# EC-6249
# ECQ:4409
showCloudletinfo - mcctl shall be able to request resources snapshot status
   [Documentation]
   ...  - send cloudletinfo show for openstack and vcd cloudlet 
   ...  - verify resources snapshot platform vms name
   ...  - verify resources snapshot platform vms type
   ...  - verify resources snapshot platform vms status
   ...  - verify resources snapshot platform vms ipaddresses

   [Template]  Resources Snapshot Via mcctl
        region=${region}  cloudlet=${openstack_cloudlet}  cloudletorg=${openstack_org}
        region=${region}  cloudlet=${vcd_cloudlet}  cloudletorg=${vcd_org}

# EC-6263
showClusterinfo - mcctl shall be able to request resources snapshot info
   [Documentation]
   ...  - send clusterinfo show for openstack and vcd cloudlet
   ...  - verify resources snapshot vms name
   ...  - verify resources snapshot vms type
   ...  - verify resources snapshot vms status
   ...  - verify resources snapshot vms ipaddresses

   [Template]  Cluster Resources Snapshot Via mcctl
        region=${region}  cloudlet=${openstack_cloudlet}  cloudletorg=${openstack_org}  cluster=${k8s_cluster}
        region=${region}  cloudlet=${vcd_cloudlet}  cloudletorg=${vcd_org}  cluster=${k8s_cluster}

*** Keywords ***
Setup
   ${super_token}=  Get Super Token
   Set Suite Variable  ${super_token}

Resources Snapshot Via mcctl
   [Arguments]  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   ${cloudlet_info}=  Run mcctl  cloudletinfo show ${parmss}

   ${org_parms}=  Set Variable  ${parms['cloudletorg']}
   Set Variable  ${org_parms}
   ${cloudlet_parms}=  Set Variable  ${parms['cloudlet']}
   Set Variable  ${cloudlet_parms}
   ${cloudlet_pf}=  Catenate  SEPARATOR=-  ${cloudlet_parms}  ${org_parms}  pf
   Set Test Variable  ${cloudlet_pf}  
   ${cloudlet_lb}=  Catenate  SEPARATOR=.  ${cloudlet_parms}  ${org_parms}  ${mobiledgex_domain}
   ${cloudlet_lb}=  Convert To Lowercase  ${cloudlet_lb}
   Set Test Variable  ${cloudlet_lb}
   @{node_status}=  Create List   ${status_active}  ${status_off}  ${status_error}  ${status_p_on}  ${status_p_off}
   
   Dictionary Should Contain Key  ${cloudlet_info[0]}  resources_snapshot
   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][0]['name']}  ${cloudlet_pf}
   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][0]['type']}  ${platform_vm}
   Should Contain Any  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][0]['status']}  IN  @{node_status} 
   Dictionary Should Contain Key  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][0]['ipaddresses'][0]}   externalIp

   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['name']}  ${cloudlet_lb}
   Should Be Equal  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['type']}  ${type_srlb}
   Should Contain Any  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['status']}  IN  @{node_status}
   Should Be True  'externalIp' in ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['ipaddresses'][0]} or 'externalIp' in ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['ipaddresses'][1]}
   #Dictionary Should Contain Key  ${cloudlet_info[0]['resources_snapshot']['platform_vms'][1]['ipaddresses'][0]}   externalIp


Cluster Resources Snapshot Via mcctl
   [Arguments]  &{parms}
   ${parmss}=  Evaluate  ''.join(f'{key}={str(val)} ' for key, val in &{parms}.items())
   ${cluster_info}=  Run mcctl  clusterinst show ${parmss}

   ${org_parms}=  Set Variable  ${parms['cloudletorg']}
   Set Variable  ${org_parms}
   ${cloudlet_parms}=  Set Variable  ${parms['cloudlet']}
   Set Variable  ${cloudlet_parms}
   ${cloudlet_pf}=  Catenate  SEPARATOR=-  ${cloudlet_parms}  ${org_parms}  pf
   Set Test Variable  ${cloudlet_pf}
   ${cloudlet_lb}=  Catenate  SEPARATOR=.  ${cloudlet_parms}  ${org_parms}  ${mobiledgex_domain}
   ${cloudlet_lb}=  Convert To Lowercase  ${cloudlet_lb}
   Set Test Variable  ${cloudlet_lb}


   @{type_error}=  Create List   ${type_unknown}  ${ip_none}
   Should Be True  len(@{type_error}) >= 2
   @{node_status}=  Create List   ${status_active}  ${status_off}  ${status_error}  ${status_p_on}  ${status_p_off}
   Should Be True  len(@{node_status}) >= 5
   @{type_old}=  Create List   ${type_rlb_old}  ${master_old}  ${node_k8s_old} 
   Should Be True  len(@{type_old}) >= 3
   @{type_new}=  Create List   ${type_drlb}  ${k8s_master}  ${k8s_node}  ${type_drlb}
   Should Be True  len(@{type_new}) >= 4

   Dictionary Should Contain Key  ${cluster_info[0]}  resources
   Should Be Equal  ${cluster_info[0]['key']['cloudlet_key']['name']}  ${cloudlet_parms}
   Should Be Equal  ${cluster_info[0]['key']['cloudlet_key']['organization']}  ${org_parms}
   Should Contain Any  ${cluster_info[0]['resources']['vms'][0]['status']}  IN  @{node_status}
   Should Contain Any  ${cluster_info[0]['resources']['vms'][0]['type']}  IN  @{type_new}   # OR  @{type_old}  OR  @{type_error}
   Should Contain Any  ${cluster_info[0]['resources']['vms'][1]['type']}  IN  @{type_new}   # OR  @{type_old}  OR  @{type_error} 
   Should Contain Any  ${cluster_info[0]['resources']['vms'][2]['type']}  IN  @{type_new}   # OR  @{type_old}  OR  @{type_error} 
   Should Contain Any  ${cluster_info[0]['resources']['vms'][1]['ipaddresses'][0]}   externalIp  internalIp
   Should Contain Any  ${cluster_info[0]['resources']['vms'][0]['ipaddresses'][0]}   externalIp  internalIp
   Run Keyword If  ${cluster_info[0]['resources']['vms'][1]['ipaddresses']} != None  Should Contain Any  ${cluster_info[0]['resources']['vms'][1]['ipaddresses'][0]}   internalIp  externalIp
   Should Contain Any  ${cluster_info[0]['resources']['vms'][2]['ipaddresses'][0]}   externalIp  internalIp 
