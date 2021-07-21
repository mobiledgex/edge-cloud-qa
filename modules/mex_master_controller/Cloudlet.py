import logging
import re

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex cloudlet rest')


class Cloudlet(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateCloudlet'
        self.delete_url = '/auth/ctrl/DeleteCloudlet'
        self.show_url = '/auth/ctrl/ShowCloudlet'
        self.show_info_url = '/auth/ctrl/ShowCloudletInfo'
        self.inject_info_url = '/auth/ctrl/InjectCloudletInfo'
        self.update_url = '/auth/ctrl/UpdateCloudlet'
        self.metrics_url = '/auth/metrics/cloudlet'
        self.metrics_client_cloudlet_url = '/auth/metrics/clientcloudletusage'
        self.addmapping_url = '/auth/ctrl/AddCloudletResMapping'
        self.addrestag_url = '/auth/ctrl/AddResTag'
        self.manifest_url = '/auth/ctrl/GetCloudletManifest'
        self.revoke_url = '/auth/ctrl/RevokeAccessKey'
        self.resource_usage_url = '/auth/ctrl/GetCloudletResourceUsage'
        self.resourcequotaprops_url = '/auth/ctrl/GetCloudletResourceQuotaProps'
        self.cloudletusage_metrics_url = '/auth/metrics/cloudlet/usage'
        self.cloudletrefs_url = '/auth/ctrl/ShowCloudletRefs'
        self.findflavormatch_url = '/auth/ctrl/FindFlavorMatch'
        self.showflavorsfor_url = '/auth/ctrl/ShowFlavorsForCloudlet'

    def _build(self, cloudlet_name=None, operator_org_name=None, number_dynamic_ips=None, latitude=None, longitude=None, ip_support=None, access_uri=None, static_ips=None, platform_type=None, physical_name=None, container_version=None, package_version=None, maintenance_state=None, env_vars=None, access_vars=None, vm_pool=None, deployment_local=None, override_policy_container_version=None, crm_override=None, notify_server_address=None, infra_api_access=None, infra_config_flavor_name=None, infra_config_external_network_name=None, trust_policy=None, deployment_type=None, resource_list=None, default_resource_alert_threshold=None, gpudriver_name=None, gpudriver_org=None, kafka_cluster=None, kafka_user=None, kafka_password=None, flavor_name=None, include_fields=False, use_defaults=True):

        _fields_list = []
        _operator_name_field_number = "2.1"
        _cloudlet_name_field_number = "2.2"
        _container_version_field_number = "20"
        _package_version_field_number = "25"
        _maintenance_state_field_number = "30"
        _num_dynamic_ips_field_number = "8"
        _latitude_field_number = "5.1"
        _longitude_field_number = "5.2"
        _static_ips_field_number = "7"
        _override_policy_container_version_field_number = "31"
        _trust_policy_field_number = "37"
        _env_vars_field_number = "19"
        _resource_quotas_field_number = "39"
        _default_resource_alert_threshold_field_number = "40"
        _gpudriver_name_field_number = "45.1.1"
        _gpudriver_org_field_number = "45.1.2"

        if use_defaults:
            if cloudlet_name is None:
                cloudlet_name = shared_variables.cloudlet_name_default
            if operator_org_name is None:
                operator_org_name = shared_variables.operator_name_default
            if latitude is None:
                latitude = shared_variables.latitude_default
            if longitude is None:
                longitude = shared_variables.longitude_default
            if number_dynamic_ips is None:
                number_dynamic_ips = shared_variables.number_dynamic_ips_default
            if ip_support is None:
                ip_support = shared_variables.ip_support_default
            # if accessuri is None: self.accessuri = shared_variables.access_uri_default
            # if staticips is None: self.staticips = shared_variables.static_ips_default

        if ip_support == "IpSupportUnknown":
            ip_support = 0
        if ip_support == "IpSupportStatic":
            ip_support = 1
        if ip_support == "IpSupportDynamic":
            ip_support = 2

        if maintenance_state == 'NormalOperation':
            maintenance_state = 0
        elif maintenance_state == 'MaintenanceStart':
            maintenance_state = 1
        elif maintenance_state == 'MaintenanceStartNoFailover':
            maintenance_state = 5

        if infra_api_access == "DirectAccess":
            infra_api_access = 0
        elif infra_api_access == "RestrictedAccess":
            infra_api_access = 1

        resource_dict_list = None
        if resource_list is not None:
            resource_dict_list = []
            for resource in resource_list:
                resource_dict = {}
                if 'name' in resource and resource['name'] is not None:
                    resource_dict['name'] = resource['name']
                if 'value' in resource and resource['value'] is not None:
                    resource_dict['value'] = int(resource['value'])
                if 'alert_threshold' in resource and resource['alert_threshold'] is not None:
                    resource_dict['alert_threshold'] = int(resource['alert_threshold'])

                if resource_dict:
                    resource_dict_list.append(resource_dict)

        gpudriver_dict = {}
        gpudriver_dict_ref = {}
        if gpudriver_name is not None:
            gpudriver_dict['name'] = gpudriver_name
            _fields_list.append(_gpudriver_name_field_number)
            if gpudriver_org is not None:
                gpudriver_dict['organization'] = gpudriver_org
                _fields_list.append(_gpudriver_org_field_number)
            gpudriver_dict_ref['driver'] = gpudriver_dict

        # "{\"cloudlet\":{\"key\":{\"operator_key\":{\"name\":\"rrrr\"},\"name\":\"rrrr\"},\"location\":{\"latitude\":5,\"longitude\":5,\"timestamp\":{}},\"ip_support\":2,\"num_dynamic_ips\":2}}"
        cloudlet_dict = {}
        cloudlet_key_dict = {}

        if gpudriver_dict_ref:
            cloudlet_dict['gpu_config'] = gpudriver_dict_ref

        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name
            _fields_list.append(_operator_name_field_number)
        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
            _fields_list.append(_cloudlet_name_field_number)

        loc_dict = {}
        if latitude is not None:
            loc_dict['latitude'] = float(latitude)
            _fields_list.append(_latitude_field_number)

        if longitude is not None:
            loc_dict['longitude'] = float(longitude)
            _fields_list.append(_longitude_field_number)

        if cloudlet_key_dict:
            cloudlet_dict['key'] = cloudlet_key_dict
        if loc_dict:
            cloudlet_dict['location'] = loc_dict
        if number_dynamic_ips is not None:
            cloudlet_dict['num_dynamic_ips'] = int(number_dynamic_ips)
            _fields_list.append(_num_dynamic_ips_field_number)

        if ip_support is not None:
            cloudlet_dict['ip_support'] = ip_support
        if static_ips is not None:
            cloudlet_dict['static_ips'] = static_ips
            _fields_list.append(_static_ips_field_number)

        if physical_name is not None:
            cloudlet_dict['physical_name'] = physical_name
        if platform_type is not None:
            cloudlet_dict['platform_type'] = platform_type

        if crm_override is not None:
            if crm_override.lower() == "ignorecrm":
                crm_override = 2
            cloudlet_dict['crm_override'] = crm_override  # ignore errors from CRM

        if notify_server_address is not None:
            cloudlet_dict['notify_srv_addr'] = notify_server_address

        if container_version is not None:
            cloudlet_dict['container_version'] = container_version
            _fields_list.append(_container_version_field_number)

        if override_policy_container_version is not None:
            cloudlet_dict['override_policy_container_version'] = override_policy_container_version
            _fields_list.append(_override_policy_container_version_field_number)

        if package_version is not None:
            cloudlet_dict['package_version'] = package_version
            _fields_list.append(_package_version_field_number)

        if maintenance_state is not None:
            cloudlet_dict['maintenance_state'] = int(maintenance_state)
            _fields_list.append(_maintenance_state_field_number)

        if vm_pool is not None:
            cloudlet_dict['vm_pool'] = vm_pool

        if deployment_local is not None:
            cloudlet_dict['deployment_local'] = deployment_local

        if infra_api_access is not None:
            cloudlet_dict['infra_api_access'] = infra_api_access

        if trust_policy is not None:
            cloudlet_dict['trust_policy'] = trust_policy
            _fields_list.append(_trust_policy_field_number)

        infra_config_dict = {}
        if infra_config_flavor_name is not None:
            infra_config_dict['flavor_name'] = infra_config_flavor_name
        if infra_config_external_network_name is not None:
            infra_config_dict['external_network_name'] = infra_config_external_network_name
        if infra_config_dict:
            cloudlet_dict['infra_config'] = infra_config_dict

        if deployment_type:
            cloudlet_dict['deployment'] = deployment_type

        if kafka_cluster is not None:
            cloudlet_dict['kafka_cluster'] = kafka_cluster
        if kafka_user is not None:
            cloudlet_dict['kafka_user'] = kafka_user
        if kafka_password is not None:
            cloudlet_dict['kafka_password'] = kafka_password

        env_dict = {}
        if env_vars is not None:
            var_list = re.split('([A-Z_]+=)', env_vars)
            del var_list[0]

            for index, var in enumerate(var_list[0::2]):
                env_dict[re.sub('=$', '', var_list[index + (1 * index)])] = re.sub(',$', '', var_list[index + 1 + (1 * index)])
            cloudlet_dict['env_var'] = env_dict
            _fields_list.append(_env_vars_field_number)

        access_dict = {}
        if access_vars is not None:
            var_list = access_vars.split(',')
            for var in var_list:
                if 'CACERT_DATA' in var:
                    key, value = var.split('CACERT_DATA=')
                    key = 'CACERT_DATA'
                elif 'OPENRC_DATA' in var:
                    key, value = var.split('OPENRC_DATA=')
                    key = 'OPENRC_DATA'
                access_dict[key] = value
            cloudlet_dict['access_vars'] = access_dict

        if resource_dict_list is not None:
            cloudlet_dict['resource_quotas'] = resource_dict_list
            _fields_list.append(_resource_quotas_field_number)

        if default_resource_alert_threshold is not None:
            cloudlet_dict['default_resource_alert_threshold'] = int(default_resource_alert_threshold)
            _fields_list.append(_default_resource_alert_threshold_field_number)

        if flavor_name is not None:
            cloudlet_dict['flavor_name'] = flavor_name

        if include_fields and _fields_list:
            cloudlet_dict['fields'] = []
            for field in _fields_list:
                cloudlet_dict['fields'].append(field)

        return cloudlet_dict

    def _build_metrics(self, type_dict=None, selector=None, method=None, last=None, limit=None, number_samples=None, start_time=None, end_time=None, start_age=None, end_age=None, location_tile=None, device_os=None, device_model=None, device_carrier=None, data_network_type=None, use_defaults=True):
        metric_dict = {}
        if type_dict is not None:
            metric_dict.update(type_dict)
        if selector is not None:
            metric_dict['selector'] = selector
        if method is not None:
            metric_dict['method'] = method
        if limit is not None:
            try:
                metric_dict['limit'] = int(limit)
            except Exception:
                metric_dict['limit'] = limit
        if number_samples is not None:
            try:
                metric_dict['numsamples'] = int(number_samples)
            except Exception:
                metric_dict['numsamples'] = number_samples
        if last is not None:
            try:
                metric_dict['last'] = int(last)
            except ValueError:
                metric_dict['last'] = last
        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time
        if start_age is not None:
            metric_dict['startage'] = int(start_age)
        if end_age is not None:
            metric_dict['endage'] = int(end_age)
        if device_os is not None:
            metric_dict['deviceos'] = device_os
        if device_model is not None:
            metric_dict['devicemodel'] = device_model
        if device_carrier is not None:
            metric_dict['devicecarrier'] = device_carrier
        if data_network_type is not None:
            metric_dict['datanetworktype'] = data_network_type
        if location_tile is not None:
            metric_dict['locationtile'] = location_tile

        return metric_dict

    def _build_mapping(self, cloudlet_dict=None, mapping=None, use_defaults=True):
        map_dict = {}
        if cloudlet_dict is not None:
            map_dict.update(cloudlet_dict)

        if mapping is not None:
            tag, value = mapping.split('=')
            map_dict['cloudletresmap']['mapping'] = {tag: value}

        return map_dict

    def _build_restag(self, cloudlet_dict=None, tags=None, use_defaults=True):
        map_dict = {}
        if cloudlet_dict is not None:
            map_dict.update(cloudlet_dict)

        if tags is not None:
            tag, value = tags.split('=')
            map_dict['restagtable']['tags'] = {tag: value}

        return map_dict

    def _build_info(self, cloudlet_dict=None, container_version=None, controller=None, notify_id=None, os_max_ram=None, os_max_vcores=None, os_max_vol_gb=None, state=None, status=None, flavor_name=None, flavor_disk=None, flavor_ram=None, flavor_vcpus=None, use_defaults=True):
        info_dict = {}
        if cloudlet_dict is not None:
            info_dict.update(cloudlet_dict)

        if container_version is not None:
            info_dict['containerversion'] = container_version
        if controller is not None:
            info_dict['controller'] = controller
        if notify_id is not None:
            info_dict['notifyid'] = notify_id
        if os_max_ram is not None:
            info_dict['osmaxram'] = os_max_ram
        if os_max_vcores is not None:
            info_dict['osmaxvcores'] = os_max_vcores
        if os_max_vol_gb is not None:
            info_dict['osmaxvolgb'] = os_max_vol_gb
        if state is not None:
            if state == 'CloudletStateUnknown':
                info_dict['cloudletinfo']['state'] = 0
            elif state == 'CloudletStateErrors':
                info_dict['cloudletinfo']['state'] = 1
            elif state == 'CloudletStateReady':
                info_dict['cloudletinfo']['state'] = 2
            elif state == 'CloudletStateOffline':
                info_dict['cloudletinfo']['state'] = 3
            elif state == 'CloudletStateNotPresent':
                info_dict['cloudletinfo']['state'] = 4
            elif state == 'CloudletStateInit':
                info_dict['cloudletinfo']['state'] = 5
            elif state == 'CloudletStateUpgrade':
                info_dict['cloudletinfo']['state'] = 6
            elif state == 'CloudletStateNeedSync':
                info_dict['cloudletinfo']['state'] = 7

        if status is not None:
            info_dict['status'] = status

        return info_dict

    def create_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, static_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, access_vars=None, vm_pool=None, crm_override=None, notify_server_address=None, deployment_local=None, container_version=None, override_policy_container_version=None, infra_api_access=None, infra_config_flavor_name=None, infra_config_external_network_name=None, trust_policy=None, deployment_type=None, resource_list=None, default_resource_alert_threshold=None, gpudriver_name=None, gpudriver_org=None, kafka_cluster=None, kafka_user=None, kafka_password=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True, stream=True, stream_timeout=900):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, static_ips=static_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, env_vars=env_vars, access_vars=access_vars, vm_pool=vm_pool, deployment_local=deployment_local, container_version=container_version, override_policy_container_version=override_policy_container_version, crm_override=crm_override, notify_server_address=notify_server_address, infra_api_access=infra_api_access, infra_config_flavor_name=infra_config_flavor_name, infra_config_external_network_name=infra_config_external_network_name, trust_policy=trust_policy, deployment_type=deployment_type, resource_list=resource_list, default_resource_alert_threshold=default_resource_alert_threshold, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, kafka_cluster=kafka_cluster, kafka_user=kafka_user, kafka_password=kafka_password, use_defaults=use_defaults)
        msg_dict = {'cloudlet': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(cloudlet_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'cloudlet': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(cloudlet_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'cloudlet': msg_show}

        create_return = self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, stream=stream, stream_timeout=stream_timeout)

        if use_thread:
            return create_return
        else:
            return create_return[0]

    def delete_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False, stream=True, stream_timeout=600):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, crm_override=crm_override, use_defaults=use_defaults)
        msg_dict = {'cloudlet': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, stream=stream, stream_timeout=stream_timeout)

    def get_resource_usage(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, infra_usage=False, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults)
        if infra_usage:
            msg['infra_usage'] = True
        msg_dict = {'cloudletresourceusage': msg}

        return self.show(token=token, url=self.resource_usage_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def get_resourcequota_props(self, token=None, region=None, operator_org_name=None, platform_type=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(platform_type=platform_type, operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg_show = msg['key']
        msg_show['platform_type'] = msg['platform_type']
        msg_dict = {'cloudletresourcequotaprops': msg_show}

        return self.show(token=token, url=self.resourcequotaprops_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_cloudletrefs(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg_dict = {'cloudletrefs': msg}

        return self.show(token=token, url=self.cloudletrefs_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, json_data=None, use_defaults=True, use_thread=False, stream=True, stream_timeout=600):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, use_defaults=use_defaults)
        msg_dict = {'cloudlet': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, stream=stream, stream_timeout=stream_timeout)

    def show_cloudlet_info(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg_dict = {'cloudletinfo': msg}

        return self.show(token=token, url=self.show_info_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)

    def inject_cloudlet_info(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, container_version=None, controller=None, notify_id=None, os_max_ram=None, os_max_vcores=None, os_max_vol_gb=None, state=None, status=None, flavor_name=None, flavor_disk=None, flavor_ram=None, flavor_vcpus=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        inject_dict = {'cloudletinfo': msg}
        msg_dict = self._build_info(cloudlet_dict=inject_dict, controller=controller, container_version=container_version, notify_id=notify_id, os_max_ram=os_max_ram, os_max_vcores=os_max_vcores, os_max_vol_gb=os_max_vol_gb, state=state, status=status, flavor_name=flavor_name, flavor_disk=flavor_disk, flavor_ram=flavor_ram, flavor_vcpus=flavor_vcpus, use_defaults=False)

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(cloudlet_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_show = {'cloudletinfo': msg_show}

        return self.update(token=token, url=self.inject_info_url, show_url=self.show_info_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def update_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, container_version=None, package_version=None, maintenance_state=None, static_ips=None, trust_policy=None, resource_list=None, default_resource_alert_threshold=None, gpudriver_name=None, gpudriver_org=None, json_data=None, use_defaults=True, auto_delete=True, include_fields=True, use_thread=False, stream=True, stream_timeout=600):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, container_version=container_version, package_version=package_version, maintenance_state=maintenance_state, static_ips=static_ips, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, trust_policy=trust_policy, resource_list=resource_list, default_resource_alert_threshold=default_resource_alert_threshold, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, use_defaults=False, include_fields=include_fields)
        msg_dict = {'cloudlet': msg}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key']:
            msg_show = self._build(cloudlet_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'cloudlet': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show, stream=stream, stream_timeout=stream_timeout)[0]

    def get_cloudlet_metrics(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, selector=None, last=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        metric_dict = msg
        if 'key' in msg:
            metric_dict['cloudlet'] = msg['key']
            del metric_dict['key']
        else:
            metric_dict = msg

        msg_dict = self._build_metrics(type_dict=metric_dict, selector=selector, last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.metrics_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def get_client_cloudlet_metrics(self, method, token=None, region=None, cloudlet_name=None, operator_org_name=None, selector=None, limit=None, number_samples=None, start_time=None, end_time=None, start_age=None, end_age=None, cell_id=None, location_tile=None, device_os=None, device_model=None, device_carrier=None, data_network_type=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        metric_dict = msg
        if 'key' in msg:
            metric_dict['cloudlet'] = msg['key']
            del metric_dict['key']

        msg_dict = self._build_metrics(type_dict=metric_dict, selector=selector, limit=limit, number_samples=number_samples, start_time=start_time, end_time=end_time, start_age=start_age, end_age=end_age, location_tile=location_tile, device_os=device_os, device_model=device_model, device_carrier=device_carrier, data_network_type=data_network_type)

        return self.show(token=token, url=self.metrics_client_cloudlet_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def get_cloudletusage_metrics(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, selector=None, last=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        metric_dict = msg
        if 'key' in msg:
            metric_dict['cloudlet'] = msg['key']
        else:
            metric_dict = msg

        msg_dict = self._build_metrics(type_dict=metric_dict, selector=selector, last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.cloudletusage_metrics_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def add_cloudlet_resource_mapping(self, token=None, region=None, cloudlet_name=None, operator_org_name=None, mapping=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)

        map_dict = {'cloudletresmap': msg}
        msg_dict = self._build_mapping(cloudlet_dict=map_dict, mapping=mapping)

        # msg_dict_delete = None
        # if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']:
        #     msg_delete = self._build(cloudlet_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
        #     map_dict_delete = {'cloudletresmap': msg_delete}
        #     msg_dict_delete = self._build_mapping(cloudlet_dict=map_dict_delete, mapping=mapping)

        # msg_dict_show = None
        # if 'key' in msg:
        #    msg_show = self._build(cloudlet_name=msg['key']['name'], use_defaults=False)
        #    msg_dict_show = {'app': msg_show}

        return self.create(token=token, url=self.addmapping_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict)

    def add_resource_tag(self, token=None, region=None, resource_name=None, operator_org_name=None, tags=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        msg = self._build(cloudlet_name=resource_name, operator_org_name=operator_org_name, use_defaults=False)

        map_dict = {'restagtable': msg}
        msg_dict = self._build_restag(cloudlet_dict=map_dict, tags=tags)

        # msg_dict_delete = None
        # if auto_delete and 'key' in msg and 'name' in msg['key']:
        #     msg_delete_pre = self._build(cloudlet_name=msg['key']['name'], operator_org_name=msg['key']['organization'], use_defaults=False)
        #     map_dict_del = {'restagtable': msg_delete_pre}
        #     msg_delete = self._build_restag(cloudlet_dict=map_dict_del, tags=tags, use_defaults=False)
        #     map_dict_delete = {'restagtable': msg_delete}
        #     msg_dict_delete = self._build_mapping(cloudlet_dict=map_dict_delete, tags=tags)

        # msg_dict_show = None
        # if 'key' in msg:
        #    msg_show = self._build(cloudlet_name=msg['key']['name'], use_defaults=False)
        #    msg_dict_show = {'app': msg_show}

        return self.create(token=token, url=self.addrestag_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict)

    def get_cloudlet_manifest(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        msg_dict = {'cloudletkey': msg['key']}

        return self.show(token=token, url=self.manifest_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def revoke_access_key(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        msg_dict = {'cloudletkey': msg['key']}

        return self.show(token=token, url=self.revoke_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def find_flavor_match(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, flavor_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, flavor_name=flavor_name, use_defaults=False)
        msg_dict = {'FlavorMatch': msg}

        return self.show(token=token, url=self.findflavormatch_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def show_flavors_for_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        msg_dict = {'cloudletkey': msg['key']}

        return self.show(token=token, url=self.showflavorsfor_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
