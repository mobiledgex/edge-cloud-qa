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

#${helm_image}     https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge
${helm_image}      https://ealenn.github.io/charts:ealenn/echo-server
${helm_config}  service:${\n}${Space}${Space}type: "LoadBalancer"${\n}${Space}${Space}port: 2015
#@{helm_pods}      app1571322359-087174-insightedge-manager-0  app1571322359-087174-insightedge-pu-0  app1571322359-087174-insightedge-zeppelin-0 
#${appname}            app1571771217-3711832 
${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-1583
User shall be able to create an app instance on CRM with deployment=helm and IpAccessShared
    [Documentation]
    ...  - create an app instance on CRM with deployment=helm and IpAccessShared
    ...  - verify the app is created

    Create App  region=${region}  image_path=${helm_image}  access_ports=tcp:2015  deployment=helm  image_type=ImageTypeHelm  annotations=version=0.3.1  configs_kind=helmCustomizationYaml  configs_config=${helm_config} 

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessShared 
        Log To Console  Done Creating Cluster Instance
    END

#    EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly
#    Sleep  60secs

    Log To Console  Creating App and App Instance
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Waiting for k8s pod to be running
    #${helm_pod1}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-manager-0
    #${helm_pod2}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-pu-0
    #${helm_pod3}=  Catenate  SEPARATOR=  ${appinst['data']['key']['app_key']['name']}  v10  -  insightedge-zeppelin-0
    #@{helm_pods}=  Create List  ${helm_pod1}  ${helm_pod2}  ${helm_pod3}
    # check that pods are running
    #FOR  ${pod}  IN  @{helm_pods}
    #   Wait for k8s pod to be running  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_crm}  pod_name=${pod}
    #END
    Wait for k8s pod to be running  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_crm}  pod_name=${app_name_default}v10-echo-server

    Wait for helm app to be deployed  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_crm}  app_name=${appinst['data']['key']['app_key']['name']}  chart_name=echo-server-0.3.1

# ECQ-1609
User shall be able to create an app instance on CRM with deployment=helm and IpAccessDedicated
    [Documentation]
    ...  - create an app instance on CRM with deployment=helm and IpAccessDedicated
    ...  - verify the app is created

    #EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly
   
    Create App  region=${region}  image_path=${helm_image}  access_ports=tcp:2015  deployment=helm  image_type=ImageTypeHelm  annotations=version=0.3.1  configs_kind=helmCustomizationYaml  configs_config=${helm_config}

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated 
        Log To Console  Done Creating Cluster Instance
    END

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster['data']['key']['cluster_key']['name']}  ${rootlb}

    #EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly
    #Sleep  60secs

    Log To Console  Creating App and App Instance
    ${appinst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_crm}  pod_name=${app_name_default}v10-echo-server

    Wait for helm app to be deployed  root_loadbalancer=${rootlb}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_openstack}  app_name=${appinst['data']['key']['app_key']['name']}  chart_name=echo-server-0.3.1

# ECQ-1584
User shall be able to create an app instance on CRM with deployment=helm and a dot in the app name and IpAccessShared
    [Documentation]
    ...  - create an app instance on CRM with deployment=helm and a dot in the app name. Such as 'my.app'
    ...  - verify the app is create with the dot removed. Such as 'myapp'

    #EDGECLOUD-1444 helm app not created when CreateClusterInst and CreateAppInst is done quickly

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=.  app  ${epoch_time}
    Create App  region=${region}  app_name=${app_name}  image_path=${helm_image}  access_ports=tcp:2015  deployment=helm  image_type=ImageTypeHelm  annotations=version=0.3.1  configs_kind=helmCustomizationYaml  configs_config=${helm_config}

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessShared 
        Log To Console  Done Creating Cluster Instance
    END

    #EDGECLOUD-1439 unable to create a helm appinst with a dot in the app name 
    #Sleep  60secs

    Log To Console  Creating App and App Instance
    ${appinst}=  Create App Instance  region=${region}  app_name=${app_name}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  #cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_crm}  pod_name=${appinst['data']['key']['app_key']['name']}v10-echo-server

    Wait for helm app to be deployed  root_loadbalancer=${rootlb_shared}  cluster_name=${cluster['data']['key']['cluster_key']['name']}  operator_name=${operator_name_crm}  app_name=${appinst['data']['key']['app_key']['name']}  chart_name=echo-server-0.3.1

*** Keywords ***
Setup
    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    Set Suite Variable  ${platform_type}

    Create Flavor  region=${region}

    ${app_name_default}=  Get Default App Name

    ${rootlb_shared}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb_shared}=  Convert To Lowercase  ${rootlb_shared}

    ${rootlb_dedicated}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}

    Set Suite Variable  ${rootlb_shared}
    Set Suite Variable  ${app_name_default}
