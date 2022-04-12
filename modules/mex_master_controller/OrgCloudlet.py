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

logger = logging.getLogger('mex_orgcloudlet rest')


class OrgCloudlet(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/orgcloudlet/create'
        self.delete_url = '/auth/orgcloudlet/delete'
        self.show_url = '/auth/orgcloudlet/show'

    def _build(self, org_name=None, use_defaults=True):
        pool = None

        if org_name == 'default':
            org_name = shared_variables.organization_name_default
            
        if use_defaults:
            if org_name is None: org_name = shared_variables.organization_name_default

        pool_dict = {}

        if org_name is not None:
            pool_dict['org'] = org_name

        return pool_dict

    def show_org_cloudlet(self, token=None, region=None, org_name=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(org_name=org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

