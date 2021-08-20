import logging
import re
import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex alertpolicy rest')


class AlertPolicy(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateAlertPolicy'
        self.delete_url = '/auth/ctrl/DeleteAlertPolicy'
        self.show_url = '/auth/ctrl/ShowAlertPolicy'
        self.update_url = '/auth/ctrl/UpdateAlertPolicy'

# '{"AlertPolicy":{"annotations":{"empty":"true"},"cpu_utilization_limit":4,"description":"this is robot testcase alertpolicy","disk_utilization_limit":4,"key":{"name":"alertpolicyname","organization":"wwtdev"},"labels":{"empty":"true"},"mem_utilization_limit":4,"severity":"info","trigger_time":"30s"},"Region":"US"}'

    def _build(self, alertpolicy_name=None,  alert_org=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, auto_delete=True):

        alert_policy_dict = {}
        alert_key_dict = {}
        annotations_dict = {}
        labels_dict = {}

        alert_key_dict = {}
        if alertpolicy_name is not None:
            alert_key_dict['name'] = alertpolicy_name

        if alert_org is not None:
            alert_key_dict['organization'] = alert_org

        if alert_key_dict:
            alert_policy_dict['key'] = alert_key_dict

        annotations_dict = {}
        if annotations_vars:
            var_list = annotations_vars.split(':')
            print('varlist', var_list)
            for var in var_list:
             print(var)
             s = var.split('=')
             annotations_dict[s[0]] = s[1]
            alert_policy_dict['annotations'] = annotations_dict

        labels_dict = {}
        if labels_vars is not None:
            var_list = labels_vars.split(',')
            print('varlist', var_list)
            for var in var_list:
             print(var)
             s = var.split('=')
             labels_dict[s[0]] = s[1]
            alert_policy_dict['labels'] = labels_dict       

        if severity is not None:
            alert_policy_dict['severity'] = severity
        if trigger_time is not None:
            alert_policy_dict['trigger_time'] = trigger_time
        if description is not None:
            alert_policy_dict['description'] = description            

        if cpu_utilization is not None:
            try:
                alert_policy_dict['cpu_utilization_limit'] = int(cpu_utilization)
            except Exception:
                alert_policy_dict['cpu_utilization_limit'] = cpu_utilization
        if mem_utilization is not None:
            try:
                alert_policy_dict['mem_utilization_limit'] = int(mem_utilization)
            except Exception:
                alert_policy_dict['mem_utilization_limit'] = mem_utilization
        if disk_utilization is not None:
            try:
                alert_policy_dict['disk_utilization_limit'] = int(disk_utilization)
            except Exception:
                alert_policy_dict['disk_utilization_limit'] = disk_utilization
        if active_connections is not None:
            try:
                alert_policy_dict['active_conn_limit'] = int(active_connections)
            except Exception:
                alert_policy_dict['active_conn_limit'] = active_connections

        return alert_policy_dict

    def create_alert_policy(self, token=None, region=None, alertpolicy_name=None, alert_org=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, auto_delete=True):
        msg = self._build(alertpolicy_name=alertpolicy_name, alert_org=alert_org, severity=severity, cpu_utilization=cpu_utilization, mem_utilization=mem_utilization, disk_utilization=disk_utilization, active_connections=active_connections, trigger_time=trigger_time, labels_vars=labels_vars, annotations_vars=annotations_vars, description=description, use_defaults=use_defaults, auto_delete=auto_delete)
        msg_dict = {'alertpolicy': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(alertpolicy_name=msg['key']['name'], alert_org=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'alertpolicy': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_show = self._build(alertpolicy_name=msg['key']['name'], alert_org=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'alertpolicy': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, use_defaults=use_defaults, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def show_alert_policy(self, token=None, region=None, alertpolicy_name=None, alert_org=None, json_data=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(alertpolicy_name=alertpolicy_name, alert_org=alert_org, use_defaults=use_defaults)
        msg_dict = {'alertpolicy': msg}

        return self.show(url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def delete_alert_policy(self, token=None, region=None, alertpolicy_name=None, alert_org=None, json_data=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, auto_delete=True):
        msg = self._build(token=token, region=region, alertpolicy_name=alertpolicy_name, alert_org=alert_org, severity=severity, cpu_utilization=cpu_utilization, mem_utilization=mem_utilization, disk_utilization=disk_utilization, active_connections=active_connections, trigger_time=trigger_time, labels_vars=labels_vars, annotations_vars=annotations_vars, description=description, use_defaults=use_defaults, auto_delete=auto_delete)
        msg_dict = {'alertpolicy': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_alert_policy(self, token=None, region=None, alertpolicy_name=None, alert_org=None, json_data=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(alertpolicy_name=alertpolicy_name, alert_org=alert_org, severity=severity, cpu_utilization=cpu_utilization, mem_utilization=mem_utilization, disk_utilization=disk_utilization, active_connections=active_connections, trigger_time=trigger_time, labels_vars=labels_vars, annotations_vars=annotations_vars, description=description, use_defaults=use_defaults, auto_delete=auto_delete)

        msg_dict = {'alertpolicy': msg}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(alertpolicy_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'alertpolicy': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)
