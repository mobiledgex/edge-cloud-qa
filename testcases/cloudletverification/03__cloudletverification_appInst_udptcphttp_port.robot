*** Settings ***
Documentation  use FQDN to access app on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}  auto_login=${False}
Library  MexDmeRest  dme_address=%{AUTOMATION_DME_REST_ADDRESS}  root_cert=%{AUTOMATION_DME_CERT}
Library  MexApp
Library  String
Library  Process
Library  OperatingSystem

Suite Setup      Setup
#Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout} 
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationSunnydaleCloudlet
${operator_name_openstack}  GDDT
${cloudlet_latitude}       32.7767
${cloudlet_longitude}      -96.7970

${cluster_name}  cluster

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${docker_image}    docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0
${docker_command}  ./server_ping_threaded.py
${http_page}       automation.html

${manifest_url}=  http://35.199.188.102/apps/server_ping_threaded_udptcphttp.yml
${manifest_url_sharedvolumesize}  http://35.199.188.102/apps/server_ping_threaded_udptcphttp_shared_volumemount.yml
	
${test_timeout_crm}  32 min

${region}=  EU
	
*** Test Cases ***
User shall be able to create an App on docker dedicated
   [Documentation]
   ...  create app on IpAccessDedicated docker with TCP/UDP/HTTP port
   ...  Verify app is created successfull
   [Tags]  app  docker  dedicated  app

   Create App  region=${region}  app_name=${app_name_dockerdedicated}  deployment=docker      image_path=${docker_image}       access_ports=tcp:2016,udp:2015,tcp:8085   command=${docker_command}  developer_org_name=${developer_organization_name}

User shall be able to create an App on docker shared
   [Documentation]
   ...  create app on IpAccessShared docker with TCP/UDP/HTTP port
   ...  Verify app is created successfull
   [Tags]  app  docker  shared  app

   Create App  region=${region}  app_name=${app_name_dockershared}     deployment=docker      image_path=${docker_image}       access_ports=tcp:2016,udp:2015,tcp:8085   command=${docker_command}  developer_org_name=${developer_organization_name}

User shall be able to deploy App Instance on docker dedicated
   [Documentation]
   ...  deploy app instance on IpAccessDedicated docker with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  docker  dedicated  appinst

   Log To Console  \nCreate app instance for docker dedicated 

   Create App Instance  region=${region}  app_name=${app_name_dockerdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockerdedicated}  developer_org_name=${developer_organization_name}

   Log To Console  \nCreate app instance done 

User shall be able to deploy App Instance on docker shared
   [Documentation]
   ...  deploy app instance on IpAccessShared docker with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  docker  shared  appinst

   Log To Console  \nCreate app instance for docker shared

   Create App Instance  region=${region}  app_name=${app_name_dockershared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockershared}  developer_org_name=${developer_organization_name}

   Log To Console  \nCreate app instance done

User shall be able to create an App on k8s shared
   [Documentation]
   ...  create app on k8s shared with TCP/UDP/HTTP port
   ...  Verify app is created successfull
   [Tags]  app  k8s  shared  app

   Create App  region=${region}  app_name=${app_name_k8sshared}        deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}  developer_org_name=${developer_organization_name}

User shall be able to create an App on k8s dedicated
   [Documentation]
   ...  create app on k8s dedicated with TCP/UDP/HTTP port
   ...  Verify app is created successfull
   [Tags]  app  k8s  dedicated  app

   Create App  region=${region}  app_name=${app_name_k8sdedicated}        deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}  developer_org_name=${developer_organization_name}

User shall be able to create an App on k8s shared with sharedvolumesize 
   [Documentation]
   ...  create app on k8s shared with TCP/UDP/HTTP port and sharedvolumesize
   ...  Verify app is created successfull
   [Tags]  app  k8s  shared  app  sharedvolumesize

   Create App  region=${region}  app_name=${app_name_k8ssharedvolumesize}        deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015  deployment_manifest=${manifest_url_sharedvolumesize}   developer_org_name=${developer_organization_name}

