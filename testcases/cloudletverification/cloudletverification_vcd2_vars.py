#####################################3
# This file defines variables used by the testcases.
# The file is in Python.
# It should be passed into the robot command when running the testcases by using the '-V' option
# example: robot --loglevel TRACE -V cloudletverification/cloudletverification_vars.py --outputdir=cloudletverification/logs -i cloudlet  cloudletverification
#
# Individual parameters can be overriden with the '-v' option
# example: robot --loglevel TRACE -V cloudletverification/cloudletverification_vcd2.py -v cloudlet_name:mycloudlet --outputdir=cloudletverification/logs -i cloudlet  cloudletverification
# --dryrun to see what tests will execute without running them
# -v run_test_teardown:False will not tear down in order to analyze a test run
# THis will run 87 tests use --dryrun to see output
# robot --loglevel TRACE --consolewidth 290 -V cloudletverification/cloudletverification_vcd2_vars.py --outputdir=cloudletverification/logsphase12allmetrics02 -v run_test_teardown:False -e gpu -e vm  -e vsphere -e sharedvolumesize -e privacypolicy cloudletverification
# 
################################################
import time

timestamp = str(time.time()).replace('.','')

# this is the time to wait before aborting the testcase. This avoids testcases hanging or wasting time
test_timeout = '32 min'
# this is the time to wait for the https stream message to comeback for create Cluster Inst
# stream_timeout = 1200
# this is the controller region used to run the tests
region = 'US'


# account information qa 
username_mexadmin = 'mexadmin'
password_mexadmin = 'mexadminfastedgecloudinfra'
username_developer = 'andyanderson'
password_developer = 'mexadminfastedgecloudinfra'
# username_developer = 'tomdevmanager'
# password_developer = '58a8dd77baf9b8833f9753c93a62a5f5f3f35b11'
username_operator = 'andyanderson'
password_operator = 'mexadminfastedgecloudinfra'
#developer_organization_name = 'tomdev'
developer_organization_name = 'MobiledgeX'



# test will create flavors or not.  Requires mexadmin username/password.  Sometimes flavors will be predefined and we wont have permissions to create our own
create_flavors = True 

# mcctl --addr https://console-qa.mobiledgex.net:443 region --skipverify CreateCloudlet cloudlet=qa-vcd-01 region=US cloudlet-org=packet physicalname=qa-lab infraapiaccess=DirectAccess platformtype=PlatformTypeVcd  location.latitude=33 location.longitude=-96 numdynamicips=4 envvar=MEX_DATASTORE=datastore1 envvar=MEX_EXTERNAL_NETWORK_MASK=29 envvar=MEX_NETWORK_SCHEME=cidr=10.102.X.0/24 envvar=MEX_IMAGE_DISK_FORMAT=vmdk deployment=docker infraconfig.flavorname=x1.medium envvar=MEX_EXT_NETWORK=ext-net envvar=MEX_VDC_TEMPLATE=mobiledgex-v4.2.1-rc1-vcd envvar=MEX_CATALOG=MEX-Cat01



# env_vars=${cloudlet_env_vars}
# vcd qaorg cloudlet variables
operator_name = 'packet'
cloudlet_platform_type = 'PlatformTypeVcd'
cloudlet_latitude = '33'
cloudlet_longitude = '-96'
cloudlet_ipsupport = 'dynamic'
cloudlet_infraapiaccess = 'directaccess'
cloudlet_numdynamicips = '10'
cloudlet_security_group = 'cloudletverification'
cloudlet_external_subnet = 'external-subnet'  # used for cloudlet metrics verification
cloudlet_infraconfig_flavorname = 'x1.medium'
cloudlet_infraconfig_externalnetworkname = 'eexternal-network-qa'
deployment = 'docker'


