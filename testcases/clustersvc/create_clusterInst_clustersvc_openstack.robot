*** Settings ***
Documentation  use FQDN to access app on openstack

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
#Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Teardown

Test Timeout  30 minutes
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationHawkinsCloudlet
${operator_name_openstack}  GDDT
${mobiledgex_domain}  mobiledgex.net

${latitude}       32.7767
${longitude}      -96.7970

#@{clustersvc_pods}  alertmanager-mexprometheusappname-prome-alertmanager  mexprometheusappname-kube-state-metrics  mexprometheusappname-prome-operator  mexprometheusappname-prometheus-node-exporter  prometheus-mexprometheusappname-prome-prometheus  
#@{clustersvc_pods}  mexprometheusappnamev10-kube-state-metrics  mexprometheusappnamev10-pr-operator  mexprometheusappnamev10-prometheus-node-exporter  mexprometheusappnamev10-prometheus-node-exporter  prometheus-mexprometheusappnamev10-pr-prometheus
@{clustersvc_pods}  mexprometheusappnamev10-kube-state-metrics  mexprometheusappnamev10-ku-operator  mexprometheusappnamev10-prometheus-node-exporter  mexprometheusappnamev10-prometheus-node-exporter  prometheus-mexprometheusappnamev10-ku-prometheus
#mexmetricswriter-deployment  mexprometheusappname-grafana

#${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
#${docker_command}  ./server_ping_threaded.py

#${app_template}    http://35.199.188.102/apps/apptemplate.yaml
	
*** Test Cases ***
# ECQ-1289
Create clusterInst for clustersvc on CRM
    [Documentation]
    ...  - create a clusterInst on CRM
    ...  - verify MEXPrometheusAppName and MEXMetricsWriter are created

    IF  '${platform_type}' != 'K8SBareMetal'
        Create Cluster Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  flavor_name=${cluster_flavor_name}
    END
    ${cluster_name_default}=  Get Default Cluster Name

    # check that apps are created
    App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_org_name=MobiledgeX  image_path=https://prometheus-community.github.io/helm-charts:prometheus-community/kube-prometheus-stack  default_flavor_name=x1.medium  cluster_name=default  deployment=helm
    #App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_org_name=MobiledgeX  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=default  deployment=helm
    #App Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=MobiledgeX  image_path=docker.mobiledgex.net/mobiledgex/images/metrics-exporter:latest  default_flavor_name=x1.medium  deployment=kubernetes

    # check that pods are running
    FOR  ${pod}  IN  @{clustersvc_pods}
       Wait for k8s pod to be running  pod_name=${pod}  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_crm}
    END

    # check that app instances are created
    App Instance Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_org_name=MobiledgeX  flavor_name=x1.medium  cluster_instance_name=default  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    #App Instance Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=MobiledgeX  flavor_name=x1.medium  cluster_instance_name=default  cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}


*** Keywords ***
Setup
    #Create Developer
    Create Flavor
    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    Set Suite Variable  ${platform_type}

    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  
    #Create Cluster   default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}  
    ${rootlb}=  Catenate  SEPARATOR=.  shared  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}

Teardown
    Cleanup provisioning

    App Instance Should Not Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=MobiledgeX  flavor_name=x1.medium  cluster_instance_name=default  cloudlet_name=${cloudlet_name_crm}  operator_name=${operator_name_crm}
    #App Instance Should Not Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=MobiledgeX  flavor_name=x1.medium  cluster_instance_name=default  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}
    App Should Not Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=MobiledgeX image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=helm
    #App Should Not Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=MobiledgeX  image_path=docker.mobiledgex.net/mobiledgex/images/metrics-exporter:latest  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=kubernetes
