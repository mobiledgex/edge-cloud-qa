import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex cloudlet rest')


class AutoProvisioningPolicy(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateAutoProvPolicy'
        self.delete_url = '/auth/ctrl/DeleteAutoProvPolicy'
        self.show_url = '/auth/ctrl/ShowAutoProvPolicy'
        self.update_url = '/auth/ctrl/UpdateAutoProvPolicy'
        self.addcloudlet_url = '/auth/ctrl/AddAutoProvPolicyCloudlet'
        self.removecloudlet_url = '/auth/ctrl/RemoveAutoProvPolicyCloudlet'

    def _build(self, policy_name=None, developer_org_name=None, deploy_client_count=None, deploy_interval_count=None, cloudlet_name=None, undeploy_client_count=None, undeploy_interval_count=None, min_active_instances=None, max_instances=None, operator_org_name=None, cloudlet_list=None, include_fields=False, use_defaults=True):
        _fields_list = []
        _policy_name_field_number = "2.1"
        _developer_name_field_number = "2.2"
        _deploy_client_count_field_number = "3"
        _deploy_interval_count_field_number = "4"
        _min_active_instances_field_number = "6"
        _max_instances_field_number = "7"
        _undeploy_client_count_field_number = "8"
        # _undeploy_interval_count_field_number = "9"
        # _cloudlets_field_number = "5"
        # _cloudlet_organization_field
        _cloudlet_org_field_number = "5.1.1"
        _cloudlet_name_field_number = "5.1.2"

        if use_defaults:
            if policy_name is None:
                policy_name = shared_variables.autoprov_policy_name_default
            if developer_org_name is None:
                developer_org_name = shared_variables.developer_name_default

        # {"autoprovpolicy":{"deploy_client_count":1,"deploy_interval_count":1,"key":{"name":"mypolicy","organization":"MobiledgeX"}},"region":"EU"}
        # {"autoprovpolicycloudlet":{"cloudlet_key":{"name":"automationMunichCloudlet","organization":"TDG"},"key":{"name":"TestAutoPolicy","organization":"ldevorg"}},"region":"EU"}

        shared_variables.autoprov_policy_name_default = policy_name

        policy_dict = {}
        policy_key_dict = {}
        cloudlet_key_dict = {}
        cloudlet_dict = {}

        if policy_name is not None:
            policy_key_dict['name'] = policy_name
            _fields_list.append(_policy_name_field_number)
        if developer_org_name is not None:
            policy_key_dict['organization'] = developer_org_name
            _fields_list.append(_developer_name_field_number)

        if policy_key_dict:
            policy_dict['key'] = policy_key_dict

        if deploy_client_count is not None:
            try:
                policy_dict['deploy_client_count'] = int(deploy_client_count)
            except Exception:
                policy_dict['deploy_client_count'] = deploy_client_count
            _fields_list.append(_deploy_client_count_field_number)

        if deploy_interval_count is not None:
            try:
                policy_dict['deploy_interval_count'] = int(deploy_interval_count)
            except Exception:
                policy_dict['deploy_interval_count'] = deploy_interval_count
            _fields_list.append(_deploy_interval_count_field_number)

        if undeploy_client_count is not None:
            try:
                policy_dict['undeploy_client_count'] = int(undeploy_client_count)
            except Exception:
                policy_dict['undeploy_client_count'] = undeploy_client_count
            _fields_list.append(_undeploy_client_count_field_number)

        if undeploy_interval_count is not None:
            try:
                policy_dict['undeploy_interval_count'] = int(undeploy_interval_count)
            except Exception:
                policy_dict['undeploy_interval_count'] = undeploy_interval_count
            _fields_list.append(_deploy_interval_count_field_number)

        if min_active_instances is not None:
            try:
                policy_dict['min_active_instances'] = int(min_active_instances)
            except Exception:
                policy_dict['min_active_instances'] = min_active_instances
            _fields_list.append(_min_active_instances_field_number)

        if max_instances is not None:
            try:
                policy_dict['max_instances'] = int(max_instances)
            except Exception:
                policy_dict['max_instances'] = max_instances
            _fields_list.append(_max_instances_field_number)

        cloudlet_dict_list = None
        if cloudlet_list is not None:
            cloudlet_dict_list = []
            for cloudlet in cloudlet_list:
                cloudlet_dict = {}
                cloudlet_key_dict = {}
                cloudlet_dict['key'] = cloudlet
                cloudlet_dict_list.append(cloudlet_dict)

        if cloudlet_dict_list is not None:
            policy_dict['cloudlets'] = cloudlet_dict_list
            _fields_list.append(_cloudlet_name_field_number)
            _fields_list.append(_cloudlet_org_field_number)

        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name

        if cloudlet_key_dict:
            policy_dict['cloudlet_key'] = cloudlet_key_dict

        if include_fields and _fields_list:
            policy_dict['fields'] = []
            for field in _fields_list:
                policy_dict['fields'].append(field)

        return policy_dict

    def create_autoprov_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, deploy_client_count=None, deploy_interval_count=None, undeploy_client_count=None, undeploy_interval_count=None, min_active_instances=None, max_instances=None, cloudlet_list=[], json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, deploy_client_count=deploy_client_count, deploy_interval_count=deploy_interval_count, undeploy_client_count=undeploy_client_count, undeploy_interval_count=undeploy_interval_count, min_active_instances=min_active_instances, max_instances=max_instances, cloudlet_list=cloudlet_list, use_defaults=use_defaults)
        msg_dict = {'autoprovpolicy': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(policy_name=msg['key']['name'], developer_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'autoprovpolicy': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'autoprovpolicy': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def delete_autoprov_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, use_defaults=use_defaults)
        msg_dict = {'autoprovpolicy': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_autoprov_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, use_defaults=use_defaults)
        msg_dict = {'autoprovpolicy': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_autoprov_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, deploy_client_count=None, deploy_interval_count=None, undeploy_client_count=None, undeploy_interval_count=None, min_active_instances=None, max_instances=None, cloudlet_list=[], json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, deploy_client_count=deploy_client_count, deploy_interval_count=deploy_interval_count, undeploy_client_count=undeploy_client_count, undeploy_interval_count=undeploy_interval_count, min_active_instances=min_active_instances, max_instances=max_instances, cloudlet_list=cloudlet_list, use_defaults=use_defaults, include_fields=True)
        msg_dict = {'autoprovpolicy': msg}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'autoprovpolicy': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def add_autoprov_policy_cloudlet(self, token=None, region=None, policy_name=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg_dict = {'autoprovpolicycloudlet': msg}

        # msg_dict_delete = None
        # if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
        #    msg_delete = self._build(policy_name=msg['key']['name'], developer_org_name=msg['key']['organization'], use_defaults=False)
        #    msg_dict_delete = {'autoprovpolicycloudlet': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'autoprovpolicy': msg_show}

        return self.create(token=token, url=self.addcloudlet_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=None, show_msg=msg_dict_show)

    def remove_autoprov_policy_cloudlet(self, token=None, region=None, policy_name=None, developer_org_name=None,
                                        cloudlet_name=None, operator_org_name=None, json_data=None, auto_delete=True,
                                        use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name,
                          operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg_dict = {'autoprovpolicycloudlet': msg}
        # return self.delete(token=token, url=self.removecloudlet_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)
        return self.delete(token=token, url=self.removecloudlet_url, region=region, json_data=json_data,
                           use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