# for VCD qa2org /28
cloudlet_name = 'automation-qa2-vcd-01'
physical_name = 'qa2-lab'
cloudlet_vdc_template = 'MEX_VDC_TEMPLATE=mobiledgex-v4.2.1-vcd'
cloudlet_mex_catalog =  'MEX_CATALOG=qa2-cat'
cloudlet_whitelist_in = 'MEX_CLOUDLET_FIREWALL_WHITELIST_EGRESS=protocol=tcp,portrange=1:65535,remotecidr=0.0.0.0/0;protocol=udp,portrange=1:65535,remotecidr=0.0.0.0/0;protocol=icmp,remotecidr=0.0.0.0/0;protocol=tcp,portrange=22,remotecidr=76.184.227.212/32;protocol=tcp,portrange=22,remotecidr=35.199.188.102/32'
cloudlet_whitelist_eg = 'MEX_CLOUDLET_FIREWALL_WHITELIST_INGRESS=protocol=tcp,portrange=1:65535,remotecidr=0.0.0.0/0;protocol=udp,portrange=1:65535,remotecidr=0.0.0.0/0;protocol=icmp,remotecidr=0.0.0.0/0;protocol=tcp,portrange=22,remotecidr=76.184.227.212/32;protocol=tcp,portrange=22,remotecidr=35.199.188.102/32'
cloudlet_datastore = 'MEX_DATASTORE=datastore1'
cloudlet_ext_netmask = 'MEX_EXTERNAL_NETWORK_MASK=28'
cloudlet_ext_gateway = 'MEX_EXTERNAL_NETWORK_GATEWAY=139.178.87.225'
cloudlet_ext_network = 'MEX_EXT_NETWORK=external-network-qa2'
cloudlet_image_disk_format = 'MEX_IMAGE_DISK_FORMAT=vmdk'
cloudlet_ext_netscheme = 'MEX_NETWORK_SCHEME=cidr=10.102.X.0/24'

#vcd format

cloudlet_env_vars= f'{cloudlet_datastore},{cloudlet_ext_netmask},{cloudlet_ext_netscheme},{cloudlet_ext_network},{cloudlet_ext_gateway},{cloudlet_image_disk_format},{cloudlet_vdc_template},{cloudlet_mex_catalog},{cloudlet_whitelist_in},{cloudlet_whitelist_eg}'

# docker image used for docker/k8s deployments
docker_image = 'docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:6.0'
#docker_image = 'docker-qa.mobiledgex.net/tomdev/images/server-ping-threaded:6.0'
docker_image_gpu = 'docker-qa.mobiledgex.net/mobiledgex/images/mobiledgexsdkdemo20:2020-06-16-GPU'
docker_image_privacypolicy = 'docker-qa.mobiledgex.net/mobiledgex/images/port_test_server:1.0'

# QCOW image used for VM deployments which has the test app running on it
qcow_centos_image = 'https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7_http.qcow2#md5:c7f7e312dd18b1c9ea586650721c75ba'
# QCOW image used for VM deployments which does NOT have the test app running on it. This is used for cloudconfig tests with starts the app via a manifest file
qcow_centos_image_notrunning = 'https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c'
# QCOW image used for GPU testing. This has the openpose app installed
qcow_gpu_ubuntu16_image = 'https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/ubuntu16_nvidia_gpu.qcow2#md5:ebefc158437895d0399802dac66b2f4f'

# cloudconfig to use for VM deploymenst
vm_cloudconfig = 'http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml'

# http page to request when testing http app inst acces
http_page = 'automation.html'

# token server to verify for DME requests
token_server_url = 'http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc'

# GPU resource name used for configuring the cloudlets for GPUs
gpu_resource_name = 'mygpuresrouce'

# tester used to the GPU
facedetection_server_tester = 'cloudletverification/FaceDetectionServer/multi_client.py'
facedetection_image = 'cloudletverification/FaceDetectionServer/3_bodies.png'

# external server to use when checking for egress access.  Server will be pinged from app instance
trust_policy_server = '35.199.188.102'

##############################################
# these define the names used for flavors/apps/clusters
##############################################3
#   Should Be Equal             ${cluster_inst['data']['flavor']['name']}  ${flavor_name_small}
#   Should Be Equal As Numbers  ${cluster_inst['data']['ip_access']}       3  #IpAccessShared
#   Should Be Equal             ${cluster_inst['data']['deployment']}      kubernetes
#   Should Be Equal As Numbers  ${cluster_inst['data']['state']}           5  #Ready
#   Should Be Equal As Numbers  ${cluster_inst['data']['num_masters']}     1
#   Should Be Equal As Numbers  ${cluster_inst['data']['num_nodes']}       1
#   Should Be Equal             ${cluster_inst['data']['master_node_flavor']}  ${master_flavor_name_small}
#   Should Be Equal             ${cluster_inst['data']['node_flavor']}         ${node_flavor_name_small}


