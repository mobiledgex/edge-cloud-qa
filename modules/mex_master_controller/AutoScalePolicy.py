import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_autoscalepolicy rest')


class AutoScalePolicy(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateAutoScalePolicy'
        self.delete_url = '/auth/ctrl/DeleteAutoScalePolicy'
        self.show_url = '/auth/ctrl/ShowAutoScalePolicy'
        self.update_url = '/auth/ctrl/UpdateAutoScalePolicy'

    def _build(self, policy_name=None, developer_name=None, developer_org_name=None, min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None, include_fields=False, use_defaults=True):

        policy = None

        policy_name = policy_name
        developer_name = developer_name
        min_nodes = min_nodes
        max_nodes = max_nodes
        scale_up_cpu_threshold = scale_up_cpu_threshold
        scale_down_cpu_threshold = scale_down_cpu_threshold
        trigger_time = trigger_time

        _fields_list = []
        _developer_field_number = "2.1"
        _name_field_number = "2.2"
        _min_nodes_field_number = "3"
        _max_nodes_field_number = "4"
        _scale_up_cpu_threshold_field_number = "5"
        _scale_down_cpu_threshold_field_number = "6"
        _trigger_time_field_number = "7"
                
        if policy_name == 'default':
            policy_name = shared_variables.autoscale_policy_name_default
            
        if use_defaults:
            if policy_name is None: policy_name = shared_variables.autoscale_policy_name_default
            #if developer_name is None: developer_name = shared_variables.developer_name_default
            if developer_org_name is None: developer_org_name = shared_variables.developer_name_default
            if min_nodes is None: min_nodes = 1
            if max_nodes is None: max_nodes = 2
            if scale_up_cpu_threshold is None: scale_up_cpu_threshold = 50
            if scale_down_cpu_threshold is None: scale_down_cpu_threshold = 40
            if trigger_time is None: trigger_time = 30

        policy_dict = {}
        policy_key_dict = {}
        if policy_name is not None:
            policy_key_dict['name'] = policy_name
            _fields_list.append(_name_field_number)

        if developer_name:
            policy_key_dict['developer'] = developer_name
            _fields_list.append(_developer_field_number)
   
        if developer_org_name is not None:
            policy_key_dict['organization'] = developer_org_name
                        
        if policy_key_dict:
            policy_dict['key'] = policy_key_dict

        if min_nodes is not None:
            try:
                policy_dict['min_nodes'] = int(min_nodes)
            except:
                policy_dict['min_nodes'] = min_nodes
            _fields_list.append(_min_nodes_field_number)
            
        if max_nodes is not None:
            try:
                policy_dict['max_nodes'] = int(max_nodes)
            except:
                policy_dict['max_nodes'] = max_nodes
            _fields_list.append(_max_nodes_field_number)
            
        if scale_up_cpu_threshold is not None:
            try:
                policy_dict['scale_up_cpu_thresh'] = int(scale_up_cpu_threshold)
            except:
                policy_dict['scale_up_cpu_thresh'] = scale_up_cpu_threshold
            _fields_list.append(_scale_up_cpu_threshold_field_number)
            
        if scale_down_cpu_threshold is not None:
            try:
                policy_dict['scale_down_cpu_thresh'] = int(scale_down_cpu_threshold)
            except:
                policy_dict['scale_down_cpu_thresh'] = scale_down_cpu_threshold
            _fields_list.append(_scale_down_cpu_threshold_field_number)
            
        if trigger_time is not None:
            try:
                policy_dict['trigger_time_sec'] = int(trigger_time)
            except:
                policy_dict['trigger_time_sec'] = trigger_time
            _fields_list.append(_trigger_time_field_number)
        
        if include_fields and _fields_list:
            policy_dict['fields'] = []
            for field in _fields_list:
                policy_dict['fields'].append(field)

        return policy_dict

    def create_autoscale_policy(self, token=None, region=None, policy_name=None, developer_name=None, developer_org_name=None, min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_name=developer_name, developer_org_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_cpu_threshold, scale_down_cpu_threshold=scale_down_cpu_threshold, trigger_time=trigger_time, use_defaults=use_defaults)
        msg_dict = {'autoscalepolicy': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(policy_name=msg['key']['name'], developer_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'autoscalepolicy': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], developer_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'autoscalepolicy': msg_show}
        
        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def show_autoscale_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_cpu_threshold, scale_down_cpu_threshold=scale_down_cpu_threshold, trigger_time=trigger_time, use_defaults=use_defaults)
        msg_dict = {'autoscalepolicy': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def delete_autoscale_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_cpu_threshold, scale_down_cpu_threshold=scale_down_cpu_threshold, trigger_time=trigger_time, use_defaults=use_defaults)
        msg_dict = {'autoscalepolicy': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_autoscale_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None,  json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, developer_org_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_cpu_threshold, scale_down_cpu_threshold=scale_down_cpu_threshold, trigger_time=trigger_time, use_defaults=use_defaults, include_fields=True)
        msg_dict = {'autoscalepolicy': msg}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], developer_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'autoscalepolicy': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

