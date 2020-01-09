import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_app rest')


class AppInstance(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        self.create_url = '/auth/ctrl/CreateAppInst'
        self.delete_url = '/auth/ctrl/DeleteAppInst'
        self.show_url = '/auth/ctrl/ShowAppInst'
        self.update_url = '/auth/ctrl/UpdateAppInst'
        self.metrics_client_url = '/auth/metrics/client'

    def _build(self, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, cluster_instance_name=None, cluster_instance_developer_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, use_defaults=True):
        
        if app_name == 'default':
            app_name = shared_variables.app_name_default
        if developer_name == 'default':
            developer_name = shared_variables.developer_name_default
        if app_version == 'default':
            app_version = shared_variables.app_version_default
        if operator_name == 'default':
            operator_name = shared_variables.operator_name_default
        if cloudlet_name == 'default' and operator_name != 'developer':  # special case for samsung where they use operator=developer and cloudlet=default
            cloudlet_name = shared_variables.cloudlet_name_default

        if use_defaults:
            if not app_name: app_name = shared_variables.app_name_default
            #if not cluster_instance_developer_name: self.developer_name = shared_variables.developer_name_default
            if not developer_name: developer_name = shared_variables.developer_name_default
            if not cluster_instance_name: cluster_instance_name = shared_variables.cluster_name_default
            if not cluster_instance_developer_name: cluster_instance_developer_name = developer_name
            if not app_version: app_version = shared_variables.app_version_default
            if not cloudlet_name: cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_name: operator_name = shared_variables.operator_name_default


        if cluster_instance_name == 'default':
            cluster_instance_name = shared_variables.cluster_name_default

        if autocluster_ip_access == 'IpAccessUnknown':
            autocluster_ip_access = 0
        elif autocluster_ip_access == 'IpAccessDedicated':
            autocluster_ip_access = 1
        elif autocluster_ip_access == 'IpAccessDedicatedOrShared':
            autocluster_ip_access = 2
        elif autocluster_ip_access == 'IpAccessShared':
            autocluster_ip_access = 3

        shared_variables.operator_name_default = operator_name

        appinst_dict = {}
        appinst_key_dict = {}
        app_key_dict = {}
        cloudlet_key_dict = {}
        clusterinst_key_dict = {}
        cluster_key_dict = {}
        loc_dict = None

        if app_name:
            app_key_dict['name'] = app_name
        if app_version:
            app_key_dict['version'] = app_version
        if developer_name is not None:
            app_key_dict['developer_key'] = {'name': developer_name}

        if cluster_instance_name is not None:
            cluster_key_dict['name'] = cluster_instance_name
        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
        if operator_name is not None:
            cloudlet_key_dict['operator_key'] = {'name': operator_name}
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_key_dict
        if cluster_key_dict:
            clusterinst_key_dict['cluster_key'] = cluster_key_dict
        if cluster_instance_developer_name is not None:
            clusterinst_key_dict['developer'] = cluster_instance_developer_name
        if latitude is not None:
            loc_dict['latitude'] = float(latitude)
        if longitude is not None:
            loc_dict['longitude'] = float(longitude)
        if loc_dict is not None:
            appinst_dict['cloudlet_loc'] = loc_dict

        if app_key_dict:
            appinst_key_dict['app_key'] = app_key_dict
        if clusterinst_key_dict:
            appinst_key_dict['cluster_inst_key'] = clusterinst_key_dict

        if appinst_key_dict:
            appinst_dict['key'] = appinst_key_dict
        
        if uri is not None:
            appinst_dict['uri'] = uri
        if flavor_name is not None:
            appinst_dict['flavor'] = {'name': flavor_name}
        if autocluster_ip_access is not None:
            appinst_dict['auto_cluster_ip_access'] = autocluster_ip_access 

        if crm_override:
            appinst_dict['crm_override'] = 1  # ignore errors from CRM
            
        return appinst_dict

    def _build_metrics(self, type_dict=None, method=None, cellid=None, selector=None, last=None, start_time=None, end_time=None, use_defaults=True):
        metric_dict = {}
        print('*WARN*', cellid)
        if type_dict is not None:
            metric_dict.update(type_dict)
        if selector is not None:
            metric_dict['selector'] = selector
        if last is not None:
            try:
                metric_dict['last'] = int(last)
            except:
                metric_dict['last'] = last
        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time
        if method is not None:
            metric_dict['method'] = method
        if cellid is not None:
            metric_dict['cellid'] = int(cellid)

        return metric_dict


    def create_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, cluster_instance_name=None, cluster_instance_developer_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_name=operator_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_name=cluster_instance_developer_name, developer_name=developer_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'appinst': msg}

        thread_name = None
        if 'key' in msg and 'app_key' in msg['key']:
            thread_name = msg['key']['app_key']['name']

        msg_dict_delete = None
        if auto_delete and 'key' in msg:
            msg_delete = self._build(app_name=msg['key']['app_key']['name'], developer_name=msg['key']['app_key']['developer_key']['name'], app_version=msg['key']['app_key']['version'], cluster_instance_name=msg['key']['cluster_inst_key']['cluster_key']['name'], cloudlet_name=msg['key']['cluster_inst_key']['cloudlet_key']['name'], operator_name=msg['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name'], cluster_instance_developer_name=msg['key']['cluster_inst_key']['developer'], use_defaults=False)
            msg_dict_delete = {'appinst': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(app_name=msg['key']['app_key']['name'], developer_name=msg['key']['app_key']['developer_key']['name'], app_version=msg['key']['app_key']['version'], cluster_instance_name=msg['key']['cluster_inst_key']['cluster_key']['name'], cloudlet_name=msg['key']['cluster_inst_key']['cloudlet_key']['name'], operator_name=msg['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name'], cluster_instance_developer_name=msg['key']['cluster_inst_key']['developer'], use_defaults=False)
            msg_dict_show = {'appinst': msg_show}
        
        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name)

    def delete_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, cluster_instance_name=None, cluster_instance_developer_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_name=operator_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_name=cluster_instance_developer_name, developer_name=developer_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'appinst': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_app_instance(self, token=None, region=None, appinst_id=None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, cluster_instance_name=None, cluster_instance_developer_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_name=operator_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_name=cluster_instance_developer_name, developer_name=developer_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'appinst': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)

    
    def get_find_cloudlet_api_metrics(self, token=None, region=None, app_name=None, developer_name=None, app_version=None, selector=None, last=None, start_time=None, end_time=None, cellid=None, json_data=None, use_defaults=True, use_thread=False):
        print('*WARN*', 'c',cellid)
        app_inst = self._build(app_name=app_name, developer_name=developer_name, app_version=app_version, use_defaults=False)
        app_inst_metric = app_inst
        app_inst_metric['appinst'] = app_inst['key']
        del app_inst_metric['key']



        msg_dict = self._build_metrics(type_dict=app_inst_metric, method='FindCloudlet', cellid=cellid, selector='api', last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.metrics_client_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
