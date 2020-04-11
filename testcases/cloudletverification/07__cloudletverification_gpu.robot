*** Settings ***
Documentation  Cluster Creation 

Library         MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_DEDICATED_ENV}
Library  String
	
Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout     ${test_timeout} 
	
*** Variables ***
${cloudlet_name_openstack}  automationBonnCloudlet
${operator_name_openstack}  TDG 
${mobiledgex_domain}  mobiledgex.net
${cluster_name}  cluster

${test_timeout_crm}  32 min

${region}=  EU
	
*** Test Cases ***
ClusterInst shall create with IpAccessDedicated/docker and GPU on openstack
   [Documentation]
   ...  create a gpu cluster on openstack with IpAccessDedicated and deploymenttype=docker
   ...  verify it creates vm with gpu flavor
   [Tags]  cluster  docker  dedicated  gpu  create

   Create App  region=${region}  app_name=${app_name_dockerdedicatedgpu}  image_path=${docker_image_gpu}         access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=docker

   Log to Console  \nCreating GPU docker dedicated IP cluster instance

   ${cluster_name_dockerdedicatedgpu_starttime}=  Get Time  epoch
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_dockerdedicatedgpu}   cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker  flavor_name=${flavor_name_gpu}
   ${cluster_name_dockerdedicatedgpu_endtime}=  Get Time  epoch

   Log to Console  \nCreating GPU cluster instance done

   # verify gpu_flavor
   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_gpu}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       1  #IpAccessDedicated
   Should Be Equal             ${cluster_inst['data']['deployment']}      docker
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Should Be Equal             ${cluster_inst['data']['node_flavor']}     ${node_flavor_name_gpu}

   Set Global Variable  ${cluster_name_dockerdedicatedgpu_starttime}
   Set Global Variable  ${cluster_name_dockerdedicatedgpu_endtime}

   Log To Console  \nCreate GPU app instance for docker dedicated
   Create App Instance  region=${region}  app_name=${app_name_dockerdedicatedgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockerdedicatedgpu}
   Log To Console  \nCreate GPU app instance done

   Log To Console  \nRegistering Client and Finding Cloudlet for GPU docker dedicated
   Register Client  app_name=${app_name_dockerdedicatedgpu}
   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}

   Wait For DNS  ${cloudlet.fqdn}

   Sleep  30 s

   #${server_tester}=  Catenate  SEPARATOR=/  ${client_path}  server_tester.py
   #${image_full}=     Catenate  SEPARATOR=/  ${client_path}  ${image}

   ${epoch_time}=  Get Time  epoch
   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
   Run Process  python3  ${facedetection_server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${facedection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
   #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

   ${output}=  Get File  ${outfile}
   Log To Console  ${output}

   Should Contain  ${output}  TEST_PASS=True

ClusterInst shall create with IpAccessShared/K8s and GPU and num_masters=1 and num_nodes=1 on openstack
   [Documentation]
   ...  create a GPU cluster on openstack with IpAccessShared and deploymenttype=k8s and num_nodes=1
   ...  verify it creates 1 lb and 1 node and 1 master
   [Tags]  cluster  k8s  shared  gpu  create

   Create App  region=${region}  app_name=${app_name_k8ssharedgpu}        image_path=${docker_image_gpu}         access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=kubernetes

   Log to Console  \nCreating GPU k8s shared IP cluster instance

   ${cluster_name_k8ssharedgpu_starttime}=  Get Time  epoch
   ${cluster_inst}=  Create Cluster Instance  region=${region}  cluster_name=${cluster_name_k8ssharedgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  number_nodes=1  number_masters=1  ip_access=IpAccessShared  deployment=kubernetes  flavor_name=${flavor_name_gpu}
   ${cluster_name_k8ssharedgpu_endtime}=  Get Time  epoch

   Log to Console  \nCreating GPU cluster instance done

   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_gpu}
   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       3  #IpAccessShared
   Should Be Equal             ${cluster_inst['data']['deployment']}      kubernetes
   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
   Should Be Equal As Numbers  ${cluster_inst['data']['num_masters']}     1
   Should Be Equal As Numbers  ${cluster_inst['data']['num_nodes']}       1
   Should Be Equal             ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name}
   Should Be Equal             ${cluster_inst['data']['node_flavor']}         ${node_flavor_name_gpu}

   Set Global Variable  ${cluster_name_k8ssharedgpu_starttime}
   Set Global Variable  ${cluster_name_k8ssharedgpu_endtime}

   Log To Console  \nCreate GPU app instance for k8s shared
   Create App Instance  region=${region}  app_name=${app_name_k8sharedgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8ssharedgpu}
   Log To Console  \nCreate GPU app instance done

   Log To Console  \nRegistering Client and Finding Cloudlet for GPU k8s shared
   Register Client  app_name=${app_name_k8ssharedgpu}
   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}

   Wait For DNS  ${cloudlet.fqdn}

   Sleep  30 s

   ${epoch_time}=  Get Time  epoch
   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
   Run Process  python3  ${facedetection_server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${facedection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
   #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

   ${output}=  Get File  ${outfile}
   Log To Console  ${output}

   Should Contain  ${output}  TEST_PASS=True

#User shall be able to deploy GPU App Instance on docker dedicated
#   [Documentation]
#   ...  deploy app instance on IpAccessDedicated docker with TCP/UDP/HTTP port
#   ...  Verify deployment is successfull
#   [Tags]  app  docker  dedicated  appinst  gpu
#
#   Log To Console  \nCreate GPU app instance for docker dedicated
#
#   Create App Instance  region=${region}  app_name=${app_name_dockerdedicatedgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_dockerdedicatedgpu}
#
#   Log To Console  \nCreate GPU app instance done

#User shall be able to deploy GPU App Instance on k8s shared 
#   [Documentation]
#   ...  deploy app instance on IpAccessDedicated docker with TCP/UDP/HTTP port
#   ...  Verify deployment is successfull
#   [Tags]  app  k8s  shared  appinst  gpu
#
#   Log To Console  \nCreate GPU app instance for k8s shared 
#
#   Create App Instance  region=${region}  app_name=${app_name_k8sharedgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_k8ssharedgpu}
#
#   Log To Console  \nCreate GPU app instance done

User shall be able to deploy a GPU VM App Instance
   [Documentation]
   ...  deploy a VM app instance with TCP/UDP/HTTP port
   ...  Verify deployment is successfull
   [Tags]  app  vm  appinst  gpu

   Create App  region=${region}  app_name=${app_name_vm_gpu}              image_path=${qcow_gpu_ubuntu16_image}  access_ports=tcp:8008,tcp:8011  image_type=ImageTypeQCOW    deployment=vm

   Log To Console  \nCreate GPU VM app instance

   ${vmgpu_starttime}=  Get Time  epoch
   Create App Instance  region=${region}  app_name=${app_name_vmgpu}  cloudlet_name=${cloudlet_name_openstack}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_vmgpu}
   ${vmgpu_endtime}=  Get Time  epoch

   Log To Console  \nCreate GPU app instance done

   Set Global Variable  ${vmgpu_starttime}
   Set Global Variable  ${vmgpu_endtime}

   Log To Console  \nRegistering Client and Finding Cloudlet for GPU VM
   Register Client  app_name=${app_name_vmgpu}
   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}

   Wait For DNS  ${cloudlet.fqdn}

   Sleep  30 s

   ${epoch_time}=  Get Time  epoch
   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
   Run Process  python3  ${facedetection_server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${facedection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
   #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

   ${output}=  Get File  ${outfile}
   Log To Console  ${output}

   Should Contain  ${output}  TEST_PASS=True

#User shall be able to access the GPU on docker dedicated
#   [Documentation]
#   ...  deploy app with 1 UDP port
#   ...  verify the port as accessible via fqdn
#   [Tags]  app  docker  dedicated  gpu  gpuaccess
#
#   Log To Console  \nRegistering Client and Finding Cloudlet for GPU docker dedicated
#   Register Client  app_name=${app_name_dockerdedicatedgpu}
#   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
#   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
#   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
#   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}
#
#   Wait For DNS  ${cloudlet.fqdn}
#
#   Sleep  30 s
#
#   #${server_tester}=  Catenate  SEPARATOR=/  ${client_path}  server_tester.py
#   #${image_full}=     Catenate  SEPARATOR=/  ${client_path}  ${image}
#
#   ${epoch_time}=  Get Time  epoch
#   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}
#
#   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
#   Run Process  python3  ${facedetection_server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${facedection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
#   #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
#
#   ${output}=  Get File  ${outfile}
#   Log To Console  ${output}
#
#   Should Contain  ${output}  TEST_PASS=True

#User shall be able to access the GPU on k8s shared 
#   [Documentation]
#   ...  deploy app with 1 UDP port
#   ...  verify the port as accessible via fqdn
#   [Tags]  app  k8s  shared  gpu  gpuaccess
#
#   Log To Console  \nRegistering Client and Finding Cloudlet for GPU k8s shared 
#   Register Client  app_name=${app_name_k8ssharedgpu}
#   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
#   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
#   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
#   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}
#
#   Wait For DNS  ${cloudlet.fqdn}
#
#   Sleep  30 s
#
#   ${epoch_time}=  Get Time  epoch
#   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}
#
#   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
#   Run Process  python3  ${facedetection_server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${facedection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
#   #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
#
#   ${output}=  Get File  ${outfile}
#   Log To Console  ${output}
#
#   Should Contain  ${output}  TEST_PASS=True

#User shall be able to access the GPU on VM
#   [Documentation]
#   ...  deploy app with 1 UDP port
#   ...  verify the port as accessible via fqdn
#   [Tags]  app  vm  gpu  gpuaccess
#
#   Log To Console  \nRegistering Client and Finding Cloudlet for GPU VM 
#   Register Client  app_name=${app_name_vmgpu}
#   ${cloudlet}=  Find Cloudlet   latitude=${cloudlet_latitude}  longitude=${cloudlet_longitude}  carrier_name=${operator_name_openstack}
#   ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet['ports'][0]['fqdn_prefix']}  ${cloudlet['fqdn']}
#   ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet['ports'][1]['fqdn_prefix']}  ${cloudlet['fqdn']}
#   ${page}=    Catenate  SEPARATOR=/  ${cloudlet['ports'][0]['path_prefix']}  ${http_page}
#
#   Wait For DNS  ${cloudlet.fqdn}
#
#   Sleep  30 s
#
#   ${epoch_time}=  Get Time  epoch
#   ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}
#
#   # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
#   Run Process  python3  ${facedetection_server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${facedection_image}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
#   #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
#
#   ${output}=  Get File  ${outfile}
#   Log To Console  ${output}
#
#   Should Contain  ${output}  TEST_PASS=True

*** Keywords ***
Setup
   #${flavor_name}=   Get Default Flavor Name
   #Set Suite Variable  ${flavor_name}

#   Create App  region=${region}  app_name=${app_name_dockerdedicatedgpu}  image_path=${docker_image_gpu}         access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=docker
#   Create App  region=${region}  app_name=${app_name_k8ssharedgpu}        image_path=${docker_image_gpu}         access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=kubernetes
#   Create App  region=${region}  app_name=${app_name_vm_gpu}              image_path=${qcow_gpu_ubuntu16_image}  access_ports=tcp:8008,tcp:8011  image_type=ImageTypeQCOW    deployment=vm 

