*** Settings ***
Documentation  use FQDN to access app on openstack with IpAccessDedicated

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  30 minutes
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationBonnCloudlet
${operator_name_openstack}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html
${app_template}    http://35.199.188.102/apps/apptemplate.yaml
	
*** Test Cases ***
User shall be able to access 1 UDP port on openstack with IpAccessDedicated
    [Documentation]
    ...  deploy app with 1 UDP port
    ...  verify the port as accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  app_template=${apptemplate}  default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}
	
    Log To Console  Registering Client and Finding Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_openstack}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
#    UDP Port Should Be Alive  app1554837441-901057-udp.automationhamburgcloudlet.tdg.mobiledgex.net  2015
   #UDP Port Should Be Alive  10.101.8.2  2015

User shall be able to access 2 UDP ports on openstack with IpAccessDedicated
    [Documentation]
    ...  deploy app with 2 UDP ports
    ...  verify both ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=udp:2015,udp:2016  command=${docker_command}  app_template=${apptemplate}  default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Log To Console  Registering Client and Finding Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].FQDN_prefix}  ${cloudlet.FQDN}
	
    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    UDP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

User shall be able to access 1 TCP port on openstack with IpAccessDedicated
    [Documentation]
    ...  deploy app with 1 TCP port
    ...  verify the port as accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  app_template=${apptemplate}  default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}

User shall be able to access 2 TCP ports on openstack with IpAccessDedicated
    [Documentation]
    ...  deploy app with 2 TCP ports
    ...  verify both ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  command=${docker_command}  app_template=${apptemplate}  default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].FQDN_prefix}  ${cloudlet.FQDN}

    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

User shall be able to access 2 UDP and 2 TCP ports on openstack with IpAccessDedicated
    [Documentation]
    ...  deploy app with 2 UDP and 2 TCP ports
    ...  verify all ports are accessible via fqdn

    # EDGECLOUD-324 Creating an app with tcp and udp ports sets the fqdnprefix to tcp for both ports

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  command=${docker_command}  app_template=${apptemplate}  default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}
    ${fqdn_1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].FQDN_prefix}  ${cloudlet.FQDN}
    ${fqdn_2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].FQDN_prefix}  ${cloudlet.FQDN}
    ${fqdn_3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].FQDN_prefix}  ${cloudlet.FQDN}

    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn_3}  ${cloudlet.ports[3].public_port}

User shall be able to access HTTP port on openstack with IpAccessDedicated
    [Documentation]
    ...  deploy app with HTTP port
    ...  verify the port as accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=http:8085  command=${docker_command}  default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}
	
    Log To Console  Registering Client and Finding Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_openstack}
    ${page}=  Catenate  SEPARATOR=/  ${cloudlet.ports[0].path_prefix}  ${http_page}

    Log To Console  Waiting for k8s pod to be running
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    HTTP Port Should Be Alive  ${cloudlet.FQDN}  ${cloudlet.ports[0].public_port}  ${page}

User shall be able to access UDP,TCP and HTTP ports on openstack with IpAccessDedicated
    [Documentation]
    ...  deploy app with 1 UDP and 1 TCP and 1 HTTP ports
    ...  verify all ports are accessible via fqdn

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create App  image_path=${docker_image}  access_ports=tcp:2015,udp:2015,http:8085  command=${docker_command}  default_flavor_name=${cluster_flavor_name}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].FQDN_prefix}  ${cloudlet.FQDN}
    ${page}=    Catenate  SEPARATOR=/  ${cloudlet.ports[2].path_prefix}  ${http_page}

    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name_default}


    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
    HTTP Port Should Be Alive  ${cloudlet.FQDN}  ${cloudlet.ports[2].public_port}  ${page}

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    Create Cluster   #default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  ip_access=IpAccessDedicated
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${cluster_name}=  Get Default Cluster Name
    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}
    
    Set Suite Variable  ${rootlb}
