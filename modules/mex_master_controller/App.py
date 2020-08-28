import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_app rest')


class App(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateApp'
        self.delete_url = '/auth/ctrl/DeleteApp'
        self.show_url = '/auth/ctrl/ShowApp'
        self.update_url = '/auth/ctrl/UpdateApp'

    def _build(self, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, annotations=None, auto_prov_policy=None, access_type=None, configs_kind=None, configs_config=None, include_fields=False, use_defaults=True):

        _fields_list = []
        _app_name_field_number = "2.2"
        _app_version_field_number = "2.3"
        _developer_name_field_number = "2.1.2"
        _accessports_field_number = "7"
        _autoprov_field_number = "28"

        if app_name == 'default': app_name = shared_variables.app_name_default
        if app_version == 'default': app_version = shared_variables.app_version_default
        if developer_org_name == 'default': developer_org_name = shared_variables.developer_name_default

        if use_defaults:
            if app_name is None: app_name = shared_variables.app_name_default
            if developer_org_name is None: developer_org_name = shared_variables.developer_name_default
            if app_version is None: app_version = shared_variables.app_version_default
        
        if use_defaults and not include_fields:
            #if app_name is None: app_name = shared_variables.app_name_default
            #if developer_name is None: developer_name = shared_variables.developer_name_default
            #if app_version is None: app_version = shared_variables.app_version_default
            if image_type is None: image_type = 'ImageTypeDocker'
            if deployment is None: deployment = 'kubernetes'
            if default_flavor_name is None: default_flavor_name = shared_variables.flavor_name_default
            if access_ports is None: access_ports = 'tcp:1234'

            if image_path and image_path.lower() == 'no_default':
                # dont set the path
                pass
            else:
                if deployment.lower() == 'docker':
                    if image_path is None:
                        image_path='docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
                if deployment.lower() == 'kubernetes':
                    if image_path is None:
                        image_path='docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
                elif deployment.lower() == 'vm':
                    if image_path is None:
                        image_path = 'https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d'

        shared_variables.app_name_default = app_name
        
        if image_type == 'ImageTypeDocker':
            image_type = 1
        elif image_type == 'ImageTypeQCOW':
            image_type = 2
        elif image_type == 'ImageTypeHelm':
            image_type = 3            
        elif image_type == 'ImageTypeUnknown':
            image_type = 0

        if access_type and access_type.lower() == 'default':
            access_type = 0
        elif access_type and access_type.lower() == 'direct':
            access_type = 1
        elif access_type and access_type.lower() == 'loadbalancer':
            access_type = 2            

        if app_name == 'default':
            app_name = shared_variables.app_name_default
        if app_version == 'default':
            app_version = shared_variables.app_version_default
        if developer_org_name == 'default':
            developer_org_name = shared_variables.developer_name_default
        if default_flavor_name == 'default':
            default_flavor_name = shared_variables.flavor_name_default
        if image_path == 'default':
            image_path='docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
            
        app_dict = {}
        app_key_dict = {}
        configs_dict = {}
        
        if app_name is not None:
            app_key_dict['name'] = app_name
            _fields_list.append(_app_name_field_number)
        if app_version:
            app_key_dict['version'] = app_version
            _fields_list.append(_app_version_field_number)
        if developer_org_name is not None:
            app_key_dict['organization'] = developer_org_name
            _fields_list.append(_developer_name_field_number)
            
        if 'name' in app_key_dict or app_version or 'organization' in app_key_dict:
            app_dict['key'] = app_key_dict
        if image_type is not None:
            app_dict['image_type'] = image_type
        if image_path is not None and image_path != 'no_default':
            app_dict['image_path'] = image_path
        if default_flavor_name is not None:
            app_dict['default_flavor'] = {'name': default_flavor_name}
        if access_ports:
            app_dict['access_ports'] = access_ports
            _fields_list.append(_accessports_field_number)
        if command is not None:
            app_dict['command'] = command
        if auth_public_key is not None:
            app_dict['auth_public_key'] = auth_public_key
        if permits_platform_apps is not None:
            app_dict['permits_platform_apps'] = permits_platform_apps
        if deployment is not None:
            app_dict['deployment'] = deployment
        if access_type is not None:
            app_dict['access_type'] = access_type        
        if deployment_manifest is not None:
            app_dict['deployment_manifest'] = deployment_manifest
            #_fields_list.append(self._deployment_manifest_field)
        if scale_with_cluster:
            app_dict['scale_with_cluster'] = True
        if official_fqdn:
            app_dict['official_fqdn'] = official_fqdn
        if annotations:
            app_dict['annotations'] = annotations
        if auto_prov_policy is not None:
            app_dict['auto_prov_policy'] = auto_prov_policy
            _fields_list.append(_autoprov_field_number)
        if configs_kind:
            configs_dict['kind'] = configs_kind
        if configs_config:
            configs_dict['config'] = configs_config

        if configs_dict:
            app_dict['configs'] = [configs_dict]
            
            
        if include_fields and _fields_list:
            app_dict['fields'] = []
            for field in _fields_list:
                app_dict['fields'].append(field)

        return app_dict


    def create_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, annotations=None, auto_prov_policy=None, access_type=None, configs_kind=None, configs_config=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_org_name=developer_org_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn, annotations=annotations, auto_prov_policy=auto_prov_policy, access_type=access_type, configs_kind=configs_kind, configs_config=configs_config, use_defaults=use_defaults)
        msg_dict = {'app': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'version' in msg['key'] and 'organization' in msg['key']:
            msg_delete = self._build(app_name=msg['key']['name'], app_version=msg['key']['version'], developer_org_name=msg['key']['organization'], use_defaults=False)
            msg_dict_delete = {'app': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(app_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'app': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def delete_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, annotations=None, auto_prov_policy=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_org_name=developer_org_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn, annotations=annotations, auto_prov_policy=auto_prov_policy, use_defaults=use_defaults)
        msg_dict = {'app': msg}

        return self.delete(token=token, url=self.update_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, annotations=None, auto_prov_policy=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_org_name=developer_org_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn, annotations=annotations, auto_prov_policy=auto_prov_policy, use_defaults=use_defaults)
        msg_dict = {'app': msg}

        return self.show(token=token, url=self.update_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
        
    def update_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, annotations=None, auto_prov_policy=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_org_name=developer_org_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn, annotations=annotations, auto_prov_policy=auto_prov_policy, use_defaults=use_defaults, include_fields=True)
        msg_dict = {'app': msg}

        return self.update(token=token, url=self.update_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
