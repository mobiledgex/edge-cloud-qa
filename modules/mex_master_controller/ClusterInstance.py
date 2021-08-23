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
        self.metrics_cluster_url = '/auth/metrics/cluster'
        self.delete_idle_url = '/auth/ctrl/DeleteIdleReservableClusterInsts'

    def _build(self, cluster_name=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, number_masters=None, number_nodes=None, crm_override=None, deployment=None, shared_volume_size=None, privacy_policy=None, reservable=None, reservation_ended_at_seconds=None, reservation_ended_at_nanoseconds=None, autoscale_policy_name=None, use_defaults=True, include_fields=False, auto_delete=True):

        _fields_list = []
        _number_nodes_field_number = "14"
        _autoscale_policy_field_number = "18"
        _flavor_name_field_number = "3.1"
        _reservable_field_number = "21"

        liveness = None

        if cluster_name == 'default':
            cluster_name = shared_variables.cluster_name_default
        if cloudlet_name == 'default':
            cloudlet_name = shared_variables.cloudlet_name_default
        if operator_org_name == 'default':
            operator_org_name = shared_variables.operator_name_default
        if developer_org_name == 'default':
            developer_org_name = shared_variables.developer_name_default

        if use_defaults:
            if cluster_name is None:
                cluster_name = shared_variables.cluster_name_default
            if cloudlet_name is None:
                cloudlet_name = shared_variables.cloudlet_name_default
            if operator_org_name is None:
                operator_org_name = shared_variables.operator_name_default
            if flavor_name is None:
                flavor_name = shared_variables.flavor_name_default
            if developer_org_name is None:
                developer_org_name = shared_variables.developer_name_default
            # if liveness is None: liveness = 1
            if deployment == 'kubernetes':
                if number_masters is None:
                    number_masters = 1
                if number_nodes is None:
                    number_nodes = 1

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
        cloudlet_key_dict = {}

        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name
        if cloudlet_name:
            cloudlet_key_dict['name'] = cloudlet_name

        if cluster_name:
            clusterinst_key_dict['cluster_key'] = {'name': cluster_name}
        if cloudlet_key_dict:
            clusterinst_key_dict['cloudlet_key'] = cloudlet_key_dict
        if developer_org_name is not None:
            clusterinst_key_dict['organization'] = developer_org_name

        if clusterinst_key_dict:
            clusterinst_dict['key'] = clusterinst_key_dict

        if flavor_name is not None:
            clusterinst_dict['flavor'] = {'name': flavor_name}
            _fields_list.append(_flavor_name_field_number)

        if liveness is not None:
            clusterinst_dict['liveness'] = liveness

        if ip_access is not None:
            clusterinst_dict['ip_access'] = ip_access

        if number_masters is not None:
            clusterinst_dict['num_masters'] = int(number_masters)

        if number_nodes is not None:
            clusterinst_dict['num_nodes'] = int(number_nodes)
            _fields_list.append(_number_nodes_field_number)

        if shared_volume_size is not None:
            clusterinst_dict['shared_volume_size'] = int(shared_volume_size)

        if privacy_policy is not None:
            clusterinst_dict['privacy_policy'] = privacy_policy

        reservation_ended_at_dict = {}
        if reservable is not None:
            clusterinst_dict['reservable'] = reservable
            _fields_list.append(_reservable_field_number)
        if reservation_ended_at_seconds is not None:
            reservation_ended_at_dict['seconds'] = int(reservation_ended_at_seconds)
        if reservation_ended_at_nanoseconds is not None:
            reservation_ended_at_dict['nanos'] = int(reservation_ended_at_nanoseconds)
        if reservation_ended_at_dict:
            clusterinst_dict['reservation_ended_at'] = reservation_ended_at_dict

        if crm_override:
            if str(crm_override).lower() == "ignorecrm":
                crm_override = 2
            elif str(crm_override).lower() == "ignorecrmandtransientstate":
                crm_override = 4
            clusterinst_dict['crm_override'] = crm_override  # ignore errors from CRM

        if deployment is not None:
            clusterinst_dict['deployment'] = deployment

        if autoscale_policy_name is not None:
            if str(autoscale_policy_name) != "Unset":
                clusterinst_dict['auto_scale_policy'] = autoscale_policy_name
            _fields_list.append(_autoscale_policy_field_number)

        if include_fields and _fields_list:
            clusterinst_dict['fields'] = []
            for field in _fields_list:
                clusterinst_dict['fields'].append(field)

        return clusterinst_dict

    def _build_metrics(self, type_dict=None, method=None, cell_id=None, selector=None, last=None, start_time=None, end_time=None, use_defaults=True):
        metric_dict = {}

        if type_dict is not None:
            metric_dict.update(type_dict)
        if selector is not None:
            metric_dict['selector'] = selector
        if last is not None:
            try:
                metric_dict['limit'] = int(last)
            except Exception:
                metric_dict['limit'] = last
        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time
        if method is not None:
            metric_dict['method'] = method
        if cell_id is not None:
            metric_dict['cellid'] = int(cell_id)

        return metric_dict

    def _build_idledelete(self, idle_time=None, use_defaults=True):
        idle_dict = {}

        if idle_time is not None:
            idle_dict['idle_time'] = idle_time

        return idle_dict

    def create_cluster_instance(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, deployment=None, number_masters=None, number_nodes=None, shared_volume_size=None, privacy_policy=None, autoscale_policy_name=None, reservable=None, reservation_ended_at_seconds=None, reservation_ended_at_nanoseconds=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True, stream=True, stream_timeout=600):
        msg = self._build(cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access, deployment=deployment, number_masters=number_masters, number_nodes=number_nodes, shared_volume_size=shared_volume_size, privacy_policy=privacy_policy, autoscale_policy_name=autoscale_policy_name, reservable=reservable, reservation_ended_at_seconds=reservation_ended_at_seconds, reservation_ended_at_nanoseconds=reservation_ended_at_nanoseconds, auto_delete=auto_delete, use_defaults=use_defaults)
        msg_dict = {'clusterinst': msg}

        thread_name = None
        if 'key' in msg and 'cluster_key' in msg['key']:
            thread_name = msg['key']['cluster_key']['name']

        msg_dict_delete = None
        if auto_delete and 'key' in msg:
            msg_delete = self._build(cluster_name=msg['key']['cluster_key']['name'], operator_org_name=msg['key']['cloudlet_key']['organization'], cloudlet_name=msg['key']['cloudlet_key']['name'], developer_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'clusterinst': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(cluster_name=msg['key']['cluster_key']['name'], operator_org_name=msg['key']['cloudlet_key']['organization'], cloudlet_name=msg['key']['cloudlet_key']['name'], developer_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'clusterinst': msg_show}

        create_return = self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)

        if use_thread:
            return create_return
        else:
            return create_return[0]

    def delete_cluster_instance(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, deployment=None, number_masters=None, number_nodes=None, shared_volume_size=None, privacy_policy=None, reservable=None, json_data=None, crm_override=None, use_defaults=True, use_thread=False, stream=True, stream_timeout=600):
        msg = self._build(cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access, deployment=deployment, number_masters=number_masters, number_nodes=number_nodes, shared_volume_size=shared_volume_size, privacy_policy=privacy_policy, reservable=reservable, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'clusterinst': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, stream=True, stream_timeout=600)

    def update_cluster_instance(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, deployment=None, number_masters=None, number_nodes=None, autoscale_policy_name=None, reservation_ended_at_seconds=None, reservation_ended_at_nanoseconds=None, json_data=None, crm_override=None, use_defaults=True, use_thread=False, stream=True, stream_timeout=600):
        if not cluster_name:
            cluster_name = 'default'
        if not operator_org_name:
            operator_org_name = 'default'
        if not cloudlet_name:
            cloudlet_name = 'default'
        if not developer_org_name:
            developer_org_name = 'default'

        msg = self._build(cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access, deployment=deployment, number_masters=number_masters, number_nodes=number_nodes, reservation_ended_at_seconds=reservation_ended_at_seconds, reservation_ended_at_nanoseconds=reservation_ended_at_nanoseconds, crm_override=crm_override, autoscale_policy_name=autoscale_policy_name, use_defaults=False, include_fields=True)
        msg_dict = {'clusterinst': msg}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(cluster_name=msg['key']['cluster_key']['name'], operator_org_name=msg['key']['cloudlet_key']['organization'], cloudlet_name=msg['key']['cloudlet_key']['name'], developer_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'clusterinst': msg_show}
        print('*WARN*', use_defaults, region)

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, show_msg=msg_dict_show, message=msg_dict, stream=True, stream_timeout=600)[0]

    def show_cluster_instance(self, token=None, region=None, cluster_name=None, cloudlet_name=None, developer_org_name=None, json_data=None, use_thread=False, use_defaults=True, stream=True, stream_timeout=600):
        msg = self._build(cluster_name=cluster_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, use_defaults=use_defaults)
        msg_dict = {'clusterinst': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, stream=True, stream_timeout=600)

    def get_cluster_metrics(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, selector=None, last=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        inst = self._build(cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, use_defaults=False)
        inst_metric = inst
        if 'key' in inst:
            inst_metric['clusterinst'] = inst['key']
            del inst_metric['key']

        msg_dict = self._build_metrics(type_dict=inst_metric, selector=selector, last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.metrics_cluster_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def delete_idle_clusters(self, token=None, region=None, idle_time=None, json_data=None, use_defaults=True, use_thread=False):
        inst = self._build_idledelete(idle_time=idle_time, use_defaults=False)

        msg_dict = {'idlereservableclusterinsts': inst}

        return self.delete(token=token, url=self.delete_idle_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, stream=True, stream_timeout=600)
