import time

timestamp = str(time.time()).replace('.','')

test_timeout = '32 min'

region = 'EU'

app_name = 'app' + timestamp
cluster_name = 'cluster' + timestamp

app_name_dockerdedicated = app_name + 'dockerdedicated'
app_name_dockershared = app_name + 'dockershared'
app_name_k8sdedicated = app_name + 'k8sdedicated'
app_name_k8sshared = app_name + 'k8sshared'
app_name_vm = app_name + 'vm'

cluster_name_dockerdedicated = cluster_name + 'dockerdedicated'
cluster_name_dockershared = cluster_name + 'dockershared'
cluster_name_k8sdedicated = cluster_name + 'k8sdedicated'
cluster_name_k8sshared = cluster_name + 'k8sshared'

# these are used to calculated how long the cluster has been up. primarily for metrics tests
cluster_name_dockerdedicated_endtime = 0
cluster_name_dockershared_endtime = 0
cluster_name_k8sdedicated_endtime = 0
cluster_name_k8sshared_endtime = 0

cloudlet_name_openstack = 'verificationCloudlet'
operator_name_openstack = 'TDG'
physical_name_openstack = 'dusseldorf'

cloudlet_name_openstack_metrics = 'montreal-pitfield'

cloudlet_latitude = '45.5017'
cloudlet_longitude = '-73.5673'

cluster_name = 'cluster' + timestamp

docker_image = 'docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:6.0'

qcow_centos_image = 'https://artifactory-qa.mobiledgex.net/artifactory/repo-mobiledgex/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'
#qcow_centos_image_notrunning = 'https://artifactory.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_notrunning_centos7.qcow2#md5:7a08091f71f1e447ce291e467cc3926c'
#qcow_windows_image = 'https://artifactory.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_windows2012.qcow2#md5:42171406daca80298098ac314200634a'
#qcow_centos_openstack_image = 'server_ping_threaded_centos7'

http_page = 'automation.html'

token_server_url = 'http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc'

