*** Settings ***
Documentation  App Configs Shared

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_SHARED_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationbuckhorncloudlet.gddt.mobiledgex.net

${helm_image}     https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge
#${helm_image}      stable/aerospike
${helm_nfs_image}  stable/nfs-client-provisioner

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_volumemount.yml
${manifest_pod_name}=  server-ping-threaded-udptcphttp

${configs_envvars_url}=  http://35.199.188.102/apps/automation_configs_envvars.yml
	
${test_timeout_crm}  15 min

${region}=  EU
	
*** Test Cases ***
# ECQ-2264
CreateApp - User shall be able to create k8s IpAccessShared with envVarsYaml Configs parm 
    [Documentation]
    ...  deploy IpAccessShared k8s app with envVarsYaml Configs parm
    ...  verify vars are exported in the container 

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name
   
    ${rootlb}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}
 
    ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessShared  number_masters=1  number_nodes=1  #flavor_name=${cluster_flavor_name}
        Log To Console  Done Creating Cluster Instance
    END

    Create App           region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  configs_kind=envVarsYaml  configs_config=${config}  #default_flavor_name=flavor1583873482-5017228
    ${app_name_default}=  Get Default App Name
    log to console  ${app_name_default} 
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    ${export1}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue
    ${export2}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue2

    ${openstack_master_name}=    Catenate  SEPARATOR=-  master  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_master_name}
    ${server_split}=  Split String  ${server_info_node[0]['Networks']}  =   
    log to console  ${server_info_node} ${server_split[1]}

    Should Be Equal  ${export1[0].strip()}  ${server_split[1]} 
    Should Be Equal  ${export2[0].strip()}  ${server_split[1]} 

# ECQ-2265
CreateApp - User shall be able to create k8s IpAccessShared with envVarsYaml Configs URL parm
    [Documentation]
    ...  deploy IpAccessShared k8s app with envVarsYaml Configs URL parm
    ...  verify vars are exported in the container

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${rootlb}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessShared  number_masters=1  number_nodes=1  #flavor_name=${cluster_flavor_name}
        Log To Console  Done Creating Cluster Instance
    END

    Create App           region=${region}  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  configs_kind=envVarsYaml  configs_config=${configs_envvars_url}  #default_flavor_name=flavor1583873482-5017228
    ${app_name_default}=  Get Default App Name
    log to console  ${app_name_default}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    ${export1}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue
    ${export2}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue2

    ${openstack_master_name}=    Catenate  SEPARATOR=-  master  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_master_name}
    ${server_split}=  Split String  ${server_info_node[0]['Networks']}  =
    log to console  ${server_info_node} ${server_split[1]}

    Should Be Equal  ${export1[0].strip()}  ${server_split[1]}
    Should Be Equal  ${export2[0].strip()}  ${server_split[1]}

CreateApp - User shall be able to create helm IpAccessShared with envVarsYaml Configs parm
    [Documentation]
    ...  deploy IpAccessShared k8s app with envVarsYaml Configs parm
    ...  verify vars are exported in the container

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=helm  ip_access=IpAccessShared  number_masters=1  number_nodes=1  #flavor_name=${cluster_flavor_name}
    Log To Console  Done Creating Cluster Instance

    Sleep  60  # needed because of another bug. need to wait for prometheus to start

    Create App           region=${region}  image_path=${helm_image}  access_ports=tcp:2016,udp:2015,http:8085  deployment=helm  image_type=ImageTypeHelm  configs_kind=envVarsYaml  configs_config=${config}  #default_flavor_name=flavor1583873482-5017228
    ${app_name_default}=  Get Default App Name
    log to console  ${app_name_default}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    ${export1}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue
    ${export2}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue2

    ${openstack_master_name}=    Catenate  SEPARATOR=-  master  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_master_name}
    ${server_split}=  Split String  ${server_info_node[0]['Networks']}  =
    log to console  ${server_info_node} ${server_split[1]}

    Should Be Equal  ${export1[0].strip()}  ${server_split[1]}
    Should Be Equal  ${export2[0].strip()}  ${server_split[1]}

CreateApp - User shall be able to create helm IpAccessShared with Configs parm
    [Documentation]
    ...  deploy app with 1 UDP and 1 TCP and 1 HTTP ports with manifest volume mounts
    ...  verify mounts
    ...  verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    #${config}=  Set Variable  - nfs:${\n}${SPACE*2}path: /share${\n}${SPACE*2}server: [[ .Deployment.ClusterIp ]]${\n}- storageClass:${\n}${SPACE*2}name: standard${\n}${SPACE*2}defaultClass: true
    ${config}=  Set Variable  nfs:${\n}${SPACE*2}path: /share${\n}${SPACE*2}server: [[ .Deployment.ClusterIp ]]${\n}storageClass:${\n}${SPACE*2}name: standard${\n}${SPACE*2}defaultClass: true

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=helm  ip_access=IpAccessShared  number_masters=1  number_nodes=1  #flavor_name=${cluster_flavor_name}
    Log To Console  Done Creating Cluster Instance

    sleep  70

    Create App           region=${region}  access_ports=tcp:2016,udp:2015,tcp:8085  deployment=helm  image_type=ImageTypeHelm  image_path=${helm_nfs_image}  configs_kind=helmCustomizationYaml  configs_config=${config}
    ${app_name_default}=  Get Default App Name
    log to console  ${app_name_default}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    ${export1}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue
    ${export2}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue2

    ${openstack_master_name}=    Catenate  SEPARATOR=-  master  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_master_name}
    ${server_split}=  Split String  ${server_info_node[0]['Networks']}  =
    log to console  ${server_info_node} ${server_split[1]}

    Should Be Equal  ${export1[0].strip()}  ${server_split[1]}
    Should Be Equal  ${export2[0].strip()}  ${server_split[1]}

# EDGECLOUD-3163 Support envVarsYaml config for CreateApp on docker
CreateApp - User shall be able to create docker IpAccessShared with Configs parm
    [Documentation]
    ...  deploy app with 1 UDP and 1 TCP and 1 HTTP ports with manifest volume mounts
    ...  verify mounts
    ...  verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

#    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
#    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${config}=  Set Variable  - name: CrmValue${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]${\n}- name: CrmValue2${\n}${SPACE*2}value: [[ .Deployment.ClusterIp ]]

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=docker  ip_access=IpAccessShared 
    Log To Console  Done Creating Cluster Instance

    Create App           region=${region}  deployment=docker  image_path=${docker_image}  access_ports=tcp:2016,udp:2015,tcp:8085  configs_kind=envVarsYaml  configs_config=${config}  #default_flavor_name=flavor1583873482-5017228
    ${app_name_default}=  Get Default App Name
    log to console  ${app_name_default}
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    ${export1}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue
    ${export2}=  Run Command On Pod  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}  pod_name=${app_name_default}  command=echo \\\$CrmValue2

    ${openstack_master_name}=    Catenate  SEPARATOR=-  master  ${cloudlet_lowercase}  ${cluster_name_default}
    ${server_info_node}=    Get Server List  name=${openstack_master_name}
    ${server_split}=  Split String  ${server_info_node[0]['Networks']}  =
    log to console  ${server_info_node} ${server_split[1]}

    Should Be Equal  ${export1[0].strip()}  ${server_split[1]}
    Should Be Equal  ${export2[0].strip()}  ${server_split[1]}

*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    Set Suite Variable  ${platform_type}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_crm}

    Set Suite Variable  ${cloudlet_lowercase}

    Set Suite Variable  ${rootlb}
