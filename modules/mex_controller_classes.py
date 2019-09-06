import shared_variables

class Organization():
    organization = None

    def __init__(self, organization_name=None, organization_type=None, phone=None, address=None, use_defaults=True):
        org_dict = {}

        self.org_name = organization_name
        self.org_type = organization_type
        self.phone = phone
        self.address = address

        if use_defaults:
            if organization_name is None: self.org_name = shared_variables.organization_name_default
            if phone is None: self.phone = shared_variables.phone_default
            if address is None: self.address = shared_variables.address_default
            if organization_type is None: self.org_type = shared_variables.organization_type_default

        #shared_variables.flavor_name_default = self.flavor_name

        if self.org_name is not None:
            org_dict['name'] = self.org_name
        if self.phone is not None:
            org_dict['phone'] = self.phone
        if self.address is not None:
            org_dict['address'] = self.address
        if self.org_type is not None:
            org_dict['type'] = self.org_type

        self.organization = org_dict

class Flavor():
    flavor = None
    
    def __init__(self, flavor_name=None, ram=None, vcpus=None, disk=None, use_defaults=True):
        flavor_dict = {}

        self.flavor_name = flavor_name
        self.ram = ram
        self.vcpus = vcpus
        self.disk = disk

        if use_defaults:
            if flavor_name is None: self.flavor_name = shared_variables.flavor_name_default
            if ram is None: self.ram = 1024 
            if vcpus is None: self.vcpus = 1 
            if disk is None: self.disk = 1

        shared_variables.flavor_name_default = self.flavor_name

        #"{\"flavor\":{\"key\":{\"name\":\"uu\"},\"ram\":1,\"vcpus\":1,\"disk\":1}}", "resp": "{}", "took": "85.424786ms"}
        
        if self.flavor_name is not None:
            flavor_dict['key'] = {'name': self.flavor_name}
        if self.ram is not None:
            flavor_dict['ram'] = int(self.ram)
        if self.vcpus is not None:
            flavor_dict['vcpus'] = int(self.vcpus)
        if self.disk is not None:
            flavor_dict['disk'] = int(self.disk)

        
        self.flavor = flavor_dict

class Cloudlet():
    cloudlet = None
    
    def __init__(self, cloudlet_name=None, operator_name=None, number_dynamic_ips=None, latitude=None, longitude=None, ip_support=None, access_uri=None, static_ips=None, platform_type=None, physical_name=None, use_defaults=True):

        self.cloudlet_name = cloudlet_name
        self.operator_name = operator_name
        self.access_uri = access_uri
        self.latitude = latitude
        self.longitude = longitude
        self.ip_support = ip_support
        self.static_ips = static_ips
        self.number_dynamic_ips = number_dynamic_ips
        self.platform_type = platform_type
        self.physical_name = physical_name
        
        if use_defaults:
            if cloudlet_name is None: self.cloudlet_name = shared_variables.cloudlet_name_default
            if operator_name is None: self.operator_name = shared_variables.operator_name_default
            if latitude is None: self.latitude = shared_variables.latitude_default
            if longitude is None: self.longitude = shared_variables.longitude_default
            if number_dynamic_ips is None: self.number_dynamic_ips = shared_variables.number_dynamic_ips_default
            if ip_support is None: self.ip_support = shared_variables.ip_support_default
            #if accessuri is None: self.accessuri = shared_variables.access_uri_default
            #if staticips is None: self.staticips = shared_variables.static_ips_default

        if self.ip_support == "IpSupportUnknown":
            self.ip_support = 0
        if self.ip_support == "IpSupportStatic":
            self.ip_support = 1
        if self.ip_support == "IpSupportDynamic":
            self.ip_support = 2

        #"{\"cloudlet\":{\"key\":{\"operator_key\":{\"name\":\"rrrr\"},\"name\":\"rrrr\"},\"location\":{\"latitude\":5,\"longitude\":5,\"timestamp\":{}},\"ip_support\":2,\"num_dynamic_ips\":2}}"
        cloudlet_dict = {}
        cloudlet_key_dict = {}
        if self.operator_name is not None:
            cloudlet_key_dict['operator_key'] = {'name': self.operator_name}
        if self.cloudlet_name is not None:
            cloudlet_key_dict['name'] = self.cloudlet_name

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if cloudlet_key_dict:
            cloudlet_dict['key'] = cloudlet_key_dict
        if loc_dict:
            cloudlet_dict['location'] = loc_dict
        if self.number_dynamic_ips is not None:
            cloudlet_dict['num_dynamic_ips'] = int(self.number_dynamic_ips)
        if self.ip_support is not None:
            cloudlet_dict['ip_support'] = self.ip_support
        #if self.accessuri is not None:
        #    cloudlet_dict['access_uri'] = self.accessuri
        #    _fields_list.append(self._cloudlet_accessuri_field)
        #if self.staticips is not None:
        #    cloudlet_dict['static_ips'] = self.staticips
        #    _fields_list.append(self._cloudlet_staticips_field)

        if self.physical_name is not None:
            cloudlet_dict['physical_name'] = self.physical_name
        if self.platform_type is not None:
            cloudlet_dict['platform_type'] = self.platform_type

        self.cloudlet = cloudlet_dict

