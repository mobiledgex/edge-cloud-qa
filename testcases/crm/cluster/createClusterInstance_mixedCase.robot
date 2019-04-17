*** Settings ***
Documentation   Create cluster instances with mixed case clustername on openstack

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library         String

Test Timeout    40 minutes
	
*** Variables ***
${cloudlet_name_openstack}  automationHawkinsCloudlet   #has to match crm process startup parms
${operator_name}  GDDT
${flavor_name}	  x1.medium

*** Test Cases ***
CRM shall be able to create a cluster instances with mixed case clustername for openstack
    [Documentation]
    ...  Create a clusters and cluster instances with a clustername of MyCluster  on openstack
    ...  Verify created successfully

    ${epoch_time}=  Get Time  epoch

    ${cluster_name_1}=  Catenate  SEPARATOR=  MyCluster  ${epoch_time}  

    Create Cluster		cluster_name=${cluster_name_1}  default_flavor_name=${flavor_name}
    Create Cluster Instance	cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  cluster_name=${cluster_name_1}  flavor_name=${flavor_name}

    sleep  120   #wait for prometheus to finish creating before deleting. bug for this already
