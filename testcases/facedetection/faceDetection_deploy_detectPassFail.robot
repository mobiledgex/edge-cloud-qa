*** Settings ***
Documentation  Facedetection server shall recognize faces

Library	 MexController  controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexApp
Library  Process
Library  OperatingSystem
#Variables       shared_variables.py

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout  30 minutes
	
*** Variables ***
${cluster_flavor_name}  x1.medium
	
${cloudlet_name_openstack}  automationHamburgCloudlet
${operator_name}  TDG
${latitude}       32.7767
${longitude}      -96.7970

${rootlb}          automationhamburgcloudlet.tdg.mobiledgex.net

${docker_image}    registry.mobiledgex.net:5000/mobiledgex/facedetection:Nimbus_automation_20190225
${docker_command}  ./gunicorn
${facedetection_ports}  tcp:8008

${client_path}     ../edge-cloud-sampleapps/FaceDetectionServer/client

@{image_list_good}  Bruce.jpg  Bruce.png  Wonho.png  Wonho2.png  face.png  face2.png  faceHuge.jpg  faceHuge.png  face_20181015-163834.png  face_large.png  face_small.png  face_triple.png
@{image_list_bad}   1_body.png  3_bodies.png  6_bodies.jpg  empty_portrait_black.png  empty_portrait_white.png  multi_body.png  single_pixel.png
	
${app_template}    http://35.199.188.102/apps/apptemplate.yaml
	
*** Test Cases ***
Facedetection server shall recognize faces
    [Documentation]
    ...  deploy the facedetection server
    ...  verify it detects known faces
    ...  verify it fails on non faces

    ${epoch_time}=  Get Time  epoch
    ${app_name}=    Catenate  SEPARATOR=  facedetect  ${epoch_time}

    Log To Console  Creating App and App Instance
    Create App           app_name=${app_name}  image_path=${docker_image}  access_ports=${facedetection_ports}  default_flavor_name=${cluster_flavor_name}  #default_flavor_name=flavor1550017240-694686
    Create App Instance  app_name=${app_name}  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  cluster_instance_name=autocluster  flavor_name=${cluster_flavor_name} 

    Log To Console  Registering Client and Finding Cloudlet
    Register Client  app_name=${app_name}
    ${cloudlet}=  Find Cloudlet	latitude=${latitude}  longitude=${longitude}  carrier_name=${operator_name}
    ${fqdn}=  Catenate  SEPARATOR=  ${cloudlet.ports[0].FQDN_prefix}  ${cloudlet.FQDN}

    Log To Console  Waiting for k8s pod to be running
    ${cluster_name}=  Catenate  SEPARATOR=  autocluster  ${app_name}
    Wait for k8s pod to be running  root_loadbalancer=${rootlb}  cluster_name=${cluster_name}  operator_name=${operator_name}  pod_name=${app_name}

    Sleep  30  # wait for process to be up

    ${server_tester}=  Catenate  SEPARATOR=/  ${client_path}  server_tester.py

    # verify good images
    FOR  ${image}  IN  @{image_list_good}
    \  ${image_full}=  Catenate  SEPARATOR=/  ${client_path}  ${image}
    \  ${outfile}=     Catenate  SEPARATOR=  outfile  ${image}  ${epoch_time}
    \  Run Process  python  ${server_tester}   -s   ${fqdn}   -p  ${cloudlet.ports[0].public_port}  -e   /detector/detect/   -f   ${image_full}   --show-responses  stdout=${outfile}  stderr=STDOUT
    \  ${output}=  Get File  ${outfile}
    \  Log To Console  ${output}

    \  Should Contain  ${output}  "success": "true"

    # verify bad images
    FOR  ${image}  IN  @{image_list_bad}
    \  ${image_full}=  Catenate  SEPARATOR=/  ${client_path}  ${image}
    \  ${outfile}=     Catenate  SEPARATOR=  outfile  ${image}  ${epoch_time}
    \  Run Process  python  ${server_tester}   -s   ${fqdn}   -p  ${cloudlet.ports[0].public_port}  -e   /detector/detect/   -f   ${image_full}   --show-responses  stdout=${outfile}  stderr=STDOUT
    \  ${output}=  Get File  ${outfile}
    \  Log To Console  ${output}

    \  Should Contain  ${output}  "success": "false"

*** Keywords ***
Setup
    Create Developer
    Create Flavor
    #Create Cluster Flavor  cluster_flavor_name=${cluster_flavor_name}  
    #Create Cluster   default_flavor_name=${cluster_flavor_name}
    #Create Cloudlet  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  latitude=${latitude}  longitude=${longitude}
    #Log To Console  Creating Cluster Instance
    #Create Cluster Instance  cloudlet_name=${cloudlet_name_openstack}  operator_name=${operator_name}  flavor_name=${cluster_flavor_name}
    #Log To Console  Done Creating Cluster Instance
