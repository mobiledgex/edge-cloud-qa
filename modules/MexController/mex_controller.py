import grpc
import sys
import copy
import os
import time
import logging
from pprint import pprint
import controller_pb2
import controller_pb2_grpc
import cluster_pb2
import cluster_pb2_grpc
import clusterinst_pb2
import clusterinst_pb2_grpc
import cloudlet_pb2
import cloudlet_pb2_grpc
import operator_pb2
import operator_pb2_grpc
import flavor_pb2
import flavor_pb2_grpc
import app_pb2
import app_pb2_grpc
import developer_pb2
import developer_pb2_grpc
import clusterflavor_pb2
import clusterflavor_pb2_grpc
import app_inst_pb2
import app_inst_pb2_grpc
import loc_pb2
import loc_pb2_grpc

import shared_variables

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_controller')

#default_time_stamp = str(int(time.time()))
#cloudlet_name_default = 'cloudlet' + default_time_stamp
#operator_name_default = 'operator' + default_time_stamp
#cluster_name_default = 'cluster' + default_time_stamp
#app_name_default = 'app' + default_time_stamp
#app_version_default = '1.0'
#developer_name_default = 'developer' + default_time_stamp
#flavor_name_default = 'flavor' + default_time_stamp
#cluster_flavor_name_default = 'cluster_flavor' + default_time_stamp

class Developer():
    def __init__(self, developer_name=None, developer_address=None, developer_email=None, developer_passhash=None, developer_username=None, include_fields=False, use_defaults=True):
        #global developer_name_default
        
        dev_dict = {}
        _fields_list = []

        self.developer_name = developer_name
        self.developer_address = developer_address
        self.developer_email = developer_email
        self.developer_passhash = developer_passhash
        self.developer_username = developer_username

        # used for UpdateDeveloper - hardcoded from proto
        self._developer_name_field = str(developer_pb2.Developer.KEY_FIELD_NUMBER) + '.' + str(developer_pb2.DeveloperKey.NAME_FIELD_NUMBER)
        self._developer_username_field = str(developer_pb2.Developer.USERNAME_FIELD_NUMBER)
        self._developer_passhash_field = str(developer_pb2.Developer.PASSHASH_FIELD_NUMBER)
        self._developer_address_field = str(developer_pb2.Developer.ADDRESS_FIELD_NUMBER)
        self._developer_email_field = str(developer_pb2.Developer.EMAIL_FIELD_NUMBER)

        #print('key', vars(developer_pb2.Developer))
        #print('fields', developer_pb2.DeveloperKey._fields, dir(developer_pb2.DeveloperKey))
        #pprint(vars(developer_pb2.Developer))
        ##pprint(vars(developer_pb2.Developer.fields))
        #print('emailfield', developer_pb2.Developer.KEY_FIELD_NUMBER, developer_pb2.DeveloperKey.NAME_FIELD_NUMBER)
        #print('devfield', self._developer_name_field)
        #sys.exit(1)

        if use_defaults:
            if not developer_name: self.developer_name = shared_variables.developer_name_default

        shared_variables.developer_name_default = self.developer_name
        
        if self.developer_name is not None:
            dev_dict['key'] = developer_pb2.DeveloperKey(name=self.developer_name)
            _fields_list.append(self._developer_name_field)
        if developer_address is not None:
            dev_dict['address'] = developer_address
            _fields_list.append(self._developer_address_field)
        else:
            self.developer_address = ''
        if developer_email is not None:
            dev_dict['email'] = developer_email
            _fields_list.append(self._developer_email_field)
        else:
            self.developer_email = ''
        if developer_passhash is not None:
            dev_dict['passhash'] = developer_passhash
            _fields_list.append(self._developer_passhash_field)
        else:
            self.developer_passhash = ''
        if developer_username is not None:
            dev_dict['username'] = developer_username
            _fields_list.append(self._developer_username_field)
        else:
            self.developer_username = ''
        #dev_dict['fields'] = 'andy'
        #print(dev_dict)
        self.developer = developer_pb2.Developer(**dev_dict)
        
        if include_fields:
            for field in _fields_list:
                self.developer.fields.append(field)
        
    def __eq__(self, c):
        #print('c',c.address, 'a',self.developer_address)
        if c.key.name == self.developer_name and c.address == self.developer_address and c.email == self.developer_email and c.username == self.developer_username and c.passhash == self.developer_passhash:
            #print('contains')
            return True

    def exists(self, op_list):
        logger.info('checking developer exists')
        
        found = False
        for c in op_list:
            #print('xxxx', c)
            #print('dddddd', self.developer)
            if self.__eq__(c):
                found = True
                logger.info('found developer')
                break
        if not found:
            logger.error('ERROR: developer NOT found')
        return found

