*** Settings ***
Documentation  Create same Cluster/AppInst twice

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Teardown

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationBonnCloudlet
${operator_name_openstack}  TDG

${latitude}=  1
${longitude}=  1 
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
	
${test_timeout_crm}  15 min

${region}=  EU
	
*** Test Cases ***
# ECQ-2884
CreateAppInst - User shall be able to create same cluster/appinst twice
    [Documentation]
    ...  - deploy IpAccessDedicated k8s cluster/appInst and verify health check is OK
    ...  - delete and readd the cluster/appinst 
    ...  - verify health check is still OK

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name
   
    Create App           region=${region}  image_path=${docker_image}  access_ports=tcp:2016,tcp:2015  allow_serverless=${allow_serverless}

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance
        Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1  auto_delete=${False}
        Log To Console  Done Creating Cluster Instance
    END

    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}  auto_delete=${False}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    Delete App Instance  region=${region}
    Delete Cluster Instance  region=${region}

    IF  '${platform_type}' != 'K8SBareMetal'
        Log To Console  Creating Cluster Instance again
        Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=1
        Log To Console  Done Creating Cluster Instance again
    END

    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet2}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_02}=  Catenate  SEPARATOR=   ${cloudlet2.ports[0].fqdn_prefix}  ${cloudlet2.fqdn}
    ${fqdn_12}=  Catenate  SEPARATOR=   ${cloudlet2.ports[1].fqdn_prefix}  ${cloudlet2.fqdn}

    TCP Port Should Be Alive  ${fqdn_02}  ${cloudlet2.ports[0].public_port}
    TCP Port Should Be Alive  ${fqdn_12}  ${cloudlet2.ports[1].public_port}

*** Keywords ***
Setup
    Create Flavor  region=${region}

    ${platform_type}  Get Cloudlet Platform Type  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}

    IF  '${platform_type}' == 'K8SBareMetal'
        ${allow_serverless}=  Set Variable  ${True}
    ELSE
        ${allow_serverless}=  Set Variable  ${None}
    END
    Set Suite Variable  ${platform_type}
    Set Suite Variable  ${allow_serverless}

Teardown
    Cleanup provisioning
