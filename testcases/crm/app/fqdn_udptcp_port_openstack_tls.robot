*** Settings ***
Documentation  use FQDN to access TLS app on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  String
Library  OperatingSystem
Library  Process

Test Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack_shared}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

${region}=  EU

${test_timeout_crm}  15 min
	
*** Test Cases ***
# ECQ-2252
User shall be able to access TCP and HTTP TLS ports with cluster=k8s/shared and app=k8s/lb
   [Documentation]
   ...  deploy k8s/shared clusterinst 
   ...  deploy k8s/lb app with 2 TCP TLS and 1 HTTP TLS port and UDP non-TLS port
   ...  verify all ports are accessible via fqdn

   #EDGECLOUD-2796 unable to terminate https tls connections

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessShared  number_masters=1  number_nodes=1 
   Log To Console  Done Creating Cluster Instance

   ${cluster_name_default}=  Get Default Cluster Name
   ${app_name_default}=  Get Default App Name

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016:tls,tcp:8085:tls,udp:2016  deployment=kubernetes  image_type=ImageTypeDocker  access_type=loadbalancer 
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
   
   Register Client
   ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_2}=  Catenate  SEPARATOR=   ${cloudlet.ports[3].fqdn_prefix}  ${cloudlet.fqdn}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  tls=${True}
   TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}  tls=${True}

   UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[3].public_port}

   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}  tls=${True}

   Verify Ssl Certificate  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   Verify Ssl Certificate  ${fqdn_1}  ${cloudlet.ports[1].public_port}
   Verify Ssl Certificate  ${cloudlet.fqdn}  ${cloudlet.ports[2].public_port}


# ECQ-2253
User shall be able to access TCP and HTTP TLS ports with cluster=k8s/dedicated and app=k8s/lb
   [Documentation]
   ...  deploy k8s/dedicated clusterinst
   ...  deploy k8s/lb app with 2 TCP TLS and 1 HTTP TlS port and UDP non-TLS port
   ...  verify all ports are accessible via fqdn

   #EDGECLOUD-2796 unable to terminate https tls connections
   #EDGECLOUD-2794 envoy not starting for docker dedicated with tls

   Log To Console  Creating Cluster Instance
   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  deployment=kubernetes  ip_access=IpAccessDedicated  number_masters=1  number_nodes=0
   Log To Console  Done Creating Cluster Instance

   ${cluster_name_default}=  Get Default Cluster Name
   ${app_name_default}=  Get Default App Name

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016:tls,tcp:8085:tls,udp:2016  image_type=ImageTypeDocker  access_type=loadbalancer
   #Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015:tls,tcp:2016:tls,http:8085:tls,udp:2016  image_type=ImageTypeDocker  access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

   Register Client
   ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_2}=  Catenate  SEPARATOR=   ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  tls=${True}
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].end_port}     tls=${True}
   #TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[1].public_port}  tls=${True}

   UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}

   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}  tls=${True}

   Verify Ssl Certificate  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   Verify Ssl Certificate  ${fqdn_0}  ${cloudlet.ports[0].end_port}
   Verify Ssl Certificate  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}
 
# ECQ-2254
User shall be able to access TCP TLS ports with cluster=docker/dedicated and app=docker/loadbalancer 
   [Documentation]
   ...  deploy docker/dedicated clusterinst
   ...  deploy docker/lb app with 2 TCP TLS port with 1 for HTTP access
   ...  verify all ports are accessible via fqdn

   ${cluster_name_default}=  Get Default Cluster Name
   ${app_name_default}=  Get Default App Name

   #EDGECLOUD-2794 envoy not starting for docker dedicated with tls
   #EDGECLOUD-2796 unable to terminate https tls connections
   # EDGECLOUD-3192 - TLS connections not working with port ranges

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker

   #Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016:tls,tcp:2015:tls,tcp:8085:tls,udp:2016  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer 
   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016:tls,tcp:8085:tls,udp:2016  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer

   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

   Register Client
   ${cloudlet}=  Find Cloudlet        latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_2}=  Catenate  SEPARATOR=   ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}

   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  tls=${True}
   TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[0].end_port}  tls=${True}

   UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}

   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}  tls=${True}

   Verify Ssl Certificate  ${fqdn_0}  ${cloudlet.ports[0].public_port}
   Verify Ssl Certificate  ${fqdn_1}  ${cloudlet.ports[0].end_port}
   Verify Ssl Certificate  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}

