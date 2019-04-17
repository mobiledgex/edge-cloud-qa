*** Settings ***
Documentation   Create cluster instances with long name on opentstack

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String

Test Timeout    30 minutes

Test Setup      Setup
Test Teardown   Cleanup provisioning
	
*** Variables ***
${k8s_name}       mex-k8s-node-1-
${cloudlet_name_openstack}  automationHawkinsCloudlet   #has to match crm process startup parms
${operator_name}  GDDT
${flavor_name}	  x1.medium
${cluster_name_long}=  longnameeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

*** Test Cases ***
CRM shall be able to create a cluster instances with 64 chars on openstack
    [Documentation]
    ...  Create a clusters and cluster instances with a clustername of 64 chars on openstack
    ...  Verify created successfully

    Create Cluster              cluster_name=${cluster_name}  default_flavor_name=${flavor_name}
    Create Cluster Instance	cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  cluster_name=${cluster_name}  flavor_name=${flavor_name}

    Sleep  120 s

CRM shall be able to create a cluster instances with long name on openstack
    [Documentation]
    ...  Create a clusters and cluster instances with a clustername of long name on openstack
    ...  Verify created successfully

    Create Cluster              cluster_name=${cluster_name_long}  default_flavor_name=${flavor_name}
    Create Cluster Instance     cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  cluster_name=${cluster_name_long}  flavor_name=${flavor_name}

    Sleep  120 s

*** Keywords ***
Setup
    ${k8s_length}=  Get Length  ${k8s_name}
    ${k8s_cloudlet_name}=  Catenate  SEPARATOR=  ${cloudlet_name_openstack}  -
    ${cloudlet_length}=  Get Length  ${k8s_cloudlet_name}
    ${cluster_name_long_length}=  Get Length  ${cluster_name_long}
    ${trunc_length}=  Evaluate  64 - (${k8s_length} + ${cloudlet_length})

    ${cluster_name}=  Get Substring  ${cluster_name_long}  0   ${trunc_length}

    Set Suite Variable  ${cluster_name}
