import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex cloudlet rest')


class Cloudlet(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateCloudlet'
        self.delete_url = '/auth/ctrl/DeleteCloudlet'
        self.show_url = '/auth/ctrl/ShowCloudlet'
        self.update_url = '/auth/ctrl/UpdateCloudlet'
        self.metrics_url = '/auth/metrics/cloudlet'
        self.addmapping_url = '/auth/ctrl/AddCloudletResMapping'
        self.addrestag_url = '/auth/ctrl/AddResTag'

    def _build(self, cloudlet_name=None, operator_org_name=None, number_dynamic_ips=None, latitude=None, longitude=None, ip_support=None, access_uri=None, static_ips=None, platform_type=None, physical_name=None, container_version=None, package_version=None, env_vars=None, crm_override=None, notify_server_address=None, include_fields=False, use_defaults=True):

        _fields_list = []
        _operator_name_field_number = "2.1"
        _cloudlet_name_field_number = "2.2"
        _container_version_field_number = "20"
        _package_version_field_number = "25"

        if use_defaults:
            if cloudlet_name is None: cloudlet_name = shared_variables.cloudlet_name_default
            if operator_org_name is None: operator_org_name = shared_variables.operator_name_default
            if latitude is None: latitude = shared_variables.latitude_default
            if longitude is None: longitude = shared_variables.longitude_default
            if number_dynamic_ips is None: number_dynamic_ips = shared_variables.number_dynamic_ips_default
            if ip_support is None: ip_support = shared_variables.ip_support_default
            #if accessuri is None: self.accessuri = shared_variables.access_uri_default
            #if staticips is None: self.staticips = shared_variables.static_ips_default

        if ip_support == "IpSupportUnknown":
            ip_support = 0
        if ip_support == "IpSupportStatic":
            ip_support = 1
        if ip_support == "IpSupportDynamic":
            ip_support = 2
        
        #"{\"cloudlet\":{\"key\":{\"operator_key\":{\"name\":\"rrrr\"},\"name\":\"rrrr\"},\"location\":{\"latitude\":5,\"longitude\":5,\"timestamp\":{}},\"ip_support\":2,\"num_dynamic_ips\":2}}"
        cloudlet_dict = {}
        cloudlet_key_dict = {}
        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name
            _fields_list.append(_operator_name_field_number)
        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
            _fields_list.append(_cloudlet_name_field_number)

        loc_dict = {}
        if latitude is not None:
            loc_dict['latitude'] = float(latitude)
        if longitude is not None:
            loc_dict['longitude'] = float(longitude)

        if cloudlet_key_dict:
            cloudlet_dict['key'] = cloudlet_key_dict
        if loc_dict:
            cloudlet_dict['location'] = loc_dict
        if number_dynamic_ips is not None:
            cloudlet_dict['num_dynamic_ips'] = int(number_dynamic_ips)
        if ip_support is not None:
            cloudlet_dict['ip_support'] = ip_support
        #if self.accessuri is not None:
        #    cloudlet_dict['access_uri'] = self.accessuri
        #    _fields_list.append(self._cloudlet_accessuri_field)
        #if self.staticips is not None:
        #    cloudlet_dict['static_ips'] = self.staticips
        #    _fields_list.append(self._cloudlet_staticips_field)

        if physical_name is not None:
            cloudlet_dict['physical_name'] = physical_name
        if platform_type is not None:
            cloudlet_dict['platform_type'] = platform_type

        if crm_override is not None:
            if crm_override.lower() == "ignorecrm":
                crm_override = 2
            cloudlet_dict['crm_override'] = crm_override  # ignore errors from CRM

        if notify_server_address is not None:
            cloudlet_dict['notify_srv_addr'] = notify_server_address

        if container_version is not None:
            cloudlet_dict['container_version'] = container_version
            _fields_list.append(_container_version_field_number)

        if package_version is not None:
            cloudlet_dict['package_version'] = package_version
            _fields_list.append(_package_version_field_number)

            
        env_dict = {}
        if env_vars is not None:
            key,value = env_vars.split('=')
            env_dict[key] = value
            cloudlet_dict['env_var'] = env_dict
            
        if include_fields and _fields_list:
            cloudlet_dict['fields'] = []
            for field in _fields_list:
                cloudlet_dict['fields'].append(field)

        return cloudlet_dict

    def _build_metrics(self, type_dict=None, selector=None, last=None, start_time=None, end_time=None, use_defaults=True):
        metric_dict = {}
        if type_dict is not None:
            metric_dict.update(type_dict)
        if selector is not None:
            metric_dict['selector'] = selector
        if last is not None:
            try:
                metric_dict['last'] = int(last)
            except:
                metric_dict['last'] = last
        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time

        return metric_dict

    def _build_mapping(self, cloudlet_dict=None, mapping=None, use_defaults=True):
        map_dict = {}
        if cloudlet_dict is not None:
            map_dict.update(cloudlet_dict)
                    
        if mapping is not None:
            tag,value = mapping.split('=')
            map_dict['cloudletresmap']['mapping'] = {tag:value}

        return map_dict

    def _build_restag(self, cloudlet_dict=None, tags=None, use_defaults=True):
        map_dict = {}
        if cloudlet_dict is not None:
            map_dict.update(cloudlet_dict)
                    
        if tags is not None:
            tag,value = tags.split('=')
            map_dict['restagtable']['tags'] = {tag:value}

        return map_dict

    
    def create_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, use_defaults=use_defaults)
        msg_dict = {'cloudlet': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(cloudlet_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'cloudlet': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(cloudlet_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'app': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)


    def delete_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'cloudlet': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, use_defaults=use_defaults)
        msg_dict = {'cloudlet': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, container_version=None, package_version=None, json_data=None, use_defaults=True, auto_delete=True, include_fields=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, container_version=container_version, package_version=package_version, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, use_defaults=use_defaults, include_fields=include_fields)
        msg_dict = {'cloudlet': msg}

        return self.update(token=token, url=self.update_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)

    def get_cloudlet_metrics(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, selector=None, last=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        print('*WARN*', 'msg',msg)
        metric_dict = msg
        if 'key' in msg:
            metric_dict['cloudlet'] = msg['key']
            del metric_dict['key']
        else:
            metric_dict = msg

        msg_dict = self._build_metrics(type_dict=metric_dict, selector=selector, last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.metrics_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def add_cloudlet_resource_mapping(self, token=None, region=None, cloudlet_name=None, operator_org_name=None, mapping=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)

        map_dict = {'cloudletresmap': msg}
        msg_dict = self._build_mapping(cloudlet_dict=map_dict, mapping=mapping)
        
        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(cloudlet_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
            map_dict_delete = {'cloudletresmap': msg_delete}
            msg_dict_delete = self._build_mapping(cloudlet_dict=map_dict_delete, mapping=mapping)

        #msg_dict_show = None
        #if 'key' in msg:
        #    msg_show = self._build(cloudlet_name=msg['key']['name'], use_defaults=False)
        #    msg_dict_show = {'app': msg_show}

        return self.create(token=token, url=self.addmapping_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict)

    def add_resource_tag(self, token=None, region=None, resource_name=None, operator_org_name=None, tags=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(cloudlet_name=resource_name, operator_org_name=operator_org_name, use_defaults=False)

        map_dict = {'restagtable': msg}
        msg_dict = self._build_restag(cloudlet_dict=map_dict, tags=tags)
        
        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key']:
            msg_delete_pre = self._build(cloudlet_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
            map_dict_del = {'restagtable': msg_delete_pre}
            msg_delete = self._build_restag(cloudlet_dict=map_dict_del, tags=tags, use_defaults=False)
            #map_dict_delete = {'restagtable': msg_delete}
            #msg_dict_delete = self._build_mapping(cloudlet_dict=map_dict_delete, tags=tags)

        #msg_dict_show = None
        #if 'key' in msg:
        #    msg_show = self._build(cloudlet_name=msg['key']['name'], use_defaults=False)
        #    msg_dict_show = {'app': msg_show}

        return self.create(token=token, url=self.addrestag_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict)

