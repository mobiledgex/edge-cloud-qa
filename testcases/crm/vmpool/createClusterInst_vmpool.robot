*** Settings ***
Documentation  CreateClusterInst/CreateAppInst for VM Pools 

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_VMPOOL_ENV}
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
# ECQ-2397
VM should be free after CreateClusterInst and UpdateVMPool state=VmForceFree
   [Documentation]
   ...  - CreateClusteInst with IpAccessDedicated/docker on vm pool
   ...  - CreateAppInst with direct access
   ...  - Verify VM is inuse in the pool
   ...  - UpdateVMPool with state=VmForceFree
   ...  - Verify VM is free

   @{vm_list}=  Create List
   @{node_list}=  Create List

   ${app_name}=  Get Default App Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=docker
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_lb}=  Set Variable  ${cluster_inst['data']['key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_vm}=  Convert To Lowercase  ${internal_name_vm}
   ${internal_name_lb}=  Convert To Lowercase  ${internal_name_lb}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_lb}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_vm}
   Append To List  ${vm_list}  ${vm1}  ${vm2}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

   ${pool}=  Show VM Pool  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}
   @{update_list}=  Create List
   FOR  ${vm}  IN  @{pool[0]['data']['vms']}
      &{update_dict}=  Run Keyword If  'group_name' in $vm   Build Update  group_name=${group_name}  vm_group_name=${vm['group_name']}  name=${vm['name']}  external_ip=${vm['net_info']['external_ip']}  internal_ip=${vm['net_info']['internal_ip']}  state=6
      ...  ELSE  Build Update  group_name=${None}  vm_group_name=${None}  name=${vm['name']}  external_ip=${vm['net_info']['external_ip']}  internal_ip=${vm['net_info']['internal_ip']}  state=${None}
      Append To List  ${update_list}  ${update_dict}
   END
   log to console  ${update_list}

   ${update_return}=  Update VM Pool  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  vm_list=${update_list}

   VM Should Not Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  vm_name=${vm1}
   VM Should Not Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  vm_name=${vm2}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2369
ClusterInst/AppInst shall create with VMPool IpAccessDedicated/docker/direct
   [Documentation]
   ...  - CreateClusteInst with IpAccessDedicated/docker on vm pool
   ...  - CreateAppInst with direct access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible 

   @{vm_list}=  Create List
   @{node_list}=  Create List
   
   ${app_name}=  Get Default App Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=docker
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_lb}=  Set Variable  ${cluster_inst['data']['key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
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

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=docker  access_type=direct
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

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

# ECQ-2370
ClusterInst/AppInst shall create with VMPool IpAccessDedicated/docker/lb
   [Documentation]
   ...  - CreateClusteInst with IpAccessDedicated/docker on vm pool
   ...  - CreateAppInst with loadbalancer access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible

   ${app_name}=  Get Default App Name

   @{vm_list}=  Create List
   @{node_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=docker
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_lb}=  Set Variable  ${cluster_inst['data']['key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_vm}=  Convert To Lowercase  ${internal_name_vm}
   ${internal_name_lb}=  Convert To Lowercase  ${internal_name_lb}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_lb}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_vm}
   Append To List  ${vm_list}  ${vm1}  ${vm2}

   Append To List  ${node_list}  qa-${region}-${internal_name_lb}  qa-${region}-${internal_name_vm}

   #Node Status Should Be Success  qa-${region}-${internal_name_lb}
   #Node Status Should Be Success  qa-${region}-${internal_name_vm}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

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

# ECQ-2371
ClusterInst/AppInst shall create with VMPool IpAccessShared/docker/lb
   [Documentation]
   ...  - CreateClusteInst with IpAccessShared/docker on vm pool
   ...  - CreateAppInst with loadbalancer access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible

   ${app_name}=  Get Default App Name

   @{vm_list}=  Create List
   @{node_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=docker
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_vm}=  Set Variable  mex-docker-vm-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_vm}=  Convert To Lowercase  ${internal_name_vm}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_vm}
   @{vm_list}=  Append To List  ${vm_list}  ${vm1}

   Append To List  ${node_list}  qa-${region}-${internal_name_vm}

   Sleep  5
   #Node Status Should Be Success  qa-${region}-${internal_name_vm}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

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

