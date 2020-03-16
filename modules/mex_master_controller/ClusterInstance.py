import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_app rest')


class ClusterInstance(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        self.create_url = '/auth/ctrl/CreateClusterInst'
        self.delete_url = '/auth/ctrl/DeleteClusterInst'
        self.show_url = '/auth/ctrl/ShowClusterInst'
        self.update_url = '/auth/ctrl/UpdateClusterInst'
        #self.metrics_client_url = '/auth/metrics/client'
        #self.metrics_app_url = '/auth/metrics/app'
        #self.show_appinst_client_url = '/auth/ctrl/ShowAppInstClient'

    def _build(self, cluster_name=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, number_masters=None, number_nodes=None, crm_override=None, deployment=None, shared_volume_size=None, privacy_policy=None, reservable=None, use_defaults=True):
        liveness = 5
        
        if cluster_name == 'default':
            cluster_name = shared_variables.cluster_name_default
            
        if use_defaults:
            if cluster_name is None: cluster_name = shared_variables.cluster_name_default
            if cloudlet_name is None: cloudlet_name = shared_variables.cloudlet_name_default
            if operator_org_name is None: operator_org_name = shared_variables.operator_name_default
            if flavor_name is None: flavor_name = shared_variables.flavor_name_default
            if developer_org_name is None: developer_name = shared_variables.developer_name_default
            if liveness is None: liveness = 1
            if deployment == 'kubernetes':
                if number_masters is None: number_masters = 1
                if number_nodes is None: number_nodes = 1

            shared_variables.cluster_name_default = cluster_name
            shared_variables.cloudlet_name_default = cloudlet_name
            shared_variables.operator_name_default = operator_org_name
            shared_variables.flavor_name_default = flavor_name

        if liveness == 'LivenessStatic':
            liveness = 1
        elif liveness == 'LivenessDynamic':
            liveness = 2

        if ip_access == 'IpAccessUnknown':
            ip_access = 0
        elif ip_access == 'IpAccessDedicated':
            ip_access = 1
        elif ip_access == 'IpAccessDedicatedOrShared':
            ip_access = 2
        elif ip_access == 'IpAccessShared':
            ip_access = 3

        clusterinst_dict = {}
        clusterinst_key_dict = {}
        operator_dict = {}
        cloudlet_key_dict = {}
        #cluster_key_dict = {}

        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name
        if cloudlet_name:
            cloudlet_key_dict['name'] = cloudlet_name
            
        if cluster_name:
            clusterinst_key_dict['cluster_key'] = {'name': cluster_name}
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_key_dict
        if developer_name is not None:
            clusterinst_key_dict['organization'] = developer_org_name

        if clusterinst_key_dict:
            clusterinst_dict['key'] = clusterinst_key_dict
            
        if flavor_name is not None:
            clusterinst_dict['flavor'] = {'name': flavor_name}

        if liveness is not None:
            clusterinst_dict['liveness'] = liveness

        if ip_access is not None:
            clusterinst_dict['ip_access'] = ip_access

        if number_masters is not None:
            clusterinst_dict['num_masters'] = int(number_masters)

        if number_nodes is not None:
            clusterinst_dict['num_nodes'] = int(number_nodes)

        if shared_volume_size is not None:
            clusterinst_dict['shared_volume_size'] = int(shared_volume_size)

        if privacy_policy is not None:
            clusterinst_dict['privacy_policy'] = privacy_policy

        if reservable is not None:
            clusterinst_dict['reservable'] = reservable

        if crm_override:
            if crm_override.lower() == "ignorecrm":
                crm_override = 2
            elif crm_override.lower() == "ignorecrmandtransientstate":
                crm_override = 4
            clusterinst_dict['crm_override'] = crm_override  # ignore errors from CRM

        if deployment is not None:
            clusterinst_dict['deployment'] = deployment
            
        print("ClusterInst Dict", clusterinst_dict)    

        return clusterinst_dict

    def create_cluster_instance(self, token=None, region=None, cluster_name=None, operator_name=None, cloudlet_name=None, developer_name=None, flavor_name=None, liveness=None, ip_access=None, deployment=None, number_masters=None, number_nodes=None, shared_volume_size=None, privacy_policy=None, reservable=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cluster_name=cluster_name, operator_name=operator_name, cloudlet_name=cloudlet_name, developer_name=developer_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access, deployment=deployment, number_masters=number_masters, number_nodes=number_nodes, shared_volume_size=shared_volume_size, privacy_policy=privacy_policy, reservable=reservable, use_defaults=use_defaults)
        msg_dict = {'clusterinst': msg}

        thread_name = None
        if 'key' in msg and 'cluster_key' in msg['key']:
            thread_name = msg['key']['cluster_key']['name']

        msg_dict_delete = None
        if auto_delete and 'key' in msg:
            msg_delete = self._build(cluster_name=msg['key']['cluster_key']['name'], operator_org_name=msg['key']['cluster_key']['cloudlet_key']['organization'], cloudlet_name=msg['key']['cluster_key']['cloudlet_key']['name'], developer_org_name=msg['key']['cluster_key']['organization'], use_defaults=False)
            msg_dict_delete = {'clusterinst': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_delete = self._build(cluster_name=msg['key']['cluster_key']['name'], operator_org_name=msg['key']['cluster_key']['cloudlet_key']['organization'], cloudlet_name=msg['key']['cluster_key']['cloudlet_key']['name'], developer_org_name=msg['key']['cluster_key']['organization'], use_defaults=False)
            msg_dict_show = {'clusterinst': msg_show}
        
        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name)


    def delete_cluster_instance(self, token=None, region=None, cluster_name=None, operator_name=None, cloudlet_name=None, developer_name=None, flavor_name=None, liveness=None, ip_access=None, deployment=None, number_masters=None, number_nodes=None, shared_volume_size=None, privacy_policy=None, reservable=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cluster_name=cluster_name, operator_name=operator_name, cloudlet_name=cloudlet_name, developer_name=developer_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access, deployment=deployment, number_masters=number_masters, number_nodes=number_nodes, shared_volume_size=shared_volume_size, privacy_policy=privacy_policy, reservable=reservable, use_defaults=use_defaults)
        msg_dict = {'clusterinst': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_cluster_instance(self, token=None, region=None, cluster_name=None, cloudlet_name=None, json_data=None, use_thread=False, use_defaults=True):
        msg = self._build(cluster_name=cluster_name, cloudlet_name=cloudlet_name, use_defaults=use_defaults)
        msg_dict = {'clusterinst': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

                                     
