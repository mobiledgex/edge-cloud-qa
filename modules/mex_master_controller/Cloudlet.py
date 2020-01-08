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

    def _build(self, cloudlet_name=None, operator_name=None, number_dynamic_ips=None, latitude=None, longitude=None, ip_support=None, access_uri=None, static_ips=None, platform_type=None, physical_name=None, version=None, env_vars=None, crm_override=None, notify_server_address=None, include_fields=False, use_defaults=True):

        _fields_list = []
        _operator_name_field_number = "2.1.1"
        _cloudlet_name_field_number = "2.2"
        _version_field_number = "20"

        if use_defaults:
            if cloudlet_name is None: cloudlet_name = shared_variables.cloudlet_name_default
            if operator_name is None: operator_name = shared_variables.operator_name_default
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
        if operator_name is not None:
            cloudlet_key_dict['operator_key'] = {'name': operator_name}
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

        if version is not None:
            cloudlet_dict['version'] = version
            _fields_list.append(_version_field_number)
            
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

    def create_cloudlet(self, token=None, region=None, operator_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(cloudlet_name=cloudlet_name, operator_name=operator_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, use_defaults=use_defaults)
        msg_dict = {'cloudlet': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'operator_key' in msg['key']:
            msg_delete = self._build(cloudlet_name=msg['key']['name'], operator_name=msg['key']['operator_key']['name'], use_defaults=False)
            msg_dict_delete = {'cloudlet': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(cloudlet_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'app': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)


    def delete_cloudlet(self, token=None, region=None, operator_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_name=operator_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'cloudlet': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_cloudlet(self, token=None, region=None, operator_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_name=operator_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, version=version, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, use_defaults=use_defaults, include_fields=include_fields)
        msg_dict = {'cloudlet': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_cloudlet(self, token=None, region=None, operator_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, version=None, json_data=None, use_defaults=True, auto_delete=True, include_fields=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_name=operator_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, version=version, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, use_defaults=use_defaults, include_fields=include_fields)
        msg_dict = {'cloudlet': msg}

        return self.update(token=token, url=self.update_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)
