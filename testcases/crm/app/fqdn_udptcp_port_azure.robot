*** Settings ***
Documentation  use FQDN to access app on azure

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme         dme_address=%{AUTOMATION_DME_ADDRESS}	
Library  MexCrm         crm_pod_name=%{AUTOMATION_CRM_AZURE_POD_NAME}  kubeconfig=%{AUTOMATION_KUBECONFIG}
Library  MexApp
#Variables       shared_variables.py

Test Setup      Setup
Test Teardown	Cleanup provisioning

Test Timeout  15 minutes

*** Variables ***
${cluster_flavor_name}  x1.tiny
	
${cloudlet_name_azure}  automationAzureCentralCloudlet
${operator_name}  azure
${latitude}       32.7767
${longitude}      -96.7970

${crm_pod_name}   crmazurecloud1

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${app_template}    http://35.199.188.102/apps/apptemplate.yaml
	
*** Test Cases ***
User shall be able to access 1 UDP port on azure
    [Documentation]
    ...  deploy app with 1 UDP port on azure
    ...  verify the port as accessible 

    Log To Console  Creating App and App Instance	
    Create App  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  app_template=${apptemplate}
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}  cluster_instance_name=${cluster_name} 

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default} 

    Log To Console  Checking if port is alive
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}

User shall be able to access 2 UDP ports on azure
    [Documentation]
    ...  deploy app with 2 UDP ports on azure
    ...  verify both ports are accessible 

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=udp:2015,udp:2016  command=${docker_command}  app_template=${apptemplate}
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}  cluster_instance_name=${cluster_name} 

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[1].public_port}

User shall be able to access 1 TCP port on azure
    [Documentation] 
    ...  deploy app with 1 TCP port on azure
    ...  verify the port as accessible 

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  app_template=${apptemplate}
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}  cluster_instance_name=${cluster_name} 

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}

User shall be able to access 2 TCP ports on azure
    [Documentation]
    ...  deploy app with 2 TCP ports on azure
    ...  verify both ports are accessible 

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  command=${docker_command}  app_template=${apptemplate}
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}  cluster_instance_name=${cluster_name} 

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[1].public_port}

User shall be able to access 2 UDP and 2 TCP ports on azure
    [Documentation]
    ...  deploy app with 2 UDP and 2 TCP ports on azure
    ...  verify all ports are accessible 

    # EDGECLOUD-324 Creating an app with tcp and udp ports sets the fqdnprefix to tcp for both ports

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  command=${docker_command}  app_template=${apptemplate}
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}  cluster_instance_name=${cluster_name} 

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[1].public_port}
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[3].public_port}

*** Keywords ***
Setup

    ${epoch_time}=  Get Time  epoch
    ${cluster_name}=    Catenate  SEPARATOR=  cl  ${epoch_time}

    #Create Operator   operator_name=${operator_name}
    Create Developer
    Create Flavor
    Create Cluster Flavor  #cluster_flavor_name=${cluster_flavor_name}  
    Create Cluster   cluster_name=${cluster_name} 
    #Create Cloudlet  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    log to console  START creating cluster instance
    Create Cluster Instance  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}  #flavor_name=${cluster_flavor_name}
    log to console  DONE creating cluster instance

    Set Suite Variable  ${cluster_name}