User shall be able to deploy App Instance on k8s shared 
   [Documentation]
   ...  deploy app instance on k8s shared with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  k8s  shared  appinst

   Log To Console  \nCreate app instance for k8s shared 

   Create App Instance  region=${region}  app_name=${app_name_k8sshared}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8sshared}  developer_org_name=${developer_organization_name}

   Log To Console  \nCreate app instance done

User shall be able to deploy App Instance on k8s dedicated 
   [Documentation]
   ...  deploy app instance on k8s dedicated with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  k8s  dedicated  appinst

   Log To Console  \nCreate app instance for k8s dedicated

   Create App Instance  region=${region}  app_name=${app_name_k8sdedicated}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8sdedicated}  developer_org_name=${developer_organization_name}

   Log To Console  \nCreate app instance done

User shall be able to deploy App Instance on k8s shared with sharedvolumesize
   [Documentation]
   ...  deploy app instance on k8s shared with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  k8s  shared  appinst  sharedvolumesize

   Log To Console  \nCreate app instance for k8s shared with sharedvolumesize

   Create App Instance  region=${region}  app_name=${app_name_k8ssharedvolumesize}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8ssharedvolumesize}  developer_org_name=${developer_organization_name}

   Log To Console  \nCreate app instance done

User shall be able to create a VM App
   [Documentation]
   ...  create a VM app 
   ...  Verify app is created successfull
   [Tags]  app  vm  app

   Create App  region=${region}  app_name=${app_name_vm}  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015,tcp:8085  image_type=ImageTypeQCOW  default_flavor_name=${flavor_name_vm}  developer_org_name=${developer_organization_name}

User shall be able to create a VM with cloud-config
   [Documentation]
   ...  create a VM app with cloud-config
   ...  Verify app is created successfull
   [Tags]  app  vm  app

   Create App  region=${region}  app_name=${app_name_vm_cloudconfig}  deployment=vm  image_path=${qcow_centos_image_notrunning}  access_ports=tcp:2016,udp:2015,tcp:8085  image_type=ImageTypeQCOW  default_flavor_name=${flavor_name_vm}  deployment_manifest=${vm_cloudconfig}  developer_org_name=${developer_organization_name}

User shall be able to deploy a VM App Instance
   [Documentation]
   ...  deploy a VM app instance with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  vm  appinst

   Log To Console  \nCreate VM app instance

   ${vm_starttime}=  Get Time  epoch
   Set Global Variable  ${vm_starttime}

   Create App Instance  region=${region}  app_name=${app_name_vm}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_vm}  developer_org_name=${developer_organization_name}
   ${vm_endtime}=  Get Time  epoch

   Log To Console  \nCreate app instance done

   Set Global Variable  ${vm_endtime}

User shall be able to deploy VM App Instance with cloud-config
   [Documentation]
   ...  deploy VM app on openstack with 1 UDP and 1 TCP port with cloud-config
   ...  verify all ports are accessible via fqdn
   [Tags]  app  vm  appinst

   Log To Console  \nCreate VM app instance with cloud-config

   ${vmcloudconfig_starttime}=  Get Time  epoch
   Set Global Variable  ${vmcloudconfig_starttime}

   ${app_inst}=  Create App Instance  region=${region}  app_name=${app_name_vm_cloudconfig}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_vm}  developer_org_name=${developer_organization_name}
   ${vmcloudconfig_endtime}=  Get Time  epoch

   Log To Console  \nCreate app instance done

   Set Global Variable  ${vmcloudconfig_endtime}

User shall be able to deploy GPU App Instance on docker dedicated
   [Documentation]
   ...  deploy app instance on IpAccessDedicated docker with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  docker  dedicated  appinst  gpu

   Log To Console  \nCreate GPU app instance for docker dedicated

   Create App Instance  region=${region}  app_name=${app_name_dockerdedicatedgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockerdedicatedgpu}  developer_org_name=${developer_organization_name}

   Log To Console  \nCreate GPU app instance done

