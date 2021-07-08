*** Settings ***
Documentation  GPU docker/k8s app on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
#Library	 MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_GPU_ENV}
Library  MexApp
Library  String
Library  OperatingSystem
Library  Process

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm} 
	
*** Variables ***
${region}=  EU
${gpu_resource_name}  mygpuresrouce

${cluster_flavor_name}  x1.medium

${cloudlet_name_openstack_gpu}  automationParadiseCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhawkinscloudlet.gddt.mobiledgex.net

${qcow_gpu_ubuntu16_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d

#${client_path}     ../../../edge-cloud-sampleapps/ComputerVisionServer/client
${gpu_client_path}   ../../../../edge-cloud-sampleapps/ComputerVisionServer/client
${gpu_client}        multi_client.py
${gpu_client_image}=  3_bodies.png

${docker_compose_url}=  http://35.199.188.102/apps/automation_configs_gpu_compose.yml
	
${test_timeout_crm}  15 min

*** Test Cases ***
# ECQ-2560
GPU - shall be able to deploy docker dedicated NVidia T4 Passthru GPU app on KVM Openstack
    [Documentation]
    ...  - deploy docker dedicated with GPU support on openstack
    ...  - verify app uses the GPU with ComputerVisionServer

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker
    Sleep  30  seconds
    Create App  region=${region}  image_path=${docker_image_gpu}  access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=docker  #access_type=direct
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet	 latitude=${latitude}  longitude=${longitude}

    Wait For DNS  ${cloudlet.fqdn}

    Sleep  30 s

    ${server_tester}=  Catenate  SEPARATOR=/  ${gpu_client_path}  ${gpu_client}
    ${image_full}=     Catenate  SEPARATOR=/  ${gpu_client_path}  ${gpu_client_image}

    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
    Run Process  python3  ${server_tester}   -s   ${cloudlet.fqdn}  -e   /openpose/detect/  -c  rest  -f   ${image_full}   --show-responses  stdout=${outfile}  stderr=STDOUT
    #Run Process  python3  ${server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${image_full}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
    #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

    ${output}=  Get File  ${outfile}
    Log To Console  ${output}

    Should Contain  ${output}  TEST_PASS=True 

# ECQ-2561
GPU - shall be able to deploy docker shared NVidia T4 Passthru GPU app on KVM Openstack
    [Documentation]
    ...  - deploy docker shared with GPU support on openstack
    ...  - verify app uses the GPU with ComputerVisionServer

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=docker
    Sleep  30  seconds
    Create App  region=${region}  image_path=${docker_image_gpu}  access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=docker
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    Wait For DNS  ${cloudlet.fqdn}

    Sleep  30 s

    ${server_tester}=  Catenate  SEPARATOR=/  ${gpu_client_path}  ${gpu_client}
    ${image_full}=     Catenate  SEPARATOR=/  ${gpu_client_path}  ${gpu_client_image}

    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
    Run Process  python3  ${server_tester}   -s   ${cloudlet.fqdn}  -e   /openpose/detect/  -c  rest  -f   ${image_full}   --show-responses  stdout=${outfile}  stderr=STDOUT
    #Run Process  python3  ${server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${image_full}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
    #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

    ${output}=  Get File  ${outfile}
    Log To Console  ${output}

    Should Contain  ${output}  TEST_PASS=True

# ECQ-2589
GPU - shall be able to deploy docker compose NVidia T4 Passthru GPU app on KVM Openstack
    [Documentation]
    ...  - deploy docker compose with GPU support on openstack
    ...  - verify app uses the GPU with ComputerVisionServer

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessDedicated  deployment=docker
    Sleep  30  seconds
    Create App  region=${region}  deployment_manifest=${docker_compose_url}  image_path=no_default  access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=docker  #access_type=direct
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    Wait For DNS  ${cloudlet.fqdn}

    Sleep  30 s

    ${server_tester}=  Catenate  SEPARATOR=/  ${gpu_client_path}  ${gpu_client}
    ${image_full}=     Catenate  SEPARATOR=/  ${gpu_client_path}  ${gpu_client_image}

    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
    Run Process  python3  ${server_tester}   -s   ${cloudlet.fqdn}  -e   /openpose/detect/  -c  rest  -f   ${image_full}   --show-responses  stdout=${outfile}  stderr=STDOUT
    #Run Process  python3  ${server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${image_full}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
    #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

    ${output}=  Get File  ${outfile}
    Log To Console  ${output}

    Should Contain  ${output}  TEST_PASS=True

# add when k8s is supported
GPU - shall be able to deploy k8s shared NVidia T4 Passthru GPU app on KVM Openstack
    [Documentation]
    ...  deploy Ubuntu 16 VM image with GPU support on openstack
    ...  verify app uses the GPU

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name

    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  ip_access=IpAccessShared  deployment=kubernetes
    Sleep  30  seconds
    Create App  region=${region}  image_path=${docker_image_gpu}  access_ports=tcp:8008,tcp:8011  image_type=ImageTypeDocker  deployment=kubernetes
    Create App Instance  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  cluster_instance_name=${cluster_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}

    Wait For DNS  ${cloudlet.fqdn}

    Sleep  30 s

    ${server_tester}=  Catenate  SEPARATOR=/  ${client_path}  server_tester.py
    ${image_full}=     Catenate  SEPARATOR=/  ${client_path}  ${image}

    ${epoch_time}=  Get Time  epoch
    ${outfile}=        Catenate  SEPARATOR=  outfile  ${epoch_time}

    # python3 server_tester.py -s 37.50.200.37  -e /openpose/detect/ -f 3_bodies.png --show-responses -r 4
    Run Process  python3  ${server_tester}   -s   ${cloudlet.fqdn}   -e  /openpose/detect/   -f   ${image_full}  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT
    #Run Process  python  ${server_tester}   -s    37.50.200.37  -e  /openpose/detect/   -f   3_bodies.png  --show-responses  -r  4  stdout=${outfile}  stderr=STDOUT

    ${output}=  Get File  ${outfile}
    Log To Console  ${output}

    Should Contain  ${output}  TEST_PASS=True

*** Keywords ***
Setup
    Create Flavor  region=${region}  disk=80  optional_resources=gpu=pci:1

    Add Cloudlet Resource Mapping  region=${region}  cloudlet_name=${cloudlet_name_openstack_gpu}  operator_org_name=${operator_name_openstack}  mapping=gpu=${gpu_resource_name}
    Add Resource Tag  region=${region}  resource_name=${gpu_resource_name}  operator_org_name=${operator_name_openstack}  tags=pci=t4gpu:1
	