class ClusterInstance():
    def __init__(self, operator_name=None, cluster_name=None, cloudlet_name=None, developer_name=None, flavor_name=None, liveness=None, ip_access=None, number_masters=None, number_nodes=None, crm_override=None, deployment=None, use_defaults=True):

        self.cluster_instance = None

        self.cluster_name = cluster_name
        self.operator_name = operator_name
        self.cloudlet_name = cloudlet_name
        self.flavor_name = flavor_name
        self.crm_override = crm_override
        self.liveness = liveness
        self.ip_access = ip_access
        self.developer_name = developer_name
        self.number_masters = number_masters
        self.number_nodes = number_nodes
        self.deployment = deployment
        #self.liveness = 1
        #if liveness is not None:
        #    self.liveness = liveness # LivenessStatic

        print("Liveness", self.liveness)    
        self.state = 5    # Ready

        if cluster_name == 'default':
            self.cluster_name = shared_variables.cluster_name_default
            
        if use_defaults:
            if cluster_name is None: self.cluster_name = shared_variables.cluster_name_default
            if cloudlet_name is None: self.cloudlet_name = shared_variables.cloudlet_name_default
            if operator_name is None: self.operator_name = shared_variables.operator_name_default
            if flavor_name is None: self.flavor_name = shared_variables.flavor_name_default
            if developer_name is None: self.developer_name = shared_variables.developer_name_default
            if liveness is None: self.liveness = 1
            if number_masters is None: self.number_masters = 1
            if number_nodes is None: self.number_nodes = 1

        if self.liveness == 'LivenessStatic':
            self.liveness = 1
        elif self.liveness == 'LivenessDynamic':
            self.liveness = 2

        if self.ip_access == 'IpAccessUnknown':
            self.ip_access = 0
        elif self.ip_access == 'IpAccessDedicated':
            self.ip_access = 1
        elif self.ip_access == 'IpAccessDedicatedOrShared':
            self.ip_access = 2
        elif self.ip_access == 'IpAccessShared':
            self.ip_access = 3

        clusterinst_dict = {}
        clusterinst_key_dict = {}
        operator_dict = {}
        cloudlet_key_dict = {}
        #cluster_key_dict = {}

        shared_variables.cluster_name_default = self.cluster_name
        shared_variables.cloudlet_name_default = self.cloudlet_name
        shared_variables.operator_name_default = self.operator_name
        shared_variables.flavor_name_default = self.flavor_name

        if self.operator_name is not None:
            cloudlet_key_dict['operator_key'] = {'name': self.operator_name}
        if self.cloudlet_name:
            cloudlet_key_dict['name'] = self.cloudlet_name
            
        if self.cluster_name:
            clusterinst_key_dict['cluster_key'] = {'name': self.cluster_name}
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_key_dict
        if self.developer_name is not None:
            clusterinst_key_dict['developer'] = self.developer_name

        if clusterinst_key_dict:
            clusterinst_dict['key'] = clusterinst_key_dict
            
        if self.flavor_name is not None:
            clusterinst_dict['flavor'] = {'name': self.flavor_name}

        if self.liveness is not None:
            clusterinst_dict['liveness'] = self.liveness

        if self.ip_access is not None:
            clusterinst_dict['ip_access'] = self.ip_access

        if self.number_masters is not None:
            clusterinst_dict['num_masters'] = int(self.number_masters)

        if self.number_nodes is not None:
            clusterinst_dict['num_nodes'] = int(self.number_nodes)

        if self.crm_override:
            appinst_dict['crm_override'] = 1  # ignore errors from CRM

        if self.deployment is not None:
            clusterinst_dict['deployment'] = self.deployment
            
        print("ClusterInst Dict", clusterinst_dict)    

        self.cluster_instance = clusterinst_dict