User shall be able to deploy GPU App Instance on k8s shared
   [Documentation]
   ...  deploy app instance on IpAccessDedicated docker with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  k8s  shared  appinst  gpu

   Log To Console  \nCreate GPU app instance for k8s shared

   Create App Instance  region=${region}  app_name=${app_name_k8sharedgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8ssharedgpu}  developer_org_name=${developer_organization_name}

   Log To Console  \nCreate GPU app instance done

User shall be able to deploy a GPU VM App Instance
   [Documentation]
   ...  deploy a VM app instance with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  vm  appinst  gpu

   Log To Console  \nCreate GPU VM app instance

   ${vmgpu_starttime}=  Get Time  epoch
   Create App Instance  region=${region}  app_name=${app_name_vmgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_vmgpu}  developer_org_name=${developer_organization_name}
   ${vmgpu_endtime}=  Get Time  epoch

   Log To Console  \nCreate GPU app instance done

   Set Global Variable  ${vmgpu_starttime}
   Set Global Variable  ${vmgpu_endtime}

User shall be able to access UDP/TCP port on docker dedicated 
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  docker  dedicated  portaccess 

   Log To Console  \nRegistering Client and Finding Cloudlet for docker dedicated
   Register Client  app_name=${app_name_dockerdedicated}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet	 latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port ${fqdn_0}:${cloudlet['ports'][0]['public_port']} is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}

   Log To Console  \nChecking if port ${fqdn_1}:${cloudlet['ports'][1]['public_port']} is alive
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}

   Log To Console  \nChecking if port ${cloudlet['fqdn']}:${cloudlet['ports'][2]['public_port']} is alive
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

User shall be able to access UDP/TCP port on docker shared
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  docker  shared  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for docker shared
   Register Client  app_name=${app_name_dockershared}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

User shall be able to access UDP/TCP/HTTP port on k8s dedicated
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  k8s  dedicated  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for k8s dedicated
   Register Client  app_name=${app_name_k8sdedicated}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

User shall be able to access UDP/TCP/HTTP port on k8s shared 
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  k8s  shared  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for k8s shared 
   Register Client  app_name=${app_name_k8sshared}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${page}

User shall be able to access UDP/TCP/HTTP port on VM
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  vm  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for VM 
   Register Client  app_name=${app_name_vm}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}
   HTTP Port Should Be Alive  ${cloudlet['fqdn']}  ${cloudlet['ports'][2]['public_port']}  ${http_page}

User shall be able to access UDP/TCP port on VM with cloudconfig
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  vm  portaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for VM with cloudconfig
   Register Client  app_name=${app_name_vm_cloudconfig}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet  latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   #${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][2]['path_prefix']}  ${http_page}

   Log To Console  \nChecking if port is alive
   TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet['ports'][0]['public_port']}
   UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet['ports'][1]['public_port']}

