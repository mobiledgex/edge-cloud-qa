*** Settings ***
Documentation  RunCommand

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  auto_login=${False}

Suite Setup      Setup

Test Timeout    ${test_timeout} 
	
*** Variables ***
${cloudlet_name}  automationSunnydaleCloudlet
${operator_name}  GDDT

${region}  EU

${app_version}=  1.0
${developer_organization_name}=  mobiledgex


*** Test Cases ***
User shall be able to do RunCommand k8s shared lb app
   [Documentation]
   ...  do RunCommand on k8s shared app 
   ...  verify RunCommand works 
   [Tags]  k8s  shared  loadbalancer  runcommand

   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_k8ssharedlb}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_k8ssharedlb}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}  command=whoami

   Should Be Equal  ${stdout_noid}  root\r\n

User shall be able to do RunCommand on k8s dedicated lb app
   [Documentation]
   ...  do RunCommand on k8s dedicated app
   ...  verify RunCommand works
   [Tags]  k8s  dedicated  loadbalancer  runcommand

   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_k8sdedicatedlb}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_k8sdedicatedlb}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}  command=whoami

   Should Be Equal  ${stdout_noid}  root\r\n

#not suppported 02-20-2021
#User shall be able to do RunCommand on docker dedicated/direct
#   [Documentation]
#   ...  do RunCommand on docker dedicated app
#   ...  verify RunCommand works
#   [Tags]  docker  dedicated  direct  runcommand
#
#   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_dockerdedicateddirect}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_dockerdedicateddirect}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}  command=whoami
#
#   Should Be Equal  ${stdout_noid}  root\r\n

User shall be able to do RunCommand on docker dedicated/lb
   [Documentation]
   ...  do RunCommand on docker loadbalancer app
   ...  verify RunCommand works
   [Tags]  docker  dedicated  loadbalancer  runcommand

   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_dockerdedicatedlb}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_dockerdedicatedlb}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}  command=whoami

   Should Be Equal  ${stdout_noid}  root\r\n

User shall be able to do RunCommand on docker shared/lb
   [Documentation]
   ...  do RunCommand on docker shared app
   ...  verify RunCommand works
   [Tags]  docker  shared  loadbalancer  runcommand

   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_dockersharedlb}  app_version=${app_version}  developer_org_name=${developer_organization_name}  cluster_instance_name=${cluster_name_dockersharedlb}  operator_org_name=${operator_name}  cloudlet_name=${cloudlet_name}  token=${token}  command=whoami

   Should Be Equal  ${stdout_noid}  root\r\n

*** Keywords ***
Setup
   ${token}=  Login  username=${username_developer}  password=${password_developer}

   Set Suite Variable  ${token}   
