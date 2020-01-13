*** Settings ***
Documentation  Cluster size for openstack with IpAccessDedicated and Docker

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  String
Library  OperatingSystem
Library  Collections
Library  DateTime
Library  Process
			
Suite Teardown  WriteHTML
Test Setup      Setup
Test Teardown   Teardown

Test Timeout     ${test_timeout_crm} 
	
*** Variables ***
#${cloudlet_name_openstack}   automationHamburgCloudlet
#${cloudlet_name_openstack}   automationBonnCloudlet
#${cloudlet_name_openstack}   automationBerlinCloudlet
#${cloudlet_name_openstack}   automationGcpCentralCloudlet
#${cloudlet_name_openstack}   automationAzureCentralCloudlet
#${cloudlet_name_openstack}   automationMunichCloudletStage
${cloudlet_name_openstack}   automationFrankfurtCloudlet
#${cloudlet_name_openstack}   edmonton-main
#${cloudlet_name_openstack}   tmocloud-1
#${operator_name_openstack}   gcp 
#${operator_name_openstack}   azure 
${operator_name_openstack}   TDG
#${operator_name_openstack}   TELUS 
#${operator_name_openstack}   tmus
${mobiledgex_domain}    mobiledgex.net
${developer_name_openstack}     automation_api

${test_timeout_crm}  32 min
	
*** Test Cases ***
ClusterInst Timing shall create single with IpAccessDedicated/docker on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and deploymenttype=docker
   ...  collect the time it takes to create the cluster and write it to a file

        ${testtime}=   Get Time  epoch
	${testtime}=   Convert To String    ${testtime}
	${testtime}=   Catenate  SEPARATOR=   ${testtime}  \n
	Create File   ${EXECDIR}/${FileName}
	Append To File   ${EXECDIR}/${FileName}    ${testtime}  
	Clear Thread Dict
	Set Suite Variable    ${testnum}   1
	
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	 
	${epoch_start_time}=   Get Time  epoch
	Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=0  number_masters=0   ip_access=IpAccessDedicated    deployment=docker     	
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       ${testnum} Openstack Docker Dedicated Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}     
	Write Data   


