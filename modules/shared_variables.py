import time
import random

#default_time_stamp = str(int(time.time()))
default_time_stamp = str(time.time()).replace('.', '-')
cloudlet_name_default = 'cloudlet' + default_time_stamp
operator_name_default = 'operator' + default_time_stamp
cluster_name_default = 'cluster' + default_time_stamp
app_name_default = 'app' + default_time_stamp
app_version_default = '1.0'
developer_name_default = 'developer' + default_time_stamp
flavor_name_default = 'flavor' + default_time_stamp
cluster_flavor_name_default = 'cluster_flavor' + default_time_stamp
latitude_default = 10
longitude_default = 10
number_dynamic_ips_default = 254
ip_support_default = 'IpSupportDynamic'
static_ips_default = '10.10.10.10'
access_uri_default = 'https://www.edgesupport.com/test'
session_cookie_default = ''
token_default = ''
token_server_uri_default = ''
crm_notify_server_address = '127.0.0.1:' + str(random.randint(6000, 7000))

