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


cloudlet_name_openstack_create = 'verificationCloudlet'

verification_region = 'US'

physical_name_openstack = 'munich'
operator_name_openstack = 'TELUS'

cloudlet_name_openstack = 'montreal-pitfield'
cloudlet_name_openstack_metrics = 'montreal-pitfield'

cloudlet_latitude = '45.5017'
cloudlet_longitude = '-73.5673'

docker_image = 'docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'

qcow_centos_image = 'https://artifactory.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'
qcow_centos_image_notrunning = 'https://artifactory.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c'
qcow_windows_image = 'https://artifactory.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_windows2012.qcow2#md5:42171406daca80298098ac314200634a'
qcow_centos_openstack_image = 'server_ping_threaded_centos7'


token_server_url = 'http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc'