flavor_name = 'flavorpoc' + timestamp
app_name = 'apppoc' + timestamp
#cluster_name = 'clusterpoc' + timestamp
cluster_name = 'cpoc' + timestamp
privacy_policy_name = 'privacypolicypoc' + timestamp

flavor_name_small = flavor_name + 'small'
flavor_name_medium = flavor_name + 'medium'
flavor_name_large = flavor_name + 'large'
flavor_name_vm = flavor_name + 'vm'
flavor_name_gpu = flavor_name + 'gpu'
master_flavor_name_small = 'vsphere.smallest'
master_flavor_name_medium = 'vsphere.medium'
master_flavor_name_large = 'vsphere.large'
master_flavor_name_gpu = 'vsphere.large-gpu'
#master_flavor_name_gpu = 'm4.small' all the above were small
#node_flavor_name_small = 'm4.small'
node_flavor_name_small =  'vsphere.smallest'
node_flavor_name_medium = 'vsphere.medium'
node_flavor_name_large = 'vsphere.large'
node_flavor_name_gpu = 'vsphere.large-gpu'

app_name_dockerdedicateddirect = app_name + 'dockerdedicateddirect'
app_name_dockerdedicatedlb = app_name + 'dockerdedicatedlb'
app_name_dockerdedicatedgpu = app_name + 'dockerdedicatedgpu'
app_name_dockersharedlb = app_name + 'dockersharedlb'
app_name_dockerdedicated_privacypolicy = app_name + 'dockerprivacypolicy'
app_name_k8sdedicatedlb = app_name + 'k8sdedicatedlb'
app_name_k8ssharedlb = app_name + 'k8ssharedlb'
app_name_k8ssharedgpu = app_name + 'k8ssharedgpu'
app_name_k8ssharedvolumesize = app_name + 'k8ssharedvolumesize'
app_name_vmdirect = app_name + 'vmdirect'
app_name_vmlb = app_name + 'vmlb'
app_name_vm_cloudconfig = app_name + 'vmcloudconfig'
app_name_vmgpu = app_name + 'vmgpu'

cluster_name_dockerdedicateddirect = cluster_name + 'dkrdeddrct'
#cluster_name_dockerdedicatedlb = cluster_name + 'dkrdedlb'
cluster_name_dockerdedicatedlb = cluster_name + 'dkrdedlb'
cluster_name_dockersharedlb = cluster_name + 'dkershrdlb'
cluster_name_dockerdedicatedgpu = cluster_name + 'dkerdedgpu'
cluster_name_dockerdedicated_privacypolicy = cluster_name + 'dkerprivplcy'
cluster_name_k8ssharedgpu = cluster_name + 'k8shrdgpu'
cluster_name_k8sdedicatedlb = cluster_name + 'k8sdedlb'
cluster_name_k8ssharedlb = cluster_name + 'k8shrdlb'
cluster_name_k8ssharedvolumesize = cluster_name + 'k8shrdvolsze'
cluster_name_vm = 'autoclustervm'
cluster_name_vmgpu = 'autoclustervmgpu'

# metrics wait time
metrics_wait_docker = 20*60  # 20mins
metrics_wait_k8s = 20*60     # 20mins
metrics_wait_vm = 25*60      # 25mins

# these are used to calculated how long the cluster has been up. primarily for metrics tests
cluster_name_dockerdedicateddirect_starttime = 0
cluster_name_dockerdedicatedlb_starttime = 0
cluster_name_dockersharedlb_starttime = 0
cluster_name_dockerdedicatedgpu_starttime = 0
cluster_name_dockersharedgpu_starttime = 0
cluster_name_k8sdedicatedlb_starttime = 0
cluster_name_k8ssharedlb_starttime = 0
cluster_name_k8ssharedvolumesize_starttime = 0
vmdirect_starttime = 0
vmlb_starttime = 0
vmcloudconfig_starttime = 0
vmgpu_starttime = 0
cluster_name_dockerdedicateddirect_endtime = 0
cluster_name_dockerdedicatedlb_endtime = 0
cluster_name_dockersharedlb_endtime = 0
cluster_name_dockerdedicatedgpu_endtime = 0
cluster_name_dockersharedgpu_endtime = 0
cluster_name_k8sdedicatedlb_endtime = 0
cluster_name_k8ssharedlb_endtime = 0
cluster_name_k8ssharedvolumesize_endtime = 0
vmdirect_endtime = 0
vmlb_endtime = 0
vmcloudconfig_endtime = 0
vmgpu_endtime = 0