class Operator():
    def __init__(self, operator_name=None, use_defaults=False):
        op_dict = {}
        self.operator_name = operator_name

        if use_defaults:
            self.operator_name = operator_name_default
            
        if self.operator_name is not None:
            op_dict['key'] = operator_pb2.OperatorKey(name = self.operator_name)

        self.operator= operator_pb2.Operator(**op_dict)

    def __eq__(self, c):
        if c.key.name == self.operator_name:
            #print('contains')
            return True

    def exists(self, op_list):
        logger.info('checking operator exists')
        
        found = False
        for c in op_list:
            if self.__eq__(c):
                found = True
                logger.info('operator found')
                break
        if not found:
            logger.error('ERROR: operator NOT found')
        return found

class Flavor():
    def __init__(self, flavor_name=None, ram=None, vcpus=None, disk=None, use_defaults=True):
        flavor_dict = {}

        #global flavor_name_default
        
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

        if self.flavor_name is not None:
            flavor_dict['key'] = key = flavor_pb2.FlavorKey(name = self.flavor_name)
        if self.ram is not None:
            flavor_dict['ram'] = int(self.ram)
        if self.vcpus is not None:
            flavor_dict['vcpus'] = int(self.vcpus)
        if self.disk is not None:
            flavor_dict['disk'] = int(self.disk)

        self.flavor = flavor_pb2.Flavor(**flavor_dict)
        
    def __eq__(self, c):
        if c.key.name == self.flavor_name and c.ram == self.ram and c.vcpus == self.vcpus and c.disk == self.disk:
            return True

    def exists(self, op_list):
        logger.info('checking flavor exists')
        
        found = False
        for c in op_list:
            if self.__eq__(c):
                found = True
                logger.info('flavor found')
                break
        if not found:
            logger.error('ERROR: flavor NOT found')
        return found

class ClusterFlavor():
    def __init__(self, cluster_flavor_name=None, node_flavor_name=None, master_flavor_name=None, number_nodes=None,max_nodes=None, number_masters=None, use_defaults=True):
        #global cluster_flavor_name_default
        
        self.cluster_flavor_name = cluster_flavor_name
        self.node_flavor_name = node_flavor_name
        self.master_flavor_name = master_flavor_name
        self.number_nodes = number_nodes
        self.max_nodes = max_nodes
        self.number_masters = number_masters

        if use_defaults:
            if not cluster_flavor_name: self.cluster_flavor_name = shared_variables.cluster_flavor_name_default
            if not node_flavor_name: self.node_flavor_name = shared_variables.flavor_name_default
            if not master_flavor_name: self.master_flavor_name = shared_variables.flavor_name_default 
            if not number_nodes: self.number_nodes = 1
            if not max_nodes: self.max_nodes = 1
            if not number_masters: self.number_masters = 1

        shared_variables.cluster_flavor_name_default = self.cluster_flavor_name
        
        self.cluster_flavor = clusterflavor_pb2.ClusterFlavor(
                                                              key=clusterflavor_pb2.ClusterFlavorKey(name=self.cluster_flavor_name),
                                                              node_flavor=flavor_pb2.FlavorKey(name=self.node_flavor_name),
                                                              master_flavor=flavor_pb2.FlavorKey(name=self.master_flavor_name),
                                                              num_nodes=int(self.number_nodes),
                                                              max_nodes=int(self.max_nodes),
                                                              num_masters=int(self.number_masters)
                                                             )



class Cluster():
    def __init__(self, cluster_name=None, default_flavor_name=None, use_defaults=True):
        self.cluster_name = cluster_name
        self.flavor_name = default_flavor_name

        if cluster_name == 'default':
            self.cluster_name = shared_variables.cluster_name_default
            
        if use_defaults:
            if not cluster_name: self.cluster_name = shared_variables.cluster_name_default
            if not default_flavor_name: self.flavor_name = shared_variables.cluster_flavor_name_default

        self.cluster = cluster_pb2.Cluster(
                                      key = cluster_pb2.ClusterKey(name = self.cluster_name),
                                      default_flavor = clusterflavor_pb2.ClusterFlavorKey(name = self.flavor_name)
                                     )
    def __eq__(self, c):
        print(c.key.name, self.cluster_name, c.default_flavor.name, self.flavor_name)
        if c.key.name == self.cluster_name and c.default_flavor.name == self.flavor_name:
            #print('contains')
            return True

    def exists(self, cluster_list):
        logger.info('checking cluster exists')
        
        found_cluster = False
        #self.cluster_instance.state = 5 # Ready
        for c in cluster_list:
            #print('xxxx', c)
            #print('dddddd', self.cluster)
            #if self.cluster_instance == c:
            if self.__eq__(c):
                found_cluster = True
                logging.info('found cluster')
                break
        if not found_cluster:
            logger.error('ERROR: cluster NOT found')
        return found_cluster

