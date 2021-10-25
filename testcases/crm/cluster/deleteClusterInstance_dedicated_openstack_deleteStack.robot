*** Settings ***
Documentation  Delete ClusterInst/AppInst after stack has been deleted 

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet
${operator_name_openstack}            TDG 
${mobiledgex_domain}                  mobiledgex.net
${docker_image}                       docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}                     ./server_ping_threaded.py

${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-2423
ClusterInst/AppInst shall be deleted with IpAccessDedicated/docker on openstack when no stack exists
   [Documentation]
   ...  - create a clusterinst/appinst on openstack with IpAccessDedicated and deploymenttype=docker
   ...  - delete the stack from openstack
   ...  - delete the appinst and clusterinst 

   #Create Flavor          ram=1024  vcpus=1  disk=1

   ${cluster_name}=  Get Default Cluster Name
   ${developer_name}=  Get Default Developer Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  number_nodes=0  number_masters=0  ip_access=IpAccessDedicated  deployment=docker  #no_auto_delete={$True}
   Log to Console  DONE creating cluster instance

   Create App  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment=docker  #default_flavor_name=${cluster_flavor_name}
   Create App Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}

   ${openstack_stack_name}=    Catenate  SEPARATOR=-  ${cloudlet_lowercase_dedicated}  ${cluster_name}  ${developer_name}
   Delete Stack  ${openstack_stack_name}

   Sleep  30

   #Delete Cluster Instance

# ECQ-2424
ClusterInst/AppInst shall be deleted with IpAccessDedicated/k8s on openstack when no stack exists
   [Documentation]
   ...  - create a clusterinst/appinst on openstack with IpAccessDedicated and deploymenttype=k8s
   ...  - delete the stack from openstack
   ...  - delete the appinst and clusterinst

   #Create Flavor          ram=1024  vcpus=1  disk=1

   ${cluster_name}=  Get Default Cluster Name
   ${developer_name}=  Get Default Developer Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  number_nodes=1  number_masters=1  ip_access=IpAccessDedicated  deployment=kubernetes  #no_auto_delete={$True}
   Log to Console  DONE creating cluster instance

   ${openstack_stack_name}=    Catenate  SEPARATOR=-  ${cloudlet_lowercase_dedicated}  ${cluster_name}  ${developer_name}

   Delete Stack  ${openstack_stack_name}

   Sleep  30

   #Delete Cluster Instance

*** Keywords ***
Setup
    Create Flavor          ram=1024  vcpus=1  disk=1
    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase_dedicated}=  Convert to Lowercase  ${cloudlet_name_crm}

    Set Suite Variable  ${cloudlet_lowercase_dedicated}
