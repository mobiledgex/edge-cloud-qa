*** Settings ***
Documentation  use FQDN to access app on openstack

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp

Test Setup      Setup
Test Teardown   Teardown

Test Timeout  30 minutes
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name}  automationHamburgCloudlet
${operator_name}  TDG
${latitude}       32.7767
${longitude}      -96.7970

@{clustersvc_pods}  alertmanager-mexprometheusappname-prome-alertmanager  mexprometheusappname-grafana  mexprometheusappname-kube-state-metrics  mexprometheusappname-prome-operator  mexprometheusappname-prometheus-node-exporter  prometheus-mexprometheusappname-prome-prometheus  
#mexmetricswriter-deployment

#${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
#${docker_command}  ./server_ping_threaded.py

#${app_template}    http://35.199.188.102/apps/apptemplate.yaml
	
*** Test Cases ***
Create clusterInst for clustersvc on openstack
    [Documentation]
    ...  create a clusterInst on openstack
    ...  verify MEXPrometheusAppName and MEXMetricsWriter are created

    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}

    # check that apps are created
    App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=helm
    App Should Exist  app_name=MEXMetricsWriter  app_version=1.0  developer_name=mexinfradev_  image_path=registry.mobiledgex.net:5000/mexinfradev_/MEXMetricsWriter:1.0  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=kubernetes

    # check that pods are running
    Wait for k8s pod to be running  pod=${clustersvc_pods}  root_loadbalancer=automation-bonn.tdg.mobiledgex.net

    # check that app instances are created
    App Instance Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_name=default  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Instance Should Exist  app_name=MEXMetricsWriter  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_name=default  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}


*** Keywords ***
Setup
    Create Developer
    Create Flavor
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  
    #Create Cluster   default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}  

Teardown
    Cleanup provisioning

    App Instance Should Not Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_name=default  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Instance Should Not Exist  app_name=MEXMetricsWriter  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_name=default  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Should Not Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=helm
    App Should Not Exist  app_name=MEXMetricsWriter  app_version=1.0  developer_name=mexinfradev_  image_path=registry.mobiledgex.net:5000/mexinfradev_/MEXMetricsWriter:1.0  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=kubernetes
