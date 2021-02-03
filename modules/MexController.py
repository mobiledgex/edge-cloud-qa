import grpc
import sys
import copy
import os
import time
import random
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
#import operator_pb2
#import operator_pb2_grpc
import flavor_pb2
import flavor_pb2_grpc
import app_pb2
import app_pb2_grpc
#import developer_pb2
#import developer_pb2_grpc
#import clusterflavor_pb2
#import clusterflavor_pb2_grpc
import appinst_pb2
import appinst_pb2_grpc
import exec_pb2
import exec_pb2_grpc
import loc_pb2
import loc_pb2_grpc
import threading
import queue

from mex_grpc import MexGrpc
import mex_certs

import shared_variables
#import MexSharedVariables

#logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger(__name__)

#default_time_stamp = str(int(time.time()))
#cloudlet_name_default = 'cloudlet' + default_time_stamp
#operator_name_default = 'operator' + default_time_stamp
#cluster_name_default = 'cluster' + default_time_stamp
#app_name_default = 'app' + default_time_stamp
#app_version_default = '1.0'
#developer_name_default = 'developer' + default_time_stamp
#flavor_name_default = 'flavor' + default_time_stamp
#cluster_flavor_name_default = 'cluster_flavor' + default_time_stamp


crm_notify_server_address_port_last = None

