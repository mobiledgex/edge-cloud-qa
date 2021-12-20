*** Settings ***
Documentation   Create and delete 50 clusterinst

Library         MexConsole  url=%{AUTOMATION_CONSOLE_ADDRESS}

Test Setup      Setup
Test Teardown   Close Browser

Test Timeout    40 minutes

*** Variables ***
${browser}           Chrome
${console_username}  mexadmin
${console_password}  mexadminfastedgecloudinfra
${cluster}  jclustertest
${region}  EU
${developer_name}  MobiledgeX
${operator_name}  TMPL
${cloudlet_name}  krakow-main
${ip_access}  Dedicated  
${deployment}  Docker
${flavor}  x1.medium
${wait}  200


## Doesn't have enough IPs to create all 50 

*** Test Cases ***
Web UI - user shall be able to create a new US clusterinst with Docker Dedicated Ip Access
    [Documentation]
    ...  Create a new US cluster
    ...  Verify cluster shows in list

    :FOR    ${i}    IN RANGE    50
    \  Sleep  5s
    \  ${cluster_name}=  Catenate  SEPARATOR=  ${cluster}  ${i} 
    
    \  Add New Cluster Instance  region=${region}  cluster_name=${cluster_name}  developer_name=${developer_name}  operator_name=${operator_name}  cloudlet_name=${cloudlet_name}  ip_access=${ip_access}  deployment=${deployment}  flavor_name=${flavor}  wait=300

    \  Cluster Should Exist  region=${region}  cluster_name=${cluster_name}  ip_access=${ip_access}  wait=${wait}

    #:FOR    ${i}    IN RANGE    50
  #  \  Cluster Should Exist  region=${region}  cluster_name=${cluster_name}  ip_access=${ip_access}  wait=${wait}


    :FOR    ${i}    IN RANGE    50
    \  ${cluster_name}=  Catenate  SEPARATOR=  ${cluster}  ${i} 
    \  Delete Cluster  cluster_name=${cluster_name}  wait=${wait}

    \  Cluster Should Not Exist


*** Keywords ***
Setup
    Open Browser
    Login to Mex Console  browser=${browser}  #username=${console_username}  password=${console_password}
    Open Compute
    Open Cluster Instances
Teardown
    Close Browser

