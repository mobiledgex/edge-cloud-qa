*** Settings ***
Documentation   Create cluster instances with long name

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String

Test Timeout     ${test_timeout_crm}

Test Setup      Setup
Test Teardown   Cleanup provisioning
	
*** Variables ***
${k8s_name}       mex-k8s-node-1-
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet   #has to match crm process startup parms
${operator_name_openstack}  GDDT
${cloudlet_name_azure}  automationHawkinsCloudlet   #has to match crm process startup parms
${operator_name_azure}  GDDT

${flavor_name}	  x1.medium
${cluster_name_long}=  longnameeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
${cluster_name_openstack}=  longnameeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-1277
CRM shall be able to create a cluster instances with 64 chars
    [Documentation]
    ...  - Create a clusters and cluster instances with a clustername of 64 chars
    ...  - Verify created successfully

    Create Cluster Instance	cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name}  number_nodes=${numnodes}  #flavor_name=${flavor_name}

# ECQ-1278
CRM shall be able to create a cluster instances with long name
    [Documentation]
    ...  - Create a clusters and cluster instances with a clustername of long name
    ...  - Verify created successfully

    ${cluster_name_openstack_length}=  Get Length   ${cluster_name_openstack}
    log to console   Length of cluster name=${cluster_name_openstack_length}
    Create Cluster Instance     cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_name=${cluster_name_openstack}  number_nodes=${numnodes}  #flavor_name=${flavor_name}

# ECQ-1599
CRM shall be able to create a cluster instances with long name on azure
    [Documentation]
    ...  - Create a clusters and cluster instances with a clustername of long name on azure
    ...  - Verify created successfully

    Create Cluster Instance     cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  cluster_name=${cluster_name_azure}  #flavor_name=${flavor_name}

    Sleep  1 s

*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    ${numnodes}=  Set Variable  1
    Set Suite Variable  ${numnodes}

    ${time}=  Get Time  epoch
    Create Flavor  flavor_name=flavor${time}

    ${k8s_length}=  Get Length  ${k8s_name}
    ${k8s_cloudlet_name}=  Catenate  SEPARATOR=  ${cloudlet_name_openstack_shared}  -
    ${cloudlet_length}=  Get Length  ${k8s_cloudlet_name}
    ${cluster_name_long_length}=  Get Length  ${cluster_name_long}
    ${trunc_length}=  Evaluate  64 - (${k8s_length} + ${cloudlet_length})

    log to console  ${trunc_length}
    ${cluster_name}=  Get Substring  ${cluster_name_long}  0   ${trunc_length}

    ${random_azure}=  Generate Random String  length=2  chars=[LOWER]  # generate 2 char string with lowercase only. This is because of limitations on length of resourcegroups in azure

    #${cluster_name_azure}=  Get Substring  ${cluster_name_long}  0  38  # truncate to 40chars
    ${cluster_name_azure}=  Catenate  SEPARATOR=  ${random_azure}  ${cluster_name_long}
    ${cluster_name_azure}=  Get Substring  ${cluster_name_azure}  0  38  # truncate to 40chars
 
    log to console  az=${cluster_name_azure} os=${cluster_name}
    Set Suite Variable  ${cluster_name}
    Set Suite Variable  ${cluster_name_azure}


