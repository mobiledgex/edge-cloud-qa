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

${ntp_wait_time}=  100

*** Test Cases ***
# ECQ-2995
CreateCloudlet - User shall be able to create a cloudlet with MEX_NTP_SERVERS 
   [Documentation]
   ...  - do CreateCloudlet with MEX_NTP_SERVERS=0.us.pool.ntp.org,1.us.pool.ntp.org
   ...  - do CreateClusterInst for docker and k8s
   ...  - verify they created successfully
   ...  - verify NTP is set and synched

   Create Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  platform_type=PlatformTypeOpenstack  physical_name=${physical_name_openstack_packet}  number_dynamic_ips=254  latitude=53.551085  longitude=9.993682  env_vars=MEX_NTP_SERVERS=0.us.pool.ntp.org,1.us.pool.ntp.org

   Wait For NTP Sync  node_type=platformvm

   Wait For NTP Sync  node_type=sharedrootlb

   # create docker clusterinst
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}docker  operator_org_name=${operator_name_openstack_packet}  deployment=docker  cloudlet_name=${cloudlet_name}
   ${docker_cluster}=  Catenate  SEPARATOR=.  ${cluster_name}docker  ${cloudlet_name}  ${operator_name_openstack_packet}  mobiledgex.net

   Wait For NTP Sync  node_name=${docker_cluster}

   # create k8s clusterinst
   Create Cluster Instance  region=${region}  cluster_name=${cluster_name}k8s  operator_org_name=${operator_name_openstack_packet}  deployment=kubernetes  number_nodes=1  ip_access=IpAccessDedicated  cloudlet_name=${cloudlet_name}
   ${k8s_cluster}=  Catenate  SEPARATOR=.  ${cluster_name}k8s  ${cloudlet_name}  ${operator_name_openstack_packet}  mobiledgex.net

   Wait For NTP Sync  node_name=${k8s_cluster}

*** Keywords ***
Setup
   Create Flavor  region=${region}
   ${cluster_name}=  Get Default Cluster Name
   ${cloudlet_name}=  Get Default Cloudlet Name

   Set Suite Variable  ${cloudlet_name}
   Set Suite Variable  ${cluster_name}

Wait For NTP Sync
   [Arguments]  ${node_type}=${None}  ${node_name}=${None}

   FOR  ${i}  IN RANGE  ${ntp_wait_time}
      ${status_crm}=  Run Keyword If  '${node_type}' != '${None}'  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_type=${node_type}  command=systemctl status systemd-timesyncd | grep Status  cloudlet_name=${cloudlet_name}
      ...  ELSE  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_name=${node_name}  command=systemctl status systemd-timesyncd | grep Status  cloudlet_name=${cloudlet_name}

      ${match}=  Run Keyword And Ignore Error  Should Match Regexp  ${status_crm}  Synchronized to time server .+0\.us\.pool\.ntp\.org
      log to console  ${i} ${ntp_wait_time}   ${match[0]}
      Exit For Loop If  '${match[0]}'=='PASS'
      Sleep  10s
      
   END

   log to console  ${i} ${ntp_wait_time}
   Run Keyword If  ${i}==${ntp_wait_time}  Fail  NTP sync wait timeout 

   ${ntp_crm}=  Run Keyword If  '${node_type}' != '${None}'  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_type=${node_type}  command=grep NTP /etc/systemd/timesyncd.conf  cloudlet_name=${cloudlet_name}
   ...  ELSE  Access Cloudlet  region=${region}  operator_org_name=${operator_name_openstack_packet}  node_name=${node_name}  command=grep NTP /etc/systemd/timesyncd.conf  cloudlet_name=${cloudlet_name}
   Should Contain  ${ntp_crm}  0.us.pool.ntp.org
   Should Contain  ${ntp_crm}  1.us.pool.ntp.org