class App():
    def __init__(self, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, include_fields=False, use_defaults=True):

        _fields_list = []

        self.app_name = app_name
        self.app_version = app_version
        self.developer_name = developer_name
        self.image_type = image_type
        self.image_path = image_path
        #self.config = config
        self.command = command
        self.default_flavor_name = default_flavor_name
        #self.cluster_name = cluster_name
        #self.ip_access = ip_access
        self.access_ports = access_ports
        self.auth_public_key = auth_public_key
        self.permits_platform_apps = permits_platform_apps
        self.deployment = deployment
        self.deployment_manifest = deployment_manifest
        self.scale_with_cluster = scale_with_cluster
        self.official_fqdn = official_fqdn
        
        # used for UpdateApp - hardcoded from proto
        #self._deployment_manifest_field = str(app_pb2.App.DEPLOYMENT_MANIFEST_FIELD_NUMBER)
        #self._access_ports_field = str(app_pb2.App.ACCESS_PORTS_FIELD_NUMBER)

        if use_defaults:
            if app_name is None: self.app_name = shared_variables.app_name_default
            if developer_name is None: self.developer_name = shared_variables.developer_name_default
            if app_version is None: self.app_version = shared_variables.app_version_default
            if image_type is None: self.image_type = 'ImageTypeDocker'
            #if cluster_name is None: self.cluster_name = shared_variables.cluster_name_default
            if default_flavor_name is None: self.default_flavor_name = shared_variables.flavor_name_default
            #if ip_access is None: self.ip_access = 3 # default to shared
            if access_ports is None: self.access_ports = 'tcp:1234'
            
            if self.image_type == 'ImageTypeDocker':
                if self.image_path is None:
                    self.image_path='docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
                    #try:
                    #    new_app_name = self._docker_sanitize(self.app_name)
                    #    if self.developer_name is not None:
                    #        self.image_path = 'registry.mobiledgex.net:5000/' + self.developer_name + '/' + new_app_name + ':' + self.app_version
                    #    else:
                    #        self.image_path = 'registry.mobiledgex.net:5000/' + '/' + new_app_name + ':' + self.app_version
                    #except:
                    #    self.image_path = 'failed_to_set'
                #self.image_type = 1
            elif self.image_type == 'ImageTypeQCOW':
                if self.image_path is None:
                    self.image_path = 'https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d'
                #self.image_type = 2


        if self.image_type == 'ImageTypeDocker':
            self.image_type = 1
        elif self.image_type == 'ImageTypeQCOW':
            self.image_type = 2
        elif self.image_type == 'ImageTypeUnknown':
            self.image_type = 0

        if self.app_name == 'default':
            self.app_name = shared_variables.app_name_default
        if self.app_version == 'default':
            self.app_version = shared_variables.app_version_default
        if self.developer_name == 'default':
            self.developer_name = shared_variables.developer_name_default
        #if self.cluster_name == 'default':
        #    self.cluster_name = shared_variables.cluster_name_default
        if self.default_flavor_name == 'default':
            self.default_flavor_name = shared_variables.flavor_name_default
        if self.image_path == 'default':
            self.image_path='docker.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
            
        app_dict = {}
        app_key_dict = {}

        if self.app_name is not None:
            app_key_dict['name'] = self.app_name
        if self.app_version:
            app_key_dict['version'] = self.app_version
        if self.developer_name is not None:
            app_key_dict['developer_key'] = {'name': self.developer_name}

        if 'name' in app_key_dict or self.app_version or 'developer_key' in app_key_dict:
            app_dict['key'] = app_key_dict
        if self.image_type is not None:
            app_dict['image_type'] = self.image_type
        if self.image_path is not None:
            app_dict['image_path'] = self.image_path
        #if self.ip_access:
        #    app_dict['ip_access'] = self.ip_access
        #if self.cluster_name is not None:
        #    app_dict['cluster'] = cluster_pb2.ClusterKey(name = self.cluster_name)
        if self.default_flavor_name is not None:
            app_dict['default_flavor'] = {'name': self.default_flavor_name}
        if self.access_ports:
            app_dict['access_ports'] = self.access_ports
            #_fields_list.append(self._access_ports_field)
        #if self.config:
        #    app_dict['config'] = self.config
        #else:
        #    self.config = ''
        if self.command is not None:
            app_dict['command'] = self.command
        if self.auth_public_key is not None:
            app_dict['auth_public_key'] = self.auth_public_key
        if self.permits_platform_apps is not None:
            app_dict['permits_platform_apps'] = self.permits_platform_apps
        if self.deployment is not None:
            app_dict['deployment'] = self.deployment
        if self.deployment_manifest is not None:
            app_dict['deployment_manifest'] = self.deployment_manifest
            #_fields_list.append(self._deployment_manifest_field)
        if self.scale_with_cluster:
            app_dict['scale_with_cluster'] = True
        if self.official_fqdn:
            app_dict['official_fqdn'] = self.official_fqdn
            
        print(app_dict)
        self.app = app_dict

        shared_variables.app_name_default = self.app_name
        
        #if include_fields:
        #    for field in _fields_list:
        #        self.app.fields.append(field)

