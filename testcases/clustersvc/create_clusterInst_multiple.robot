*** Settings ***
Documentation  Verify multiple Prometheus apps are created when creating a cluster instance

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Variables       shared_variables.py

Test Setup      Setup
Test Teardown   Teardown

Test Timeout  30 minutes
	
*** Variables ***
${cloudlet_name}  tmocloud-1
${operator_name}  dmuus
	
*** Test Cases ***
clustersvc shall create/delete multiple MEXPrometheusAppName and MEXMetricsExporter app and app instance
    [Documentation]
    ...  create a cluster instance
    ...  verify MEXPrometheusAppName and MEXMetricsExporter apps and app instances are created
    ...  delete the cluster instance
    ...  verify MEXPrometheusAppName and MEXMetricsExporter app instances are deleted

    Create Cluster Instance  cluster_name=${cluster_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    Create Cluster Instance  cluster_name=${cluster_name_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    sleep  5
	
    Show Apps
    # check that apps are created
    App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=${cluster_name_default}  ip_access=IpAccessShared  deployment=helm
    App Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  image_path=registry.mobiledgex.net:5000/mobiledgex/metrics-exporter:latest  default_flavor_name=x1.medium  cluster_name=${cluster_name_default}  ip_access=IpAccessShared  deployment=kubernetes
    App Instance Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Instance Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=${cluster_name_2}  ip_access=IpAccessShared  deployment=helm
    App Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  image_path=registry.mobiledgex.net:5000/mobiledgex/metrics-exporter:latest  default_flavor_name=x1.medium  cluster_name=${cluster_name_2}  ip_access=IpAccessShared  deployment=kubernetes
    App Instance Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=${cluster_name_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Instance Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=${cluster_name_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor
    Create Cluster

    ${cluster_name_2}=  Catenate  SEPARATOR=-  ${cluster_name_default}  2
    Create Cluster  cluster_name=${cluster_name_2}

    Set Suite Variable  ${cluster_name_2} 

Teardown
    Cleanup provisioning

    App Instance Should Not Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Instance Should Not Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=${cluster_name_default}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=${cluster_name_default}  ip_access=IpAccessShared  deployment=helm
    App Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  image_path=registry.mobiledgex.net:5000/mobiledgex/metrics-exporter:latest  default_flavor_name=x1.medium  cluster_name=${cluster_name_default}  ip_access=IpAccessShared  deployment=kubernetes

    App Instance Should Not Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=${cluster_name_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Instance Should Not Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=${cluster_name_2}  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=${cluster_name_2}  ip_access=IpAccessShared  deployment=helm
    App Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  image_path=registry.mobiledgex.net:5000/mobiledgex/metrics-exporter:latest  default_flavor_name=x1.medium  cluster_name=${cluster_name_2}  ip_access=IpAccessShared  deployment=kubernetes