# ECQ-2372
ClusterInst/AppInst shall create with VMPool IpAccessShared/k8s/lb nummasters=1 numnodes=1
   [Documentation]
   ...  - CreateClusteInst with IpAccessShared/k8s nummasters=1 numnodes=1 on vm pool
   ...  - CreateAppInst with loadbalancer access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible

   ${app_name}=  Get Default App Name

   @{node_list}=  Create List
   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=1
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_node}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_master}=  Convert To Lowercase  ${internal_name_master}
   ${internal_name_node}=  Convert To Lowercase  ${internal_name_node}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node}
   Append To List  ${vm_list}  ${vm1}  ${vm2}

   #Node Status Should Be Success  qa-${region}-${internal_name_master}
   #Node Status Should Be Success  qa-${region}-${internal_name_node}
   Append To List  ${node_list}  qa-${region}-${internal_name_master}  qa-${region}-${internal_name_node}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}
   log to console  ${fqdn_0} ${fqdn_1}
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2373
ClusterInst/AppInst shall create with VMPool IpAccessDedicated/k8s/lb nummasters=1 numnodes=1
   [Documentation]
   ...  - CreateClusterInst with IpAccessDedicated/k8s nummasters=1 numnodes=1 on vm pool
   ...  - CreateAppInst with loadbalancer access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible

   ${app_name}=  Get Default App Name

   @{node_list}=  Create List
   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=kubernetes  number_masters=1  number_nodes=1
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_lb}=  Set Variable  ${cluster_inst['data']['key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_node}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
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
   Append To List  ${node_list}  qa-${region}-${internal_name_master}  qa-${region}-${internal_name_node}  qa-${region}-${internal_name_lb}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}
   log to console  ${fqdn_0} ${fqdn_1}
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2374
ClusterInst/AppInst shall create with VMPool IpAccessShared/k8s/lb nummasters=1 numnodes=0
   [Documentation]
   ...  - CreateClusterInst with IpAccessShared/k8s nummasters=1 numnodes=0 on vm pool
   ...  - CreateAppInst with loadbalancer access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible

   ${app_name}=  Get Default App Name

   @{node_list}=  Create List
   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=0
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_master}=  Convert To Lowercase  ${internal_name_master}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   Append To List  ${vm_list}  ${vm1}

   #Node Status Should Be Success  qa-${region}-${internal_name_master}
   Append To List  ${node_list}  qa-${region}-${internal_name_master}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}
   log to console  ${fqdn_0} ${fqdn_1}
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2375
ClusterInst/AppInst shall create with VMPool IpAccessShared/k8s/lb nummasters=1 numnodes=2
   [Documentation]
   ...  - CreateClusterInst with IpAccessShared/k8s nummasters=1 numnodes=2 on vm pool
   ...  - CreateAppInst with loadbalancer access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible

   ${app_name}=  Get Default App Name

   @{node_list}=  Create List
   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=2
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_node1}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_node2}=  Set Variable  mex-k8s-node-2-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_master}=  Convert To Lowercase  ${internal_name_master}
   ${internal_name_node1}=  Convert To Lowercase  ${internal_name_node1}
   ${internal_name_node2}=  Convert To Lowercase  ${internal_name_node2}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node1}
   ${vm3}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node2}
   Append To List  ${vm_list}  ${vm1}  ${vm2}  ${vm3}

   #Node Status Should Be Success  qa-${region}-${internal_name_master}
   #Node Status Should Be Success  qa-${region}-${internal_name_node1}
   #Node Status Should Be Success  qa-${region}-${internal_name_node2}
   Append To List  ${node_list}  qa-${region}-${internal_name_master}  qa-${region}-${internal_name_node1}  qa-${region}-${internal_name_node2}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}
   log to console  ${fqdn_0} ${fqdn_1}
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

