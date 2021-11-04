*** Settings ***
Documentation  Facedetection server shall recognize faces

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}   root_cert=%{AUTOMATION_MC_CERT}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  Process
Library  OperatingSystem
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  30 minutes
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationHamburgCloudlet
${operator_name}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${mobiledgex_domain}  mobiledgex.net

#${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${docker_image_facedetection}    docker.mobiledgex.net/mobiledgex/images/facedetection:latest
${docker_command}  ./gunicorn
${facedetection_ports}  tcp:8008,tcp:8011

${gpu_client}  multi_client.py
${gpu_client_path}     ../edge-cloud-sampleapps/ComputerVisionServer/client
#${client_path}     ../../../edge-cloud-sampleapps/FaceDetectionServer/client

@{image_list_good}  Bruce.jpg  Bruce.png  Wonho.png  Wonho2.png  face.png  face2.png  faceHuge.jpg  face_20181015-163834.png  face_large.png  face_small.png  face_triple.png
@{image_list_bad}   1_body.png  3_bodies.png  6_bodies.jpg  empty_portrait_black.png  empty_portrait_white.png  multi_body.png  single_pixel.png
	
${app_template}    http://35.199.188.102/apps/apptemplate.yaml

${region}=  EU
	
*** Test Cases ***
# ECQ-1139
Facedetection server shall recognize faces
    [Documentation]
    ...  - deploy the facedetection server
    ...  - verify it detects known faces
    ...  - verify it fails on non faces

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=  facedetect  ${epoch_time}
    #${cluster_name}=  Catenate  SEPARATOR=  autocluster  ${app_name}

    ${config}=  Set Variable  - name: REDIS_SERVER_PASSWORD${\n}${SPACE*2}value: S@ndhi11 

    Log To Console  Creating App and App Instance
    Create App           region=${region}  app_name=${app_name}  image_path=${docker_image_gpu}  access_ports=${facedetection_ports}  configs_kind=envVarsYaml  configs_config=${config}  deployment=kubernetes  default_flavor_name=${cluster_flavor_name}  #default_flavor_name=flavor1550017240-694686
    Create App Instance  region=${region}  app_name=${app_name}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  flavor_name=${cluster_flavor_name} 

    Log To Console  Registering Client and Finding Cloudlet
    Register Client  app_name=${app_name}
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name_crm}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}

    #Log To Console  Waiting for k8s pod to be running
    #Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name}  operator_name=${operator_name_crm}  pod_name=${app_name}

    Sleep  60  # wait for process to be up

    ${server_tester}=  Catenate  SEPARATOR=/  ${gpu_client_path}  ${gpu_client} 

    # verify good images
    FOR  ${image}  IN  @{image_list_good}
      ${image_full}=  Catenate  SEPARATOR=/  ${gpu_client_path}  ${image}
      ${outfile}=     Catenate  SEPARATOR=  outfile  ${image}  ${epoch_time}
      Run Process  python3  ${server_tester}   -s   ${fqdn}  -e   /detector/detect/  -c  rest  -f   ${image_full}   --show-responses  stdout=${outfile}  stderr=STDOUT
      ${output}=  Get File  ${outfile}
      Log To Console  ${output}

      Should Contain  ${output}  "success": "true"
    END

    # verify bad images
    FOR  ${image}  IN  @{image_list_bad}
      ${image_full}=  Catenate  SEPARATOR=/  ${gpu_client_path}  ${image}
      ${outfile}=     Catenate  SEPARATOR=  outfile  ${image}  ${epoch_time}
      Run Process  python3  ${server_tester}   -s   ${fqdn}   -e   /detector/detect/  -c  rest  -f   ${image_full}   --show-responses  stdout=${outfile}  stderr=STDOUT
      ${output}=  Get File  ${outfile}
      Log To Console  ${output}

      Should Contain  ${output}  "success": "false"
    END

*** Keywords ***
Setup
    #Create Developer
    Create Flavor  region=${region}  ram=4096  vcpus=4  disk=4
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  
    #Create Cluster   default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    Log To Console  Creating Cluster Instance
    Create Cluster Instance  region=${region}  cloudlet_name=${cloudlet_name_crm}  operator_org_name=${operator_name_crm}  deployment=kubernetes  number_masters=1  number_nodes=1
    Log To Console  Done Creating Cluster Instance

    ${rootlb}=  Catenate  SEPARATOR=.  ${cloudlet_name_crm}  ${operator_name_crm}  ${mobiledgex_domain}
    ${rootlb}=  Convert To Lowercase  ${rootlb}

    Set Suite Variable  ${rootlb}
