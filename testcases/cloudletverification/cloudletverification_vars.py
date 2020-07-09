#####################################3
# This file defines variables used by the testcases.
# The file is in Python.
# It should be passed into the robot command when running the testcases by using the '-V' option
# example: robot --loglevel TRACE -V cloudletverification/cloudletverification_vars.py --outputdir=cloudletverification/logs -i cloudlet  cloudletverification
#
# Individual parameters can be overriden with the '-v' option
# example: robot --loglevel TRACE -V cloudletverification/cloudletverification_vars.py -v cloudlet_name_openstack:mycloudlet --outputdir=cloudletverification/logs -i cloudlet  cloudletverification
################################################3
import time

timestamp = str(time.time()).replace('.','')

# this is the time to wait before aborting the testcase. This avoids testcases hanging or wasting time
test_timeout = '32 min'

# this is the controller region used to run the tests
region = 'EU'

# account information
username_mexadmin = 'mexadmin'
password_mexadmin = 'mexadmin123'
username_developer = 'andyanderson'
password_developer = 'password'
username_operator = 'andyanderson'
password_operator = 'password'

# test will create flavors or not.  Requires mexadmin username/password.  Sometimes flavors will be predefined and we wont have permissions to create our own
create_flavors = True 

# cloudlet variables
cloudlet_name_openstack = 'verificationCloudlet'
operator_name_openstack = 'TDG'
physical_name_openstack = 'munich'
cloudlet_latitude = '45.5017'
cloudlet_longitude = '-73.5673'
cloudlet_security_group = 'cloudletverification'
cloudlet_external_subnet = 'external-subnet'  # used for cloudlet metrics verification
cloudlet_env_vars = f'MEX_SECURITY_GROUP={cloudlet_security_group}'

developer_organization_name = 'MobiledgeX'

# docker image used for docker/k8s deployments
docker_image = 'docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:6.0'
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
privacy_policy_server = '35.199.188.102'

##############################################
# these define the names used for flavors/apps/clusters
##############################################3
flavor_name = 'flavorpoc' + timestamp
app_name = 'apppoc' + timestamp
cluster_name = 'clusterpoc' + timestamp
privacy_policy_name = 'privacypolicypoc' + timestamp

flavor_name_small = flavor_name + 'small'
flavor_name_medium = flavor_name + 'medium'
flavor_name_large = flavor_name + 'large'
flavor_name_vm = flavor_name + 'vm'
flavor_name_gpu = flavor_name + 'gpu'
master_flavor_name_small = 'm4.small'
master_flavor_name_medium = 'm4.small'
master_flavor_name_large = 'm4.small'
master_flavor_name_gpu = 'm4.small'
node_flavor_name_small = 'm4.small'
node_flavor_name_medium = 'm4.medium'
node_flavor_name_large = 'm4.large'
node_flavor_name_gpu = 'm4.large-gpu'

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

cluster_name_dockerdedicateddirect = cluster_name + 'dockerdedicateddirect'
cluster_name_dockerdedicatedlb = cluster_name + 'dockerdedicatedlb'
cluster_name_dockersharedlb = cluster_name + 'dockersharedlb'
cluster_name_dockerdedicatedgpu = cluster_name + 'dockerdedicatedgpu'
cluster_name_dockerdedicated_privacypolicy = cluster_name + 'dockerprivacypolicy'
cluster_name_k8ssharedgpu = cluster_name + 'k8ssharedgpu'
cluster_name_k8sdedicatedlb = cluster_name + 'k8sdedicatedlb'
cluster_name_k8ssharedlb = cluster_name + 'k8ssharedlb'
cluster_name_k8ssharedvolumesize = cluster_name + 'k8ssharedvolumesize'
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

