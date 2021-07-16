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
        self.update_url = '/auth/ctrl/UpdateVMPool'
        self.add_member_url = '/auth/ctrl/AddVMPoolMember'
        self.remove_member_url = '/auth/ctrl/RemoveVMPoolMember'

    def _build(self, pool_name=None, organization=None, vm_list=None, include_fields=False, use_defaults=True):
        pool = None
 
        _fields_list = []
        _operator_name_field_number = '2.1'
        _pool_name_field_number = '2.2'
        _vms_field_number = '3'

        # "key":{"name":"andypool","organization":"GDDT"},"vms":[{"name":"andypool","net_info":{"external_ip":"1.1.1.1","internal_ip":"2.2.2.2"}}]}}
        
        if pool_name == 'default':
            pool_name = shared_variables.vmpool_name_default
            
        if use_defaults:
            if pool_name is None: pool_name = shared_variables.vmpool_name_default
            if organization is None: organization = shared_variables.organization_name_default

        pool_dict = {}
        pool_key_dict = {}
        if pool_name is not None:
            pool_key_dict['name'] = pool_name
            _fields_list.append(_pool_name_field_number)

        if organization is not None:
            pool_key_dict['organization'] = organization
            _fields_list.append(_operator_name_field_number)

        vm_dict_list = None 
        if vm_list is not None:
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
                if 'state' in vm and vm['state'] is not None:
                    vm_dict['state'] = vm['state']
                if net_dict:
                    vm_dict['net_info'] = net_dict

                if vm_dict:
                    vm_dict_list.append(vm_dict)    

        if pool_key_dict:
            pool_dict['key'] = pool_key_dict

        if vm_dict_list is not None:
            pool_dict['vms'] = vm_dict_list
            _fields_list.append(_vms_field_number)

        if include_fields and _fields_list:
            pool_dict['fields'] = []
            for field in _fields_list:
                pool_dict['fields'].append(field)

        return pool_dict

    def _build_member(self, pool_name=None, organization=None, vm_name=None, external_ip=None, internal_ip=None, include_fields=False, use_defaults=True):
        pool = None

        # "key":{"name":"andypool","organization":"GDDT"},"vms":[{"name":"andypool","net_info":{"external_ip":"1.1.1.1","internal_ip":"2.2.2.2"}}]}}

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

        vm_dict = {}
        net_dict = {}
        if vm_name is not None:
            vm_dict['name'] = vm_name
        if external_ip is not None:
            net_dict['external_ip'] = external_ip
        if internal_ip is not None:
            net_dict['internal_ip'] = internal_ip
        if net_dict:
            vm_dict['net_info'] = net_dict

        if pool_key_dict:
            pool_dict['key'] = pool_key_dict

        if vm_dict:
            pool_dict['vm'] = vm_dict

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

    def show_vm_pool(self, token=None, region=None, vm_pool_name=None, organization=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(pool_name=vm_pool_name, organization=organization, use_defaults=use_defaults)
        msg_dict = {'vmpool': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_vm_pool(self, token=None, region=None, vm_pool_name=None, organization=None, vm_list=None, json_data=None, use_defaults=True, include_fields=True, use_thread=False):
        msg = self._build(pool_name=vm_pool_name, organization=organization, vm_list=vm_list, include_fields=include_fields, use_defaults=use_defaults)
        msg_dict = {'vmpool': msg}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(pool_name=msg['key']['name'], organization=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'vmpool': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def add_vm_pool_member(self, token=None, region=None, vm_pool_name=None, organization=None, vm_name=None, external_ip=None, internal_ip=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build_member(pool_name=vm_pool_name, organization=organization, vm_name=vm_name, external_ip=external_ip, internal_ip=internal_ip, use_defaults=use_defaults)
        msg_dict = {'vmpoolmember': msg}

        thread_name = None
        if 'key' in msg:
            thread_name = msg['key']['name']

        msg_dict_delete = None
        #if auto_delete and 'key' in msg:
        #    msg_delete = self._build(pool_name=msg['key']['name'], organization=msg['key']['organization'], use_defaults=False)
        #    msg_dict_delete = {'vmpoolmember': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(pool_name=msg['key']['name'], organization=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'vmpool': msg_show}

        return self.create(token=token, url=self.add_member_url, delete_url=self.remove_member_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name)

    def remove_vm_pool_member(self, token=None, region=None, vm_pool_name=None, organization=None, vm_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build_member(pool_name=vm_pool_name, organization=organization, vm_name=vm_name, use_defaults=use_defaults)
        msg_dict = {'vmpoolmember': msg}

        return self.delete(token=token, url=self.remove_member_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def vm_should_be_in_use(self, token=None, region=None, vm_pool_name=None, organization=None, group_name=None, internal_name=None):
        pool = self.show_vm_pool(token=token, region=region, vm_pool_name=vm_pool_name, organization=organization, use_defaults=True)
        if not pool:
            raise Exception(f'VM pool={vm_pool_name} not found')

        for vm in pool[0]['data']['vms']:
            if 'group_name' in vm and vm['group_name'] == group_name and vm['internal_name'] == internal_name and vm['state'] == 'InUse':
                return vm['name']

        raise Exception(f'VM with group_name={group_name} and internal_name={internal_name} not In Use or not found')
                
    def vm_should_not_be_in_use(self, token=None, region=None, vm_pool_name=None, organization=None, vm_name=None):
        pool = self.show_vm_pool(token=token, region=region, vm_pool_name=vm_pool_name, organization=organization, use_defaults=True)
        if not pool:
            raise Exception(f'VM pool={vm_pool_name} not found')

        vm_found = False
        
        for vm in pool[0]['data']['vms']:
            if vm['name'] == vm_name:
                logging.debug(f'found vm:{vm}')
                vm_found = True
                if 'group_name' in vm or 'internal_name' in vm or 'state' in vm:
                   raise Exception(f'VM pool={vm_pool_name} name={vm_name} is in use:{vm}') 
                else:
                    logging.debug('vm is not in use')

        if not vm_found:
           raise Exception(f'VM with pool={vm_pool_name} name={vm_name} is not found')

        return True 
