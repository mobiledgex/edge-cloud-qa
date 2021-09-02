import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex cloudletpoolmember rest')


class CloudletPoolMember(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/AddCloudletPoolMember'
        self.delete_url = '/auth/ctrl/RemoveCloudletPoolMember'
        self.show_url = '/auth/ctrl/ShowCloudletPool'

    def _build(self, cloudlet_pool_name=None, operator_org_name=None, cloudlet_name=None, include_fields=False, use_defaults=True):
        if cloudlet_pool_name == 'default':
            cloudlet_pool_name = shared_variables.cloudletpool_name_default

        if use_defaults:
            if cloudlet_pool_name is None:
                cloudlet_pool_name = shared_variables.cloudletpool_name_default
            if operator_org_name is None:
                operator_org_name = shared_variables.operator_name_default
            if cloudlet_name is None:
                cloudlet_name = shared_variables.cloudlet_name_default

        pool_dict = {}
        pool_key_dict = {}
        if cloudlet_pool_name is not None:
            pool_key_dict['name'] = cloudlet_pool_name

        if operator_org_name is not None:
            pool_key_dict['organization'] = operator_org_name
        if cloudlet_name is not None:
            pool_dict['cloudlet_name'] = cloudlet_name

        if pool_key_dict:
            pool_dict['key'] = pool_key_dict

        return pool_dict

    def add_cloudlet_pool_member(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=use_defaults)
        msg_dict = {'cloudletpoolmember': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'organization' in msg['key'] and 'name' in msg['key'] and 'cloudlet_name' in msg['key']:
            msg_delete = self._build(cloudlet_pool_name=msg['key']['name'], cloudlet_name=msg['cloudlet_name'], operator_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'cloudletpoolmember': msg_delete}

        msg_dict_show = None
        # if 'key' in msg:
        #    msg_show = self._build(cloudlet_pool_name=msg['key']['name'], use_defaults=False)
        #    msg_dict_show = {'cloudletpoolmember': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def remove_cloudlet_pool_member(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=use_defaults)
        msg_dict = {'cloudletpoolmember': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    # def show_cloudlet_pool_member(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
    #    msg = self._build(cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=use_defaults)
    #    msg_dict = {'cloudletpoolmember': msg}

    #    return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
