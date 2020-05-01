*** Settings ***
Documentation   Create Dedicated K8s Cluster and Run Performance Test between PODs

Library         MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library		    MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}  root_cert=%{AUTOMATION_MC_CERT}
Library         String
Library         SSHLibrary  10 Seconds
Library         OperatingSystem

Test Setup      Setup
#Suite Setup     Open Connection And Log In
Suite Teardown   Cleanup provisioning

Test Timeout     15 minutes



*** Variables ***
${cloudlet_name_openstack_dedicated}  automationParadiseCloudlet
${operator_name_openstack}  GDDT
${mobiledgex_domain}  mobiledgex.net
${region}  EU
${flavor}  automation_api_flavor
#${rootlb}  SEPARATOR=.  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}
#${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_openstack_shared}  ${operator_name_openstack}  ${mobiledgex_domain}

${test_timeout_crm}  15 min

*** Test Cases ***

ClusterInst shall create with IpAccessDedicated/k8s and num_masters=1 and num_nodes=2 on openstack
   [Documentation]
   ...  create a cluster on openstack with IpAccessDedicated and kubernetes and masters=1 and num_nodes=2
   ...  verify it creates 1 lb and 2 nodes and 1 master

     ${cluster_name}=  Get Default Cluster Name

   ${clusterlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${rootlb}

   Log to Console  START creating cluster instance
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  number_nodes=2  number_masters=1  ip_access=IpAccessDedicated  deployment=kubernetes  flavor_name=${flavor}
   Log to Console  DONE creating cluster instance


SSH to RootLB VM

  [Documentation]
  ...  SSH to RootLB VM
  ...  Copy Performance Repository from Github and measture bandwidth between master and worker nodes

   Open Connection And Log In

   ${stdout}  ${stderr}=  Execute Command   git clone https://github.com/ashutoshbhatt1/k8sperf.git  return_stderr=${True}  #timeout=20 Seconds
   log to console  ${stdout} ${stderr}
   SSHLibrary.Directory Should Exist  k8sperf

   write  ls -lrt  #return_stderr=${True}
   log to console  ${stdout} ${stderr}

   write  cp -r /home/ubuntu/k8sperf/* /home/ubuntu
   log to console  ${stdout} ${stderr}

   ${stdout}  ${stderr}  ${rc}=  execute command  ./run-iperf.sh  return_stderr=${True}  return_rc=${True} #timeout=20 Seconds
#   Should Be Equal As Integers	${rc}	0
   Log  ${stdout}
   Log to console  ${stdout}

   ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
   ${rootlb}=  Convert To Lowercase  ${rootlb}

*** Keywords ***
Setup

    ${cluster_name}=  Get Default Cluster Name

    ${epoch_time}=  Get Time  epoch
    ${cloudlet_lowercase}=  Convert to Lowercase  ${cloudlet_name_openstack_dedicated}

    Set Suite Variable  ${cloudlet_lowercase}
    Set Suite Variable  ${cluster_name}  #cluster1584127457-059605.automationparadisecloudlet.gddt.mobiledgex.net


    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase   ${rootlb}
    Set Suite Variable  ${rootlb}  #cluster1584127457-059605.automationparadisecloudlet.gddt.mobiledgex.net


Open Connection And Log In

   ${cert}=    Find File  id_rsa_mex
   Open Connection                 ${rootlb}
   login with public key           ubuntu   ${cert}

    Set Suite Variable  ${rootlb}
    Set Suite Variable  ${cluster_name}

    ${rootlb}=  Catenate  SEPARATOR=.  ${cluster_name}  ${cloudlet_name_openstack_dedicated}  ${operator_name_openstack}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase   ${rootlb}