class ClusterInstance():
    def __init__(self, operator_name=None, cluster_name=None, cloudlet_name=None, flavor_name=None, liveness=None, use_defaults=True):

        self.cluster_instance = None

        self.cluster_name = cluster_name
        self.operator_name = operator_name
        self.cloudlet_name = cloudlet_name
        self.flavor_name = flavor_name

        self.liveness = 1
        if liveness:
            self.liveness = liveness # LivenessStatic
        self.state = 5    # Ready

        if cluster_name == 'default':
            self.cluster_name = shared_variables.cluster_name_default
            
        if use_defaults:
            if not cluster_name: self.cluster_name = shared_variables.cluster_name_default
            if not cloudlet_name: self.cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_name: self.operator_name = shared_variables.operator_name_default
            if not flavor_name: self.flavor_name = shared_variables.cluster_flavor_name_default

        clusterinst_dict = {}
        clusterinst_key_dict = {}
        operator_dict = {}
        cloudlet_key_dict = {}
        #cluster_key_dict = {}

        if self.operator_name is not None:
            cloudlet_key_dict['operator_key'] = operator_pb2.OperatorKey(name = self.operator_name)
        if self.cloudlet_name:
            cloudlet_key_dict['name'] = self.cloudlet_name

        if self.cluster_name:
            clusterinst_key_dict['cluster_key'] = cluster_pb2.ClusterKey(name = self.cluster_name)
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict)

        if clusterinst_key_dict:
            clusterinst_dict['key'] = clusterinst_pb2.ClusterInstKey(**clusterinst_key_dict)

        if self.flavor_name is not None:
            clusterinst_dict['flavor'] = clusterflavor_pb2.ClusterFlavorKey(name = self.flavor_name)

        if self.liveness is not None:
            clusterinst_dict['liveness'] = self.liveness

        self.cluster_instance = clusterinst_pb2.ClusterInst(**clusterinst_dict)

#        if self.operator_name: 
#            operator_key = operator_pb2.OperatorKey(name = self.operator_name)
#        if self.cluster_name:
#            cluster_key = cluster_pb2.ClusterKey(name = self.cluster_name)
#        if self.cloudlet_name or self.operator_key:
#            cloudlet_key = cloudlet_pb2.CloudletKey(name = self.cloudlet_name,
#                                                    operator_key = self.operator_key)
#        if self.flavor_name is not None:
#            flavor = clusterflavor_pb2.ClusterFlavorKey(name = self.flavor_name)#
#
#        if cluster_key and cloudlet_key:
#            clusterinst_key = clusterinst_pb2.ClusterInstKey(cluster_key = self.cluster_key,
#                                                            cloudlet_key = self.cloudlet_key
#                                                           )
#        elif cluster_key:
#            clusterinst_key = clusterinst_pb2.ClusterInstKey(cluster_key = self.cluster_key)
#        elif cloudlet_key:
#            clusterinst_key = clusterinst_pb2.ClusterInstKey(cloudlet_key = self.cloudlet_key)#
#
#        if self.flavor and clusterinst_key and self.liveness is not None:
#            self.cluster_instance = clusterinst_pb2.ClusterInst(
#                                                                flavor = self.flavor,
#                                                                key = clusterinst_key,
#                                                                liveness = self.liveness
#                                                               )
#        elif self.flavor and clusterinst_key:
#            self.cluster_instance = clusterinst_pb2.ClusterInst(
#                                                                flavor = flavor,
#                                                                key = clusterinst_key
#                                                               )
#        elif flavor:
#            self.cluster_instance = clusterinst_pb2.ClusterInst(flavor = flavor)
#        elif clusterinst_key:
#            self.cluster_instance = clusterinst_pb2.ClusterInst(key = clusterinst_key)
#        else:
#             self.cluster_instance = clusterinst_pb2.ClusterInst()
        #print(self.cluster_instance)

    def __eq__(self, c):
        if c.key.cluster_key.name == self.cluster_name and c.key.cloudlet_key.operator_key.name == self.operator_name and c.key.cloudlet_key.name == self.cloudlet_name and c.flavor.name == self.flavor_name and c.state == self.state and c.liveness == self.liveness:
            #print('contains')

            return True

    def exists(self, cluster_instance_list):
        logger.info('checking cluster instance exists')
        found_cluster = False
        #self.cluster_instance.state = 5 # Ready
        for c in cluster_instance_list:
            #if self.cluster_instance == c:
            if self.__eq__(c):
                found_cluster = True
                logger.info('found cluster instance')
                break
        if not found_cluster:
            logger.error('ERROR: clusterinst NOT found')
        return found_cluster

