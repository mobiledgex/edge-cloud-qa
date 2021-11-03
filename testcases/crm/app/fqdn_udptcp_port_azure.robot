*** Settings ***
Documentation  use FQDN to access app on azure

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme         dme_address=%{AUTOMATION_DME_ADDRESS}	
#Library  MexCrm         crm_pod_name=%{AUTOMATION_CRM_AZURE_POD_NAME}  kubeconfig=%{AUTOMATION_KUBECONFIG}
Library  MexApp
Library  DateTime
Library  String
#Variables       shared_variables.py

Test Setup      Setup
Test Teardown	Cleanup provisioning

Test Timeout    ${test_timeout_crm} 

*** Variables ***
${cluster_flavor_name}  x1.tiny
	
${cloudlet_name_azure}  automationAzureCentralCloudlet
${operator_name_azure}  azure
${latitude}       32.7767
${longitude}      -96.7970

${crm_pod_name}   crmazurecloud1

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-1143
User shall be able to access 1 UDP port on azure
    [Documentation]
    ...  - deploy app with 1 UDP port on azure
    ...  - verify the port as accessible 

    Log To Console  Creating App and App Instance	
    Create App  cluster_name=${cluster_name}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name_azure}  pod_name=${app_name_default} 

    Log To Console  Checking if port is alive
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}

# ECQ-1144
User shall be able to access 2 UDP ports on azure
    [Documentation]
    ...  - deploy app with 2 UDP ports on azure
    ...  - verify both ports are accessible 

    Log To Console  Creating App and App Instance
    Create App  cluster_name=${cluster_name}  image_path=${docker_image}  access_ports=udp:2015,udp:2016  command=${docker_command}  
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name_azure}  pod_name=${app_name_default}

    Sleep  10 seconds

    Log To Console  Checking if port is alive
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[1].public_port}

# ECQ-1145
User shall be able to access 1 TCP port on azure
    [Documentation] 
    ...  - deploy app with 1 TCP port on azure
    ...  - verify the port as accessible 

    Log To Console  Creating App and App Instance
    Create App  cluster_name=${cluster_name}  image_path=${docker_image}  access_ports=tcp:2015  command=${docker_command}  
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name_azure}  pod_name=${app_name_default}

    Sleep  10 seconds

    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}

# ECQ-1146
User shall be able to access 2 TCP ports on azure
    [Documentation]
    ...  - deploy app with 2 TCP ports on azure
    ...  - verify both ports are accessible 

    Log To Console  Creating App and App Instance
    Create App  cluster_name=${cluster_name}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016  command=${docker_command}  
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name_azure}  pod_name=${app_name_default}

    Sleep  10 seconds

    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn}  ${cloudlet.ports[1].public_port}

# ECQ-1147
User shall be able to access 2 UDP and 2 TCP ports on azure
    [Documentation]
    ...  - deploy app with 2 UDP and 2 TCP ports on azure
    ...  - verify all ports are accessible 

    # EDGECLOUD-324 Creating an app with tcp and udp ports sets the fqdnprefix to tcp for both ports

    Log To Console  Creating App and App Instance
    Create App  cluster_name=${cluster_name}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,udp:2015,udp:2016  command=${docker_command}  
    Create App Instance  cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  cluster_instance_name=${cluster_name} 

    Wait For App Instance Health Check OK

    Log To Console  Register Client and Find Cloudlet
    Register Client
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    ${fqdn0}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn1}=  Catenate  SEPARATOR=  ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn2}=  Catenate  SEPARATOR=  ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn3}=  Catenate  SEPARATOR=  ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    #Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name_azure}  pod_name=${app_name_default}

    Sleep  10 seconds
	
    Log To Console  Checking if port is alive
    TCP Port Should Be Alive  ${fqdn0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn1}  ${cloudlet.ports[1].public_port}
    UDP Port Should Be Alive  ${fqdn2}  ${cloudlet.ports[2].public_port}
    UDP Port Should Be Alive  ${fqdn3}  ${cloudlet.ports[3].public_port}

*** Keywords ***
Setup
    ${cluster_name}=  Generate Random String  length=2  chars=[LOWER]  # generate 2 char string with lowercase only. This is because of limitations on length of resourcegroups in azure

    ${current_date}=  Get Current Date
    #${epoch_time}=  Get Time  epoch
    ${epoch_time}=  Convert Date  ${current_date}  epoch
    ${cluster_name}=    Catenate  SEPARATOR=  ${cluster_name}  ${epoch_time}
    #${cluster_name}=  Remove String  ${cluster_name}  .
	
    #Create Developer
    Create Flavor
    #Create Cluster   cluster_name=${cluster_name} 
    #Create Cloudlet  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    log to console  START creating cluster instance
    Create Cluster Instance  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name_azure}  operator_org_name=${operator_name_azure}  #flavor_name=${cluster_flavor_name}
    log to console  DONE creating cluster instance

    Set Suite Variable  ${cluster_name}

