import logging
import re

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('__name__')


class Usage(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.app_url = '/auth/usage/app'
        self.cluster_url = '/auth/usage/cluster'
        self.cloudletpool_url = '/auth/usage/cloudlet'

    def _build(self, type_dict=None, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, cloudlet_name=None, operator_org_name=None, vm_only=None, start_time=None, end_time=None, use_defaults=True):
        metric_dict = {}
        appkey_dict = {}
        clusterkey_dict = {}
        clusterinstkey_dict = {}
        cloudletkey_dict = {}

        if app_name is not None:
            appkey_dict['name'] = app_name
        if developer_org_name is not None:
            appkey_dict['organization'] = developer_org_name

        if cluster_instance_name is not None:
            clusterkey_dict['name'] = cluster_instance_name

        if cloudlet_name is not None:
            cloudletkey_dict['name'] = cloudlet_name
        if operator_org_name is not None:
            cloudletkey_dict['organization'] = operator_org_name

        if cloudletkey_dict:
            clusterinstkey_dict['cloudlet_key'] = cloudletkey_dict
        if clusterkey_dict:
            clusterinstkey_dict['cluster_key'] = clusterkey_dict
        if clusterinstkey_dict:
            metric_dict['cluster_inst_key'] = clusterinstkey_dict

        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time
        if vm_only is not None:
            metric_dict['vmonly'] = vm_only

        return metric_dict

    def get_app_usage(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, cloudlet_name=None, operator_org_name=None, vm_only=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cluster_instance_name=cluster_instance_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, start_time=start_time, end_time=end_time, use_defaults=False)
        msg_dict = {'appinst': msg}
        print('*WARN*', 'x', msg)
#        if 'name' in msg:
#            #metric_dict['app_key'] = msg['key']
#            #del metric_dict['key']
#            metric_dict['appinst'] = {'app_key': msg['key']}
#        else:
#            metric_dict = msg

#        msg_dict = self._build_metrics(type_dict=metric_dict, selector=selector, last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.app_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]
