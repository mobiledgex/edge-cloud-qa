import logging
import asyncio
import websockets

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex cloudlet rest')


class RunCommand(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.runCommand_url = '/auth/ctrl/RunCommand'
        self.showLogs_url = '/auth/ctrl/ShowLogs'
        self.runConsole_url = '/auth/ctrl/RunConsole'
        self.accessCloudlet_url = '/auth/ctrl/AccessCloudlet'

    def _build(self, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, use_defaults=True):

        if use_defaults:
            if not app_name:
                app_name = shared_variables.app_name_default
            if not developer_org_name:
                developer_org_name = shared_variables.developer_name_default
            if not cluster_instance_name:
                cluster_instance_name = shared_variables.cluster_name_default
            if not cluster_instance_developer_org_name:
                cluster_instance_developer_org_name = shared_variables.developer_name_default
            if not app_version:
                app_version = shared_variables.app_version_default
            if not cloudlet_name:
                cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_org_name:
                operator_org_name = shared_variables.operator_name_default

        # curl https://console-qa.mobiledgex.net:443/api/v1/auth/ctrl/RunCommand -X POST  -H "Content-Type: application/json" -H "Authorization: Bearer $BT" -d '{"region":"EU","ExecRequest":{"app_inst_key":{"app_key":{"organization":"testmonitor","name":"myapp","version":"v1"},"cluster_inst_key":{"cluster_key":{"name":"k8sshared"},"cloudlet_key":{"organization":"GDDT","name":"automationParadiseCloudlet"}}},"cmd":{"command":"ls"}}}'

        runcommand_dict = {}
        appinst_key_dict = {}
        app_key_dict = {}
        cloudlet_key_dict = {}
        clusterinst_key_dict = {}
        cluster_key_dict = {}

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

        if app_key_dict:
            appinst_key_dict['app_key'] = app_key_dict
        if clusterinst_key_dict:
            appinst_key_dict['cluster_inst_key'] = clusterinst_key_dict

        if appinst_key_dict:
            runcommand_dict['app_inst_key'] = appinst_key_dict

        if container_id is not None:
            runcommand_dict['container_id'] = container_id

        return runcommand_dict

    def _build_cmd(self, type_dict, command):
        runcommand_dict = {}

        msg_dict = {}
        msg_dict.update(type_dict)

        runcommand_dict.update(type_dict)
        if command is not None:
            msg_dict['cmd'] = {'command': command}

        return msg_dict

    def _build_show(self, type_dict, since=None, tail=None, time_stamps=None, follow=None):
        show_dict = {}

        msg_dict = {}
        msg_dict.update(type_dict)

        if since:
            show_dict['since'] = since
        if tail:
            try:
                show_dict['tail'] = int(tail)
            except Exception:
                show_dict['tail'] = tail
        if time_stamps:
            show_dict['timestamps'] = time_stamps
        if follow:
            print('*WARN*', 'follow', follow)
            show_dict['follow'] = follow

        if show_dict:
            msg_dict['log'] = show_dict

        return msg_dict

    def _build_mcctl(self, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, command=None, since=None, tail=None, time_stamps=None, follow=None, use_defaults=True):

        if use_defaults:
            if not app_name:
                app_name = shared_variables.app_name_default
            if not developer_org_name:
                developer_org_name = shared_variables.developer_name_default
            if not cluster_instance_name:
                cluster_instance_name = shared_variables.cluster_name_default
            if not cluster_instance_developer_org_name:
                cluster_instance_developer_org_name = shared_variables.developer_name_default
            if not app_version:
                app_version = shared_variables.app_version_default
            if not cloudlet_name:
                cloudlet_name = shared_variables.cloudlet_name_default
            if not operator_org_name:
                operator_org_name = shared_variables.operator_name_default

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

    def _build_access(self, type_dict, node_name=None, node_type=None, cloudlet_name=None, operator_org_name=None, command=None, clusterkey=None, clusterinst=None, appkey=None, appinstkey=None, use_defanlts=False):

        # {"Region":"US","ExecRequest":{"app_inst_key":{"app_key":{},"cluster_inst_key":{"cluster_key":{},"cloudlet_key":{"organization":"packet","name":"DFWVMW"}}},"cmd":{"command":"docker ps;exit","cloudlet_mgmt_node":{"type":"platformvm","name":"DFWVMW-packet-pf"}}}}

        cmd_key_dict = {}
        node_dict = {}

        msg_dict = {}
        msg_dict.update(type_dict)

        if command is not None:
            cmd_key_dict['command'] = command
        if node_name is not None:
            node_dict['name'] = node_name
        if node_type is not None:
            node_dict['type'] = node_type
        if node_dict:
            cmd_key_dict['cloudlet_mgmt_node'] = node_dict
        if cmd_key_dict:
            msg_dict['cmd'] = cmd_key_dict

        return msg_dict

    def access_cloudlet(self, node_name=None, node_type=None, region=None, cloudlet_name=None, operator_org_name=None, command=None, token=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=False)
        msg_access = self._build_access(type_dict=msg, node_name=node_name, node_type=node_type, command=command)
        return self._show(token=token, url=self.accessCloudlet_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_access)

    def run_command(self, mc_address=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, command=None, token=None, region=None, json_data=None, timeout=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, use_defaults=use_defaults)
        msg_run = self._build_cmd(type_dict=msg, command=command)

        return self._show(token=token, url=self.runCommand_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_run)

    def show_logs(self, mc_address=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, since=None, tail=None, time_stamps=None, follow=None, token=None, region=None, json_data=None, timeout=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, use_defaults=use_defaults)

        msg_show = self._build_show(type_dict=msg, since=since, tail=tail, time_stamps=time_stamps, follow=follow)

        return self._show(token=token, url=self.showLogs_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_show)

    def run_console(self, mc_address=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, token=None, region=None, json_data=None, timeout=None, use_defaults=True, use_thread=False):
        msg = self._build(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, use_defaults=use_defaults)
        msg_dict = {'ExecRequest': msg}

        # msg_show = self._build_show(type_dict=msg, since=since, tail=tail, time_stamps=time_stamps)

        # return self._show(token=token, url=self.runConsole_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg)
        return self.show(token=token, url=self.runConsole_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def _show(self, token=None, url=None, region=None, json_data=None, timeout=None, use_defaults=True, use_thread=False, message=None):
        msg_dict = {'ExecRequest': message}
        resp = self.show(token=token, url=url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
        url = resp[0]['access_url']

        async def wsconnect():
            async with websockets.connect(url) as websocket:
                dataqueue = ''
                while True:
                    try:
                        data = await websocket.recv()
                        logging.debug(f'data recved:{data}')
                        dataqueue += data
                    except websockets.exceptions.ConnectionClosed as e:
                        logging.debug(f'connection already closed exception:{e}')
                        break
                    except websockets.exceptions.ConnectionClosedOK as e:
                        logging.debug(f'connection closed properly exception:{e}')
                        break
                    except websockets.exceptions.ConnectionClosedError as e:
                        logging.debug(f'connection closed error exception:{e}')
                        break

                    except Exception as e:
                        logging.error(f'ws exception:{e}')
                        return

                return dataqueue
        data = asyncio.get_event_loop().run_until_complete(wsconnect())

        # if 'Error' in data:
        #    raise Exception(f'error={data}')

        return data

    def run_command_mcctl(self, mc_address=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, command=None, token=None, region=None, timeout=None, use_defaults=True, use_thread=False):
        msg = self._build_mcctl(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, command=command, use_defaults=use_defaults)

        cmd = f'mcctl --addr https://{mc_address} region RunCommand region={region} {msg}'

        return self.run(token=token, command=cmd, region=region, timeout=timeout, use_defaults=use_defaults, use_thread=use_thread)

    def show_logs_mcctl(self, mc_address=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, since=None, tail=None, time_stamps=None, follow=None, token=None, region=None, use_defaults=True, use_thread=False):
        msg = self._build_mcctl(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, since=since, tail=tail, time_stamps=time_stamps, follow=follow, use_defaults=use_defaults)

        cmd = f'mcctl --addr https://{mc_address} region ShowLogs region={region} {msg}'

        return self.run(token=token, command=cmd, region=region, use_defaults=use_defaults, use_thread=use_thread)

    def run_console_mcctl(self, mc_address=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, command=None, token=None, region=None, use_defaults=True, use_thread=False):
        msg = self._build_mcctl(app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, command=command, use_defaults=use_defaults)

        cmd = f'mcctl --addr https://{mc_address} region RunConsole region={region} {msg}'

        return self.run(token=token, command=cmd, region=region, timeout=30, use_defaults=use_defaults, use_thread=use_thread)
