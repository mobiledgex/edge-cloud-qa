import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_mastercontroller rest')


class VMPool(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateVMPool'
        self.delete_url = '/auth/ctrl/DeleteVMPool'
        self.show_url = '/auth/ctrl/ShowVMPool'

    def _build(self, pool_name=None, organization=None, vm_list=[], use_defaults=True):
        pool = None

        # "key":{"name":"andypool","organization":"TDG"},"vms":[{"name":"andypool","net_info":{"external_ip":"1.1.1.1","internal_ip":"2.2.2.2"}}]}}
        
        if pool_name == 'default':
            pool_name = shared_variables.vmpool_name_default
            
        if use_defaults:
            if pool_name is None: pool_name = shared_variables.vmpool_name_default
            if organization is None: organization = shared_variables.organization_name_default

        pool_dict = {}
        pool_key_dict = {}
        if pool_name is not None:
            pool_key_dict['name'] = pool_name
        if organization is not None:
            pool_key_dict['organization'] = organization

        vm_dict_list = []
        for vm in vm_list:
            vm_dict = {}
            net_dict = {}
            if 'name' in vm and vm['name'] is not None:
                vm_dict['name'] = vm['name']
            if 'external_ip' in vm and vm['external_ip'] is not None:
                net_dict['external_ip'] = vm['external_ip']
            if 'internal_ip' in vm and vm['internal_ip'] is not None:
                net_dict['internal_ip'] = vm['internal_ip']
            if net_dict:
                vm_dict['net_info'] = net_dict

            if vm_dict:
                vm_dict_list.append(vm_dict)    

        if pool_key_dict:
            pool_dict['key'] = pool_key_dict

        if vm_dict_list:
            pool_dict['vms'] = vm_dict_list

        return pool_dict

    def create_vm_pool(self, token=None, region=None, vm_pool_name=None, organization=None, vm_list=[], json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(pool_name=vm_pool_name, organization=organization, vm_list=vm_list, use_defaults=use_defaults)
        msg_dict = {'vmpool': msg}

        thread_name = None
        if 'key' in msg:
            thread_name = msg['key']['name']
            
        msg_dict_delete = None
        if auto_delete and 'key' in msg:
            msg_delete = self._build(pool_name=msg['key']['name'], organization=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'vmpool': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(pool_name=msg['key']['name'], organization=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'vmpool': msg_show}
        
        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name)

    def delete_vm_pool(self, token=None, region=None, vm_pool_name=None, organization=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(pool_name=vm_pool_name, organization=organization, use_defaults=use_defaults)
        msg_dict = {'vmpool': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_vm_pool(self, token=None, region=None, vm_pool_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(pool_name=vm_pool_name, use_defaults=use_defaults)
        msg_dict = {'vmpool': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