class Cloudlet():
    def __init__(self, cloudlet_name=None, operator_name=None, number_of_dynamic_ips=None, latitude=None, longitude=None, use_defaults=True):
        #global cloudlet_name_default
        #global operator_name_default

        self.cloudlet_name = cloudlet_name
        self.operator_name = operator_name
        self.number_of_dynamic_ips = number_of_dynamic_ips
        self.latitude = latitude
        self.longitude = longitude

        if use_defaults:
            if not cloudlet_name: self.cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_name: self.operator_name = shared_variables.operator_name_default
            if not number_of_dynamic_ips: self.number_of_dynamic_ips = 254
            if not latitude: self.latitude = 10
            if not longitude: self.longitude = 10
            
        if cloudlet_name == 'default':
            self.cloudlet_name = shared_variables.cloudlet_name_default
        if operator_name == 'default':
            self.operator_name = shared_variables.operator_name_default
        if number_of_dynamic_ips == 'default':
            self.number_of_dynamic_ips = 254

        shared_variables.cloudlet_name_default = self.cloudlet_name
        shared_variables.operator_name_default = self.operator_name
        
        cloudlet_key_dict = {}
        if self.cloudlet_name:
            cloudlet_key_dict['name'] = self.cloudlet_name
        if self.operator_name:
            cloudlet_key_dict['operator_key'] = operator_pb2.OperatorKey(name = self.operator_name)

        loc_dict = {}
        if self.latitude:
            loc_dict['lat'] = float(self.latitude)
        if self.longitude:
            loc_dict['long'] = float(self.longitude)

        cloudlet_dict = {}
        if loc_dict:
            cloudlet_dict['location'] = loc_pb2.Loc(**loc_dict)
        if cloudlet_key_dict:
            cloudlet_dict['key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict)
        if self.number_of_dynamic_ips:
            cloudlet_dict['num_dynamic_ips'] = self.number_of_dynamic_ips
        self.cloudlet = cloudlet_pb2.Cloudlet(**cloudlet_dict)

class App():
    def __init__(self, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_name=None, default_flavor_name=None, config=None, command=None, app_template=None, use_defaults=True):
        self.app_name = app_name
        self.app_version = app_version
        self.developer_name = developer_name
        self.image_type = image_type
        self.image_path = image_path
        self.config = config
        self.command = command
        self.default_flavor_name = default_flavor_name
        self.cluster_name = cluster_name
        self.ip_access = ip_access
        
        if use_defaults:
            if app_name is None: self.app_name = shared_variables.app_name_default
            if developer_name is None: self.developer_name = shared_variables.developer_name_default
            if app_version is None: self.app_version = shared_variables.app_version_default
            if image_type is None: self.image_type = 'ImageTypeDocker'
            if cluster_name is None: self.cluster_name = shared_variables.cluster_name_default
            if default_flavor_name is None: self.default_flavor_name = shared_variables.flavor_name_default
            if ip_access is None: self.ip_access = 3 # default to shared
            
            if self.image_type == 'ImageTypeDocker':
                print('ssssssssssssssssss')
                if self.image_path is None:
                    try:
                        new_app_name = self._docker_sanitize(app_name)
                        self.image_path = 'mobiledgex_' + developer_name + '/' + new_app_name + ':' + app_version
                    except:
                        self.image_path = 'failed_to_set'
                #self.image_type = 1
            elif self.image_type == 'ImageTypeQCOW':
                if self.image_path is None:
                    self.image_path = 'qcow path not determined yet'
                #self.image_type = 2


        if self.image_type == 'ImageTypeDocker':
                self.image_type = 1
        elif self.image_type == 'ImageTypeQCOW':
                self.image_type = 2

        #self.ip_access = 3 # default to shared
        if ip_access == 'IpAccessDedicated':
            self.ip_access = 1
        elif ip_access == 'IpAccessDedicatedOrShared':
            self.ip_access = 2
        elif ip_access == 'IpAccessShared':
            self.ip_access = 3
            
        if access_ports is None:
            self.access_ports = ''
        else:
            self.access_ports = access_ports

        if self.app_name == 'default':
            self.app_name = app_name_default
        if self.developer_name == 'default':
            self.developer_name = developer_name_default
        if self.cluster_name == 'default':
            self.cluster_name = cluster_name_default
            
        app_dict = {}
        app_key_dict = {}

        if self.app_name is not None:
            app_key_dict['name'] = self.app_name
        if self.app_version:
            app_key_dict['version'] = self.app_version
        if self.developer_name is not None:
            app_key_dict['developer_key'] = developer_pb2.DeveloperKey(name=self.developer_name)

        if 'name' in app_key_dict or self.app_version or 'developer_key' in app_key_dict:
            app_dict['key'] = app_pb2.AppKey(**app_key_dict)
        if self.image_type is not None:
            app_dict['image_type'] = self.image_type
        if self.image_path is not None:
            app_dict['image_path'] = self.image_path
        if self.ip_access:
            app_dict['ip_access'] = self.ip_access
        if self.cluster_name is not None:
            app_dict['cluster'] = cluster_pb2.ClusterKey(name = self.cluster_name)
        if self.default_flavor_name is not None:
            app_dict['default_flavor'] = flavor_pb2.FlavorKey(name = self.default_flavor_name)
        if self.access_ports:
            app_dict['access_ports'] = self.access_ports
        if self.config:
            app_dict['config'] = self.config
        else:
            self.config = ''
        if self.command is not None:
            app_dict['command'] = self.command
            
        self.app = app_pb2.App(**app_dict)
        
        #self.app_complete = copy.copy(self.app)
        #self.app_complete.image_path = self.image_path
        
        #print('s',self.app)
        #print('sc', self.app_complete)
        #print('sd',self.app.__dict__,'esd')
        #print('sd2',self.app_complete.__dict__,'esd2')
        #sys.exit(1) 

    def __eq__(self, a):
        print('aaaaaaa',a.image_path,'bbbbbb',self.image_path)
        if a.key.name == self.app_name and a.key.version == self.app_version and a.image_path == self.image_path and a.ip_access == self.ip_access and a.access_ports == self.access_ports and a.default_flavor.name == self.default_flavor_name and a.cluster.name == self.cluster_name and a.image_type == self.image_type and a.config == self.config:
            #print('contains')
            return True
        

    def exists(self, app_list):
        logger.info('checking app exists')

        found_app = False
        
        for a in app_list:
            #print('xxxx', a.ip_access,'s',self.ip_access)
            #print('appp', a)
            #print('dddddd', self.app)
            if self.__eq__(a):
                found_app = True
                logger.info('found app')
                break
        if not found_app:
            logger.error('ERROR: app NOT found')
        return found_app

    def _docker_sanitize(self, name):
        str = name
        str = str.replace(' ', '')
        str = str.replace('&', '-')
        str = str.replace(',', '')
        str = str.replace('!', '.')

        return str
    
class AppInstance():
    def __init__(self, appinst_id = None, app_name=None, app_version=None, developer_name=None, cloudlet_name=None, operator_name=None, image_type=None, image_path=None, cluster_name=None, default_flavor_name=None, config=None, use_defaults=True):
        self.appinst_id = appinst_id
        self.app_name = app_name
        self.app_version = app_version
        self.developer_name = developer_name
        self.operator_name = operator_name
        self.cloudlet_name = cloudlet_name

        if self.app_name == 'default':
            self.app_name = shared_variables.app_name_default
        if self.developer_name == 'default':
            self.developer_name = shared_variables.developer_name_default
        if self.app_version == 'default':
            self.app_version = shared_variables.app_version_default
        if self.operator_name == 'default':
            self.operator_name = shared_variables.operator_name_default
        if self.cloudlet_name == 'default':
            self.cloudlet_name = shared_variables.cloudlet_name_default
            
        if use_defaults:
            if not app_name: self.app_name = shared_variables.app_name_default
            if not developer_name: self.developer_name = shared_variables.developer_name_default
            if not app_version: self.app_version = shared_variables.app_version_default
            if not cloudlet_name: self.cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_name: self.operator_name = shared_variables.operator_name_default

        appinst_dict = {}
        appinst_key_dict = {}
        app_key_dict = {}
        cloudlet_key_dict = {}

        if self.app_name:
            app_key_dict['name'] = self.app_name
        if self.app_version:
            app_key_dict['version'] = self.app_version
        if self.developer_name is not None:
            app_key_dict['developer_key'] = developer_pb2.DeveloperKey(name=self.developer_name)

        if self.cloudlet_name is not None:
            cloudlet_key_dict['name'] = self.cloudlet_name
        if self.operator_name is not None:
            cloudlet_key_dict['operator_key'] = operator_pb2.OperatorKey(name = self.operator_name)
 
        if app_key_dict:
            appinst_key_dict['app_key'] = app_pb2.AppKey(**app_key_dict)
        if cloudlet_key_dict:
            appinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict) 
        if appinst_id is not None:
            appinst_key_dict['id'] = appinst_id


        if appinst_key_dict:
            appinst_dict['key'] = app_inst_pb2.AppInstKey(**appinst_key_dict)
           
        self.app_instance = app_inst_pb2.AppInst(**appinst_dict)

        print(appinst_dict)
        print('s',self.app_instance)
        #sys.exit(1)

