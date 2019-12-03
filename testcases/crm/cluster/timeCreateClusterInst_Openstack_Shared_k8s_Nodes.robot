*** Settings ***
Documentation  Cluster size for openstack with IpAccessShared and Kubernetes

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_ENV}
Library  String
Library  OperatingSystem
Library  Collections
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
#${cloudlet_name_openstack}  automationHamburgCloudlet
#${cloudlet_name_openstack}  automationBonnCloudlet
${cloudlet_name_openstack}  automationMunichCloudlet
#${cloudlet_name_openstack}   tmocloud-1
${operator_name_openstack}  TDG 
#${operator_name_openstack}  tmus
${mobiledgex_domain}  mobiledgex.net
${developer_name_openstack}   automation_api

${test_timeout_crm}  32 min
	
*** Test Cases ***
ClusterInst shall create single with IpAccessShared/kubernetes with 1 Node on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deployment type=kubernetes number of nodes 1
   ...  collect the time it takes to create the cluster and write it to a file

	Create File   ${EXECDIR}/${FileName}
	
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
	${epoch_start_time}=   Get Time  epoch
	Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    	flavor_name=${flavor_name}    number_nodes=1  number_masters=1   ip_access=IpAccessShared    deployment=kubernetes     	
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       1 Openstack Kubernetes Shared 1 Node Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}    


ClusterInst shall create single with IpAccessShared/kubernetes with 2 Nodes on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deployment type=kubernetes number of nodes 2
   ...  collect the time it takes to create the cluster and write it to a file

	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
	${epoch_start_time}=   Get Time  epoch
	Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=2  number_masters=1   ip_access=IpAccessShared    deployment=kubernetes     	
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       1 Openstack Kubernetes Shared 2 Node Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}    


ClusterInst shall create single with IpAccessShared/kubernetes with 3 Nodes on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deployment type=kubernetes number of nodes 3
   ...  collect the time it takes to create the cluster and write it to a file

	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
	${epoch_start_time}=   Get Time  epoch
	Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=3  number_masters=1   ip_access=IpAccessShared    deployment=kubernetes     	
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       1 Openstack Kubernetes Shared 3 Node Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}    

ClusterInst shall create single with IpAccessShared/kubernetes with 4 Nodes on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deployment type=kubernetes number of nodes 4
   ...  collect the time it takes to create the cluster and write it to a file

	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
	${epoch_start_time}=   Get Time  epoch
	Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=4  number_masters=1   ip_access=IpAccessShared    deployment=kubernetes     	
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       1 Openstack Kubernetes Shared 4 Node Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}    

ClusterInst shall create single with IpAccessShared/kubernetes with 5 Nodes on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deployment type=kubernetes number of nodes 5
   ...  collect the time it takes to create the cluster and write it to a file

	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
	${epoch_start_time}=   Get Time  epoch
	Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=5  number_masters=1   ip_access=IpAccessShared    deployment=kubernetes     	
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       1 Openstack Kubernetes Shared 5 Node Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}    


ClusterInst shall create single with IpAccessShared/kubernetes with 10 Nodes on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessShared and deployment type=kubernetes number of nodes 10
   ...  collect the time it takes to create the cluster and write it to a file

	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
	${epoch_start_time}=   Get Time  epoch
	Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=10  number_masters=1   ip_access=IpAccessShared    deployment=kubernetes     	
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       1 Openstack Kubernetes Shared 10 Node Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}    



*** Keywords ***
Setup

	${flavor_name}=     Set Variable     automation_api_flavor
	${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack}
	${FileName}=    Catenate  SEPARATOR=    ${cloudlet_name_openstack}   OpenstackTimingsK8sSharedNodes
	${x}=  Evaluate    random.randint(2,20000)   random
	${x}=  Convert To String  ${x}
	${cluster_name}=  Catenate  SEPARATOR=  timingcluster  ${x}

	Set Suite Variable  ${cloudlet_lowercase}

	${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
	${rootlb}=  Convert To Lowercase  ${rootlb}

	Set Suite Variable    ${rootlb}
	Set Suite Variable    ${FileName}
	Set Suite Variable    ${flavor_name}
	Set Suite Variable    ${cluster_name}	
