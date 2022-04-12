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

test_timeout_crm = '60 min'

cloudlet_name_azure = 'automationAzureCentralCloudlet'
cloudlet_name_gcp = 'automationGcpCentralCloudlet'
#cloudlet_name_openstack = 'automationHamburgCloudlet'
cloudlet_name_openstack = 'automationBonnCloudlet'
cloudlet_name_openstack_shared = 'automationBonnCloudlet'
cloudlet_name_openstack_dedicated = 'automationMunichCloudlet'
cloudlet_name_openstack_vm = 'automationMunichCloudlet'
cloudlet_name_openstack_metrics = 'automationBerlinCloudletStage'

operator_name_azure = 'azure'
operator_name_gcp = 'gcp'

docker_image = 'docker-stage.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'

artifactory_dummy_image_name = 'execJira.py'

qcow_centos_image = 'https://artifactory.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'
qcow_centos_image_notrunning = 'https://artifactory.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c'
qcow_windows_image = 'https://artifactory.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_windows2012.qcow2#md5:42171406daca80298098ac314200634a'
qcow_centos_openstack_image = 'server_ping_threaded_centos7'

#vm_console_address =  'https://hamedgecloud.telekom.de:6080/vnc_auto.html'
vm_console_address =  'https://bonnedgecloud.telekom.de:6080/vnc_auto.html'

mextester99_gmail_password = 'rfbixqomqidobmcb'


