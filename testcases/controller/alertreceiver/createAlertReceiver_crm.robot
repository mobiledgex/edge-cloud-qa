*** Settings ***
Documentation  CreatePrivacyPolicy

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}
Library  MexApp
Library  String

#Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout  1m

*** Variables ***
${region}=  EU
${app_name}=  andyhealth 
${developer}=  MobiledgeX

${latitude}       32.7767
${longitude}      -96.7970

*** Test Cases ***
CreatePrivacyPolicy - shall be able to create with policy and developer name only
   [Documentation]
   ...  send CreatePrivacyPolicy with policy and developer name only
   ...  verify policy is created

   #${alert}=  Create Alert Receiver  region=${region}  app_name=${app_name}  developer_org_name=${developer}  

    #Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015,tcp:2016,tcp:4015  command=${docker_command}  image_type=ImageTypeDocker  deployment=docker
    #Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name}
    Register Client  app_name=${app_name}
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    ${fqdn_0}=  Catenate  SEPARATOR=  ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

    Stop TCP Port  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
    Wait For App Instance Health Check Fail  region=${region}  app_name=${app_name}  state=HealthCheckFailServerFail

