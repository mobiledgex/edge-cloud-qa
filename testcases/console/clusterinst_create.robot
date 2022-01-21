*** Settings ***
Documentation   Create new clusterinst
## Passes
## Has trouble with success boxes
Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}
Library         MexMasterController  %{AUTOMATION_MC_ADDRESS}  %{AUTOMATION_MC_CERT}

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${developer_name}  MobiledgeX
${operator_name}  dmuus
${cloudlet_name}  tmocloud-1
${flavor}  x1.medium
${wait}  200

*** Test Cases ***
Web UI - user shall be able to create a new EU clusterinst with Docker Dedicated Ip Access
    [Documentation]
    ...  Create a new EU cluster
    ...  Verify cluster shows in list

    Sleep  5s

    Add New Cluster Instance  region=EU  developer_name=${developer_name}  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=Dedicated  deployment=Docker  flavor_name=${flavor}  wait=300

    Cluster Should Exist  region=EU  ip_access=Dedicated  

    Sleep  60s

    Delete Cluster wait=${wait}

    Cluster Should Not Exist

Web UI - user shall be able to create a new US clusterinst with Docker Dedicated Ip Access
    [Documentation]
    ...  Create a new US cluster
    ...  Verify cluster shows in list

    Sleep  5s

    Add New Cluster Instance  region=US  cluster_name=${cluster_instance_name_default}  developer_name=${developer_name}  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=Dedicated  deployment=docker  flavor_name=${flavor}  wait=300
    Sleep  30s
    Cluster Should Exist  region=US  cluster_name=${cluster_instance_name_default}  ip_access=Dedicated  wait=${wait}
    ${clusterInst}=  Show Cluster Instances  region=US  cluster_name=${cluster_instance_name_default}  cloudlet_name=${cloudlet_name}   developer_org_name=${developer_name}
    Log To Console  Printing Cluster Instance Object
    Log To Console  ${clusterInst}
    Should Be Equal              ${clusterInst[0]['data']['ip_access']}                           Dedicated
    Should Be Equal              ${clusterInst[0]['data']['flavor']['name']}                         ${flavor}


    Delete Cluster  cluster_name=${cluster_instance_name_default}  wait=${wait}

    Cluster Should Not Exist  cluster_name=${cluster_instance_name_default}

Web UI - user shall be able to create a new EU clusterinst with Kubernetes Shared Ip Access
    [Documentation]
    ...  Create a new EU cluster
    ...  Verify cluster shows in list

    Sleep  5s

    Add New Cluster Instance  region=EU  developer_name=${developer_name}  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=Shared  deployment=Kubernetes  flavor_name=${flavor}  wait=300

    Cluster Should Exist  region=US  ip_access=Shared  wait=${wait}

    Sleep  60s

    Delete Cluster 

    Cluster Should Not Exist

Web UI - user shall be able to create a new US clusterinst with Kubernetes Shared Ip Access
    [Documentation]
    ...  Create a new US cluster
    ...  Verify cluster shows in list

    Sleep  5s

    Add New Cluster Instance  region=US  developer_name=${developer_name}  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=Shared  deployment=Kubernetes  flavor_name=${flavor}  wait=300

    Cluster Should Exist  region=US  ip_access=Shared  wait=${wait}

    Sleep  60s

    Delete Cluster 

    Cluster Should Not Exist

Web UI - user shall be able to create a new EU clusterinst with Kubernetes Dedicated Ip Access
    [Documentation]
    ...  Create a new EU cluster
    ...  Verify cluster shows in list

    Sleep  5s

    Add New Cluster Instance  region=EU  developer_name=${developer_name}  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=Dedicated  deployment=Kubernetes  flavor_name=${flavor}  wait=300

    Cluster Should Exist  region=US  ip_access=Dedicated  wait=${wait}

    Sleep  60s

    Delete Cluster 

    Cluster Should Not Exist

Web UI - user shall be able to create a new US clusterinst with Kubernetes Dedicated Ip Access
    [Documentation]
    ...  Create a new US cluster
    ...  Verify cluster shows in list

    Sleep  5s

    Add New Cluster Instance  region=US  developer_name=${developer_name}  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=Dedicated  deployment=Kubernetes  flavor_name=${flavor}  wait=300

    Cluster Should Exist  region=US  ip_access=Dedicated  wait=${wait}

    Sleep  60s

    Delete Cluster 

    Cluster Should Not Exist

*** Keywords ***
Setup
    ${cluster_instance_name_default}=  Get Default Cluster Name
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Cluster Instances
    Set Suite Variable  ${cluster_instance_name_default}

Teardown
    Close Browser
