import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_mastercontroller rest')


class CloudletPool(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateCloudletPool'
        self.delete_url = '/auth/ctrl/DeleteCloudletPool'
        self.show_url = '/auth/ctrl/ShowCloudletPool'

    def _build(self, cloudlet_pool_name=None, organization=None, cloudlet_list=None, use_defaults=True):
        pool = None

        if cloudlet_pool_name == 'default':
            cloudlet_pool_name = shared_variables.cloudletpool_name_default
            
        if use_defaults:
            if cloudlet_pool_name is None: cloudlet_pool_name = shared_variables.cloudletpool_name_default
            if organization is None: organization = shared_variables.operator_name_default

        pool_dict = {}
        pool_key_dict = {}
        if cloudlet_pool_name is not None:
            pool_key_dict['name'] = cloudlet_pool_name

        if organization is not None:
            pool_key_dict['organization'] = organization
           
        if cloudlet_list is not None:
           pool_dict['cloudlets'] = cloudlet_list
 
        if pool_key_dict:
            pool_dict['key'] = pool_key_dict

        return pool_dict

    def create_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_list=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, organization=operator_org_name, cloudlet_list=cloudlet_list, use_defaults=use_defaults)
        msg_dict = {'cloudletpool': msg}

        thread_name = None
        if 'key' in msg and 'name' in msg['key']:
            thread_name = msg['key']['name']
            
        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(cloudlet_pool_name=msg['key']['name'], organization=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'cloudletpool': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_show = self._build(cloudlet_pool_name=msg['key']['name'], organization=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'cloudletpool': msg_show}
        
        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name)

    def delete_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, organization=operator_org_name, use_defaults=use_defaults)
        msg_dict = {'cloudletpool': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, organization=operator_org_name, use_defaults=use_defaults)
        msg_dict = {'cloudletpool': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

