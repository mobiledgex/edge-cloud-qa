# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

    def _build(self, node_name=None, node_type=None, region=None, cloudlet_name=None, operator_org_name=None, args=None, command=None, pretty=None, timeout=None, use_defaults=True):

        #  {"debugrequest":{"cmd":"stop-cpu-profile","node":{"cloudlet_key":{"name":"automationParadiseCloudlet","organization":"GDDT"},"name":"automationparadisecloudlet","region":"EU","type":"crm"},"pretty":true}}
        rundebug_dict = {}
        cloudlet_key_dict = {}
        node_dict = {}
         
        if command:
            rundebug_dict['cmd'] = command
        if pretty:
            rundebug_dict['pretty'] = pretty
        if args:
            rundebug_dict['args'] = args
        if timeout:
            rundebug_dict['timeout'] = timeout

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

    def run_debug(self, timeout=None, node_name=None, node_type=None, region=None, cloudlet_name=None, operator_org_name=None, args=None, command=None, pretty=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(timeout=timeout, node_name=node_name, node_type=node_type, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, args=args, command=command, pretty=pretty, use_defaults=use_defaults)

        msg_dict = {'debugrequest': msg}

        return self.show(token=token, url=self.runDebug_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