ClusterInst Timing shall create 2 with IpAccessDedicated/docker on openstack
   [Documentation]
   ...  create 2 clusters on openstack with IpAccessDedicated and deploymenttype=docker
   ...  collect the time it takes to create the clusters and write it to a file

	Clear Thread Dict
	Set Suite Variable    ${testnum}   2
	
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	
	@{handle_list}=  Create List
	${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   2
	
	${epoch_start_time}=   Get Time  epoch
	: FOR  ${INDEX}  IN RANGE  0  2
	\  ${y}=   Convert To String   ${INDEX}
	\  ${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   ${y}
	\  ${handle}=   Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=0  number_masters=0   ip_access=IpAccessDedicated    deployment=docker     use_thread=${True}    del_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	MexController.Wait For Replies    @{handle_list}
	${epoch_end_time}=     Get Time  epoch

	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       ${testnum} Openstack Docker Dedicated Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}     
	Write Data   


ClusterInst Timing shall create 3 with IpAccessDedicated/docker on openstack
   [Documentation]
   ...  create 3 clusters on openstack with IpAccessDedicated and deploymenttype=docker
   ...  collect the time it takes to create the clusters and write it to a file

	Clear Thread Dict
	Set Suite Variable    ${testnum}    3
	
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	
	@{handle_list}=  Create List
	${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   3
	
	${epoch_start_time}=   Get Time  epoch
	: FOR  ${INDEX}  IN RANGE  0  3
	\  ${y}=   Convert To String   ${INDEX}
	\  ${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   ${y}
	\  ${handle}=   Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=0  number_masters=0   ip_access=IpAccessDedicated    deployment=docker     use_thread=${True}    del_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	MexController.Wait For Replies    @{handle_list}
	${epoch_end_time}=     Get Time  epoch

	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       ${testnum} Openstack Docker Dedicated Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}     
	Write Data   


ClusterInst Timing shall create 4 with IpAccessDedicated/docker on openstack
   [Documentation]
   ...  create 4 clusters on openstack with IpAccessDedicated and deploymenttype=docker
   ...  collect the time it takes to create the clusters and write it to a file

	Clear Thread Dict
	Set Suite Variable    ${testnum}   4
	
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	
	@{handle_list}=  Create List
	${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   4
	
	${epoch_start_time}=   Get Time  epoch
	: FOR  ${INDEX}  IN RANGE  0  4
	\  ${y}=   Convert To String   ${INDEX}
	\  ${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   ${y}
	\  ${handle}=   Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=0  number_masters=0   ip_access=IpAccessDedicated    deployment=docker     use_thread=${True}    del_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	MexController.Wait For Replies    @{handle_list}
	${epoch_end_time}=     Get Time  epoch

	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       ${testnum} Openstack Docker Dedicated Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}     
	Write Data   


ClusterInst Timing shall create 5 with IpAccessDedicated/docker on openstack
   [Documentation]
   ...  create 5 clusters on openstack with IpAccessDedicated and deploymenttype=docker
   ...  collect the time it takes to create the clusters and write it to a file

	Clear Thread Dict
	Set Suite Variable    ${testnum}   5
		
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	
	@{handle_list}=  Create List
	${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   5
	
	${epoch_start_time}=   Get Time  epoch
	: FOR  ${INDEX}  IN RANGE  0  5
	\  ${y}=   Convert To String   ${INDEX}
	\  ${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   ${y}
	\  ${handle}=   Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=0  number_masters=0   ip_access=IpAccessDedicated    deployment=docker     use_thread=${True}    del_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	MexController.Wait For Replies    @{handle_list}
	${epoch_end_time}=     Get Time  epoch

	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       ${testnum} Openstack Docker Dedicated Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}     
	Write Data   


ClusterInst Timing shall create 10 with IpAccessDedicated/docker on openstack
   [Documentation]
   ...  create 10 clusters on openstack with IpAccessDedicated and deploymenttype=docker
   ...  collect the time it takes to create the clusters and write it to a file

	Clear Thread Dict
	Set Suite Variable     ${testnum}    10
	
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	
	@{handle_list}=  Create List
	${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   6
		
	${epoch_start_time}=   Get Time  epoch
	: FOR  ${INDEX}  IN RANGE  0  10
	\  ${y}=   Convert To String   ${INDEX}
	\  ${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   ${y}
	\  ${handle}=   Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_name=${operator_name_openstack}    developer_name=${developer_name_openstack}    flavor_name=${flavor_name}   number_nodes=0  number_masters=0   ip_access=IpAccessDedicated    deployment=docker     use_thread=${True}    del_thread=${True}
	\  Append To List   ${handle_list}   ${handle}
	MexController.Wait For Replies    @{handle_list}
	${epoch_end_time}=     Get Time  epoch

	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	
	${FileData}=     Set Variable       ${testnum} Openstack Docker Dedicated Cluster Creation Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}     
	Write Data   


*** Keywords ***
Setup
	${testdate}=    Get Time  epoch
	${testdate}=    Convert Date    ${testdate}       result_format=%d-%m-%Y
	${testdate}=     Catenate  SEPARATOR=      -      ${testdate}
	${flavor_name}=     Set Variable     automation_api_flavor
	${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack}
	${FileName}=    Catenate  SEPARATOR=    ${cloudlet_name_openstack}   OpenstackTimingsDockerDedicated
	${FileName}=    Catenate  SEPARATOR=    ${FileName}     ${testdate}	
	${FileName}=    Catenate  SEPARATOR=    ${FileName}     .timings
	
	${x}=  Evaluate    random.randint(2,20000)   random
	${x}=  Convert To String  ${x}
	${cluster_name}=  Catenate  SEPARATOR=  timecl  ${x}
	${testnum}=   Set Variable   1
        ${failedData}=   Set Variable    Test Failed

	Set Suite Variable  ${cloudlet_lowercase}
	Set Suite Variable  ${testnum}
	Set Suite Variable  ${failedData}

	${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
	${rootlb}=  Convert To Lowercase  ${rootlb}

	Set Suite Variable    ${rootlb}
	Set Suite Variable    ${FileName}
	Set Suite Variable    ${flavor_name}
	Set Suite Variable    ${cluster_name}	

Teardown
	Run Keyword If Test Passed   Clean Up
	Run Keyword If Test Failed   Failed Data 


Clean Up
	Clear Thread Dict
	${epoch_start_time}=   Get Time  epoch
	Cleanup provisioning
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	${FileData}=     Set Variable       Delete ${testnum} Openstack Docker Dedicated Cluster Time: ${epoch_total_time}\n
	Append To File   ${EXECDIR}/${FileName}     ${FileData}  
	Write Data   

Write Data
	&{thread_list}=   Get Thread Dict
	${count}=  Convert To Integer  1
	: FOR  ${ITEM}   IN   @{thread_list}
	\  ${thread_data}=   Set Variable   Cluster ${count} Start: ${thread_list['${ITEM}'][0]} End: ${thread_list['${ITEM}'][1]} Total: ${thread_list['${ITEM}'][2]}\n 
	\  Append To File    ${EXECDIR}/${FileName}   ${thread_data}  
	\  ${count}=    Evaluate   ${count}+1

Failed Data
	Cleanup provisioning
        ${failedData}=   Set Variable    Test ${testnum} Failed\n
	Append To File    ${EXECDIR}/${FileName}    ${failedData}


WriteHTML
	${result}=   Run Process   python3  ${EXECDIR}/writeTimings.py   ${EXECDIR}/${FileName}
        log    ${result.stdout}
	log    ${result.stderr}
	Should Be Equal As Integers    ${result.rc}    0