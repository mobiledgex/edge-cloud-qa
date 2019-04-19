*** Settings ***
Documentation  Create provisioning

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}

*** Test Cases ***
Create Operator
   Create Operator  operator_name=TDG
   Create Operator  operator_name=gcp
   Create Operator  operator_name=tmus
   Create Operator  operator_name=att
   Create Operator  operator_name=azure

Create Developer
   Create Developer  developer_name=automation_api

Create Flavor
   Create Flavor  flavor_name=x1.medium  ram=4096  vcpus=4  disk=4
   Create Flavor  flavor_name=automation_api_flavor  ram=4096  vcpus=4  disk=4

Create Cluster Flavor
   Create Cluster Flavor  cluster_flavor_name=x1.medium  node_flavor_name=x1.medium  master_flavor_name=x1.medium  number_nodes=3  max_nodes=4  number_masters=1
   Create Cluster Flavor  cluster_flavor_name=automation_api_cluster_flavor  node_flavor_name=automation_api_flavor  master_flavor_name=automation_api_flavor  number_nodes=1  max_nodes=1  number_masters=1

Create Cluster
   Create Cluster  cluster_name=automationapicluster  default_flavor_name=automation_api_cluster_flavor
	
Create Cloudlet
   Create Cloudlet  cloudlet_name=tmocloud-1  operator_name=tmus  number_of_dynamic_ips=254  latitude=31  longitude=-91  ipsupport=IpSupportDynamic
   Create Cloudlet  cloudlet_name=tmocloud-2  operator_name=tmus  number_of_dynamic_ips=254  latitude=35  longitude=-95  ipsupport=IpSupportDynamic
   Create Cloudlet  cloudlet_name=automationBonnCloudlet  operator_name=TDG  number_of_dynamic_ips=254  latitude=35  longitude=-95  ipsupport=IpSupportDynamic
   Create Cloudlet  cloudlet_name=automationBerlinCloudlet  operator_name=TDG  number_of_dynamic_ips=254  latitude=35  longitude=-95  ipsupport=IpSupportDynamic
   Create Cloudlet  cloudlet_name=automationHamburgCloudlet  operator_name=TDG  number_of_dynamic_ips=254  latitude=35  longitude=-95  ipsupport=IpSupportDynamic
   Create Cloudlet  cloudlet_name=attcloud-1  operator_name=att  number_of_dynamic_ips=254  latitude=35  longitude=-95  ipsupport=IpSupportDynamic
   Create Cloudlet  cloudlet_name=automationProdHamburgCloudlet  operator_name=att  number_of_dynamic_ips=254  latitude=35  longitude=-95  ipsupport=IpSupportDynamic
   Create Cloudlet  cloudlet_name=automationAzureCentralCloudlet  operator_name=azure  number_of_dynamic_ips=254  latitude=32.7767  longitude=-96.797  ipsupport=IpSupportDynamic

Create App
   Create App  app_name=automation_api_app  app_version=1.0  developer_name=automation_api  image_type=ImageTypeDocker  cluster_name=automationapicluster  default_flavor_name=automation_api_flavor
   Create App  app_name=automation_api_auth_app  app_version=1.0  developer_name=automation_api  image_type=ImageTypeDocker  cluster_name=automationapicluster  default_flavor_name=automation_api_flavor  auth_public_key=-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij\nTkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0\nVU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC\nGJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS\nz3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m\nQnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C\n/QIDAQAB\n-----END PUBLIC KEY-----

Create App Instance
   Create App Instance  app_name=automation_api_app  app_version=1.0  developer_name=automation_api  cluster_instance_name=autocluster  cloudlet_name=tmocloud-1  operator_name=tmus  flavor_name=automation_api_flavor