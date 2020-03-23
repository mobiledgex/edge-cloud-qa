*** Settings ***
Documentation  RunCommand

Library	 MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}

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
User shall be able to do RunCommand k8s shared
   [Documentation]
   ...  do RunCommand on k8s shared app 
   ...  verify RunCommand works 
   [Tags]  k8s  shared  runcommand

   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_k8sshared}  app_version=${app_version}  developer_org_name=${developer}  cluster_instance_name=${cluster_name_k8sshared}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${token}  command=whoami

   Should Be Equal  ${stdout_noid[-1]}  root\r\n

User shall be able to do RunCommand on k8s dedicated
   [Documentation]
   ...  do RunCommand on k8s dedicated app
   ...  verify RunCommand works
   [Tags]  k8s  dedicated  runcommand

   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_k8sdedicated}  app_version=${app_version}  developer_org_name=${developer}  cluster_instance_name=${cluster_name_k8sdedicated}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${token}  command=whoami

   Should Be Equal  ${stdout_noid[-1]}  root\r\n

User shall be able to do RunCommand on docker dedicated
   [Documentation]
   ...  do RunCommand on docker dedicated app
   ...  verify RunCommand works
   [Tags]  docker  dedicated  runcommand

   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_dockerdedicated}  app_version=${app_version}  developer_org_name=${developer}  cluster_instance_name=${cluster_name_dockerdedicated}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${token}  command=whoami

   Should Be Equal  ${stdout_noid[-1]}  root\r\n

User shall be able to do RunCommand on docker shared
   [Documentation]
   ...  do RunCommand on docker shared app
   ...  verify RunCommand works
   [Tags]  docker  shared  runcommand

   ${stdout_noid}=  Run Command  region=${region}  app_name=${app_name_dockershared}  app_version=${app_version}  developer_org_name=${developer}  cluster_instance_name=${cluster_name_dockershared}  operator_org_name=${operator_name_openstack}  cloudlet_name=${cloudlet_name_openstack}  token=${token}  command=whoami

   Should Be Equal  ${stdout_noid[-1]}  root\r\n

*** Keywords ***
Setup
   ${token}=  Login

   Set Suite Variable  ${token}   
