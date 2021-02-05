import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation
from mex_master_controller.ClusterInstance import ClusterInstance

logger = logging.getLogger('mex_app rest')


class AppInstance(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        self.create_url = '/auth/ctrl/CreateAppInst'
        self.delete_url = '/auth/ctrl/DeleteAppInst'
        self.show_url = '/auth/ctrl/ShowAppInst'
        self.update_url = '/auth/ctrl/UpdateAppInst'
        self.refresh_url = '/auth/ctrl/RefreshAppInst'
        self.metrics_client_url = '/auth/metrics/client'
        self.metrics_app_url = '/auth/metrics/app'
        self.show_appinst_client_url = '/auth/ctrl/ShowAppInstClient'
        self.root_url = root_url

    def _build(self, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, shared_volume_size=None, privacy_policy=None, crm_override=None, powerstate=None, configs_kind=None, configs_config=None, use_defaults=True, include_fields=False):
 
        _fields_list = []
        _power_state_field_number = '31'
        _configs_field_number = '27'

        if app_name == 'default':
            app_name = shared_variables.app_name_default
        if developer_org_name == 'default':
            developer_org_name = shared_variables.developer_name_default
        if app_version == 'default':
            app_version = shared_variables.app_version_default
        if operator_org_name == 'default':
            operator_org_name = shared_variables.operator_name_default
        if cloudlet_name == 'default' and operator_org_name != 'developer':  # special case for samsung where they use operator=developer and cloudlet=default
            cloudlet_name = shared_variables.cloudlet_name_default

        if use_defaults:
            if not app_name: app_name = shared_variables.app_name_default
            #if not cluster_instance_developer_name: self.developer_name = shared_variables.developer_name_default
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

        if autocluster_ip_access == 'IpAccessUnknown':
            autocluster_ip_access = 0
        elif autocluster_ip_access == 'IpAccessDedicated':
            autocluster_ip_access = 1
        elif autocluster_ip_access == 'IpAccessDedicatedOrShared':
            autocluster_ip_access = 2
        elif autocluster_ip_access == 'IpAccessShared':
            autocluster_ip_access = 3
        
        if powerstate is not None:
            if powerstate == 'PowerOn':
                power_state = 3
            elif powerstate == 'PowerOff':
                power_state = 6
            else:
                power_state = 9

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
        if privacy_policy is not None:
            appinst_dict['privacy_policy'] = privacy_policy
        if shared_volume_size is not None:
            appinst_dict['shared_volume_size'] = int(shared_volume_size) 
        if powerstate is not None:
            appinst_dict['power_state'] = power_state
            _fields_list.append(_power_state_field_number)

        if configs_kind:
            configs_dict['kind'] = configs_kind
        if configs_config:
            configs_dict['config'] = configs_config
        if configs_dict:
            appinst_dict['configs'] = [configs_dict]
            _fields_list.append(_configs_field_number)
            
        if crm_override:
            if str(crm_override).lower() == "ignorecrm":
                crm_override = 2
            elif str(crm_override).lower() == "IgnoreCrmAndTransientState":
                crm_override = 4
            appinst_dict['crm_override'] = crm_override  # ignore errors from CRM

        if include_fields and _fields_list:
            appinst_dict['fields'] = []
            for field in _fields_list:
                appinst_dict['fields'].append(field) 
            
        return appinst_dict

    def _build_metrics(self, type_dict=None, method=None, cell_id=None, selector=None, last=None, start_time=None, end_time=None, use_defaults=True):
        metric_dict = {}

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
        if cell_id is not None:
            metric_dict['cellid'] = int(cell_id)

        return metric_dict

    def create_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, shared_volume_size=None, privacy_policy=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True, stream=True, stream_timeout=600):
        msg = self._build(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, shared_volume_size=shared_volume_size, privacy_policy=privacy_policy, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'appinst': msg}

        thread_name = None
        if 'key' in msg and 'app_key' in msg['key']:
            thread_name = msg['key']['app_key']['name']

        msg_dict_delete = None
        if auto_delete and 'key' in msg:
            if msg['key']['cluster_inst_key']['cluster_key']['name'].startswith('autocluster'): 
                msg['key']['cluster_inst_key']['cluster_key']['name'] = msg['key']['cluster_inst_key']['cluster_key']['name'].lower()
                clusterinst = ClusterInstance(root_url=self.root_url)
                cluster_delete_url = clusterinst.delete_url
                cluster_delete_msg = {'clusterinst': clusterinst._build(cluster_name='namenotset', cloudlet_name=msg['key']['cluster_inst_key']['cloudlet_key']['name'], operator_org_name=msg['key']['cluster_inst_key']['cloudlet_key']['organization'], developer_org_name=msg['key']['cluster_inst_key']['organization'], use_defaults=False)}
                    
            msg_delete = self._build(app_name=msg['key']['app_key']['name'], developer_org_name=msg['key']['app_key']['organization'], app_version=msg['key']['app_key']['version'], cluster_instance_name=msg['key']['cluster_inst_key']['cluster_key']['name'], cloudlet_name=msg['key']['cluster_inst_key']['cloudlet_key']['name'], operator_org_name=msg['key']['cluster_inst_key']['cloudlet_key']['organization'], cluster_instance_developer_org_name=msg['key']['cluster_inst_key']['organization'], use_defaults=False)
            msg_dict_delete = {'appinst': msg_delete}
 
        msg_dict_show = None
        if 'key' in msg:
            if msg['key']['cluster_inst_key']['cluster_key']['name'].startswith('autocluster'): msg['key']['cluster_inst_key']['cluster_key']['name'] = msg['key']['cluster_inst_key']['cluster_key']['name'].lower()
            msg_show = self._build(app_name=msg['key']['app_key']['name'], developer_org_name=msg['key']['app_key']['organization'], app_version=msg['key']['app_key']['version'], cluster_instance_name=msg['key']['cluster_inst_key']['cluster_key']['name'], cloudlet_name=msg['key']['cluster_inst_key']['cloudlet_key']['name'], operator_org_name=msg['key']['cluster_inst_key']['cloudlet_key']['organization'], cluster_instance_developer_org_name=msg['key']['cluster_inst_key']['organization'], use_defaults=False)
            msg_dict_show = {'appinst': msg_show}
        
        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, delete_autocluster_url=cluster_delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, delete_autocluster_msg=cluster_delete_msg, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)[0]
        #return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)[0]


    def create_app_instance_stream(self):
        return self.get_create_stream_output()

    def delete_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False, stream=True, stream_timeout=600):
        msg = self._build(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'appinst': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, stream=stream, stream_timeout=stream_timeout)

    def update_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, shared_volume_size=None, privacy_policy=None, crm_override=None, powerstate=None, configs_kind=None, configs_config=None, json_data=None, use_defaults=True, use_thread=False, stream=True, stream_timeout=600):
        msg = self._build(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, shared_volume_size=shared_volume_size, privacy_policy=privacy_policy, crm_override=crm_override, powerstate=powerstate, configs_kind=configs_kind, configs_config=configs_config, use_defaults=use_defaults, include_fields=True)
        msg_dict = {'appinst': msg}
 
        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(app_name=msg['key']['app_key']['name'], developer_org_name=msg['key']['app_key']['organization'], app_version=msg['key']['app_key']['version'], cluster_instance_name=msg['key']['cluster_inst_key']['cluster_key']['name'], cloudlet_name=msg['key']['cluster_inst_key']['cloudlet_key']['name'], operator_org_name=msg['key']['cluster_inst_key']['cloudlet_key']['organization'], cluster_instance_developer_org_name=msg['key']['cluster_inst_key']['organization'], use_defaults=False)
            msg_dict_show = {'appinst': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show, stream=stream, stream_timeout=stream_timeout)[0] 

    def refresh_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, shared_volume_size=None, privacy_policy=None, crm_override=None, powerstate=None, configs_kind=None, configs_config=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, shared_volume_size=shared_volume_size, privacy_policy=privacy_policy, crm_override=crm_override, powerstate=powerstate, configs_kind=configs_kind, configs_config=configs_config, use_defaults=use_defaults, include_fields=True)
        msg_dict = {'appinst': msg}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(app_name=msg['key']['app_key']['name'], developer_org_name=msg['key']['app_key']['organization'], app_version=msg['key']['app_key']['version'], cluster_instance_name=msg['key']['cluster_inst_key']['cluster_key']['name'], cloudlet_name=msg['key']['cluster_inst_key']['cloudlet_key']['name'], operator_org_name=msg['key']['cluster_inst_key']['cloudlet_key']['organization'], cluster_instance_developer_org_name=msg['key']['cluster_inst_key']['organization'], use_defaults=False)
            msg_dict_show = {'appinst': msg_show}

        return self.update(token=token, url=self.refresh_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def show_app_instance(self, token=None, region=None, appinst_id=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False, stream=True, stream_timeout=600):
        msg = self._build(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'appinst': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, stream=stream, stream_timeout=stream_timeout)
    
    def get_api_metrics(self, method, token=None, region=None, app_name=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, app_version=None, selector=None, last=None, start_time=None, end_time=None, cell_id=None, json_data=None, use_defaults=True, use_thread=False):
        app_inst = self._build(app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        app_inst_metric = app_inst
        if 'key' in app_inst:
            app_inst_metric['appinst'] = app_inst['key']
            del app_inst_metric['key']

        msg_dict = self._build_metrics(type_dict=app_inst_metric, method=method, cell_id=cell_id, selector='api', last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.metrics_client_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def get_app_metrics(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, operator_org_name=None, cloudlet_name=None, selector=None, last=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        app_inst = self._build(app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cluster_instance_name=cluster_instance_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=False)
        app_inst_metric = app_inst
        app_inst_metric['appinst'] = app_inst['key']
        del app_inst_metric['key']

        msg_dict = self._build_metrics(type_dict=app_inst_metric, selector=selector, last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.metrics_app_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def show_app_instance_client_metrics(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, operator_org_name=None, cloudlet_name=None, cluster_instance_developer_name=None, uuid=None, json_data=None, use_defaults=True, use_thread=False):
        app_inst = self._build(app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cluster_instance_name=cluster_instance_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=True)
        app_inst_key = {'app_inst_key': app_inst['key']}
        app_inst_metric = {'appinstclientkey': app_inst_key}
        

        return self.show(token=token, url=self.show_appinst_client_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=app_inst_metric, stream=True, stream_timeout=5)

    def get_show_app_instance_client_metrics(self):
        return self.get_stream_output()
