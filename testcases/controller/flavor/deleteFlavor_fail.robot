*** Settings ***
Documentation   Flavor with missing parms

Library		MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name}  tmus
${cloudlet_name}  tmocloud-1
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

*** Test Cases ***
Flavor - error shall be recieved when deleting flavor used by k8s/dedicated clusterInst
    [Documentation]
    ...  create a k8s/dedicated cluster instance 
    ...  attempt to delete the flavor used by the clusterinst
    ...  verify error is received

    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessDedicated

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Flavor

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   Flavor in use by Cluster 

Flavor - error shall be recieved when deleting flavor used by k8s/shared clusterInst
    [Documentation]
    ...  create a k8s/shared cluster instance
    ...  attempt to delete the flavor used by the clusterinst
    ...  verify error is received

    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  deployment=kubernetes  ip_access=IpAccessShared

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Flavor

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   Flavor in use by Cluster

Flavor - error shall be recieved when deleting flavor used by docker/dedicated clusterInst
    [Documentation]
    ...  create a docker/dedicated cluster instance
    ...  attempt to delete the flavor used by the clusterinst
    ...  verify error is received

    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Flavor

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   Flavor in use by Cluster

Flavor - error shall be recieved when deleting flavor used by docker app
    [Documentation]
    ...  create a docker app
    ...  attempt to delete the flavor used by the app
    ...  verify error is received

    Create App  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Flavor

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   Flavor in use by App

Flavor - error shall be recieved when deleting flavor used by k8s app
    [Documentation]
    ...  create a k8s app
    ...  attempt to delete the flavor used by the app
    ...  verify error is received

    Create App  deployment=kubernetes  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Flavor

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   Flavor in use by App

Flavor - error shall be recieved when deleting flavor used by vm app
    [Documentation]
    ...  create a vm app
    ...  attempt to delete the flavor used by the app
    ...  verify error is received

    Create App  deployment=vm  image_type=ImageTypeQcow  image_path=${qcow_centos_image}  access_ports=tcp:1

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Flavor

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   Flavor in use by App

Flavor - error shall be recieved when deleting flavor used by autocluster appinst
    [Documentation]
    ...  create an appinst with autocluster
    ...  attempt to delete the flavor used by the appinst/cluster
    ...  verify error is received

    ${epoch_time}=  Get Time  epoch

    ${cluster_name}=  Catenate  SEPARATOR=-  autocluster  ${epoch_time}

    Create App  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1

    Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  cluster_instance_name=${cluster_name}

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Flavor

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   Flavor in use by Cluster 

Flavor - error shall be recieved when deleting flavor used by appinst
    [Documentation]
    ...  create an appinst with autocluster
    ...  attempt to delete the flavor used by the appinst/cluster
    ...  verify error is received

    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  deployment=docker  ip_access=IpAccessDedicated

    Create App  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:1

    ${flavor_name_default}=  Get Default Flavor Name
    ${flavor_name_new}=  Catenate  SEPARATOR=  ${flavor_name_default}  1 
    Create Flavor  flavor_name=${flavor_name_new}

    Create App Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${flavor_name_new}

    ${error_msg}=  Run Keyword and Expect Error  *  Delete Flavor  flavor_name=${flavor_name_new}

    Should Contain  ${error_msg}   status = StatusCode.UNKNOWN
    Should Contain  ${error_msg}   Flavor in use by AppInst

*** Keywords ***
Setup
    Create Developer
    Create Flavor
