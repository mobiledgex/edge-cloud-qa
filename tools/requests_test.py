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

import requests
import logging
import time

logging.getLogger('urllib3').setLevel(logging.DEBUG)

with open('/Users/andyanderson/.mctoken') as file:  
   token = file.read() 
appname = 'andyvcd3'
url = 'https://console-qa.mobiledgex.net:443/api/v1/auth/ctrl/CreateClusterInst'
data = '{"clusterinst":{"deployment":"kubernetes","flavor":{"name":"m4.small"},"ip_access":1,"key":{"cloudlet_key":{"name":"automation-qa2-vcd-01","organization":"packet"},"cluster_key":{"name":"' + appname + '"},"organization":"MobiledgeX"},"num_masters":1,"num_nodes":1},"region":"US"}'
verify_cert = False
headers = {'Content-type': 'application/json', 'accept': 'application/json', 'Authorization': f'Bearer {token}'}
files = None
stream = True
timeout = timeout = (3.05, 1200)
#print(headers)

resp = requests.post(url, data, verify=verify_cert, headers=headers, files=files, stream=stream, timeout=timeout)
for line in resp.iter_lines():
   print(time.asctime(time.localtime()), line)

print(resp)
