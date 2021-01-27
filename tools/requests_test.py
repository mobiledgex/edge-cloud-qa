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
