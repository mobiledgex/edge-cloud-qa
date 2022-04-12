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


class Flavor(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateFlavor'
        self.delete_url = '/auth/ctrl/DeleteFlavor'
        self.show_url = '/auth/ctrl/ShowFlavor'

    def _build(self, flavor_name=None, ram=None, vcpus=None, disk=None, optional_resources=None, use_defaults=True):
        flavor_dict = {}

        if use_defaults:
            if flavor_name is None: flavor_name = shared_variables.flavor_name_default
            if ram is None: ram = 1024 
            if vcpus is None: vcpus = 1 
            if disk is None: disk = 20

        shared_variables.flavor_name_default = flavor_name

        #"{\"flavor\":{\"key\":{\"name\":\"uu\"},\"ram\":1,\"vcpus\":1,\"disk\":1}}", "resp": "{}", "took": "85.424786ms"}
        
        if flavor_name is not None:
            flavor_dict['key'] = {'name': flavor_name}
        if ram is not None:
            flavor_dict['ram'] = int(ram)
        if vcpus is not None:
            flavor_dict['vcpus'] = int(vcpus)
        if disk is not None:
            flavor_dict['disk'] = int(disk)
        if optional_resources is not None:
            key, value = optional_resources.split('=')
            flavor_dict['opt_res_map'] = {key:value}
        
        return flavor_dict

    def create_flavor(self,
                      token=None,
                      region=None,
                      flavor_name=None,
                      ram=None,
                      vcpus=None,
                      disk=None,
                      optional_resources=None,
                      json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk, optional_resources=optional_resources, use_defaults=use_defaults)
        msg_dict = {'flavor': msg}

        thread_name = None
        if 'key' in msg:
            thread_name = msg['key']['name']
            
        msg_dict_delete = None
        if auto_delete and 'key' in msg:
            msg_delete = self._build(flavor_name=msg['key']['name'], use_defaults=False)
            msg_dict_delete = {'flavor': msg_delete}

        msg_dict_show = None
        if 'key' in msg:
            msg_show = self._build(flavor_name=msg['key']['name'], use_defaults=False)
            msg_dict_show = {'flavor': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name)

    def delete_flavor(self, token=None, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk, use_defaults=use_defaults)
        msg_dict = {'flavor': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_flavor(self, token=None, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(flavor_name, ram=ram, vcpus=vcpus, disk=disk, use_defaults=use_defaults)
        msg_dict = {'flavor': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

