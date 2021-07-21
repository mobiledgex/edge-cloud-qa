import logging
import re

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class GpuDriver(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateGPUDriver'
        self.delete_url = '/auth/ctrl/DeleteGPUDriver'
        self.show_url = '/auth/ctrl/ShowGPUDriver'
        self.update_url = '/auth/ctrl/UpdateGPUDriver'
        self.addbuild_url = '/auth/ctrl/AddGPUDriverBuild'
        self.removebuild_url = '/auth/ctrl/RemoveGPUDriverBuild'
        self.getbuild_url = '/auth/ctrl/GetGPUDriverBuildURL'

    def _build(self, gpudriver_name=None, gpudriver_org=None, builds_dict={}, license_config=None, properties={}, build_name=None, build_driverpath=None, build_os=None, build_md5sum=None, build_driverpathcreds=None, build_kernelversion=None, build_hypervisorinfo=None, ignorestate=None, include_fields=False, use_defaults=True):

        _fields_list = []
        _gpudriver_name_field_number = "2.1"
        _gpudriver_org_field_number  = "2.2"
        _build_name_field_number = "3.1"
        _build_driverpath_field_number = "3.2"
        _build_driverpathcreds_field_number = "3.3"
        _build_os_field_number = "3.4"
        _build_kernelversion_field_number = "3.5"
        _build_hypervisorinfo_field_number = "3.6"
        _build_md5sum_field_number = "3.7"
        _license_config_field_number = "4"
        _properties_field_number = "6"

        if use_defaults:
            if gpudriver_name is None:
                gpudriver_name = shared_variables.gpudriver_name_default
            if gpudriver_org is None:
                gpudriver_org = shared_variables.operator_name_default

        builds_dict_list = []
        if builds_dict:
            dict = {}
            if 'driver_path' in builds_dict.keys():
                dict['driver_path'] = builds_dict['driver_path']
            if 'driver_path_creds' in builds_dict.keys():
                dict['driver_path_creds'] = builds_dict['driver_path_creds']
            if 'kernel_version' in builds_dict.keys():
                dict['kernel_version'] = builds_dict['kernel_version']
            if 'md5sum' in builds_dict.keys():
                dict['md5sum'] = builds_dict['md5sum']
            if 'name' in builds_dict.keys():
                dict['name'] = builds_dict['name']
            if 'operating_system' in builds_dict.keys():
                if builds_dict['operating_system'] == 'Linux':
                    dict['operating_system'] = 0

            if dict:
                builds_dict_list.append(dict)

        gpudriver_dict = {}
        gpudriver_key_dict = {}

        if builds_dict_list:
            gpudriver_dict['builds'] = builds_dict_list

        if gpudriver_name is not None:
            gpudriver_key_dict['name'] = gpudriver_name

        if gpudriver_org is not None:
            gpudriver_key_dict['organization'] = gpudriver_org

        if gpudriver_key_dict:
            gpudriver_dict['key'] = gpudriver_key_dict

        if properties:
            gpudriver_dict['properties'] = properties
            _fields_list.append(_properties_field_number)

        if license_config is not None:
            gpudriver_dict['license_config'] = license_config
            _fields_list.append(_license_config_field_number)

        addbuild_dict = {}
        if build_name is not None:
            addbuild_dict['name'] = build_name

        if build_driverpath is not None:
            addbuild_dict['driver_path'] = build_driverpath           

        if build_os is not None:
            if build_os == 'Linux':
                addbuild_dict['operating_system'] = 0
  
        if build_md5sum is not None:
            addbuild_dict['md5sum'] = build_md5sum

        if build_driverpathcreds is not None:
            addbuild_dict['driver_path_creds'] = build_driverpathcreds

        if build_kernelversion is not None:
            addbuild_dict['kernel_version'] = build_kernelversion
      
        if addbuild_dict:
            gpudriver_dict['build'] = addbuild_dict

        if include_fields and _fields_list:
            gpudriver_dict['fields'] = []
            for field in _fields_list:
                gpudriver_dict['fields'].append(field)

        return gpudriver_dict


    def create_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, builds_dict={}, license_config=None, properties={}, use_defaults=True, use_thread=False, auto_delete=True, json_data=None, stream=True, stream_timeout=100):
        msg = self._build(gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, builds_dict=builds_dict, license_config=license_config, properties=properties, use_defaults=use_defaults)
        msg_dict = {'GPUDriver': msg}

        thread_name = None
        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(gpudriver_name=msg['key']['name'], gpudriver_org=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'GPUDriver': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(gpudriver_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'GPUDriver': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)[0]

    def update_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, license_config=None, properties={}, use_defaults=True, use_thread=False, include_fields=True, json_data=None):
        msg = self._build(gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, license_config=license_config, properties=properties, use_defaults=use_defaults, include_fields=include_fields)
        msg_dict = {'GPUDriver': msg}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(gpudriver_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'GPUDriver': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def delete_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, use_defaults=use_defaults)
        msg_dict = {'GPUDriver': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, properties={}, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, properties=properties,  use_defaults=use_defaults)
        msg_dict = {'GPUDriver': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def addbuild_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, build_name=None, build_driverpath=None, build_os=None, build_md5sum=None, build_driverpathcreds=None, build_kernelversion=None, build_hypervisorinfo=None, ignorestate=None, use_defaults=True, use_thread=False, json_data=None, stream=True, stream_timeout=100):
        msg = self._build(gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, build_name=build_name, build_driverpath=build_driverpath, build_os=build_os, build_md5sum=build_md5sum, build_driverpathcreds=build_driverpathcreds, build_kernelversion=build_kernelversion, build_hypervisorinfo=build_hypervisorinfo, ignorestate=ignorestate, use_defaults=use_defaults)
        msg_dict = {'GPUDriverBuildMember': msg}

        thread_name = None
        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(gpudriver_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'GPUDriver': msg_show}

        return self.create(token=token, url=self.addbuild_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)[0]

    def removebuild_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, build_name=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, build_name=build_name, use_defaults=use_defaults)
        msg_dict = {'GPUDriverBuildMember': msg}
 
        thread_name = None
        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(gpudriver_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'GPUDriver': msg_show}

        return self.create(token=token, url=self.removebuild_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, show_msg=msg_dict_show, thread_name=thread_name)

    def getbuildurl_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, build_name=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, build_name=build_name, use_defaults=use_defaults)
        msg_dict = {'GPUDriverBuildMember': msg}

        return self.show(token=token, url=self.getbuild_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

 
