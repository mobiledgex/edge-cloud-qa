import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex alertreceiver rest')


class AlertReceiver(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/alertreceiver/create'
        self.delete_url = '/auth/alertreceiver/delete'
        self.show_url = '/auth/alertreceiver/show'

    def _build(self, receiver_name=None, type=None, severity=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, use_defaults=True):

        if use_defaults:
            if receiver_name is None: receiver_name = shared_variables.alert_receiver_name_default
            if type is None: type = shared_variables.alert_receiver_type_default
            if severity is None: severity = shared_variables.alert_receiver_severity_default
            #if app_name is None: app_name = shared_variables.app_name_default
            #if developer_org_name is None: developer_org_name = shared_variables.developer_name_default
            #if app_version is None: app_version = shared_variables.app_version_default
        
        #{"name":"DevOrgReceiver1","type":"email","severity":"error","appinst":{"app_key":{"organization":"DevOrg","name":"Face Detection Demo","version":"1.0"},"clusterinstkey":{"clusterkey":{"name":"AppCluster"},"cloudlet_key":{"organization":"mexdev","name":"localtest"},"organization":"DevOrg"}}}
        receiver_dict = {}
        app_key_dict = {}
        appinst_key_dict = {}
        cloudlet_key_dict = {}
        
        if receiver_name is not None:
            receiver_dict['name'] = receiver_name
        if type is not None:
            receiver_dict['type'] = type
        if severity is not None:
            receiver_dict['severity'] = severity

        if app_name:
            app_key_dict['name'] = app_name
        if app_version:
            app_key_dict['version'] = app_version
        if developer_org_name is not None:
            app_key_dict['organization'] = developer_org_name

        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name

        if app_key_dict:
           appinst_key_dict['app_key'] = app_key_dict

        if cloudlet_key_dict:
            receiver_dict['cloudlet'] = cloudlet_key_dict
        if appinst_key_dict:
            receiver_dict['appinst'] = appinst_key_dict

        return receiver_dict

    def create_alert_receiver(self, token=None, region=None, receiver_name=None, type=None, severity=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(receiver_name=receiver_name, type=type, severity=severity, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_delete = None
        if auto_delete and 'name' in msg:
            msg_delete = self._build(receiver_name=msg['name'], use_defaults=False)
            msg_dict_delete = msg_delete

        msg_dict_show = None
        if 'name' in msg:
            msg_show = self._build(receiver_name=msg['name'], use_defaults=False)
            msg_dict_show = msg_show

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)[0]

    def delete_alert_receiver(self, token=None, region=None, receiver_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(receiver_name=receiver_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_alert_receiver(self, token=None, region=None, receiver_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(receiver_name=receiver_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
