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

import CloudFlare

cf_token = '***REMOVED***'
cf_user = 'mobiledgex.ops@mobiledgex.com'
cf_zone_name = 'mobiledgex.net'
dns_name = "311-480.dme.mobiledgex.net"
new_dns = 'eu-qa.dme.mobiledgex.net'

cf = CloudFlare.CloudFlare(email=cf_user, token=cf_token)

zoneid = cf.zones.get(params = {'name':cf_zone_name,'per_page':1})[0]['id']
print(zoneid)

dns_record = cf.zones.dns_records.get(zoneid, params = {'name':dns_name})[0]   #['content']
dns_ip = dns_record['content']
dns_record_id = dns_record['id']
print(dns_record)

update_record = {
            'name':dns_name,
            'type':'CNAME',
            'content':new_dns,
            'proxied':dns_record['proxied']
        }
dns_record_updated = cf.zones.dns_records.put(zoneid, dns_record_id, data=update_record)
print(dns_record_updated)
