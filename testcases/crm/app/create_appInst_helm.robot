*** Settings ***
Documentation  Create helm deployment 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT} 
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhawkinscloudlet.gddt.mobiledgex.net

${helm_image}     https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge
#@{helm_pods}      app1571322359-087174-insightedge-manager-0  app1571322359-087174-insightedge-pu-0  app1571322359-087174-insightedge-zeppelin-0 
#${appname}            app1571771217-3711832 
${test_timeout_crm}  15 min
	
*** Test Cases ***
User shall be able to create an app instance on openstack with deployment=helm 
    [Documentation]
    ...  create an app instance on openstack with deployment=helm 
    ...  verify the app is created

    EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly
    #Sleep  60secs

    Log To Console  Creating App and App Instance
    Create App  region=US  image_path=${helm_image}  access_ports=udp:2015  deployment=helm  image_type=ImageTypeUnknown  annotations=version=14.5.0
    ${appinst}=  Create App Instance  region=US  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Waiting for k8s pod to be running
    ${helm_pod1}=  Catenate  SEPARATOR=-  ${appinst['data']['key']['app_key']['name']}  insightedge-manager-0
    ${helm_pod2}=  Catenate  SEPARATOR=-  ${appinst['data']['key']['app_key']['name']}  insightedge-pu-0
    ${helm_pod3}=  Catenate  SEPARATOR=-  ${appinst['data']['key']['app_key']['name']}  insightedge-zeppelin-0
    @{helm_pods}=  Create List  ${helm_pod1}  ${helm_pod2}  ${helm_pod3}
    # check that pods are running
    : FOR  ${pod}  IN  @{helm_pods}
    \  Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  pod_name=${pod}
    #\  Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=cluster1571771217-3711832  operator_name=${operator_name_openstack}  pod_name=${pod}

    #Wait for helm app to be deployed  root_loadbalancer=${rootlb}  cluster_name=cluster1571771217-3711832  operator_name=${operator_name_openstack}  app_name=${app_name}  chart_name=insightedge-14.5
    Wait for helm app to be deployed  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  app_name=${appinst['data']['key']['app_key']['name']}  chart_name=insightedge-14.5


User shall be able to create an app instance on openstack with deployment=helm and a dot in the app name
    [Documentation]
    ...  create an app instance on openstack with deployment=helm and a dot in the app name. Such as 'my.app'
    ...  verify the app is create with the dot removed. Such as 'myapp'

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=.  app  ${epoch_time}

    #${cluster_name_default}=  Get Default Cluster Name

    EDGECLOUD-1439 unable to create a helm appinst with a dot in the app name 
    Sleep  30secs

    Log To Console  Creating App and App Instance
    Create App  region=US  image_path=${helm_image}  access_ports=udp:2015  deployment=helm  image_type=ImageTypeUnknown 
    Create App Instance  region=US  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Waiting for k8s pod to be running
    ${helm_pod1}=  Catenate  SEPARATOR=-  ${appname}  insightedge-manager-0 
    ${helm_pod2}=  Catenate  SEPARATOR=-  ${appname}  insightedge-pu-0
    ${helm_pod3}=  Catenate  SEPARATOR=-  ${appname}  insightedge-zeppelin-0
    @{helm_pods}=  Create List  ${helm_pod1}  ${helm_pod2}  ${helm_pod3}
    # check that pods are running
    : FOR  ${pod}  IN  @{helm_pods}
    \  Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['cluster_key']['name']}}  operator_name=${operator_name_openstack}  pod_name=app_name
#    \  Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=cluster1571322359-087174  operator_name=${operator_name_openstack}  pod_name=${pod}

*** Keywords ***
Setup
    #Create Developer
    Create Flavor  region=US
    Log To Console  Creating Cluster Instance
    ${cluster}=  Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name_openstack_shared}  operator_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared 
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}
    Set Suite Variable  ${cluster}