class AppInstance():
    def __init__(self, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, cluster_instance_name=None, cluster_instance_developer_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, use_defaults=True):
        self.appinst_id = appinst_id
        self.app_name = app_name
        self.app_version = app_version
        self.developer_name = developer_name
        self.cluster_developer_name = cluster_instance_developer_name
        self.operator_name = operator_name
        self.cloudlet_name = cloudlet_name
        self.uri = uri
        self.flavor_name = flavor_name
        self.cluster_name = cluster_instance_name
        self.latitude = latitude
        self.longitude = longitude
        self.crm_override = crm_override
        self.autocluster_ipaccess = autocluster_ip_access
        
        if self.app_name == 'default':
            self.app_name = shared_variables.app_name_default
        if self.developer_name == 'default':
            self.developer_name = shared_variables.developer_name_default
        if self.app_version == 'default':
            self.app_version = shared_variables.app_version_default
        if self.operator_name == 'default':
            self.operator_name = shared_variables.operator_name_default
        if self.cloudlet_name == 'default' and self.operator_name != 'developer':  # special case for samsung where they use operator=developer and cloudlet=default
            self.cloudlet_name = shared_variables.cloudlet_name_default

        if use_defaults:
            if not app_name: self.app_name = shared_variables.app_name_default
            #if not cluster_instance_developer_name: self.developer_name = shared_variables.developer_name_default
            if not developer_name: self.developer_name = shared_variables.developer_name_default
            if not cluster_instance_name: self.cluster_name = shared_variables.cluster_name_default
            if not cluster_instance_developer_name: self.cluster_developer_name = shared_variables.developer_name_default
            if not app_version: self.app_version = shared_variables.app_version_default
            if not cloudlet_name: self.cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_name: self.operator_name = shared_variables.operator_name_default

        if self.cluster_name == 'default':
            self.cluster_name = shared_variables.cluster_name_default

        if self.autocluster_ipaccess == 'IpAccessUnknown':
            self.autocluster_ipaccess = 0
        elif self.autocluster_ipaccess == 'IpAccessDedicated':
            self.autocluster_ipaccess = 1
        elif self.autocluster_ipaccess == 'IpAccessDedicatedOrShared':
            self.autocluster_ipaccess = 2
        elif self.autocluster_ipaccess == 'IpAccessShared':
            self.autocluster_ipaccess = 3

        shared_variables.operator_name_default = self.operator_name

        appinst_dict = {}
        appinst_key_dict = {}
        app_key_dict = {}
        cloudlet_key_dict = {}
        clusterinst_key_dict = {}
        cluster_key_dict = {}
        loc_dict = {}
        
        if self.app_name:
            app_key_dict['name'] = self.app_name
        if self.app_version:
            app_key_dict['version'] = self.app_version
        if self.developer_name is not None:
            app_key_dict['developer_key'] = {'name': self.developer_name}
        print('*WARN*', 'apdict', app_key_dict)
        if self.cluster_name is not None:
            #clusterinst_key_dict['cluster_key'] = clusterinst_pb2.ClusterInstKey(name = self.cluster_name)
            cluster_key_dict['name'] = self.cluster_name
        #if self.developer_name is not None:
        #    clusterinst_key_dict['developer'] = self.developer_name
        if self.cloudlet_name is not None:
            cloudlet_key_dict['name'] = self.cloudlet_name
        if self.operator_name is not None:
            cloudlet_key_dict['operator_key'] = {'name': self.operator_name}
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_key_dict
        if cluster_key_dict:
            clusterinst_key_dict['cluster_key'] = cluster_key_dict
        if self.cluster_developer_name is not None:
            clusterinst_key_dict['developer'] = self.cluster_developer_name
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)
        if loc_dict is not None:
            appinst_dict['cloudlet_loc'] = loc_dict

        if app_key_dict:
            appinst_key_dict['app_key'] = app_key_dict
        if clusterinst_key_dict:
            appinst_key_dict['cluster_inst_key'] = clusterinst_key_dict
        #if cloudlet_key_dict:
        #    appinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict) 
        #if self.appinst_id is not None:
        #    appinst_key_dict['id'] = int(self.appinst_id)


        if appinst_key_dict:
            appinst_dict['key'] = appinst_key_dict
        
        if self.uri is not None:
            appinst_dict['uri'] = self.uri
        if self.flavor_name is not None:
            appinst_dict['flavor'] = {'name': self.flavor_name}
        if self.autocluster_ipaccess is not None:
            appinst_dict['auto_cluster_ip_access'] = self.autocluster_ipaccess 

        if self.crm_override:
            appinst_dict['crm_override'] = 1  # ignore errors from CRM
            
        self.app_instance = appinst_dict

