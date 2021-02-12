*** Settings ***
Documentation   CreateClusterInst - created_at and updated_at

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Suite Setup	Setup
Suite Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1

${developer_name}=  automation_dev_org
${region}=  US

*** Test Cases ***
# ECQ-2867
CreateClusterInst - timestamps shall be created for Create/Update k8s/helm Instances 
    [Documentation]
    ...  - create/update k8s/helm clusterinstance with various parms
    ...  - verify timestamps

    [Template]  Create/Update Clusterinst and Check Timestamps

    ip_access=IpAccessUnknown
    ip_access=IpAccessShared
    ip_access=IpAccessDedicated
    deployment=kubernetes  number_masters=1  number_nodes=1   ip_access=IpAccessShared
    deployment=kubernetes  number_masters=1  number_nodes=1   ip_access=IpAccessDedicated
    deployment=kubernetes  number_masters=1  number_nodes=1   ip_access=IpAccessShared  reservable=${True}
    deployment=kubernetes  number_masters=1  number_nodes=1   ip_access=IpAccessDedicated  reservable=${True}

    deployment=helm  number_masters=1  number_nodes=1   ip_access=IpAccessShared
    deployment=helm  number_masters=1  number_nodes=1   ip_access=IpAccessDedicated
    deployment=helm  number_masters=1  number_nodes=1   ip_access=IpAccessShared  reservable=${True}
    deployment=helm  number_masters=1  number_nodes=1   ip_access=IpAccessDedicated  reservable=${True}

# ECQ-2875
CreateClusterInst - timestamps shall be created for Create Docker Instances
    [Documentation]
    ...  - create docker clusterinstance with various parms
    ...  - verify timestamps

    [Template]  CreateClusterinst for Docker and Check Timestamps

    deployment=docker   ip_access=IpAccessShared
    deployment=docker   ip_access=IpAccessDedicated
    deployment=docker   ip_access=IpAccessShared  reservable=${True}
    deployment=docker   ip_access=IpAccessDedicated  reservable=${True}

# ECQ-2876
CreateClusterInst - timestamps shall be created for autocluster docker Instances
    [Documentation]
    ...  - create autoucluster docker clusterinstance with various parms
    ...  - verify timestamps

    [Template]  CreateClusterinst for docker autocluster and Check Timestamps

    autocluster_ip_access=IpAccessShared
    autocluster_ip_access=IpAccessDedicated

# ECQ-2877
CreateClusterInst - timestamps shall be created for autocluster k8s Instances
    [Documentation]
    ...  - create autocluster k8s clusterinstance with various parms
    ...  - verify timestamps

    [Template]  CreateClusterinst for k8s autocluster and Check Timestamps

    autocluster_ip_access=IpAccessShared
    autocluster_ip_access=IpAccessDedicated

# ECQ-2878
CreateClusterInst - timestamps shall be created for autocluster helm Instances
    [Documentation]
    ...  - create autocluster helm clusterinstance with various parms
    ...  - verify timestamps

    [Template]  CreateClusterinst for helm autocluster and Check Timestamps

    autocluster_ip_access=IpAccessShared
    autocluster_ip_access=IpAccessDedicated

*** Keywords ***
Setup
    ${token}=  Get Super Token
    ${cluster_name}=  Get Default Cluster Name

    Create Flavor  region=${region}
    ${policy}=  Create Auto Scale Policy  region=${region}   min_nodes=1  max_nodes=2  #use_defaults=${False}
    Set Suite Variable  ${policy}
    Set Suite Variable  ${token}
    Set Suite Variable  ${cluster_name}

