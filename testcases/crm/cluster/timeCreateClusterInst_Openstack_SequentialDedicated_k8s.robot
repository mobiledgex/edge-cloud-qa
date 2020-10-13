*** Settings ***
Documentation  Cluster size for openstack with IpAccessDed and Kubernetes

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
#${cloudlet_name_openstack}   automationHawkinsCloudlet
#${cloudlet_name_openstack}   automationBuckhornCloudlet
${cloudlet_name_openstack}   automationBeaconCloudlet
#${cloudlet_name_openstack}   automationGcpCentralCloudlet
#${cloudlet_name_openstack}   automationAzureCentralCloudlet
#${cloudlet_name_openstack}   automationSunnydaleCloudletStage
#${cloudlet_name_openstack}   automationFairviewCloudlet
#${cloudlet_name_openstack}   tmocloud-1
#${operator_name_openstack}   gcp 
#${operator_name_openstack}   azure 
${operator_name_openstack}   GDDT 
#${operator_name_openstack}   dmuus
${mobiledgex_domain}    mobiledgex.net
${developer_name_openstack}     MobiledgeX

${test_timeout_crm}   32 min
	
*** Test Cases ***
# ECQ-	
ClusterInst shall create 5 clusters in sequence with IpAccessDedicated/kubernetes on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and deployment type=kubernetes
   ...  collect the time it takes to create the cluster and write it to a file

        ${testtime}=   Get Time  epoch
	${testtime}=   Convert To String    ${testtime}
	${testtime}=   Catenate  SEPARATOR=   ${testtime}  \n
	Create File   ${EXECDIR}/${FileName}
	Append To File   ${EXECDIR}/${FileName}    ${testtime}  
	Clear Thread Dict
	
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   0
	 
	FOR  ${INDEX}  IN RANGE  1  6
   	   ${y}=   Convert To String   ${INDEX}
	   ${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   ${y}
	   Append To List    ${clusterList}     ${cluster_name}
	   ${epoch_start_time}=   Get Time  epoch
	   Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_org_name=${operator_name_openstack}     flavor_name=${flavor_name}   number_nodes=0  number_masters=0   ip_access=IpAccessDedicated    deployment=kubernetes     	
	   ${epoch_end_time}=     Get Time  epoch
	   ${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	   ${FileData}=     Set Variable   Create Sequential Cluster ${y} Openstack Kubernetes Dedicated Cluster Time: ${epoch_total_time}\n
	   Append To File   ${EXECDIR}/${FileName}     ${FileData}
 	   ${z}=   Get Length     ${cluster_name}
	   ${z}=   Evaluate   ${z}-1
	   ${cluster_name}=   Get Substring   ${cluster_name}   0   ${z}
	END

*** Keywords ***
Setup

	${testdate}=    Get Time  epoch
	${testdate}=    Convert Date    ${testdate}       result_format=%d-%m-%Y
	${testdate}=     Catenate  SEPARATOR=      -      ${testdate}
	${flavor_name}=     Set Variable   automation_api_flavor
	${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack}
	${FileName}=    Catenate  SEPARATOR=    ${cloudlet_name_openstack}   OpenstackSequentioalTimingsK8sDedicated
	${FileName}=    Catenate  SEPARATOR=    ${FileName}     ${testdate}
	${FileName}=    Catenate  SEPARATOR=    ${FileName}     .timings

	${x}=  Evaluate    random.randint(10, 20000)   random
	${x}=  Convert To String  ${x}
	${cluster_name}=  Catenate  SEPARATOR=  timecl  ${x}
        ${failedData}=   Set Variable    Test Failed
	@{clusterList}=   Create List
	${a}=   Set Variable   1

	Set Suite Variable  ${cloudlet_lowercase}
	Set Suite Variable  ${failedData}

	${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
	${rootlb}=  Convert To Lowercase  ${rootlb}

	Set Suite Variable    ${rootlb}
	Set Suite Variable    ${FileName}
	Set Suite Variable    ${flavor_name}
	Set Suite Variable    ${cluster_name}	
	Set Suite Variable    @{clusterList}	
	Set Suite Variable    ${a}
	
Teardown
	Run Keyword If Test Passed   Clean Up
	Run Keyword If Test Failed   Failed Data 

Clean Up
	${a}=   Set Variable    1
	FOR  ${ITEM}   IN   @{clusterList}
	   ${b}=   Convert To String    ${a}
	   ${epoch_start_time}=   Get Time  epoch
	   Delete Cluster Instance    cluster_name=${ITEM}   cloudlet_name=${cloudlet_name_openstack}   operator_org_name=${operator_name_openstack}   developer_org_name=${developer_name_openstack}  
	   ${epoch_end_time}=     Get Time  epoch
	   ${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	   ${FileData}=     Set Variable       Delete Sequential Cluster ${b} Openstack Kubernetes Dedicated Cluster Time: ${epoch_total_time}\n
	   Append To File   ${EXECDIR}/${FileName}     ${FileData}
	   ${a}=   Evaluate   ${a}+1
        END

Failed Data
	${a}=   Set Variable   1
	FOR  ${ITEM}   IN   @{clusterList}
	   ${b}=   Convert To String    ${a}
           Run Keyword And Ignore Error   Delete Cluster Instance    cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_org_name=${operator_name_openstack}   
           ${failedData}=   Set Variable    Sequential Cluster ${b} Failed\n
           Append To File    ${EXECDIR}/${FileName}    ${failedData}
	   ${a}=   Evaluate   ${a}+1
	END

WriteHTML
	${result}=   Run Process   python3  ${EXECDIR}/writeSequentialTimings.py   ${EXECDIR}/${FileName}
        log    ${result.stdout}
	log    ${result.stderr}
	Should Be Equal As Integers    ${result.rc}    0