# direct not supported
# ECQ-2255
#User shall be able to access TCP TLS ports with cluster=docker/dedicated and app=docker/direct
#   [Documentation]
#   ...  deploy docker/dedicated clusterinst
#   ...  deploy docker/lb app with 2 TCP TLS port with 1 for HTTP access
#   ...  verify all ports are accessible via fqdn
#
#   ${cluster_name_default}=  Get Default Cluster Name
#   ${app_name_default}=  Get Default App Name
#
#   #EDGECLOUD-2794 envoy not starting for docker dedicated with tls
#   #EDGECLOUD-2796 unable to terminate https tls connections
#   # EDGECLOUD-3192 - TLS connections not working with port ranges
#
#   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_dedicated}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker
#
#   #Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016:tls,tcp:2015:tls,tcp:8085:tls,udp:2016  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
#   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2015-2016:tls,tcp:8085:tls,udp:2016  image_type=ImageTypeDocker  deployment=docker  access_type=direct
#
#   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}
#
#   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
#
#   Register Client
#   ${cloudlet}=  Find Cloudlet        latitude=${latitude}  longitude=${longitude}
#   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
#   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
#   ${page}=    Catenate  SEPARATOR=   /  ${http_page}
#   ${fqdn_2}=  Catenate  SEPARATOR=   ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}
#
#   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  tls=${True}
#   TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[0].end_port}  tls=${True}
#
#   UDP Port Should Be Alive  ${fqdn_2}  ${cloudlet.ports[2].public_port}
#
#   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[1].public_port}  ${page}  tls=${True}

# ECQ-2256 
User shall be able to access TCP TLS ports with cluster=docker/shared and app=docker/loadbalancer
   [Documentation]
   ...  deploy docker/shared clusterinst
   ...  deploy docker/lb app with 2 TCP TLS port with 1 for HTTP access
   ...  verify all ports are accessible via fqdn

   ${cluster_name_default}=  Get Default Cluster Name
   ${app_name_default}=  Get Default App Name

   #EDGECLOUD-2794 envoy not starting for docker dedicated with tls

   Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker

   Create App  region=${region}  image_path=${docker_image}  access_ports=tcp:2016:tls,tcp:2015,udp:2015,tcp:8085  image_type=ImageTypeDocker  deployment=docker  access_type=loadbalancer
   Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_shared}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

   Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

   Register Client
   ${cloudlet}=  Find Cloudlet        latitude=${latitude}  longitude=${longitude}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
   ${fqdn_2}=  Catenate  SEPARATOR=   ${cloudlet.ports[2].fqdn_prefix}  ${cloudlet.fqdn}

   #TCP Port Should Be Alive   cluster1589497241-27719.automationparadisecloudlet.gddt.mobiledgex.net  2016  #tls=${True}
   # add 2 tcp ports
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  tls=${True}
   TCP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}  tls=${False}

   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[2].public_port}

   HTTP Port Should Be Alive  ${cloudlet.fqdn}  ${cloudlet.ports[3].public_port}  #tls=${False}

   Verify Ssl Certificate  ${fqdn_0}  ${cloudlet.ports[0].public_port}

# ECQ-2257
User shall be able to access TCP TLS ports with VM/LB deployment 
    [Documentation]
    ...  - deploy VM app with a Load Balancer on CRM with UDP and  TCP TLS port 
    ...  - verify all ports are accessible via fqdn

    # EDGECLOUD-3226 TLS connections not working for VM behind a loadbalancer

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    ${time}=  Get Time  epoch
    Create Flavor  region=${region}  flavor_name=flavor${time}1  disk=80

    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016:tls,tcp:2015,udp:2015,tcp:8085   access_type=loadbalancer    region=${region}   #default_flavor_name=${cluster_flavor_name}
    ${app_inst}=  Create App Instance  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  cluster_instance_name=dummycluster  region=${region}   #autocluster_ip_access=IpAccessDedicated

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}  tls=${True}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    Verify Ssl Certificate  ${fqdn_0}  ${cloudlet.ports[0].public_port}

*** Keywords ***
Setup
    ${time}=  Get Time  epoch
    Create Flavor  region=${region}  flavor_name=flavor${time}
    
    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}

Verify Ssl Certificate
    [Arguments]  ${fqdn}  ${public_port}

    ${URL}=  Catenate  SEPARATOR=:  ${fqdn}  ${public_port}
    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    Run Process   curl -v https://${URL}/ --cacert letsencrypt-stg-root-x1.pem --max-time 10   shell=True  stdout=${outfile}  stderr=STDOUT
    ${output}=  Get File  ${outfile}
    Log To Console  ${output}
    Should Contain  ${output}  SSL certificate verify ok
