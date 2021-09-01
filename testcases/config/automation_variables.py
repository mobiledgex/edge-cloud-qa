test_timeout_crm = '32 min'
test_timeout_crm1 = '40 min'

cloudlet_name_azure = 'automationAzureCentralCloudlet'
cloudlet_name_gcp = 'automationGcpCentralCloudlet'
# cloudlet_name_openstack = 'automationHamburgCloudlet'
cloudlet_name_openstack = 'automationDusseldorfCloudlet'
cloudlet_name_openstack_shared = 'automationHamburgCloudlet'
cloudlet_name_openstack_dedicated = 'automationHamburgCloudlet'
cloudlet_name_openstack_vm = 'automationHamburgCloudlet'
cloudlet_name_openstack_metrics = 'automationHamburgCloudlet'
cloudlet_name_openstack_gpu = 'automationBonnCloudlet'
cloudlet_name_openstack_vgpu = 'automationHamburgCloudlet'
cloudlet_name_vmpool = 'automationVMPoolCloudlet'
cloudlet_name_vsphere = 'DFWVMW2'
cloudlet_name_openstack_packet = 'packet-qaregression'
cloudlet_name_openstack_ha1 = 'automationHamburgCloudlet'
cloudlet_name_openstack_ha2 = 'automationMunichCloudlet'
cloudlet_name_crm = 'automationHamburgCloudlet'
cloudlet_name_fake = 'tmocloud-1'
cloudlet_name_offline = 'automationBonnCloudlet'

master_node_flavor_default = 'automation_api_flavor'

region_packet = 'US'
region_vsphere = 'US'
region_gcp = 'US'
region_azure = 'US'

vmpool_name = 'automationVMPool'

app_name_automation = 'automation_api_app'
app_name_auth_automation = 'automation_api_auth_app'
developer_org_name_automation = 'automation_dev_org'
flavor_name_automation = 'automation_api_flavor'
alert_policy_name_automation = 'automation_api_alert_policy_name'

operator_name_azure = 'azure'
operator_name_gcp = 'gcp'
operator_name_vsphere = 'packet'
operator_name_openstack = 'TDG'
operator_name_openstack_packet = 'packet'
operator_name_vsphere = 'packet'
operator_name_crm = 'TDG'
operator_name_fake = 'tmus'

gitlab_server = 'docker-qa.mobiledgex.net'
gitlab_username = 'root'
gitlab_password = 'sandhill'

docker_image = 'docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:10.0'
docker_image_developer = 'MobiledgeX'
docker_image_facedetection = 'docker-qa.mobiledgex.net/mobiledgex/images/facedetection:latest'
docker_image_gpu = 'docker-qa.mobiledgex.net/mobiledgex/images/computervision-gpu:2020-09-22'
docker_image_samsung = 'docker-qa.mobiledgex.net/samsung/images/server_ping_threaded:10.0'
docker_image_cpu = 'docker-qa.mobiledgex.net/mobiledgex/images/cpu_generator:1.0'
docker_image_porttest = 'docker-qa.mobiledgex.net/mobiledgex/images/port_test_server:1.0'

artifactory_dummy_image_name = 'execJira.py'

qcow_centos_image = 'https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'
qcow_centos_image_notrunning = 'https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c'
qcow_windows_image = 'https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_windows2012.qcow2#md5:42171406daca80298098ac314200634a'
qcow_centos_openstack_image = 'server_ping_threaded_centos7'
qcow_gpu_ubuntu16_image = 'https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/ubuntu16_nvidia_gpu.qcow2#md5:ebefc158437895d0399802dac66b2f4f'
qcow_centos_image_nocloudinit = 'https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7_nocloudinit.qcow2#md5:1e0f1567f87c5867e4cd999a9a3eec3a'

server_ping_threaded_cloudconfig = 'http://35.199.188.102/apps/server_ping_threaded_cloudconfig.yml'
robotnik_manifest = 'http://35.199.188.102/apps/automation_robotnik.yml'
namespace_manifest = 'http://35.199.188.102/apps/automation_server_ping_threaded_namespaces.yml'

helm_image = 'https://resources.gigaspaces.com/helm-charts:gigaspaces/insightedge'

# vm_console_address =  'https://hamedgecloud.telekom.de:6080/vnc_auto.html'
vm_console_address = 'https://bonnedgecloud.telekom.de:6080/vnc_auto.html'

mextester99_gmail_password = 'rfbixqomqidobmcb'
mextester06_gmail_password = 'thequickbrownfoxjumpedoverthelazydog9$'
mexadmin_password = 'mexadminfastedgecloudinfra'
admin_manager_username = 'qaadmin'
admin_manager_password = mexadmin_password
admin_manager_email = 'mxdmnqa@gmail.com'
op_manager_user_automation = 'op_manager_automation'
op_contributor_user_automation = 'op_contributor_automation'
op_viewer_user_automation = 'op_viewer_automation'
dev_manager_user_automation = 'dev_manager_automation'
dev_contributor_user_automation = 'dev_contributor_automation'
dev_viewer_user_automation = 'dev_viewer_automation'
op_manager_password_automation = 'thequickbrownfoxjumpedoverthelazydog9$'
op_contributor_password_automation = op_manager_password_automation
op_viewer_password_automation = op_manager_password_automation
dev_manager_password_automation = op_manager_password_automation
dev_contributor_password_automation = op_manager_password_automation
dev_viewer_password_automation = op_manager_password_automation