Create/Update Clusterinst and Check Timestamps
    [Arguments]  &{parms}

    ${clusterInst}=  Create Cluster Instance  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  &{parms}  auto_delete=${False} 
    Should Be True  ${clusterInst['data']['created_at']['seconds']} > 0
    Should Be True  ${clusterInst['data']['created_at']['nanos']} > 0
    Should Be True  'updated_at' in ${clusterInst['data']} and 'seconds' not in ${clusterInst['data']['updated_at']} and 'nanos' not in ${clusterInst['data']['updated_at']}

    Sleep  1s

    ${updateInst}=  Update Cluster Instance  region=${region}  token=${token}  cluster_name=${cluster_name}  developer_org_name=${developer_name}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  autoscale_policy_name=${policy['data']['key']['name']}  use_defaults=${False}
    Should Be True  ${updateInst['data']['created_at']['seconds']} == ${clusterInst['data']['created_at']['seconds']}
    Should Be True  ${updateInst['data']['created_at']['nanos']} == ${clusterInst['data']['created_at']['nanos']}
    Should Be True  ${updateInst['data']['updated_at']['seconds']} > ${clusterInst['data']['created_at']['seconds']}
    Should Be True  ${updateInst['data']['updated_at']['seconds']} > 0

    Delete Cluster Instance  region=${region}

CreateClusterinst for Docker and Check Timestamps
    [Arguments]  &{parms}

    ${clusterInst}=  Create Cluster Instance  region=${region}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  &{parms}  auto_delete=${False}
    Should Be True  ${clusterInst['data']['created_at']['seconds']} > 0
    Should Be True  ${clusterInst['data']['created_at']['nanos']} > 0
    Should Be True  'updated_at' in ${clusterInst['data']} and 'seconds' not in ${clusterInst['data']['updated_at']} and 'nanos' not in ${clusterInst['data']['updated_at']}

    Delete Cluster Instance  region=${region}

CreateClusterinst for Docker Autocluster and Check Timestamps
    [Arguments]  &{parms} 

    Create App   region=${region}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  auto_delete=${False}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=auto${cluster_name}  &{parms}  auto_delete=${False}  

    ${clusterInst}=  Show Cluster Instances  region=${region}  cluster_name=auto${cluster_name}
    Should Be True  ${clusterInst[0]['data']['created_at']['seconds']} > 0
    Should Be True  ${clusterInst[0]['data']['created_at']['nanos']} > 0
    Should Be True  'updated_at' in ${clusterInst[0]['data']} and 'seconds' not in ${clusterInst[0]['data']['updated_at']} and 'nanos' not in ${clusterInst[0]['data']['updated_at']}

    Delete App Instance  region=${region}
    Delete App  region=${region}

CreateClusterinst for K8s Autocluster and Check Timestamps
    [Arguments]  &{parms} 

    Create App   region=${region}  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}  auto_delete=${False}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=auto${cluster_name}  &{parms}  auto_delete=${False}

    ${clusterInst}=  Show Cluster Instances  region=${region}  cluster_name=auto${cluster_name}
    Should Be True  ${clusterInst[0]['data']['created_at']['seconds']} > 0
    Should Be True  ${clusterInst[0]['data']['created_at']['nanos']} > 0
    Should Be True  'updated_at' in ${clusterInst[0]['data']} and 'seconds' not in ${clusterInst[0]['data']['updated_at']} and 'nanos' not in ${clusterInst[0]['data']['updated_at']}

    Delete App Instance  region=${region}
    Delete App  region=${region}

CreateClusterinst for Helm Autocluster and Check Timestamps
    [Arguments]  &{parms}

    Create App   region=${region}  deployment=helm  image_type=ImageTypeHelm  image_path=${docker_image}  auto_delete=${False}
    ${app_inst}=  Create App Instance  region=${region}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name}  cluster_instance_name=auto${cluster_name}  &{parms}  auto_delete=${False}

    ${clusterInst}=  Show Cluster Instances  region=${region}  cluster_name=auto${cluster_name}
    Should Be True  ${clusterInst[0]['data']['created_at']['seconds']} > 0
    Should Be True  ${clusterInst[0]['data']['created_at']['nanos']} > 0
    Should Be True  'updated_at' in ${clusterInst[0]['data']} and 'seconds' not in ${clusterInst[0]['data']['updated_at']} and 'nanos' not in ${clusterInst[0]['data']['updated_at']}

    Delete App Instance  region=${region}
    Delete App  region=${region}

