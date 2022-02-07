import logging

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('__name__')


class Usage(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.app_url = '/auth/usage/app'
        self.cluster_url = '/auth/usage/cluster'
        self.cloudletpool_url = '/auth/usage/cloudletpool'

    def _build_app(self, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, cloudlet_name=None, operator_org_name=None, vm_only=None, start_time=None, end_time=None, use_defaults=True):
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
            metric_dict['appinst'] = {'cluster_inst_key': clusterinstkey_dict}
        if appkey_dict:
            if 'appinst' in metric_dict:
                metric_dict['appinst']['app_key'] = appkey_dict
            else:
                metric_dict['appinst'] = {'app_key': appkey_dict}
        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time
        if vm_only is not None:
            metric_dict['vmonly'] = vm_only

        return metric_dict

    # '{"ClusterInst":{"cloudlet_key":{"name":"q","organization":"GDDT"},"cluster_key":{"name":"a"},"organization":"x"},"EndTime":"2021-06-14T20:49:56Z","Region":"US","StartTime":"2021-06-13T20:39:56Z"}'
    def _build_cluster(self, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, cloudlet_name=None, operator_org_name=None, vm_only=None, start_time=None, end_time=None, use_defaults=True):
        metric_dict = {}
        clusterkey_dict = {}
        clusterinstkey_dict = {}
        cloudletkey_dict = {}

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
        if developer_org_name is not None:
            clusterinstkey_dict['organization'] = developer_org_name

        if clusterinstkey_dict:
            metric_dict['clusterinst'] = clusterinstkey_dict
        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time

        if 'cloudlet_key' in metric_dict or 'cluster_key' in metric_dict or 'organization' in metric_dict:
            metric_dict['clusterinst'] = metric_dict

        return metric_dict

    # {"CloudletPool":{"name":"x","organization":"y"},"EndTime":"2006-01-02T15:04:05Z","Region":"US","StartTime":"2006-01-02T15:04:05Z"}
    def _build_cloudletpool(self, cloudlet_pool_name=None, operator_org_name=None, show_vm_apps_only=None, start_time=None, end_time=None, use_defaults=True):
        metric_dict = {}
        pool_dict = {}

        if cloudlet_pool_name is not None:
            pool_dict['name'] = cloudlet_pool_name
        if operator_org_name is not None:
            pool_dict['organization'] = operator_org_name

        if pool_dict:
            metric_dict['cloudletpool'] = pool_dict
        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time
        if show_vm_apps_only is not None:
            metric_dict['showvmappsonly'] = show_vm_apps_only

        return metric_dict

    def get_app_usage(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, cloudlet_name=None, operator_org_name=None, vm_only=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build_app(app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cluster_instance_name=cluster_instance_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, start_time=start_time, end_time=end_time, vm_only=vm_only, use_defaults=False)
        msg_dict = msg

        return self.show(token=token, url=self.app_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def get_cluster_usage(self, token=None, region=None, developer_org_name=None, cluster_instance_name=None, cloudlet_name=None, operator_org_name=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build_cluster(developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, start_time=start_time, end_time=end_time, use_defaults=False)
        msg_dict = msg

        return self.show(token=token, url=self.cluster_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def get_cloudlet_pool_usage(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, show_vm_apps_only=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build_cloudletpool(cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, start_time=start_time, end_time=end_time, show_vm_apps_only=show_vm_apps_only, use_defaults=False)
        msg_dict = msg

        return self.show(token=token, url=self.cloudletpool_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]
