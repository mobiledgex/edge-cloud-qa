*** Settings ***
Documentation  ShowLogs 

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  auto_login=${False}
Library  Collections

Suite Setup      Setup

Test Timeout    ${test_timeout} 
	
*** Variables ***
${cloudlet_name}  automationSunnydaleCloudlet
${operator_name}  GDDT

${region}  EU

${app_version}=  1.0
${developer_organization_name}=  mobiledgex


*** Test Cases ***
User shall be able to do ShowLogs k8s shared lb app
   [Documentation]
   ...  do ShowLogs on k8s shared app 
   ...  verify ShowLogs works 
   [Tags]  k8s  shared  loadbalancer  showlogs

   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_k8ssharedlb}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_k8ssharedlb}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token} 

#   List Should Contain Value  ${stdout_noid}  all threads started\r\n
   Should Contain  ${stdout_noid}  all threads started

User shall be able to do ShowLogs on k8s dedicated lb app
   [Documentation]
   ...  do ShowLogs on k8s dedicated app
   ...  verify ShowLogs works
   [Tags]  k8s  dedicated  loadbalancer  showlogs

   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_k8sdedicatedlb}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_k8sdedicatedlb}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}

#   List Should Contain Value  ${stdout_noid}  all threads started\r\n
   Should Contain  ${stdout_noid}  all threads started

#Test no longer supported for direct access
#User shall be able to do ShowLogs on docker dedicated/direct
#   [Documentation]
#   ...  do ShowLogs on docker dedicated app
#   ...  verify ShowLogs works
#   [Tags]  docker  dedicated  direct  showlogs
#
#   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name_dockerdedicateddirect}
#   ${ids}=  Get Matches  ${appinst[0]['data']['runtime_info']['container_ids']}  ${app_name_dockerdedicateddirect}*
#
#   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_dockerdedicateddirect}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_dockerdedicateddirect}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}  container_id=${ids[0]}
#
#   List Should Contain Value  ${stdout_noid}  all threads started\r\n
#   Should Contain  ${stdout_noid}  all threads started

User shall be able to do ShowLogs on docker dedicated/loadbalancer
   [Documentation]
   ...  do ShowLogs on docker dedicated app
   ...  verify ShowLogs works
   [Tags]  docker  dedicated  loadbalancer  showlogs

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name_dockerdedicatedlb}
   ${ids}=  Get Matches  ${appinst[0]['data']['runtime_info']['container_ids']}  ${app_name_dockerdedicatedlb}*

   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_dockerdedicatedlb}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_dockerdedicatedlb}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}  container_id=${ids[0]}

#   List Should Contain Value  ${stdout_noid}  all threads started\r\n
   Should Contain  ${stdout_noid}  all threads started

User shall be able to do ShowLogs on docker shared/lb
   [Documentation]
   ...  do ShowLogs on docker shared app
   ...  verify ShowLogs works
   [Tags]  docker  shared  loadbalancer  showlogs

   ${appinst}=  Show App Instances  region=${region}  app_name=${app_name_dockersharedlb}
   ${ids}=  Get Matches  ${appinst[0]['data']['runtime_info']['container_ids']}  ${app_name_dockersharedlb}*

   ${stdout_noid}=  Show Logs  region=${region}  app_name=${app_name_dockersharedlb}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_dockersharedlb}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}

#   List Should Contain Value  ${stdout_noid}  all threads started\r\n
   Should Contain  ${stdout_noid}  all threads started

*** Keywords ***
Setup
   ${token}=  Login  username=${username_developer}  password=${password_developer}

   Set Suite Variable  ${token}   
