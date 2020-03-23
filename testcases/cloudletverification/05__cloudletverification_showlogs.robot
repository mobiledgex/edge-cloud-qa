*** Settings ***
Documentation  ShowLogs 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  Collections

Suite Setup      Setup

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cloudlet_name_openstack}  automationSunnydaleCloudlet
${operator_name_openstack}  GDDT

${region}  EU

${app_version}=  1.0
${developer}=  mobiledgex

${test_timeout_crm}  32 min

*** Test Cases ***
User shall be able to do ShowLogs k8s shared
   [Documentation]
   ...  do ShowLogs on k8s shared app 
   ...  verify ShowLogs works 
   [Tags]  k8s  shared  showlogs

   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_k8sshared}  app_version=${app_version}  developer_org_name=${developer}  cluster_instance_name=${cluster_name_k8sshared}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${token} 

   List Should Contain Value  ${stdout_noid}  all threads started\r\n

User shall be able to do ShowLogs on k8s dedicated
   [Documentation]
   ...  do ShowLogs on k8s dedicated app
   ...  verify ShowLogs works
   [Tags]  k8s  dedicated  showlogs

   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_k8sdedicated}  app_version=${app_version}  developer_org_name=${developer}  cluster_instance_name=${cluster_name_k8sdedicated}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${token}

   List Should Contain Value  ${stdout_noid}  all threads started\r\n

User shall be able to do ShowLogs on docker dedicated
   [Documentation]
   ...  do ShowLogs on docker dedicated app
   ...  verify ShowLogs works
   [Tags]  docker  dedicated  showlogs

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name_dockerdedicated}
   ${ids}=  Get Matches  ${appinst[0]['data']['runtime_info']['container_ids']}  ${app_name_dockerdedicated}*

   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_dockerdedicated}  app_version=${app_version}  developer_org_name=${developer}  cluster_instance_name=${cluster_name_dockerdedicated}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${token}  container_id=${ids[0]}

   List Should Contain Value  ${stdout_noid}  all threads started\r\n

User shall be able to do ShowLogs on docker shared
   [Documentation]
   ...  do ShowLogs on docker shared app
   ...  verify ShowLogs works
   [Tags]  docker  shared  showlogs

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name_dockershared}
   ${ids}=  Get Matches  ${appinst[0]['data']['runtime_info']['container_ids']}  ${app_name_dockershared}*

   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_dockershared}  app_version=${app_version}  developer_org_name=${developer}  cluster_instance_name=${cluster_name_dockershared}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${token}

   List Should Contain Value  ${stdout_noid}  all threads started\r\n

*** Keywords ***
Setup
   ${token}=  Login

   Set Suite Variable  ${token}   
