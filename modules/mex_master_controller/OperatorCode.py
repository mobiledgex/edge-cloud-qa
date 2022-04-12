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

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_mastercontroller rest')


class OperatorCode(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateOperatorCode'
        self.delete_url = '/auth/ctrl/DeleteOperatorCode'
        self.show_url = '/auth/ctrl/ShowOperatorCode'

    def _build(self, code=None, operator_org_name=None, use_defaults=True):
        code_dict = {}

        if use_defaults:
            if operator_org_name is None: operator_org_name = shared_variables.operator_name_default
            # if ram is None: ram = 1024
            # if vcpus is None: vcpus = 1
            # if disk is None: disk = 1

        shared_variables.operator_name_default = operator_org_name

        #posting {"operatorcode": {"code": "156", "operator_name": "dmuus"}, "region": "US"}

        if operator_org_name is not None:
            code_dict['organization'] = operator_org_name
        if code is not None:
            code_dict['code'] = code

        # if ram is not None:
        #     flavor_dict['ram'] = int(ram)
        # if vcpus is not None:
        #     flavor_dict['vcpus'] = int(vcpus)
        # if disk is not None:
        #     flavor_dict['disk'] = int(disk)
        # if optional_resources is not None:
        #     key, value = optional_resources.split('=')
        #     flavor_dict['opt_res_map'] = {key: value}

        return code_dict

    def create_operator_code(self,
                      token=None,
                      region=None,
                      operator_org_name=None,
                      code=None,
                      json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(operator_org_name=operator_org_name,code=code,use_defaults=use_defaults)
        msg_dict = {'operatorcode': msg}

        thread_name = None
        if 'code' in msg:
            thread_name = msg['code']

        msg_dict_delete = None
        if auto_delete and 'code' in msg and 'organization' in msg:
            msg_delete = self._build(operator_org_name=msg['organization'], code= msg['code'], use_defaults=False)
            msg_dict_delete = {'operatorcode': msg_delete}

        msg_dict_show = None
        if 'code' in msg and 'organization' in msg:
            msg_show = self._build(operator_org_name=msg['organization'],code= msg['code'], use_defaults=False)
            msg_dict_show = {'operatorcode': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url,
                           region=region, json_data=json_data, use_defaults=True, use_thread=use_thread,
                           create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show,
                           thread_name=thread_name)

    def delete_operator_code(self, token=None, region=None, json_data=None, operator_org_name=None, code=None,
                      use_defaults=True, use_thread=False):
        msg = self._build(operator_org_name=operator_org_name,code=code, use_defaults=use_defaults)
        msg_dict = {'operatorcode': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data,
                           use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_operator_code(self, token=None, region=None, flavor_name=None, json_data=None, operator_org_name=None, code=None,
                    use_defaults=True, use_thread=False):
        msg = self._build(operator_org_name=operator_org_name,code=code, use_defaults=use_defaults)
        msg_dict = {'operatorcode': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults,
                         use_thread=use_thread, message=msg_dict)

