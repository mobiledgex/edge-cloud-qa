import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex cloudlet rest')


class RunCommand(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)


    def _build(self, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, command=None, since=None, tail=None, time_stamps=None, follow=None, use_defaults=True):

        if use_defaults:
            if not app_name: app_name = shared_variables.app_name_default
            if not developer_org_name: developer_org_name = shared_variables.developer_name_default
            if not cluster_instance_name: cluster_instance_name = shared_variables.cluster_name_default
            if not cluster_instance_developer_org_name: cluster_developer_org_name = shared_variables.developer_name_default
            if not app_version: app_version = shared_variables.app_version_default
            if not cloudlet_name: cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_org_name: operator_org_name = shared_variables.operator_name_default

        cmd_run = f'appname={app_name} appvers={app_version} app-org={developer_org_name} cluster={cluster_instance_name} cloudlet-org={operator_org_name} cloudlet={cloudlet_name} --skipverify'

        if command:
            cmd_run += f' command={command}'
        if container_id:
            cmd_run += f' containerid={container_id}'
        if since:
            cmd_run += f' since={since}'
        if tail:
            cmd_run += f' tail={tail}'
        if time_stamps:
            cmd_run += f' timestamps={time_stamps}'
        if follow:
            cmd_run += f' follow={follow}'

        return cmd_run

    def run_command(self, mc_address=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, command=None, token=None, region=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, command=command, use_defaults=use_defaults)

        cmd = f'mcctl --addr https://{mc_address} region RunCommand region={region} {msg}'

        return self.run(token=token, command=cmd, region=region, use_defaults=use_defaults, use_thread=use_thread)

    def show_logs(self, mc_address=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, since=None, tail=None, time_stamps=None, follow=None, token=None, region=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, since=since, tail=tail, time_stamps=time_stamps, follow=follow, use_defaults=use_defaults)

        cmd = f'mcctl --addr https://{mc_address} region ShowLogs region={region} {msg}'
        
        return self.run(token=token, command=cmd, region=region, use_defaults=use_defaults, use_thread=use_thread)

