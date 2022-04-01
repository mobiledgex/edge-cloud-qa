*** Settings ***
Documentation  Create helm deployment 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium

${cloudlet_name_openstack_dedicated}  automationBuckhornCloudlet
${region}  EU
${operator_name_openstack}  GDDT

${mobiledgex_domain}  mobiledgex-qa.net


${helm_image}     https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge
${test_timeout_crm}  15 min
	
*** Test Cases ***
IpAccessDedicated helm - Heathcheck shows HealthCheckOk after creation of App Instance 
    [Documentation]
    ...  create an app instance on openstack with deployment=helm and IpAccessDedicated
    ...  verify that healthcheck shows HealthCheckOk

    ${app_name_default}=  Get Default App Name
    Log To Console  Creating Cluster Instance
    ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cluster_key']['name']}  ${rootlb}

    #EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly
    Sleep  60secs

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${helm_image}  access_ports=udp:2015  deployment=helm  image_type=ImageTypeHelm  annotations=version=14.5.0
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  

    Log To Console  Waiting for k8s pod to be running
    ${helm_pod1}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-manager-0
    ${helm_pod2}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-pu-0
    ${helm_pod3}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-zeppelin-0
    @{helm_pods}=  Create List  ${helm_pod1}  ${helm_pod2}  ${helm_pod3}
    # check that pods are running
    FOR  ${pod}  IN  @{helm_pods}
        Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  pod_name=${pod}
    END
    Wait for helm app to be deployed  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  app_name=${appinst['data']['key']['app_key']['name']}  chart_name=insightedge-14.5

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

*** Keywords ***
Setup
    Create Flavor  region=${region}



