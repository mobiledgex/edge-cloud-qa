*** Settings ***
Documentation  use UpdateAppInst to manage VM based App Inst on openstack

Library  MexMasterController  mc_address=%{AUTOMATION_MC_ADDRESS}
Library  MexDme  dme_address=%{AUTOMATION_DME_ADDRESS}
Library  MexOpenstack   environment_file=%{AUTOMATION_OPENSTACK_VM_ENV}
Library  MexApp
Library  String

Test Setup      Setup
Test Teardown   Cleanup provisioning

Test Timeout    ${test_timeout_crm}

*** Variables ***
${region}  EU
${cloudlet_name_openstack_vm}  automationBuckhornCloudlet
${operator_name_openstack}  GDDT
${latitude}       32.7767
${longitude}      -96.7970

${qcow_centos_image}    https://artifactory.mobiledgex.net/artifactory/qa-repo-automationdevorg/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d
${image}    server_ping_threaded_centos7
${test_timeout_crm}  30 min

*** Test Cases ***
# direct not supported
# ECQ-2260
#User shall be able to poweroff/poweron VM based App Inst with AccessTypeDirect
#    [Documentation]
#    ...  create VM based App Inst on openstack with AccessTypeDirect
#    ...  UpdateAppInst to poweroff/poweron the VM
#    ...  Verify the power state using openstack API 
#
#    ${cluster_name_default}=  Get Default Cluster Name
#    ${app_name_default}=  Get Default App Name
#    ${developer_name_default}=  Get Default Developer Name
#    ${version_default}=  Get Default App Version
#
#    ${vm}=  Convert To Lowercase  ${developer_name_default}${app_name_default}${version_default}
#    ${vm}=  Remove String  ${vm}  .
#
#    Log To Console  Creating App and App Instance
#    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015   region=${region} 
#    Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}
#
#    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
#
#    Register Client
#    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
#    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
#    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
#
#    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
#    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}
#
#    Log To Console  Updating App Instance
#    Update App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}  powerstate=PowerOff
#
#    FOR  ${x}  IN RANGE  0  5
#        ${vm_info}=  Get Server List  name=${vm}
#        Exit For Loop If  '${vm_info[0]['Status']}' == 'SHUTOFF'
#        Sleep  2s
#    END
#
#    Should Be Equal   ${vm_info[0]['Status']}  SHUTOFF
#
#    Log To Console  Updating App Instance
#    Update App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}  powerstate=PowerOn
#
#    FOR  ${x}  IN RANGE  0  5
#        ${vm_info}=  Get Server List  name=${vm}
#        Exit For Loop If  '${vm_info[0]['Status']}' == 'ACTIVE'
#        Sleep  2s
#    END
#
#    Should Be Equal   ${vm_info[0]['Status']}  ACTIVE
#
#    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
#
#    Register Client
#    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
#    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
#    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}
#
#    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
#    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

# direct not supported 
# ECQ-2259
#User shall be able to reboot VM based App Inst with AccessTypeDirect
#    [Documentation]
#    ...  create VM based App Inst on openstack with AccessTypeDirect
#    ...  UpdateAppInst to reboot the VM
#    ...  Verify the power state using openstack API
#
#    ${cluster_name_default}=  Get Default Cluster Name
#    ${app_name_default}=  Get Default App Name
#    ${developer_name_default}=  Get Default Developer Name
#    ${version_default}=  Get Default App Version
#
#    ${vm}=  Convert To Lowercase  ${developer_name_default}${app_name_default}${version_default}
#    ${vm}=  Remove String  ${vm}  .
#
#    Log To Console  Creating App and App Instance
#    Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015   region=${region}
#    Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}
#
#    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}
#
#    ${node_info}=  Get Server Show  name=${vm} 
#    ${time_before_reboot}=  Set Variable  ${node_info['updated']}
#
#    Log To Console  Updating App Instance
#    Update App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}  powerstate=Reboot
#
#    FOR  ${x}  IN RANGE  0  5
#        ${vm_info}=  Get Server List  name=${vm}
#        Exit For Loop If  '${vm_info[0]['Status']}' == 'ACTIVE'
#        Sleep  2s
#    END
#
#    Should Be Equal   ${vm_info[0]['Status']}  ACTIVE
#    ${node_info}=  Get Server Show  name=${vm}
#    ${time_after_reboot}=  Set Variable  ${node_info['updated']}
#    Should Not Be Equal  ${time_before_reboot}  ${time_after_reboot}