class RunCommand():
    def __init__(self, command=None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, cluster_instance_name=None, cluster_instance_developer_name=None, use_defaults=True):
        self.app_name = app_name
        self.app_version = app_version
        self.developer_name = developer_name
        self.cluster_developer_name = cluster_instance_developer_name
        self.operator_name = operator_name
        self.cloudlet_name = cloudlet_name
        self.cluster_name = cluster_instance_name
        
        if use_defaults:
            if not app_name: self.app_name = shared_variables.app_name_default
            if not developer_name: self.developer_name = shared_variables.developer_name_default
            if not cluster_instance_name: self.cluster_name = shared_variables.cluster_name_default
            if not cluster_instance_developer_name: self.cluster_developer_name = shared_variables.developer_name_default
            if not app_version: self.app_version = shared_variables.app_version_default
            if not cloudlet_name: self.cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_name: self.operator_name = shared_variables.operator_name_default

        runcommand_dict = {}
        appinst_key_dict = {}
        app_key_dict = {}
        cloudlet_key_dict = {}
        clusterinst_key_dict = {}
        cluster_key_dict = {}
        
        #if self.app_name:
        #    app_key_dict['name'] = self.app_name
        #if self.app_version:
        #    app_key_dict['version'] = self.app_version
        #if self.developer_name is not None:
        #    app_key_dict['developerkey'] = {'name': self.developer_name}

        #if self.cluster_name is not None:
        #    cluster_key_dict['name'] = self.cluster_name
        #if self.cloudlet_name is not None:
        #    cloudlet_key_dict['name'] = self.cloudlet_name
        #if self.operator_name is not None:
        #    cloudlet_key_dict['operatorkey'] = {'name': self.operator_name}
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudletkey'] = cloudlet_key_dict
        #if cluster_key_dict:
        #    clusterinst_key_dict['clusterkey'] = cluster_key_dict
        #if self.cluster_developer_name is not None:
        #    clusterinst_key_dict['developer'] = self.cluster_developer_name

        #if app_key_dict:
        #    appinst_key_dict['appkey'] = app_key_dict
        #if clusterinst_key_dict:
        #    appinst_key_dict['clusterinstkey'] = clusterinst_key_dict

        #if appinst_key_dict:
        #    runcommand_dict['appinstkey'] = appinst_key_dict
        
        if command is not None:
            runcommand_dict['command'] = command
            runcommand_dict['cloudlet_loc'] = {}
        self.run_command = runcommand_dict
