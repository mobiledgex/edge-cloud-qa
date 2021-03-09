import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation
from mex_master_controller.ClusterInstance import ClusterInstance

logger = logging.getLogger('mex_app rest')


class RequestAppInstLatency(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        self.request_url = '/auth/ctrl/RequestAppInstLatency'

    def _build(self, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, use_defaults=True, include_fields=False):
        if app_name == 'default':
            app_name = shared_variables.app_name_default
        if developer_org_name == 'default':
            developer_org_name = shared_variables.developer_name_default
        if app_version == 'default':
            app_version = shared_variables.app_version_default
        if operator_org_name == 'default':
            operator_org_name = shared_variables.operator_name_default
        if cloudlet_name == 'default' and operator_org_name != 'developer':  # special case for platos where they use operator=developer and cloudlet=default
            cloudlet_name = shared_variables.cloudlet_name_default

        if use_defaults:
            if not app_name: app_name = shared_variables.app_name_default
            if not developer_org_name: developer_org_name = shared_variables.developer_name_default
            if not cluster_instance_name: cluster_instance_name = shared_variables.cluster_name_default
            if not cluster_instance_developer_org_name: 
                if cluster_instance_name.startswith('autocluster'):
                    cluster_instance_developer_org_name = 'MobiledgeX'
                else:
                    cluster_instance_developer_org_name = developer_org_name
            if not app_version: app_version = shared_variables.app_version_default
            if not cloudlet_name: cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_org_name: operator_org_name = shared_variables.operator_name_default

        if cluster_instance_name == 'default':
            cluster_instance_name = shared_variables.cluster_name_default

        if operator_org_name: shared_variables.operator_name_default = operator_org_name
        if cloudlet_name: shared_variables.cloudlet_name_default = cloudlet_name

        appinst_dict = {}
        appinst_key_dict = {}
        app_key_dict = {}
        cloudlet_key_dict = {}
        clusterinst_key_dict = {}
        cluster_key_dict = {}
        loc_dict = None
        configs_dict = {}

        if app_name:
            app_key_dict['name'] = app_name
        if app_version:
            app_key_dict['version'] = app_version
        if developer_org_name is not None:
            app_key_dict['organization'] = developer_org_name

        if cluster_instance_name is not None:
            cluster_key_dict['name'] = cluster_instance_name
        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name

        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_key_dict
        if cluster_key_dict:
            clusterinst_key_dict['cluster_key'] = cluster_key_dict
        if cluster_instance_developer_org_name is not None:
            clusterinst_key_dict['organization'] = cluster_instance_developer_org_name

        if app_key_dict:
            appinst_key_dict['app_key'] = app_key_dict
        if clusterinst_key_dict:
            appinst_key_dict['cluster_inst_key'] = clusterinst_key_dict

        if appinst_key_dict:
            appinst_dict['key'] = appinst_key_dict
       
        return appinst_dict

    def request_appinst_latency(self, token=None, region=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, use_defaults=use_defaults)
        msg_dict = {'appinstlatency': msg}

        return self.show(token=token, url=self.request_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]
