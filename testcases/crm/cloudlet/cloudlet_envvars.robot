*** Settings ***
Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}

Test Timeout   25 min 

Test Setup  Setup
Test Teardown  Cleanup Provisioning

*** Variables ***
${operator_name_openstack_packet}  packet
${physical_name_openstack_packet}  packet

${region}=  US

${test_timeout_crm}  60 min

*** Test Cases ***
# ECQ-2995
CreateCloudlet - User shall be able to create a cloudlet with MEX_NTP_SERVERS 
   [Documentation]
   ...  - do CreateCloudlet with MEX_NTP_SERVERS=0.us.pool.ntp.org,1.us.pool.ntp.org
   ...  - do CreateClusterInst for docker and k8s
   ...  - verify they created successfully
   ...  - verify NTP is set and synched

   Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=MEX_NTP_SERVERS=0.us.pool.ntp.org,1.us.pool.ntp.org

   ${status_crm}=  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_type=platformvm  command=systemctl status systemd-timesyncd | grep Status  cloudlet_name=${cloudlet_name}
   Should Match Regexp  ${status_crm}  Synchronized to time server .+0\.us\.pool\.ntp\.org

   ${ntp_crm}=  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_type=platformvm  command=grep NTP /etc/systemd/timesyncd.conf  cloudlet_name=${cloudlet_name}
   Should Contain  ${ntp_crm}  0.us.pool.ntp.org
   Should Contain  ${ntp_crm}  1.us.pool.ntp.org 

   ${status_rootlb}=  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_type=sharedrootlb  command=systemctl status systemd-timesyncd | grep Status  cloudlet_name=${cloudlet_name}
   Should Match Regexp  ${status_rootlb}  Synchronized to time server .+0\.us\.pool\.ntp\.org

   ${ntp_rootlb}=  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_type=sharedrootlb  command=grep NTP /etc/systemd/timesyncd.conf  cloudlet_name=${cloudlet_name}
   Should Contain  ${ntp_rootlb}  0.us.pool.ntp.org
   Should Contain  ${ntp_rootlb}  1.us.pool.ntp.org

   # create docker clusterinst
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}docker  operator_org_name=${operator_name_openstack_packet}  deployment=docker  cloudlet_name=${cloudlet_name}
   Sleep  30s  # wait for ntp sync
   ${docker_cluster}=  Catenate  SEPARATOR=.  ${cluster_name}docker  ${cloudlet_name}  ${operator_name_openstack_packet}  mobiledgex.net
   #${docker_cluster}=  Set Variable  cluster1608656648-5467021.cloudlet1608652591-6507368.packet.mobiledgex.net
   ${status_docker}=  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_name=${docker_cluster}  command=systemctl status systemd-timesyncd | grep Status  cloudlet_name=${cloudlet_name}
   Should Match Regexp  ${status_docker}  Synchronized to time server .+0\.us\.pool\.ntp\.org
   ${ntp_docker}=  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_name=${docker_cluster}  command=grep NTP /etc/systemd/timesyncd.conf  cloudlet_name=${cloudlet_name}
   Should Contain  ${ntp_docker}  0.us.pool.ntp.org
   Should Contain  ${ntp_docker}  1.us.pool.ntp.org

   # create k8s clusterinst
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}k8s  operator_org_name=${operator_name_openstack_packet}  deployment=kubernetes  number_nodes=1  ip_access=IpAccessDedicated  cloudlet_name=${cloudlet_name}
   Sleep  30s  # wait for ntp sync
   ${k8s_cluster}=  Catenate  SEPARATOR=.  ${cluster_name}k8s  ${cloudlet_name}  ${operator_name_openstack_packet}  mobiledgex.net
   ${status_k8s}=  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_name=${k8s_cluster}  command=systemctl status systemd-timesyncd | grep Status  cloudlet_name=${cloudlet_name}
   Should Match Regexp  ${status_k8s}  Synchronized to time server .+0\.us\.pool\.ntp\.org
   ${ntp_k8s}=  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_name=${k8s_cluster}  command=grep NTP /etc/systemd/timesyncd.conf  cloudlet_name=${cloudlet_name}
   Should Contain  ${ntp_k8s}  0.us.pool.ntp.org
   Should Contain  ${ntp_k8s}  1.us.pool.ntp.org


*** Keywords ***
Setup
   Create Flavor  region=${region}
   ${cluster_name}=  Get Default Cluster Name
   ${cloudlet_name}=  Get Default Cloudlet Name

   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}
