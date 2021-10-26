*** Settings ***
Documentation  Cluster size for openstack
...  ram  vcpus  disk  num_nodes  azure
...  1024   1     1       1      m4.small
...  2048   2     2       1      Standard_DS2_v2
...  4096   4     4       1      Standard_DS3_v2
...  1024   1     4       4      Standard_DS3_v2
...  1024  20    error exceeding quota

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack_shared}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT 
#${cluster_name}=  cluster1556727500-74324

${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-1310
Cluster shall create with IpAccessShared and num_nodes=4 on CRM
   [Documentation]
   ...  - create a cluster on CRM with num_nodes=4
   ...  - verify it 4 nodes and 1 master

   Create Flavor          ram=1024  vcpus=1  disk=1
   #Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  number_nodes=4  number_masters=1  ip_access=IpAccessShared
   Log to Console  DONE creating cluster instance

   IF  '${platform_type}' == 'Openstack'
      ${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
      ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

      ${server_info_node}=    Get Server List  name=${openstack_node_name}
      ${server_info_master}=  Get Server List  name=${openstack_node_master}
      Should Contain   ${server_info_node[0]['Flavor']}     .small
      Should Contain   ${server_info_node[1]['Flavor']}     .small
      Should Contain   ${server_info_node[2]['Flavor']}     .small
      Should Contain   ${server_info_node[3]['Flavor']}     .small
      Should Contain   ${server_info_master[0]['Flavor']}   .small

      ${num_servers_node}=     Get Length  ${server_info_node}
      ${num_servers_master}=   Get Length  ${server_info_master}
      Should Be Equal As Numbers  ${num_servers_node}    4   # 4 nodes
      Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
   END

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Contain   ${cluster_inst.node_flavor}   .small

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

# ECQ-1311
Cluster shall create with IpAccessShared and num_nodes=10 on CRM
   [Documentation]
   ...  - create a cluster on CRM with num_nodes=10
   ...  - verify it 10 nodes and 1 master

   Create Flavor          ram=8192  vcpus=4  disk=40
   #Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  number_nodes=10  number_masters=1  ip_access=IpAccessShared
   Log to Console  DONE creating cluster instance

   IF  '${platform_type}' == 'Openstack'
      ${openstack_node_name}=    Catenate  SEPARATOR=-  "node  \\d+  ${cloudlet_lowercase}  ${cluster_name}"
      ${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

      ${server_info_node}=    Get Server List  name=${openstack_node_name}
      ${server_info_master}=  Get Server List  name=${openstack_node_master}
      Should Be Equal   ${server_info_node[0]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[1]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[2]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[3]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[4]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[5]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[6]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[7]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[8]['Flavor']}    m4.large
      Should Be Equal   ${server_info_node[9]['Flavor']}    m4.large
      Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small

      ${num_servers_node}=     Get Length  ${server_info_node}
      ${num_servers_master}=   Get Length  ${server_info_master}
      Should Be Equal As Numbers  ${num_servers_node}    10   # 4 nodes
      Should Be Equal As Numbers  ${num_servers_master}  1   # 1 master
   END

   Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   Should Be Equal  ${cluster_inst.node_flavor}    m4.large

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

# ECQ-1312
Cluster shall not create with IpAccessShared and multiple masters
   [Documentation]
   ...  - create a cluster on CRM with multiple masters
   ...  - verify error is received

   Create Flavor          ram=1024  vcpus=1  disk=1
   #Create Cluster        

   ${cluster_name}=  Get Default Cluster Name
   ${flavor_name}=   Get Default Flavor Name

   Log to Console  START creating cluster instance
   #${cluster_inst}=  Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  number_nodes=4  number_masters=2
   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  number_nodes=0  number_masters=2  ip_access=IpAccessShared
   Log to Console  DONE creating cluster instance

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   NumMasters cannot be greater than 1

   #${openstack_node_name}=    Catenate  SEPARATOR=-  node  .  ${cloudlet_lowercase}  ${cluster_name}
   #${openstack_node_master}=  Catenate  SEPARATOR=-  master   ${cloudlet_lowercase}  ${cluster_name}

   #${server_info_node}=    Get Server List  name=${openstack_node_name}
   #${server_info_master}=  Get Server List  name=${openstack_node_master}
   #Should Be Equal   ${server_info_node[0]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[1]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[2]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_node[3]['Flavor']}    m4.small
   #Should Be Equal   ${server_info_master[0]['Flavor']}  m4.small
   #Should Be Equal   ${server_info_master[1]['Flavor']}  m4.small
   
   #${num_servers_node}=     Get Length  ${server_info_node}
   #${num_servers_master}=   Get Length  ${server_info_master}
   #Should Be Equal As Numbers  ${num_servers_node}    4   # 4 nodes
   #Should Be Equal As Numbers  ${num_servers_master}  2   # 2 master

   #Should Be Equal  ${cluster_inst.flavor.name}   ${flavor_name}
   #Should Be Equal  ${cluster_inst.node_flavor}    m4.small

   #Sleep  120 seconds  #wait for metrics apps to build before can delete

# works with 0 masters since it sets it to 1 master
#Cluster shall not create clusterInst with IpAccessShared and 0 masters
#   [Documentation]
#   ...  create a clusterInst on openstack with IpAccessShared and 0 masters
#   ...  verify error is received
#
#   Create Flavor          ram=1024  vcpus=1  disk=1
#   #Create Cluster        
#
#   Log to Console  START creating cluster instance
#   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  number_nodes=4  number_masters=0  ip_access=IpAccessShared
#   Log to Console  DONE creating cluster instance
#
#   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
#   Should Contain  ${error_msg}   NumMasters cannot be 0 except for dedicated clusters


*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    Set Suite Variable  ${platform_type}

    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_crm}

    Set Suite Variable  ${cloudlet_lowercase}
	
    #${cluster_name}=    Catenate  SEPARATOR=  cl  ${epoch_time}
    #Set Suite Variable  ${cluster_name}
