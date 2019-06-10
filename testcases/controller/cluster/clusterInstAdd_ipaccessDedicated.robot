*** Settings ***
Documentation   CreateClusterInst - ipaccess dedicated

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1

*** Test Cases ***
CreateClusterInst - create a clusterinst with ipaccess=IpAccessDedicated and no deployment shall default to kubernetes
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated and no deployment
    ...  verify it is set to deployment=kubernetes

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated
    Should Be Equal             ${clusterInst.deployment}  kubernetes 

CreateClusterInst - shall be able to create a clusterinst with ipaccess=IpAccessDedicated and deployment=kubernetes
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated deployment=kubernetes
    ...  verify it is set to deployment=kubernetes

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=kubernetes

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated
    Should Be Equal             ${clusterInst.deployment}  kubernetes

CreateClusterInst - create a clusterinst with ipaccess=IpAccessDedicated and deployment=helm shall default to kubernetes
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated deployment=helm
    ...  verify it is set to deployment=kubernetes

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=helm

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated
    Should Be Equal             ${clusterInst.deployment}  kubernetes

CreateClusterInst - shall not be able to create a clusterinst with ipaccess=IpAccessDedicated and deployment=vm
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated deployment=vm
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=vm

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   ClusterInst is not needed for deployment type vm, just create an AppInst directly 

CreateClusterInst - shall be not able to create a clusterinst with ipaccess=IpAccessDedicated and deployment=docker num_masters=0 num_nodes=1
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated deployment=docker and num_masters=0
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  number_masters=0  number_nodes=1

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   NumMasters and NumNodes not applicable for deployment type docker

CreateClusterInst - shall be not able to create a clusterinst with ipaccess=IpAccessDedicated and deployment=docker num_masters=1 num_nodes=0
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated deployment=docker and num_nodes=0
    ...  verify it is set to deployment=kubernetes

    ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  number_masters=1  number_nodes=0

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   NumMasters and NumNodes not applicable for deployment type docker

CreateClusterInst - shall be not able to create a clusterinst with ipaccess=IpAccessDedicated and deployment=docker num_masters=1 num_nodes=1
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated deployment=docker and num_masters=1 num_nodes=1
    ...  verify error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  number_masters=1  number_nodes=1

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   NumMasters and NumNodes not applicable for deployment type docker

CreateClusterInst - shall be able to create a clusterinst with ipaccess=IpAccessDedicated and deployment=docker num_masters=0 num_nodes=0
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated and deployment=docker num_masters=0 num_nodes=0
    ...  verify clusterinst is created

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated  deployment=docker  number_masters=0  number_nodes=0

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated
    Should Be Equal             ${clusterInst.deployment}  docker

CreateClusterInst - shall not create with IpAccessDedicated/kubernetes and multiple masters
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and multiple masters
   ...  verify error is received

   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  number_nodes=4  number_masters=2  ip_access=IpAccessDedicated  deployment=kubernetes

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   NumMasters cannot be greater than 1

CreateClusterInst - shall not create with IpAccessDedicated/kubernetes and num_masters=0 num_nodes=0
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and k8s and num_masters=0 and num_nodes=0
   ...  verify error is received

   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  number_nodes=0  number_masters=0  ip_access=IpAccessDedicated  deployment=kubernetes

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   Zero NumNodes not supported yet

CreateClusterInst - shall not create with IpAccessDedicated/kubernetes and num_masters=1 num_nodes=0
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and k8s and num_masters=1 and num_nodes=0
   ...  verify error is received

   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  number_nodes=0  number_masters=1  ip_access=IpAccessDedicated  deployment=kubernetes

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   Zero NumNodes not supported yet

CreateClusterInst - shall not create with IpAccessDedicated and invalid deployment
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and k8s and num_masters=0 and num_nodes=0
   ...  verify error is received

   ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  number_nodes=0  number_masters=0  ip_access=IpAccessDedicated  deployment=k8s

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   Invalid deployment type k8s for ClusterInst 

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    #Create Cluster
	

