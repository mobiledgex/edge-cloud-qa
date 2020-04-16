*** Settings ***
Documentation   Create Dedicated Docker Cluster VM and Run TCP Performance Test between PODs

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         String
Library         SSHLibrary  10 Seconds
Library         OperatingSystem

Test Setup      Setup
#Suite Setup     Open Connection And Log In
Suite Teardown  Cleanup provisioning

Test Timeout     15 minutes

*** Variables ***
${cloudlet_name_openstack_dedicated}  automationParadiseCloudlet
${operator_name_openstack}  GDDT
${mobiledgex_domain}  mobiledgex.net
${region}  EU
${flavor}  automation_api_flavor
${cluster_name_1}  dockerserver
${cluster_name_2}  dockerclient


${test_timeout_crm}  15 min

*** Test Cases ***

ClusterInst shall create with IpAccessDedicated/k8s and num_masters=1 and num_nodes=2 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and kubernetes and masters=1 and num_nodes=2
   ...  verify it creates 1 lb and 2 nodes and 1 master

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_1}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_2}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor}
   Log to Console  DONE creating cluster instance

SSH to RootLB VM

  [Documentation]
  ...  SSH to RootLB VM
  ...  Run and Start Iperf Docker Server Containter

  SSH to Iperf Server Side Docker Containter

  ${stdout}  ${stderr}  ${rc}=  Execute Command  docker run -d --rm --name=iperf3-server -p 5201:5201 networkstatic/iperf3 -s    return_stderr=${True}  return_rc=${True}
  Should Be Equal As Integers	${rc}	0

  SSH to Iperf Client Side Docker Container and Run TCP Performance Test for 30s

  ${stdout}  ${stderr}  ${rc}=  Execute Command  docker run --rm networkstatic/iperf3 -c dockerserver.automationParadiseCloudlet.GDDT.mobiledgex.net -t 30   return_stderr=${True}  return_rc=${True}
  Should Be Equal As Integers	${rc}	0
  Log  ${stdout}
  Log to console  ${stdout}

*** Keywords ***
Setup

    ${cluster_name}=  Get Default Cluster Name

    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}

    Set Suite Variable  ${cloudlet_lowercase}
    Set Suite Variable  ${cluster_name}  #cluster1584127457-059605.automationparadisecloudlet.gddt.mobiledgex.net


    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name_1}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase   ${rootlb}
    Set Suite Variable  ${rootlb}  #cluster1584127457-059605.automationparadisecloudlet.gddt.mobiledgex.net

SSH to Iperf Server Side Docker Containter

   ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name_1}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
   ${rootlb}=  Convert To Lowercase   ${rootlb}
   ${cert}=    Find File  id_rsa_mex

   Open Connection                 ${rootlb}
   login with public key           ubuntu   ${cert}

SSH to Iperf Client Side Docker Container and Run TCP Performance Test for 30s

   ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name_2}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
   ${rootlb}=  Convert To Lowercase   ${rootlb}
   ${cert}=    Find File  id_rsa_mex

   Open Connection                 ${rootlb}
   login with public key           ubuntu  ${cert}




