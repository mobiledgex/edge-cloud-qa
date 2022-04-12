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

cloudlets = ['automationSunnydaleCloudlet', 'automationFairviewCloudlet', 'automationBeaconCloudlet']
num_cores_needed = 10
num_ips_needed   = 10
openstack_envs =  {'automationFairviewCloudlet':'/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_fairview.mex',
                   'automationBeaconCloudlet':'/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_beacon.mex',
                   'automationSunnydaleCloudlet':'/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_sunnydale.mex'}

