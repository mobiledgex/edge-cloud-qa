*** Settings ***
Documentation  Create an app instance on CRM with a dot in the appname

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

#Variables       shared_variables.py

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationBonnCloudlet
${operator_name_openstack}  TDG

${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex-qa.net

#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/server_ping_threaded:4.0
${docker_command}  ./server_ping_threaded.py

${test_timeout_crm}  15 min

${region}=  US
	
*** Test Cases ***
# ECQ-1137
User shall be able to create an app instance on CRM with a dot in the app name
    [Documentation]
    ...  - create an app instance on CRM with a dot in the app name. Such as 'my.app'
    ...  - verify the app is create with the dot removed. Such as 'myapp'

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=.  app  ${epoch_time}

    ${cluster_name_default}=  Get Default Cluster Name

    Log To Console  Creating App and App Instance
    Create App  region=${region}  app_name=${app_name}  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  #   default_flavor_name=flavor1550592128-673488   cluster_name=cl1550691984-633559 
    ${appInst}=  Create App Instance  region=${region}  app_name=${app_name}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default} 
    #${version}=  Set Variable  ${appInst.key.app_key.version}
    #${version}=  Remove String  ${version}  .

    Wait For App Instance Health Check OK  region=${region}

    Log To Console  Registering Client and Finding Cloudlet
    Register Client  app_name=${app_name}
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
    #${app_name_nodot}=    Catenate  SEPARATOR=  app  ${epoch_time}  ${version}  -udp.

    # verify dot is gone
    #Should Be Equal     ${app_name_nodot}  ${cloudlet.ports[0].fqdn_prefix}
    Should Be Equal      ${cloudlet.fqdn}   ${fqdn}

    #Log To Console  Waiting for k8s pod to be running
    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name_default}  operator_name=${operator_name_openstack}  pod_name=${app_name}

*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}-${operator_name_crm}  ${region}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}
    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        ${cluster}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  #flavor_name=${cluster_flavor_name}
        Log To Console  Done Creating Cluster Instance
        ${fqdn}=  Set Variable  shared.${rootlb}
    ELSE
        ${fqdn}=  Convert To Lowercase  shared.${cloudlet_name_crm}-${operator_name_crm}.${region}.${mobiledgex_domain}
    END

    Set Suite Variable  ${rootlb}
    Set Suite Variable  ${fqdn}
