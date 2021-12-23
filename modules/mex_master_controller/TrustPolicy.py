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
        self.create_exception_url = '/auth/ctrl/CreateTrustPolicyException'
        self.delete_exception_url = '/auth/ctrl/DeleteTrustPolicyException'
        self.show_exception_url = '/auth/ctrl/ShowTrustPolicyException'
        self.update_exception_url = '/auth/ctrl/UpdateTrustPolicyException'

    def _build(self, policy_name=None, operator_org_name=None, rule_list=[], include_fields=False, use_defaults=True):
        _fields_list = []
        _policy_name_field_number = "2.1"
        _operator_name_field_number = "2.2"
        _protocol_field_number = "3.1"
        _port_range_min_field_number = "3.2"
        _port_range_max_field_number = "3.3"
        _remote_cidr_field_number = "3.4"

        if use_defaults:
            if policy_name is None:
                policy_name = shared_variables.trust_policy_name_default
            if operator_org_name is None:
                operator_org_name = shared_variables.operator_name_default

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
                except Exception:
                    rule_dict['port_range_min'] = rule['port_range_minimum']
                _fields_list.append(_port_range_min_field_number)

            if 'port_range_maximum' in rule and rule['port_range_maximum'] is not None:
                try:
                    rule_dict['port_range_max'] = int(rule['port_range_maximum'])
                except Exception:
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

    def _build_exception(self, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, rule_list=[], state=None, use_defaults=True):
        if use_defaults:
            if policy_name is None:
                policy_name = shared_variables.trust_policy_name_default
            if app_name is None:
                app_name = shared_variables.app_name_default
            if developer_org_name is None:
                developer_org_name = shared_variables.developer_name_default
            if app_version is None:
                app_version = shared_variables.app_version_default
            if cloudlet_pool_name is None:
                cloudlet_pool_name = shared_variables.cloudletpool_name_default
            if cloudlet_pool_org_name is None:
                cloudlet_pool_org_name = shared_variables.operator_name_default

        policy_dict = {}
        policy_key_dict = {}
        app_key_dict = {}
        cloudlet_pool_key_dict = {}

        if policy_name is not None:
            policy_key_dict['name'] = policy_name

        if app_name is not None:
            app_key_dict['name'] = app_name
        if developer_org_name is not None:
            app_key_dict['organization'] = developer_org_name
        if app_version is not None:
            app_key_dict['version'] = app_version

        if cloudlet_pool_name is not None:
            cloudlet_pool_key_dict['name'] = cloudlet_pool_name
        if cloudlet_pool_org_name is not None:
            cloudlet_pool_key_dict['organization'] = cloudlet_pool_org_name

        if policy_key_dict:
            policy_dict['key'] = policy_key_dict

        if app_key_dict:
            if 'key' not in policy_dict:
                policy_dict['key'] = {}
            policy_dict['key']['app_key'] = app_key_dict

        if cloudlet_pool_key_dict:
            policy_dict['key']['cloudlet_pool_key'] = cloudlet_pool_key_dict

        if state is not None:
            state = state.lower()
            state_dict = {'unknown': 0, 'approvalrequested': 1, 'active': 2, 'rejected': 3}
            policy_dict['state'] = state_dict[state]

        if 'empty' in rule_list:
            policy_dict['outbound_security_rules'] = []
        elif rule_list:
            rule_dict_list = self._build_rules(rule_list)
            policy_dict['outbound_security_rules'] = rule_dict_list

        return policy_dict

    def _build_rules(self, rule_list=[]):
        rule_dict_list = []

        if 'empty' not in rule_list:
            for rule in rule_list:
                rule_dict = {}
                if 'protocol' in rule and rule['protocol'] is not None:
                    rule_dict['protocol'] = rule['protocol']

                if 'port_range_minimum' in rule and rule['port_range_minimum'] is not None:
                    try:
                        rule_dict['port_range_min'] = int(rule['port_range_minimum'])
                    except Exception:
                        rule_dict['port_range_min'] = rule['port_range_minimum']

                if 'port_range_maximum' in rule and rule['port_range_maximum'] is not None:
                    try:
                        rule_dict['port_range_max'] = int(rule['port_range_maximum'])
                    except Exception:
                        rule_dict['port_range_max'] = rule['port_range_maximum']

                if 'remote_cidr' in rule and rule['remote_cidr'] is not None:
                    rule_dict['remote_cidr'] = rule['remote_cidr']

                if rule_dict:
                    rule_dict_list.append(rule_dict)

        return rule_dict_list

    def create_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, rule_list=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(policy_name=policy_name, operator_org_name=operator_org_name, rule_list=rule_list, use_defaults=use_defaults)
        msg_dict = {'trustpolicy': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(policy_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'trustpolicy': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
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
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'trustpolicy': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def create_trust_policy_exception(self, token=None, region=None, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, rule_list=None, state=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build_exception(policy_name=policy_name, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, rule_list=rule_list, state=state, use_defaults=use_defaults)
        msg_dict = {'trustpolicyexception': msg}

        msg_dict_delete = None
        print('*WARN*', 'msgaaa', msg)
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'app_key' in msg['key'] and 'name' in msg['key']['app_key'] and 'version' in msg['key']['app_key'] and 'organization' in msg['key']['app_key'] and 'cloudlet_pool_key' in msg['key'] and 'name' in msg['key']['cloudlet_pool_key'] and 'organization' in msg['key']['cloudlet_pool_key']:
            msg_delete = self._build_exception(policy_name=msg['key']['name'], app_name=msg['key']['app_key']['name'], developer_org_name=msg['key']['app_key']['organization'], app_version=msg['key']['app_key']['version'], cloudlet_pool_name=msg['key']['cloudlet_pool_key']['name'], cloudlet_pool_org_name=msg['key']['cloudlet_pool_key']['organization'], use_defaults=False)
            msg_dict_delete = {'trustpolicyexception': msg_delete}
            print('*WARN*', 'msgdelete', msg_dict_delete)
        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build_exception(policy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'trustpolicyexception': msg_show}

        return self.create(token=token, url=self.create_exception_url, delete_url=self.delete_exception_url, show_url=self.show_exception_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def delete_trust_policy_exception(self, token=None, region=None, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, rule_list=[], json_data=None, use_defaults=True, use_thread=False):
        msg = self._build_exception(policy_name=policy_name, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, rule_list=rule_list, use_defaults=use_defaults)
        msg_dict = {'trustpolicyexception': msg}
        print('xxxx', msg_dict)
        return self.delete(token=token, url=self.delete_exception_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_trust_policy_exception(self, token=None, region=None, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, json_data=None, rule_list=[], use_defaults=True, use_thread=False):
        msg = self._build_exception(policy_name=policy_name, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, rule_list=rule_list, use_defaults=use_defaults)
        msg_dict = {'trustpolicyexception': msg}

        return self.show(token=token, url=self.show_exception_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_trust_policy_exception(self, token=None, region=None, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, json_data=None, rule_list=[], state=None, use_defaults=True, use_thread=False):
        msg = self._build_exception(policy_name=policy_name, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, rule_list=rule_list, state=state, use_defaults=use_defaults)
        msg_dict = {'trustpolicyexception': msg}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(policy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'trustpolicyexception': msg_show}

        return self.update(token=token, url=self.update_exception_url, show_url=self.show_exception_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)