# ECQ-2376
ClusterInst/AppInst shall create with VMPool IpAccessShared/k8s/lb after adding new pool member
   [Documentation]
   ...  - CreateClusterInst with IpAccessShared/k8s nummasters=1 numnodes=4 on vm pool
   ...  - Verify it fails because there are not enough vms in the pool
   ...  - AddVmPoolMember to add another member to the pool
   ...  - CreateClusterInst with IpAccessShared/k8s nummasters=1 numnodes=4 on vm pool
   ...  - CreateAppInst with loadbalancer access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible

   ${app_name}=  Get Default App Name

   @{node_list}=  Create List
   @{vm_list}=  Create List

   ${error}=  Run Keyword and Expect Error  *  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=4
   #Should Contain  ${error}  Encountered failures: Create failed: Cluster VM create Failed: Unable to find a free VM with internal network connectivity","code":400
   Should Contain  ${error}  Encountered failures: Create failed: Cluster VM create Failed: Failed to meet VM requirement

   ${ymlfile}=  Find File  vmpool_template_1server.yml
   Create Stack  file=${ymlfile}  name=${app_name}stack
   Sleep  60  # wait for server to come up
   ${new_server}=  Get Server List  name=automationvmpool7
   ${networks}=  Split String  ${new_server[0]['Networks']}   separator=;
   ${ext_network}=  Split String  ${networks[0]}  separator==
   ${int_network}=  Split String  ${networks[1]}  separator==

   Add VM Pool Member  region=${region}  vm_pool_name=${vmpool_name}  org_name=GDDT  vm_name=x1  external_ip=${ext_network[1]}  internal_ip=${int_network[1]}

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessShared  deployment=kubernetes  number_masters=1  number_nodes=4
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-mobiledgex
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_node1}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_node2}=  Set Variable  mex-k8s-node-2-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_master}=  Convert To Lowercase  ${internal_name_master}
   ${internal_name_node1}=  Convert To Lowercase  ${internal_name_node1}
   ${internal_name_node2}=  Convert To Lowercase  ${internal_name_node2}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node1}
   ${vm3}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node2}
   Append To List  ${vm_list}  ${vm1}  ${vm2}  ${vm3}

   #Node Status Should Be Success  qa-${region}-${internal_name_master}
   #Node Status Should Be Success  qa-${region}-${internal_name_node1}
   #Node Status Should Be Success  qa-${region}-${internal_name_node2}
   Append To List  ${node_list}  qa-${region}-${internal_name_master}  qa-${region}-${internal_name_node1}  qa-${region}-${internal_name_node2}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}
   log to console  ${fqdn_0} ${fqdn_1}
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][2]['public_port']}  ${page}

   [Teardown]  TeardownStack  ${app_name}stack  ${vm_list}  ${node_list}

# ECQ-2422
ClusterInst shall update with VMPool IpAccessDedicated/k8s/lb nummasters=1 numnodes=2
   [Documentation]
   ...  - CreateClusterInst with IpAccessDedicated/k8s nummasters=1 numnodes=1 on vm pool
   ...  - CreateAppInst with loadbalancer access
   ...  - Verify VM is inuse in the pool
   ...  - Verify Knife status is correct
   ...  - Register/FindCloudlet and verify the ports are accessible
   ...  - UpdateClusterInst by adding another worker node
   ...  - Verify new VM is inuse in the pool
   ...  - Verify new Knife status is correct

   ${app_name}=  Get Default App Name

   @{node_list}=  Create List
   @{vm_list}=  Create List

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  ip_access=IpAccessDedicated  deployment=kubernetes  number_masters=1  number_nodes=1
   Log to Console  DONE creating cluster instance

   ${organization_lc}=  Convert To Lowercase  ${organization}
   ${operator_lc}=  Convert To Lowercase  ${operator_name_vmpool}

   ${group_name}=  Set Variable  ${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_lb}=  Set Variable  ${cluster_inst['data']['key']['cluster_key']['name']}.${cloudlet_name_vmpool}.${operator_lc}.mobiledgex.net
   ${internal_name_master}=  Set Variable  mex-k8s-master-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_node}=  Set Variable  mex-k8s-node-1-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${internal_name_node2}=  Set Variable  mex-k8s-node-2-${cloudlet_name_vmpool}-${cluster_inst['data']['key']['cluster_key']['name']}-automation-dev-org
   ${group_name}=  Convert To Lowercase  ${group_name}
   ${internal_name_master}=  Convert To Lowercase  ${internal_name_master}
   ${internal_name_node}=  Convert To Lowercase  ${internal_name_node}
   ${internal_name_node2}=  Convert To Lowercase  ${internal_name_node2}
   ${internal_name_lb}=  Convert To Lowercase  ${internal_name_lb}

   ${vm1}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_master}
   ${vm2}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node}
   ${vm3}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_lb}
   Append To List  ${vm_list}  ${vm1}  ${vm2}  ${vm3}

   #Node Status Should Be Success  qa-${region}-${internal_name_lb}
   #Node Status Should Be Success  qa-${region}-${internal_name_master}
   #Node Status Should Be Success  qa-${region}-${internal_name_node}
   Append To List  ${node_list}  qa-${region}-${internal_name_master}  qa-${region}-${internal_name_node}  qa-${region}-${internal_name_lb}

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=kubernetes  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}
   log to console  ${fqdn_0} ${fqdn_1}
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][2]['public_port']}  ${page}

   Log To Console  Updating Cluster Instance
   Update Cluster Instance   region=${region}  cloudlet_name=${cloudlet_name_vmpool}  operator_org_name=${operator_name_vmpool}  number_nodes=2
   Log To Console  Done Updating Cluster Instance

   ${vm4}=  VM Should Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  group_name=${group_name}  internal_name=${internal_name_node}
   Append To List  ${vm_list}  ${vm4}

   #Node Status Should Be Success  qa-${region}-${internal_name_node2}
   Append To List  ${node_list}  qa-${region}-${internal_name_node2}

   [Teardown]  Teardown  ${vm_list}  ${node_list}