class Developer():
    #def __init__(self, developer_name=None, developer_address=None, developer_email=None, developer_passhash=None, developer_username=None, include_fields=False, use_defaults=True):
    def __init__(self, developer_name=None, include_fields=False, use_defaults=True):
        #global developer_name_default
        
        dev_dict = {}
        _fields_list = []

        self.developer_name = developer_name
        #self.developer_address = developer_address
        #self.developer_email = developer_email
        #self.developer_passhash = developer_passhash
        #self.developer_username = developer_username

        # used for UpdateDeveloper - hardcoded from proto
        self._developer_name_field = str(developer_pb2.Developer.KEY_FIELD_NUMBER) + '.' + str(developer_pb2.DeveloperKey.NAME_FIELD_NUMBER)
        #self._developer_username_field = str(developer_pb2.Developer.USERNAME_FIELD_NUMBER)
        #self._developer_passhash_field = str(developer_pb2.Developer.PASSHASH_FIELD_NUMBER)
        #self._developer_address_field = str(developer_pb2.Developer.ADDRESS_FIELD_NUMBER)
        #self._developer_email_field = str(developer_pb2.Developer.EMAIL_FIELD_NUMBER)

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
        #if developer_address is not None:
        #    dev_dict['address'] = developer_address
        #    _fields_list.append(self._developer_address_field)
        #else:
        #    self.developer_address = ''
        #if developer_email is not None:
        #    dev_dict['email'] = developer_email
        #    _fields_list.append(self._developer_email_field)
        #else:
        #    self.developer_email = ''
        #if developer_passhash is not None:
        #    dev_dict['passhash'] = developer_passhash
        #    _fields_list.append(self._developer_passhash_field)
        #else:
        #    self.developer_passhash = ''
        #if developer_username is not None:
        #    dev_dict['username'] = developer_username
        #    _fields_list.append(self._developer_username_field)
        #else:
        #    self.developer_username = ''
        #dev_dict['fields'] = 'andy'
        #print(dev_dict)
        self.developer = developer_pb2.Developer(**dev_dict)
        
        if include_fields:
            for field in _fields_list:
                self.developer.fields.append(field)
        
    def __eq__(self, c):
        #print('c',c.address, 'a',self.developer_address)
        #if c.key.name == self.developer_name and c.address == self.developer_address and c.email == self.developer_email and c.username == self.developer_username and c.passhash == self.developer_passhash:
        if c.key.name == self.developer_name:
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
            if disk is None: self.disk = 20

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
            if default_flavor_name is None: self.flavor_name = shared_variables.flavor_name_default

        self.cluster = cluster_pb2.Cluster(
                                      key = cluster_pb2.ClusterKey(name = self.cluster_name),
                                      default_flavor = flavor_pb2.FlavorKey(name = self.flavor_name)
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
    def __init__(self, operator_org_name=None, cluster_name=None, cloudlet_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, number_masters=None, number_nodes=None, crm_override=None, deployment=None, use_defaults=True):

        self.cluster_instance = None

        self.cluster_name = cluster_name
        self.operator_org_name = operator_org_name
        self.cloudlet_name = cloudlet_name
        self.flavor_name = flavor_name
        self.crm_override = crm_override
        self.liveness = liveness
        self.ip_access = ip_access
        self.developer_org_name = developer_org_name
        self.number_masters = number_masters
        self.number_nodes = number_nodes
        self.deployment = deployment
        #self.liveness = 1
        #if liveness is not None:
        #    self.liveness = liveness # LivenessStatic

        self.state = 5    # Ready

        if cluster_name == 'default':
            self.cluster_name = shared_variables.cluster_name_default
            
        if use_defaults:
            if cluster_name is None: self.cluster_name = shared_variables.cluster_name_default
            if cloudlet_name is None: self.cloudlet_name = shared_variables.cloudlet_name_default
            if operator_org_name is None: self.operator_org_name = shared_variables.operator_name_default
            if flavor_name is None: self.flavor_name = shared_variables.flavor_name_default
            if developer_org_name is None: self.developer_org_name = shared_variables.developer_name_default
            if liveness is None: self.liveness = 1
            if self.deployment is None or self.deployment == 'kubernetes':
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
        shared_variables.operator_name_default = self.operator_org_name


        if self.operator_org_name is not None:
            cloudlet_key_dict['organization'] = self.operator_org_name
        if self.cloudlet_name:
            cloudlet_key_dict['name'] = self.cloudlet_name
            
        if self.cluster_name:
            clusterinst_key_dict['cluster_key'] = cluster_pb2.ClusterKey(name = self.cluster_name)
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict)
        if self.developer_org_name is not None:
            clusterinst_key_dict['organization'] = self.developer_org_name

        if clusterinst_key_dict:
            clusterinst_dict['key'] = clusterinst_pb2.ClusterInstKey(**clusterinst_key_dict)

        if self.flavor_name is not None:
            clusterinst_dict['flavor'] = flavor_pb2.FlavorKey(name = self.flavor_name)

        if self.liveness is not None:
            clusterinst_dict['liveness'] = self.liveness

        if self.ip_access is not None:
            clusterinst_dict['ip_access'] = self.ip_access

        if self.number_masters is not None:
            clusterinst_dict['num_masters'] = int(self.number_masters)

        if self.number_nodes is not None:
            clusterinst_dict['num_nodes'] = int(self.number_nodes)

        if self.crm_override:
            clusterinst_dict['crm_override'] = self.crm_override  # ignore errors from CRM

        if self.deployment is not None:
            clusterinst_dict['deployment'] = self.deployment
            
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
        if c.key.cluster_key.name == self.cluster_name and c.key.cloudlet_key.organization == self.operator_org_name and c.key.cloudlet_key.name == self.cloudlet_name and c.flavor.name == self.flavor_name and c.state == self.state and c.liveness == self.liveness:
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
    def __init__(self, cloudlet_name=None, operator_org_name=None, number_of_dynamic_ips=None, latitude=None, longitude=None, ipsupport=None, accesscredentials=None, staticips=None, platform_type=None, physical_name=None, crm_override=None, notify_server_address=None, include_fields=False, use_defaults=True):
        #global cloudlet_name_default
        #global operator_name_default

        _fields_list = []
        self.cloudlet_name = cloudlet_name
        self.operator_org_name = operator_org_name
        self.accesscredentials = accesscredentials
        self.latitude = latitude
        self.longitude = longitude
        self.ipsupport = ipsupport
        self.staticips = staticips
        self.number_of_dynamic_ips = number_of_dynamic_ips
        self.crm_override = crm_override
        self.notify_server_address = notify_server_address
        self.platform_type = platform_type
        self.physical_name = physical_name
        
        print('*WARN*', vars(loc_pb2.Loc))
        # used for UpdateCloudelet - hardcoded from proto
        self._cloudlet_operator_field = str(cloudlet_pb2.Cloudlet.KEY_FIELD_NUMBER) + '.' + str(cloudlet_pb2.CloudletKey.ORGANIZATION_FIELD_NUMBER) #+ '.' + str(operator_pb2.OperatorKey.NAME_FIELD_NUMBER)
        self._cloudlet_name_field = str(cloudlet_pb2.Cloudlet.KEY_FIELD_NUMBER) + '.' + str(cloudlet_pb2.CloudletKey.NAME_FIELD_NUMBER)
        #self._cloudlet_accesscredentials_field = str(cloudlet_pb2.Cloudlet.ACCESS_CREDENTIALS_FIELD_NUMBER)
        self._cloudlet_latitude_field = str(cloudlet_pb2.Cloudlet.LOCATION_FIELD_NUMBER) + '.' + str(loc_pb2.Loc.LATITUDE_FIELD_NUMBER)
        self._cloudlet_longitude_field = str(cloudlet_pb2.Cloudlet.LOCATION_FIELD_NUMBER) + '.' + str(loc_pb2.Loc.LONGITUDE_FIELD_NUMBER)
        self._cloudlet_ipsupport_field = str(cloudlet_pb2.Cloudlet.IP_SUPPORT_FIELD_NUMBER)
        self._cloudlet_staticips_field = str(cloudlet_pb2.Cloudlet.STATIC_IPS_FIELD_NUMBER)
        self._cloudlet_numdynamicips_field = str(cloudlet_pb2.Cloudlet.NUM_DYNAMIC_IPS_FIELD_NUMBER)

        if cloudlet_name is None and use_defaults == True:
            self.cloudlet_name = shared_variables.cloudlet_name_default
        if operator_org_name is None and use_defaults == True:
            self.operator_org_name = shared_variables.operator_name_default
        if latitude is None and use_defaults == True:
            self.latitude = 10
        if longitude is None and use_defaults == True:
            self.longitude = 10
        if number_of_dynamic_ips is None and use_defaults == True:
            self.number_of_dynamic_ips = 254
        if ipsupport is None and use_defaults == True:
            self.ipsupport=2
        #if accesscredentials is None and use_defaults == True:
        #    self.accesscredentials='https://www.edgesupport.com/test'
        if staticips is None and use_defaults == True:
            self.staticips = '10.10.10.10'
        if notify_server_address is None and use_defaults == True:
            global crm_notify_server_address_port_last
            port = shared_variables.crm_notify_server_address_port
            if crm_notify_server_address_port_last is None:
                crm_notify_server_address_port_last = port
            else:
                crm_notify_server_address_port_last += 1
                port = crm_notify_server_address_port_last
            self.notify_server_address = shared_variables.crm_notify_server_address + ':' + str(port)

        if cloudlet_name == 'default':
            self.cloudlet_name = shared_variables.cloudlet_name_default
        if operator_org_name == 'default':
            self.operator_org_name = shared_variables.operator_name_default
        if number_of_dynamic_ips == 'default':
            self.number_of_dynamic_ips = 254

        shared_variables.cloudlet_name_default = self.cloudlet_name
        shared_variables.operator_name_default = self.operator_org_name

        if self.ipsupport == "IpSupportUnknown":
            self.ipsupport = 0
        if self.ipsupport == "IpSupportStatic":
            print("In the right spot")
            self.ipsupport = 1
        if self.ipsupport == "IpSupportDynamic":
            self.ipsupport = 2

        if self.platform_type == 'PlatformTypeFake':
            self.platform_type = 0
        if self.platform_type == 'PlatformTypeOpenstack':
            self.platform_type = 2
        elif self.platform_type == 'PlatformTypeAzure':
            self.platform_type = 3
        elif self.platform_type == 'PlatformTypeGcp':
            self.platform_type = 4
        
        cloudlet_key_dict = {}
        if self.operator_org_name is not None:
            cloudlet_key_dict['organization'] = self.operator_org_name
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
            cloudlet_dict['num_dynamic_ips'] = int(self.number_of_dynamic_ips)
            _fields_list.append(self._cloudlet_numdynamicips_field)
        if self.ipsupport is not None:
            cloudlet_dict['ip_support'] = self.ipsupport
            _fields_list.append(self._cloudlet_ipsupport_field)
        #if self.accesscredentials is not None:
        #    cloudlet_dict['access_credentials'] = self.accesscredentials
        #    #_fields_list.append(self._cloudlet_accesscredentials_field)
        if self.staticips is not None:
            cloudlet_dict['static_ips'] = self.staticips
            _fields_list.append(self._cloudlet_staticips_field)
        if self.crm_override:
            cloudlet_dict['crm_override'] = self.crm_override  # ignore errors from CRM
        if self.notify_server_address:
            cloudlet_dict['notify_srv_addr'] = self.notify_server_address
        if self.physical_name is not None:
            cloudlet_dict['physical_name'] = self.physical_name
        if self.platform_type is not None:
            cloudlet_dict['platform_type'] = self.platform_type

        print("In the class", cloudlet_dict)
        self.cloudlet = cloudlet_pb2.Cloudlet(**cloudlet_dict)

        if include_fields == True:
            for field in _fields_list:
                self.cloudlet.fields.append(field)

        #print('*WARN*', cloudlet_dict['notify_srv_addr'])
        
    def update(self, cloudlet_name=None, operator_org_name=None, number_of_dynamic_ips=None, latitude=None, longitude=None, ipsupport=None, accesscredentials=None, staticips=None, include_fields=False, use_defaults=True):
        print ("In Update", staticips)
        
        if latitude is not None:
            print("Lat Changed")
            self.latitude = float(latitude)
        if longitude is not None:
            print("Long Changed")
            self.longitude = float(longitude)
        #if accesscredentials is not None:
        #    print("Acc Changed")
        #    self.accesscredentials = accesscredentials
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
        #if self.accesscredentials is None:
        #    self.accesscredentials=""
        if self.staticips is None:
            self.staticips=""
        #print(c.key.operator_key.name, self.operator_name, c.key.name, self.cloudlet_name, c.access_credentials, self.accesscredentials, c.location.latitude, self.latitude, c.location.longitude, self.longitude, c.ip_support, self.ipsupport, c.num_dynamic_ips, self.number_of_dynamic_ips, c.static_ips, self.staticips)

        if c.key.organization == self.operator_org_name and c.key.name == self.cloudlet_name and c.location.latitude == self.latitude and c.location.longitude == self.longitude and c.ip_support == self.ipsupport and c.num_dynamic_ips == self.number_of_dynamic_ips and c.static_ips == self.staticips:
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
    def __init__(self, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  access_type=None, scale_with_cluster=False, official_fqdn=None, include_fields=False, use_defaults=True):

        _fields_list = []

        self.app_name = app_name
        self.app_version = app_version
        self.developer_org_name = developer_org_name
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
        self.access_type = access_type
        
        if self.image_type and isinstance(self.image_type, str):
            self.image_type = self.image_type.casefold()
            
        #print('*WARN*',app_pb2.App)
        #print('*WARN*','key', vars(app_pb2.App))
        #print('*WARN*','fields', app_pb2.App._fields, dir(app_pb2.App))
        #print('*WARN*','fields', dir(app_pb2.App))
        #pprint('*WARN*',vars(app_pb2.App))
        #sys.exit(1)
        
        # used for UpdateApp - hardcoded from proto
        self._deployment_manifest_field = str(app_pb2.App.DEPLOYMENT_MANIFEST_FIELD_NUMBER)
        self._access_ports_field = str(app_pb2.App.ACCESS_PORTS_FIELD_NUMBER)

        if use_defaults:
            if app_name is None: self.app_name = shared_variables.app_name_default
            if developer_org_name is None: self.developer_org_name = shared_variables.developer_name_default
            if app_version is None: self.app_version = shared_variables.app_version_default
            if image_type is None: self.image_type = 'imagetypedocker'
            #if cluster_name is None: self.cluster_name = shared_variables.cluster_name_default
            if default_flavor_name is None: self.default_flavor_name = shared_variables.flavor_name_default
            #if ip_access is None: self.ip_access = 3 # default to shared
            if access_ports is None: self.access_ports = 'tcp:1234'
            
            if self.image_type == 'imagetypedocker':
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
            elif self.image_type == 'imagetypeqcow':
                if self.image_path is None:
                    self.image_path = 'https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d'
                #self.image_type = 2

        print('*WARN*', self.image_type)
        if self.image_type == 'imagetypedocker':
            self.image_type = 1
        elif self.image_type == 'imagetypeqcow':
            self.image_type = 2
        elif self.image_type == 'imagetypeunknown':
            self.image_type = 0

        if self.access_type and self.access_type.lower() == 'default':
            self.access_type = 0
        elif self.access_type and self.access_type.lower() == 'direct':
            self.access_type = 1
        elif self.access_type and self.access_type.lower() == 'loadbalancer':
            self.access_type = 2            

        #self.ip_access = 3 # default to shared
        #if ip_access == 'IpAccessDedicated':
        #    self.ip_access = 1
        #elif ip_access == 'IpAccessDedicatedOrShared':
        #    self.ip_access = 2
        #elif ip_access == 'IpAccessShared':
        #    self.ip_access = 3
            
        #if access_ports is None:
        #    self.access_ports = ''
        #else:
        #    self.access_ports = access_ports

        if self.app_name == 'default':
            self.app_name = shared_variables.app_name_default
        if self.app_version == 'default':
            self.app_version = shared_variables.app_version_default
        if self.developer_org_name == 'default':
            self.developer_org_name = shared_variables.developer_name_default
        #if self.cluster_name == 'default':
        #    self.cluster_name = shared_variables.cluster_name_default
        if self.default_flavor_name == 'default':
            self.default_flavor_name = shared_variables.flavor_name_default
        if self.image_path == 'default':
            self.image_path='docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
            
        app_dict = {}
        app_key_dict = {}

        if self.app_name is not None:
            app_key_dict['name'] = self.app_name
        if self.app_version:
            app_key_dict['version'] = self.app_version
        if self.developer_org_name is not None:
            app_key_dict['organization'] = self.developer_org_name

        if 'name' in app_key_dict or self.app_version or 'organization' in app_key_dict:
            app_dict['key'] = app_pb2.AppKey(**app_key_dict)
        if self.image_type is not None:
            app_dict['image_type'] = self.image_type
        if self.image_path is not None and self.image_path != 'no_default':
            app_dict['image_path'] = self.image_path

        if self.access_type is not None:
            app_dict['access_type'] = self.access_type
            
        #if self.ip_access:
        #    app_dict['ip_access'] = self.ip_access
        #if self.cluster_name is not None:
        #    app_dict['cluster'] = cluster_pb2.ClusterKey(name = self.cluster_name)
        if self.default_flavor_name is not None:
            app_dict['default_flavor'] = flavor_pb2.FlavorKey(name = self.default_flavor_name)
        if self.access_ports:
            app_dict['access_ports'] = self.access_ports
            _fields_list.append(self._access_ports_field)
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
            _fields_list.append(self._deployment_manifest_field)
        if self.scale_with_cluster:
            app_dict['scale_with_cluster'] = True
        if self.official_fqdn:
            app_dict['official_fqdn'] = self.official_fqdn
            
        self.app = app_pb2.App(**app_dict)

        shared_variables.app_name_default = self.app_name
        if self.developer_org_name is not None:
            shared_variables.developer_name_default = self.developer_org_name
        
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
        #logging.info('aaaaaa ' + str(a.cluster.name) + 'bbbbbb ' + str(self.cluster_name))
        #print('zzzz',a.key.name,self.app_name ,a.key.version,self.app_version,a.image_path,self.image_path,a.ip_access,self.ip_access,a.access_ports,self.access_ports,a.default_flavor.name,self.default_flavor_name,a.cluster.name,self.cluster_name,a.image_type,self.image_type,a.config,self.config)
        #if a.key.name == self.app_name and a.key.version == self.app_version and a.image_path == self.image_path and a.ip_access == self.ip_access and a.access_ports == self.access_ports and a.default_flavor.name == self.default_flavor_name and a.cluster.name == self.cluster_name and a.image_type == self.image_type and a.config == self.config:
        if a.key.name == self.app_name and a.key.version == self.app_version and a.image_path == self.image_path and a.access_ports == self.access_ports and a.default_flavor.name == self.default_flavor_name and a.image_type:
            return True
        else:
            return False
        
            
        
    def exists(self, app_list):
        logger.info('checking app exists')
        logger.info( app_list)
        found_app = False
        
        for a in app_list:
            #print('xxxx','s',self.access_ports, 'k', self.app_name, self.image_path, self.ip_access, self.access_ports, self.default_flavor_name, self.cluster_name, self.image_type, self.config)
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
    def __init__(self, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, use_defaults=True):
        self.appinst_id = appinst_id
        self.app_name = app_name
        self.app_version = app_version
        self.developer_org_name = developer_org_name
        self.cluster_developer_org_name = cluster_instance_developer_org_name
        self.operator_org_name = operator_org_name
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
        if self.developer_org_name == 'default':
            self.developer_org_name = shared_variables.developer_name_default
        if self.app_version == 'default':
            self.app_version = shared_variables.app_version_default
        if self.operator_org_name == 'default':
            self.operator_org_name = shared_variables.operator_name_default
        if self.cloudlet_name == 'default' and self.operator_name != 'developer':  # special case for samsung where they use operator=developer and cloudlet=default
            self.cloudlet_name = shared_variables.cloudlet_name_default

        if use_defaults:
            if not app_name: self.app_name = shared_variables.app_name_default
            #if not cluster_instance_developer_name: self.developer_name = shared_variables.developer_name_default
            if not developer_org_name: self.developer_org_name = shared_variables.developer_name_default
            if not cluster_instance_name: self.cluster_name = shared_variables.cluster_name_default
            if not cluster_instance_developer_org_name: self.cluster_developer_org_name = shared_variables.developer_name_default
            if not app_version: self.app_version = shared_variables.app_version_default
            if not cloudlet_name: self.cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_org_name: self.operator_org_name = shared_variables.operator_name_default

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

        shared_variables.operator_name_default = self.operator_org_name

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
        if self.developer_org_name is not None:
            app_key_dict['organization'] = self.developer_org_name

        if self.cluster_name is not None:
            #clusterinst_key_dict['cluster_key'] = clusterinst_pb2.ClusterInstKey(name = self.cluster_name)
            cluster_key_dict['name'] = self.cluster_name
        #if self.developer_name is not None:
        #    clusterinst_key_dict['developer'] = self.developer_name
        if self.cloudlet_name is not None:
            cloudlet_key_dict['name'] = self.cloudlet_name
        if self.operator_org_name is not None:
            cloudlet_key_dict['organization'] = self.operator_org_name
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict)
        if cluster_key_dict:
            clusterinst_key_dict['cluster_key'] = cluster_pb2.ClusterKey(**cluster_key_dict)
        if self.cluster_developer_org_name is not None:
            clusterinst_key_dict['organization'] = self.cluster_developer_org_name
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)
        if loc_dict is not None:
            appinst_dict['cloudlet_loc'] = loc_pb2.Loc(**loc_dict)

        if app_key_dict:
            appinst_key_dict['app_key'] = app_pb2.AppKey(**app_key_dict)
        if clusterinst_key_dict:
            appinst_key_dict['cluster_inst_key'] = appinst_pb2.VirtualClusterInstKey(**clusterinst_key_dict)
        #if cloudlet_key_dict:
        #    appinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict) 
        #if self.appinst_id is not None:
        #    appinst_key_dict['id'] = int(self.appinst_id)


        if appinst_key_dict:
            appinst_dict['key'] = appinst_pb2.AppInstKey(**appinst_key_dict)
        
        if self.uri is not None:
            appinst_dict['uri'] = self.uri
        if self.flavor_name is not None:
            appinst_dict['flavor'] = flavor_pb2.FlavorKey(name = self.flavor_name)
        if self.autocluster_ipaccess is not None:
            appinst_dict['auto_cluster_ip_access'] = self.autocluster_ipaccess 

        if self.crm_override:
            appinst_dict['crm_override'] = 1  # ignore errors from CRM
            
        self.app_instance = appinst_pb2.AppInst(**appinst_dict)

        print(appinst_dict)
        print('s',self.app_instance)
        #sys.exit(1)

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
        
        if self.app_name:
            app_key_dict['name'] = self.app_name
        if self.app_version:
            app_key_dict['version'] = self.app_version
        if self.developer_name is not None:
            app_key_dict['developer_key'] = developer_pb2.DeveloperKey(name=self.developer_name)

        if self.cluster_name is not None:
            cluster_key_dict['name'] = self.cluster_name
        if self.cloudlet_name is not None:
            cloudlet_key_dict['name'] = self.cloudlet_name
        if self.operator_name is not None:
            cloudlet_key_dict['operator_key'] = operator_pb2.OperatorKey(name = self.operator_name)
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_pb2.CloudletKey(**cloudlet_key_dict)
        if cluster_key_dict:
            clusterinst_key_dict['cluster_key'] = cluster_pb2.ClusterKey(**cluster_key_dict)
        if self.cluster_developer_name is not None:
            clusterinst_key_dict['developer'] = self.cluster_developer_name

        if app_key_dict:
            appinst_key_dict['app_key'] = app_pb2.AppKey(**app_key_dict)
        if clusterinst_key_dict:
            appinst_key_dict['cluster_inst_key'] = clusterinst_pb2.ClusterInstKey(**clusterinst_key_dict)

        if appinst_key_dict:
            runcommand_dict['app_inst_key'] = app_inst_pb2.AppInstKey(**appinst_key_dict)
        
        if command is not None:
            runcommand_dict['command'] = command

        runcommand_dict['offer'] = '{\"type\":\"offer\",\"sdp\":\"v=0\\r\\no=- 706214052 1566425306 IN IP4 0.0.0.0\\r\\ns=-\\r\\nt=0 0\\r\\na=fingerprint:sha-256 01:10:D5:D8:54:8F:22:59:9E:29:F8:EE:A7:45:7C:A3:FC:28:DE:3A:32:D6:DC:B1:0D:64:64:2C:3C:3F:20:A6\\r\\na=group:BUNDLE 0\\r\\nm=application 9 DTLS/SCTP 5000\\r\\nc=IN IP4 0.0.0.0\\r\\na=setup:active\\r\\na=mid:0\\r\\na=sendrecv\\r\\na=sctpmap:5000 webrtc-datachannel 1024\\r\\na=ice-ufrag:pADKraYqfCqVzVaZ\\r\\na=ice-pwd:gSUghOVjhtXWiPDkcQFtBtTxqfknNAjS\\r\\na=candidate:foundation 1 udp 2130706431 192.168.1.126 53204 typ host generation 0\\r\\na=candidate:foundation 2 udp 2130706431 192.168.1.126 53204 typ host generation 0\\r\\na=candidate:foundation 1 udp 16777215 40.114.198.180 49168 typ relay raddr 0.0.0.0 rport 63101 generation 0\\r\\na=candidate:foundation 2 udp 16777215 40.114.198.180 49168 typ relay raddr 0.0.0.0 rport 63101 generation 0\\r\\na=end-of-candidates\\r\\na=setup:actpass\\r\\n\"}'
        
        print('*WARN*', runcommand_dict)
        self.run_command = exec_pb2.ExecRequest(**runcommand_dict)