class Controller():
    def __init__(self, controller_address='127.0.0.1:55001', root_cert='mex-ca.crt', key='localserver.key', client_cert='localserver.crt'):
        controller_channel = None
        self.address = controller_address
        self.response = None
        self.prov_stack = []
        
        #print(sys.path)
        #f = self._findFile(root_cert)
        #print(f)
        #sys.exit(1)
        if root_cert:
            root_cert_real = self._findFile(root_cert)
            key_real = self._findFile(key)
            client_cert_real = self._findFile(client_cert)
            with open(root_cert_real, 'rb') as f:
                logger.debug('using root_cert=' + root_cert_real)
                #trusted_certs = f.read().encode()
                trusted_certs = f.read()
            with open(key_real,'rb') as f:
                logger.debug('using key='+key_real)
                trusted_key = f.read()
            with open(client_cert_real, 'rb') as f:
                logger.debug('using client cert=' + client_cert_real)
                cert = f.read()
            # create credentials
            credentials = grpc.ssl_channel_credentials(root_certificates=trusted_certs, private_key=trusted_key, certificate_chain=cert)
            controller_channel = grpc.secure_channel(controller_address, credentials)
        else:
                controller_channel = grpc.insecure_channel(controller_address)

        self.controller_stub = controller_pb2_grpc.ControllerApiStub(controller_channel)
        self.cluster_flavor_stub = clusterflavor_pb2_grpc.ClusterFlavorApiStub(controller_channel)
        self.cluster_stub = cluster_pb2_grpc.ClusterApiStub(controller_channel)
        self.clusterinst_stub = clusterinst_pb2_grpc.ClusterInstApiStub(controller_channel)
        self.cloudlet_stub = cloudlet_pb2_grpc.CloudletApiStub(controller_channel)
        self.flavor_stub = flavor_pb2_grpc.FlavorApiStub(controller_channel)
        self.app_stub = app_pb2_grpc.AppApiStub(controller_channel)
        self.dev_stub = developer_pb2_grpc.DeveloperApiStub(controller_channel)
        self.appinst_stub = app_inst_pb2_grpc.AppInstApiStub(controller_channel)
        self.operator_stub = operator_pb2_grpc.OperatorApiStub(controller_channel)
        self.developer_stub = developer_pb2_grpc.DeveloperApiStub(controller_channel)

    def show_controllers(self, address=None):
        logger.info('show controllers on {}. \n\t{}'.format(self.address, str(address).replace('\n','\n\t')))

        resp = None
        if address:
            resp = list(self.controller_stub.ShowController(controller_pb2.Controller(key = controller_pb2.ControllerKey(addr=address))))
        else:
            resp = list(self.controller_stub.ShowController(controller_pb2.Controller()))

        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('controller list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def create_cluster_flavor(self, cluster_flavor=None, **kwargs):
        resp = None

        if not cluster_flavor:
            cluster_flavor = ClusterFlavor(**kwargs).cluster_flavor

        logger.info('create cluster flavor on {}. \n\t{}'.format(self.address, str(cluster_flavor).replace('\n','\n\t')))

        resp = self.cluster_flavor_stub.CreateClusterFlavor(cluster_flavor)

        self.prov_stack.append(lambda:self.delete_cluster_flavor(cluster_flavor))
        
        return resp

    def delete_cluster_flavor(self, cluster_flavor):
        logger.info('delete cluster flavor on {}. \n\t{}'.format(self.address, str(cluster_flavor).replace('\n','\n\t')))

        resp = self.cluster_flavor_stub.DeleteClusterFlavor(cluster_flavor)

        return resp

    def show_cluster_flavors(self):
        logger.info('show cluster flavors on {}'.format(self.address))

        resp = list(self.cluster_flavor_stub.ShowClusterFlavor(clusterflavor_pb2.ClusterFlavor()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('cluster flavor list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def create_cluster(self, cluster=None, **kwargs):
        resp = None

        if not cluster:
            cluster = Cluster(**kwargs).cluster

        logger.info('create cluster on {}. \n\t{}'.format(self.address, str(cluster).replace('\n','\n\t')))

        resp = self.cluster_stub.CreateCluster(cluster)

        self.prov_stack.append(lambda:self.delete_cluster(cluster))
        
        return resp

    def delete_cluster(self, cluster):
        logger.info('delete cluster on {}. \n\t{}'.format(self.address, str(cluster).replace('\n','\n\t')))

        resp = self.cluster_stub.DeleteCluster(cluster)

        return resp

    def show_clusters(self):
        logger.info('show clusters on {}'.format(self.address))

        resp = list(self.cluster_stub.ShowCluster(cluster_pb2.Cluster()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('cluster list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def show_cluster_instances(self):
        logger.info('show cluster instance on {}'.format(self.address))

        resp = list(self.clusterinst_stub.ShowClusterInst(clusterinst_pb2.ClusterInst()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('cluster list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def create_cluster_instance(self, cluster_instance=None, **kwargs):
        resp = None

        if not cluster_instance:
            cluster_instance = ClusterInstance(**kwargs).cluster_instance

        logger.info('create cluster instance on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))

        resp = None
        success = False
        try:
            resp = self.clusterinst_stub.CreateClusterInst(cluster_instance)
        except:
            #print("Unexpected error0:", sys.exc_info()[0])
            resp = sys.exc_info()[0]
            #print("Unexpected error1:", sys.exc_info()[1])
            #print("Unexpected error2:", sys.exc_info()[2])

            #print('typeerror')
        #print('xxxxxxxxxxx',str(resp))
        #sys.exit(1)
        self.response = resp
        for s in resp:
            #print('SSSSSSSSSS=',s)
            if "Created successfully" in str(s):
                success = True            
        if not success:
            raise Exception('Error creating cluster instance:{}'.format(str(resp)))

        self.prov_stack.append(lambda:self.delete_cluster_instance(cluster_instance))
        
        return resp

    def delete_cluster_instance(self, cluster_instance):
        logger.info('delete cluster instance on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))
        resp = self.clusterinst_stub.DeleteClusterInst(cluster_instance)
        
        self.response = resp
        for s in resp:
            if "Deleted ClusterInst successfully" in str(s):
                success = True
        if not success:
            raise Exception('Error deleting cluster instance:{}'.format(str(resp)))

    def update_cluster_instance(self, cluster_instance):
        logger.info('update cluster instance on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))
        resp = self.clusterinst_stub.UpdateClusterInst(cluster_instance)
        return resp

    def create_cloudlet(self, cloudlet_instance=None, **kwargs):
        resp = None

        if not cloudlet_instance:
            cloudlet_instance = Cloudlet(**kwargs).cloudlet

        logger.info('create cloudlet on {}. \n\t{}'.format(self.address, str(cloudlet_instance).replace('\n','\n\t')))
        resp = self.cloudlet_stub.CreateCloudlet(cloudlet_instance)
        for s in resp:
            print(s)

        self.prov_stack.append(lambda:self.delete_cloudlet(cloudlet_instance))
        
        return resp

    def delete_cloudlet(self, cloudlet_instance=None, **kwargs):
        resp = None

        if not cloudlet_instance:
            if len(kwargs) == 0:
                kwargs = {'default_stamp': True}
            cloudlet_instance = Cloudlet(**kwargs).cloudlet

        logger.info('delete cloudlet on {}. \n\t{}'.format(self.address, str(cloudlet_instance).replace('\n','\n\t')))

        resp = self.cloudlet_stub.DeleteCloudlet(cloudlet_instance)
        for s in resp:
            print(s)

        return resp

    def create_flavor(self, flavor_instance=None, **kwargs):
        resp = None

        if not flavor_instance:
            flavor_instance = Flavor(**kwargs).flavor
        
        logger.info('create flavor on {}. \n\t{}'.format(self.address, str(flavor_instance).replace('\n','\n\t')))

        resp = self.flavor_stub.CreateFlavor(flavor_instance)
        self.prov_stack.append(lambda:self.delete_flavor(flavor_instance))

        return resp

    def update_flavor(self, flavor_instance):
        logger.info('update flavor on {}. \n\t{}'.format(self.address, str(flavor_instance).replace('\n','\n\t')))

        resp = self.flavor_stub.UpdateFlavor(flavor_instance)

        return resp

    def show_flavors(self, flavor_instance=None):
        logger.info('show flavors on {}. \n\t{}'.format(self.address, str(flavor_instance).replace('\n','\n\t')))

        resp = None
        if flavor_instance:
            resp = list(self.flavor_stub.ShowFlavor(flavor_instance))
        else:
            resp = list(self.flavor_stub.ShowFlavor(flavor_pb2.Flavor()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('flavor list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def delete_flavor(self, flavor_instance):
        logger.info('delete flavor on {}. \n\t{}'.format(self.address, str(flavor_instance).replace('\n','\n\t')))

        resp = self.flavor_stub.DeleteFlavor(flavor_instance)

        return resp

    def show_apps(self, app_instance=None):
        logger.info('show apps on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = None
        if app_instance:
            resp = list(self.app_stub.ShowApp(app_instance))
        else:
            resp = list(self.app_stub.ShowApp(app_pb2.App()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('apps list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def create_app(self, app_instance=None, **kwargs):
        resp = None
        
        if not app_instance:
            app_instance = App(**kwargs).app

        logger.info('create app on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = self.app_stub.CreateApp(app_instance)
        self.prov_stack.append(lambda:self.delete_app(app_instance))

        return resp

    def delete_app(self, app_instance):
        logger.info('delete app on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = self.app_stub.DeleteApp(app_instance)

        return resp

    def show_app_instances(self, app_instance=None):
        logger.info('show app instance on {}'.format(self.address))

        resp = None
        if app_instance:
            resp = list(self.appinst_stub.ShowAppInst(app_instance))
        else:
            resp = list(self.appinst_stub.ShowAppInst(app_inst_pb2.AppInst()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('app instance list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def create_app_instance(self, app_instance=None, **kwargs):
        resp = None

        if not app_instance:
            app_instance = AppInstance(**kwargs).app_instance

        logger.info('create app instance on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        success = False

        resp = self.appinst_stub.CreateAppInst(app_instance)

        self.response = resp
        for s in resp:
            logger.debug(s)
            if "Created successfully" in str(s):
                success = True
        if not success:
            raise Exception('Error creating app instance:{}'.format(str(resp)))

        self.prov_stack.append(lambda:self.delete_app_instance(app_instance))
        return resp

    def delete_app_instance(self, app_instance):
        logger.info('delete app instance on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))
        resp = self.appinst_stub.DeleteAppInst(app_instance)
        for s in resp:
            print(s)
        
        return resp

    #def create_developer(self, dev_instance):
    #    logger.info('create dddeveloper on {}. app={}'.format(self.address, str(dev_instance)))

    #    resp = self.dev_stub.CreateDeveloper(dev_instance)
        
    #    return resp

    #def delete_developer(self, dev_instance):
    #    print('delete developer on {}. app={}'.format(self.address, str(dev_instance)))

    #    resp = self.dev_stub.DeleteDeveloper(dev_instance)

    #    return resp

    def create_operator(self, op_instance=None, **kwargs):
        resp = None

        if not op_instance:
            if len(kwargs) == 0:
                kwargs = {'use_defaults': True}
            op_instance = Operator(**kwargs).operator

        logger.info('create operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.operator_stub.CreateOperator(op_instance)
        self.prov_stack.append(lambda:self.delete_operator(op_instance))

        return resp

    def update_operator(self, op_instance):
        logger.info('update operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.operator_stub.UpdateOperator(op_instance)

        return resp

    def delete_operator(self, op_instance):
        logger.info('delete operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.operator_stub.DeleteOperator(op_instance)

        return resp

    def show_operators(self, op_instance=None):
        logger.info('show operator on {}'.format(self.address))

        resp = None
        if op_instance:
            resp = list(self.operator_stub.ShowOperator(op_instance))
        else:
            resp = list(self.operator_stub.ShowOperator(operator_pb2.Operator()))

        return resp

    def create_developer(self, op_instance=None, **kwargs):
        resp = None

        if not op_instance:
            op_instance = Developer(**kwargs).developer

        logger.info('create developer on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))
        
        resp = self.developer_stub.CreateDeveloper(op_instance)
        self.prov_stack.append(lambda:self.delete_developer(op_instance))

        return resp

    def update_developer(self, op_instance):
        logger.info('update developer on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.developer_stub.UpdateDeveloper(op_instance)

        return resp

    def delete_developer(self, op_instance):
        logger.info('delete developer on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.developer_stub.DeleteDeveloper(op_instance)

        return resp

    def show_developers(self, op_instance=None):
        logger.info('show developers on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = None
        if op_instance:
            resp = list(self.developer_stub.ShowDeveloper(op_instance))
        else:
            resp = list(self.developer_stub.ShowDeveloper(developer_pb2.Developer()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('developer list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def cleanup_provisioning(self):
        logging.info('cleaning up provisioning')
        print(self.prov_stack)
        self.prov_stack.reverse()
        for obj in self.prov_stack:
            obj()
                
    def _build_cluster(self, operator_name, cluster_name, cloud_name, flavor_name):
        operator_key = operator_pb2.OperatorKey(name = operator_name)
        clusterinst_key = clusterinst_pb2.ClusterInstKey(cluster_key = cluster_pb2.ClusterKey(name = cluster_name),
                                                        cloudlet_key = cloudlet_pb2.CloudletKey(name = cloud_name,
                                                                                                operator_key = operator_key)
                                                       )
        clusterinst = clusterinst_pb2.ClusterInst(
                                                  flavor = clusterflavor_pb2.ClusterFlavorKey(name = flavor_name),
                                                  key = clusterinst_key
                                                 )
        return clusterinst

    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Error('cant find file {}'.format(path))
