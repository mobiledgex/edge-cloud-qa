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

${cloudlet_name_openstack_shared}  automationBonnCloudlet
${cloudlet_name_openstack_dedicated}  automationBonnCloudlet
${region}  EU
${operator_name_openstack}  TDG

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${helm_image}     https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge
#@{helm_pods}      app1571322359-087174-insightedge-manager-0  app1571322359-087174-insightedge-pu-0  app1571322359-087174-insightedge-zeppelin-0 
#${appname}            app1571771217-3711832 
${test_timeout_crm}  15 min
	
*** Test Cases ***
User shall be able to create an app instance on openstack with deployment=helm and IpAccessShared
    [Documentation]
    ...  create an app instance on openstack with deployment=helm and IpAccessShared
    ...  verify the app is created

    Log To Console  Creating Cluster Instance
    ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared
    Log To Console  Done Creating Cluster Instance

    EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly
    Sleep  60secs

    Log To Console  Creating App and App Instance
    Create App  region=${region}  image_path=${helm_image}  access_ports=udp:2015  deployment=helm  image_type=ImageTypeHelm  annotations=version=14.5.0
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Waiting for k8s pod to be running
    ${helm_pod1}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-manager-0
    ${helm_pod2}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-pu-0
    ${helm_pod3}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-zeppelin-0
    @{helm_pods}=  Create List  ${helm_pod1}  ${helm_pod2}  ${helm_pod3}
    # check that pods are running
    : FOR  ${pod}  IN  @{helm_pods}
    \  Wait for k8s pod to be running  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  pod_name=${pod}

    Wait for helm app to be deployed  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  app_name=${appinst['data']['key']['app_key']['name']}  chart_name=insightedge-14.5

User shall be able to create an app instance on openstack with deployment=helm and IpAccessDedicated
    [Documentation]
    ...  create an app instance on openstack with deployment=helm and IpAccessDedicated
    ...  verify the app is created

    EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly
    
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
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Waiting for k8s pod to be running
    ${helm_pod1}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-manager-0
    ${helm_pod2}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-pu-0
    ${helm_pod3}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-zeppelin-0
    @{helm_pods}=  Create List  ${helm_pod1}  ${helm_pod2}  ${helm_pod3}
    # check that pods are running
    : FOR  ${pod}  IN  @{helm_pods}
    \  Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  pod_name=${pod}

    Wait for helm app to be deployed  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  app_name=${appinst['data']['key']['app_key']['name']}  chart_name=insightedge-14.5

User shall be able to create an app instance on openstack with deployment=helm and a dot in the app name and IpAccessShared
    [Documentation]
    ...  create an app instance on openstack with deployment=helm and a dot in the app name. Such as 'my.app'
    ...  verify the app is create with the dot removed. Such as 'myapp'

    EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly

    Log To Console  Creating Cluster Instance
    ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared
    Log To Console  Done Creating Cluster Instance

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=.  app  ${epoch_time}

    #${cluster_name_default}=  Get Default Cluster Name

    #EDGECLOUD-1439 unable to create a helm appinst with a dot in the app name 
    Sleep  60secs

    Log To Console  Creating App and App Instance
    Create App  region=${region}  app_name=${app_name}  image_path=${helm_image}  access_ports=udp:2015  deployment=helm  image_type=ImageTypeHelm 
    ${appinst}=  Create App Instance  region=${region}  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Waiting for k8s pod to be running
    ${helm_pod1}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-manager-0 
    ${helm_pod2}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-pu-0
    ${helm_pod3}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-zeppelin-0
    @{helm_pods}=  Create List  ${helm_pod1}  ${helm_pod2}  ${helm_pod3}
    # check that pods are running
    : FOR  ${pod}  IN  @{helm_pods}
    \  Wait for k8s pod to be running  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  pod_name=${pod}

    Wait for helm app to be deployed  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  app_name=${appinst['data']['key']['app_key']['name']}  chart_name=insightedge-14.5

*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${rootlb_shared}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb_shared}=  Convert To Lowercase  ${rootlb_shared}

    ${rootlb_dedicated}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}

    Set Suite Variable  ${rootlb_shared}

