*** Settings ***
Documentation   Start 2 cluster instances on same cloudlet

Library		MexController
#Library         MexCrm
#Library		MEXProcess

#Test Teardown	Cleanup provisioning

*** Variables ***
${crm_api_address}  127.0.0.1:65100
${cloudlet_name}  iperfcloudlet   #has to match crm process startup parms
${operator_name}  tmus
${latitude}	  32
${longitude}	  -90
${flavor}	  x1.medium
${number_nodes}	  3
${max_nodes}	  4
${num_masters}	  1

*** Test Cases ***
Start 2 clusterInst
      Create Cluster Flavor	cluster_flavor_name=${flavor}  node_flavor_name=${flavor}  master_flavor_name=${flavor}  number_nodes=${number_nodes}  max_nodes=${max_nodes}  number_masters=${num_masters}
      Create Cloudlet		cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  number_of_dynamic_ips=default  latitude=${latitude}  longitude=${longitude}
      Create Cluster		cluster_name=default  default_flavor_name=${flavor}
      Create Cluster		cluster_name=cluster2  default_flavor_name=${flavor}
      Create Cluster Instance	cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_name=default  flavor_name=${flavor}
      Create Cluster Instance	cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_name=cluster2  flavor_name=${flavor}

#*** Keywords ***
#Cleanup
#    Delete cloudlet	cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
#    Delete cluster	cluster_name=default
