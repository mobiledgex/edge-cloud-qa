*** Settings ***
Documentation  Verify Prometheus apps are created when creating a cluster instance

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

Test Setup      Setup
Test Teardown   Teardown

Test Timeout  30 minutes
	
*** Variables ***
${cloudlet_name}  tmocloud-1
${operator_name}  dmuus
	
*** Test Cases ***
clustersvc shall create/delete MEXPrometheusAppName and MEXMetricsExporter app and app instance
    [Documentation]
    ...  create a cluster instance
    ...  verify MEXPrometheusAppName and MEXMetricsExporter apps and app instances are created
    ...  delete the cluster instance
    ...  verify MEXPrometheusAppName and MEXMetricsExporter app instances are deleted

    Create Cluster Instance  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    sleep  5
	
    Show Apps
    # check that apps are created
    App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=helm
    App Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  image_path=registry.mobiledgex.net:5000/mobiledgex/metrics-exporter:latest  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=kubernetes

    # check that app instances are created
    App Instance Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=default  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Instance Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=default  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster Flavor
    Create Cluster
    #Create Cloudlet  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}  

Teardown
    Cleanup provisioning

    App Instance Should Not Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=default  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}
    App Instance Should Not Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  flavor_name=x1.medium  cluster_instance_name=default  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}

    App Should Exist  app_name=MEXPrometheusAppName  app_version=1.0  developer_name=mexinfradev_  image_path=stable/prometheus-operator  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=helm
    App Should Exist  app_name=MEXMetricsExporter  app_version=1.0  developer_name=mexinfradev_  image_path=registry.mobiledgex.net:5000/mobiledgex/metrics-exporter:latest  default_flavor_name=x1.medium  cluster_name=default  ip_access=IpAccessShared  deployment=kubernetes
