import json
import logging
import asyncio
import websockets

import shared_variables

from mex_master_controller.MexOperation import MexOperation
from mex_master_controller.AppInstance import AppInstance

logger = logging.getLogger('mex cloudlet rest')


class RunDebug(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.runDebug_url = '/auth/ctrl/RunDebug'

    def _build(self, node_name=None, node_type=None, cloudlet_name=None, operator_org_name=None, region=None, args=None, command=None, pretty=None, use_defaults=True):

        #  {"debugrequest":{"cmd":"stop-cpu-profile","node":{"cloudlet_key":{"name":"automationDusseldorfCloudlet","organization":"TDG"},"name":"automationdusseldorfcloudlet","region":"EU","type":"crm"},"pretty":true}}
        rundebug_dict = {}
        cloudlet_key_dict = {}
        node_dict = {}
 
        if command:
            rundebug_dict['cmd'] = command
        if pretty:
            rundebug_dict['pretty'] = pretty
        if args:
            rundebug_dict['args'] = args

        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name
            
        if cloudlet_key_dict:
            node_dict['cloudlet_key'] = cloudlet_key_dict
        if region:
            node_dict['region'] = region
        if node_name:
            node_dict['name'] = node_name 
        if node_type:
            node_dict['type'] = node_type

        if node_dict:
           rundebug_dict['node'] = node_dict

        return rundebug_dict

    def run_debug(self, node_name=None, node_type=None, cloudlet_name=None, operator_org_name=None, args=None, command=None, pretty=None, token=None, region=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(node_name=node_name, node_type=node_type, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, args=args, command=command, pretty=pretty, use_defaults=use_defaults)

        msg_dict = {'debugrequest': msg}

        return self.show(token=token, url=self.runDebug_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
