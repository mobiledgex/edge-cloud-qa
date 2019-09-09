*** Settings ***
Documentation  use FQDN to access app on openstack

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

#Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationHamburgCloudlet
${operator_name_openstack}  TDG

${docker_image}    docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
	
${test_timeout_crm}  15 min

*** Test Cases ***
RunCommand - k8s shared shall return command result on openstack
    [Documentation]
    ...  deploy k8s shared app 
    ...  verify RunCommand works 

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  deployment=kubernetes  ip_access=IpAccessShared

    Log To Console  Creating App and App Instance
    Create App  region=US  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=US  #cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout}=  Run Command  region=US  app_name=${app_inst[0]['data']['key']['app_key']['name']}  app_version=${app_inst[0]['data']['key']['app_key']['version']}  developer_name=${app_inst[0]['data']['key']['app_key']['developer_key']['name']}  cluster_instance_name=${app_inst[0]['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_name=${app_inst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name']}  cloudlet_name=${app_inst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=whoami
	
    log to console   ${stdout}

    Should Be Equal  ${stdout}  root\r\n

RunCommand - k8s dedicated shall return command result on openstack
    [Documentation]
    ...  deploy k8s dedicated app
    ...  verify RunCommand works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  deployment=kubernetes  ip_access=IpAccessDedicated

    Log To Console  Creating App and App Instance
    Create App  region=US  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=US  #cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout}=  Run Command  region=US  app_name=${app_inst[0]['data']['key']['app_key']['name']}  app_version=${app_inst[0]['data']['key']['app_key']['version']}  developer_name=${app_inst[0]['data']['key']['app_key']['developer_key']['name']}  cluster_instance_name=${app_inst[0]['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_name=${app_inst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name']}  cloudlet_name=${app_inst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=whoami

    log to console   ${stdout}

    Should Be Equal  ${stdout}  root\r\n

RunCommand - docker shall return command result on openstack
    [Documentation]
    ...  deploy docker app
    ...  verify RunCommand works

    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  deployment=docker  ip_access=IpAccessDedicated

    Log To Console  Creating App and App Instance
    Create App  region=US  image_path=${docker_image}  access_ports=udp:2015  command=${docker_command}  deployment=docker  #default_flavor_name=${cluster_flavor_name}  developer_name=${developer_name}
    ${app_inst}=  Create App Instance  region=US  #cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  #cluster_instance_name=${cluster_name_default}  developer_name=${developer_name}  cluster_instance_developer_name=${developer_name}

    log to console  ${app_inst}
    ${token}=  Login

    ${stdout}=  Run Command  region=US  app_name=${app_inst[0]['data']['key']['app_key']['name']}  app_version=${app_inst[0]['data']['key']['app_key']['version']}  developer_name=${app_inst[0]['data']['key']['app_key']['developer_key']['name']}  cluster_instance_name=${app_inst[0]['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_name=${app_inst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name']}  cloudlet_name=${app_inst[0]['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  token=${token}  command=whoami

    log to console   ${stdout}

    Should Be Equal  ${stdout}  root\r\n

*** Keywords ***
Setup
    #Create Developer
    #Create Flavor
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name_openstack}  flavor_name=${cluster_flavor_name}  #deployment=kubernetes  ip_access=IpAccessShared
    #Create Cluster Instance  region=US  cloudlet_name=${cloudlet_name}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}

    Log To Console  Done Creating Cluster Instance

    #${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack}  ${operator_name_openstack}  ${mobiledgex_domain}
    #${rootlb}=  Convert To Lowercase  ${rootlb}

    #Set Suite Variable  ${rootlb}
