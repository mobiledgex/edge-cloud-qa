import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

#from mex_rest import MexRest

logger = logging.getLogger('mex_orgcloudletpool rest')


class OrgCloudletPool(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/orgcloudletpool/create'
        self.delete_url = '/auth/orgcloudletpool/delete'
        self.show_url = '/auth/orgcloudletpool/show'

    def _build(self, cloudlet_pool_name=None, org_name=None, use_defaults=True):
        pool = None

        if cloudlet_pool_name == 'default':
            cloudlet_pool_name = shared_variables.cloudletpool_name_default
            
        if use_defaults:
            if cloudlet_pool_name is None: cloudlet_pool_name = shared_variables.cloudletpool_name_default
            if org_name is None: org_name = shared_variables.organization_name_default

        pool_dict = {}
        if cloudlet_pool_name is not None:
            pool_dict['cloudletpool'] = cloudlet_pool_name

        if org_name is not None:
            pool_dict['org'] = org_name

        return pool_dict


    def create_org_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, org_name=None, json_data=None, use_defaults=True, auto_delete=True,  use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, org_name=org_name, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_delete = None
        if auto_delete and 'cloudletpool' in msg and 'org' in msg:
            msg_delete = self._build(cloudlet_pool_name=msg['cloudletpool'], org_name=msg['org'], use_defaults=False)
            msg_dict_delete = msg_delete

        msg_dict_show = None
        if 'cloudletpool' in msg:
            msg_show = self._build(cloudlet_pool_name=msg['cloudletpool'], use_defaults=False)
            msg_dict_show = msg_show
        
        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def delete_org_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, org_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, org_name=org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_org_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, org_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, org_name=org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

