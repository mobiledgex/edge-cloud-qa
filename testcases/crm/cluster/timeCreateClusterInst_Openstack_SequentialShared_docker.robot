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
#${cloudlet_name_openstack}   automationDusseldorfCloudlet
#${cloudlet_name_openstack}   automationHamburgCloudlet
#${cloudlet_name_openstack}   automationBonnCloudlet
${cloudlet_name_openstack}   automationBerlinCloudlet
#${cloudlet_name_openstack}   automationGcpCentralCloudlet
#${cloudlet_name_openstack}   automationAzureCentralCloudlet
#${cloudlet_name_openstack}   automationMunichCloudletStage
#${cloudlet_name_openstack}   automationFrankfurtCloudlet
#${cloudlet_name_openstack}   tmocloud-1
#${operator_name_openstack}   gcp 
#${operator_name_openstack}   azure 
${operator_name_openstack}   TDG 
#${operator_name_openstack}   tmus
${mobiledgex_domain}    mobiledgex.net
${developer_name_openstack}     MobiledgeX

${test_timeout_crm}  32 min
	
*** Test Cases ***
# ECQ-2763
Create 5 sequential IpAccessShared Docker clusters on openstack
   [Documentation]
   ...  create 5 sequential clusters on openstack with IpAccessShared and deploymenttype=docker
   ...  collect the time it takes to create each of the 5 clusters and write it to a file

        ${testtime}=   Get Time  epoch
	${testtime}=   Convert To String    ${testtime}
	${testtime}=   Catenate  SEPARATOR=   ${testtime}  \n
	Create File   ${EXECDIR}/${FileName}
	Append To File   ${EXECDIR}/${FileName}    ${testtime}
	  
	${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
	${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   0
	
	FOR  ${INDEX}    IN RANGE    1    6
	${y}=   Convert To String   ${INDEX}
	${cluster_name}=  Catenate  SEPARATOR=   ${cluster_name}   ${y}
	Append To List    ${clusterList}     ${cluster_name}
	${epoch_start_time}=   Get Time  epoch
	Create Cluster Instance   cluster_name=${cluster_name}   cloudlet_name=${cloudlet_name_openstack}   operator_org_name=${operator_name_openstack}      flavor_name=${flavor_name}   number_nodes=0  number_masters=0   ip_access=IpAccessShared    deployment=docker     
	${epoch_end_time}=     Get Time  epoch
	${epoch_total_time}=   Evaluate    ${epoch_end_time}-${epoch_start_time} 
	${FileData}=     Set Variable       Create Sequential Cluster ${y} Openstack Docker Shared Cluster Time: ${epoch_total_time}\n
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
	${FileName}=    Catenate  SEPARATOR=    ${cloudlet_name_openstack}   OpenstackSequentioalTimingsDockerShared 
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
	   ${FileData}=     Set Variable       Delete Sequential Cluster ${b} Openstack Docker Shared Cluster Time: ${epoch_total_time}\n
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
