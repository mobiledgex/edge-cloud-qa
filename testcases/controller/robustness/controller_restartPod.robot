*** Settings ***
Documentation  Restart controller

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexK8s         kubeconfig=../../config/edgecloud_start.kubeconfig
#Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
#Library  MexApp
Variables  shared_variables.py
	
#Test Setup      Setup
#Test Teardown   Teardown

Test Timeout  30 minutes
	
*** Variables ***
#${cluster_flavor_name}  x1.medium
	
#${cloudlet_name}  automationHawkinsCloudlet
#${operator_name}  GDDT
#${latitude}       32.7767
#${longitude}      -96.7970

#@{clustersvc_pods}  alertmanager-mexprometheusappname-prome-alertmanager  mexprometheusappname-grafana  mexprometheusappname-kube-state-metrics  mexprometheusappname-prome-operator  mexprometheusappname-prometheus-node-exporter  prometheus-mexprometheusappname-prome-prometheus  
#mexmetricswriter-deployment

#${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
#${docker_command}  ./server_ping_threaded.py

#${app_template}    http://35.199.188.102/apps/apptemplate.yaml
	
*** Test Cases ***
Provisioning shall be correct after restarting 1 Controller
    [Documentation]
    ...  add provisioning
    ...  restart 1 controller pod
    ...  get provisioning
    ...  verify it is correct
    ...  delete provisioning	

    ${operator}=        Create Operator
    ${developer}=       Create Developer
    ${flavor}=          Create Flavor
    ${cluster_flavor}=  Create Cluster Flavor
    ${cluster}=         Create Cluster
    ${app}=             Create App
	
    Restart Controller

    Sleep  5  secs

    ${operator_post}=        Show Operators        operator_name=${operator_name_default}
    ${developer_post}=       Show Developers       developer_name=${developer_name_default}
    ${flavor_post}=          Show Flavors          flavor_name=${flavor_name_default}
    ${cluster_flavor_post}=  Show Cluster Flavors  cluster_flavor_name=${cluster_flavor_name_default}
    ${cluster_post}=         Show Clusters         cluster_name=${cluster_name_default}
    ${app_post}=             Show Apps             app_name=${app_name_default}

    Delete App
    Delete Operator
    Delete Developer
    Delete Cluster
    Delete Cluster Flavor
    Delete Flavor

    Should be equal as strings  ${operator}        ${operator_post[0]}
    Should be equal as strings  ${developer}       ${developer_post[0]}
    Should be equal as strings  ${flavor}          ${flavor_post[0]}
    Should be equal as strings  ${cluster_flavor}  ${cluster_flavor_post[0]}
    Should be equal as strings  ${cluster}         ${cluster_post[0]}
    Should be equal as strings  ${app}             ${app_post[0]}

    Operator Should Not Exist
    Developer Should Not Exist
    Flavor Should Not Exist
    Cluster Flavor Should Not Exist
    Cluster Should Not Exist
    App Should Not Exist