class MexController(MexGrpc):
    """Library for Controller GRPC operations
    
    This library contains all of the valid controller operations for Create, Show, Delete and Update
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self, controller_address='127.0.0.1:55001', root_cert=None, key=None, client_cert=None):
        """The controller address and certs can be given at library import time.
        These will be used for controller operations

        Examples:

        | =Setting= |     =Value=   | =Value=                                              |          =Comment=                                     |
        | Library   | MexController |                                                      | # Use default address and certs                        |
        | Library   | MexController | controller_address=automation.mobiledgex.net:55001   | # Use the given address and default certs              |
        | Library   | MexController | controller_address=%{AUTOMATION_CONTROLLER_ADDRESS}  | # Use the given env variable address and default certs |
        """

        controller_channel = None
        self.address = controller_address
        self.response = None
        self.prov_stack = []
        self.ctlcloudlet = None
        self._queue_obj = None
        self.thread_dict = {}
        self.last_stream = ''

        self._queue_obj = queue.Queue()

        if not root_cert:
            client_cert, key, root_cert = mex_certs.generate_new_cert(controller_address=controller_address)
            
        super(MexController, self).__init__(address=controller_address, root_cert=root_cert, key=key, client_cert=client_cert)

        #print(sys.path)
        #f = self._findFile(root_cert)
        #print(f)
        #sys.exit(1)
        #if root_cert:
        #    root_cert_real = self._findFile(root_cert)
        #    key_real = self._findFile(key)
        #    client_cert_real = self._findFile(client_cert)
        #    with open(root_cert_real, 'rb') as f:
        #        logger.debug('using root_cert=' + root_cert_real)
        #        #trusted_certs = f.read().encode()
        #        trusted_certs = f.read()
        #    with open(key_real,'rb') as f:
        #        logger.debug('using key='+key_real)
        #        trusted_key = f.read()
        #    with open(client_cert_real, 'rb') as f:
        #        logger.debug('using client cert=' + client_cert_real)
        #        cert = f.read()
        #    # create credentials
        #    credentials = grpc.ssl_channel_credentials(root_certificates=trusted_certs, private_key=trusted_key, certificate_chain=cert)
        #    # dont think this is sending at the correct interval. seems to be sending keepalive every 5mins
        #    channel_options = [('grpc.keepalive_time_ms',300000),  # 1mins. seems I cannot do less than 5mins. does 5mins anyway if set lower
        #                       ('grpc.keepalive_timeout_ms', 5000),
        #                       ('grpc.http2.min_time_between_pings_ms', 60000),
        #                       ('grpc.http2.max_pings_without_data', 0),
        #                       ('grpc.keepalive_permit_without_calls', 1)]
        #    controller_channel = grpc.secure_channel(controller_address, credentials, options=channel_options)
        #else:
        #        controller_channel = grpc.insecure_channel(controller_address)

        self.controller_stub = controller_pb2_grpc.ControllerApiStub(self.grpc_channel)

        #self.cluster_flavor_stub = clusterflavor_pb2_grpc.ClusterFlavorApiStub(self.grpc_channel)
        #self.cluster_stub = cluster_pb2_grpc.ClusterApiStub(self.grpc_channel)
        self.clusterinst_stub = clusterinst_pb2_grpc.ClusterInstApiStub(self.grpc_channel)
        self.cloudlet_stub = cloudlet_pb2_grpc.CloudletApiStub(self.grpc_channel)
        self.flavor_stub = flavor_pb2_grpc.FlavorApiStub(self.grpc_channel)
        self.app_stub = app_pb2_grpc.AppApiStub(self.grpc_channel)
#        self.dev_stub = developer_pb2_grpc.DeveloperApiStub(self.grpc_channel)
        self.appinst_stub = appinst_pb2_grpc.AppInstApiStub(self.grpc_channel)
#        self.operator_stub = operator_pb2_grpc.OperatorApiStub(self.grpc_channel)
#        self.developer_stub = developer_pb2_grpc.DeveloperApiStub(self.grpc_channel)
        self.exec_stub = exec_pb2_grpc.ExecApiStub(self.grpc_channel)

        self._init_shared_variables()

    def get_default_time_stamp(self):
        return shared_variables.time_stamp_default

    def get_default_developer_name(self):
        return shared_variables.developer_name_default

    def get_default_flavor_name(self):
        return shared_variables.flavor_name_default

    def get_default_app_name(self):
        return shared_variables.app_name_default

    def get_default_app_version(self):
        return shared_variables.app_version_default

    def get_default_cluster_name(self):
        return shared_variables.cluster_name_default

    #def get_default_cluster_instance_name(self):
    #    return shared_variables.cluster_instance_name_default

    def get_default_cluster_flavor_name(self):
        return shared_variables.cluster_flavor_name_default

    def show_controllers(self, address=None):
        """ Shows connected controllers.

        Shows all controllers when not specifing an address or shows the controller at the specified address.

        Equivalent to edgectl ShowController.

        Examples:

        | Show Controllers |               | # Show all controllers |
        | Show Controllers | 0.0.0.0:55001 | # Show controller at 0.0.0.0:55001 |

        """
        
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
        """ Creates a cluster flavor with the specified object, values or all default values

        Equivalent to edgectl CreateClusterFlavor.

        Arguments:

        | =Argument=           | =Default Value= |
        | cluster_flavor_name | 'cluster_flavor' + epochTime |
        | node_flavor_name    | 'flavor' + epochTime |
        | master_flavor_name  | 'flavor' + epochTime |
        | number_nodes        | 1 |
        | max_nodes           | 1 |
        | number_masters      | 1 |

        Examples:

        | Create Cluster Flavor |                              | # Create a cluster flavor with all defaults |
        | Create Cluster Flavor | cluster_flavor_name=myFlavor | # Create a cluster flavor with flavor name of 'myFlavor' and remaining defaults |

        """

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
        """ Creates a cluster with the specified object, values or all default values

        Equivalent to edgectl CreateCluster.

        Arguments:

        | =Argument=          | =Default Value= |
        | cluster_name        | 'cluster_flavor' + epochTime |
        | default_flavor_name | 'flavor' + epochTime or flavor set by previous Create Cluster Flavor         |
        | use_defaults        | True. Set to True or False for whether or not to use default values |

        Examples:

        | Create Cluster |                        |                       | # Create a cluster with all defaults |
        | Create Cluster | cluster_name=myCluster |                       | # Create a cluster with name of 'myCluster' and remaining defaults |
        | Create Cluster | cluster_name=myCluster | use_defaults=${False} | # Create a cluster with name of 'myCluster' and dont set any defaults |

        """
        
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
        """ Creates a cluster instance with the specified object, values or all default values

        Equivalent to edgectl CreateClusterInst.

        Arguments:

        | =Argument=          | =Default Value= |
        | cluster_name  | 'cluster_flavor' + epochTime or what was previously used for Create Cluster |
        | operator_name | 'operator' + epochTime or what was previously set by preceeding operation   |
        | cloudlet_name | 'cloudlet' + epochTime or what was previously set by Create Cloudlet        |
        | flavor_name   | 'flavor' + epochTime or what was previously set by Create Flavor            |
        | liveness      | 1                                                                           |
        | ip_access     | None                                                                        |
        | use_defaults  | True. Set to True or False for whether or not to use default values         |
        | use_thread    | False. Set to True to run the operation in a thread. Used for parallel executions         |
        | del_thread    | False, Set to True to auto delete in a thread. Used for parallel executions         | 

        Examples:

        | Create Cluster Instance |                        |                       | # Create a cluster instance with all defaults |
        | Create Cluster Instance | cluster_name=myCluster |                       | # Create a cluster instance with name of 'myCluster' and remaining defaults |
        | Create Cluster Instance | cluster_name=myCluster | use_defaults=${False} | # Create a cluster instance with name of 'myCluster' and dont set any defaults |

        """

        resp = None
        auto_delete = True
        use_thread = False
        del_thread = False
        
        if not cluster_instance:
            if 'no_auto_delete' in kwargs:
                del kwargs['no_auto_delete']
                auto_delete = False
            if 'use_thread' in kwargs:
                del kwargs['use_thread']
                use_thread = True
            if 'del_thread' in kwargs:
                del kwargs['del_thread']
                del_thread = True
            cluster_instance = ClusterInstance(**kwargs).cluster_instance

        logger.info('create cluster instance on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))

        resp = None

        def sendMessage(thread_name='Thread'):
            success = False
            time1 = time.time()

            try:
                resp = self.clusterinst_stub.CreateClusterInst(cluster_instance)
            except:
                resp = sys.exc_info()[0]

            self.response = resp
            try:
                for s in resp:
                    print(str(s))
                    if "Created ClusterInst successfully" in str(s):
                        success = True
            except:
                if self._queue_obj:
                    print('**WARN**', 'XXXXXXXXXXXXXXXX')
                    self._queue_obj.put({thread_name:sys.exc_info()})
                else:
                    raise Exception(sys.exc_info())
                
            time2 = time.time()
            threadtime = time2 - time1
            self.thread_dict[thread_name]=(time1, time2, threadtime)
            threadtime = 0
            
            if not success:
                raise Exception('Error creating cluster instance:{}'.format(str(resp)))

            if auto_delete:
                if del_thread:
                    self.prov_stack.append(lambda:self.delete_cluster_instance(use_thread=True, **kwargs))
                else:
                    self.prov_stack.append(lambda:self.delete_cluster_instance(cluster_instance))
                    
            resp =  self.show_cluster_instances(cluster_name=cluster_instance.key.cluster_key.name, operator_org_name=cluster_instance.key.cloudlet_key.organization, cloudlet_name=cluster_instance.key.cloudlet_key.name, use_defaults=False)

            return resp[0]

            #return resp

        if use_thread:
            #self._queue_obj = queue.Queue()
            thread_name = f'Thread-{cluster_instance.key.cluster_key.name}-{str(time.time())}'
            t = threading.Thread(target=sendMessage, name=thread_name, args=(thread_name,))
            t.start()
            return t
        else:
            print('sending message')
            resp = sendMessage()
            return resp

    def wait_for_replies(self, *args):
        logging.info(f'waiting on {len(args)} threads')
        failed_thread_list = []
        
        for x in args:
            x.join()
            
        print('*WARN*', 'queue', self._queue_obj.qsize())
        while not self._queue_obj.empty():
            try:
                exec = self._queue_obj.get(block=False)
                print('*WARN*', 'zzzzzz', list(exec)[0])
                logging.error(f'thread {list(exec)[0]} failed with {exec[list(exec)[0]]}')
                failed_thread_list.append(exec)
                #raise Exception(exec)
            except queue.Empty:
                pass

        logging.info(f'number of failed threads:{len(failed_thread_list)}')
        #print('*WARN*', 'threadlist',len(failed_thread_list))
        #print('*WARN*','listdone')

        if failed_thread_list:
            raise Exception(f'{len(failed_thread_list)} threads failed:', failed_thread_list)
        
    def get_thread_dict(self):
        return self.thread_dict

    def clear_thread_dict(self):
        self.thread_dict = {}
                    
    def delete_cluster_instance(self, cluster_instance=None, **kwargs):
        #resp = None
        use_thread = False
        if cluster_instance is None:
            if 'cluster_name' not in kwargs:
                kwargs['cluster_name'] = shared_variables.cluster_name_default
            if 'use_thread' in kwargs:
                del kwargs['use_thread']
                use_thread = True
            #if len(kwargs) != 0:
            #    cluster_instance = ClusterInstance(**kwargs).cluster_instance
            cluster_instance = ClusterInstance(**kwargs).cluster_instance

        logger.info('delete cluster instance on {}. \n\t{}'.format(self.address, str(cluster_instance).replace('\n','\n\t')))

        def sendMessage(thread_name='Thread'):
            success = False
            time1 = time.time()
            print("*WARN*", "thread_time1", time.time())

            try:
                resp = self.clusterinst_stub.DeleteClusterInst(cluster_instance)
            except:
                resp = sys.exc_info()[0]

            self.response = resp
            for s in resp:
                print(str(s))
                if "Deleted ClusterInst successfully" in str(s):
                    success = True
                    
            time2 = time.time()
            print("*WARN*", "thread_time2", time.time())
            threadtime = time2 - time1
            self.thread_dict[thread_name]=(time1, time2, threadtime)
            #print("*WARN*", "Thread Dict", self.thread_dict)
            threadtime = 0
            
            if not success:
                raise Exception('Error deleting cluster instance:{}'.format(str(resp)))

            return resp
        
        if use_thread:
            thread_name = "Thread-" + str(time.time())
            t = threading.Thread(target=sendMessage, name=thread_name, args=(thread_name,))
            t.start()
            return t
        else:
            print('sending message')
            resp = sendMessage()
            return resp

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
        """ Creates a cloudlet with the specified object, values or all default values

        Equivalent to edgectl CreateCloudlet.

        Arguments:

        | =Argument=            | =Default Value= |
        | cloudlet_name         | 'cloudlet' + epochTime                                              |
        | operator_name         | 'operator' + epochTime or operator set by previous Create Operator  |
        | number_of_dynamic_ips | 254                                                                 |
        | latitude              | 10                                                                  |
        | longitude             | 10                                                                  |
        | ipsupport             | IpSupportDynamic                                                    |
        | accessuri             | https://www.edgesupport.com/test                                    |
        | staticips             | 10.10.10.10                                                         |
        | use_defaults          | True. Set to True or False for whether or not to use default values |

        Examples:

        | Create Cloudlet | cloudlet_name=tmocloud-8 | operator_name=tmus    | latitude=35 | longitude=-101 | |
        | Create Cloudlet | cloudlet_name=${cldlet}  | operator_name=${oper} |                 |                   |                    | # Create a cloudlet with lat/long with default |
        | Create Cloudlet | cloudlet_name=${cldlet}  | operator_name=${oper} | latitude=${lat} | longitude=${long} | use_defaults=False | # donot fill remaining parms with defaults |
        """

        resp = None

        if cloudlet_instance is None:
            self.ctlcloudlet = Cloudlet(**kwargs)    
            cloudlet_instance = self.ctlcloudlet.cloudlet

        logger.info('create cloudlet on {}. \n\t{}'.format(self.address, str(cloudlet_instance).replace('\n','\n\t')))
        resp = self.cloudlet_stub.CreateCloudlet(cloudlet_instance)

        for s in resp:
            print(s)
            self.last_stream += str(s)
            if 'Failure' in str(s) or 'failed' in str(s):
                logging.error(str(s))
                raise Exception(str(s))

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
                logger.debug('cloudlet listxx:')
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
        resp = self.show_apps(app_name=app_instance.key.name, developer_org_name=app_instance.key.organization, app_version=app_instance.key.version, use_defaults=False)

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
            logger.debug('show' + str(resp))
            logger.debug('level' + str(logging.getLogger().getEffectiveLevel()))
        else:
            resp = list(self.appinst_stub.ShowAppInst(appinst_pb2.AppInst()))
        if logging.getLogger().getEffectiveLevel() == 10: # debug level
            logger.debug('app instance list:')
            for c in resp:
                print('xxxx\t{}'.format(str(c).replace('\n','\n\t')))

        return resp

    def create_app_instance(self, app_instance=None, **kwargs):
        """ Creates an app instance with the specified object, values or all default values

        Equivalent to edgectl CreateAppInst.

        Arguments:

        | =Argument=                      | =Default Value= |
        | app_name                        | 'app' + epochTime or appname set by previous Create App |
        | app_version                     | 1.0 |
        | cloudlet_name                   | 'cloudlet' + epochTime or cloudlet name set by previous Create Cloudlet |
        | operator_name                   | 'Operator' + epochTime or operator name set by previous Create Operator |
        | developer_name                  | 'Developer' + epochTime or operator name set by previous Create Developer |
        | cluster_instance_name           | None |
        | cluster_instance_developer_name | None |
        | flavor_name                     | None |
        | uri                             | None |
        | appinst_id                      | None |
        | use_defaults                    | True. Set to True or False for whether or not to use default values |
        | use_thread    | False. Set to True to run the operation in a thread. Used for parallel executions         |

        Examples:

        | Create App Instance | cloudlet_name=${cloudlet_name} | operator_name=${operator_name} | cluster_instance_name=autocluster 
        | Create App Instance | cluster_instance_name=autocluster |

        """

        resp = None
        auto_delete = True
        use_thread = False
        del_thread = False

        #print("*WARN*", "APP KWARGS ", kwargs)


        if not app_instance:
            if 'no_auto_delete' in kwargs:
                del kwargs['no_auto_delete']
                auto_delete = False
            if 'use_thread' in kwargs:
                del kwargs['use_thread']
                use_thread = True
            if 'del_thread' in kwargs:
                del kwargs['del_thread']
                del_thread = True
            app_instance = AppInstance(**kwargs).app_instance

        logger.info('create app instance on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = None
        success = False

        def sendMessage(thread_name='Thread'):
            time1 = time.time()

            try:
                resp = self.appinst_stub.CreateAppInst(app_instance)
            except:
                resp = sys.exc_info()[0]

            self.response = resp

            for s in resp:
                logger.debug(s)
                if "Created successfully" in str(s):
                    success = True

            if 'StatusCode.OK' in str(resp):  #check for OK because samsung isnt currently printing Created successfull
                success = True

            time2 = time.time()
            threadtime = time2 - time1
            self.thread_dict[thread_name]=(time1, time2, threadtime)
            threadtime = 0
                
            if not success:
                raise Exception('Error creating app instance:{}xxx'.format(str(resp)))

            if auto_delete:
                if del_thread:
                    self.prov_stack.append(lambda:self.delete_app_instance(use_thread=True, **kwargs))
                else:
                    self.prov_stack.append(lambda:self.delete_app_instance(app_instance))

            #resp =  self.show_app_instances(app_instance)
            resp =  self.show_app_instances(app_name=app_instance.key.app_key.name, developer_org_name=app_instance.key.app_key.organization, cloudlet_name=app_instance.key.cluster_inst_key.cloudlet_key.name, operator_org_name=app_instance.key.cluster_inst_key.cloudlet_key.organization, cluster_instance_name=app_instance.key.cluster_inst_key.cluster_key.name, use_defaults=False)

            return resp[0]
        
        if use_thread:
            thread_name = "Thread-" + str(time.time())
            t = threading.Thread(target=sendMessage, name=thread_name, args=(thread_name,))
            t.start()
            return t
        else:
            resp = sendMessage()
            return resp

    def wait_for_app_instance_health_check_ok(self, app_instance=None, timeout=180, **kwargs):
        if app_instance is None:
            if len(kwargs) == 0:
                kwargs['app_name'] = shared_variables.app_name_default
            kwargs['use_defaults'] = False
            app_instance = AppInstance(**kwargs).app_instance

        for x in range(1, timeout):
            resp = self.show_app_instances(app_instance)
            logger.info(resp)

            if resp:
                if resp and resp[0].health_check == 3:
                    logging.info(f'App Instance is health check OK')
                    return resp
                else:
                    logging.debug(f'app instance health check not OK. got {resp[0].health_check}. sleeping and trying again')
                    time.sleep(1)
            else:
                raise Exception(f'app instance is NOT found.')
            
        raise Exception(f'app instance health check is NOT OK. Got {resp[0].health_check} but expected 3')


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
        use_thread = False

        if app_instance is None:
            if 'app_name' not in kwargs:
                kwargs['app_name'] = shared_variables.app_name_default
            if 'use_thread' in kwargs:
                del kwargs['use_thread']
                use_thread = True
            app_instance = AppInstance(**kwargs).app_instance

        logger.info('delete app instance on {}. \n\t{}'.format(self.address, str(app_instance).replace('\n','\n\t')))

        resp = None

        def sendMessage(thread_name='Thread'):
            success = False
            time1 = time.time()
            print("*WARN*", "thread_time1", time.time())

            try:
                resp = self.appinst_stub.DeleteAppInst(app_instance)
            except:
                resp = sys.exc_info()[0]

            self.response = resp

            for s in resp:
                print(s)
                if "Deleted AppInst successfully" in str(s):
                    success = True

            time2 = time.time()
            print("*WARN*", "thread_time2", time.time())
            threadtime = time2 - time1
            self.thread_dict[thread_name]=(time1, time2, threadtime)
            print("*WARN*", "Thread Dict", self.thread_dict)
            threadtime = 0

                    
            if not success:
                raise Exception('Error deleting app instance:{}'.format(str(resp)))

        if use_thread:
            thread_name = "Thread-" + str(time.time())
            t = threading.Thread(target=sendMessage, name=thread_name, args=(thread_name,))
            t.start()
            return t
        else:
            print('sending message')
            resp = sendMessage()
            return resp
        
        #return resp
        
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

    def run_command(self, run_instance=None, **kwargs):
        """ Creates an app instance with the specified object, values or all default values

        Equivalent to edgectl CreateAppInst.

        Arguments:

        | =Argument=                      | =Default Value= |
        | app_name                        | 'app' + epochTime or appname set by previous Create App |
        | app_version                     | 1.0 |
        | cloudlet_name                   | 'cloudlet' + epochTime or cloudlet name set by previous Create Cloudlet |
        | operator_name                   | 'Operator' + epochTime or operator name set by previous Create Operator |
        | developer_name                  | 'Developer' + epochTime or operator name set by previous Create Developer |
        | cluster_instance_name           | None |
        | cluster_instance_developer_name | None |
        | flavor_name                     | None |
        | uri                             | None |
        | appinst_id                      | None |
        | use_defaults                    | True. Set to True or False for whether or not to use default values |
        | use_thread    | False. Set to True to run the operation in a thread. Used for parallel executions         |

        Examples:

        | Create App Instance | cloudlet_name=${cloudlet_name} | operator_name=${operator_name} | cluster_instance_name=autocluster 
        | Create App Instance | cluster_instance_name=autocluster |

        """

        resp = None
        auto_delete = True
        use_thread = False

        if not run_instance:
            if 'use_thread' in kwargs:
                del kwargs['use_thread']
                use_thread = True
            run_instance = RunCommand(**kwargs).run_command

        logger.info('run command on {}. \n\t{}'.format(self.address, str(run_instance).replace('\n','\n\t')))

        resp = None
        success = False

        def sendMessage():
            try:
                print('*WARN*', 'runc')
                resp = self.exec_stub.RunCommand(run_instance)
                print('*WARN*', 'runcd')
            except:
                print('*WARN*', 'rune')
                resp = sys.exc_info()[0]

            self.response = resp
            print('*WARN*', resp)
            for s in resp:
                logger.debug(s)
                if "Created successfully" in str(s):
                    success = True

            if 'StatusCode.OK' in str(resp):  #check for OK because samsung isnt currently printing Created successfull
                success = True

            if not success:
                raise Exception('Error creating app instance:{}xxx'.format(str(resp)))

            return resp[0]
        
        if use_thread:
            t = threading.Thread(target=sendMessage)
            t.start()
            return t
        else:
            print('sending message')
            resp = sendMessage()
            return resp

    def cleanup_provisioning(self):
        logging.info('cleaning up provisioning')
        print(self.prov_stack)
        #temp_prov_stack = self.prov_stack
        temp_prov_stack = list(self.prov_stack)
        temp_prov_stack.reverse()
        thread_stack = []
        thread_wait = False
        for obj in temp_prov_stack:
            logging.debug('deleting obj' + str(obj))
            t = obj()
            if (type(t) is threading.Thread):
                thread_stack.append(t)
                thread_wait = True
            del self.prov_stack[-1]
        if thread_wait:
            self.wait_for_replies(*thread_stack)
            

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

    def get_last_stream(self):
        return self.last_stream
    
    def _init_shared_variables(self):
        default_time_stamp = str(time.time()).replace('.', '-')
        shared_variables.time_stamp_default = default_time_stamp
        shared_variables.cloudlet_name_default = 'cloudlet' + default_time_stamp
        shared_variables.operator_name_default = 'operator' + default_time_stamp
        shared_variables.cluster_name_default = 'cluster' + default_time_stamp
        shared_variables.app_name_default = 'app' + default_time_stamp
        shared_variables.app_version_default = '1.0'
        #shared_variables.developer_name_default = 'developer' + default_time_stamp
        shared_variables.developer_name_default = 'MobiledgeX'
        shared_variables.flavor_name_default = 'flavor' + default_time_stamp
        shared_variables.cluster_flavor_name_default = 'cluster_flavor' + default_time_stamp
