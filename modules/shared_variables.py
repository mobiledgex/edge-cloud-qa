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

import time
import random

# default_time_stamp = str(int(time.time()))
default_time_stamp = str(time.time()).replace('.', '-')
time_stamp_default = default_time_stamp
cloudlet_name_default = 'cloudlet' + default_time_stamp
operator_name_default = 'operator' + default_time_stamp
cluster_name_default = 'cluster' + default_time_stamp
app_name_default = 'app' + default_time_stamp
app_version_default = '1.0'
# developer_name_default = 'developer' + default_time_stamp
developer_name_default = 'automation_dev_org'
flavor_name_default = 'flavor' + default_time_stamp
network_name_default = 'network' + default_time_stamp
cluster_flavor_name_default = 'cluster_flavor' + default_time_stamp
organization_name_default = 'org' + default_time_stamp
cloudletpool_name_default = 'cloudletpool' + default_time_stamp
vmpool_name_default = 'vmpool' + default_time_stamp
alert_receiver_name_default = 'alertreceiver' + default_time_stamp.replace('-', '')
alert_receiver_type_default = 'email'
alert_receiver_severity_default = 'info'
trust_policy_name_default = 'trustpolicy' + default_time_stamp
autoprov_policy_name_default = 'autoprovpolicy' + default_time_stamp
autoscale_policy_name_default = 'autoscalepolicy' + default_time_stamp
flow_settings_name_default = 'flow' + default_time_stamp
alert_policy_name_default = 'alertrpolicy' + default_time_stamp.replace('-', '')
max_requests_settings_name_default = 'maxreqs' + default_time_stamp

first_name_default = 'firstname' + default_time_stamp
# org_name_default = 'name' + default_time_stamp
last_name_default = 'lastname' + default_time_stamp
billing_org_type_default = 'self'
email_address_default = 'email' + default_time_stamp + '@gmail.com'

latitude_default = 10
longitude_default = 10
number_dynamic_ips_default = 254
ip_support_default = 'IpSupportDynamic'
static_ips_default = '10.10.10.10'
access_uri_default = 'https://www.edgesupport.com/test'
session_cookie_default = ''
token_default = ''
token_server_uri_default = ''
crm_notify_server_address = '127.0.0.1'
crm_notify_server_address_port = random.randint(49152, 65535)
gpudriver_name_default = 'gpudriver' + default_time_stamp
gpudriver_build_name_default = 'build' + default_time_stamp
reporter_name_default = 'reporter' + default_time_stamp
federation_name_default = 'federation' + default_time_stamp
federator_zone_default = 'zone' + default_time_stamp

platform_type = 'notset'