*** Keywords ***
Setup
   Create Flavor  region=${region}
  
   ${cluster_name_default}=  Get Default Cluster Name
   Set Suite Variable  ${cluster_name_default}

   #${token}=  Get Super Token
   #Set Suite Variable  ${token}

   #${server_list}=  Get Server List  ${vmpool_server_name}
   #@{pool_list}=  Create List
   #FOR  ${i}  IN  @{server_list}
   #   log to console  ${i}
   #   @{net_list}=  Split String  ${i['Networks']}  separator=;
   #   @{ext_ip}=  Split String  ${net_list[0]}  separator==
   #   @{int_ip}=  Split String  ${net_list[1]}  separator==
#
#      &{vm1}=  Create Dictionary  name=${i['Name']}  external_ip=${ext_ip[1]}  internal_ip=${int_ip[1]}
#      Append To List  ${pool_list}  ${vm1}       
#   END 
#
#   ${pool_return1}=  Create VM Pool  region=US  org_name=${operator_organization}  vm_list=${pool_list}
#
#   Set Suite Variable  ${pool_return1}

Build Update
    [Arguments]  ${name}  ${group_name}  ${vm_group_name}  ${external_ip}  ${internal_ip}  ${state}

      &{update_dict}=  Run Keyword If  '${vm_group_name}' == '${group_name}'  Create Dictionary  name=${name}  external_ip=${external_ip}  internal_ip=${internal_ip}  state=${state}
      ...  ELSE  Create Dictionary  name=${name}  external_ip=${external_ip}  internal_ip=${internal_ip}

#      &{update_dict}=  Create Dictionary  name=${name}  external_ip=${external_ip}  internal_ip=${internal_ip}  state=${state}

    [Return]  ${update_dict}

TeardownStack
    [Arguments]  ${stack_name}  ${vm_list}  ${node_list}

    Teardown  ${vm_list}  ${node_list}

    Run Keyword and Ignore Error  Remove VM Pool Member  region=US  vm_pool_name=${vmpool_name}  org_name=GDDT  vm_name=x1
    Run Keyword and Ignore Error  Delete Stack  name=${stack_name}

Teardown
    [Arguments]  ${vm_list}  ${node_list}

    Cleanup Provisioning

    FOR  ${v}  IN  @{vm_list}
       VM Should Not Be In Use  region=${region}  vm_pool_name=${vmpool_name}  org_name=${operator_name_vmpool}  vm_name=${v}
    END

    FOR  ${n}  IN  @{node_list}
       Node Status Should Not Exist  ${n}
       #${error}=  Run Keyword and Expect Error  *  Get Node Status  qa-${region}-${n}
       #Should Contain  ${error}  ERROR: The object you are looking for could not be found 
    END
