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
        else:
            return False
        
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
            self.operator_name = shared_variables.operator_name_default
            
        if self.operator_name is not None:
            op_dict['key'] = operator_pb2.OperatorKey(name = self.operator_name)

        self.operator= operator_pb2.Operator(**op_dict)

    def __eq__(self, c):
        if c.key.name == self.operator_name:
            #print('contains')
            return True
        else:
            return False
        
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
        else:
            return False
        
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

        cluster_flavor_dict = {}
        
        self.cluster_flavor_name = cluster_flavor_name
        self.node_flavor_name = node_flavor_name
        self.master_flavor_name = master_flavor_name
        self.number_nodes = number_nodes
        self.max_nodes = max_nodes
        self.number_masters = number_masters

        if use_defaults:
            if cluster_flavor_name is None: self.cluster_flavor_name = shared_variables.cluster_flavor_name_default
            if node_flavor_name is None: self.node_flavor_name = shared_variables.flavor_name_default
            if master_flavor_name is None: self.master_flavor_name = shared_variables.flavor_name_default 
            if number_nodes is None: self.number_nodes = 1
            if max_nodes is None: self.max_nodes = 1
            if number_masters is None: self.number_masters = 1

        shared_variables.cluster_flavor_name_default = self.cluster_flavor_name

        if self.number_masters:
            cluster_flavor_dict['num_masters'] = int(self.number_masters)
        if self.max_nodes:
            cluster_flavor_dict['max_nodes'] = int(self.max_nodes)
        if self.number_nodes:
            cluster_flavor_dict['num_nodes'] = int(self.number_nodes)
        if self.master_flavor_name:
            cluster_flavor_dict['master_flavor'] = flavor_pb2.FlavorKey(name=self.master_flavor_name)
        if self.node_flavor_name:
            cluster_flavor_dict['node_flavor'] = flavor_pb2.FlavorKey(name=self.node_flavor_name)
        if self.cluster_flavor_name:
            cluster_flavor_dict['key'] = clusterflavor_pb2.ClusterFlavorKey(name=self.cluster_flavor_name)

        self.cluster_flavor = clusterflavor_pb2.ClusterFlavor(**cluster_flavor_dict)

        #self.cluster_flavor = clusterflavor_pb2.ClusterFlavor(
        #                                                      key=clusterflavor_pb2.ClusterFlavorKey(name=self.cluster_flavor_name),
        #                                                      node_flavor=flavor_pb2.FlavorKey(name=self.node_flavor_name),
        #                                                      master_flavor=flavor_pb2.FlavorKey(name=self.master_flavor_name),
        #                                                      num_nodes=int(self.number_nodes),
        #                                                      max_nodes=int(self.max_nodes),
        #                                                      num_masters=int(self.number_masters)
        #                                                     )



