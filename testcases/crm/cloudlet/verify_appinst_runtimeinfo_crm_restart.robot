*** Settings ***
Documentation  CRM restart test

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexApp
Library  String
Library  Collections
     
Test Setup  Setup
Test Teardown  Cleanup Provisioning

Test Timeout    ${test_timeout_crm1}

*** Variables ***
${region}=  US
${developer}=  mobiledgex

${operator_name_openstack_packet}  packet
${physical_name_openstack_packet}  packet

${username}=   mextester06
${password}=   ${mextester06_gmail_password}

*** Test Cases ***
# ECQ-3398
AppInst show displays runtimeinfo after CRM restart
   [Documentation]
   ...  - Create a Cloudlet
   ...  - Create a Docker App Inst on reservable autocluster
   ...  - AppInst show displays runtimeinfo
   ...  - Restart CRM server
   ...  - Verify that AppInst show displays runtimeinfo

   ${cloudlet1}=  Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  token=${tokenop}

   Create App  region=${region}   app_name=${app_name}  developer_org_name=${developer_org_name_automation}  deployment=docker  image_type=ImageTypeDocker  image_path=${docker_image}  access_ports=tcp:2015,udp:2016  token=${tokendev}
   ${app_inst}=  Create App Instance  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app_name}  token=${tokendev} 

   Dictionary Should Contain Key  ${app_inst['data']}  runtime_info
   ${stdout_id}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  cluster_instance_developer_org_name=MobiledgeX  token=${tokendev}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=whoami

   Should Be Equal  ${stdout_id}  root\r\n

   ${cloudlet_info}=  Show Cloudlet Info   region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokenop}
   ${crm_ip}=  Set Variable  ${cloudlet_info[0]['data']['resources_snapshot']['platform_vms'][0]['ipaddresses'][0]['externalIp']}
   Stop Crm Docker Container  crm_ip=${crm_ip}
   Start Crm Docker Container  crm_ip=${crm_ip}

   FOR  ${x}  IN RANGE  0  15
       ${cloudlet_info}=  Show Cloudlet Info   region=${region}  operator_org_name=${operator_name_openstack_packet}  cloudlet_name=${cloudlet_name}  token=${tokenop}
       Exit For Loop If  '${cloudlet_info[0]['data']['state']}' == 2
       Sleep  10s
   END
   Should Be Equal As Numbers  ${cloudlet_info[0]['data']['state']}  2

   ${app_inst1}=  Show App Instances  region=${region}  developer_org_name=${developer_org_name_automation}  cloudlet_name=${cloudlet_name}  operator_org_name=${operator_name_openstack_packet}  cluster_instance_name=autocluster${app_name}  token=${tokendev}

   Dictionary Should Contain Key  ${app_inst1[0]['data']}  runtime_info
   ${stdout_id}=  Run Command  region=${region}  app_name=${app_inst['data']['key']['app_key']['name']}  app_version=${app_inst['data']['key']['app_key']['version']}  developer_org_name=${app_inst['data']['key']['app_key']['organization']}  cluster_instance_name=${app_inst['data']['key']['cluster_inst_key']['cluster_key']['name']}  operator_org_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['organization']}  cloudlet_name=${app_inst['data']['key']['cluster_inst_key']['cloudlet_key']['name']}  cluster_instance_developer_org_name=MobiledgeX  token=${tokendev}  container_id=${app_inst['data']['runtime_info']['container_ids'][0]}  command=whoami

   Should Be Equal  ${stdout_id}  root\r\n
 
*** Keywords ***
Setup
   ${token}=  Get Super Token
   Set Suite Variable  ${token}

   ${cloudlet_name}=  Get Default Cloudlet Name
   ${app_name}=  Get Default App Name

   Create Flavor  region=${region}

   ${epoch}=  Get Time  epoch
   ${usernameop_epoch}=  Catenate  SEPARATOR=  ${username}  op  ${epoch}
   ${emailop}=  Catenate  SEPARATOR=  ${username}  op  +  ${epoch}  @gmail.com

   Skip Verify Email
   Create User  username=${usernameop_epoch}  password=${password}  email_address=${emailop}
   Unlock User

   Adduser Role  username=${usernameop_epoch}  orgname=${operator_name_openstack_packet}  role=OperatorManager  

   ${tokenop}=  Login  username=${usernameop_epoch}  password=${password}
   ${tokendev}=  Login  username=dev_contributor_automation  password=${dev_contributor_password_automation}

   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${app_name}
   Set Suite Variable  ${tokenop}
   Set Suite Variable  ${tokendev}