# ECQ-2260
User shall be able to poweroff/poweron VM based App Inst with AccessTypeLoadBalancer
    [Documentation]
    ...  create VM based App Inst on openstack with AccessTypeLoadBalancer
    ...  UpdateAppInst to poweroff/poweron the VM
    ...  Verify the power state using openstack API

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name
    ${developer_name_default}=  Get Default Developer Name
    ${version_default}=  Get Default App Version

    ${developer_name_default}=  Replace String  ${developer_name_default}  _  -
    ${vm}=  Convert To Lowercase  ${developer_name_default}${app_name_default}${version_default}
    ${vm}=  Remove String  ${vm}  .

    Log To Console  Creating App and App Instance
    ${app}=  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015   access_type=loadbalancer  region=${region}
    ${image_path}=  Set Variable  ${app['data']['image_path']}
    @{array}=  Split String  ${image_path}  :
    ${checksum}=  Set Variable  ${array[2]}

    ${image_name}=  Catenate  SEPARATOR=-  ${image}  ${checksum}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

    Log To Console  Updating App Instance
    Update App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}  powerstate=PowerOff
    Sleep  10s

    ${vm_info}=  Get Server List  name=${vm}
    ${num_servers}=   Get Length  ${vm_info}

    FOR  ${x}  IN RANGE  0  ${num_servers}
        Run Keyword If   '${vm_info[${x}]['Image']}' == '${image_name}'   Should Be Equal   ${vm_info[${x}]['Status']}   SHUTOFF
        ...  ELSE  Should Be Equal   ${vm_info[${x}]['Status']}   ACTIVE
    END

    Log To Console  Updating App Instance
    Update App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}  powerstate=PowerOn
    Sleep  10s

    ${vm_info}=  Get Server List  name=${vm}
    ${num_servers}=   Get Length  ${vm_info}

    FOR  ${x}  IN RANGE  0  ${num_servers}
        Run Keyword If   '${vm_info[${x}]['Image']}' == '${image_name}'   Should Be Equal   ${vm_info[${x}]['Status']}   ACTIVE
        ...  ELSE  Should Be Equal   ${vm_info[${x}]['Status']}   ACTIVE
    END

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    Register Client
    ${cloudlet}=  Find Cloudlet  latitude=${latitude}  longitude=${longitude}
    ${fqdn_0}=  Catenate  SEPARATOR=   ${cloudlet.ports[0].fqdn_prefix}  ${cloudlet.fqdn}
    ${fqdn_1}=  Catenate  SEPARATOR=   ${cloudlet.ports[1].fqdn_prefix}  ${cloudlet.fqdn}

    TCP Port Should Be Alive  ${fqdn_0}  ${cloudlet.ports[0].public_port}
    UDP Port Should Be Alive  ${fqdn_1}  ${cloudlet.ports[1].public_port}

# ECQ-2261
User shall be able to reboot VM based App Inst with AccessTypeLoadBalancer
    [Documentation]
    ...  create VM based App Inst on openstack with AccessTypeLoadBalancer
    ...  UpdateAppInst to reboot the VM
    ...  Verify the power state using openstack API

    ${cluster_name_default}=  Get Default Cluster Name
    ${app_name_default}=  Get Default App Name
    ${developer_name_default}=  Get Default Developer Name
    ${version_default}=  Get Default App Version

    ${developer_name_default}=  Replace String  ${developer_name_default}  _  -
    ${vm}=  Convert To Lowercase  ${developer_name_default}${app_name_default}${version_default}
    ${vm}=  Remove String  ${vm}  .

    Log To Console  Creating App and App Instance
    ${app}=  Create App  image_type=ImageTypeQCOW  deployment=vm  image_path=${qcow_centos_image}  access_ports=tcp:2016,udp:2015   access_type=loadbalancer  region=${region}
    ${image_path}=  Set Variable  ${app['data']['image_path']}
    @{array}=  Split String  ${image_path}  :
    ${checksum}=  Set Variable  ${array[2]}

    ${image_name}=  Catenate  SEPARATOR=-  ${image}  ${checksum}
    Create App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}

    Wait For App Instance Health Check OK  region=${region}  app_name=${app_name_default}

    ${node_info}=  Get Server Show  name=${vm}
    ${time_before_reboot}=  Set Variable  ${node_info['updated']}

    Log To Console  Updating App Instance
    Update App Instance  cloudlet_name=${cloudlet_name_openstack_vm}  operator_org_name=${operator_name_openstack}  cluster_instance_name=dummycluster  region=${region}  powerstate=Reboot
    Sleep  10s

    ${vm_info}=  Get Server List  name=${vm}
    Should Be Equal   ${vm_info[0]['Status']}  ACTIVE
    ${node_info}=  Get Server Show  name=${vm}
    ${time_after_reboot}=  Set Variable  ${node_info['updated']}
    Should Not Be Equal  ${time_before_reboot}  ${time_after_reboot}


*** Keywords ***
Setup
    Create Flavor  disk=80  region=${region}
