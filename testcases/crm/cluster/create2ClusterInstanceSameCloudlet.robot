*** Settings ***
Documentation   Start 2 cluster instances on same cloudlet

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Library         MexCrm
#Library		MEXProcess
Library         String
Variables       shared_variables.py

Test Teardown	Cleanup provisioning

*** Variables ***
#${crm_api_address}  127.0.0.1:65100
${cloudlet_name}  automationHawkinsCloudlet   #has to match crm process startup parms
${operator_name}  GDDT
#${latitude}	  32
#${longitude}	  -90
${flavor_name}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

*** Test Cases ***
Start 2 clusterInst

    ${epoch_time}=  Get Time  epoch

    ${cluster_name_1}=  Catenate  SEPARATOR=  cl  ${epoch_time}  
    ${cluster_name_2}=  Catenate  SEPARATOR=  ${cluster_name_1}  2

    #Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}

    Create Cluster		cluster_name=${cluster_name_1}  default_flavor_name=${flavor_name}
    Create Cluster		cluster_name=${cluster_name_2}  default_flavor_name=${flavor_name}
    Create Cluster Instance	cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_name=${cluster_name_1}  flavor_name=${flavor_name}
    Create Cluster Instance	cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_name=${cluster_name_2}  flavor_name=${flavor_name}

    sleep  120   #wait for prometheus to finish creating before deleting. bug for this already
	
*** Keywords ***
Setup
    #Create Developer
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  

