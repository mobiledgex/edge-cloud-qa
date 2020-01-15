*** Settings ***
Documentation   CreateClusterInst - ipaccess

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

#Test Setup	Setup
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

    Create Flavor

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessUnknown

    Should Be Equal As Numbers  ${clusterInst.ip_access}  3  #IpAccessShared

CreateClusterInst - shall be to create a clusterInst with ipaccess=IpAccessShared
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessShared
    ...  verify it is set to IpAccessShared

    Create Flavor

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  3  #IpAccessShared

CreateClusterInst - shall be to create a clusterInst with ipaccess=IpAccessDedicated
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicated
    ...  verify it is set to IpAccessDedicated

    Create Flavor

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicated

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a clusterInst with ipaccess=IpAccessDedicatedOrShared
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicatedOrShared
    ...  verify it is set to IpAccessShared

    Create Flavor

    # allocateIP sets DedicatedOrShared to Shared
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicatedOrShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  3  #IpAccessShared

CreateClusterInst - shall be to create a azure clusterInst with ipaccess=IpAccessDedicatedOrShared
    [Documentation]
    ...  create a azure cluster instance with ipaccess=IpAccessDedicatedOrShared
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  ip_access=IpAccessDedicatedOrShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a azure clusterInst with ipaccess=IpAccessDedicated
    [Documentation]
    ...  create a azure cluster instance with ipaccess=IpAccessDedicated
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  ip_access=IpAccessDedicated

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a azure clusterInst with ipaccess=IpAccessShared
    [Documentation]
    ...  create a azure cluster instance with ipaccess=IpAccessShared
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  ip_access=IpAccessShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a azure clusterInst with ipaccess=IpAccessUnknown
    [Documentation]
    ...  create a azure cluster instance with ipaccess=IpAccessUnknown
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_azure}  cloudlet_name=${cloudlet_name_azure}  ip_access=IpAccessUnknown

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a gcp clusterInst with ipaccess=IpAccessDedicatedOrShared
    [Documentation]
    ...  create a gcp cluster instance with ipaccess=IpAccessDedicatedOrShared
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  ip_access=IpAccessDedicatedOrShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a gcp clusterInst with ipaccess=IpAccessDedicated
    [Documentation]
    ...  create a gcp cluster instance with ipaccess=IpAccessDedicated
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  ip_access=IpAccessDedicated

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a gcp clusterInst with ipaccess=IpAccessShared
    [Documentation]
    ...  create a gcp cluster instance with ipaccess=IpAccessShared
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  ip_access=IpAccessShared

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a gcp clusterInst with ipaccess=IpAccessUnknown
    [Documentation]
    ...  create a gcp cluster instance with ipaccess=IpAccessUnknown
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    # allocateIP sets azure/gcp to Dedicated
    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name_gcp}  cloudlet_name=${cloudlet_name_gcp}  ip_access=IpAccessUnknown

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

CreateClusterInst - shall be to create a clusterInst with ipaccess=IpAccessUnknown and deployment=docker
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessUnknown and deployment=docker
    ...  verify it is set to IpAccessDedicated

    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessUnknown  deployment=docker  number_masters=0  number_nodes=0

    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated
    Should Be Equal             ${clusterInst.deployment}  docker

CreateClusterInst - shall not be to create a clusterInst with ipaccess=IpAccessShared and deployment=docker
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessShared and deployment=docker
    ...  verify  error is received

    ${error_msg}=  Run Keyword and Expect Error  *  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessShared  deployment=docker  number_masters=0  number_nodes=0

   Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
   Should Contain  ${error_msg}   IpAccess must be dedicated for deployment type docker

CreateClusterInst - shall be to create a clusterInst with ipaccess=IpAccessDedicatedOrShared and deployment=docker
    [Documentation]
    ...  create a cluster instance with ipaccess=IpAccessDedicatedOrShared and deployment=docker
    ...  verify ipaccess is set to IpAccessDedicated
 
    [Setup]  Setup
    [Teardown]  Cleanup Provisioning

    ${clusterInst}=  Create Cluster Instance  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=IpAccessDedicatedOrShared  deployment=docker  number_masters=0  number_nodes=0

    # should be set to Dedicated
    Should Be Equal As Numbers  ${clusterInst.ip_access}  1  #IpAccessDedicated

*** Keywords ***
Setup
    ${epoch}=  Get Time  epoch
    ${cloudlet_name_azure}=  Catenate  SEPARATOR=  ${cloudlet_name_azure}  ${epoch}
    ${cloudlet_name_gcp}=  Catenate  SEPARATOR=  ${cloudlet_name_gcp}  ${epoch}

    Create Developer            
    Create Flavor
    #Create Cluster
    Create Cloudlet  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name_azure}  latitude=1  longitude=1
    Create Cloudlet  cloudlet_name=${cloudlet_name_gcp}  operator_name=${operator_name_gcp}  latitude=1  longitude=1
	
    Set Suite Variable  ${cloudlet_name_azure}
    Set Suite Variable  ${cloudlet_name_gcp}
