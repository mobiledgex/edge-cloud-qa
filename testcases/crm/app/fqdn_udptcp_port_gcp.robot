*** Settings ***
Documentation  use FQDN to access app on gcp

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme         dme_address=%{AUTOMATION_DME_ADDRESS}	
#Library  MexCrm         crm_pod_name=%{AUTOMATION_CRM_GCP_POD_NAME}  kubeconfig=%{AUTOMATION_KUBECONFIG}
Library  MexApp

Test Setup      Setup
Test Teardown	Cleanup provisioning

Test Timeout    ${test_timeout_crm}

*** Variables ***
${cloudlet_name_gcp}  automationGcpCentralCloudlet
${operator_name_gcp}  gcp

${latitude}       32.7767
${longitude}      -96.7970

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-1287
User shall be able to access 1 UDP port on gcp
    [Documentation]
    ...  deploy app with 1 UDP port on gcp
    ...  verify the port as accessible 

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Log To Console  Creating App and App Instance	
    Create App  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}
    Create App Instance  cloudlet_name=${cloudlet_name_gcp}  operator_org_name=${operator_name_gcp}  cluster_instance_name=${cluster_name_default} 
    
    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name_default}  operator_name=${operator_name_gcp}  pod_name=${app_name_default} 

    Log To Console  Checking if port is alive
    Sleep  1 min
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}

User shall be able to access 2 UDP ports on azure
    [Documentation]
    ...  deploy app with 2 UDP ports on azure
    ...  verify both ports are accessible 

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=udp:2015,udp:2016  command=${docker_command}  app_template=${apptemplate}
    Create App Instance  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[1].public_port}

User shall be able to access 1 TCP port on azure
    [Documentation] 
    ...  deploy app with 1 TCP port on azure
    ...  verify the port as accessible 

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  app_template=${apptemplate}
    Create App Instance  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}

User shall be able to access 2 TCP ports on azure
    [Documentation]
    ...  deploy app with 2 TCP ports on azure
    ...  verify both ports are accessible 

    Log To Console  Creating App and App Instance
    Create App  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  command=${docker_command}  app_template=${apptemplate}
    Create App Instance  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

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
    Create App Instance  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name_default}

    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[1].public_port}
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[3].public_port}

*** Keywords ***
Setup

    #${epoch_time}=  Get Time  epoch
    #${cluster_name}=    Catenate  SEPARATOR=  cl  ${epoch_time}

    #Create Developer
    Create Flavor
    #Create Cluster   #cluster_name=${cluster_name} 

    log to console  START creating cluster instance
    Create Cluster Instance   cloudlet_name=${cloudlet_name_gcp}  operator_org_name=${operator_name_gcp}
    log to console  DONE creating cluster instance

    #Set Suite Variable  ${cluster_name}

