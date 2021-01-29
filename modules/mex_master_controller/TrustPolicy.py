import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)

class TrustPolicy(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateTrustPolicy'
        self.delete_url = '/auth/ctrl/DeleteTrustPolicy'
        self.show_url = '/auth/ctrl/ShowTrustPolicy'
        self.update_url = '/auth/ctrl/UpdateTrustPolicy'

    def _build(self, policy_name=None, operator_org_name=None, rule_list=[], include_fields=False, use_defaults=True):
        _fields_list = []
        _policy_name_field_number = "2.1"
        _operator_name_field_number = "2.2"
        _protocol_field_number = "3.1"
        _port_range_min_field_number = "3.2"
        _port_range_max_field_number = "3.3"
        _remote_cidr_field_number = "3.4"

        if use_defaults:
            if policy_name is None: policy_name = shared_variables.trust_policy_name_default
            #if operator_org_name is None: operator_org_name = shared_variables.operator_name_default
        
        #"{\"cloudlet\":{\"key\":{\"name\":\"rrrr\",\"developer\":\"dev\"},\"location\":{\"latitude\":5,\"longitude\":5,\"timestamp\":{}},\"ip_support\":2,\"num_dynamic_ips\":2}}"
        policy_dict = {}
        policy_key_dict = {}
        
        if policy_name is not None:
            policy_key_dict['name'] = policy_name
            _fields_list.append(_policy_name_field_number)
        if operator_org_name is not None:
            policy_key_dict['organization'] = operator_org_name
            _fields_list.append(_operator_name_field_number)

        if policy_key_dict:
            policy_dict['key'] = policy_key_dict

        rule_dict_list = []
        for rule in rule_list:
            rule_dict = {}
            if 'protocol' in rule and rule['protocol'] is not None:
                rule_dict['protocol'] = rule['protocol']
                _fields_list.append(_protocol_field_number)
                
            if 'port_range_minimum' in rule and rule['port_range_minimum'] is not None:
                try:
                    rule_dict['port_range_min'] = int(rule['port_range_minimum'])
                except:
                    rule_dict['port_range_min'] = rule['port_range_minimum']
                _fields_list.append(_port_range_min_field_number)
                
            if 'port_range_maximum' in rule and rule['port_range_maximum'] is not None:
                try:
                    rule_dict['port_range_max'] = int(rule['port_range_maximum'])
                except:
                    rule_dict['port_range_max'] = rule['port_range_maximum']
                _fields_list.append(_port_range_max_field_number)
                
            if 'remote_cidr' in rule and rule['remote_cidr'] is not None:
                rule_dict['remote_cidr'] = rule['remote_cidr']
                _fields_list.append(_remote_cidr_field_number)

            if rule == 'empty':
                _fields_list.append(_protocol_field_number)
                _fields_list.append(_port_range_min_field_number)
                _fields_list.append(_port_range_max_field_number)
                _fields_list.append(_remote_cidr_field_number)
                
            if rule_dict:
                rule_dict_list.append(rule_dict)    
            policy_dict['outbound_security_rules'] = rule_dict_list

        if include_fields and _fields_list:
            policy_dict['fields'] = []
            for field in _fields_list:
                policy_dict['fields'].append(field)

        return policy_dict

    def create_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, rule_list=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, operator_org_name=operator_org_name, rule_list=rule_list, use_defaults=use_defaults)
        msg_dict = {'trustpolicy': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(policy_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'trustpolicy': msg_delete}

        msg_dict_show = None
        if 'key' in msg  and 'name' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'trustpolicy': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def delete_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, rule_list=[], json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, operator_org_name=operator_org_name, rule_list=rule_list, use_defaults=use_defaults)
        msg_dict = {'trustpolicy': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg_dict = {'trustpolicy': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, rule_list=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, operator_org_name=operator_org_name, rule_list=rule_list, use_defaults=use_defaults, include_fields=True)
        msg_dict = {'trustpolicy': msg}

        msg_dict_show = None
        if 'key' in msg  and 'name' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'trustpolicy': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)
