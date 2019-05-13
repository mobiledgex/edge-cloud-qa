*** Settings ***
Documentation  Create an app instance on azure with a dot in the appname

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexCrm         crm_pod_name=%{AUTOMATION_CRM_AZURE_POD_NAME}  kubeconfig=%{AUTOMATION_KUBECONFIG}
Library  MexDme         dme_address=%{AUTOMATION_DME_ADDRESS}
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  30 minutes
	
*** Variables ***
${cloudlet_name_azure}  automationAzureCentralCloudlet
${operator_name_azure}  azure
${latitude}             32.7767
${longitude}            -96.7970

#${mobiledgex_domain}  mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

	
*** Test Cases ***
User shall be able to create an app instance on azure with a dot in the app name
    [Documentation]
    ...  create an app instance on azure with a dot in the app name. Such as 'my.app'
    ...  verify the app is create with the dot removed. Such as 'myapp'

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=.  app  ${epoch_time}

    ${cluster_name_default}=  Get Default Cluster Name

    Log To Console  Creating App and App Instance
    Create App  app_name=${app_name}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  #app_template=${apptemplate}    #   default_flavor_name=flavor1550592128-673488   cluster_name=cl1550691984-633559
    Create App Instance  app_name=${app_name}  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name_azure}  cluster_instance_name=${cluster_name_default}  #cluster_instance_name=cl1550691984-633559  flavor_name=flavor1550592128-673488

    Log To Console  Registering Client and Finding Cloudlet
    Register Client  app_name=${app_name}
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${app_name_nodot}=    Catenate  SEPARATOR=  app  ${epoch_time}  -udp.

    # verify dot is gone
    Should Be Equal     ${app_name_nodot}  ${cloudlet.ports[0].FQDN_prefix}

    Log To Console  Waiting for k8s pod to be running
    ${app_name_default}=  Get Default App Name
    Wait for pod to be running on CRM  cluster_name=${cluster_name}  operator_name=${operator_name_azure}  pod_name=${app_name_default}

*** Keywords ***
Setup
    ${epoch_time}=  Get Time  epoch
    ${cluster_name}=    Catenate  SEPARATOR=.  cl  ${epoch_time}
    Set Suite Variable  ${cluster_name}

    Create Developer
    Create Flavor
    Create Cluster   cluster_name=${cluster_name} 
    
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  cluster_name=${cluster_name}  cloudlet_name=${cloudlet_name_azure}  operator_name=${operator_name_azure}
    Log To Console  Done Creating Cluster Instance