class Cluster():
    def __init__(self, cluster_name=None, default_flavor_name=None, use_defaults=True):
        self.cluster_name = cluster_name
        self.flavor_name = default_flavor_name

        if cluster_name == 'default':
            self.cluster_name = shared_variables.cluster_name_default
            
        if use_defaults:
            if cluster_name is None: self.cluster_name = shared_variables.cluster_name_default
            if default_flavor_name is None: self.flavor_name = shared_variables.cluster_flavor_name_default

        self.cluster = cluster_pb2.Cluster(
                                      key = cluster_pb2.ClusterKey(name = self.cluster_name),
                                      default_flavor = clusterflavor_pb2.ClusterFlavorKey(name = self.flavor_name)
        )

        shared_variables.cluster_name_default = self.cluster_name

    def __eq__(self, c):
        print(c.key.name, self.cluster_name, c.default_flavor.name, self.flavor_name)
        if c.key.name == self.cluster_name and c.default_flavor.name == self.flavor_name:
            #print('contains')
            return True
        else:
            return False
        
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
    def __init__(self, operator_name=None, cluster_name=None, cloudlet_name=None, flavor_name=None, liveness=None, crm_override=None, use_defaults=True):

        self.cluster_instance = None

        self.cluster_name = cluster_name
        self.operator_name = operator_name
        self.cloudlet_name = cloudlet_name
        self.flavor_name = flavor_name
        self.crm_override = crm_override
        self.liveness = liveness
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
            if flavor_name is None: self.flavor_name = shared_variables.cluster_flavor_name_default
            if liveness is None: self.liveness = 1
            
        clusterinst_dict = {}
        clusterinst_key_dict = {}
        operator_dict = {}
        cloudlet_key_dict = {}
        #cluster_key_dict = {}

        shared_variables.cloudlet_name_default = self.cloudlet_name
        shared_variables.operator_name_default = self.operator_name

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

        if self.crm_override:
            appinst_dict['crm_override'] = 1  # ignore errors from CRM

        print("ClusterInst Dict", clusterinst_dict)    

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
        else:
            return False
        
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
    def __init__(self, cloudlet_name=None, operator_name=None, number_of_dynamic_ips=None, latitude=None, longitude=None, ipsupport=None, accessuri=None, staticips=None, include_fields=False, use_defaults=True):
        #global cloudlet_name_default
        #global operator_name_default

        _fields_list = []
        self.cloudlet_name = cloudlet_name
        self.operator_name = operator_name
        self.accessuri = accessuri
        self.latitude = latitude
        self.longitude = longitude
        self.ipsupport = ipsupport
        self.staticips = staticips
        self.number_of_dynamic_ips = number_of_dynamic_ips

        print(vars(loc_pb2.Loc))
        # used for UpdateCloudelet - hardcoded from proto
        self._cloudlet_operator_field = str(cloudlet_pb2.Cloudlet.KEY_FIELD_NUMBER) + '.' + str(cloudlet_pb2.CloudletKey.OPERATOR_KEY_FIELD_NUMBER) + '.' + str(operator_pb2.OperatorKey.NAME_FIELD_NUMBER)
        self._cloudlet_name_field = str(cloudlet_pb2.Cloudlet.KEY_FIELD_NUMBER) + '.' + str(cloudlet_pb2.CloudletKey.NAME_FIELD_NUMBER)
        self._cloudlet_accessuri_field = str(cloudlet_pb2.Cloudlet.ACCESS_URI_FIELD_NUMBER)
        self._cloudlet_latitude_field = str(cloudlet_pb2.Cloudlet.LOCATION_FIELD_NUMBER) + '.' + str(loc_pb2.Loc.LATITUDE_FIELD_NUMBER)
        self._cloudlet_longitude_field = str(cloudlet_pb2.Cloudlet.LOCATION_FIELD_NUMBER) + '.' + str(loc_pb2.Loc.LONGITUDE_FIELD_NUMBER)
        self._cloudlet_ipsupport_field = str(cloudlet_pb2.Cloudlet.IP_SUPPORT_FIELD_NUMBER)
        self._cloudlet_staticips_field = str(cloudlet_pb2.Cloudlet.STATIC_IPS_FIELD_NUMBER)
        self._cloudlet_numdynamicips_field = str(cloudlet_pb2.Cloudlet.NUM_DYNAMIC_IPS_FIELD_NUMBER)

        if cloudlet_name is None and use_defaults == True:
            self.cloudlet_name = cloudlet_name_default
        if operator_name is None and use_defaults == True:
            self.operator_name = operator_name_default
        if latitude is None and use_defaults == True:
            self.latitude = 10
        if longitude is None and use_defaults == True:
            self.longitude = 10
        if number_of_dynamic_ips is None and use_defaults == True:
            self.number_of_dynamic_ips = 254
        if ipsupport is None and use_defaults == True:
            self.ipsupport=2
        if accessuri is None and use_defaults == True:
            self.accessuri='https://www.edgesupport.com/test'
        if staticips is None and use_defaults == True:
            self.staticips = '10.10.10.10'
            
        if cloudlet_name == 'default':
            self.cloudlet_name = shared_variables.cloudlet_name_default
        if operator_name == 'default':
            self.operator_name = shared_variables.operator_name_default
        if number_of_dynamic_ips == 'default':
            self.number_of_dynamic_ips = 254

        shared_variables.cloudlet_name_default = self.cloudlet_name
        shared_variables.operator_name_default = self.operator_name

        if self.ipsupport == "IpSupportUnknown":
            self.ipsupport = 0
        if self.ipsupport == "IpSupportStatic":
            print("In the right spot")
            self.ipsupport = 1
        if self.ipsupport == "IpSupportDynamic":
            self.ipsupport = 2

        cloudlet_key_dict = {}
        if self.operator_name is not None:
            cloudlet_key_dict['operator_key'] = operator_pb2.OperatorKey(name = self.operator_name)
            _fields_list.append(self._cloudlet_operator_field)
        if self.cloudlet_name is not None:
            cloudlet_key_dict['name'] = self.cloudlet_name
            _fields_list.append(self._cloudlet_name_field)

        loc_dict = {}
        if self.latitude is not None:
            self.latitude = float(self.latitude)
            loc_dict['latitude'] = self.latitude
            _fields_list.append(self._cloudlet_latitude_field)
        if self.longitude is not None:
            self.longitude = float(self.longitude)
            loc_dict['longitude'] = self.longitude
            _fields_list.append(self._cloudlet_longitude_field)

        cloudlet_dict = {}
        if loc_dict is not None:
            cloudlet_dict['location'] = loc_pb2.Loc(**loc_dict)
        if cloudlet_key_dict is not None:
            cloudlet_dict['key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict)
        if self.number_of_dynamic_ips is not None:
            cloudlet_dict['num_dynamic_ips'] = self.number_of_dynamic_ips
            _fields_list.append(self._cloudlet_numdynamicips_field)
        if self.ipsupport is not None:
            cloudlet_dict['ip_support'] = self.ipsupport
            _fields_list.append(self._cloudlet_ipsupport_field)
        if self.accessuri is not None:
            cloudlet_dict['access_uri'] = self.accessuri
            _fields_list.append(self._cloudlet_accessuri_field)
        if self.staticips is not None:
            cloudlet_dict['static_ips'] = self.staticips
            _fields_list.append(self._cloudlet_staticips_field)
        print("In the class", cloudlet_dict)
        self.cloudlet = cloudlet_pb2.Cloudlet(**cloudlet_dict)

        if include_fields == True:
            for field in _fields_list:
                self.cloudlet.fields.append(field)


    def update(self, cloudlet_name=None, operator_name=None, number_of_dynamic_ips=None, latitude=None, longitude=None, ipsupport=None, accessuri=None, staticips=None, include_fields=False, use_defaults=True):
        print ("In Update", staticips)
        
        if latitude is not None:
            print("Lat Changed")
            self.latitude = float(latitude)
        if longitude is not None:
            print("Long Changed")
            self.longitude = float(longitude)
        if accessuri is not None:
            print("Acc Changed")
            self.accessuri = accessuri
        if ipsupport is not None:
            print("Sup Changed")
            self.ipsupport = ipsupport
        if staticips is not None:
            print("Stat Changed")
            self.staticips = staticips
        if number_of_dynamic_ips is not None:
            print("Dyn Changed")
            self.number_of_dynamic_ips = number_of_dynamic_ips
        

                
    def __eq__(self, c):
        if self.ipsupport is None:
            self.ipsupport = 2
        if self.accessuri is None:
            self.accessuri=""
        if self.staticips is None:
            self.staticips=""
        print(c.key.operator_key.name, self.operator_name, c.key.name, self.cloudlet_name, c.access_uri, self.accessuri, c.location.latitude, self.latitude, c.location.longitude, self.longitude, c.ip_support, self.ipsupport, c.num_dynamic_ips, self.number_of_dynamic_ips, c.static_ips, self.staticips)

        if c.key.operator_key.name == self.operator_name and c.key.name == self.cloudlet_name and c.access_uri == self.accessuri and c.location.latitude == self.latitude and c.location.longitude == self.longitude and c.ip_support == self.ipsupport and c.num_dynamic_ips == self.number_of_dynamic_ips and c.static_ips == self.staticips:
            return True
        else:
            return False
        
    def exists(self, cloudlet_list):
        logger.info('checking cloudlet exists')
        
        found_cloudlet = False
        for c in cloudlet_list:
            if self.__eq__(c):
                found_cloudlet = True
                logging.info('found cloudlet')
                break
        if not found_cloudlet:
            logger.info('INFO: cloudlet NOT found')
        return found_cloudlet

        

class App():
    def __init__(self, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  include_fields=False, use_defaults=True):

        _fields_list = []

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
        self.access_ports = access_ports
        self.auth_public_key = auth_public_key
        self.permits_platform_apps = permits_platform_apps
        self.deployment = deployment
        self.deployment_manifest = deployment_manifest

        # used for UpdateApp - hardcoded from proto
        self._deployment_manifest_field = str(app_pb2.App.DEPLOYMENT_MANIFEST_FIELD_NUMBER)
        self._access_ports_field = str(app_pb2.App.ACCESS_PORTS_FIELD_NUMBER)

        if use_defaults:
            if app_name is None: self.app_name = shared_variables.app_name_default
            if developer_name is None: self.developer_name = shared_variables.developer_name_default
            if app_version is None: self.app_version = shared_variables.app_version_default
            if image_type is None: self.image_type = 'ImageTypeDocker'
            if cluster_name is None: self.cluster_name = shared_variables.cluster_name_default
            if default_flavor_name is None: self.default_flavor_name = shared_variables.flavor_name_default
            if ip_access is None: self.ip_access = 3 # default to shared
            if access_ports is None: self.access_ports = 'tcp:1234'

            if self.image_type == 'ImageTypeDocker':
                if self.image_path is None:
                    try:
                        new_app_name = self._docker_sanitize(self.app_name)
                        if self.developer_name is not None:
                            self.image_path = 'registry.mobiledgex.net:5000/' + self.developer_name + '/' + new_app_name + ':' + self.app_version
                        else:
                            self.image_path = 'registry.mobiledgex.net:5000/' + '/' + new_app_name + ':' + self.app_version
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
            
        #if access_ports is None:
        #    self.access_ports = ''
        #else:
        #    self.access_ports = access_ports

        if self.app_name == 'default':
            self.app_name = shared_variables.app_name_default
        if self.app_version == 'default':
            self.app_version = shared_variables.app_version_default
        if self.developer_name == 'default':
            self.developer_name = shared_variables.developer_name_default
        if self.cluster_name == 'default':
            self.cluster_name = shared_variables.cluster_name_default
        if self.default_flavor_name == 'default':
            self.default_flavor_name = shared_variables.flavor_name_default
            
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
            _fields_list.append(self._access_ports_field)
        if self.config:
            app_dict['config'] = self.config
        else:
            self.config = ''
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
            _fields_list.append(self._deployment_manifest_field)
            
        print(app_dict)
        self.app = app_pb2.App(**app_dict)
        
        #self.app_complete = copy.copy(self.app)
        #self.app_complete.image_path = self.image_path
        
        #print('s',self.app)
        #print('sc', self.app_complete)
        #print('sd',self.app.__dict__,'esd')
        #print('sd2',self.app_complete.__dict__,'esd2')
        #sys.exit(1) 

        if include_fields:
            for field in _fields_list:
                self.app.fields.append(field)

    def __eq__(self, a):
        logging.info('aaaaaa ' + str(a.cluster.name) + 'bbbbbb ' + str(self.cluster_name))
        print('zzzz',a.key.name,self.app_name ,a.key.version,self.app_version,a.image_path,self.image_path,a.ip_access,self.ip_access,a.access_ports,self.access_ports,a.default_flavor.name,self.default_flavor_name,a.cluster.name,self.cluster_name,a.image_type,self.image_type,a.config,self.config)
        if a.key.name == self.app_name and a.key.version == self.app_version and a.image_path == self.image_path and a.ip_access == self.ip_access and a.access_ports == self.access_ports and a.default_flavor.name == self.default_flavor_name and a.cluster.name == self.cluster_name and a.image_type == self.image_type and a.config == self.config:
            return True
        else:
            return False
        
            
        
    def exists(self, app_list):
        logger.info('checking app exists')
        logger.info( app_list)
        found_app = False
        
        for a in app_list:
            print('xxxx','s',self.access_ports, 'k', self.app_name, self.image_path, self.ip_access, self.access_ports, self.default_flavor_name, self.cluster_name, self.image_type, self.config)
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
    def __init__(self, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, image_type=None, image_path=None, cluster_instance_name=None, cluster_instance_developer_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, crm_override=None, use_defaults=True):
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
            #if not cluster_instance_name: self.cluster_name = shared_variables.cluster_name_default
            if not app_version: self.app_version = shared_variables.app_version_default
            if not cloudlet_name: self.cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_name: self.operator_name = shared_variables.operator_name_default

        if self.cluster_name == 'default':
            self.cluster_name = shared_variables.cluster_name_default

        appinst_dict = {}
        appinst_key_dict = {}
        app_key_dict = {}
        cloudlet_key_dict = {}
        clusterinst_key_dict = {}
        loc_dict = {}
        
        if self.app_name:
            app_key_dict['name'] = self.app_name
        if self.app_version:
            app_key_dict['version'] = self.app_version
        if self.developer_name is not None:
            app_key_dict['developer_key'] = developer_pb2.DeveloperKey(name=self.developer_name)

        if self.cluster_name is not None:
            clusterinst_key_dict['cluster_key'] = cluster_pb2.ClusterKey(name = self.cluster_name)
        #if self.developer_name is not None:
        #    clusterinst_key_dict['developer'] = self.developer_name
        if self.cloudlet_name is not None:
            cloudlet_key_dict['name'] = self.cloudlet_name
        if self.operator_name is not None:
            cloudlet_key_dict['operator_key'] = operator_pb2.OperatorKey(name = self.operator_name)
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict)

        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)
        if loc_dict is not None:
            appinst_dict['cloudlet_loc'] = loc_pb2.Loc(**loc_dict)

        if app_key_dict:
            appinst_key_dict['app_key'] = app_pb2.AppKey(**app_key_dict)
        if cloudlet_key_dict:
            appinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict) 
        if appinst_id is not None:
            appinst_key_dict['id'] = appinst_id


        if appinst_key_dict:
            appinst_dict['key'] = app_inst_pb2.AppInstKey(**appinst_key_dict)
        if clusterinst_key_dict:
            appinst_dict['cluster_inst_key'] = clusterinst_pb2.ClusterInstKey(**clusterinst_key_dict)
        if self.uri is not None:
            appinst_dict['uri'] = self.uri
        if self.flavor_name is not None:
            appinst_dict['flavor'] = flavor_pb2.FlavorKey(name = self.flavor_name)


        if self.crm_override:
            appinst_dict['crm_override'] = 1  # ignore errors from CRM
            
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
        self.ctlcloudlet = None
        
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
            # dont think this is sending at the correct interval. seems to be sending keepalive every 5mins
            channel_options = [('grpc.keepalive_time_ms',300000),  # 1mins. seems I cannot do less than 5mins. does 5mins anyway if set lower
                               ('grpc.keepalive_timeout_ms', 5000),
                               ('grpc.http2.min_time_between_pings_ms', 60000),
                               ('grpc.http2.max_pings_without_data', 0),
                               ('grpc.keepalive_permit_without_calls', 1)]
            controller_channel = grpc.secure_channel(controller_address, credentials, options=channel_options)
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
            if len(kwargs) == 0:
                kwargs = {'use_defaults': True}
            cluster_flavor = ClusterFlavor(**kwargs).cluster_flavor

        logger.info('create cluster flavor on {}. \n\t{}'.format(self.address, str(cluster_flavor).replace('\n','\n\t')))

        resp = self.cluster_flavor_stub.CreateClusterFlavor(cluster_flavor)

        self.prov_stack.append(lambda:self.delete_cluster_flavor(cluster_flavor))

        resp = self.show_cluster_flavors(cluster_flavor_name=cluster_flavor.key.name, use_defaults=False)

        if len(resp) == 0:
            return None
        else:
            return resp[0]

        return resp

    def delete_cluster_flavor(self, cluster_flavor=None, **kwargs):
        resp = None

        if cluster_flavor is None:
            if 'cluster_flavor_name' not in kwargs:
                kwargs['cluster_flavor_name'] = shared_variables.cluster_flavor_name_default
            cluster_flavor = ClusterFlavor(**kwargs).cluster_flavor

        logger.info('delete cluster flavor on {}. \n\t{}'.format(self.address, str(cluster_flavor).replace('\n','\n\t')))

        resp = self.cluster_flavor_stub.DeleteClusterFlavor(cluster_flavor)

        return resp

    def show_cluster_flavors(self, op_instance=None, **kwargs):
        resp = None

        if not op_instance:
            if len(kwargs) != 0:
                op_instance = ClusterFlavor(**kwargs).cluster_flavor

        logger.info('show cluster flavors on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))
        
        resp = None
        if op_instance:
            resp = list(self.cluster_flavor_stub.ShowClusterFlavor(op_instance))
        else:
            resp = list(self.cluster_flavor_stub.ShowClusterFlavor(clusterflavor_pb2.ClusterFlavor()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('cluster flavor list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def cluster_flavor_should_exist(self, op_instance=None, **kwargs):

        if op_instance is None:
            kwargs['use_defaults'] = False
            if 'cluster_flavor_name' not in kwargs:
                kwargs['cluster_flavor_name'] = shared_variables.cluster_flavor_name_default
            op_instance = ClusterFlavor(**kwargs).cluster_flavor
                 
        resp = None

        logger.info('should contain operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.show_cluster_flavors(op_instance)
        logger.info(resp)
        
        if not resp:
            raise AssertionError('Cluster Flavor does not exist'.format(str(resp)))

        return resp

    def cluster_flavor_should_not_exist(self, op_instance=None, **kwargs):

        try:
            resp = self.cluster_flavor_should_exist(op_instance=None, **kwargs)
            raise AssertionError('Cluster Flavor does exist'.format(str(resp)))
        except:
            logger.info('cluster flavor does not exist')

    def create_cluster(self, cluster=None, **kwargs):
        resp = None

        if not cluster:
            cluster = Cluster(**kwargs).cluster

        logger.info('create cluster on {}. \n\t{}'.format(self.address, str(cluster).replace('\n','\n\t')))

        resp = self.cluster_stub.CreateCluster(cluster)
        self.prov_stack.append(lambda:self.delete_cluster(cluster))

        resp = self.show_clusters(cluster_name=cluster.key.name, use_defaults=False)

        if len(resp) == 0:
            return None
        else:
            return resp[0]

        return resp

    def delete_cluster(self, cluster=None, **kwargs):
        resp = None

        if cluster is None:
            if 'cluster_name' not in kwargs:
                kwargs['cluster_name'] = shared_variables.cluster_name_default
            cluster = Cluster(**kwargs).cluster

        logger.info('delete cluster on {}. \n\t{}'.format(self.address, str(cluster).replace('\n','\n\t')))

        resp = self.cluster_stub.DeleteCluster(cluster)

        return resp

    def show_clusters(self, cluster_instance=None, **kwargs):
        resp = None

        if not cluster_instance:
            if len(kwargs) != 0:
                cluster_instance = Cluster(**kwargs).cluster

        logger.info('show clusters on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))

        resp = None
        if cluster_instance:
            resp = list(self.cluster_stub.ShowCluster(cluster_instance))
        else:
            resp = list(self.cluster_stub.ShowCluster(cluster_pb2.Cluster()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('cluster list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def cluster_should_exist(self, op_instance=None, **kwargs):

        if op_instance is None:
            kwargs['use_defaults'] = False
            if 'cluster_name' not in kwargs:
                kwargs['cluster_name'] = shared_variables.cluster_name_default
            op_instance = Cluster(**kwargs).cluster
                 
        resp = None

        logger.info('should contain cluster on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.show_clusters(op_instance)
        logger.info(resp)
        
        if not resp:
            raise AssertionError('Cluster does not exist'.format(str(resp)))

        return resp

    def cluster_should_not_exist(self, op_instance=None, **kwargs):
        try:
            resp = self.cluster_should_exist(op_instance=None, **kwargs)
            raise AssertionError('Cluster does exist'.format(str(resp)))
        except:
            logger.info('cluster does not exist')

    def show_cluster_instances(self, cluster_instance=None, **kwargs):
        resp = None

        if cluster_instance is None:
            if len(kwargs) != 0:
                cluster_instance = ClusterInstance(**kwargs).cluster_instance

        logger.info('show cluster instance on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))

        if cluster_instance is None:
            resp = list(self.clusterinst_stub.ShowClusterInst(clusterinst_pb2.ClusterInst()))
        else:
            resp = list(self.clusterinst_stub.ShowClusterInst(cluster_instance))
            
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('cluster instance list:')
            for c in resp:
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def create_cluster_instance(self, cluster_instance=None, **kwargs):
        resp = None
        auto_delete = True

        if not cluster_instance:
            if 'no_auto_delete' in kwargs:
                del kwargs['no_auto_delete']
                auto_delete = False
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

        if auto_delete:
            self.prov_stack.append(lambda:self.delete_cluster_instance(cluster_instance))
        
        return resp

    def delete_cluster_instance(self, cluster_instance=None, **kwargs):
        resp = None

        if cluster_instance is None:
            if len(kwargs) != 0:
                cluster_instance = ClusterInstance(**kwargs).cluster_instance

        logger.info('delete cluster instance on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))
        resp = self.clusterinst_stub.DeleteClusterInst(cluster_instance)

        success = False
        
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

    def cluster_instance_should_exist(self, cluster_instance=None, **kwargs):
        if cluster_instance is None:
            if len(kwargs) != 0:
                kwargs['use_defaults'] = False
                cluster_instance = ClusterInstance(**kwargs).cluster_instance
                                 
        resp = None
        logger.info('should contain cluster instance on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))

        resp = self.show_cluster_instances(cluster_instance)
        logger.info(resp)
        
        if not resp:
            raise AssertionError('Cluster Instance does not exist'.format(str(resp)))

        return resp

    def cluster_instance_should_not_exist(self, cluster_instance=None, **kwargs):
        resp = None
        try:
            resp = self.cluster_instance_should_exist(cluster_instance=None, **kwargs)
        except:
            logger.info('cluster instance does exist')
            
        if resp:    
            raise AssertionError('Cluster instance does exist'.format(str(resp)))


    def create_cloudlet(self, cloudlet_instance=None, **kwargs):
        resp = None

        if cloudlet_instance is None:
            self.ctlcloudlet = Cloudlet(**kwargs)    
            cloudlet_instance = self.ctlcloudlet.cloudlet

        logger.info('create cloudlet on {}. \n\t{}'.format(self.address, str(cloudlet_instance).replace('\n','\n\t')))
        resp = self.cloudlet_stub.CreateCloudlet(cloudlet_instance)
        for s in resp:
            print(s)

        self.prov_stack.append(lambda:self.delete_cloudlet(cloudlet_instance))
        
        return resp

    def show_cloudlets(self, cloudlet_instance=None, **kwargs):
        logger.info('show cloudlets on {}. \n\t{}'.format(self.address, str(cloudlet_instance).replace('\n','\n\t')))

        if cloudlet_instance is None:
            if len(kwargs) != 0:
                cloudlet_instance = Cloudlet(**kwargs).cloudlet

        resp = None
        if cloudlet_instance is not None:
            resp = list(self.cloudlet_stub.ShowCloudlet(cloudlet_instance))
        else:
            resp = list(self.cloudlet_stub.ShowCloudlet(cloudlet_pb2.Cloudlet()))

        print("LOG LEVEL = ", logging.getLogger().getEffectiveLevel())
        for c in resp:
            if logging.getLogger().getEffectiveLevel() == 10 or logging.getLogger().getEffectiveLevel() == 0:  # debug level
                logger.debug('cloudlet list:')
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def cloudlet_should_exist(self, cloudlet_instance=None, **kwargs):

        if cloudlet_instance is None:
            if len(kwargs) != 0:
                cloudlet_instance = Cloudlet(**kwargs).cloudlet
                 
        resp = None

        logger.info('should contain cloudlet on {}. \n\t{}'.format(self.address, str(cloudlet_instance).replace('\n','\n\t')))
        if cloudlet_instance is None and len(kwargs) == 0:
            resp = self.show_cloudlets()
        else:
            resp = self.show_cloudlets(cloudlet_instance)
            
        if not self.ctlcloudlet.exists(resp):
            raise AssertionError('Cloudlet not in the list'.format(str(resp)))

        return resp    

    def cloudlet_should_not_exist(self, cloudlet_instance=None, **kwargs):

        if cloudlet_instance is None:
            if len(kwargs) != 0:
                cloudlet_instance = Cloudlet(use_defaults=False, **kwargs).cloudlet

        resp = None

        logger.info('should contain cloudlet on {}. \n\t{}'.format(self.address, str(cloudlet_instance).replace('\n','\n\t')))
        if cloudlet_instance is None and len(kwargs) == 0:
            resp = self.show_cloudlets()
        else:
            resp = self.show_cloudlets(cloudlet_instance)

        if self.ctlcloudlet.exists(resp):
            raise AssertionError('Cloudlet in the list'.format(str(resp)))

        return resp    
    
    def update_cloudlet(self, cloudlet_instance=None, **kwargs):
        resp = None

        print("INCOMING - ", kwargs)
        if cloudlet_instance is None:
            if len(kwargs) != 0:
                if self.ctlcloudlet is None:
                    self.ctlcloudlet = Cloudlet(**kwargs)
                cloudlet_instance = Cloudlet(include_fields=True, **kwargs).cloudlet

        
        logger.info('update cloudlet on {}. \n\t{}'.format(self.address, str(cloudlet_instance).replace('\n','\n\t')))

        resp = self.cloudlet_stub.UpdateCloudlet(cloudlet_instance)

        self.ctlcloudlet.update(**kwargs)

        for c in resp:
            if logging.getLogger().getEffectiveLevel() == 10 or logging.getLogger().getEffectiveLevel() == 0:  # debug level
                logger.debug('cloudlet list:')
                print('\t{}'.format(str(c).replace('\n','\n\t')))

        return resp


    def delete_cloudlet(self, cloudlet_instance=None, **kwargs):
        resp = None

        if cloudlet_instance is None:
            if len(kwargs) != 0:
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

        resp = self.show_flavors(flavor_name=flavor_instance.key.name, use_defaults=False)

        if len(resp) == 0:
            return None
        else:
            return resp[0]

        #return resp

    def update_flavor(self, flavor_instance):
        logger.info('update flavor on {}. \n\t{}'.format(self.address, str(flavor_instance).replace('\n','\n\t')))

        resp = self.flavor_stub.UpdateFlavor(flavor_instance)

        return resp

    def show_flavors(self, flavor_instance=None, **kwargs):
        resp = None

        if not flavor_instance:
            if len(kwargs) != 0:
                flavor_instance = Flavor(**kwargs).flavor

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

    def delete_flavor(self, flavor_instance=None, **kwargs):
        resp = None

        if flavor_instance is None:
            if 'flavor_name' not in kwargs:
                kwargs['flavor_name'] = shared_variables.flavor_name_default
            flavor_instance = Flavor(**kwargs).flavor

        logger.info('delete flavor on {}. \n\t{}'.format(self.address, str(flavor_instance).replace('\n','\n\t')))

        resp = self.flavor_stub.DeleteFlavor(flavor_instance)

        return resp

    def flavor_should_exist(self, op_instance=None, **kwargs):

        if op_instance is None:
            kwargs['use_defaults'] = False
            if 'flavor_name' not in kwargs:
                kwargs['flavor_name'] = shared_variables.flavor_name_default
            op_instance = Flavor(**kwargs).flavor
                 
        resp = None

        logger.info('should contain operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.show_flavors(op_instance)
        logger.info(resp)
        
        if not resp:
            raise AssertionError('Flavor does not exist'.format(str(resp)))

        return resp

    def flavor_should_not_exist(self, op_instance=None, **kwargs):

        try:
            resp = self.flavor_should_exist(op_instance=None, **kwargs)
            raise AssertionError('Flavor does exist'.format(str(resp)))
        except:
            logger.info('flavor does not exist')

    def show_apps(self, app_instance=None, **kwargs):
        resp = None

        if not app_instance:
            if len(kwargs) != 0:
                app_instance = App(**kwargs).app

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

        #resp =  self.show_apps(app_instance)
        resp = self.show_apps(app_name=app_instance.key.name, use_defaults=False)

        if len(resp) == 0:
            return None
        else:
            return resp[0]

        #return resp

    def update_app(self, app_instance=None, **kwargs):
        resp = None
        
        if not app_instance:
            kwargs['include_fields'] = True
            app_instance = App(**kwargs).app

        logger.info('update app on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = self.app_stub.UpdateApp(app_instance)

        #resp =  self.show_apps(app_instance)
        resp = self.show_apps(app_name=app_instance.key.name, use_defaults=False)

        if len(resp) == 0:
            return None
        else:
            return resp[0]

        #return resp

    def app_should_exist(self, app_instance=None, **kwargs):

        if app_instance is None:
            if len(kwargs) != 0:
                kwargs['use_defaults'] = False
                app_instance = App(**kwargs).app
                 
        resp = None

        logger.info('should contain app on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = self.show_apps(app_instance)
        logger.info(resp)
        
        if not resp:
            raise AssertionError('App does not exist'.format(str(resp)))

        return resp
    
    def app_should_not_exist(self, app_instance=None, **kwargs):

        try:
            resp = self.app_should_exist(app_instance=None, **kwargs)
            raise AssertionError('App does exist'.format(str(resp)))
        except:
            logger.info('app does not exist')
        
    def delete_app(self, app_instance=None, **kwargs):
        resp = None

        if app_instance is None:
            if 'app_name' not in kwargs:
                kwargs['app_name'] = shared_variables.app_name_default
            app_instance = App(**kwargs).app

        logger.info('delete app on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = self.app_stub.DeleteApp(app_instance)

        return resp

    def show_app_instances(self, app_instance=None, **kwargs):
        resp = None

        if not app_instance:
            if len(kwargs) != 0:
                app_instance = AppInstance(**kwargs).app_instance

        logger.info('show app instance on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))
        
        if app_instance:
            resp = list(self.appinst_stub.ShowAppInst(app_instance))
        else:
            resp = list(self.appinst_stub.ShowAppInst(app_inst_pb2.AppInst()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('app instance list:')
            for c in resp:
                print('xxxx\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def create_app_instance(self, app_instance=None, **kwargs):
        resp = None
        auto_delete = True
        
        if not app_instance:
            if 'no_auto_delete' in kwargs:
                del kwargs['no_auto_delete']
                auto_delete = False
            app_instance = AppInstance(**kwargs).app_instance

        logger.info('create app instance on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        success = False

        resp = self.appinst_stub.CreateAppInst(app_instance)

        self.response = resp

        for s in resp:
            logger.debug(s)
            if "Created successfully" in str(s):
                success = True

        if 'StatusCode.OK' in str(resp):  #check for OK because samsung isnt currently printing Created successfull
            success = True

        if not success:
            raise Exception('Error creating app instance:{}xxx'.format(str(resp)))

        if auto_delete:
            self.prov_stack.append(lambda:self.delete_app_instance(app_instance))

        #resp =  self.show_app_instances(app_instance)
        resp =  self.show_app_instances(app_name=app_instance.key.app_key.name, developer_name=app_instance.key.app_key.developer_key.name, cloudlet_name=app_instance.key.cloudlet_key.name, operator_name=app_instance.key.cloudlet_key.operator_key.name, use_defaults=False)

        return resp[0]

    def app_instance_should_exist(self, app_instance=None, **kwargs):

        if app_instance is None:
            if len(kwargs) == 0:
                kwargs['app_name'] = shared_variables.app_name_default
            kwargs['use_defaults'] = False
            app_instance = AppInstance(**kwargs).app_instance
                
        resp = None

        logger.info('should contain app instance on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = self.show_app_instances(app_instance)
        logger.info(resp)
        
        if not resp:
            raise AssertionError('App Instance does not exist'.format(str(resp)))

        return resp

    def app_instance_should_not_exist(self, app_instance=None, **kwargs):
        resp = None
        try:
            resp = self.app_instance_should_exist(app_instance=None, **kwargs)
        except:
            logger.info('app instance does not exist')

        if resp:    
            raise AssertionError('App instance does exist'.format(str(resp)))

    def delete_app_instance(self, app_instance=None, **kwargs):
        resp = None

        if app_instance is None:
            if 'app_name' not in kwargs:
                kwargs['app_name'] = shared_variables.app_name_default
            app_instance = AppInstance(**kwargs).app_instance

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

        resp = self.show_operators(operator_name=op_instance.key.name, use_defaults=False)

        if len(resp) == 0:
            return None
        else:
            return resp[0]

        return resp

    def update_operator(self, op_instance):
        logger.info('update operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.operator_stub.UpdateOperator(op_instance)

        return resp

    def delete_operator(self, op_instance=None, **kwargs):
        resp = None

        if op_instance is None:
            if 'operator_name' not in kwargs:
                kwargs['operator_name'] = shared_variables.operator_name_default
            op_instance = Operator(**kwargs).operator
                
        logger.info('delete operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.operator_stub.DeleteOperator(op_instance)

        return resp

    def show_operators(self, op_instance=None, **kwargs):
        resp = None

        if not op_instance:
            if len(kwargs) != 0:
                op_instance = Operator(**kwargs).operator

        logger.info('show operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = None
        if op_instance:
            resp = list(self.operator_stub.ShowOperator(op_instance))
        else:
            resp = list(self.operator_stub.ShowOperator(operator_pb2.Operator()))

        return resp

    def operator_should_exist(self, op_instance=None, **kwargs):

        if op_instance is None:
            kwargs['use_defaults'] = False
            if 'operator_name' not in kwargs:
                kwargs['operator_name'] = shared_variables.operator_name_default
            op_instance = Operator(**kwargs).operator
                 
        resp = None

        logger.info('should contain operator on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.show_operators(op_instance)
        logger.info(resp)
        
        if not resp:
            raise AssertionError('Operator does not exist'.format(str(resp)))

        return resp

    def operator_should_not_exist(self, op_instance=None, **kwargs):

        try:
            resp = self.operator_should_exist(op_instance=None, **kwargs)
            raise AssertionError('Operator does exist'.format(str(resp)))
        except:
            logger.info('operator does not exist')

    def create_developer(self, op_instance=None, **kwargs):
        resp = None

        if not op_instance:
            op_instance = Developer(**kwargs).developer

        logger.info('create developer on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))
        
        resp = self.developer_stub.CreateDeveloper(op_instance)
        self.prov_stack.append(lambda:self.delete_developer(op_instance))

        resp = self.show_developers(developer_name=op_instance.key.name, use_defaults=False)

        if len(resp) == 0:
            return None
        else:
            return resp[0]

        #return resp

    def update_developer(self, op_instance):
        logger.info('update developer on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.developer_stub.UpdateDeveloper(op_instance)

        return resp

    def delete_developer(self, op_instance=None, **kwargs):
        resp = None

        if op_instance is None:
            if 'developer_name' not in kwargs:
                kwargs['developer_name'] = shared_variables.developer_name_default
            op_instance = Developer(**kwargs).developer

        logger.info('delete developer on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.developer_stub.DeleteDeveloper(op_instance)

        return resp

    def show_developers(self, op_instance=None, **kwargs):
        resp = None

        if not op_instance:
            if len(kwargs) != 0:
                op_instance = Developer(**kwargs).developer

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

    def developer_should_exist(self, op_instance=None, **kwargs):

        if op_instance is None:
            kwargs['use_defaults'] = False
            if 'developer_name' not in kwargs:
                kwargs['developer_name'] = shared_variables.developer_name_default
            op_instance = Developer(**kwargs).developer
                 
        resp = None

        logger.info('should contain developer on {}. \n\t{}'.format(self.address, str(op_instance).replace('\n','\n\t')))

        resp = self.show_developers(op_instance)
        logger.info(resp)
        
        if not resp:
            raise AssertionError('Developer does not exist'.format(str(resp)))

        return resp

    def developer_should_not_exist(self, op_instance=None, **kwargs):

        try:
            resp = self.developer_should_exist(op_instance=None, **kwargs)
            raise AssertionError('Developer does exist'.format(str(resp)))
        except:
            logger.info('developer does not exist')

    def cleanup_provisioning(self):
        logging.info('cleaning up provisioning')
        print(self.prov_stack)
        #temp_prov_stack = self.prov_stack
        temp_prov_stack = list(self.prov_stack)
        temp_prov_stack.reverse()
        for obj in temp_prov_stack:
            logging.debug('deleting obj' + str(obj))
            obj()
            del self.prov_stack[-1]

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
