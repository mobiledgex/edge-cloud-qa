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
${cloudlet_name}  automationHamburgCloudlet   #has to match crm process startup parms
${operator_name}  TDG
#${latitude}	  32
#${longitude}	  -90
${flavor_name}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

*** Test Cases ***
Start 2 clusterInst

    # EDGECLOUD-420

    ${cluster_name_2}=  Catenate  SEPARATOR=  ${cluster_name_default}  2
    ${cluster_name_2}=  Get Substring  ${cluster_name_2}  0  18           # reduce string to bypass problem with 64char instance names

    #Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}

    Create Cluster		default_flavor_name=${flavor_name}
    Create Cluster		cluster_name=${cluster_name_2}  default_flavor_name=${flavor_name}
    Create Cluster Instance	cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_name=${cluster_name_default}  flavor_name=${flavor_name}
    Create Cluster Instance	cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_name=${cluster_name_2}       flavor_name=${flavor_name}

    sleep  120   #wait for prometheus to finish creating before deleting. bug for this already
	
*** Keywords ***
Setup
    #Create Developer
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  

