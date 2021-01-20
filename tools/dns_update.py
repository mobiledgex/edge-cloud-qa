import CloudFlare

cf_token = '60632181cb3b7419304ffa820b2d99e292092'
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
