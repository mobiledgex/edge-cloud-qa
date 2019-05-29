*** Settings ***
Documentation   CreateClusterInst - ipaccess

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup	Setup
Test Teardown	Cleanup provisioning

*** Variables ***
${operator_name}  tmus
${operator_name_gcp}  gcp
${operator_name_azure}  azure
${cloudlet_name}  tmocloud-1
${cloudlet_name_azure}  azurecloud-1
${cloudlet_name_gcp}  gcpcloud-1
${mobile_latitude}  1
${mobile_longitude}  1

*** Test Cases ***
CreateClusterInst - creating cluster inst with ipaccess=IpAccessUnknown shall set to IpAccessShared
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessUnknown
    ...  verify it is set to IpAccessShared

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessUnknown

    Should Be Equal As Numbers  ${clusterInst.ip_access}  3  #IpAccessShared

CreateClusterInst - shall be to create a clusterInst with ipaccess=IpAccessShared
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessShared
    ...  verify it is set to IpAccessShared

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  3  #IpAccessShared

CreateClusterInst - shall be to create a clusterInst with ipaccess=IpAccessDedicated
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated
    ...  verify it is set to IpAccessDedicated

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a clusterInst with ipaccess=IpAccessDedicatedOrShared
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicatedOrShared
    ...  verify it is set to IpAccessShared

    # allocateIP sets DedicatedOrShared to Shared
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicatedOrShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  3  #IpAccessShared

CreateClusterInst - shall be to create a azure clusterInst with ipaccess=IpAccessDedicatedOrShared
    [Documentation]
    ...  create a azure cluster instance with ipaccess=IpAccessDedicatedOrShared
    ...  verify it is set to IpAccessDedicated

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  ip_access=IpAccessDedicatedOrShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a azure clusterInst with ipaccess=IpAccessDedicated
    [Documentation]
    ...  create a azure cluster instance with ipaccess=IpAccessDedicated
    ...  verify it is set to IpAccessDedicated

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  ip_access=IpAccessDedicated

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a azure clusterInst with ipaccess=IpAccessShared
    [Documentation]
    ...  create a azure cluster instance with ipaccess=IpAccessShared
    ...  verify it is set to IpAccessDedicated

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  ip_access=IpAccessShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a azure clusterInst with ipaccess=IpAccessUnknown
    [Documentation]
    ...  create a azure cluster instance with ipaccess=IpAccessUnknown
    ...  verify it is set to IpAccessDedicated

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  ip_access=IpAccessUnknown

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a gcp clusterInst with ipaccess=IpAccessDedicatedOrShared
    [Documentation]
    ...  create a gcp cluster instance with ipaccess=IpAccessDedicatedOrShared
    ...  verify it is set to IpAccessDedicated

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  ip_access=IpAccessDedicatedOrShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a gcp clusterInst with ipaccess=IpAccessDedicated
    [Documentation]
    ...  create a gcp cluster instance with ipaccess=IpAccessDedicated
    ...  verify it is set to IpAccessDedicated

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  ip_access=IpAccessDedicated

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a gcp clusterInst with ipaccess=IpAccessShared
    [Documentation]
    ...  create a gcp cluster instance with ipaccess=IpAccessShared
    ...  verify it is set to IpAccessDedicated

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  ip_access=IpAccessShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a gcp clusterInst with ipaccess=IpAccessUnknown
    [Documentation]
    ...  create a gcp cluster instance with ipaccess=IpAccessUnknown
    ...  verify it is set to IpAccessDedicated

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  ip_access=IpAccessUnknown

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

*** Keywords ***
Setup
    Create Developer            
    Create Flavor
    Create Cluster
    Create Cloudlet  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name_azure}  latitude=1  longitude=1
    Create Cloudlet  cloudlet_name=${cloudlet_name_gcp}  operator_name=${operator_name_gcp}  latitude=1  longitude=1
	

