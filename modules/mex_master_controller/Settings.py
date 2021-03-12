import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)

class Settings(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.show_url = '/auth/ctrl/ShowSettings'
        self.update_url = '/auth/ctrl/UpdateSettings'
        self.reset_url = '/auth/ctrl/ResetSettings'

    # '{"region":"US","settings":{"fields":["2"],"shepherd_metrics_collection_interval":"5s"}}'
    def _build(self, shepherd_metrics_collection_interval=None, shepherd_alert_evaluation_interval=None, shepherd_health_check_retries=None, shepherd_health_check_interval=None, auto_deploy_interval_sec=None, auto_deploy_offset_sec=None, auto_deploy_max_intervals=None, create_cloudlet_timeout=None, update_cloudlet_timeout=None, create_app_inst_timeout=None, update_app_inst_timeout=None, delete_app_inst_timeout=None, create_cluster_inst_timeout=None, update_cluster_inst_timeout=None, delete_cluster_inst_timeout=None, master_node_flavor=None, load_balancer_max_port_range=None, max_tracked_dme_clients=None, chef_client_interval=None, influx_db_cloudlet_usage_metrics_retention=None, influx_db_metrics_retention=None, cloudlet_maintenance_timeout=None, update_vm_pool_timeout=None, update_trust_policy_timeout=None, dme_api_metrics_collection_interval=None, persistent_connection_metrics_collection_interval=None, cleanup_reservable_auto_cluster_idletime=None, include_fields=False, use_defaults=True):
        _fields_list = []
        _shepherd_metrics_collection_interval_field_number = '2'
        _shepherd_alert_evaluation_interval_field_number = '20'
        _shepherd_health_check_retries_field_number = '3'
        _shepherd_health_check_interval_field_number = '4'
        _auto_deploy_interval_field_number = '5'
        _auto_deploy_offset_field_number = '6'
        _auto_deploy_max_intervals_field_number = '7'
        _create_app_inst_timeout_field_number = '8'
        _update_app_inst_timeout_field_number = '9'
        _delete_app_inst_timeout_field_number = '10'
        _create_cluster_inst_timeout_field_number = '11'
        _update_cluster_inst_timeout_field_number = '12'
        _delete_cluster_inst_timeout_field_number = '13'
        _master_node_flavor_field_number = '14'
        _load_balancer_max_port_range_field_number = '15'
        _max_tracked_dme_clients_field_number = '16'
        _chef_client_interval_field_number = '17'
        _influx_db_metrics_retention_field_number = '18'
        _cloudlet_maintenance_timeout_field_number = '19'
        _update_vm_pool_timeout_field_number = '21'
        _update_trust_policy_timeout_field_number = '22'
        _dme_api_metrics_collection_interval_field_number = '23'
        _persistent_connection_metrics_collection_interval_field_number = '24'
        _cleanup_reservable_auto_cluster_idletime_field_number = '25'
        _influx_db_cloudlet_usage_metrics_retention_field_number = '26'
        _create_cloudlet_timeout_field_number = '27'
        _update_cloudlet_timeout_field_number = '28'

        settings_dict = {}
        
        if shepherd_metrics_collection_interval is not None:
            settings_dict['shepherd_metrics_collection_interval'] = shepherd_metrics_collection_interval
            _fields_list.append(_shepherd_metrics_collection_interval_field_number)
        if shepherd_alert_evaluation_interval is not None:
            settings_dict['shepherd_alert_evaluation_interval'] = shepherd_alert_evaluation_interval
            _fields_list.append(_shepherd_alert_evaluation_interval_field_number)
        if shepherd_health_check_retries is not None:
            try:
                settings_dict['shepherd_health_check_retries'] = int(shepherd_health_check_retries)
            except:
                settings_dict['shepherd_health_check_retries'] = shepherd_health_check_retries
            _fields_list.append(_shepherd_health_check_retries_field_number)
        if shepherd_health_check_interval is not None:
            settings_dict['shepherd_health_check_interval'] = shepherd_health_check_interval
            _fields_list.append(_shepherd_health_check_interval_field_number)

        if auto_deploy_interval_sec is not None:
            try:
                settings_dict['auto_deploy_interval_sec'] = int(auto_deploy_interval_sec)
            except:
                settings_dict['auto_deploy_interval_sec'] = auto_deploy_interval_sec
            _fields_list.append(_auto_deploy_interval_field_number)
        if auto_deploy_offset_sec is not None:
            try:
                settings_dict['auto_deploy_offset_sec'] = int(auto_deploy_offset_sec)
            except:
                settings_dict['auto_deploy_offset_sec'] = auto_deploy_offset_sec
            _fields_list.append(_auto_deploy_offset_field_number)
        if auto_deploy_max_intervals is not None:
            try:
                settings_dict['auto_deploy_max_intervals'] = int(auto_deploy_max_intervals)
            except:
                settings_dict['auto_deploy_max_intervals'] = auto_deploy_max_intervals
            _fields_list.append(_auto_deploy_max_intervals_field_number)

        if create_app_inst_timeout is not None:
            settings_dict['create_app_inst_timeout'] = create_app_inst_timeout
            _fields_list.append(_create_app_inst_timeout_field_number)
        if update_app_inst_timeout is not None:
            settings_dict['update_app_inst_timeout'] = update_app_inst_timeout
            _fields_list.append(_update_app_inst_timeout_field_number)
        if delete_app_inst_timeout is not None:
            settings_dict['delete_app_inst_timeout'] = delete_app_inst_timeout
            _fields_list.append(_delete_app_inst_timeout_field_number)

        if create_cluster_inst_timeout is not None:
            settings_dict['create_cluster_inst_timeout'] = create_cluster_inst_timeout
            _fields_list.append(_create_cluster_inst_timeout_field_number)
        if update_cluster_inst_timeout is not None:
            settings_dict['update_cluster_inst_timeout'] = update_cluster_inst_timeout
            _fields_list.append(_update_cluster_inst_timeout_field_number)
        if delete_cluster_inst_timeout is not None:
            settings_dict['delete_cluster_inst_timeout'] = delete_cluster_inst_timeout
            _fields_list.append(_delete_cluster_inst_timeout_field_number)

        if create_cloudlet_timeout is not None:
            settings_dict['create_cloudlet_timeout'] = create_cloudlet_timeout
            _fields_list.append(_create_cloudlet_timeout_field_number)
        if update_cloudlet_timeout is not None:
            settings_dict['update_cloudlet_timeout'] = update_cloudlet_timeout
            _fields_list.append(_update_cloudlet_timeout_field_number)

        if master_node_flavor is not None:
            settings_dict['master_node_flavor'] = master_node_flavor
            _fields_list.append(_master_node_flavor_field_number)
        if load_balancer_max_port_range is not None:
            try:
                settings_dict['load_balancer_max_port_range'] = int(load_balancer_max_port_range)
            except:
                settings_dict['load_balancer_max_port_range'] = load_balancer_max_port_range
            _fields_list.append(_load_balancer_max_port_range_field_number)
        if max_tracked_dme_clients is not None:
            try:
                settings_dict['max_tracked_dme_clients'] = int(max_tracked_dme_clients)
            except:
                settings_dict['max_tracked_dme_clients'] = max_tracked_dme_clients
            _fields_list.append(_max_tracked_dme_clients_field_number)
        if chef_client_interval is not None:
            settings_dict['chef_client_interval'] = chef_client_interval
            _fields_list.append(_chef_client_interval_field_number)
        if influx_db_metrics_retention is not None:
            settings_dict['influx_db_metrics_retention'] = influx_db_metrics_retention
            _fields_list.append(_influx_db_metrics_retention_field_number)
        if influx_db_cloudlet_usage_metrics_retention is not None:
            print('*WARN*', 'xxxx')
            settings_dict['influx_db_cloudlet_usage_metrics_retention'] = influx_db_cloudlet_usage_metrics_retention 
            _fields_list.append(_influx_db_cloudlet_usage_metrics_retention_field_number)
        if cloudlet_maintenance_timeout is not None:
            settings_dict['cloudlet_maintenance_timeout'] = cloudlet_maintenance_timeout
            _fields_list.append(_cloudlet_maintenance_timeout_field_number)
        if update_vm_pool_timeout is not None:
            settings_dict['update_vm_pool_timeout'] = update_vm_pool_timeout
            _fields_list.append(_update_vm_pool_timeout_field_number)
        if update_trust_policy_timeout is not None:
            settings_dict['update_trust_policy_timeout'] = update_trust_policy_timeout
            _fields_list.append(_update_trust_policy_timeout_field_number)

        if dme_api_metrics_collection_interval is not None:
            settings_dict['dme_api_metrics_collection_interval'] = dme_api_metrics_collection_interval 
            _fields_list.append(_dme_api_metrics_collection_interval_field_number)

        if persistent_connection_metrics_collection_interval is not None:
            settings_dict['persistent_connection_metrics_collection_interval'] = persistent_connection_metrics_collection_interval
            _fields_list.append(_persistent_connection_metrics_collection_interval_field_number)
      
        if cleanup_reservable_auto_cluster_idletime is not None:
            settings_dict['cleanup_reservable_auto_cluster_idletime'] = cleanup_reservable_auto_cluster_idletime 
            _fields_list.append(_cleanup_reservable_auto_cluster_idletime_field_number)

        if include_fields and _fields_list:
            settings_dict['fields'] = []
            for field in _fields_list:
                settings_dict['fields'].append(field)

        return settings_dict

    def show_settings(self, token=None, region=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg_dict = {}
        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def reset_settings(self, token=None, region=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg_dict = {}
        return self.show(token=token, url=self.reset_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def update_settings(self, token=None, region=None, shepherd_metrics_collection_interval=None, shepherd_alert_evaluation_interval=None, shepherd_health_check_retries=None, shepherd_health_check_interval=None, auto_deploy_interval_sec=None, auto_deploy_offset_sec=None, auto_deploy_max_intervals=None, create_cloudlet_timeout=None, update_cloudlet_timeout=None, create_app_inst_timeout=None, update_app_inst_timeout=None, delete_app_inst_timeout=None, create_cluster_inst_timeout=None, update_cluster_inst_timeout=None, delete_cluster_inst_timeout=None, master_node_flavor=None, load_balancer_max_port_range=None, max_tracked_dme_clients=None, chef_client_interval=None, influx_db_cloudlet_usage_metrics_retention=None, influx_db_metrics_retention=None, cloudlet_maintenance_timeout=None, update_vm_pool_timeout=None, update_trust_policy_timeout=None, dme_api_metrics_collection_interval=None, persistent_connection_metrics_collection_interval=None, cleanup_reservable_auto_cluster_idletime=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(shepherd_metrics_collection_interval=shepherd_metrics_collection_interval, shepherd_alert_evaluation_interval=shepherd_alert_evaluation_interval, shepherd_health_check_retries=shepherd_health_check_retries, shepherd_health_check_interval=shepherd_health_check_interval, auto_deploy_interval_sec=auto_deploy_interval_sec, auto_deploy_offset_sec=auto_deploy_offset_sec, auto_deploy_max_intervals=auto_deploy_max_intervals, create_cloudlet_timeout=create_cloudlet_timeout, update_cloudlet_timeout=update_cloudlet_timeout, create_app_inst_timeout=create_app_inst_timeout, update_app_inst_timeout=update_app_inst_timeout, delete_app_inst_timeout=delete_app_inst_timeout, create_cluster_inst_timeout=create_cluster_inst_timeout, update_cluster_inst_timeout=update_cluster_inst_timeout, delete_cluster_inst_timeout=delete_cluster_inst_timeout, master_node_flavor=master_node_flavor, load_balancer_max_port_range=load_balancer_max_port_range, max_tracked_dme_clients=max_tracked_dme_clients, chef_client_interval=chef_client_interval, influx_db_metrics_retention=influx_db_metrics_retention, influx_db_cloudlet_usage_metrics_retention=influx_db_cloudlet_usage_metrics_retention, cloudlet_maintenance_timeout=cloudlet_maintenance_timeout, update_vm_pool_timeout=update_vm_pool_timeout, update_trust_policy_timeout=update_trust_policy_timeout, dme_api_metrics_collection_interval=dme_api_metrics_collection_interval, persistent_connection_metrics_collection_interval=persistent_connection_metrics_collection_interval, cleanup_reservable_auto_cluster_idletime=cleanup_reservable_auto_cluster_idletime, use_defaults=use_defaults, include_fields=True)
        msg_dict = {'settings': msg}

        msg_dict_show = {}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)