User shall be able to access the GPU on docker dedicated
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  docker  dedicated  gpu  gpuaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for GPU docker dedicated
   Register Client  app_name=${app_name_dockerdedicatedgpu}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}

   #Wait For DNS  ${cloudlet['fqdn']}
   ${ip}=  Get DNS IP  ${cloudlet['fqdn']}

   Sleep  30 s

   #${server_tester}=  Catenate  SEPARATOR=/  ${client_path}  server_tester.py
   #${image_full}=     Catenate  SEPARATOR=/  ${client_path}  ${image}

   ${epoch_time}=  Get Time  epoch
   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
   Run Process  python3  ${facedetection_server_tester}   -s   ${ip}   -e  /openpose/detect/   -f   ${facedetection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
#   Run Process  python3  ${facedetection_server_tester}   -s    cluster1586639345696343dockerdedicatedgpu.verificationcloudlet.gddt.mobiledgex.net  -e  /openpose/detect/   -f   ${facedetection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

   ${output}=  Get File  ${outfile}
   Log To Console  ${output}

   Should Contain  ${output}  TEST_PASS=True

User shall be able to access the GPU on k8s shared
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  k8s  shared  gpu  gpuaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for GPU k8s shared
   Register Client  app_name=${app_name_k8ssharedgpu}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}

   Wait For DNS  ${cloudlet['fqdn']}

   Sleep  30 s

   ${epoch_time}=  Get Time  epoch
   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
   Run Process  python3  ${facedetection_server_tester}   -s   ${cloudlet['fqdn']}   -e  /openpose/detect/   -f   ${facedetection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
   #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

   ${output}=  Get File  ${outfile}
   Log To Console  ${output}

   Should Contain  ${output}  TEST_PASS=True

User shall be able to access the GPU on VM
   [Documentation]
   ...  deploy app with 1 UDP port
   ...  verify the port as accessible via fqdn
   [Tags]  app  vm  gpu  gpuaccess

   Log To Console  \nRegistering Client and Finding Cloudlet for GPU VM
   Register Client  app_name=${app_name_vmgpu}  developer_org_name=${developer_organization_name}
   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}

   Wait For DNS  ${cloudlet['fqdn']}  wait_time=1800

   Sleep  30 s

   ${epoch_time}=  Get Time  epoch
   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
   Run Process  python3  ${facedetection_server_tester}   -s   ${cloudlet['fqdn']}   -e  /openpose/detect/   -f   ${facedetection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
   #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

   ${output}=  Get File  ${outfile}
   Log To Console  ${output}

   Should Contain  ${output}  TEST_PASS=True

*** Keywords ***
Setup
   Login  username=${username_developer}  password=${password_developer}

#   Create App  region=${region}  app_name=${app_name_dockerdedicated}  deployment=docker      image_path=${docker_image}       access_ports=tcp:2016,udp:2015,tcp:8085   command=${docker_command}  developer_org_name=${developer_organization_name}
#   Create App  region=${region}  app_name=${app_name_dockershared}     deployment=docker      image_path=${docker_image}       access_ports=tcp:2016,udp:2015,tcp:8085   command=${docker_command}  developer_org_name=${developer_organization_name}
#   Create App  region=${region}  app_name=${app_name_k8sdedicated}     deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}  developer_org_name=${developer_organization_name}
#   Create App  region=${region}  app_name=${app_name_k8sshared}        deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015,http:8085  command=${docker_command}  developer_org_name=${developer_organization_name}
#   Create App  region=${region}  app_name=${app_name_k8ssharedvolumesize}        deployment=kubernetes  image_path=${docker_image}       access_ports=tcp:2016,udp:2015  deployment_manifest=${manifest_url_sharedvolumesize}   developer_org_name=${developer_organization_name}

#   Create App  region=${region}  app_name=${app_name_vm}              deployment=vm  image_path=${qcow_centos_image}             access_ports=tcp:2016,udp:2015,tcp:8085  image_type=ImageTypeQCOW  default_flavor_name=${flavor_name_vm}  developer_org_name=${developer_organization_name}
#   Create App  region=${region}  app_name=${app_name_vm_cloudconfig}  deployment=vm  image_path=${qcow_centos_image_notrunning}  access_ports=tcp:2016,udp:2015,tcp:8085  image_type=ImageTypeQCOW  default_flavor_name=${flavor_name_vm}  deployment_manifest=${vm_cloudconfig}  developer_org_name=${developer_organization_name}

#   Create App  region=${region}  app_name=${app_name_dockerdedicatedgpu}  image_path=${docker_image_gpu}         access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=docker  developer_org_name=${developer_organization_name}
#   Create App  region=${region}  app_name=${app_name_k8ssharedgpu}        image_path=${docker_image_gpu}         access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=kubernetes  developer_org_name=${developer_organization_name}
#   Create App  region=${region}  app_name=${app_name_vm_gpu}              image_path=${qcow_gpu_ubuntu16_image}  access_ports=tcp:8008,tcp:8011  image_type=ImageTypeQCOW    deployment=vm  developer_org_name=${developer_organization_name}

