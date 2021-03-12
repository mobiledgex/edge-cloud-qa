*** Settings ***
Documentation  VMPool autocluster 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexKnife
Library  MexApp
Library  Collections
Library  String

Test Setup  Setup
#Suite Teardown  Teardown

*** Variables ***
${organization}=  MobiledgeX
${operator_name_vmpool}=  GDDT
${vmpool_server_name}=  vmpoolvm
${physical_name}=  beacon

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${http_page}       automation.html

${cloudlet_name_vmpool}=  automationVMPoolCloudlet
${vmpool_name}=  automationVMPool 

${latitude}       32.7767
${longitude}      -96.7970

${region}=  EU

${clustername}=  andypool

*** Test Cases ***
# ECQ-2377
AppInst autocluster shall create with VMPool IpAccessDedicated/docker/direct
   [Documentation]
   ...  - create IpAccessDedicated/docker/direct autocluster on vmpool 
   ...  - verify VMs are in use
   ...  - verify noded are connected to chef
   ...  - verify ports are accessible

   @{vm_list}=  Create List
   @{node_list}=  Create List
   
   ${app_name}=  Get Default App Name

   Log to Console  START creating cluster instance
   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=docker  access_type=direct
   ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=autocluster${cluster_name_default}  #autocluster_ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}-mobiledgex
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}-mobiledgex
   ${internal_name_lb}=  Set Variable  ${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_vm}=  Convert To Lowercase  ${internal_name_vm}
   ${internal_name_lb}=  Convert To Lowercase  ${internal_name_lb}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_lb}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_vm}
   Append To List  ${vm_list}  ${vm1}  ${vm2}

   #${node_status_lb}=  Get Node Status  qa-${region}-${internal_name_lb}
   #${node_status_vm}=  Get Node Status  qa-${region}-${internal_name_lb}
   Append To List  ${node_list}  qa-${region}-${internal_name_lb}  qa-${region}-${internal_name_vm} 

   Node Status Should Be Success  qa-${region}-${internal_name_lb}
   Node Status Should Be Success  qa-${region}-${internal_name_vm}

   #Should Be Equal  ${node_status_lb}  success
   #Should Be Equal  ${node_status_vm}  success

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2378
AppInst autocluster shall create with VMPool IpAccessDedicated/docker/lb
   [Documentation]
   ...  - create IpAccessDedicated/docker/lb autocluster on vmpool
   ...  - verify VMs are in use
   ...  - verify noded are connected to chef
   ...  - verify ports are accessible

   ${app_name}=  Get Default App Name

   @{vm_list}=  Create List
   @{node_list}=  Create List

   Log to Console  START creating cluster instance
   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=autocluster${cluster_name_default}  #autocluster_ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${app_inst['data']['real_cluster_name']}-mobiledgex
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${app_inst['data']['real_cluster_name']}-mobiledgex
   ${internal_name_lb}=  Set Variable  ${app_inst['data']['real_cluster_name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_vm}=  Convert To Lowercase  ${internal_name_vm}
   ${internal_name_lb}=  Convert To Lowercase  ${internal_name_lb}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_lb}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_vm}
   Append To List  ${vm_list}  ${vm1}  ${vm2}

   Append To List  ${node_list}  qa-${region}-${internal_name_lb}  qa-${region}-${internal_name_vm}

   #Node Status Should Be Success  qa-${region}-${internal_name_lb}
   #Node Status Should Be Success  qa-${region}-${internal_name_vm}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2379
AppInst autocluster shall create with VMPool IpAccessShared/docker/lb
   [Documentation]
   ...  - create IpAccessShared/docker/lb autocluster on vmpool
   ...  - verify VMs are in use
   ...  - verify noded are connected to chef
   ...  - verify ports are accessible

   ${app_name}=  Get Default App Name

   @{vm_list}=  Create List
   @{node_list}=  Create List

   Log to Console  START creating cluster instance
   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=autocluster${cluster_name_default}  #autocluster_ip_access=IpAccessShared
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}-mobiledgex
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}-mobiledgex
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_vm}=  Convert To Lowercase  ${internal_name_vm}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_vm}
   @{vm_list}=  Append To List  ${vm_list}  ${vm1}

   Append To List  ${node_list}  qa-${region}-${internal_name_vm}

   Sleep  5
   #Node Status Should Be Success  qa-${region}-${internal_name_vm}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2380
AppInst autocluster shall create with VMPool IpAccessShared/k8s/lb nummasters=1 numnodes=1
   [Documentation]
   ...  - create IpAccessShared/k8s/lb autocluster on vmpool
   ...  - verify VMs are in use
   ...  - verify noded are connected to chef
   ...  - verify ports are accessible

   ${app_name}=  Get Default App Name

   @{node_list}=  Create List
   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=autocluster${cluster_name_default}  #autocluster_ip_access=IpAccessShared
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${app_inst['data']['real_cluster_name']}-mobiledgex
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${app_inst['data']['real_cluster_name']}-mobiledgex
   ${internal_name_node}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${app_inst['data']['real_cluster_name']}-mobiledgex
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_master}=  Convert To Lowercase  ${internal_name_master}
   ${internal_name_node}=  Convert To Lowercase  ${internal_name_node}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node}
   Append To List  ${vm_list}  ${vm1}  ${vm2}

   #Node Status Should Be Success  qa-${region}-${internal_name_master}
   #Node Status Should Be Success  qa-${region}-${internal_name_node}
   Append To List  ${node_list}  qa-${region}-${internal_name_master}  qa-${region}-${internal_name_node}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2381
AppInst autocluster shall create with VMPool IpAccessDedicated/k8s/lb nummasters=1 numnodes=1
   [Documentation]
   ...  - create IpAccessDedicated/k8s/lb autocluster on vmpool
   ...  - verify VMs are in use
   ...  - verify noded are connected to chef
   ...  - verify ports are accessible

   ${app_name}=  Get Default App Name

   @{node_list}=  Create List
   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=autocluster${cluster_name_default}  #autocluster_ip_access=IpAccessDedicated
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}-mobiledgex
   ${internal_name_lb}=  Set Variable  ${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}-mobiledgex
   ${internal_name_node}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}-mobiledgex
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_master}=  Convert To Lowercase  ${internal_name_master}
   ${internal_name_node}=  Convert To Lowercase  ${internal_name_node}
   ${internal_name_lb}=  Convert To Lowercase  ${internal_name_lb}


   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node}
   ${vm3}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_lb}
   Append To List  ${vm_list}  ${vm1}  ${vm2}  ${vm3}

   #Node Status Should Be Success  qa-${region}-${internal_name_lb}
   #Node Status Should Be Success  qa-${region}-${internal_name_master}
   #Node Status Should Be Success  qa-${region}-${internal_name_node}
   Append To List  ${node_list}  qa-${region}-${internal_name_lb}  qa-${region}-${internal_name_master}  qa-${region}-${internal_name_node}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

*** Keywords ***
Setup
   Create Flavor  region=${region}
  
   ${cluster_name_default}=  Get Default Cluster Name
   Set Suite Variable  ${cluster_name_default}

Teardown
    [Arguments]  ${vm_list}  ${node_list}

    Cleanup Provisioning

    FOR  ${v}  IN  @{vm_list}
       VM Should Not Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  vm_name=${v}
    END

    FOR  ${n}  IN  @{node_list}
       Node Status Should Not Exist  ${n}
    END
