# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
password_mexadmin = 'rf45E2ziSa'
username_developer = 'andyanderson'
password_developer = 'andya123'
username_operator = 'andyanderson'
password_operator = 'andya123'

create_flavors = False  # test will create flavors or not.  Requires mexadmin username/password.  Sometimes flavors will be predefined and we wont have permissions to create our own

# cloudlet variables
cloudlet_name_openstack = 'edge2-galicia-spain'
#cloudlet_name_openstack = 'edge1-madrid-spain'
operator_name_openstack = 'Sonoral'
physical_name_openstack = 'paradise'
cloudlet_latitude = '45.5017'
cloudlet_longitude = '-73.5673'
cloudlet_security_group = 'cloudletverification'

developer_organization_name = 'andydeveloper'

# docker image used for docker/k8s deployments
docker_image = f'docker-tef.mobiledgex.net/{developer_organization_name}/images/server_ping_threaded:7.0'
docker_image_gpu = f'docker-tef.mobiledgex.net/{developer_organization_name}/images/openpose-docker:20200116'

# QCOW image used for VM deployments which has the test app running on it
#qcow_centos_image = 'https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7_http.qcow2#md5:c7f7e312dd18b1c9ea586650721c75ba'
qcow_centos_image = 'https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'
#qcow_centos_image = 'https://artifactory.mobiledgex.net/mobiledgex/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'
# QCOW image used for VM deployments which does NOT have the test app running on it. This is used for cloudconfig tests with starts the app via a manifest file
qcow_centos_image_notrunning = 'https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c'
# QCOW image used for GPU testing. This has the openpose app installed
qcow_gpu_ubuntu16_image = 'https://artifactory-qa.mobiledgex.net/artifactory/repo-MobiledgeX/ubuntu16_nvidia_gpu.qcow2#md5:ebefc158437895d0399802dac66b2f4f'

# cloudconfig to use for VM deploymenst
vm_cloudconfig = 'http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml'

# manifest for shared volume mounts
manifest_url_sharedvolumesize = 'http://35.199.188.102/apps/server_ping_threaded_udptcphttp_shared_volumemount_tef.yml'

# http page to request when testing http app inst acces
http_page = 'automation.html'

# token server to verify for DME requests
token_server_url = 'http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc'

# GPU resource name used for configuring the cloudlets for GPUs
gpu_resource_name = 'mygpuresrouce'

# tester used to the GPU
facedetection_server_tester = 'cloudletverification/FaceDetectionServer/server_tester.py'
facedetection_image = 'cloudletverification/FaceDetectionServer/3_bodies.png'

##############################################
# these define the names used for flavors/apps/clusters
##############################################3
flavor_name = 'flavor' + timestamp
app_name = 'app' + timestamp
cluster_name = 'cluster' + timestamp

#flavor_name_small = flavor_name + 'small'
#flavor_name_medium = flavor_name + 'medium'
#flavor_name_large = flavor_name + 'large'
#flavor_name_vm = flavor_name + 'vm'
#flavor_name_gpu = flavor_name + 'gpu'

flavor_name_small = 'm4.small'
flavor_name_medium = 'm4.medium'
flavor_name_large = 'm4.large'
flavor_name_vm = 'm4.large'
flavor_name_gpu = 'm4.xxlarge-gpu' 
master_flavor_name_small = 'm1.medium'
master_flavor_name_medium = 'm1.medium'
master_flavor_name_large = 'm1.large'
master_flavor_name_gpu = 'm1.large-gpu'
node_flavor_name_small = 'm1.medium'
node_flavor_name_medium = 'm1.medium'
node_flavor_name_large = 'm1.large'
node_flavor_name_gpu = 'm1.xxlarge-gpu'

app_name_dockerdedicated = app_name + 'dockerdedicated'
app_name_dockerdedicatedgpu = app_name + 'dockerdedicatedgpu'
app_name_dockershared = app_name + 'dockershared'
app_name_k8sdedicated = app_name + 'k8sdedicated'
app_name_k8sshared = app_name + 'k8sshared'
app_name_k8ssharedgpu = app_name + 'k8ssharedgpu'
app_name_k8ssharedvolumesize = app_name + 'k8ssharedvolumesize'
app_name_vm = app_name + 'vm'
app_name_vm_cloudconfig = app_name + 'vmcloudconfig'
app_name_vmgpu = app_name + 'vmgpu'
app_name_dockerdedicated_privacypolicy = app_name + 'dockerdedicatedprivacypolicy'

cluster_name_dockerdedicated = cluster_name + 'dockerdedicated'
cluster_name_dockershared = cluster_name + 'dockershared'
cluster_name_dockerdedicatedgpu = cluster_name + 'dockerdedicatedgpu'
cluster_name_k8ssharedgpu = cluster_name + 'k8ssharedgpu'
cluster_name_k8sdedicated = cluster_name + 'k8sdedicated'
cluster_name_k8sshared = cluster_name + 'k8sshared'
cluster_name_k8ssharedvolumesize = cluster_name + 'k8ssharedvolumesize'
cluster_name_vm = 'autoclustervm'
cluster_name_vmgpu = 'autoclustervmgpu'

# metrics wait time
metrics_wait_docker = 1200
metrics_wait_k8s = 1200
metrics_wait_vm = 1200

# these are used to calculated how long the cluster has been up. primarily for metrics tests
cluster_name_dockerdedicated_starttime = 0
cluster_name_dockershared_starttime = 0
cluster_name_dockerdedicatedgpu_starttime = 0
cluster_name_dockersharedgpu_starttime = 0
cluster_name_k8sdedicated_starttime = 0
cluster_name_k8sshared_starttime = 0
cluster_name_k8ssharedvolumesize_starttime = 0
vm_starttime = 0
vmcloudconfig_starttime = 0
vmgpu_starttime = 0
cluster_name_dockerdedicated_endtime = 0
cluster_name_dockershared_endtime = 0
cluster_name_dockerdedicatedgpu_endtime = 0
cluster_name_dockersharedgpu_endtime = 0
cluster_name_k8sdedicated_endtime = 0
cluster_name_k8sshared_endtime = 0
cluster_name_k8ssharedvolumesize_endtime = 0
vm_endtime = 0
vmcloudconfig_endtime = 0
vmgpu_endtime = 0