token_server_url = 'http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc'
expired_cookie = 'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1ODQ1NzQ5MDIsImlhdCI6MTU4NDQ4ODUwMiwia2V5Ijp7InBlZXJpcCI6IjEwLjI0MC4wLjQiLCJvcmduYW1lIjoiU2Ftc3VuZyIsImFwcG5hbWUiOiJTYW1zdW5nRW5hYmxpbmdMYXllciIsImFwcHZlcnMiOiIxLjAiLCJ1bmlxdWVpZHR5cGUiOiJkbWUta3N1aWQiLCJ1bmlxdWVpZCI6IjFaSEdGVlFKNERxUXdnWUlvTlVLVnNZTjJ5ZyIsImtpZCI6Mn19.WK_vIYpsjlgtzRznPOd0PMwRytxA6dzI62OKV2upQM1-51hfVMZQANPpzckbkJgai5imvARQAYshlMZR9w8KkQ'

# vm_public_key = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrHlOJOJUqvd4nEOXQbdL8ODKzWaUxKVY94pF7J3diTxgZ1NTvS6omqOjRS3loiU7TOlQQU4cKnRRnmJW8QQQZSOMIGNrMMInGaEYsdm6+tr1k4DDfoOrkGMj3X/I2zXZ3U+pDPearVFbczCByPU0dqs16TWikxDoCCxJRGeeUl7duzD9a65bI8Jl+zpfQV+I7OPa81P5/fw15lTzT4+F9MhhOUVJ4PFfD+d6/BLnlUfZ94nZlvSYnT+GoZ8xTAstM7+6pvvvHtaHoV4YqRf5CelbWAQ162XNa9/pW5v/RKDrt203/JEk3e70tzx9KAfSw2vuO1QepkCZAdM9rQoCd ubuntu@registry'
# vm_public_key = '-----BEGIN RSA PUBLIC KEY-----\nMIIBCgKCAQEAqx5TiTiVKr3eJxDl0G3S/Dgys1mlMSlWPeKReyd3Yk8YGdTU70uq\nJqjo0Ut5aIlO0zpUEFOHCp0UZ5iVvEEEGUjjCBjazDCJxmhGLHZuvra9ZOAw36Dq\n5BjI91/yNs12d1PqQz3mq1RW3Mwgcj1NHarNek1opMQ6AgsSURnnlJe3bsw/WuuW\nyPCZfs6X0FfiOzj2vNT+f38NeZU80+PhfTIYTlFSeDxXw/nevwS55VH2feJ2Zb0m\nJ0/hqGfMUwLLTO/uqb77x7Wh6FeGKkX+QnpW1gENetlzWvf6Vub/0Sg67dtN/yRJ\nN3u9Lc8fSgH0sNr7jtUHqZAmQHTPa0KAnQIDAQAB\n-----END RSA PUBLIC KEY-----'

vm_public_key = '-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij\nTkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0\nVU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC\nGJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS\nz3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m\nQnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C\n/QIDAQAB\n-----END PUBLIC KEY-----'

app_auth_public_key = '-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0Spdynjh+MPcziCH2Gij\nTkK9fspTH4onMtPTgxo+MQC+OZTwetvYFJjGV8jnYebtuvWWUCctYmt0SIPmA0F0\nVU6qzSlrBOKZ9yA7Rj3jSQtNrI5vfBIzK1wPDm7zuy5hytzauFupyfboXf4qS4uC\nGJCm9EOzUSCLRryyh7kTxa4cYHhhTTKNTTy06lc7YyxBsRsN/4jgxjjkxe3J0SfS\nz3eaHmfFn/GNwIAqy1dddTJSPugRkK7ZjFR+9+sscY9u1+F5QPwxa8vTB0U6hh1m\nQnhVd1d9osRwbyALfBY8R+gMgGgEBCPYpL3u5iSjgD6+n4d9RQS5zYRpeMJ1fX0C\n/QIDAQAB\n-----END PUBLIC KEY-----'

gpu_client = 'multi_client.py'
gpu_client_path = '../edge-cloud-sampleapps/ComputerVisionServer/moedx/client'
gpu_client_image = '3_bodies.png'

# alert receiver
slack_channel = '#qa-alertreceiver'
slack_api_url = 'https://hooks.slack.com/services/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'
# pagerduty_key = 'R012YDFZXKFQ4OTD0TDE9JNYM1Y2M97I'
# pagerduty_key = '8048c9a8e470430dc0ad9605c7fb00a0'  # free account
pagerduty_key = 'd1bdad0245364905c0e25090ce357f30'  # paid account

trust_policy_server = '35.199.188.102'
